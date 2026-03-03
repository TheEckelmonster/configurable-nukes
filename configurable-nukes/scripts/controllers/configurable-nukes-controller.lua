local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick_rocket_silo_processing = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name })
configurable_nukes_controller.num_surfaces_to_process = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name })

local rocket_ready_status = defines.rocket_silo_status.rocket_ready

configurable_nukes_controller.rhythm = { name = configurable_nukes_controller.name, }

---

function configurable_nukes_controller.on_nth_tick(event)
    -- Log.debug("configurable_nukes_controller.on_nth_tick")
    -- Log.info(event)

    storage.cache = storage.cache or {}
    local cache = storage.cache

    if (not cache.print_space_launched_time_to_target_message or cache.print_space_launched_time_to_target_message.ttl < game.tick) then
        cache.print_space_launched_time_to_target_message = { value = true, ttl = game.tick + 20 }
        ICBM_Utils.print_space_launched_time_to_target_message()
    end

    if (storage.rkt_key and storage.rkt_val) then
        local circuit_connected_silos = nil

        for i = 1, configurable_nukes_controller.num_surfaces_to_process or 1, 1 do
            if (storage.rkt_val.entity and storage.rkt_val.entity.valid and storage.rkt_val.entity.type == "rocket-silo" and storage.rkt_val.entity.rocket_silo_status == rocket_ready_status) then
                circuit_connected_silos = circuit_connected_silos or {}
                circuit_connected_silos[storage.rkt_key] = storage.rkt_val
            end

            if (storage.rkt_key and not storage.rocket_silos[storage.rkt_key]) then storage.rkt_key = nil end
            storage.rkt_key, storage.rkt_val = next(storage.rocket_silos, storage.rkt_key)
            if (not storage.rkt_key or not storage.rkt_val) then break end
        end

        if (circuit_connected_silos) then
            Circuit_Network_Service.attempt_launch_silos({ rocket_silos = circuit_connected_silos, })
        end
    else
        if (storage.rkt_key and not storage.rocket_silos[storage.rkt_key]) then storage.rkt_key = nil end
        storage.rkt_key, storage.rkt_val = next(storage.rocket_silos, storage.rkt_key)
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
    elseif (    event.setting == Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name
    ) then
        configurable_nukes_controller.num_surfaces_to_process = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_ROCKET_SILOS_PROCESSED_PER_TICK.name })
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