local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local payload_controller = {}
payload_controller.name = "payload_controller"

payload_controller.nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name })

function payload_controller.on_nth_tick(event)
    Log.debug("payloader_controller.on_nth_tick")
    Log.info(event)

    local payloads = storage.payloads or {}

    for k, payload in pairs(payloads) do
        if (payload.delivered and payload.updated) then
            if (game.tick > payload.delivered + 600 and game.tick > payload.updated + 600) then
                payloads[k] = nil
            end
        else
            if (payload[1]) then
                local _payload = payload
                for i = 1, #_payload, 1 do
                    local payload = _payload[i]
                    if (    not payload.tick
                        or
                            game.tick
                        and (
                                payload.icbm
                            and payload.icbm.tick_to_target
                            and (
                                    payload.icbm.tick_to_target <= payload.tick
                                and payload.tick - payload.icbm.tick_to_target >= 240 + payload_controller.nth_tick
                                or
                                    payload.icbm.tick_to_target <= game.tick
                                and game.tick - payload.icbm.tick_to_target >= 240 + payload_controller.nth_tick
                            )
                            or
                                game.tick > payload.tick
                            and game.tick - payload.tick >= 240 + payload_controller.nth_tick
                        )
                    ) then
                        payloads[k] = nil
                    end
                end
            else
                if (    not payload.tick
                    or
                        game.tick
                    and (
                            payload.icbm
                        and payload.icbm.tick_to_target
                        and (
                                payload.icbm.tick_to_target <= payload.tick
                            and payload.tick - payload.icbm.tick_to_target >= 240 + payload_controller.nth_tick
                            or
                                payload.icbm.tick_to_target <= game.tick
                            and game.tick - payload.icbm.tick_to_target >= 240 + payload_controller.nth_tick
                        )
                        or
                            game.tick > payload.tick
                        and game.tick - payload.tick >= 240 + payload_controller.nth_tick
                    )
                ) then
                    payloads[k] = nil
                end
            end
        end
    end
end
--[[ Registerd in events.lua ]]

function payload_controller.on_runtime_mod_setting_changed(event)
    Log.debug("payload_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name) then
        local new_nth_tick = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name, reindex = true })
        if (new_nth_tick ~= nil and type(new_nth_tick) == "number" and new_nth_tick >= 1 and new_nth_tick <= 60 * 60) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = payload_controller.nth_tick
            Event_Handler:unregister_event({
                event_name = "on_nth_tick",
                nth_tick = prev_nth_tick,
                source_name = "payload_controller.on_nth_tick",
            })

            Event_Handler:register_event({
                event_name = "on_nth_tick",
                nth_tick = new_nth_tick,
                source_name = "payload_controller.on_nth_tick",
                func_name = "payload_controller.on_nth_tick",
                func = payload_controller.on_nth_tick,
            })
            payload_controller.nth_tick = new_nth_tick
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "payload_controller.on_runtime_mod_setting_changed",
    func_name = "payload_controller.on_runtime_mod_setting_changed",
    func = payload_controller.on_runtime_mod_setting_changed,
})

return payload_controller