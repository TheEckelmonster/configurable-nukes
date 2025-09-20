data:extend({
  {
    type = "shortcut",
    name = "give-ICBM-remote",
    order = "f[spidertron-remote]",
    action = "spawn-item",
    localised_name = { "shortcut.create-ICBM-remote" },
    associated_control_input = "give-ICBM-remote",
    technology_to_unlock = "icbms",
    unavailable_until_unlocked = true,
    item_to_spawn = "ICBM-remote",
    icons =
    {
        {
            icon = "__base__/graphics/icons/signal/signal-damage.png",
            icon_size = 56,
        },
        {
            icon = "__base__/graphics/icons/atomic-bomb.png",
            icon_size = 56,
            floating = true,
        },
    },
    small_icons =
    {
        {
            icon = "__base__/graphics/icons/signal/signal-damage.png",
            icon_size = 24,
        },
        {
            icon = "__base__/graphics/icons/atomic-bomb.png",
            icon_size = 24,
            floating = true,
        },
    },
  }
})
