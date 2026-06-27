local storage
local configurable_nukes

local game
local get_player

local Constants = Constants or require("scripts.constants.constants")

local Set_Forces = Set_Forces

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.configurable_nukes = storage.configurable_nukes or {}
    configurable_nukes = storage.configurable_nukes

    game = __game or _ENV.game
    get_player = game.get_player

    return game
end

local table = table

local ipairs = ipairs
local next = next
local pairs = pairs
local table_insert = table.insert
local tostring = tostring
local type = type

local math_abs = math.abs
local math_atan = math.atan
local math_log = math.log

local string_find = string.find
local string_lower = string.lower

local E = math.exp(1)
local PI = math.pi
local HALF_PI = PI / 2

local BOOLEAN = "boolean"
local INTERPLANETARY = "interplanetary"
local IPBM = "ipbm"
local IPBMS = "ipbms"
local NUMBER = "number"
local ORBIT = "orbit"
local PLAYER = "player"
local PLATFORM_PREFIX = "platform-"
local ROCKET_SILO = "rocket-silo"
local STRING = "string"
local SURFACE ="surface"
local TABLE = "table"

local defines = defines
local prototypes = prototypes
local script = script
local raise_event = script.raise_event

local cargo_destination_surface = defines.cargo_destination.surface
local cargo_unit_inventory = defines.inventory.cargo_unit
local rocket_ready_status = defines.rocket_silo_status.rocket_ready
local rocket_silo_rocket_inventory = defines.inventory.rocket_silo_rocket

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local _debug = debug
local Event_Handler = Event_Handler
local Log = Log
local warn = Log.warn
local debug = Log.debug
local info = Log.info
local Settings_Service = Settings_Service
local get_runtime_global_setting = Settings_Service.get_runtime_global_setting
local get_startup_setting = Settings_Service.get_startup_setting

local Util = require("__core__.lualib.util")

local Zone_Static_Data = require("scripts.data.static.zone-static-data")

-- local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
-- local Constants = require("scripts.constants.constants")
local Custom_Events = require("prototypes.custom-events.custom-events")
local cn_on_rocket_launch_scrubbed = Custom_Events.cn_on_rocket_launch_scrubbed.name
local Force_Launch_Data_Repository = require("scripts.repositories.force-launch-data-repository")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local get_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local rocket_silo_utils = {}
rocket_silo_utils.name = "rocket_silo_utils"
rocket_silo_utils.set_game = set_game

local always_use_closest_silo = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
local atomic_bomb_rocket_launchable = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name })
local atomic_warhead_enabled = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })
local legacy_launch_system_enabled = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.LEGACY_LAUNCH_SYSTEM_ENABLED.name })

local launchable_rocket_silos = {
    [ROCKET_SILO] = 1,
    ["ipbm-rocket-silo"] = 1,
}

if (script and script.active_mods and script.active_mods["QualityRockets"]) then
    for k, v in pairs(prototypes.quality) do
        launchable_rocket_silos[k .. "-rocket-silo"] = 1
        launchable_rocket_silos[k .. "-ipbm-rocket-silo"] = 1
    end
end

local function has_power(data)
    if (data and type(type(data) == TABLE)) then
        if (data.rocket_silo and data.rocket_silo.valid) then
            return  data.rocket_silo.is_connected_to_electric_network()
                and data.rocket_silo.energy > 0
                and data.rocket_silo.energy >= data.rocket_silo.electric_buffer_size
        end
    end
end

local valid_payloads =
{
    ["atomic-bomb"]         = function () return    atomic_bomb_rocket_launchable
                                                and legacy_launch_system_enabled end,
    ["atomic-warhead"]      = function () return    atomic_warhead_enabled
                                                and legacy_launch_system_enabled end,
    ["cn-rod-from-god"]     = function () return legacy_launch_system_enabled end,
    ["cn-jericho"]          = function () return legacy_launch_system_enabled end,
    ["cn-tesla-rocket"]     = function () return legacy_launch_system_enabled end,
    ["cn-payload-vehicle"]  = function () return true end,
}

local function valid_payload(item_name)
    local return_val = false
    if (not item_name or type(item_name) ~= STRING) then return return_val end

    return valid_payloads[item_name] and valid_payloads[item_name]() and true or false
end

function rocket_silo_utils.on_runtime_mod_setting_changed(event)
    debug("rocket_silo_utils.on_runtime_mod_setting_changed")
    info(event)

    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (string_find(event.setting, "configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name) then
        always_use_closest_silo = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name) then
        atomic_bomb_rocket_launchable = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.LEGACY_LAUNCH_SYSTEM_ENABLED.name) then
        legacy_launch_system_enabled = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.LEGACY_LAUNCH_SYSTEM_ENABLED.name, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "rocket_silo_utils.on_runtime_mod_setting_changed",
    func_name = "rocket_silo_utils.on_runtime_mod_setting_changed",
    func = rocket_silo_utils.on_runtime_mod_setting_changed,
})

function rocket_silo_utils.mine_rocket_silo(event)
    debug("rocket_silo_utils.mine_rocket_silo")
    info(event)
    local rocket_silo = event.entity

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        storage.rocket_silos = storage.rocket_silos or {}
        storage.rocket_silos[rocket_silo.unit_number] = nil

        storage.surfaces = storage.surfaces or {}
        storage.surfaces[rocket_silo.surface.name] = storage.surfaces[rocket_silo.surface.name] or {}
        storage.surfaces[rocket_silo.surface.name][rocket_silo.unit_number] = nil

        Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
    end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
    debug("rocket_silo_utils.add_rocket_silo")
    info(rocket_silo)

    local saved_rocket_silo = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
    if (saved_rocket_silo and saved_rocket_silo.valid) then
        storage.rocket_silos = storage.rocket_silos or {}
        storage.rocket_silos[saved_rocket_silo.unit_number] = saved_rocket_silo

        storage.surfaces = storage.surfaces or {}
        storage.surfaces[saved_rocket_silo.surface_name] = storage.surfaces[saved_rocket_silo.surface_name] or {}
        storage.surfaces[saved_rocket_silo.surface_name][saved_rocket_silo.unit_number] = saved_rocket_silo
    end
