local Data_Utils = require("data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

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
        -- icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
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
        -- hidden = not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }),
        -- hidden_in_factoriopedia = not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }),
        hidden = true,
        hidden_in_factoriopedia = true,
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