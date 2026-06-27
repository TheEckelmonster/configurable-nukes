return function (name, duration, color)
    name = name or "cn-galvanic-cloud-visual-dummy"
    duration = duration or 0
    color = color or { r = 0.1647, g = 0.2666, b = 0.78039, a = 0.6 } -- #2642c8

    return {
        type = "smoke-with-trigger",
        name = name,
        flags = { "not-on-map" },
        hidden = true,
        show_when_smoke_off = true,
        particle_count = 24,
        particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
        particle_distance_scale_factor = 0.5,
        particle_scale_factor = { 1, 0.707 },
        particle_duration_variation = 60 * 3,
        wave_speed = { 0.5 / 80, 0.5 / 60 },
        wave_distance = { 1, 0.5 },
        spread_duration_variation = 300 - duration,

        render_layer = "object",

        affected_by_wind = false,
        cyclic = true,
        duration = 60 * duration + 3 * 60,
        fade_away_duration = 2 * 60,
        spread_duration = (300 - 6) / 2,
        color = color,

        animation =
        {
            width = 152,
            height = 120,
            line_length = 5,
            frame_count = 60,
            shift = { -0.53125, -0.4375 },
            priority = "high",
            animation_speed = 0.25,
            filename = "__base__/graphics/entity/smoke/smoke.png",
            flags = { "smoke" }
        },
        working_sound =
        {
            sound = { filename = "__base__/sound/fight/poison-cloud.ogg", volume = 0.5, audible_distance_modifier = 0.8 },
            max_sounds_per_prototype = 1,
            match_volume_to_activity = true
        }
    }
end