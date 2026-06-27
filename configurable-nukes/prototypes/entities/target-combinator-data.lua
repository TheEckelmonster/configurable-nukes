require("__base__.prototypes.entity.combinator-pictures")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local Util = require("__core__.lualib.util")

local function generate_target_combinator(combinator)
    combinator.sprites =
        make_4way_animation_from_spritesheet({
            layers =
            {
                {
                    scale = 0.5,
                    filename = "__configurable-nukes__/graphics/entity/combinator/target-combinator.png",
                    width = 114,
                    height = 102,
                    shift = Util.by_pixel(0, 5)
                },
                {
                    scale = 0.5,
                    filename = "__configurable-nukes__/graphics/entity/combinator/target-combinator-shadow.png",
                    width = 98,
                    height = 66,
                    shift = Util.by_pixel(8.5, 5.5),
                    draw_as_shadow = true
                }
            }
        })
    combinator.activity_led_sprites =
    {
        north = Util.draw_as_glow
            {
                scale = 0.5,
                filename = "__configurable-nukes__/graphics/entity/combinator/activity-leds/target-combinator-LED-N.png",
                width = 14,
                height = 12,
                shift = Util.by_pixel(9, -11.5)
            },
        east = Util.draw_as_glow
            {
                scale = 0.5,
                filename = "__configurable-nukes__/graphics/entity/combinator/activity-leds/target-combinator-LED-E.png",
                width = 14,
                height = 14,
                shift = Util.by_pixel(7.5, -0.5)
            },
        south = Util.draw_as_glow
            {
                scale = 0.5,
                filename = "__configurable-nukes__/graphics/entity/combinator/activity-leds/target-combinator-LED-S.png",
                width = 14,
                height = 16,
                shift = Util.by_pixel(-9, 2.5)
            },
        west = Util.draw_as_glow
            {
                scale = 0.5,
                filename = "__configurable-nukes__/graphics/entity/combinator/activity-leds/target-combinator-LED-W.png",
                width = 14,
                height = 16,
                shift = Util.by_pixel(-7, -15)
            }
    }
    combinator.circuit_wire_connection_points =
    {
        {
            shadow =
            {
                red = Util.by_pixel(7, -6),
                green = Util.by_pixel(23, -6)
            },
            wire =
            {
                red = Util.by_pixel(-8.5, -17.5),
                green = Util.by_pixel(7, -17.5)
            }
        },
        {
            shadow =
            {
                red = Util.by_pixel(32, -5),
                green = Util.by_pixel(32, 8)
            },
            wire =
            {
                red = Util.by_pixel(14.5, -16.5),
                green = Util.by_pixel(17.5, -3.5)
            }
        },
        {
            shadow =
            {
                red = Util.by_pixel(25, 20),
                green = Util.by_pixel(9, 20)
            },
            wire =
            {
                red = Util.by_pixel(9, 7.5),
                green = Util.by_pixel(-6.5, 7.5)
            }
        },
        {
            shadow =
            {
                red = Util.by_pixel(1, 11),
                green = Util.by_pixel(1, -2)
            },
            wire =
            {
                red = Util.by_pixel(-13.5, -0.5),
                green = Util.by_pixel(-16.5, -13.5)
            }
        }
    }
    return combinator
end

local corpse_icon_path = "__configurable-nukes__/graphics/entity/combinator/remnants/target-combinator-remnants.png"
local corpse_icon = { icon = corpse_icon_path, size = 64, scale = 1, }
local corpse_icons = { corpse_icon, }

--[[ payloader-corpse ]]
local target_combinator_corpse = Util.table.deepcopy(data.raw["corpse"]["constant-combinator-remnants"])
target_combinator_corpse.name = "target-combinator-remnants"
target_combinator_corpse.icons = corpse_icons

target_combinator_corpse.animation = make_rotated_animation_variations_from_sheet(1,
    {
        filename = "__configurable-nukes__/graphics/entity/combinator/remnants/target-combinator-remnants.png",
        line_length = 1,
        width = 118,
        height = 112,
        direction_count = 4,
        shift = Util.by_pixel(0, 0),
        scale = 0.5
    })

data:extend({ target_combinator_corpse, })

local target_combinator = generate_target_combinator(
{
    type = "constant-combinator",
    name = "target-combinator",
    icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.1, result = "target-combinator" },
    max_health = 120,
    corpse = "target-combinator-remnants",
    dying_explosion = "constant-combinator-explosion",
    collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
    selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    damaged_trigger_effect = hit_effects.entity(),
    fast_replaceable_group = "constant-combinator",
    open_sound = sounds.combinator_open,
    close_sound = sounds.combinator_close,
    icon_draw_specification = { scale = 0.7 },
    activity_led_light =
    {
        intensity = 0,
        size = 1,
        color = { r = 1.0, g = 1.0, b = 1.0 }
    },

    activity_led_light_offsets =
    {
        { 0.296875,  -0.40625 },
        { 0.25,      -0.03125 },
        { -0.296875, -0.078125 },
        { -0.21875,  -0.46875 }
    },

    circuit_wire_max_distance = combinator_circuit_wire_max_distance
})

data:extend({ target_combinator, })