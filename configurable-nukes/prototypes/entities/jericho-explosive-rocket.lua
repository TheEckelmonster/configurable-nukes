return {
    type = "projectile",
    name = "cn-jericho-explosive-rocket",
    flags = { "not-on-map" },
    hidden = true,
    acceleration = 0.01,
    turn_speed = 0.003,
    turning_speed_increases_exponentially_with_projectile_speed = true,
    action =
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "create-entity",
                    entity_name = "big-explosion",
                    only_when_visible = true
                },
                {
                    type = "damage",
                    damage = { amount = 50, type = "explosion" }
                },
                {
                    type = "create-entity",
                    entity_name = "medium-scorchmark-tintable",
                    check_buildability = true
                },
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
                {
                    type = "destroy-decoratives",
                    from_render_layer = "decorative",
                    to_render_layer = "object",
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = false,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                    radius = 3.5                   -- large radius for demostrative purposes
                },
                {
                    type = "nested-result",
                    action =
                    {
                        type = "area",
                        radius = 6.5,
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = { amount = 100, type = "explosion" }
                                },
                                {
                                    type = "create-entity",
                                    entity_name = "explosion",
                                    only_when_visible = true
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({ 1, 0.2, 0.2 }),
    shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
    smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
}
