local ipairs = ipairs
-- local pairs = pairs

-- To_Set_Game = To_Set_Game or {}

-- function Set_Forces()
--     local game = _ENV.game

--     _ENV.Forces = _ENV.Forces or {}
--     Forces = _ENV.Forces
--     Forces.list = Forces.list or {}

--     _ENV.Force_Funcs = _ENV.Force_Funcs or {}
--     Force_Funcs = _ENV.Force_Funcs
--     for name, force in pairs(game.forces) do
--         if (force.valid) then
--             Forces[name] = force
--             Forces.list[force.index] = name
--             Force_Funcs[name] = Force_Funcs[name] or {}
--         else
--             Forces[name] = nil
--         end
--     end
-- end
-- To_Set_Game.set_forces = Set_Forces

-- function Set_Surfaces()
--     local game = _ENV.game

--     _ENV.Surfaces = _ENV.Surfaces or {}
--     Surfaces = _ENV.Surfaces
--     Surfaces.list = Surfaces.list or {}

--     _ENV.Surface_Funcs = _ENV.Surface_Funcs or {}
--     Surface_Funcs = _ENV.Surface_Funcs
--     for name, surface in pairs(game.surfaces) do
--         if (surface.valid) then
--             Surfaces[name] = surface
--             Surfaces.list[surface.index] = name

--             Surface_Funcs[name] = Surface_Funcs[name] or {}
--         else
--             Surfaces[name], Surface_Funcs[name] = nil, nil
--         end
--     end
-- end
-- To_Set_Game.set_surfaces = Set_Surfaces

-- function Set_Game_Funcs()
--     To_Set_Game.set_forces()
--     To_Set_Game.set_surfaces()
-- end
-- To_Set_Game.set_game_funcs = Set_Game_Funcs

To_Set_Game = To_Set_Game or {
    to_set = {
        require("scripts.controllers.configurable-nukes-controller"),
        -- require("scripts.controllers.guis.payloader-gui-controller"),
        require("scripts.controllers.payloader-controller"),
        require("scripts.services.circuit-network-service"),
        require("scripts.utils.ICBM-utils"),
        -- require("scripts.utils.rocket-silo-utils"),
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