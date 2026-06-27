local storage
local cache
local icbms_researched
local ordered_rocket_silos
local ready_rocket_silos
local recently_launched_rkt_silos
local rocket_silos
local rocket_silo_status_timeout
local surfaces

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.cache = storage.cache
    cache = storage.cache

    storage.icbms_researched = storage.icbms_researched or {}
    icbms_researched = storage.icbms_researched

    storage.ordered_rocket_silos = storage.ordered_rocket_silos
    ordered_rocket_silos = storage.ordered_rocket_silos

    storage.ready_rocket_silos = storage.ready_rocket_silos or {}
    ready_rocket_silos = storage.ready_rocket_silos

    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
    recently_launched_rkt_silos = storage.recently_launched_rkt_silos

    storage.rocket_silos = storage.rocket_silos or {}
    rocket_silos = storage.rocket_silos

    storage.rocket_silo_status_timeout = storage.rocket_silo_status_timeout or {}
    rocket_silo_status_timeout = storage.rocket_silo_status_timeout

    surfaces = storage.surfaces or {}
    surfaces = storage.surfaces

    --[[ game ]]
    game = __game or _ENV.game

    return game
end

local table = table
local table_insert = table.insert
local table_remove = table.remove
local type = type

local next = next
local type = type

local defines = defines

local ROCKET_SILO_STATUS_TIMEOUTS = {
    -- [defines.rocket_silo_status.building_rocket] = Constants.BIG_INTEGER,
    -- [defines.rocket_silo_status.create_rocket] = 1900,
    -- [defines.rocket_silo_status.lights_blinking_open] = 1,
    -- [defines.rocket_silo_status.doors_opening] = 1,
    -- [defines.rocket_silo_status.doors_opened] = 1,
    -- [defines.rocket_silo_status.rocket_rising] = 1,
    [defines.rocket_silo_status.arms_advance] = 1,
    [defines.rocket_silo_status.rocket_ready] = 1,
    -- [defines.rocket_silo_status.launch_starting] = 1,
    -- [defines.rocket_silo_status.engine_starting] = 1,
    -- [defines.rocket_silo_status.arms_retract] = 1,
    -- [defines.rocket_silo_status.rocket_flying] = 1,
    -- [defines.rocket_silo_status.lights_blinking_close] = 1,
    -- [defines.rocket_silo_status.doors_closing] = 1,
    -- [defines.rocket_silo_status.launch_started] = 1,
}

local Data_Utils = Data_Utils
local Event_Handler = Event_Handler
local Log = Log
local Settings_Service = Settings_Service

local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local attempt_launch_silos = Circuit_Network_Service.attempt_launch_silos
local print_space_launched_time_to_target_message = ICBM_Utils.print_space_launched_time_to_target_message

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"
configurable_nukes_controller.set_game = set_game

configurable_nukes_controller.nth_tick_rocket_silo_processing = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name })
configurable_nukes_controller.num_rocket_silos_to_process = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name })
configurable_nukes_controller.rocket_silo_processing_mode = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name })

local rocket_ready_status = defines.rocket_silo_status.rocket_ready

local circuit_networks = {
    defines.wire_connector_id.circuit_red,
    defines.wire_connector_id.circuit_green,
}

configurable_nukes_controller.rhythm = { name = configurable_nukes_controller.name, }

---

function configurable_nukes_controller.on_clamps_on_trigger(event)
    -- log(serpent.block(event))
    -- game.print(serpent.block(event))

    if (not event) then return end

    if (not event.cause_entity or not event.cause_entity.valid) then return end
    local unit_number = event.cause_entity.unit_number

    if (    not rocket_silos
        and set_game()
        and not rocket_silos
        or
             not rocket_silos[unit_number]
    ) then
        return
    end

    ready_rocket_silos = ready_rocket_silos or set_game() and ready_rocket_silos
    ready_rocket_silos[unit_number] = event.tick + 100
end

