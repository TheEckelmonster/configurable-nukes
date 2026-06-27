local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local payloader_rocket = Util.table.deepcopy(data.raw["projectile"]["rocket"])
payloader_rocket.name = "payloader-rocket"

table.insert(payloader_rocket.action.action_delivery.target_effects, { type = "script", effect_id = "payload-delivered",  })

if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.USE_WHOLE_ROCKET_SPRITE.name, })) then
    local smoke_scale = (1 / 0.975)
    local chunk_scale = 1
    local function create_rocket_smoke(params)
        params = params or {}

        return
        {
            filename = "__base__/graphics/entity/rocket-silo/12-rocket-smoke.png",
            frame_count = 8,
            height = 286,
            line_length = 8,
            lines_per_file = 3,
            priority = "medium",
            scale = 0.975,
            shift = params.shift,
            tint = params.tint,
            width = 80
        }
    end

    payloader_rocket.animation.layers = {
        {
            filename = "__configurable-nukes__/graphics/entity/rocket-silo/rocket-static-pod.png",
            flags = { "no-crop", },
            -- dice_y = 4,
            frame_count = 1,
            priority = "high",
            repeat_count = 8,
            line_length = 1,
            height = 752,
            width = 308,
            scale = 0.5,
            shift = util.by_pixel( -4.0, 20.0),
        },
        {
            filename = "__configurable-nukes__/graphics/entity/rocket-silo/rocket-jet.png",
            flags = { "no-crop", },
            frame_count = 1,
            priority = "high",
            repeat_count = 8,
            line_length = 4,
            width = 290,
            height = 288,
            scale = 0.5,
            shift = util.by_pixel( 0.0, -191.5),
            draw_as_glow = true,
        },
        {
            filename = "__configurable-nukes__/graphics/entity/rocket-silo/rocket-static-emission.png",
            flags = { "no-crop", },
            frame_count = 1,
            priority = "high",
            repeat_count = 8,
            line_length = 1,
            height = 752,
            width = 308,
            scale = 0.5,
            shift = util.by_pixel( 4.0, 20.0),
            draw_as_glow = true,
        },
        create_rocket_smoke({
            shift = { -2.1875 / smoke_scale, -6.1875 / chunk_scale, },
            tint = { 0.8, 0.8, 1, 0.7 },
        }),
        create_rocket_smoke({
            shift = { 1.90625 / smoke_scale, -6.25 / chunk_scale, },
            tint = { 0.8, 0.8, 1, 0.7 },
        }),
        create_rocket_smoke({
            shift = { -2.09375 / smoke_scale, -7.03125 / chunk_scale, },
            tint = { 0.8, 0.8, 1, 0.8 },
        }),
        create_rocket_smoke({
            shift = { 0.5 / smoke_scale, -8.0625 / chunk_scale, },
            tint = { 0.8, 0.8, 1, 0.8 },
        }),
        create_rocket_smoke({
            shift = { 1.46875 / smoke_scale, -7.65625 / chunk_scale, },
            tint = { 0.8, 0.8, 1, 0.8 },
        }),
    }

    -- payloader_rocket.shadow = {
    --     draw_as_shadow = true,
    --     filename = "__base__/graphics/entity/rocket-silo/rocket-static-pod-shadow.png",
    --     height = 214,
    --     line_length = 1,
    --     priority = "medium",
    --     scale = 0.5,
    --     shift = {
    --         2.21875,
    --         0.734375
    --     },
    --     width = 738
    -- }

    payloader_rocket.icon = "__configurable-nukes__/graphics/icons/rocket-static-flying.png"
else
    payloader_rocket.icon = "__base__/graphics/icons/ammo-category/rocket.png"
end
payloader_rocket.icon_size = 64

data:extend({ payloader_rocket, })