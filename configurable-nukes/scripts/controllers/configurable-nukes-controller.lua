local storage
local cache
local circuit_connected_rkt_silos
local keys
local rocket_silos
local surfaces
local recently_launched_rkt_silos

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.cache = storage.cache or {}
    cache = storage.cache

    storage.circuit_connected_rkt_silos = storage.circuit_connected_rkt_silos or {}
    circuit_connected_rkt_silos = storage.circuit_connected_rkt_silos

    storage.keys = storage.keys or {}
    keys = storage.keys

    storage.rocket_silos = storage.rocket_silos
    rocket_silos = storage.rocket_silos

    storage.surfaces = storage.surfaces or {}
    surfaces = storage.surfaces

    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
    recently_launched_rkt_silos = storage.recently_launched_rkt_silos

    game = __game or _ENV.game

    return game
end

local next = next
local type = type

local PERFORMANCE = "performance"
local RESPONSIVE = "responsive"
local ROCKET_SILO = "rocket-silo"

local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local attempt_launch_silos = Circuit_Network_Service.attempt_launch_silos
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local print_space_launched_time_to_target_message = ICBM_Utils.print_space_launched_time_to_target_message
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"
configurable_nukes_controller.set_game = set_game

configurable_nukes_controller.nth_tick_rocket_silo_processing = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name })
configurable_nukes_controller.num_rocket_silos_to_process = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name })
configurable_nukes_controller.rocket_silo_processing_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name })

local rocket_ready_status = defines.rocket_silo_status.rocket_ready
local wire_connector_id = defines.wire_connector_id
local wire_connector_id_circuit_green = wire_connector_id.circuit_green
local wire_connector_id_circuit_red = wire_connector_id.circuit_red

configurable_nukes_controller.rhythm = { name = configurable_nukes_controller.name, }

---

