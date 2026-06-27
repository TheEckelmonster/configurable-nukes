local recipe = data.raw["recipe"]["payloader-unfuel"]

if (recipe) then
    recipe.icon = nil
    recipe.icons =
    {
        {
            icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
            icon_size = 64,
            shift = { -12, -12 },
            draw_background = true,
        },
        {
            icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
            icon_size = 64,
            shift = { 6, 6, },
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