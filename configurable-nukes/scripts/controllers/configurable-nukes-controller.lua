local Cache_Attributes_Data = require("scripts.data.cache.cache-attribute-data")
local Constants = require("scripts.constants.constants")
local CU = require("scripts.utils.cache-utils")
local Cache_Utils, Reinit_Cache = CU[1], CU[2]
local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local Custom_Events = require("prototypes.custom-events.custom-events")
local Hash_Key_Data = require("scripts.data.hash-key-data")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rhythm = require("scripts.rhythm")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local String_Utils = require("scripts.utils.string-utils")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick_surface_processing = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name })

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local rocket_ready_status = defines.rocket_silo_status.rocket_ready

configurable_nukes_controller.rhythm = { name = configurable_nukes_controller.name, }
local rhythm = Rhythm.new(configurable_nukes_controller.rhythm, configurable_nukes_controller.rhythm)
local Prime_Random = Rhythm.prime_random

Event_Handler:register_events({
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = configurable_nukes_controller.name .. ".init_rhythm",
        func_name = rhythm.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_reset_cache.name,
        source_name = configurable_nukes_controller.name .. ".init_rhythm",
        func_name = rhythm.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = configurable_nukes_controller.name .. ".init_rhythm",
        func_name = configurable_nukes_controller.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_reset_cache.name,
        source_name = configurable_nukes_controller.name .. ".init_rhythm",
        func_name = configurable_nukes_controller.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_init_cache.name,
        source_name = configurable_nukes_controller.name .. ".init_rhythm",
        func_name = configurable_nukes_controller.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
    },
})

local cache_handle = Cache_Utils.register_cache({ name = configurable_nukes_controller.name, })
configurable_nukes_controller.cache_handle = cache_handle
Event_Handler:register_event(
{
    event_name = Custom_Events.cn_init_cache.name,
    source_name = configurable_nukes_controller.name .. ".reinit_cache",
    func_name = configurable_nukes_controller.name .. ".reinit_cache",
    func = configurable_nukes_controller.reinit_cache,
})

local hash_keys = nil
local cache, cache_attributes = nil, nil

function configurable_nukes_controller.reinit_cache()
    cache_handle.__reinit_cache()
    cache, cache_attributes = Reinit_Cache(cache_handle, cache_handle.name)

    storage.hash_keys = storage.hash_keys or Hash_Key_Data:new({})
    Hash.keys = Hash.keys or storage.hash_keys

    storage.hash_keys[cache_handle.name] = storage.hash_keys[cache_handle.name] or Hash_Key_Data:new({ name = cache_handle.name, })
    hash_keys = storage.hash_keys[cache_handle.name]

    hash_keys["surfaces"] = Hash.keys[hash_keys["surfaces"] or false] and hash_keys["surfaces"] or Hash.hash("surfaces")

    cache[hash_keys["surfaces"]] = cache[hash_keys["surfaces"]] or {}
    cache_attributes[cache[hash_keys["surfaces"]]] = cache_attributes[cache[hash_keys["surfaces"]]] or Cache_Attributes_Data:new({ cas = cache_attributes, k = cache[hash_keys["surfaces"]], })
end
cache_handle.reinit_cache = configurable_nukes_controller.reinit_cache

---

