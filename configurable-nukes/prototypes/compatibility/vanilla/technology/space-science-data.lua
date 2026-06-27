local mods = mods
local space_science_pack = data.raw["tool"]["space-science-pack"]

if (type(space_science_pack) == "table") then
    space_science_pack.send_to_orbit_mode = "automated"
    space_science_pack.rocket_launch_products = space_science_pack.rocket_launch_products or {}
    space_science_pack.rocket_launch_products[#space_science_pack.rocket_launch_products+1] = { type = "item", name = "raw-fish", amount = 1, }
end

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (sa_active or se_active) then return end

data:extend({
    {
        type = "recipe",
        name = "steam-condensation",
        -- icon = "__configurable-nukes__/graphics/icons/fluid/steam-condensation",
        -- icon_size = 64,
        icons = {
            {
                icon = "__base__/graphics/icons/fluid/steam.png",
                icon_size = 64,
                shift = { 0, -8,},
            },
            {
                icon = "__base__/graphics/icons/fluid/water.png",
                icon_size = 64,
                shift = { 0, 8,},
            },
            {
                icon = "__base__/graphics/icons/fluid/steam.png",
                icon_size = 64,
                shift = { 0, -8,},
                tint = { r = 0, g = 0, b = 0, a = 0.5 },
            },
            {
                icon = "__base__/graphics/icons/fluid/water.png",
                icon_size = 64,
                shift = { 0, 8,},
                tint = { r = 0, g = 0, b = 0, a = 0.5 },
            },
            {
                icon = "__base__/graphics/icons/fluid/steam.png",
                icon_size = 64,
                shift = { 0, -8,},
                tint = { r = 0, g = 0, b = 0, a = 0.25 },
            },
        },
        category = "chemistry",
        subgroup = "fluid-recipes",
        order = "d[other-chemistry]-b[steam-condensation]",
        auto_recycle = false,
        enabled = false,
        ingredients =
        {
            { type = "fluid", name = "steam", amount = 1000, },
        },
        energy_required = 1,
        results =
        {
            { type = "fluid", name = "water", amount = 90, },
        },
        always_show_products = true,
        show_amount_in_title = false,
        allow_decomposition = false,
        allow_quality = false,
        crafting_machine_tint =
        {
            primary    = { r = 0.409, g = 0.694, b = 0.895, a = 1.000 }, -- #68b0e4ff
            secondary  = { r = 1.000, g = 1.000, b = 1.000, a = 1.000 }, -- #fffefeff
            tertiary   = { r = 0.540, g = 0.520, b = 0.520, a = 1.000 }, -- #898484ff
            quaternary = { r = 0.750, g = 0.750, b = 0.750, a = 1.000 }, -- #bfbfbfff
        }
    }
})