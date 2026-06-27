local sounds = require("__base__.prototypes.entity.sounds")

return function (name, duration, entity_name, aoe_multiplier, cluster_multiplier)
    name = name or "cn-galvanic-cloud"
    duration = duration or 0
    entity_name = entity_name or "cn-galvanic-cloud-visual-dummy"

    aoe_multiplier = aoe_multiplier or 0.42
    cluster_multiplier = cluster_multiplier or 0.25

    return {
        name = name,
        type = "smoke-with-trigger",
        flags = { "not-on-map" },
        hidden = true,
        show_when_smoke_off = true,
        particle_count = 16,
        particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
        particle_distance_scale_factor = 0.5,
        particle_scale_factor = { 1, 0.707 },
        wave_speed = { 1 / 80, 1 / 60 },
        wave_distance = { 0.3, 0.2 },
        spread_duration_variation = duration,
        particle_duration_variation = 60 * 3,
        render_layer = "object",

        affected_by_wind = false,
        cyclic = true,
        duration = 60 * duration,
        fade_away_duration = 2 * 60,
        spread_duration = 6,
        -- color = { 0.239, 0.875, 0.992, 0.690 }, -- #3ddffdb0,

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

        created_effect =
        {
            {
                type = "cluster",
                force = "not-same",
                cluster_count = 2 + (cluster_multiplier + 8 / 1) * cluster_multiplier,
                distance = (4 / 1) * aoe_multiplier,
                distance_deviation = (5 / 1) * aoe_multiplier,
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        {
                            type = "create-smoke",
                            show_in_tooltip = false,
                            entity_name = entity_name,
                            initial_height = 0
                        },
                        {
                            type = "play-sound",
                            sound = sounds.poison_capsule_explosion
                        }
                    }
                }
            },
            {
                type = "cluster",
                force = "not-same",
                cluster_count = 2 + (cluster_multiplier + 9 / 1) * cluster_multiplier,
                distance = ((9 * 1.1) / 1) * aoe_multiplier,
                distance_deviation = (3 / 1) * aoe_multiplier,
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        {
                            type = "create-smoke",
                            show_in_tooltip = false,
                            entity_name = entity_name,
                            initial_height = 0
                        },
                    },
                },
            },
        },
    }
end