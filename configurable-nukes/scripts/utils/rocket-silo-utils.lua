-- If already defined, return
if _rocket_silo_utils and _rocket_silo_utils.configurable_nukes then
    return _rocket_silo_utils
end

local Util = require("__core__.lualib.util")

local Zone_Static_Data = require("scripts.data.static.zone-static-data")

local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
local Constants = require("scripts.constants.constants")
local Custom_Events = require("prototypes.custom-events.custom-events")
local Force_Launch_Data_Repository = require("scripts.repositories.force-launch-data-repository")
local Log = require("libs.log.log")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Service = require("scripts.services.settings-service")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local has_power = function (data)
    if (data and type(type(data) == "table")) then
        if (data.rocket_silo and data.rocket_silo.valid) then
            return  data.rocket_silo.is_connected_to_electric_network()
                and data.rocket_silo.energy > 0
                and data.rocket_silo.energy >= data.rocket_silo.electric_buffer_size
        end
    end
end

local rocket_silo_utils = {}

function rocket_silo_utils.mine_rocket_silo(event)
    Log.debug("rocket_silo_utils.mine_rocket_silo")
    Log.info(event)
    local rocket_silo = event.entity

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
    end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
    Log.debug("rocket_silo_utils.add_rocket_silo")
    Log.info(rocket_silo)

    Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function rocket_silo_utils.scrub_launch(data)
    Log.debug("rocket_silo_utils.scrub_launch")
    Log.info(data)

    if (not data) then return end
    if (not data.tick) then return end
    if (not data.tick_event) then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end
    if (not data.player) then
        data.player = game.get_player(data.player_index)
        if (not data.player or not data.player.valid) then
            return
        end
    end
    if (not data.order or type(data.order) ~= "string") then
        if (not data.remove or not data.enqueued_data or type(data.enqueued_data) ~= "table") then
            return
        end
    end
    if (not data.space_launches_initiated or not type(data.space_launches_initiated) == "table") then data.space_launches_initiated = {} end
    if (data.print_message == nil or type(data.print_message) ~= "boolean") then data.print_message = true end

    local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(data.player.force.index)
    Log.warn(force_launch_data)

    if (force_launch_data.launch_action_queue.count > 0) then
        local launch_to_scrub = nil
        if (data.order) then
            launch_to_scrub = force_launch_data.launch_action_queue:dequeue({ order = data.order, maintain = false })
        elseif (data.remove and data.enqueued_data) then
            launch_to_scrub = force_launch_data.launch_action_queue:remove({ data = data.enqueued_data })
        end

        Log.warn(launch_to_scrub)
        if (not launch_to_scrub) then return end

        local configurable_nukes_data = Configurable_Nukes_Repository.get_configurable_nukes_data()
        local icbm_meta_data_source = configurable_nukes_data.icbm_meta_data[launch_to_scrub.icbm_data.surface_name]
        local icbm_meta_data_target = nil

        if (not launch_to_scrub.icbm_data.same_surface) then
            icbm_meta_data_target = configurable_nukes_data.icbm_meta_data[launch_to_scrub.icbm_data.target_surface_name]
        end

        if (icbm_meta_data_source) then
            icbm_meta_data_source:remove_data({
                icbm_data = launch_to_scrub.icbm_data,
            })
        end

        if (icbm_meta_data_target) then
            icbm_meta_data_target:remove_data({
                icbm_data = launch_to_scrub.icbm_data,
            })
        end

        local item_numbers = ICBM_Data:get_item_numbers()
        if (item_numbers.get(launch_to_scrub.icbm_data.item_number)) then item_numbers.remove(launch_to_scrub.icbm_data.item_number) end

        if (data.space_launches_initiated[launch_to_scrub.icbm_data]) then data.space_launches_initiated[launch_to_scrub.icbm_data] = nil end

        -- Remove any registered event_handlers for the launch
        for _, event_handler_data in pairs(launch_to_scrub.icbm_data.event_handlers) do
            Event_Handler:unregister_event({
                event_name = event_handler_data.event_name,
                source_name = event_handler_data.source_name,
                nth_tick = event_handler_data.nth_tick,
            })
        end

        launch_to_scrub.icbm_data.scrubbed = true
        ICBM_Repository.update_icbm_data(launch_to_scrub.icbm_data)

        launch_to_scrub.icbm_data.cargo_pod = nil
        script.raise_event(
            Custom_Events.cn_on_rocket_launch_scrubbed.name,
            {
                name = defines.events[Custom_Events.cn_on_rocket_launch_scrubbed.name],
                tick = game.tick,
                icbm_data = launch_to_scrub.icbm_data,
            }
        )

        if (    data.print_message
            and launch_to_scrub.icbm_data.force
            and launch_to_scrub.icbm_data.force.valid
        ) then
            launch_to_scrub.icbm_data.force.print({ "rocket-silo-utils.scrub-launch", launch_to_scrub.icbm_data.item_number })
        end
    end
end

