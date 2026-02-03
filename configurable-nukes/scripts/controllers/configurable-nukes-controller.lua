local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("__TheEckelmonster-core-library__.libs.data.data")

local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local String_Utils = require("scripts.utils.string-utils")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name })

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local rocket_ready_status = defines.rocket_silo_status.rocket_ready

local cache_attributes = {}
setmetatable(cache_attributes, { __mode = 'k' })

local cache = {
    surfaces = {},
}

local launch_attempts = { attempts = 0, successes = 0, }
cache_attributes[launch_attempts] = Data:new({ time_to_live = 0, valid = true })

function configurable_nukes_controller.on_nth_tick(event)
    -- Log.debug("configurable_nukes_controller.on_nth_tick")
    -- Log.info(event)

    if (not se_active and not Constants.planets_dictionary) then
        Constants.get_planets(not Constants.planets_dictionary)
    end

    if (not cache.print_space_launched_time_to_target_message or not cache_attributes[cache.print_space_launched_time_to_target_message] or cache_attributes[cache.print_space_launched_time_to_target_message].time_to_live < game.tick) then
        cache.print_space_launched_time_to_target_message = { value = true }
        cache_attributes[cache.print_space_launched_time_to_target_message] = Data:new({ time_to_live = game.tick + 20})
        ICBM_Utils.print_space_launched_time_to_target_message()
    end

    if (not cache.locals or not cache_attributes[cache.locals] or cache_attributes[cache.locals].time_to_live < game.tick) then
        cache.locals = {}

        cache.locals.num_surfaces_to_process = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_SURFACES_PROCESSED_PER_TICK.name, }) or 1
        cache.locals.failure_limit = math.floor((cache.locals.num_surfaces_to_process * 4) ^ 0.25 + cache.locals.num_surfaces_to_process / 2)

        cache_attributes[cache.locals] = Data:new({ time_to_live = game.tick + 150 + Random(90), valid = true })
    end

    local num_surfaces_to_process = cache.locals.num_surfaces_to_process or 1
    local failure_limit = cache.locals.failure_limit or 1
    local i, loops, failures = 0, 0, 0
    while i < num_surfaces_to_process do
        if (not sa_active and se_active and i > 0) then
            break
        end

        if (loops > 2 ^ 8) then break end
        if (failures > failure_limit) then break end
        i = i + 1
        loops = loops + 1
        if (se_active) then
            if (not cache.surfaces or not cache_attributes[cache.surfaces] or cache_attributes[cache.surfaces].time_to_live < game.tick) then
                cache.surfaces = Constants.get_space_exploration_surfaces()
                cache_attributes[cache.surfaces] = Data:new({ time_to_live = game.tick + 17000 + Random(1000), valid = true })
            end
            configurable_nukes_controller.surface_name, configurable_nukes_controller.surface = next(cache.surfaces, configurable_nukes_controller.surface_name)
        else
            if (not cache.planets or not cache_attributes[cache.planets] or cache_attributes[cache.planets].time_to_live < game.tick) then
                cache.planets = Constants.get_planets()
                cache_attributes[cache.planets] = Data:new({ time_to_live = game.tick + 17000 + Random(1000), valid = true })
            end
            configurable_nukes_controller.planet_index, configurable_nukes_controller.planet = next(cache.planets, configurable_nukes_controller.planet_index)
        end

        local space_location = se_active and configurable_nukes_controller.surface or configurable_nukes_controller.planet
        -- Log.debug(space_location and space_location.name)

        if (not space_location or (not configurable_nukes_controller.planet_index and not configurable_nukes_controller.surface_name)) then
            failures = failures + 1
            if (failures > failure_limit) then break end
            if (se_active) then
                goto continue
            else
                break
            end
        end
        if (not space_location) then
            failures = failures + 1
            if (failures > failure_limit) then break end
            goto continue
        end
        if (not space_location.surface or not space_location.surface.valid) then
            failures = failures + 1
            if (failures > failure_limit) then break end
            goto continue
        end
        if (se_active and String_Utils.find_invalid_substrings(space_location.name)) then
            failures = failures + 1
            if (failures > failure_limit) then break end
            goto continue
        end

        if (not launch_attempts or not cache_attributes[launch_attempts] or cache_attributes[launch_attempts].time_to_live < game.tick) then
            launch_attempts = { attempts = 0, successes = 0, }
            cache_attributes[launch_attempts] = Data:new({ time_to_live = game.tick + 30 + ((Random(25, 100) + Random(25, 100)) / 1.5), valid = true })
        end

        if (    cache_attributes[launch_attempts]
            and cache_attributes[launch_attempts].time_to_live - game.tick <= game.tick - cache_attributes[launch_attempts].created
            and (
                    launch_attempts.attempts == 0
                or  launch_attempts.successes == 0
            )
        ) then
            goto continue
        end

        local circuit_connected_silos_on_platforms = cache.circuit_connected_silos_on_platforms or {}
        if (not circuit_connected_silos_on_platforms or not next(circuit_connected_silos_on_platforms)) then
            cache.circuit_connected_silos_on_platforms = circuit_connected_silos_on_platforms or {}

            if (sa_active) then
                if (game.forces["player"] and game.forces["player"].platforms) then

                    if (not cache.all_rocket_silo_meta_data or not cache_attributes[cache.all_rocket_silo_meta_data] or cache_attributes[cache.all_rocket_silo_meta_data].time_to_live < game.tick) then
                        cache.all_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_all_rocket_silo_meta_data()
                        cache_attributes[cache.all_rocket_silo_meta_data] = Data:new({ time_to_live = game.tick + 2700, valid = true })
                    end

                    local all_rocket_silo_meta_data = cache.all_rocket_silo_meta_data

                    cache.space_platform_index, cache.space_platform = next(game.forces["player"].platforms, cache.space_platform_index)
                    if (not cache.space_platform or not cache.space_platform.valid) then cache.space_platform_index, cache.space_platform = next(game.forces["player"].platforms, nil) end

                    local space_platform = cache.space_platform
                    if (space_platform and space_platform.valid) then
                        if (not space_platform.surface or not space_platform.surface.valid) then goto continue_2 end

                        if (not cache.surfaces[space_platform.surface.name]) then cache.surfaces[space_platform.surface.name] = {} end
                        if (not cache.surfaces[space_platform.surface.name][space_platform]) then cache.surfaces[space_platform.surface.name][space_platform] = {} end

                        if (    not cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data
                            or  not cache_attributes[cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data]
                            or  cache_attributes[cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data].time_to_live < game.tick
                        ) then
                            cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data = { meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_platform.surface.name, { create = false }) }
                            cache_attributes[cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data] = Data:new({ time_to_live = game.tick + 2100 + Random(600), valid = true })
                        end

                        local rocket_silo_meta_data = cache.surfaces[space_platform.surface.name][space_platform].rocket_silo_meta_data.meta_data
                        if (rocket_silo_meta_data and rocket_silo_meta_data.valid) then
                            if (rocket_silo_meta_data.rocket_silos and next(rocket_silo_meta_data.rocket_silos, nil)) then
                                for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                                    if (v.circuit_network_data and v.entity and v.entity.valid and v.entity.rocket_silo_status == rocket_ready_status) then
                                        circuit_connected_silos_on_platforms[k] = v
                                    end
                                end
                            end
                        else
                            goto continue_2
                        end

                        if (not rocket_silo_meta_data.rocket_silos or not next(rocket_silo_meta_data.rocket_silos, nil)) then
                            all_rocket_silo_meta_data[space_platform.surface.name] = nil
                        end

                        ::continue_2::
                    end
                end
            end
        end

        if (not cache[space_location.surface.name]) then cache[space_location.surface.name] = {} end
        if (not cache[space_location.surface.name].rocket_silos) then cache[space_location.surface.name].rocket_silos = {} end

        if (not cache[space_location.surface.name].rocket_silo_meta_data or not cache_attributes[cache[space_location.surface.name].rocket_silo_meta_data] or cache_attributes[cache[space_location.surface.name].rocket_silo_meta_data].time_to_live < game.tick) then
            cache[space_location.surface.name].rocket_silo_meta_data = { meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_location.surface.name) }
            cache_attributes[cache[space_location.surface.name].rocket_silo_meta_data] = Data:new({ time_to_live = game.tick + 2345 + Random(234), valid = true })
        end

        local rocket_silo_meta_data = cache[space_location.surface.name].rocket_silo_meta_data.meta_data

        if (not next(cache[space_location.surface.name].rocket_silos)) then
            if (rocket_silo_meta_data and rocket_silo_meta_data.valid) then
                if (not cache[space_location.surface.name].rocket_silos or not cache_attributes[cache[space_location.surface.name].rocket_silos] or cache_attributes[cache[space_location.surface.name].rocket_silos].time_to_live < game.tick) then
                    cache[space_location.surface.name].rocket_silos = {}
                    cache_attributes[cache[space_location.surface.name].rocket_silos] = Data:new({ time_to_live = game.tick + 30 + ((Random(25, 100) + Random(25, 100)) / 1.5), valid = true })
                end

                local attributes = cache_attributes[cache[space_location.surface.name].rocket_silos]
                if (not attributes.add_attempts) then attributes.add_attempts = 0 end
                if (not attributes.added_count) then attributes.added_count = 0 end
                if (not attributes.successful_launches) then attributes.added_count = 0 end

                if (attributes.add_attempts > 12 and attributes.add_attempts > attributes.added_count * 1.5) then goto continue end
                if (attributes.add_attempts > 3 and attributes.added_count == 0) then goto continue end

                for count = 0, 2, 1 do
                    attributes.add_attempts = attributes.add_attempts + 1
                    attributes.key, attributes.value = next(rocket_silo_meta_data.rocket_silos, attributes.key)

                    if (attributes.key and attributes.value) then
                        local entity = attributes.value.entity
                        if (entity and entity.valid and entity.type == "rocket-silo" and entity.rocket_silo_status == rocket_ready_status) then
                            attributes.added_count = attributes.added_count + 1
                            cache[space_location.surface.name].rocket_silos[attributes.key] = attributes.value
                        end
                    end
                end
            end
        end

        local index = cache[space_location.surface.name].rocket_silos and next(cache[space_location.surface.name].rocket_silos)
        local rocket_silo_data = cache[space_location.surface.name].rocket_silos[index]
        if (rocket_silo_data and rocket_silo_data.valid) then
            if (cache[space_location.surface.name].rocket_silos[rocket_silo_data.unit_number]) then cache[space_location.surface.name].rocket_silos[rocket_silo_data.unit_number] = nil end
            if (rocket_silo_data.entity and rocket_silo_data.entity.valid and rocket_silo_data.entity.rocket_silo_status == rocket_ready_status) then
                launch_attempts.attempts = launch_attempts.attempts + 1
                if (Circuit_Network_Service.attempt_launch_silos({ rocket_silos = { rocket_silo_data } })) then
                    launch_attempts.successes = launch_attempts.successes + 1
                end
            end
        end

        if (sa_active) then
            local index = circuit_connected_silos_on_platforms and next(circuit_connected_silos_on_platforms)
            local rocket_silo_data = circuit_connected_silos_on_platforms and circuit_connected_silos_on_platforms[index] or nil
            if (rocket_silo_data and rocket_silo_data.valid) then
                if (circuit_connected_silos_on_platforms[rocket_silo_data.unit_number]) then circuit_connected_silos_on_platforms[rocket_silo_data.unit_number] = nil end
                if (rocket_silo_data.entity and rocket_silo_data.entity.valid and rocket_silo_data.entity.rocket_silo_status == rocket_ready_status) then
                    launch_attempts.attempts = launch_attempts.attempts + 1
                    if (Circuit_Network_Service.attempt_launch_silos({ rocket_silos = { rocket_silo_data } })) then
                        launch_attempts.successes = launch_attempts.successes + 1
                    end
                end
            end
        end

        ::continue::
    end

    storage.configurable_nukes_controller = {
        planet_index = configurable_nukes_controller.planet_index,
        surface_name = configurable_nukes_controller.surface_name,
        space_location = configurable_nukes_controller.space_location,
        tick = tick,
        prev_tick = configurable_nukes_controller.tick,
    }
end
--[[ Registerd in events.lua ]]

function configurable_nukes_controller.on_runtime_mod_setting_changed(event)
    Log.debug("configurable_nukes_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name) then
        local new_nth_tick = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name, reindex = true })
        if (new_nth_tick ~= nil and type(new_nth_tick) == "number" and new_nth_tick >= 1 and new_nth_tick <= 60) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = configurable_nukes_controller.nth_tick
            Event_Handler:unregister_event({
                event_name = "on_nth_tick",
                nth_tick = prev_nth_tick,
                source_name = "configurable_nukes_controller.on_nth_tick",
            })

            Event_Handler:register_event({
                event_name = "on_nth_tick",
                nth_tick = new_nth_tick,
                source_name = "configurable_nukes_controller.on_nth_tick",
                func_name = "configurable_nukes_controller.on_nth_tick",
                func = configurable_nukes_controller.on_nth_tick,
            })
            configurable_nukes_controller.nth_tick = new_nth_tick
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func = configurable_nukes_controller.on_runtime_mod_setting_changed,
})

return configurable_nukes_controller