data:extend({
    {
        type = "shortcut",
        name = "give-ICBM-remote",
        order = "f[spidertron-remote]",
        action = "spawn-item",
        localised_name = { "shortcut.create-ICBM-remote" },
        localised_description = { "shortcut-description.create-ICBM-remote" },
        associated_control_input = "give-ICBM-remote",
        technology_to_unlock = "icbms",
        unavailable_until_unlocked = true,
        item_to_spawn = "ICBM-remote",
        icons =
        {
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-rocket.png",
                icon_size = 56,
                floating = true,
            },
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-crosshair.png",
                icon_size = 56,
            },
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-tip.png",
                icon_size = 56,
            },
        },
        small_icons =
        {
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-rocket.png",
                icon_size = 24,
                floating = true,
            },
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-crosshair.png",
                icon_size = 24,
            },
            {
                icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-tip.png",
                icon_size = 24,
            },
        },
    },
})
