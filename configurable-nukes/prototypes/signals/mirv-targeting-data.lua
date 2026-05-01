local signals = {
    {
        type = "virtual-signal",
        name = "mirv-targeting-signal",
        icons = {
            {
                icon = "__configurable-nukes__/graphics/mirv-targeting-signal.png",
                icon_size = 258,
                scale = 1 / 4,
            },
        },
        hidden = true,
        hidden_in_factoriopedia = true,
    },
    {
        type = "virtual-signal",
        name = "mirv-targeting-signal-locked",
        icons = {
            {
                icon = "__configurable-nukes__/graphics/mirv-targeting-signal-locked.png",
                icon_size = 258,
                scale = 1 / 4,
            },
        },
        hidden = true,
        hidden_in_factoriopedia = true,
    },
}

data:extend(signals)