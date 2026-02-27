local Util = require("__core__.lualib.util")

local payloader_dummy_rocket =
{
    type = "projectile",
    name = "payloader-dummy-rocket",
    flags = { "not-on-map" },
    hidden = true,
    acceleration = 0.01,
    turn_speed = 0.003,
    turning_speed_increases_exponentially_with_projectile_speed = true,
    collision_box =
    {
        { -0.21, -0.21, },
        {  0.21,  0.21, },
    },
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
                    entity_name = "explosion",
                    only_when_visible = true
                },
                {
                    type = "damage",
                    damage = { amount = 200, type = "explosion" }
                },
                {
                    type = "create-entity",
                    entity_name = "small-scorchmark-tintable",
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
                    radius = 1.5                   -- large radius for demostrative purposes
                }
            }
        }
    },
    -- --light = {intensity = 0.5, size = 4},
    -- animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({ 1, 0.8, 0.3 }),
    -- shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
    -- smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,

    -- icon = "__core__/graphics/empty.png",
}

payloader_dummy_rocket.icons = nil

payloader_dummy_rocket.animation = nil
payloader_dummy_rocket.shadow = nil
payloader_dummy_rocket.smoke = nil

payloader_dummy_rocket.hidden = true
payloader_dummy_rocket.enabled = false

data:extend({ payloader_dummy_rocket, })