function configurable_nukes_controller.on_nth_tick(event)
    -- Log.debug("configurable_nukes_controller.on_nth_tick")
    -- Log.info(event)

    local cache, cache_attributes = Cache(cache_handle.name), Cache_Attributes(cache_handle.name)
    local hash_string = nil

    storage.hash_keys = storage.hash_keys or {}
    storage.hash_keys[cache_handle.name] = storage.hash_keys[cache_handle.name] or {}
    hash_keys = storage.hash_keys[cache_handle.name]

    if (not se_active and not Constants.planets_dictionary) then
        Constants.get_planets(not Constants.planets_dictionary)
    end

    if (not cache.print_space_launched_time_to_target_message or not cache_attributes[cache.print_space_launched_time_to_target_message] or cache_attributes[cache.print_space_launched_time_to_target_message].time_to_live < game.tick) then
        cache.print_space_launched_time_to_target_message = { value = true }
        cache_attributes[cache.print_space_launched_time_to_target_message] = Cache_Attributes_Data:new({ cas = cache_attributes, k = cache.print_space_launched_time_to_target_message, time_to_live = game.tick + 20, })
        ICBM_Utils.print_space_launched_time_to_target_message()
    end

    if (not cache.locals or not cache_attributes[cache.locals] or cache_attributes[cache.locals].time_to_live < game.tick) then
        cache.locals = {}

        cache.locals.num_surfaces_to_process = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_SURFACES_PROCESSED_PER_TICK.name, }) or 1
        cache.locals.failure_limit = math.floor((cache.locals.num_surfaces_to_process * 4) ^ 0.25 + cache.locals.num_surfaces_to_process / 2)

        cache_attributes[cache.locals] = Cache_Attributes_Data:new({ cas = cache_attributes, k = cache.locals, time_to_live = game.tick + 150 + Prime_Random(rhythm, 90), })
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
            hash_string = "surfaces"
            hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
            cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                tbl = cache,
                key = hash_keys[hash_string],
                val = cache[hash_keys[hash_string]] or function () return Constants.get_space_exploration_surfaces() or {} end,
                ttl = game.tick + 17000 + Prime_Random(rhythm, 1000),
            })
            local surfaces = cache[hash_keys[hash_string]]

            configurable_nukes_controller.surface_name, configurable_nukes_controller.surface = next(surfaces, surfaces[configurable_nukes_controller.surface_name] and configurable_nukes_controller.surface_name or nil)
        else
            hash_string = "planets"
            hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
            cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                tbl = cache,
                key = hash_keys[hash_string],
                val = cache[hash_keys[hash_string]] or function () return Constants.get_planets() or {} end,
                ttl = game.tick + 17000 + Prime_Random(rhythm, 1000),
            })
            local planets = cache[hash_keys[hash_string]]

            configurable_nukes_controller.planet_index, configurable_nukes_controller.planet = next(planets, planets[configurable_nukes_controller.planet_index] and configurable_nukes_controller.planet_index or nil)
        end

        local space_location = se_active and configurable_nukes_controller.surface or configurable_nukes_controller.planet

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

        hash_string = "launch_attempts"
        if (_) then _ = nil end
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        cache[hash_keys[hash_string]], _ = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val = cache[hash_keys[hash_string]] or { attempts = 0, successes = 0, } or {},
            ttl = game.tick + 30 + Prime_Random(rhythm, 30, 210),
        })
        local launch_attempts, attr = cache[hash_keys[hash_string]], _ or {}
        if (type(attr) == "table" and attr.type and attr.type == "cache-attribute") then
            attr.valid = false
            attr.ttl = game.tick - 1
            attr.updated = game.tick
            cache_attributes[attr.k or false] = nil
        elseif (type(attr) == "table") then
            attr.time_to_live = 1
            attr.valid = false
            attr.no_attr = true
            attr.updated = game.tick
        else
            attr = { time_to_live = 1, }
        end
        _ = nil

        if (    attr
            and attr.time_to_live
            and attr.created
            and attr.time_to_live - game.tick <= game.tick - attr.created
            and (
                    launch_attempts.attempts == 0
                or  launch_attempts.successes == 0
            )
        ) then
            goto continue
        end

        hash_string = "circuit_connected_silos_on_platforms"
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val = cache[hash_keys[hash_string]] or {},
        })
        local circuit_connected_silos_on_platforms = cache[hash_keys[hash_string]]

        if (not circuit_connected_silos_on_platforms or not next(circuit_connected_silos_on_platforms)) then
            if (sa_active) then
                if (game.forces["player"] and game.forces["player"].platforms) then
                    hash_string = "all_rocket_silo_meta_data"
                    hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
                    cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                        tbl = cache,
                        key = hash_keys[hash_string],
                        val = cache[hash_keys[hash_string]] or function () return Rocket_Silo_Meta_Repository.get_all_rocket_silo_meta_data() end or {},
                        ttl = game.tick + 2700,
                        attrs = { no_attrs = true, }
                    })
                    local all_rocket_silo_meta_data = cache[hash_keys[hash_string]]

                    local space_platform = nil
                    local luaSpacePlatform = nil
                    cache.space_platform_index, luaSpacePlatform = next(game.forces["player"].platforms, cache.space_platform_index)
                    if (not game.forces["player"].platforms[cache.space_platform_index] or not game.forces["player"].platforms[cache.space_platform_index].valid) then
                        cache.space_platform_index, luaSpacePlatform = next(game.forces["player"].platforms, nil)
                    end

                    if (cache.space_platform_index and luaSpacePlatform and luaSpacePlatform.valid and luaSpacePlatform.surface.valid) then
                        space_platform = { index = cache.space_platform_index, name = luaSpacePlatform.name, surface = luaSpacePlatform.surface, valid = luaSpacePlatform.valid and luaSpacePlatform.surface and luaSpacePlatform.surface.valid, }
                    end

                    if (space_platform) then
                        hash_string = "space_platforms." .. space_platform.name
                        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
                        cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                            tbl = cache,
                            key = hash_keys[hash_string],
                            val = cache[hash_keys[hash_string]] or space_platform,
                            ttl = Constants.BIG_INTEGER,
                        })
                        space_platform = cache[hash_keys[hash_string]]
                    end

                    if (space_platform and space_platform.valid) then
                        if (not space_platform.surface or not space_platform.surface.valid) then goto continue_2 end

                        hash_string = "surfaces." .. space_platform.surface.name .. "." .. space_platform.name .. ".rocket_silo_meta_data"
                        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
                        cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                            tbl = cache,
                            key = hash_keys[hash_string],
                            val = cache[hash_keys[hash_string]]
                                or  function ()
                                        return { meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_platform.surface.name, { create = false }), }
                                    end
                                or {},
                            ttl = game.tick + 2100 + Prime_Random(rhythm, 600),
                        })
                        local cached_rocket_silo_meta_data = cache[hash_keys[hash_string]]

                        local rocket_silo_meta_data = cached_rocket_silo_meta_data and cached_rocket_silo_meta_data.meta_data
                        if (rocket_silo_meta_data and rocket_silo_meta_data.valid) then
                            if (rocket_silo_meta_data.rocket_silos and next(rocket_silo_meta_data.rocket_silos)) then
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

        hash_string = "surfaces." .. space_location.surface.name .. "." .. space_location.name .. ".rocket_silo_meta_data"
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val = cache[hash_keys[hash_string]]
                or  function ()
                        return { meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_location.surface.name, { create = false }), }
                    end
                or {},
            ttl = game.tick + 2345 + Prime_Random(rhythm, 234),
        })
        local cached_rocket_silo_meta_data = cache[hash_keys[hash_string]]

        local rocket_silo_meta_data = cached_rocket_silo_meta_data and cached_rocket_silo_meta_data.meta_data

        hash_string = "surfaces." .. space_location.surface.name .. "." .. space_location.name .. ".rocket_silos"
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        local attributes = nil
        cache[hash_keys[hash_string]], attributes = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val = cache[hash_keys[hash_string]] or {},
            ttl = game.tick + 6789 + Prime_Random(rhythm, 1234),
        })
        local space_location_rocket_silos = cache[hash_keys[hash_string]]

        if (not next(space_location_rocket_silos)) then
            if (rocket_silo_meta_data and rocket_silo_meta_data.valid) then
                if (attributes) then
                    if (not attributes.add_attempts) then attributes.add_attempts = 0 end
                    if (not attributes.added_count) then attributes.added_count = 0 end
                    if (not attributes.successful_launches) then attributes.added_count = 0 end

                    if (attributes.add_attempts > 12 and attributes.add_attempts > attributes.added_count * 1.5) then goto continue end
                    if (attributes.add_attempts > 3 and attributes.added_count == 0) then goto continue end

                    for count = 0, 2, 1 do
                        attributes.add_attempts = attributes.add_attempts + 1
                        if (attributes.key == nil or rocket_silo_meta_data.rocket_silos[attributes.key]) then
                            attributes.key, attributes.value = next(rocket_silo_meta_data.rocket_silos, attributes.key)
                        end

                        if (attributes.key and attributes.value) then
                            local entity = attributes.value.entity
                            if (entity and entity.valid and entity.type == "rocket-silo" and entity.rocket_silo_status == rocket_ready_status) then
                                attributes.added_count = attributes.added_count + 1
                                space_location_rocket_silos[attributes.key] = attributes.value
                            end
                        end
                    end
                end
            end
        end

        local index = space_location_rocket_silos and next(space_location_rocket_silos)
        local rocket_silo_data = space_location_rocket_silos[index]
        if (rocket_silo_data and rocket_silo_data.valid) then
            if (space_location_rocket_silos[rocket_silo_data.unit_number]) then space_location_rocket_silos[rocket_silo_data.unit_number] = nil end
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
        tick = game.tick,
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

    if (    event.setting == Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name
    ) then
        local new_nth_tick = Settings_Service.get_runtime_global_setting({ setting = event.setting.name, reindex = true })
        if (new_nth_tick ~= nil and type(new_nth_tick) == "number" and new_nth_tick >= 1 and new_nth_tick <= 60) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = 60
            if (event.setting.name == Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name) then
                prev_nth_tick = configurable_nukes_controller.nth_tick_surface_processing
            end
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
            if (event.setting.name == Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name) then
                configurable_nukes_controller.nth_tick_surface_processing = new_nth_tick
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func = configurable_nukes_controller.on_runtime_mod_setting_changed,
})

configurable_nukes_controller.add_to_cache_list = true

return configurable_nukes_controller