end

function rocket_silo_utils.scrub_launch(data)
    debug("rocket_silo_utils.scrub_launch")
    info(data)

    if (not data) then return end
    if (not data.player_index or type(data.player_index) ~= NUMBER or data.player_index < 1) then return end
    if (not data.player) then
        -- data.player = game.get_player(data.player_index)
        data.player = (game or set_game()) and get_player and get_player(data.player_index)
        if (not data.player or not data.player.valid) then
            return
        end
    end
    if (not data.order or type(data.order) ~= STRING) then
        if (not data.remove or not data.enqueued_data or type(data.enqueued_data) ~= TABLE) then
            return
        end
    end
    if (not data.space_launches_initiated or not type(data.space_launches_initiated) == TABLE) then data.space_launches_initiated = {} end
    if (data.print_message == nil or type(data.print_message) ~= BOOLEAN) then data.print_message = true end

    local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(data.player.force.index)
    warn(force_launch_data)

    if (force_launch_data.launch_action_queue.count > 0) then
        local launch_to_scrub = nil
        if (data.order) then
            launch_to_scrub = force_launch_data.launch_action_queue:dequeue({ order = data.order, maintain = false })
        elseif (data.remove and data.enqueued_data) then
            launch_to_scrub = force_launch_data.launch_action_queue:remove({ data = data.enqueued_data })
        end

        warn(launch_to_scrub)
        if (not launch_to_scrub) then return end

        warn(launch_to_scrub.icbm_data)
        if (type(launch_to_scrub.icbm_data) ~= TABLE or not launch_to_scrub.icbm_data.valid) then return end

        -- local configurable_nukes_data = Configurable_Nukes_Repository.get_configurable_nukes_data()
        configurable_nukes = configurable_nukes or set_game() and configurable_nukes
        local icbm_meta_data_source = configurable_nukes.icbm_meta_data[launch_to_scrub.icbm_data.surface_name]
        local icbm_meta_data_target = nil

        if (not launch_to_scrub.icbm_data.same_surface) then
            icbm_meta_data_target = configurable_nukes.icbm_meta_data[launch_to_scrub.icbm_data.target_surface_name]
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
        if (type(launch_to_scrub.icbm_data.event_handlers) == TABLE) then --[[ May not exist for launches from previous versions ]]
            for _, event_handler_data in pairs(launch_to_scrub.icbm_data.event_handlers) do
                Event_Handler:unregister_event({
                    event_name = event_handler_data.event_name,
                    source_name = event_handler_data.source_name,
                    nth_tick = event_handler_data.nth_tick,
                })
            end
        end

        launch_to_scrub.icbm_data.scrubbed = true
        ICBM_Repository.update_icbm_data(launch_to_scrub.icbm_data)

        if (type(launch_to_scrub.icbm_data) == TABLE and launch_to_scrub.icbm_data.valid) then
            ICBM_Repository.delete_icbm_data_by_item_number(launch_to_scrub.icbm_data.surface_name, launch_to_scrub.icbm_data.item_number)
        end

        launch_to_scrub.icbm_data.cargo_pod = nil

        local force = launch_to_scrub.icbm_data.force
        game = game or set_game()
        local forces = game.forces
        if (not force or not force.valid) then force = forces[launch_to_scrub.icbm_data.force_index] end
        if (not force or not force.valid) then force = forces[PLAYER] end
        if (not force or not force.valid) then force = nil end

        if (data.raise_event) then
            raise_event(
                cn_on_rocket_launch_scrubbed,
                {
                    name = defines.events[cn_on_rocket_launch_scrubbed],
                    tick = game.tick,
                    force = force,
                    item_number = launch_to_scrub.icbm_data.item_number,
                }
            )
        end

        if (    data.print_message
            and launch_to_scrub.icbm_data.force
            and launch_to_scrub.icbm_data.force.valid
        ) then
            launch_to_scrub.icbm_data.force.print({ "rocket-silo-utils.scrub-launch", launch_to_scrub.icbm_data.item_number })
        end
    end
end