function rocket_silo_utils.launch_rocket(event)
    Log.debug("rocket_silo_utils.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick or not event.surface or not event.surface.valid) then return end
    if (not event.surface.name) then return end
    local surface = event.surface
    if (not surface or not surface.valid) then return end
    if (not event.player_index or type(event.player_index) ~= "number") then return end
    local player = event.player_index > 0 and game.get_player(event.player_index)
    local circuit_launch_initiated = false
    if (not player and event.player_index == 0) then circuit_launch_initiated = true end
    if (not circuit_launch_initiated and (not player or not player.valid)) then return end

    local sa_active = storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    local multisurface_circuit_launch = false
    if (event.circuit_launched ~= nil and type(event.circuit_launched) ~= "boolean") then return end
    if (event.circuit_launched and (not event.rocket_silo or not event.rocket_silo.valid)) then return end
    if (event.circuit_launched and event.rocket_silo.surface and event.rocket_silo.surface.valid) then
        local target_surface = surface
        local source_surface = event.rocket_silo.surface

        if (target_surface ~= source_surface) then
            multisurface_circuit_launch = true
        end
    end
    if (event.circuit_launched and (not event.rocket_silo_data or not event.rocket_silo_data.valid)) then return end

    local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(surface.name)

    local target_position = {
        x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
        y = (event.area.left_top.y + event.area.right_bottom.y) / 2,
    }

    local rocket_silo_array = {}

    local setting_atomic_bomb_rocket_launchable = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name })
    local setting_atomic_warhead_enabled = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })

    if (not Constants.planets_dictionary[surface.name]) then Constants.get_planets(true) end
    local source_target_planet = Constants.planets_dictionary[surface.name]
    local source_target_system = nil
    Log.debug(source_target_planet)

    if (se_active) then
        if (not surface.name:find("spaceship-", 1, true) and not Constants.space_exploration_dictionary[surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
        source_target_planet = surface.name:find("spaceship-", 1, true) and Constants["space-exploration"].spaceships[surface.name:lower()] or Constants.space_exploration_dictionary[surface.name:lower()]
        Log.warn(surface.name)
        Log.info(source_target_planet)
        if (not source_target_planet) then
            if (not Constants.mod_data_dictionary["se-" .. surface.name:lower()]) then Constants.get_mod_data(true) end
            source_target_planet = Constants.mod_data_dictionary["se-" .. surface.name:lower()]
            Log.warn(source_target_planet and source_target_planet.name)
            Log.info(source_target_planet)
        end

        if (source_target_planet) then
            --[[ Find the parent star, if it exists, of the target space-location ]]
            Log.warn(source_target_planet.name)
            Log.info(source_target_planet)

            local source_target_system_name = source_target_planet.type == "spaceship-data" and source_target_planet.previous_space_location:get_stellar_system() or source_target_planet:get_stellar_system()
            if (source_target_system_name) then source_target_system_name = source_target_system_name:lower() end
            if (not Constants.space_exploration_dictionary[source_target_system_name]) then Constants.get_space_exploration_universe(true) end
            source_target_system = Constants.space_exploration_dictionary[source_target_system_name]
        end
    end

    local found_in_orbit = false
    local icbm_allow_multisurface = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
    local ipbm_researched = false
    if (sa_active or se_active) then
        if (player and player.valid) then
            ipbm_researched = player.force.technologies["ipbms"].researched
        elseif (event.rocket_silo and event.rocket_silo.valid) then
            ipbm_researched = event.rocket_silo.force.technologies["ipbms"].researched
        end
    end

    --[[ Circuit-network launched ]]
    local circuit_launch = event.circuit_launched or false
    if (circuit_launch and event.rocket_silo and event.rocket_silo.valid and has_power({ rocket_silo = event.rocket_silo })) then
        circuit_launch = true
        local position = event.rocket_silo.position
        local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5

        local launched_from = nil
        local do_calc_distance = false
        if (multisurface_circuit_launch) then
            launched_from = "interplanetary"
            do_calc_distance = true
        end
        if (sa_active) then
            --[[ Is this scenario even possible presently? ]]
            launched_from =     event.rocket_silo.surface.name:lower():find("platform-", 1, true)
                            and event.rocket_silo.surface.platform
                            and event.rocket_silo.surface.platform.valid
                            and "orbit"
                        or
                            "surface"
        elseif (se_active) then
            launched_from =     event.rocket_silo.surface.name:lower():find(" orbit", 1, true)
                            and "orbit"
                        or
                            "surface"
        else
            launched_from = "surface"
        end

        local launched_from_space = launched_from == "orbit"

        local rocket_silo_data = {}
        if (do_calc_distance) then
            if (event.rocket_silo_data and event.circuit_launched_space_location_name) then
                rocket_silo_data = rocket_silo_utils.calculate_multifsurface_distance({
                    rocket_silo_data = event.rocket_silo_data,
                    space_location_name = event.circuit_launched_space_location_name,
                    target_position = target_position,
                    source_target_planet = source_target_planet,
                    source_target_system = source_target_system,
                    setting_atomic_bomb_rocket_launchable = setting_atomic_bomb_rocket_launchable,
                    setting_atomic_warhead_enabled = setting_atomic_warhead_enabled,
                    launched_from = launched_from,
                    orbit_to_surface = event.orbit_to_surface,
                })
            end
            if (type(rocket_silo_data) ~= "table") then
                if (type(rocket_silo_data) == "number") then
                    if (rocket_silo_data == -1) then
                        Log.warn("Invalid data provided to calculate multisurface distance")
                    elseif (rocket_silo_data == -2) then
                        Log.warn("Valid data provided, but silo not available for launch")
                    else
                        Log.error("How is this possible? 1")
                    end
                else
                    Log.error("How is this possible? 2")
                end

                return -1
            end
        else
            rocket_silo_data =
            {
                entity = event.rocket_silo,
                distance = distance,
                source_surface = event.rocket_silo.surface,
                launched_from = launched_from,
                launched_from_space = launched_from_space,
            }
        end

        if (type(rocket_silo_data) == "table") then
            table.insert(rocket_silo_array, rocket_silo_data)
        end
    end

    Log.warn(rocket_silo_array)

    --[[ Check for silos in orbit first ]]
    Log.warn("circuit_launch = " .. tostring(circuit_launch))
    Log.warn("se_active = " .. tostring(se_active))
    if (not circuit_launch and not se_active) then
        local planet = surface.planet
        if (planet and planet.valid) then
            for name, platform in pairs(planet.get_space_platforms("player")) do
                if (platform.valid and platform.space_location) then
                    if (not Constants.space_locations_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                    local space_location = Constants.space_locations_dictionary[platform.space_location.name]
                    if (not space_location) then
                        if (not Constants.planets_dictionary[platform.space_location.name]) then Constants.get_planets(true) end
                        space_location = Constants.planets_dictionary[platform.space_location.name]
                    end

                    if (space_location and space_location.name == surface.name) then

                        local orbit_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(platform.surface.name)

                        if (orbit_rocket_silo_meta_data and orbit_rocket_silo_meta_data.valid) then
                            for k, v in pairs(orbit_rocket_silo_meta_data.rocket_silos) do
                                if (    v.entity
                                    and v.entity.valid
                                    and v.entity.type == "rocket-silo"
                                    and has_power({ rocket_silo = v.entity })
                                    and v.entity.position
                                    and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                                    and (
                                            v.entity.name == "rocket-silo"
                                        or
                                            Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                                        and v.entity.name == "ipbm-rocket-silo"
                                    ))
                                then
                                    local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                                    if (inventory and inventory.valid) then
                                        for _, item in ipairs(inventory.get_contents()) do
                                            if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                                                or
                                                    (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                                            then
                                                found_in_orbit = true
                                                local position = v.entity.position
                                                local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                local distance_modifier = 1 - (1 / (math.pi / 2)) * (-1 * math.atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math.log(distance + math.exp(1), math.exp(1))) ^ 3) * distance) + math.pi / 2)

                                                if (distance_modifier > 1) then distance_modifier = 1 end
                                                distance = distance * distance_modifier

                                                if (#rocket_silo_array == 0) then
                                                    table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                else
                                                    local found = false
                                                    for i, j in ipairs(rocket_silo_array) do
                                                        if (distance < j.distance) then
                                                            table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                            found = true
                                                            break
                                                        end
                                                    end

                                                    if (not found) then
                                                        table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif (not circuit_launch and se_active) then
        if (not Constants.space_exploration_dictionary[surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
        local space_location = Constants.space_exploration_dictionary[surface.name:lower()]
        if (space_location and space_location.type) then
            if (space_location.type == "planet-data" or space_location.type == "moon-data") then
                if (space_location.orbit) then
                    Log.warn(space_location.orbit.name)
                    Log.info(space_location.orbit)
                    local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_location.orbit.surface_name)
                    if (rocket_silo_meta_data) then
                        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                            if (    v.entity
                                and v.entity.valid
                                and v.entity.type == "rocket-silo"
                                and has_power({ rocket_silo = v.entity })
                                and v.entity.position
                                and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                                and (
                                        v.entity.name == "rocket-silo"
                                    or
                                        Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                                    and v.entity.name == "ipbm-rocket-silo"
                                ))
                            then
                                local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                                if (inventory and inventory.valid) then
                                    for _, item in ipairs(inventory.get_contents()) do
                                        if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                                            or
                                                (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                                        then
                                            found_in_orbit = true
                                            local position = v.entity.position
                                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                            local distance_modifier = 1 - (1 / (math.pi / 2)) * (-1 * math.atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math.log(distance + math.exp(1), math.exp(1))) ^ 3) * distance) + math.pi / 2)

                                            if (distance_modifier > 1) then distance_modifier = 1 end
                                            distance = distance * distance_modifier

                                            if (#rocket_silo_array == 0) then
                                                table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                            else
                                                local found = false
                                                for i, j in ipairs(rocket_silo_array) do
                                                    if (distance < j.distance) then
                                                        table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                        found = true
                                                        break
                                                    end
                                                end

                                                if (not found) then
                                                    table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Log.warn(rocket_silo_array)

    --[[ Create an ordered array of rocket-silos; ordered by distance, closest to farthest, from the silo to the target position ]]
    local found_on_surface = false
    Log.warn("1 found_in_orbit = " .. tostring(found_in_orbit))
    if (not circuit_launch and not found_in_orbit) then
        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
            if (    v.entity
                and v.entity.valid
                and v.entity.type == "rocket-silo"
                and has_power({ rocket_silo = v.entity })
                and v.entity.position
                and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                and (
                        v.entity.name == "rocket-silo"
                    or
                        Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                    and v.entity.name == "ipbm-rocket-silo"
                ))
            then
                local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                if (inventory and inventory.valid) then
                    for _, item in ipairs(inventory.get_contents()) do
                        if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                            or
                                (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                        then
                            found_on_surface = true
                            local position = v.entity.position
                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                            if (#rocket_silo_array == 0) then
                                table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                            else
                                local found = false
                                for i, j in ipairs(rocket_silo_array) do
                                    if (distance < j.distance) then
                                        table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                                        found = true
                                        break
                                    end
                                end

                                if (not found) then
                                    table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Log.warn(rocket_silo_array)

    --[[ If no rocket-silos are found in orbit, or on the surface, and ipbms have been researched, iterate through availble space-splatforms ]]
    Log.warn("found_on_surface = " .. tostring(found_on_surface))
    Log.warn("ipbm_researched = " .. tostring(ipbm_researched))
    if (not circuit_launch and not found_in_orbit and not found_on_surface and ipbm_researched) then
        if (not se_active) then
            local planet = surface.planet
            if (planet and planet.valid) then
                for name, platform in pairs(planet.get_space_platforms("player")) do
                    if (platform.valid and platform.space_location) then
                        if (not Constants.space_locations_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                        local space_location = Constants.space_locations_dictionary[platform.space_location.name]
                        if (not space_location) then
                            if (not Constants.planets_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                            space_location = Constants.planets_dictionary[platform.space_location.name]
                        end

                        if (space_location and space_location.name == surface.name) then
                            local orbit_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(platform.surface.name)
                            if (orbit_rocket_silo_meta_data and orbit_rocket_silo_meta_data.valid) then
                                for k, v in pairs(orbit_rocket_silo_meta_data.rocket_silos) do
                                    if (    v.entity
                                        and v.entity.valid
                                        and v.entity.type == "rocket-silo"
                                        and has_power({ rocket_silo = v.entity })
                                        and v.entity.position
                                        and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                                        and v.entity.name == "ipbm-rocket-silo")
                                    then
                                        local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                                        if (inventory and inventory.valid) then
                                            for _, item in ipairs(inventory.get_contents()) do
                                                if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                                                    or
                                                        (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                                                then
                                                    found_in_orbit = true
                                                    local position = v.entity.position
                                                    local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                    local distance_modifier = 1 - (1 / (math.pi / 2)) * (-1 * math.atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math.log(distance + math.exp(1), math.exp(1))) ^ 3) * distance) + math.pi / 2)

                                                    if (distance_modifier > 1) then distance_modifier = 1 end
                                                    distance = distance * distance_modifier

                                                    if (#rocket_silo_array == 0) then
                                                        table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                    else
                                                        local found = false
                                                        for i, j in ipairs(rocket_silo_array) do
                                                            if (distance < j.distance) then
                                                                table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                                found = true
                                                                break
                                                            end
                                                        end

                                                        if (not found) then
                                                            table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true })
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            if (not Constants.space_exploration_dictionary[surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
            local space_location = Constants.space_exploration_dictionary[surface.name:lower()]
            if (space_location and space_location.type) then
                if (space_location.type == "planet-data" or space_location.type == "moon-data") then
                    if (space_location.orbit) then
                        Log.warn(space_location.orbit.name)
                        Log.info(space_location.orbit)
                        local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_location.orbit.surface_name)
                        if (rocket_silo_meta_data) then
                            for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                                if (    v.entity
                                    and v.entity.valid
                                    and v.entity.type == "rocket-silo"
                                    and has_power({ rocket_silo = v.entity })
                                    and v.entity.position
                                    and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                                    and v.entity.name == "ipbm-rocket-silo")
                                then
                                    local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                                    if (inventory and inventory.valid) then
                                        for _, item in ipairs(inventory.get_contents()) do
                                            if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                                                or
                                                    (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                                            then
                                                found_in_orbit = true
                                                local position = v.entity.position
                                                local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                local distance_modifier = 1 - (1 / (math.pi / 2)) * (-1 * math.atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math.log(distance + math.exp(1), math.exp(1))) ^ 3) * distance) + math.pi / 2)

                                                if (distance_modifier > 1) then distance_modifier = 1 end
                                                distance = distance * distance_modifier

                                                local rocket_silo_data = { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "orbit", launched_from_space = true }

                                                if (#rocket_silo_array == 0) then
                                                    table.insert(rocket_silo_array, rocket_silo_data)
                                                else
                                                    local found = false
                                                    for i, j in ipairs(rocket_silo_array) do
                                                        if (distance < j.distance) then
                                                            table.insert(rocket_silo_array, i, rocket_silo_data)
                                                            found = true
                                                            break
                                                        end
                                                    end

                                                    if (not found) then
                                                        table.insert(rocket_silo_array, rocket_silo_data)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Log.warn(rocket_silo_array)

    --[[ If:
            no rocket-silos are found in orbit,
            or on the surface,
            and no ipbm-rocket-silos are found in orbit,
            or on any platforms,

            Create an ordered array of ipbm-rocket-silos; ordered by distance, closest to farthest, from the silo to the target position
    ]]
    Log.warn("2 found_in_orbit = " .. tostring(found_in_orbit))
    if (not circuit_launch and not found_in_orbit and not found_on_surface) then
        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
            if (    v.entity
                and v.entity.valid
                and v.entity.type == "rocket-silo"
                and has_power({ rocket_silo = v.entity })
                and v.entity.position
                and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                and v.entity.name == "ipbm-rocket-silo")
            then
                local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                if (inventory and inventory.valid) then
                    for _, item in ipairs(inventory.get_contents()) do
                        if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                            or
                                (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                        then
                            found_on_surface = true
                            local position = v.entity.position
                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                            if (#rocket_silo_array == 0) then
                                table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                            else
                                local found = false
                                for i, j in ipairs(rocket_silo_array) do
                                    if (distance < j.distance) then
                                        table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                                        found = true
                                        break
                                    end
                                end

                                if (not found) then
                                    table.insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = "surface", launched_from_space = false })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Log.warn(rocket_silo_array)

    --[[
        If none of the above checks found a suitable rocket-silo or ipbm-rocket-silo to launch from,
        iterate through all known rocket-silos and ipbm-silos.
        -> Creating a sorted list (by least distance to greatest distance) of the found silos

        -> TODO: structure/store this infromation somehow to improve retrieval/search times
    ]]
    if ((ipbm_researched or icbm_allow_multisurface) and not circuit_launch and not found_in_orbit and not found_on_surface) then
        local all_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_all_rocket_silo_meta_data()

        for space_location_name, rocket_silo_meta_data in pairs(all_rocket_silo_meta_data) do
            if (se_active and space_location_name:lower():find("spaceship-", 1, true)) then
                goto continue
            end
            local calculated = false
            local returned_rocket_silo_data = nil
            for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                if (v.entity and v.entity.valid and v.entity.surface and v.entity.surface.valid) then

                    local payload_found = false

                    if (    v.entity
                        and v.entity.valid
                        and v.entity.type == "rocket-silo"
                        and has_power({ rocket_silo = v.entity })
                        and v.entity.position
                        and v.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
                        and (
                                Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
                                and v.entity.name == "rocket-silo"
                            or
                                v.entity.name == "ipbm-rocket-silo"))
                    then

                        local inventory = v.entity.get_inventory(defines.inventory.rocket_silo_rocket)
                        if (inventory and inventory.valid) then
                            for _, item in ipairs(inventory.get_contents()) do
                                if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                                    or
                                        (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                                then
                                    payload_found = true
                                    break
                                end
                            end
                        end
                    end

                    if (payload_found) then
                        if (not calculated) then
                            returned_rocket_silo_data = rocket_silo_utils.calculate_multifsurface_distance({
                                rocket_silo_data = v,
                                space_location_name = space_location_name,
                                target_position = target_position,
                                rocket_silo_array = rocket_silo_array,
                                source_target_planet = source_target_planet,
                                source_target_system = source_target_system,
                                setting_atomic_bomb_rocket_launchable = setting_atomic_bomb_rocket_launchable,
                                setting_atomic_warhead_enabled = setting_atomic_warhead_enabled,
                            })
                            if (type(returned_rocket_silo_data) == "table") then
                                calculated = true
                            end
                        elseif (calculated and returned_rocket_silo_data) then
                            local return_val_copy = Util.table.deepcopy(returned_rocket_silo_data)
                            return_val_copy.entity = v.entity
                            return_val_copy.is_ipbm = v.entity and v.entity.valid and v.entity.name == "ipbm-rocket-silo"
                            return_val_copy.source_surface = v.entity.surface

                            if (rocket_silo_array) then
                                local index = #rocket_silo_array
                                for i = 1, #rocket_silo_array, 1 do
                                    if (return_val_copy.is_ipbm) then
                                        if (not rocket_silo_array[i].is_ipbm) then
                                            index = i
                                            break
                                        end
                                    end
                                end

                                table.insert(rocket_silo_array, index, return_val_copy)
                            end
                        end
                    end
                end
            end

            ::continue::
        end
    end

    Log.warn(rocket_silo_array)

    for _, rocket_silo_data in ipairs(rocket_silo_array) do
        local rocket_silo = nil
        local launched = false

        if (rocket_silo_data.entity and rocket_silo_data.entity.valid) then
            rocket_silo = rocket_silo_data.entity
        end

        if (rocket_silo and rocket_silo.valid) then
            local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
            if (inventory and inventory.valid) then
                for _, item in ipairs(inventory.get_contents()) do

                    if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                        or
                            (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                    then
                        local rocket = rocket_silo.rocket

                        local cargo_pod
                        if (rocket and rocket.valid) then
                            cargo_pod = rocket.attached_cargo_pod

                            if (cargo_pod and cargo_pod.valid) then
                                cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.surface, surface = surface, rocket_silo_type = rocket_silo.name }
                            end
                        end

                        Log.debug(rocket_silo_data)
                        if (rocket_silo.launch_rocket(cargo_pod.cargo_pod_destination)) then
                            Log.debug("Launched rocket_silo:")
                            Log.info(rocket_silo)

                            local speed =       not se_active
                                            and rocket_silo_data.launched_from_space
                                            and rocket_silo.surface
                                            and rocket_silo.surface.valid
                                            and rocket_silo.surface.platform
                                            and rocket_silo.surface.platform.valid
                                            and rocket_silo.surface.platform.speed
                                            and 60 * rocket_silo.surface.platform.speed
                                            or 0

                            local launch_initiated_params =
                            {
                                type = item.name == "atomic-bomb" and "atomic-rocket" or "atomic-warhead",
                                surface = rocket_silo.surface,
                                target_surface = surface,
                                item = item,
                                tick = event.tick,
                                source_silo = rocket_silo,
                                area = event.area,
                                cargo_pod = cargo_pod and cargo_pod.valid and cargo_pod,
                                circuit_launch = circuit_launch,
                                player_index = event.player_index,
                                distance = rocket_silo_data.distance,
                                launched_from = rocket_silo_data.launched_from,
                                launched_from_space = rocket_silo_data.launched_from_space,
                                base_target_distance = rocket_silo_data.base_target_distance,
                                speed = speed,
                                is_travelling = rocket_silo_data.is_travelling,
                                space_origin_pos = rocket_silo_data.space_origin_pos,
                                -- origin_system = rocket_silo_data.origin_system,
                                -- source_target_system = rocket_silo_data.source_target_system,
                            }
                            Log.debug(launch_initiated_params)
                            ICBM_Utils.launch_initiated(launch_initiated_params)
                            launched = true
                            break
                        else
                            Log.error("Failed to launch rocket_silo: ")
                            Log.warn(rocket)
                            Log.warn(cargo_pod)
                            Log.warn(rocket_silo_data)
                            Log.warn(rocket_silo)
                        end
                    end
                end
            end
        end

        if (launched) then return end
    end
end

function rocket_silo_utils.calculate_multifsurface_distance(data)
    Log.debug("rocket_silo_utils.calculate_multifsurface_distance")
    Log.info(data)

    if (data == nil or type(data) ~= "table") then return -1 end

    local passed_rocket_silo_data = data.rocket_silo_data
    local space_location_name = data.space_location_name
    local target_position = data.target_position
    local rocket_silo_array = data.rocket_silo_array
    local source_target_planet = data.source_target_planet
    local source_target_system = data.source_target_system
    local setting_atomic_bomb_rocket_launchable = data.setting_atomic_bomb_rocket_launchable
    local setting_atomic_warhead_enabled = data.setting_atomic_warhead_enabled
    local launched_from = data.launched_from
    local orbit_to_surface = data.orbit_to_surface

    local sa_active = storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    if (    passed_rocket_silo_data.entity
        and passed_rocket_silo_data.entity.valid
        and passed_rocket_silo_data.entity.type == "rocket-silo"
        and has_power({ rocket_silo = passed_rocket_silo_data.entity })
        and passed_rocket_silo_data.entity.position
        and passed_rocket_silo_data.entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready
        and (
                (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
                or orbit_to_surface)
                and passed_rocket_silo_data.entity.name == "rocket-silo"
            or
                passed_rocket_silo_data.entity.name == "ipbm-rocket-silo"))
    then

        local inventory = passed_rocket_silo_data.entity.get_inventory(defines.inventory.rocket_silo_rocket)
        if (inventory and inventory.valid) then
            for _, item in ipairs(inventory.get_contents()) do
                if (    (item.name == "atomic-bomb" and setting_atomic_bomb_rocket_launchable)
                    or
                        (item.name == "atomic-warhead" and setting_atomic_warhead_enabled))
                then

                    local is_travelling = false
                    local space_connection_distance = nil
                    local space_connection_distance_travelled = nil
                    local space_connection = nil
                    local reversed = false
                    local space_connection_contains_destination = false

                    local is_ipbm = passed_rocket_silo_data.entity.name == "ipbm-rocket-silo"

                    local base_target_distance = 0

                    if (not se_active and not Constants.planets_dictionary[passed_rocket_silo_data.entity.surface.name]) then Constants.get_planets(true) end
                    local origin_space_location = not se_active and Constants.planets_dictionary[passed_rocket_silo_data.entity.surface.name]
                    if (not origin_space_location) then
                        if (se_active) then
                            if (passed_rocket_silo_data.entity.surface.name:find("spaceship-", 1, true)) then
                                --[[ TODO: Reach out about the bug caused when launching a rocket while a spaceship takes off
                                    -> No error on this side; rather, is coming from SE:

                                        The mod Space Exploration (0.7.34) caused a non-recoverable error.
                                        Please report this error to the mod author.

                                        Error while running event space-exploration::on_rocket_launched (ID 14)
                                        __space-exploration__/control.lua:1551: attempt to index field 'attached_cargo_pod' (a nil value)
                                        stack traceback:
                                            __space-exploration__/control.lua:1551: in function 'callback'
                                            __space-exploration__/scripts/event.lua:20: in function <__space-exploration__/scripts/event.lua:18>

                                    -> [Missing a '.valid' check when a cargo-pod finishes ascending]
                                ]]

                                origin_space_location = Constants["space-exploration"].spaceships[passed_rocket_silo_data.entity.surface.name]
                            else
                                if (not Constants.space_exploration_dictionary[string.lower(passed_rocket_silo_data.entity.surface.name)]) then Constants.get_space_exploration_universe(true) end
                                origin_space_location = Constants.space_exploration_dictionary[string.lower(passed_rocket_silo_data.entity.surface.name)]

                                if (not origin_space_location) then
                                    if (not Constants.mod_data_dictionary["se-" .. string.lower(passed_rocket_silo_data.entity.surface.name)]) then Constants.get_mod_data(true) end
                                    origin_space_location = Constants.mod_data_dictionary["se-" .. string.lower(passed_rocket_silo_data.entity.surface.name)]
                                    Log.warn(origin_space_location and origin_space_location.name)
                                    Log.info(origin_space_location)
                                end
                            end
                        else
                            if (string.find(passed_rocket_silo_data.entity.surface.name, "platform-", 1, true) and passed_rocket_silo_data.entity.surface.platform and passed_rocket_silo_data.entity.surface.platform.valid) then
                                local space_location = passed_rocket_silo_data.entity.surface.platform.space_location
                                space_connection = passed_rocket_silo_data.entity.surface.platform.space_connection

                                if ((not space_location or not space_location.valid) and space_connection and space_connection.valid) then
                                    local from = passed_rocket_silo_data.entity.surface.platform.last_visited_space_location
                                    if (from ~= space_connection.from) then
                                        reversed = true
                                    end
                                    if (from and from.valid and not Constants.planets_dictionary[from.name]) then Constants.get_planets(true) end
                                    origin_space_location = from and from.valid and Constants.planets_dictionary[from.name]
                                    is_travelling = origin_space_location and true

                                    if (is_travelling) then
                                        space_connection_distance = space_connection.length

                                        --[[ Calculate the actual distance between from and to, rather than using the space-connection distance ]]
                                        local from = space_connection.from
                                        local to = space_connection.to
                                        if (not Constants.planets_dictionary[from.name] or not Constants.planets_dictionary[to.name]) then Constants.get_planets(true) end
                                        local planet_from = Constants.planets_dictionary[from.name]
                                        local planet_to = Constants.planets_dictionary[to.name]

                                        space_connection_distance = (((planet_from.x - planet_to.x) ^ 2 + (planet_from.y - planet_to.y) ^ 2) ^ 0.5)
                                        space_connection_distance = space_connection_distance * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name })

                                        if (reversed) then
                                            space_connection_distance_travelled = space_connection_distance * (1 - passed_rocket_silo_data.entity.surface.platform.distance)
                                        else
                                            space_connection_distance_travelled = space_connection_distance * passed_rocket_silo_data.entity.surface.platform.distance
                                        end
                                    end

                                elseif (space_location and space_location.valid) then
                                    if (not Constants.planets_dictionary[space_location.name]) then Constants.get_planets(true) end
                                    origin_space_location = Constants.planets_dictionary[space_location.name]
                                end
                            end
                            local planet = passed_rocket_silo_data.entity.surface.planet or origin_space_location and origin_space_location.surface and origin_space_location.surface.valid and origin_space_location.surface.planet

                            if (planet and planet.valid) then
                                if (not Constants.planets_dictionary[planet.name]) then Constants.get_planets(true) end
                                origin_space_location = Constants.planets_dictionary[planet.name]
                            end
                            if (not origin_space_location) then
                                origin_space_location = { magnitude = 1, orientation = 0.1, star_distance = 100, }
                            end
                        end
                    end
                    if (not origin_space_location) then
                        origin_space_location = { magnitude = 1, orientation = 0.1, star_distance = 100, }
                    end

                    local target_planet = source_target_planet
                                        or
                                        {
                                            name = "",
                                            magnitude = 1,
                                            orientation = origin_space_location.orientation,
                                            star_distance = (origin_space_location.star_distance and origin_space_location.star_distance or 0) + origin_space_location.magnitude,
                                        }

                    local origin_pos = nil

                    local origin_system = nil

                    if (se_active) then
                        --[[ Find the parent star, if it exists, of the current space-location ]]
                        Log.warn(origin_space_location and origin_space_location.name)
                        local origin_system_name = nil
                        if (origin_space_location.type) then
                            Log.warn(origin_space_location and origin_space_location.previous_space_location and origin_space_location.previous_space_location.name)
                            origin_system_name = origin_space_location.type == "spaceship-data" and origin_space_location.previous_space_location:get_stellar_system() or origin_space_location:get_stellar_system()

                            if (not origin_space_location.type == "spaceship-data" and not Constants.space_exploration_dictionary[origin_system_name]) then Constants.get_space_exploration_universe(true) end
                            origin_system = Constants.space_exploration_dictionary[origin_system_name]
                        else
                            --[[ TODO: what exactly? ]]
                        end
                        if (not Constants.space_exploration_dictionary[origin_system_name]) then Log.warn(origin_system_name); Constants.get_space_exploration_universe(true) end
                        local origin_system = Constants.space_exploration_dictionary[origin_system_name]

                        if (origin_system) then
                            origin_pos = {
                                x = origin_system.x,
                                y = origin_system.y,
                            }
                        end
                    end

                    origin_pos =    not se_active and { x = origin_space_location.x, y = origin_space_location.y, }
                                or  origin_pos
                                or  { x = 0, y = 0 }

                    Log.warn(origin_space_location and origin_space_location.name)
                    Log.warn(origin_pos)

                    local launched_from_space = space_location_name:find("platform-", 1, true) == 1
                    if (se_active) then
                        --[[ Check for SE space launches ]]
                        Log.warn(origin_space_location.name)
                        launched_from_space = not origin_space_location:is_solid()
                    end

                    base_target_distance = ((target_position.x ^ 2) + (target_position.y ^ 2)) ^ 0.5

                    local modifier = 0.5
                    if (not se_active and is_travelling and space_connection and space_connection.valid) then
                        modifier = space_connection_distance_travelled / space_connection_distance

                        local reversed = origin_space_location.surface_name ~= space_connection.from.name

                        if (not reversed) then modifier = 1 - modifier end

                        local to = not reversed and space_connection.to or space_connection.from
                        if (not Constants.planets_dictionary[to.name]) then Constants.get_planets(true) end
                        local to_planet = Constants.planets_dictionary[to.name]

                        local fellback = false
                        if (origin_pos.x == to_planet.x and origin_pos.y == to_planet.y) then
                            fellback = true
                            reversed = not reversed
                            to = not reversed and space_connection.to or space_connection.from
                            if (not Constants.planets_dictionary[to.name]) then Constants.get_planets(true) end
                            to_planet = Constants.planets_dictionary[to.name]
                        end

                        local delta_x = (origin_pos.x - to_planet.x) ^ 2
                        delta_x = delta_x ^ 0.5
                        delta_x = delta_x * modifier
                        local delta_y = (origin_pos.y - to_planet.y) ^ 2
                        delta_y = delta_y ^ 0.5
                        delta_y = delta_y * modifier

                        if (fellback) then delta_y = delta_y * -1 end
                        if (target_planet.name == space_connection.from.name or target_planet.name == space_connection.to.name) then space_connection_contains_destination = true end

                        if (reversed) then
                            delta_x = delta_x * -1
                            delta_y = delta_y * -1
                        end
                        origin_pos.x = origin_space_location.orientation < 0.5 and origin_space_location.orientation ~= 1 and (origin_pos.x + delta_x) or (origin_pos.x - delta_x)
                        origin_pos.y = (origin_space_location.orientation < 0.25 or origin_space_location.orientation >= 0.75) and (origin_pos.y + delta_y) or (origin_pos.y - delta_y)
                    end
                    Log.debug(origin_space_location and origin_space_location.name)
                    Log.debug(target_planet and target_planet.name)
                    Log.debug(source_target_planet and source_target_planet.name)
                    Log.debug(origin_pos)

                    local target_distance =  1
                    if (se_active) then
                        Log.info(origin_system)
                        Log.warn(origin_system and origin_system.name)
                        Log.info(source_target_system)
                        Log.warn(source_target_system and source_target_system.name)
                        Log.info(source_target_planet)
                        Log.warn(source_target_planet and source_target_planet.name)
                        if (origin_system and (source_target_system or source_target_planet)) then
                            if (not source_target_system) then source_target_system = source_target_planet end

                            local origin_space_distortion = origin_space_location.type == "anomaly-data" and origin_space_location.space_distortion or 0
                            local destination_space_distortion = source_target_planet.type == "anomaly-data" and origin_space_location.space_distortion or 0

                            local distance_calculcated = false

                            --[[ Haven't actually tested this yet; that being firing at/from the anomaly ]]
                            if (origin_space_distortion > 0 and destination_space_distortion > 0) then
                                --[[ Patrially distorted ]]
                                target_distance = Zone_Static_Data.travel_cost.interstellar * math.abs(origin_space_distortion - destination_space_distortion)
                                distance_calculcated = true
                            elseif (origin_space_distortion > 0) then
                                --[[ Origin distortion ]]
                                target_distance = Zone_Static_Data.travel_cost.anomaly
                                                    + Zone_Static_Data.travel_cost.star_gravity * origin_space_location.star_gravity_well
                                                    + Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well

                                distance_calculcated = true
                            elseif (destination_space_distortion > 0) then
                                --[[ Destination distortion]]
                                target_distance = Zone_Static_Data.travel_cost.anomaly
                                                    + Zone_Static_Data.travel_cost.star_gravity * source_target_planet.star_gravity_well
                                                    + Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well

                                distance_calculcated = true
                            end

                            Log.warn(origin_system.name)
                            Log.debug(origin_system.planet_gravity_well)
                            Log.debug(origin_system.star_gravity_well)

                            Log.warn(origin_space_location.name)
                            Log.debug(origin_space_location.planet_gravity_well)
                            Log.debug(origin_space_location.star_gravity_well)

                            Log.warn(source_target_system.name)
                            Log.debug(source_target_system.planet_gravity_well)
                            Log.debug(source_target_system.star_gravity_well)

                            Log.warn(source_target_planet.name)
                            Log.debug(source_target_planet.planet_gravity_well)
                            Log.debug(source_target_planet.star_gravity_well)

                            Log.debug(Zone_Static_Data.travel_cost.planet_gravity)

                            if (not distance_calculcated) then
                                Log.debug("distance not yet calculated - no distortion")
                                if (origin_system.x == source_target_system.x and origin_system.y == source_target_system.y) then
                                    --[[ Same solar system ]]
                                    Log.debug("same solar system")
                                    local origin_star_gravity_well = origin_space_location.star_gravity_well
                                    Log.debug(origin_star_gravity_well)
                                    if (origin_space_location.type == "orbit-data") then
                                        origin_star_gravity_well = origin_space_location.parent and origin_space_location.parent.star_gravity_well or 0
                                    end
                                    Log.debug(origin_star_gravity_well)

                                    if (origin_star_gravity_well == source_target_planet.star_gravity_well) then
                                        --[[ Same planetary system ]]
                                        Log.debug("same planetary system")
                                        Log.info(origin_space_location)
                                        Log.debug(math.abs(origin_space_location.planet_gravity_well - source_target_planet.planet_gravity_well))

                                        local origin_planet_gravity_well = origin_space_location.star_gravity_well
                                        Log.debug(origin_planet_gravity_well)
                                        if (origin_space_location.type == "orbit-data") then
                                            origin_planet_gravity_well = origin_space_location.parent and origin_space_location.parent.star_gravity_well or 0
                                        end
                                        Log.debug(origin_planet_gravity_well)

                                        target_distance = Zone_Static_Data.travel_cost.planet_gravity * math.abs(origin_planet_gravity_well - source_target_planet.planet_gravity_well)
                                    else
                                        --[[ Different planetary system ]]
                                        Log.debug("different planetary system")
                                        target_distance = Zone_Static_Data.travel_cost.star_gravity * math.abs(origin_star_gravity_well - source_target_planet.star_gravity_well)
                                            + Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well
                                            + Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well
                                    end
                                else
                                    --[[ Different solar systems ]]
                                    Log.debug("different solar system")
                                    local target = source_target_system or source_target_planet
                                    local base_interstellar_distance = (((origin_pos.x - target.x) ^ 2 + (origin_pos.y - target.y) ^ 2) ^ 0.5)
                                    Log.debug(base_interstellar_distance)
                                    Log.debug(Zone_Static_Data.travel_cost.interstellar * base_interstellar_distance)
                                    Log.debug(Zone_Static_Data.travel_cost.star_gravity * origin_space_location.star_gravity_well)
                                    Log.debug(Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well)
                                    Log.debug(Zone_Static_Data.travel_cost.star_gravity * source_target_planet.star_gravity_well)
                                    Log.debug(Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well)

                                    target_distance = Zone_Static_Data.travel_cost.interstellar * base_interstellar_distance
                                        + Zone_Static_Data.travel_cost.star_gravity * origin_space_location.star_gravity_well
                                        + Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well
                                        + Zone_Static_Data.travel_cost.star_gravity * source_target_planet.star_gravity_well
                                        + Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well
                                end
                            end
                        end
                    elseif (origin_system) then
                        --[[ Origin system, but no target
                            -> How?
                        ]]
                        log(serpent.block(origin_system))
                        log(serpent.block(source_target_planet))
                        log(serpent.block(source_target_system))
                        Log.error(origin_system)
                        Log.error(source_target_planet)
                        Log.error(source_target_system)
                        -- error("Found an origin system, but no target system")
                        target_distance = (((origin_pos.x - target_planet.x) ^ 2 + (origin_pos.y - target_planet.y) ^ 2) ^ 0.5)
                    elseif (source_target_system) then
                        --[[ Target system, but no origin
                            -> How?
                        ]]
                        log(serpent.block(source_target_system))
                        log(serpent.block(origin_system))
                        log(serpent.block(origin_space_location))
                        Log.error(source_target_system)
                        Log.error(origin_system)
                        Log.error(origin_space_location)
                        -- error("Found an origin system, but no target system")
                        target_distance = (((origin_pos.x - target_planet.x) ^ 2 + (origin_pos.y - target_planet.y) ^ 2) ^ 0.5)
                    else
                        target_distance = (((origin_pos.x - target_planet.x) ^ 2 + (origin_pos.y - target_planet.y) ^ 2) ^ 0.5)
                    end
                    Log.warn(serpent.block(target_distance))

                    Log.warn("pre-multiplication, target_distance = " .. target_distance)
                    if (not se_active) then
                        target_distance = target_distance * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name })
                    end
                    Log.warn("post-multiplication, target_distance = " .. target_distance)
                    if (not se_active) then
                        if (space_location_name:find("platform-", 1, true)) then
                            --[[ base_target_distance shouldn't contribute as much if launched from space/a platform -> it is already in space/orbit ]]
                            target_distance = target_distance + math.log(1 + base_target_distance, (math.exp(1) * 2) / (target_planet.magnitude) ^ math.exp(1))
                            Log.warn(target_distance)
                        else
                            target_distance = target_distance + base_target_distance
                            Log.debug(target_distance)
                        end
                    else
                        --[[ TODO: anything? ]]
                    end

                    Log.warn("is_travelling = " .. tostring(is_travelling))

                    local local_rocket_silo_data =
                    {
                        entity = passed_rocket_silo_data.entity,
                        -- distance = is_travelling and distance_to_target or target_distance,
                        distance = target_distance or -1,
                        source_surface = passed_rocket_silo_data.entity.surface,
                        launched_from = "interplanetary",
                        launched_from_space = launched_from_space,
                        base_target_distance = base_target_distance,
                        is_travelling = is_travelling,
                        space_origin_pos = origin_pos,
                        -- origin_system = origin_system,
                        -- source_target_system = source_target_system,
                        is_ipbm = is_ipbm,
                    }

                    Log.warn(serpent.block(local_rocket_silo_data))
                    Log.warn(serpent.block(target_distance))

                    if (rocket_silo_array) then
                        if (#rocket_silo_array == 0) then
                            table.insert(rocket_silo_array, local_rocket_silo_data)
                        else
                            local found = false
                            for i, j in ipairs(rocket_silo_array) do
                                if (
                                            (distance_to_target
                                        and
                                            (distance_to_target < j.distance
                                            or
                                                space_location_name:find("platform-", 1, true)
                                                and distance_to_target <= j.distance
                                                and j.entity.name == "rocket-silo"
                                            or
                                                is_ipbm
                                                and distance_to_target <= j.distance
                                            )
                                        )
                                    or
                                        (not distance_to_target
                                        and
                                            (target_distance < j.distance
                                            or
                                                    space_location_name:find("platform-", 1, true)
                                                and target_distance <= j.distance
                                                and j.entity.name == "rocket-silo"
                                            or
                                                is_ipbm
                                                and target_distance <= j.distance
                                        )
                                    )
                                )
                                then
                                    table.insert(rocket_silo_array, i, local_rocket_silo_data)
                                    found = true
                                    break
                                end
                            end

                            if (not found) then
                                table.insert(rocket_silo_array, local_rocket_silo_data)
                            end
                        end
                        Log.debug(rocket_silo_array)
                    end

                    Log.debug(space_location_name)
                    Log.debug(local_rocket_silo_data.entity.surface.name)
                    Log.debug(local_rocket_silo_data.entity.surface.platform)
                    Log.debug(space_connection_contains_destination)
                    Log.debug(reversed)

                    --[[ Return the calculated rocket_silo_data; and secondarily return the rocket_silo_array if it was provided ]]
                    return local_rocket_silo_data, rocket_silo_array
                end
            end
        end
    end

    return -2
end

rocket_silo_utils.configurable_nukes = true

local _rocket_silo_utils = rocket_silo_utils

return rocket_silo_utils