function configurable_nukes_controller.on_tick(event)

    ordered_rocket_silos = ordered_rocket_silos or set_game() and ordered_rocket_silos
    if (not ordered_rocket_silos[event.tick % 60]) then return end
    if (not ordered_rocket_silos[event.tick % 60][1]) then
        ordered_rocket_silos[event.tick % 60] = nil
        return
    end
    local rocket_silos_row = ordered_rocket_silos[event.tick % 60]
    local circuit_network_data = nil
    local circuit_connected_silos = nil
    rocket_silos_row.added_last_tick = 0
    rocket_silos_row.idx = rocket_silos_row.idx or 1
    ready_rocket_silos = ready_rocket_silos or set_game() and ready_rocket_silos
    rocket_silo_status_timeout = rocket_silo_status_timeout or set_game() and rocket_silo_status_timeout
    for idx = rocket_silos_row.idx, #rocket_silos_row, 1 do
        circuit_network_data = rocket_silos_row[idx]
        if (not circuit_network_data) then goto continue end
        if (rocket_silos_row.added_last_tick > configurable_nukes_controller.num_rocket_silos_to_process) then break end
        if (not circuit_network_data.entity.valid) then
            table_remove(ordered_rocket_silos[event.tick % 60], idx)
        elseif (
                ready_rocket_silos[circuit_network_data.unit_number]
            and ready_rocket_silos[circuit_network_data.unit_number] <= event.tick
            and (
                    not rocket_silo_status_timeout[circuit_network_data.unit_number]
                or
                    rocket_silo_status_timeout[circuit_network_data.unit_number] <= event.tick
            )
        ) then
            if (    circuit_network_data.entity.send_to_orbit_automatically
                or
                    circuit_network_data.entity.rocket_silo_status ~= rocket_ready_status
                or
                    recently_launched_rkt_silos
                and recently_launched_rkt_silos[circuit_network_data.unit_number]
                and recently_launched_rkt_silos[circuit_network_data.unit_number] >= event.tick - 1600
                or
                    set_game()
                and recently_launched_rkt_silos
                and recently_launched_rkt_silos[circuit_network_data.unit_number]
                and recently_launched_rkt_silos[circuit_network_data.unit_number] >= event.tick - 1600
                or
                        not icbms_researched
                    and set_game()
                    and not icbms_researched
                or
                    not icbms_researched[circuit_network_data.entity.force.index]
            ) then
                recently_launched_rkt_silos[circuit_network_data.unit_number] = recently_launched_rkt_silos[circuit_network_data.unit_number] or rocket_silo_status_timeout[circuit_network_data.rocket_silo_status] or event.tick
                goto continue
            end

            local signals = circuit_network_data.entity.get_signals(circuit_networks[1], circuit_networks[2])
            if (signals and #signals > 3) then
                rocket_silos_row.added_last_tick = rocket_silos_row.added_last_tick + 1
                circuit_connected_silos = circuit_connected_silos or {}
                circuit_connected_silos[rocket_silos_row.added_last_tick] = { circuit_network_data = circuit_network_data, signals = signals, }
            end
        end

        ::continue::
    end

    if (circuit_connected_silos) then attempt_launch_silos({ tick = event.tick, rocket_silos_row = circuit_connected_silos, }) end

    rocket_silos_row.idx = 1 + (rocket_silos_row.idx + configurable_nukes_controller.num_rocket_silos_to_process) % #rocket_silos_row
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "configurable_nukes_controller.on_tick",
    func_name = "configurable_nukes_controller.on_tick",
    func = configurable_nukes_controller.on_tick,
})

---

