local list_dot = {
    type = "sprite",
    name = "cn-list-dot",
    layers =
    {
        {
            filename = "__configurable-nukes__/graphics/gui/list-dot.png",
            size = 128,
            tint = { 255, 230, 192 }
        },
    }
}

local damage_icon = {
    type = "sprite",
    name = "cn-damage-icon",
    layers =
    {
        {
            filename = "__configurable-nukes__/graphics/gui/effect.png",
            size = 64,
            tint = { 255, 200, 0 },
        },
    }
}

local close_icon = {
    type = "sprite",
    name = "cn-close-icon",
    layers =
    {
        {
            filename = "__base__/graphics/icons/signal/signal-deny.png",
            size = 64,
        },
    }
}

data:extend({
    list_dot,
    damage_icon,
    close_icon,
})