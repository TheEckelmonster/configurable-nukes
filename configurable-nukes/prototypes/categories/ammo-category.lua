Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local nuclear_artillery_research_bonus_visible =   Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AMMO_CATEGORY.name }) == "nuclear-artillery"
                                                or Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AMMO_CATEGORY.name }) == "nuclear-artillery"

local sa_active = mods and mods["space-age"] and true

data:extend({
    {
        type = "ammo-category",
        name = "nuclear",
        icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
        subgroup = "ammo-category",
        hidden = not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }),
        hidden_in_factoriopedia = not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }),
    },
    {
        type = "ammo-category",
        name = "nuclear-artillery",
        icons =
        {
            {
                icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
            },
            {
                icon = "__base__/graphics/icons/ammo-category/artillery-shell.png",
            },
        },
        subgroup = "ammo-category",
        hidden = not nuclear_artillery_research_bonus_visible,
        hidden_in_factoriopedia = not nuclear_artillery_research_bonus_visible,
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
        subgroup = "ammo-category",
    },
})

data:extend({
    {
        type = "ammo-category",
        name = "icbm-top-speed",
        hidden = true,
        hidden_in_factoriopedia = true,
        subgroup = "ammo-category",
    },
})

data:extend({
    {
        type = "ammo-category",
        name = "kinetic-weapon",
        hidden = true,
        hidden_in_factoriopedia = true,
        subgroup = "ammo-category",
    },
    {
        type = "ammo-category",
        name = "ballistic-missile-payload",
        hidden = true,
        hidden_in_factoriopedia = true,
        subgroup = "ammo-category",
    },
})

if (sa_active) then
    data:extend({
        {
            type = "ammo-category",
            name = "tesla-rocket",
            hidden = true,
            hidden_in_factoriopedia = true,
            subgroup = "ammo-category",
        },
    })
end