local tick = 0
function configurable_nukes_controller.on_nth_tick(event)
    -- Log.debug("configurable_nukes_controller.on_nth_tick")
    -- Log.info(event)

    cache = cache or set_game() and cache
    tick = event.tick

    if (not cache.print_space_launched_time_to_target_message or cache.print_space_launched_time_to_target_message.ttl < tick) then
        cache.print_space_launched_time_to_target_message = cache.print_space_launched_time_to_target_message or {}
        cache.print_space_launched_time_to_target_message.value, cache.print_space_launched_time_to_target_message.ttl = true, tick + 20
        print_space_launched_time_to_target_message()
    end

    local circuit_connected_silos = nil

    if (configurable_nukes_controller.rocket_silo_processing_mode ~= PERFORMANCE) then
        surfaces = surfaces or set_game() and surfaces
        keys = keys or set_game() and keys

        if (keys.surface_key) then
            for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
                if (keys.rkt_surface_key and keys.rkt_surface_val) then
                    recently_launched_rkt_silos = recently_launched_rkt_silos or set_game()
                    if (not recently_launched_rkt_silos[keys.rkt_surface_key] or recently_launched_rkt_silos[keys.rkt_surface_key] < tick - 1600) then
                        if (recently_launched_rkt_silos[keys.rkt_surface_key] and recently_launched_rkt_silos[keys.rkt_surface_key] < tick - 1600) then recently_launched_rkt_silos[keys.rkt_surface_key] = nil end
                        if (keys.rkt_surface_val.entity and keys.rkt_surface_val.entity.valid and keys.rkt_surface_val.entity.type == ROCKET_SILO and not keys.rkt_surface_val.entity.send_to_orbit_automatically and keys.rkt_surface_val.entity.rocket_silo_status == rocket_ready_status) then
                            local get_circuit_network = keys.rkt_surface_val.entity.get_circuit_network
                            if (get_circuit_network(wire_connector_id_circuit_red) or get_circuit_network(wire_connector_id_circuit_green)) then
                                circuit_connected_silos = circuit_connected_silos or {}
                                circuit_connected_silos[keys.rkt_surface_key] = keys.rkt_surface_val
                            end
                        end
                    end
                end
                if (keys.rkt_surface_key and not surfaces[keys.surface_key][keys.rkt_surface_key]) then keys.rkt_surface_key = nil end
                keys.rkt_surface_key, keys.rkt_surface_val = next(surfaces[keys.surface_key], keys.rkt_surface_key)

                if (keys.surface_key and not surfaces[keys.surface_key]) then storage.surface_key = nil end
                keys.surface_key, _ = next(surfaces, keys.surface_key)
                if (not keys.surface_key) then break end
            end
        else
            if (keys.surface_key and not surfaces[keys.surface_key]) then keys.surface_key = nil end
            keys.surface_key, _ = next(surfaces, keys.surface_key)
        end
    end

    rocket_silos = rocket_silos or set_game and rocket_silos
    keys = keys or set_game() and keys

    if (keys.rkt_key and keys.rkt_val) then
        for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
            recently_launched_rkt_silos = recently_launched_rkt_silos or set_game()
            if (not recently_launched_rkt_silos[keys.rkt_key] or recently_launched_rkt_silos[keys.rkt_key] < tick - 1600) then
                if (recently_launched_rkt_silos[keys.rkt_key] and recently_launched_rkt_silos[keys.rkt_key] < tick - 1600) then recently_launched_rkt_silos[keys.rkt_key] = nil end
                if (keys.rkt_val.entity and keys.rkt_val.entity.valid and keys.rkt_val.entity.type == ROCKET_SILO and not keys.rkt_val.entity.send_to_orbit_automatically and keys.rkt_val.entity.rocket_silo_status == rocket_ready_status) then
                    if (not circuit_connected_silos or not circuit_connected_silos[keys.rkt_key]) then
                        local get_circuit_network = keys.rkt_val.entity.get_circuit_network
                        if (get_circuit_network(wire_connector_id_circuit_red) or get_circuit_network(wire_connector_id_circuit_green)) then
                            circuit_connected_silos = circuit_connected_silos or {}
                            circuit_connected_silos[keys.rkt_key] = keys.rkt_val
                        end
                    end
                end
            end

            if (keys.rkt_key and not rocket_silos[keys.rkt_key]) then keys.rkt_key = nil end
            keys.rkt_key, keys.rkt_val = next(rocket_silos, keys.rkt_key)
            if (not keys.rkt_key or not keys.rkt_val) then break end
        end

    else
        if (keys.rkt_key and not keys.rocket_silos[keys.rkt_key]) then keys.rkt_key = nil end
        keys.rkt_key, keys.rkt_val = next(rocket_silos, keys.rkt_key)
    end

    if (configurable_nukes_controller.rocket_silo_processing_mode == RESPONSIVE) then
        circuit_connected_rkt_silos = circuit_connected_rkt_silos or set_game() and circuit_connected_rkt_silos

        if (keys.circuit_connected_rkt_key and keys.circuit_connected_rkt_val) then
            for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
                recently_launched_rkt_silos = recently_launched_rkt_silos or set_game()
                if (not recently_launched_rkt_silos[keys.rkt_key] or recently_launched_rkt_silos[keys.rkt_key] < tick - 1600) then
                    if (recently_launched_rkt_silos[keys.rkt_key] and recently_launched_rkt_silos[keys.rkt_key] < tick - 1600) then recently_launched_rkt_silos[keys.rkt_key] = nil end
                    if (keys.circuit_connected_rkt_val.entity and keys.circuit_connected_rkt_val.entity.valid and keys.circuit_connected_rkt_val.entity.type == ROCKET_SILO and not keys.circuit_connected_rkt_val.entity.send_to_orbit_automatically and keys.circuit_connected_rkt_val.entity.rocket_silo_status == rocket_ready_status) then
                        if (not circuit_connected_silos or not circuit_connected_silos[storage.circuit_connected_rkt_key]) then
                            local get_circuit_network = keys.circuit_connected_rkt_val.entity.get_circuit_network
                            if (get_circuit_network(wire_connector_id_circuit_red) or get_circuit_network(wire_connector_id_circuit_green)) then
                                circuit_connected_silos = circuit_connected_silos or {}
                                circuit_connected_silos[keys.circuit_connected_rkt_key] = keys.circuit_connected_rkt_val
                            end
                        end
                    end
                end

                if (keys.circuit_connected_rkt_key and not rocket_silos[keys.circuit_connected_rkt_key]) then keys.circuit_connected_rkt_key = nil end
                keys.circuit_connected_rkt_key, keys.circuit_connected_rkt_val = next(rocket_silos, keys.circuit_connected_rkt_key)
                if (not keys.circuit_connected_rkt_key or not keys.circuit_connected_rkt_val) then break end
            end
        else
            if (keys.circuit_connected_rkt_key and not circuit_connected_rkt_silos[keys.circuit_connected_rkt_key]) then keys.circuit_connected_rkt_key = nil end
            keys.circuit_connected_rkt_key, keys.circuit_connected_rkt_val = next(circuit_connected_rkt_silos, keys.circuit_connected_rkt_key)
        end
    end

    if (circuit_connected_silos) then
        attempt_launch_silos(circuit_connected_silos, tick)
    end
end
--[[ Registerd in events.lua ]]

function configurable_nukes_controller.on_runtime_mod_setting_changed(event)
    Log.debug("configurable_nukes_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (    event.setting == Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name
    ) then
        local new_nth_tick = Settings_Service.get_runtime_global_setting({ setting = event.setting.name, reindex = true })
        if (new_nth_tick ~= nil and type(new_nth_tick) == "number" and new_nth_tick >= 1 and new_nth_tick <= 60) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = 60
            if (event.setting == Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name) then
                prev_nth_tick = configurable_nukes_controller.nth_tick_rocket_silo_processing
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
            if (event.setting == Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name) then
                configurable_nukes_controller.nth_tick_rocket_silo_processing = new_nth_tick
            end
        end
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name) then
        configurable_nukes_controller.num_rocket_silos_to_process = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name) then
        configurable_nukes_controller.rocket_silo_processing_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func = configurable_nukes_controller.on_runtime_mod_setting_changed,
})

function configurable_nukes_controller.init(__storage) storage = __storage or _ENV.storage end

return configurable_nukes_controller