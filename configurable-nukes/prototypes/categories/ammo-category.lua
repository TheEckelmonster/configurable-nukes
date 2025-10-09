local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

-- NUCLEAR_AMMO_CATEGORY
local get_nuclear_ammo_category = function ()
    local setting = false

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name].value
    end

    return setting
end

data:extend({
    {
        type = "ammo-category",
        name = "nuclear",
        icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
        subgroup = "ammo-category",
        hidden = not get_nuclear_ammo_category(),
        hidden_in_factoriopedia = not get_nuclear_ammo_category(),
    },
})

data:extend({
    {
        type = "ammo-category",
        name = "icbm-guidance",
        icons =
        {
            {
                icon = "__base__/graphics/icons/signal/signal-damage.png",
            },
            {
                icon = "__base__/graphics/icons/atomic-bomb.png",
                floating = true,
            },
        },
        hidden = true,
        hidden_in_factoriopedia = true,
        subgroup = "ammo-category"
    },
})

data:extend({
    {
        type = "ammo-category",
        name = "icbm-top-speed",
        hidden = true,
        hidden_in_factoriopedia = true,
        subgroup = "ammo-category"
    },
})