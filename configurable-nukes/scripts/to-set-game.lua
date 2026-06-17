local ipairs = ipairs

To_Set_Game = To_Set_Game or {
    to_set = {
        require("scripts.controllers.payloader-controller"),
    }
}

function Set_game_all(event)
    local __game, __storage = _ENV.game, _ENV.storage
    __storage.settings_map = __storage.settings_map or {}
    __storage.settings_map.runtime_global = __storage.settings_map.runtime_global or {}

    for _, v in ipairs(To_Set_Game.to_set or {}) do
        if (type(v.set_game) == "function") then
            v.set_game(event, __game, __storage)
        end
    end
end
To_Set_Game.set_game_all = Set_game_all
Event_Handler:register_events({
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = "To_Set_Game.set_game_all",
        func_name = "To_Set_Game.set_game_all",
        func = To_Set_Game.set_game_all,
    },
    -- {
    --     event_name = Custom_Events.cn_migrations_applied.name,
    --     source_name = "To_Set_Game.set_game_all",
    --     func_name = "To_Set_Game.set_game_all",
    --     func = To_Set_Game.set_game_all,
    -- },
    {
        event_name = "on_configuration_changed",
        source_name = "To_Set_Game.set_game_all",
        func_name = "To_Set_Game.set_game_all",
        func = To_Set_Game.set_game_all,
    }
})

return To_Set_Game