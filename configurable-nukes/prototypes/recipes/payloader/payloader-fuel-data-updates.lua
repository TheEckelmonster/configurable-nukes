
local recipe = data.raw["recipe"]["payloader-fuel"]

if (recipe) then
    recipe.icon = nil
    recipe.icons =
    {
        {
            icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
            icon_size = 64,
            shift = { -12, -12, },
            draw_background = true,
        },
        {
            icon = "__base__/graphics/icons/fluid/barreling/barrel-side-mask.png",
            icon_size = 64,
            shift = { -12, -12, },
            tint = {
                a = 0.75,
                b = 0,
                g = 0.33,
                r = 0.57
            },
        },
        {
            icon = "__base__/graphics/icons/fluid/barreling/barrel-hoop-top-mask.png",
            icon_size = 64,
            shift = { -12, -12, },
            tint = {
                a = 0.75,
                b = 0.07,
                g = 0.73,
                r = 1
            },
        },
        {
            icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
            icon_size = 64,
            shift = { 6, 6 },
            draw_background = true,
        },
        {
            icon = "__configurable-nukes__/graphics/technology/object-to-object-arrow.png",
            icon_size = 256,
            shift = { -2, -2 },
            scale = (1 / 5),
            floating = true,
        },
    }
end