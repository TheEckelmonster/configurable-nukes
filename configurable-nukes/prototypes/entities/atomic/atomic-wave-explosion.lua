--[[ atomic-wave-explosion ]]
return function (params)
    if (type(params) ~= "table") then return end

    local name = params.name

    local quality_name = params.quality_name
    local quality_level_multiplier = params.quality_level_multiplier

    local max_nuke_shockwave_movement_distance = params.max_nuke_shockwave_movement_distance
    local max_nuke_shockwave_movement_distance_deviation = params.max_nuke_shockwave_movement_distance_deviation

    return {
        {
            type = "projectile",
            name = name .. "-wave-spawns-nuke-shockwave-explosion" .. "-" .. quality_name,
            flags = {"not-on-map"},
            hidden = true,
            acceleration = 0,
            speed_modifier = { 1, 0.707 },
            action =
            {
                {
                    type = "direct",
                    action_delivery =
                    {
                        type = "instant",
                        target_effects =
                        {
                            {
                                type = "create-explosion",
                                entity_name = "atomic-nuke-shockwave",
                                max_movement_distance = 1 + max_nuke_shockwave_movement_distance * quality_level_multiplier,
                                max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * quality_level_multiplier,
                                inherit_movement_distance_from_projectile = true,
                                cycle_while_moving = true
                            },
                        },
                    },
                },
            },
            animation = nil,
            shadow = nil
        },
        {
            type = "projectile",
            name = name .. "-wave-spawns-fire-smoke-explosion" .. "-" .. quality_name,
            flags = {"not-on-map"},
            hidden = true,
            acceleration = 0,
            speed_modifier = { 1, 0.707 },
            action =
            {
                {
                    type = "direct",
                    action_delivery =
                    {
                        type = "instant",
                        target_effects =
                        {
                            {
                                type = "create-explosion",
                                entity_name = "atomic-fire-smoke",
                                max_movement_distance = 1 + max_nuke_shockwave_movement_distance * quality_level_multiplier,
                                max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * quality_level_multiplier,
                                inherit_movement_distance_from_projectile = true,
                                cycle_while_moving = true
                            },
                        },
                    },
                },
            },
            animation = nil,
            shadow = nil
        },
    }
end