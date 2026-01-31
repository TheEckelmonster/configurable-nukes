local Util = require("__core__.lualib.util")

return function (params)
    if (not params or type(params) ~= "table") then return end
    if (not params.name or type(params.name) ~= "string") then return end
    if ((
                not params.target_effects
            or  type(params.target_effects) ~= "table"
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
    if (params.target_effects and params.target_effects.projectile) then return end
    if (params.magazine_size and (type(params.magazine_size) ~= "number" or params.magazine_size < 1)) then params.magazine_size = nil end

    local projectile_placeholder = Util.table.deepcopy(data.raw.projectile.rocket)

    projectile_placeholder.name = "cn-projectile-placeholder-" .. params.name
    projectile_placeholder.icon = "__core__/graphics/empty.png"
    projectile_placeholder.icons = nil
    if (not params.no_collision) then
        projectile_placeholder.collision_box = {
            { -0.3, -1.1, },
            { 0.3, 1.1, }
        }
    end

    projectile_placeholder.animation = nil
    projectile_placeholder.shadow = nil
    projectile_placeholder.smoke = nil

    local target_effects = {}

    if (params.target_effects) then
        if (params.target_effects[1]) then
            for _, target_effect in ipairs(params.target_effects) do
                table.insert(target_effects, target_effect)
            end
        else
            target_effects = params.target_effects
        end

        projectile_placeholder.action.action_delivery.target_effects = target_effects
    elseif (params.stream_action) then
        projectile_placeholder.action = params.stream_action
    elseif (params.beam_action) then
        projectile_placeholder.action = params.beam_action
    end

    if (params.magazine_size) then
        projectile_placeholder.action.action_delivery.repeat_count = params.magazine_size
    end

    return projectile_placeholder
end