function rocket_silo_utils.launch_rocket(event)
    debug("rocket_silo_utils.launch_rocket")
    info(event)

    if (not event) then return end
    if (not event.tick or not event.surface or not event.surface.valid) then return end
    if (not event.surface.name) then return end
    local surface = event.surface
    if (not surface or not surface.valid) then return end
    if (not event.player_index or type(event.player_index) ~= NUMBER) then return end
    -- local player = event.player_index > 0 and game.get_player(event.player_index)
    local player = event.player_index > 0 and (game or set_game()) and get_player and get_player(event.player_index)
    local circuit_launch_initiated = false
    if (not player and event.player_index == 0) then circuit_launch_initiated = true end
    if (not circuit_launch_initiated and (not player or not player.valid)) then return end

    local multisurface_circuit_launch = false
    if (event.circuit_launched ~= nil and type(event.circuit_launched) ~= BOOLEAN) then return end
    if (event.circuit_launched and (not event.rocket_silo or not event.rocket_silo.valid)) then return end
    if (event.circuit_launched and event.rocket_silo.surface and event.rocket_silo.surface.valid) then
        local target_surface = surface
        local source_surface = event.rocket_silo.surface

        if (target_surface ~= source_surface) then
            multisurface_circuit_launch = true
        end
    end
    if (event.circuit_launched and (not event.rocket_silo_data or not event.rocket_silo_data.valid)) then return end

    local rocket_silo_meta_data = get_rocket_silo_meta_data(surface.name)

    local target_position = {
        x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
        y = (event.area.left_top.y + event.area.right_bottom.y) / 2,
    }

    local rocket_silo_array = {}

    if (not Constants.planets_dictionary[surface.name]) then Constants.get_planets(true) end
    local source_target_planet = Constants.planets_dictionary[surface.name]
    local source_target_system = nil
    debug(source_target_planet)

    if (se_active) then
        if (not string_find(surface.name, "spaceship-", 1, true) and not Constants.space_exploration_dictionary[surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
        source_target_planet = string_find(surface.name, "spaceship-", 1, true) and Constants["space-exploration"].spaceships[surface.name:lower()] or Constants.space_exploration_dictionary[surface.name:lower()]
        warn(surface.name)
        info(source_target_planet)
        if (not source_target_planet) then
            if (not Constants.mod_data_dictionary["se-" .. surface.name:lower()]) then Constants.get_mod_data(true) end
            source_target_planet = Constants.mod_data_dictionary["se-" .. surface.name:lower()]
            warn(source_target_planet and source_target_planet.name)
            info(source_target_planet)
        end

        if (source_target_planet) then
            --[[ Find the parent star, if it exists, of the target space-location ]]
            warn(source_target_planet.name)
            info(source_target_planet)

            local source_target_system_name = source_target_planet.type == "spaceship-data" and source_target_planet.previous_space_location:get_stellar_system() or source_target_planet:get_stellar_system()
            if (source_target_system_name) then source_target_system_name = source_target_system_name:lower() end
            if (not Constants.space_exploration_dictionary[source_target_system_name]) then Constants.get_space_exploration_universe(true) end
            source_target_system = Constants.space_exploration_dictionary[source_target_system_name]
        end
    end

    local found_in_orbit = false
    local icbm_allow_multisurface = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
    local ipbm_researched = false
    if (sa_active or se_active) then
        if (player and player.valid) then
            ipbm_researched = player.force.technologies[IPBMS].researched
        elseif (event.rocket_silo and event.rocket_silo.valid) then
            ipbm_researched = event.rocket_silo.force.technologies[IPBMS].researched
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
            launched_from = INTERPLANETARY
            do_calc_distance = true
        end
        if (sa_active) then
            launched_from =     string_find(string_lower(event.rocket_silo.surface.name), PLATFORM_PREFIX, 1, true)
                            and event.rocket_silo.surface.platform
                            and event.rocket_silo.surface.platform.valid
                            and ORBIT
                        or
                            SURFACE
        elseif (se_active) then
            launched_from =     string_find(string_lower(event.rocket_silo.surface.name)," orbit", 1, true)
                            and ORBIT
                        or
                            SURFACE
        else
            launched_from = SURFACE
        end

        local launched_from_space = launched_from == ORBIT

        local rocket_silo_data = {}
        if (do_calc_distance) then
            if (event.rocket_silo_data and event.circuit_launched_space_location_name) then
                rocket_silo_data = rocket_silo_utils.calculate_multifsurface_distance({
                    rocket_silo_data = event.rocket_silo_data,
                    space_location_name = event.circuit_launched_space_location_name,
                    target_position = target_position,
                    source_target_planet = source_target_planet,
                    source_target_system = source_target_system,
                    setting_atomic_bomb_rocket_launchable = atomic_bomb_rocket_launchable,
                    setting_atomic_warhead_enabled = atomic_warhead_enabled,
                    launched_from = launched_from,
                    orbit_to_surface = event.orbit_to_surface,
                })
            end
            if (type(rocket_silo_data) ~= TABLE) then
                if (type(rocket_silo_data) == NUMBER) then
                    if (rocket_silo_data == -1) then
                        warn("Invalid data provided to calculate multisurface distance")
                    elseif (rocket_silo_data == -2) then
                        warn("Valid data provided, but silo not available for launch")
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

        if (type(rocket_silo_data) == TABLE) then
            table_insert(rocket_silo_array, rocket_silo_data)
        end
    end

    warn(rocket_silo_array)

    --[[ Check for silos in orbit first ]]
    warn("circuit_launch = " .. tostring(circuit_launch))
    warn("se_active = " .. tostring(se_active))
    if (not circuit_launch and not se_active) then
        local planet = surface.planet
        if (planet and planet.valid) then
            for name, platform in pairs(planet.get_space_platforms(PLAYER)) do
                if (platform.valid and platform.space_location) then
                    if (not Constants.space_locations_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                    local space_location = Constants.space_locations_dictionary[platform.space_location.name]
                    if (not space_location) then
                        if (not Constants.planets_dictionary[platform.space_location.name]) then Constants.get_planets(true) end
                        space_location = Constants.planets_dictionary[platform.space_location.name]
                    end

                    if (space_location and space_location.name == surface.name) then

                        local orbit_rocket_silo_meta_data = get_rocket_silo_meta_data(platform.surface.name)

                        if (orbit_rocket_silo_meta_data and orbit_rocket_silo_meta_data.valid) then
                            for k, v in pairs(orbit_rocket_silo_meta_data.rocket_silos) do
                                if (    v.entity
                                    and v.entity.valid
                                    and v.entity.type == ROCKET_SILO
                                    and has_power({ rocket_silo = v.entity })
                                    and v.entity.position
                                    and v.entity.rocket_silo_status == rocket_ready_status
                                    -- and (
                                    --         v.entity.name == ROCKET_SILO
                                    --     or
                                    --         get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                                    --     and v.entity.name == "ipbm-rocket-silo"
                                    -- ))
                                    and launchable_rocket_silos[v.entity.name]
                                    and (
                                            not string_find(v.entity.name, IPBM)
                                        or
                                            string_find(v.entity.name, IPBM)
                                        and always_use_closest_silo
                                    ))
                                then
                                    local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                                    if (inventory and inventory.valid) then
                                        for _, item in ipairs(inventory.get_contents()) do
                                            if (valid_payload(item.name)) then
                                                found_in_orbit = true
                                                local position = v.entity.position
                                                local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                local distance_modifier = 1 - (1 / (HALF_PI)) * (-1 * math_atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math_log(distance + E, E)) ^ 3) * distance) + HALF_PI)

                                                if (distance_modifier > 1) then distance_modifier = 1 end
                                                distance = distance * distance_modifier

                                                if (#rocket_silo_array == 0) then
                                                    table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                                else
                                                    local found = false
                                                    for i, j in ipairs(rocket_silo_array) do
                                                        if (distance < j.distance) then
                                                            table_insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                                            found = true
                                                            break
                                                        end
                                                    end

                                                    if (not found) then
                                                        table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
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
                    warn(space_location.orbit.name)
                    info(space_location.orbit)
                    local rocket_silo_meta_data = get_rocket_silo_meta_data(space_location.orbit.surface_name)
                    if (rocket_silo_meta_data) then
                        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                            if (    v.entity
                                and v.entity.valid
                                and v.entity.type == ROCKET_SILO
                                and has_power({ rocket_silo = v.entity })
                                and v.entity.position
                                and v.entity.rocket_silo_status == rocket_ready_status
                                -- and (
                                --         v.entity.name == ROCKET_SILO
                                --     or
                                --         get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                                --     and v.entity.name == "ipbm-rocket-silo"
                                -- ))
                                and launchable_rocket_silos[v.entity.name]
                                and (
                                        not string_find(v.entity.name, IPBM)
                                    or
                                        string_find(v.entity.name, IPBM)
                                    and always_use_closest_silo
                                ))
                            then
                                local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                                if (inventory and inventory.valid) then
                                    for _, item in ipairs(inventory.get_contents()) do
                                        if (valid_payload(item.name)) then
                                            found_in_orbit = true
                                            local position = v.entity.position
                                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                            local distance_modifier = 1 - (1 / (HALF_PI)) * (-1 * math_atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math_log(distance + E, E)) ^ 3) * distance) + HALF_PI)

                                            if (distance_modifier > 1) then distance_modifier = 1 end
                                            distance = distance * distance_modifier

                                            if (#rocket_silo_array == 0) then
                                                table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                            else
                                                local found = false
                                                for i, j in ipairs(rocket_silo_array) do
                                                    if (distance < j.distance) then
                                                        table_insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                                        found = true
                                                        break
                                                    end
                                                end

                                                if (not found) then
                                                    table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
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

    warn(rocket_silo_array)

    --[[ Create an ordered array of rocket-silos; ordered by distance, closest to farthest, from the silo to the target position ]]
    local found_on_surface = false
    warn("1 found_in_orbit = " .. tostring(found_in_orbit))
    if (not circuit_launch and not found_in_orbit) then
        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
            if (    v.entity
                and v.entity.valid
                and v.entity.type == ROCKET_SILO
                and has_power({ rocket_silo = v.entity })
                and v.entity.position
                and v.entity.rocket_silo_status == rocket_ready_status
                -- and (
                --         v.entity.name == ROCKET_SILO
                --     or
                --         get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO.name })
                --     and v.entity.name == "ipbm-rocket-silo"
                -- ))
                and launchable_rocket_silos[v.entity.name]
                and (
                        not string_find(v.entity.name, IPBM)
                    or
                        string_find(v.entity.name, IPBM)
                    and always_use_closest_silo
                ))
            then
                local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                if (inventory and inventory.valid) then
                    for _, item in ipairs(inventory.get_contents()) do
                        if (valid_payload(item.name)) then
                            found_on_surface = true
                            local position = v.entity.position
                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                            if (#rocket_silo_array == 0) then
                                table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                            else
                                local found = false
                                for i, j in ipairs(rocket_silo_array) do
                                    if (distance < j.distance) then
                                        table_insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                                        found = true
                                        break
                                    end
                                end

                                if (not found) then
                                    table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    warn(rocket_silo_array)

    --[[ If no rocket-silos are found in orbit, or on the surface, and ipbms have been researched, iterate through availble space-splatforms ]]
    warn("found_on_surface = " .. tostring(found_on_surface))
    warn("ipbm_researched = " .. tostring(ipbm_researched))
    if (not circuit_launch and not found_in_orbit and not found_on_surface and ipbm_researched) then
        if (not se_active) then
            local planet = surface.planet
            if (planet and planet.valid) then
                for name, platform in pairs(planet.get_space_platforms(PLAYER)) do
                    if (platform.valid and platform.space_location) then
                        if (not Constants.space_locations_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                        local space_location = Constants.space_locations_dictionary[platform.space_location.name]
                        if (not space_location) then
                            if (not Constants.planets_dictionary[platform.space_location.name]) then Constants.get_space_locations(true) end
                            space_location = Constants.planets_dictionary[platform.space_location.name]
                        end

                        if (space_location and space_location.name == surface.name) then
                            local orbit_rocket_silo_meta_data = get_rocket_silo_meta_data(platform.surface.name)
                            if (orbit_rocket_silo_meta_data and orbit_rocket_silo_meta_data.valid) then
                                for k, v in pairs(orbit_rocket_silo_meta_data.rocket_silos) do
                                    if (    v.entity
                                        and v.entity.valid
                                        and v.entity.type == ROCKET_SILO
                                        and has_power({ rocket_silo = v.entity })
                                        and v.entity.position
                                        and v.entity.rocket_silo_status == rocket_ready_status
                                        -- and v.entity.name == "ipbm-rocket-silo")
                                        and string_find(v.entity.name, IPBM)
                                        and launchable_rocket_silos[v.entity.name]
                                    ) then
                                        local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                                        if (inventory and inventory.valid) then
                                            for _, item in ipairs(inventory.get_contents()) do
                                                if (valid_payload(item.name)) then
                                                    found_in_orbit = true
                                                    local position = v.entity.position
                                                    local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                    local distance_modifier = 1 - (1 / (HALF_PI)) * (-1 * math_atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math_log(distance + E, E)) ^ 3) * distance) + HALF_PI)

                                                    if (distance_modifier > 1) then distance_modifier = 1 end
                                                    distance = distance * distance_modifier

                                                    if (#rocket_silo_array == 0) then
                                                        table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                                    else
                                                        local found = false
                                                        for i, j in ipairs(rocket_silo_array) do
                                                            if (distance < j.distance) then
                                                                table_insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
                                                                found = true
                                                                break
                                                            end
                                                        end

                                                        if (not found) then
                                                            table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true })
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
                        warn(space_location.orbit.name)
                        info(space_location.orbit)
                        local rocket_silo_meta_data = get_rocket_silo_meta_data(space_location.orbit.surface_name)
                        if (rocket_silo_meta_data) then
                            for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                                if (    v.entity
                                    and v.entity.valid
                                    and v.entity.type == ROCKET_SILO
                                    and has_power({ rocket_silo = v.entity })
                                    and v.entity.position
                                    and v.entity.rocket_silo_status == rocket_ready_status
                                    -- and v.entity.name == "ipbm-rocket-silo"
                                    and string_find(v.entity.name, IPBM)
                                    and launchable_rocket_silos[v.entity.name]
                                ) then
                                    local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                                    if (inventory and inventory.valid) then
                                        for _, item in ipairs(inventory.get_contents()) do
                                            if (valid_payload(item.name)) then
                                                found_in_orbit = true
                                                local position = v.entity.position
                                                local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                                                local distance_modifier = 1 - (1 / (HALF_PI)) * (-1 * math_atan((--[[ TODO: Make the 1/3 configurable ]](1/3)/(math_log(distance + E, E)) ^ 3) * distance) + HALF_PI)

                                                if (distance_modifier > 1) then distance_modifier = 1 end
                                                distance = distance * distance_modifier

                                                local rocket_silo_data = { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = ORBIT, launched_from_space = true }

                                                if (#rocket_silo_array == 0) then
                                                    table_insert(rocket_silo_array, rocket_silo_data)
                                                else
                                                    local found = false
                                                    for i, j in ipairs(rocket_silo_array) do
                                                        if (distance < j.distance) then
                                                            table_insert(rocket_silo_array, i, rocket_silo_data)
                                                            found = true
                                                            break
                                                        end
                                                    end

                                                    if (not found) then
                                                        table_insert(rocket_silo_array, rocket_silo_data)
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

    warn(rocket_silo_array)

    --[[ If:
            no rocket-silos are found in orbit,
            or on the surface,
            and no ipbm-rocket-silos are found in orbit,
            or on any platforms,

            Create an ordered array of ipbm-rocket-silos; ordered by distance, closest to farthest, from the silo to the target position
    ]]
    warn("2 found_in_orbit = " .. tostring(found_in_orbit))
    if (not circuit_launch and not found_in_orbit and not found_on_surface) then
        for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
            if (    v.entity
                and v.entity.valid
                and v.entity.type == ROCKET_SILO
                and has_power({ rocket_silo = v.entity })
                and v.entity.position
                and v.entity.rocket_silo_status == rocket_ready_status
                -- and v.entity.name == "ipbm-rocket-silo"
                and string_find(v.entity.name, IPBM)
                and launchable_rocket_silos[v.entity.name]
            ) then
                local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                if (inventory and inventory.valid) then
                    for _, item in ipairs(inventory.get_contents()) do
                        if (valid_payload(item.name)) then
                            found_on_surface = true
                            local position = v.entity.position
                            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
                            if (#rocket_silo_array == 0) then
                                table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                            else
                                local found = false
                                for i, j in ipairs(rocket_silo_array) do
                                    if (distance < j.distance) then
                                        table_insert(rocket_silo_array, i, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                                        found = true
                                        break
                                    end
                                end

                                if (not found) then
                                    table_insert(rocket_silo_array, { entity = v.entity, distance = distance, source_surface = v.entity.surface, launched_from = SURFACE, launched_from_space = false })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    warn(rocket_silo_array)

    --[[
        If none of the above checks found a suitable rocket-silo or ipbm-rocket-silo to launch from,
        iterate through all known rocket-silos and ipbm-silos.
        -> Creating a sorted list (by least distance to greatest distance) of the found silos

        -> TODO: structure/store this infromation somehow to improve retrieval/search times
    ]]
    if ((ipbm_researched or icbm_allow_multisurface) and not circuit_launch and not found_in_orbit and not found_on_surface) then
        local all_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_all_rocket_silo_meta_data()

        for space_location_name, rocket_silo_meta_data in pairs(all_rocket_silo_meta_data) do
            if (se_active and string_find(string_lower(space_location_name), "spaceship-", 1, true)) then
                goto continue
            end
            local calculated = false
            local returned_rocket_silo_data = nil
            for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                if (v.entity and v.entity.valid and v.entity.surface and v.entity.surface.valid) then

                    local payload_found = false

                    if (    v.entity
                        and v.entity.valid
                        and v.entity.type == ROCKET_SILO
                        and has_power({ rocket_silo = v.entity })
                        and v.entity.position
                        and v.entity.rocket_silo_status == rocket_ready_status
                        and (
                            --     get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
                            --     -- and v.entity.name == ROCKET_SILO
                            --     and launchable_rocket_silos[v.entity.name]
                            -- or
                            --     -- v.entity.name == "ipbm-rocket-silo"
                            --         string_find(v.entity.name, IPBM)
                            --     and launchable_rocket_silos[v.entity.name]
                                launchable_rocket_silos[v.entity.name]
                            and (
                                    get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
                                or
                                    string_find(v.entity.name, IPBM)
                            )
                        )
                    ) then

                        local inventory = v.entity.get_inventory(rocket_silo_rocket_inventory)
                        if (inventory and inventory.valid) then
                            for _, item in ipairs(inventory.get_contents()) do
                                if (valid_payload(item.name)) then
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
                                setting_atomic_bomb_rocket_launchable = atomic_bomb_rocket_launchable,
                                setting_atomic_warhead_enabled = atomic_warhead_enabled,
                            })
                            if (type(returned_rocket_silo_data) == TABLE) then
                                calculated = true
                            end
                        elseif (calculated and returned_rocket_silo_data) then
                            local return_val_copy = Util.table.deepcopy(returned_rocket_silo_data)
                            return_val_copy.entity = v.entity
                            -- return_val_copy.is_ipbm = v.entity and v.entity.valid and v.entity.name == "ipbm-rocket-silo"
                            return_val_copy.is_ipbm = v.entity and v.entity.valid and string_find(v.entity.name, IPBM)
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

                                table_insert(rocket_silo_array, index, return_val_copy)
                            end
                        end
                    end
                end
            end

            ::continue::
        end
    end

    warn(rocket_silo_array)

    local return_val, return_data
    for _, rocket_silo_data in ipairs(rocket_silo_array) do
        local rocket_silo = nil
        local launched = false
        if (rocket_silo_data.entity and rocket_silo_data.entity.valid) then
            rocket_silo = rocket_silo_data.entity
        end

        local speed =       not se_active
                        and rocket_silo_data.launched_from_space
                        and rocket_silo
                        and rocket_silo.valid
                        and rocket_silo.surface
                        and rocket_silo.surface.valid
                        and rocket_silo.surface.platform
                        and rocket_silo.surface.platform.valid
                        and rocket_silo.surface.platform.speed
                        and 60 * rocket_silo.surface.platform.speed
                        or 0

        if (rocket_silo and rocket_silo.valid) then
            --[[ rocket silo inventory ]]
            local inventory = rocket_silo.get_inventory(rocket_silo_rocket_inventory)
            if (inventory and inventory.valid) then
                local items = {}
                local payload_items = {}
                local total_payload_items = 1
                local cargo_dictionary = {}

                --[[ Iterate through the rocket-silo's inventory slots ]]
                for i = 1, #inventory, 1 do
                    local item = inventory[i]
                    if (item and item.valid and item.valid_for_read and valid_payload(item.name)) then
                        local _item = { name = item.name, count = item.count, quality = item.quality.name, }
                        table_insert(items, _item)

                        if (not cargo_dictionary[item.name]) then
                            cargo_dictionary[item.name] = { name = item.name, count = item.count, }
                        else
                            cargo_dictionary[item.name].count = cargo_dictionary[item.name].count + item.count
                        end

                        --[[ Does the item have an inventroy? i.e. is it a cn-payload-vehicle? ]]
                        local item_inventory = item.get_inventory(cargo_unit_inventory)
                        if (item_inventory and item_inventory.valid) then
                            --[[ Get the contents of the cn-payload-vehicle ]]
                            local contents = item_inventory.get_contents()
                            if (contents) then
                                for _, v in pairs(contents) do
                                    total_payload_items = total_payload_items + v.count
                                    table_insert(payload_items, v)

                                    if (v.name == "explosives") then
                                        if (not _item.explosives) then _item.explosives = 0 end
                                        _item.explosives = _item.explosives + v.count
                                    end

                                    if (not cargo_dictionary[v.name]) then
                                        cargo_dictionary[v.name] = { name = v.name, count = v.count, }
                                    else
                                        cargo_dictionary[v.name].count = cargo_dictionary[v.name].count + v.count
                                    end
                                end
                            end
                        end
                    end
                end

                if (next(items)) then
                    local rocket = rocket_silo.rocket

                    local cargo_pod
                    if (rocket and rocket.valid) then
                        cargo_pod = rocket.attached_cargo_pod

                        if (cargo_pod and cargo_pod.valid) then
                            cargo_pod.cargo_pod_destination = { type = cargo_destination_surface, surface = surface, rocket_silo_type = rocket_silo.name }
                        end
                    end

                    debug(rocket_silo_data)
                    if (cargo_pod and cargo_pod.valid and rocket_silo.launch_rocket(cargo_pod.cargo_pod_destination)) then
                        debug("Launched rocket_silo:")
                        info(rocket_silo)

                        local item_name = #items == 1 and items[1] and items[1].count == 1 and items[1].name or nil
                        if (item_name == "atomic-bomb") then item_name = "atomic-rocket" end

                        local launch_initiated_params =
                        {
                            surface = rocket_silo.surface,
                            target_surface = surface,
                            item_name = item_name,
                            item = item_name and items[1] or nil,
                            items = not item_name and items or nil,
                            cargo = payload_items,
                            cargo_dictionary = cargo_dictionary,
                            total_payload_items = total_payload_items,
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
                        debug(launch_initiated_params)
                        return_val, return_data = ICBM_Utils.launch_initiated(launch_initiated_params)
                        launched = true
                    else
                        Log.error("Failed to launch rocket_silo: ")
                        warn(rocket)
                        warn(cargo_pod)
                        warn(rocket_silo_data)
                        warn(rocket_silo)
                    end
                end
            end
        end

        if (launched) then return return_val, return_data end
    end
end

function rocket_silo_utils.calculate_multifsurface_distance(data)
    debug("rocket_silo_utils.calculate_multifsurface_distance")
    info(data)

    if (data == nil or type(data) ~= TABLE) then return -1 end

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

    if (    passed_rocket_silo_data.entity
        and passed_rocket_silo_data.entity.valid
        and passed_rocket_silo_data.entity.type == ROCKET_SILO
        and has_power({ rocket_silo = passed_rocket_silo_data.entity })
        and passed_rocket_silo_data.entity.position
        and passed_rocket_silo_data.entity.rocket_silo_status == rocket_ready_status
        and (
            --     (get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
            --     or orbit_to_surface)
            --     and passed_rocket_silo_data.entity.name == ROCKET_SILO
            -- or
            --     passed_rocket_silo_data.entity.name == "ipbm-rocket-silo"))
                launchable_rocket_silos[passed_rocket_silo_data.entity.name]
            and ((
                        get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })
                    or
                        orbit_to_surface
                )
                or
                    string_find(passed_rocket_silo_data.entity.name, IPBM)
            )
        )
    ) then

        local inventory = passed_rocket_silo_data.entity.get_inventory(rocket_silo_rocket_inventory)
        if (inventory and inventory.valid) then
            for _, item in ipairs(inventory.get_contents()) do
                if (valid_payload(item.name)) then

                    local is_travelling = false
                    local space_connection_distance = nil
                    local space_connection_distance_travelled = nil
                    local space_connection = nil
                    local reversed = false
                    local space_connection_contains_destination = false

                    -- local is_ipbm = passed_rocket_silo_data.entity.name == "ipbm-rocket-silo"
                    local is_ipbm = string_find(passed_rocket_silo_data.entity.name, IPBM) ~= nil

                    local base_target_distance = 0

                    if (not se_active and not Constants.planets_dictionary[passed_rocket_silo_data.entity.surface.name]) then Constants.get_planets(true) end
                    local origin_space_location = not se_active and Constants.planets_dictionary[passed_rocket_silo_data.entity.surface.name]
                    if (not origin_space_location) then
                        if (se_active) then
                            if (string_find(passed_rocket_silo_data.entity.surface.name, "spaceship-", 1, true)) then
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
                                    warn(origin_space_location and origin_space_location.name)
                                    info(origin_space_location)
                                end
                            end
                        else
                            if (string.find(passed_rocket_silo_data.entity.surface.name, PLATFORM_PREFIX, 1, true) and passed_rocket_silo_data.entity.surface.platform and passed_rocket_silo_data.entity.surface.platform.valid) then
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
                                        space_connection_distance = space_connection_distance * get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name })

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
                        warn(origin_space_location and origin_space_location.name)
                        local origin_system_name = nil
                        if (origin_space_location.type) then
                            warn(origin_space_location and origin_space_location.previous_space_location and origin_space_location.previous_space_location.name)
                            origin_system_name = origin_space_location.type == "spaceship-data" and origin_space_location.previous_space_location:get_stellar_system() or origin_space_location:get_stellar_system()

                            if (not origin_space_location.type == "spaceship-data" and not Constants.space_exploration_dictionary[origin_system_name]) then Constants.get_space_exploration_universe(true) end
                            origin_system = Constants.space_exploration_dictionary[origin_system_name]
                        else
                            --[[ TODO: what exactly? ]]
                        end
                        if (not Constants.space_exploration_dictionary[origin_system_name]) then warn(origin_system_name); Constants.get_space_exploration_universe(true) end
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

                    warn(origin_space_location and origin_space_location.name)
                    warn(origin_pos)

                    local launched_from_space = string_find(space_location_name, PLATFORM_PREFIX, 1, true) == 1
                    if (se_active) then
                        --[[ Check for SE space launches ]]
                        warn(origin_space_location.name)
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
                    debug(origin_space_location and origin_space_location.name)
                    debug(target_planet and target_planet.name)
                    debug(source_target_planet and source_target_planet.name)
                    debug(origin_pos)

                    local target_distance =  1
                    if (se_active) then
                        info(origin_system)
                        warn(origin_system and origin_system.name)
                        info(source_target_system)
                        warn(source_target_system and source_target_system.name)
                        info(source_target_planet)
                        warn(source_target_planet and source_target_planet.name)
                        if (origin_system and (source_target_system or source_target_planet)) then
                            if (not source_target_system) then source_target_system = source_target_planet end

                            local origin_space_distortion = origin_space_location.type == "anomaly-data" and origin_space_location.space_distortion or 0
                            local destination_space_distortion = source_target_planet.type == "anomaly-data" and origin_space_location.space_distortion or 0

                            local distance_calculcated = false

                            --[[ Haven't actually tested this yet; that being firing at/from the anomaly ]]
                            if (origin_space_distortion > 0 and destination_space_distortion > 0) then
                                --[[ Patrially distorted ]]
                                target_distance = Zone_Static_Data.travel_cost.interstellar * math_abs(origin_space_distortion - destination_space_distortion)
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

                            warn(origin_system.name)
                            debug(origin_system.planet_gravity_well)
                            debug(origin_system.star_gravity_well)

                            warn(origin_space_location.name)
                            debug(origin_space_location.planet_gravity_well)
                            debug(origin_space_location.star_gravity_well)

                            warn(source_target_system.name)
                            debug(source_target_system.planet_gravity_well)
                            debug(source_target_system.star_gravity_well)

                            warn(source_target_planet.name)
                            debug(source_target_planet.planet_gravity_well)
                            debug(source_target_planet.star_gravity_well)

                            debug(Zone_Static_Data.travel_cost.planet_gravity)

                            if (not distance_calculcated) then
                                debug("distance not yet calculated - no distortion")
                                if (origin_system.x == source_target_system.x and origin_system.y == source_target_system.y) then
                                    --[[ Same solar system ]]
                                    debug("same solar system")
                                    local origin_star_gravity_well = origin_space_location.star_gravity_well
                                    debug(origin_star_gravity_well)
                                    if (origin_space_location.type == "orbit-data") then
                                        origin_star_gravity_well = origin_space_location.parent and origin_space_location.parent.star_gravity_well or 0
                                    end
                                    debug(origin_star_gravity_well)

                                    if (origin_star_gravity_well == source_target_planet.star_gravity_well) then
                                        --[[ Same planetary system ]]
                                        debug("same planetary system")
                                        info(origin_space_location)
                                        debug(math_abs(origin_space_location.planet_gravity_well - source_target_planet.planet_gravity_well))

                                        local origin_planet_gravity_well = origin_space_location.star_gravity_well
                                        debug(origin_planet_gravity_well)
                                        if (origin_space_location.type == "orbit-data") then
                                            origin_planet_gravity_well = origin_space_location.parent and origin_space_location.parent.star_gravity_well or 0
                                        end
                                        debug(origin_planet_gravity_well)

                                        target_distance = Zone_Static_Data.travel_cost.planet_gravity * math_abs(origin_planet_gravity_well - source_target_planet.planet_gravity_well)
                                    else
                                        --[[ Different planetary system ]]
                                        debug("different planetary system")
                                        target_distance = Zone_Static_Data.travel_cost.star_gravity * math_abs(origin_star_gravity_well - source_target_planet.star_gravity_well)
                                            + Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well
                                            + Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well
                                    end
                                else
                                    --[[ Different solar systems ]]
                                    debug("different solar system")
                                    local target = source_target_system or source_target_planet
                                    local base_interstellar_distance = (((origin_pos.x - target.x) ^ 2 + (origin_pos.y - target.y) ^ 2) ^ 0.5)
                                    debug(base_interstellar_distance)
                                    debug(Zone_Static_Data.travel_cost.interstellar * base_interstellar_distance)
                                    debug(Zone_Static_Data.travel_cost.star_gravity * origin_space_location.star_gravity_well)
                                    debug(Zone_Static_Data.travel_cost.planet_gravity * origin_space_location.planet_gravity_well)
                                    debug(Zone_Static_Data.travel_cost.star_gravity * source_target_planet.star_gravity_well)
                                    debug(Zone_Static_Data.travel_cost.planet_gravity * source_target_planet.planet_gravity_well)

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
                    warn(serpent.block(target_distance))

                    warn("pre-multiplication, target_distance = " .. target_distance)
                    if (not se_active) then
                        target_distance = target_distance * get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name })
                    end
                    warn("post-multiplication, target_distance = " .. target_distance)
                    if (not se_active) then
                        if (string_find(space_location_name, PLATFORM_PREFIX, 1, true)) then
                            --[[ base_target_distance shouldn't contribute as much if launched from space/a platform -> it is already in space/orbit ]]
                            target_distance = target_distance + math_log(1 + base_target_distance, (E * 2) / (target_planet.magnitude) ^ E)
                            warn(target_distance)
                        else
                            target_distance = target_distance + base_target_distance
                            debug(target_distance)
                        end
                    else
                        --[[ TODO: anything? ]]
                    end

                    warn("is_travelling = " .. tostring(is_travelling))

                    local local_rocket_silo_data =
                    {
                        entity = passed_rocket_silo_data.entity,
                        -- distance = is_travelling and distance_to_target or target_distance,
                        distance = target_distance or -1,
                        source_surface = passed_rocket_silo_data.entity.surface,
                        launched_from = INTERPLANETARY,
                        launched_from_space = launched_from_space,
                        base_target_distance = base_target_distance,
                        is_travelling = is_travelling,
                        space_origin_pos = origin_pos,
                        -- origin_system = origin_system,
                        -- source_target_system = source_target_system,
                        is_ipbm = is_ipbm,
                    }

                    warn(serpent.block(local_rocket_silo_data))
                    warn(serpent.block(target_distance))

                    if (rocket_silo_array) then
                        if (#rocket_silo_array == 0) then
                            table_insert(rocket_silo_array, local_rocket_silo_data)
                        else
                            local found = false
                            for i, j in ipairs(rocket_silo_array) do
                                if (
                                            (distance_to_target
                                        and
                                            (distance_to_target < j.distance
                                            or
                                                string_find(space_location_name, PLATFORM_PREFIX, 1, true)
                                                and distance_to_target <= j.distance
                                                and j.entity.name == ROCKET_SILO
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
                                                    string_find(space_location_name, PLATFORM_PREFIX, 1, true)
                                                and target_distance <= j.distance
                                                and j.entity.name == ROCKET_SILO
                                            or
                                                is_ipbm
                                                and target_distance <= j.distance
                                        )
                                    )
                                )
                                then
                                    table_insert(rocket_silo_array, i, local_rocket_silo_data)
                                    found = true
                                    break
                                end
                            end

                            if (not found) then
                                table_insert(rocket_silo_array, local_rocket_silo_data)
                            end
                        end
                        debug(rocket_silo_array)
                    end

                    debug(space_location_name)
                    debug(local_rocket_silo_data.entity.surface.name)
                    debug(local_rocket_silo_data.entity.surface.platform)
                    debug(space_connection_contains_destination)
                    debug(reversed)

                    --[[ Return the calculated rocket_silo_data; and secondarily return the rocket_silo_array if it was provided ]]
                    return local_rocket_silo_data, rocket_silo_array
                end
            end
        end
    end

    return -2
end

function rocket_silo_utils.init(__storage) storage = __storage or _ENV.storage end

return rocket_silo_utils
