local galvanic_sticker =
{
    type = "sticker",
    name = "cn-galvanic-sticker",
    hidden = true,
    animation =
    {
        filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",
        line_length = 5,
        width = 42,
        height = 48,
        frame_count = 50,
        animation_speed = 0.5,
        -- tint = { 1.000, 0.663, 0.000, 0.694 }, -- #ffa900b1
        tint = { 0.000, 0.663, 1.000, 0.694 },
        shift = util.by_pixel(2, -0.5),
        scale = 0.5
    },
    duration_in_ticks = 75 + 60 * 6,
    damage_interval = 10,
    damage_per_tick = {
        type = "electric",
        amount = 6,
    },
    ground_target = true,
    -- target_movement_modifier = 0.35
    target_movement_modifier_from = 0.7,
    target_movement_modifier_to = 0.2,
    -- target_movement_max_from = 0.9,
    -- target_movement_max_to = 0.35,
    vehicle_speed_modifier_from = 0.6,
    vehicle_speed_modifier_to = 0.1,
    -- vehicle_speed_max_from = 0.9,
    -- vehicle_speed_max_to = 0.45,
    vehicle_friction_modifier_from = 1.5,
    vehicle_friction_modifier_to = 2,
}

return galvanic_sticker