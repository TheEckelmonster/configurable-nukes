local Util = require("__core__.lualib.util")

local debug_count = 1

return function (params)
    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    if (DEBUG) then log(serpent.block(params)) end

    if (not params or type(params) ~= "table") then return end
    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    if (not params.name or type(params.name) ~= "string") then return end
    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    if ((
                not params.target_effects
            and not params.source_effects
            or
                (
                    params.target_effects
                and type(params.target_effects) ~= "table"
                or
                    params.source_effects
                and type(params.source_effects) ~= "table"
            )
        ) and (
                not params.stream_action
            or  type(params.stream_action) ~= "table"
        ) and (
                not params.beam_action
            or  type(params.beam_action) ~= "table"
        )
    ) then
        return
    end
    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    if (params.target_effects and params.target_effects.projectile) then return end
    if (params.magazine_size and (type(params.magazine_size) ~= "number" or params.magazine_size < 1)) then params.magazine_size = nil end

    local projectile_placeholder = Util.table.deepcopy(data.raw.projectile.rocket)

    projectile_placeholder.name = "cn-projectile-placeholder-" .. params.name
    projectile_placeholder.icon = "__core__/graphics/empty.png"
    projectile_placeholder.icons = nil
    if (not params.no_collision) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        projectile_placeholder.collision_box = {
            { -0.3, -1.1, },
            { 0.3, 1.1, }
        }
    end

    if (params.type and not params.type ~= "land-mine") then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        projectile_placeholder.animation = nil
        projectile_placeholder.shadow = nil
        projectile_placeholder.smoke = nil
    end

    projectile_placeholder.action.action_delivery.target_effects = nil

    local target_effects = {}
    local source_effects = nil

    if (params.target_effects) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        if (params.target_effects[1]) then
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            for _, target_effect in ipairs(params.target_effects) do
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                table.insert(target_effects, target_effect)
            end
        else
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            target_effects = params.target_effects
        end

        projectile_placeholder.action.action_delivery.target_effects = target_effects
    elseif (params.stream_action) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        projectile_placeholder.action = params.stream_action
    elseif (params.beam_action) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        projectile_placeholder.action = params.beam_action
    end

    if (params.source_effects) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        source_effects = {}
        for _, source_effect in ipairs(params.source_effects) do
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            table.insert(source_effects, source_effect)
        end

        if (not next(source_effects)) then source_effects = nil end
        if (source_effects) then
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            if (params.type) then
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                if (params.type == "land-mine") then
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    projectile_placeholder.action.action_delivery.target_effects = projectile_placeholder.action.action_delivery.target_effects or {}
                    for _, v in ipairs(source_effects) do
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        table.insert(projectile_placeholder.action.action_delivery.target_effects, v)
                    end
                else
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    projectile_placeholder.action.action_delivery.source_effects = projectile_placeholder.action.action_delivery.source_effects or {}
                    for _, v in ipairs(source_effects) do
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        table.insert(projectile_placeholder.action.action_delivery.source_effects, v)
                    end
                end
            else
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                projectile_placeholder.action.action_delivery.source_effects = projectile_placeholder.action.action_delivery.source_effects or {}
                for _, v in ipairs(source_effects) do
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    table.insert(projectile_placeholder.action.action_delivery.source_effects, v)
                end
            end
        end
    end

    if (params.magazine_size) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        projectile_placeholder.action.action_delivery.repeat_count = params.magazine_size
    end

    return projectile_placeholder
end