function configurable_nukes_controller.on_nth_tick(event)
    -- Log.debug("configurable_nukes_controller.on_nth_tick")
    -- Log.info(event)

    if (not storage.icbms_researched) then return end

    -- local storage = storage

    cache = cache or set_game() and cache

    if (not cache.print_space_launched_time_to_target_message or cache.print_space_launched_time_to_target_message.ttl < game.tick) then
        cache.print_space_launched_time_to_target_message = { value = true, ttl = event.tick + 20 }
        -- ICBM_Utils.print_space_launched_time_to_target_message()
        print_space_launched_time_to_target_message()
    end

    local circuit_connected_silos = nil

    if (configurable_nukes_controller.rocket_silo_processing_mode ~= "performance") then
        surfaces = surfaces or set_game() or surfaces

        if (storage.surface_key) then
            for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
                if (storage.rkt_surface_key and storage.rkt_surface_val) then
                    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
                    if (not storage.recently_launched_rkt_silos[storage.rkt_surface_key] or storage.recently_launched_rkt_silos[storage.rkt_surface_key] < game.tick - 1600) then
                        if (storage.recently_launched_rkt_silos[storage.rkt_surface_key] and storage.recently_launched_rkt_silos[storage.rkt_surface_key] < game.tick - 1600) then storage.recently_launched_rkt_silos[storage.rkt_surface_key] = nil end
                        if (storage.rkt_surface_val.entity and storage.rkt_surface_val.entity.valid and storage.rkt_surface_val.entity.type == "rocket-silo" and not storage.rkt_surface_val.entity.send_to_orbit_automatically and storage.rkt_surface_val.entity.rocket_silo_status == rocket_ready_status) then
                            -- if (storage.rkt_surface_val.entity.get_circuit_network(circuit_networks[1]) or storage.rkt_surface_val.entity.get_circuit_network(circuit_networks[2])) then
                            --     circuit_connected_silos = circuit_connected_silos or {}
                            --     circuit_connected_silos[storage.rkt_surface_key] = storage.rkt_surface_val
                            -- end
                            if (storage.icbms_researched and storage.icbms_researched[storage.rkt_surface_val.entity.force.index]) then
                                -- if (storage.rkt_surface_val.entity.get_circuit_network(circuit_networks[1]) or storage.rkt_surface_val.entity.get_circuit_network(circuit_networks[2]) then
                                -- if (storage.rkt_surface_val.entity.get_signals(circuit_networks[1], circuit_networks[2])) then
                                local signals = storage.rkt_surface_val.entity.get_signals(circuit_networks[1], circuit_networks[2])
                                if (signals and #signals > 3) then
                                    circuit_connected_silos = circuit_connected_silos or {}
                                    circuit_connected_silos[storage.rkt_surface_key] = storage.rkt_surface_val
                                end
                            end
                        end
                    end
                end
                if (storage.rkt_surface_key and not storage.surfaces[storage.surface_key][storage.rkt_surface_key]) then storage.rkt_surface_key = nil end
                storage.rkt_surface_key, storage.rkt_surface_val = next(storage.surfaces[storage.surface_key], storage.rkt_surface_key)

                if (storage.surface_key and not storage.surfaces[storage.surface_key]) then storage.surface_key = nil end
                storage.surface_key, _ = next(storage.surfaces, storage.surface_key)
                if (not storage.surface_key) then break end
            end
        else
            if (storage.surface_key and not storage.surfaces[storage.surface_key]) then storage.surface_key = nil end
            storage.surface_key, _ = next(storage.surfaces, storage.surface_key)
        end
    end

    rocket_silos = rocket_silos or {}
    if (storage.rkt_key and storage.rkt_val) then
        for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
            storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
            if (not storage.recently_launched_rkt_silos[storage.rkt_key] or storage.recently_launched_rkt_silos[storage.rkt_key] < game.tick - 1600) then
                if (storage.recently_launched_rkt_silos[storage.rkt_key] and storage.recently_launched_rkt_silos[storage.rkt_key] < game.tick - 1600) then storage.recently_launched_rkt_silos[storage.rkt_key] = nil end
                if (storage.rkt_val.entity and storage.rkt_val.entity.valid and storage.rkt_val.entity.type == "rocket-silo" and not storage.rkt_val.entity.send_to_orbit_automatically and storage.rkt_val.entity.rocket_silo_status == rocket_ready_status) then
                    if (not circuit_connected_silos or not circuit_connected_silos[storage.rkt_key]) then
                        -- if (storage.rkt_val.entity.get_circuit_network(circuit_networks[1]) or storage.rkt_val.entity.get_circuit_network(circuit_networks[2])) then
                        --     circuit_connected_silos = circuit_connected_silos or {}
                        --     circuit_connected_silos[storage.rkt_key] = storage.rkt_val
                        -- end
                        if (storage.icbms_researched and storage.icbms_researched[storage.rkt_val.entity.force.index]) then
                            -- if (storage.rkt_val.entity.get_circuit_network(circuit_networks[1]) or storage.rkt_val.entity.get_circuit_network(circuit_networks[2])) then
                            -- if (storage.rkt_val.entity.get_signals(circuit_networks[1], circuit_networks[2])) then
                            local signals = storage.rkt_val.entity.get_signals(circuit_networks[1], circuit_networks[2])
                            if (signals and #signals > 3) then
                                circuit_connected_silos = circuit_connected_silos or {}
                                circuit_connected_silos[storage.rkt_key] = storage.rkt_val
                            end
                        end
                    end
                end
            end

            if (storage.rkt_key and not rocket_silos[storage.rkt_key]) then storage.rkt_key = nil end
            storage.rkt_key, storage.rkt_val = next(rocket_silos, storage.rkt_key)
            if (not storage.rkt_key or not storage.rkt_val) then break end
        end

    else
        if (storage.rkt_key and not rocket_silos[storage.rkt_key]) then storage.rkt_key = nil end
        storage.rkt_key, storage.rkt_val = next(rocket_silos, storage.rkt_key)
    end

    if (configurable_nukes_controller.rocket_silo_processing_mode == "responsive") then
        storage.circuit_connected_rkt_silos = storage.circuit_connected_rkt_silos or {}

        if (storage.circuit_connected_rkt_key and storage.circuit_connected_rkt_val) then
            for i = 1, configurable_nukes_controller.num_rocket_silos_to_process or 1, 1 do
                storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
                if (not storage.recently_launched_rkt_silos[storage.rkt_key] or storage.recently_launched_rkt_silos[storage.rkt_key] < game.tick - 1600) then
                    if (storage.recently_launched_rkt_silos[storage.rkt_key] and storage.recently_launched_rkt_silos[storage.rkt_key] < game.tick - 1600) then storage.recently_launched_rkt_silos[storage.rkt_key] = nil end
                    if (storage.circuit_connected_rkt_val.entity and storage.circuit_connected_rkt_val.entity.valid and storage.circuit_connected_rkt_val.entity.type == "rocket-silo" and not storage.circuit_connected_rkt_val.entity.send_to_orbit_automatically and storage.circuit_connected_rkt_val.entity.rocket_silo_status == rocket_ready_status) then
                        if (not circuit_connected_silos or not circuit_connected_silos[storage.circuit_connected_rkt_key]) then
                            -- if (storage.circuit_connected_rkt_val.entity.get_circuit_network(circuit_networks[1]) or storage.circuit_connected_rkt_val.entity.get_circuit_network(circuit_networks[2])) then
                            --     circuit_connected_silos = circuit_connected_silos or {}
                            --     circuit_connected_silos[storage.circuit_connected_rkt_key] = storage.circuit_connected_rkt_val
                            -- end
                            if (storage.icbms_researched and storage.icbms_researched[storage.circuit_connected_rkt_val.entity.force.index]) then
                                -- if (storage.circuit_connected_rkt_val.entity.get_circuit_network(circuit_networks[1]) or storage.circuit_connected_rkt_val.entity.get_circuit_network(circuit_networks[2])) then
                                -- if (storage.circuit_connected_rkt_val.entity.get_signals(circuit_networks[1], circuit_networks[2])) then
                                local signals = storage.circuit_connected_rkt_val.entity.get_signals(circuit_networks[1], circuit_networks[2])
                                if (signals and #signals > 3) then
                                    circuit_connected_silos = circuit_connected_silos or {}
                                    circuit_connected_silos[storage.circuit_connected_rkt_key] = storage.circuit_connected_rkt_val
                                end
                            end
                        end
                    end
                end

                if (storage.circuit_connected_rkt_key and not rocket_silos[storage.circuit_connected_rkt_key]) then storage.circuit_connected_rkt_key = nil end
                storage.circuit_connected_rkt_key, storage.circuit_connected_rkt_val = next(rocket_silos, storage.circuit_connected_rkt_key)
                if (not storage.circuit_connected_rkt_key or not storage.circuit_connected_rkt_val) then break end
            end
        else
            if (storage.circuit_connected_rkt_key and not storage.circuit_connected_rkt_silos[storage.circuit_connected_rkt_key]) then storage.circuit_connected_rkt_key = nil end
            storage.circuit_connected_rkt_key, storage.circuit_connected_rkt_val = next(storage.circuit_connected_rkt_silos, storage.circuit_connected_rkt_key)
        end
    end

    if (circuit_connected_silos) then
        Circuit_Network_Service.attempt_launch_silos({ rocket_silos = circuit_connected_silos, })
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
        configurable_nukes_controller.num_rocket_silos_to_process = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name) then
        configurable_nukes_controller.rocket_silo_processing_mode = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILOS_PROCESSING_MODE.name, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func_name = "configurable_nukes_controller.on_runtime_mod_setting_changed",
    func = configurable_nukes_controller.on_runtime_mod_setting_changed,
})

function configurable_nukes_controller.init(__storage)
    storage = __storage
end

return configurable_nukes_controller