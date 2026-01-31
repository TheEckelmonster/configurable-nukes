local payload_controller = {}
payload_controller.name = "payload_controller"

function payload_controller.on_nth_tick(event)
    Log.debug("payloader_controller.on_nth_tick")
    Log.info(event)

    local payloads = storage.payloads or {}

    for k, payload in pairs(payloads) do
        if (payload.delivered and payload.updated) then
            if (game.tick > payload.delivered + 600 and game.tick > payload.updated + 600) then
                payloads[k] = nil
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_nth_tick",
    --[[ TODO: implement this ]]
    -- nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOADER_UPDATE_RATE.name }) or 15 * 60,
    nth_tick = 15 * 60,
    source_name = "payload_controller.on_nth_tick",
    func_name = "payload_controller.on_nth_tick",
    func = payload_controller.on_nth_tick,
})

return payload_controller