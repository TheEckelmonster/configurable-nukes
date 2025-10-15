local Data_Utils = require("data-utils")

local quality_active = mods and mods["quality"]

if (quality_active) then
    local atomic_bomb_item = data.raw["ammo"]["atomic-bomb"]

    local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "atomic-rocket",
    })

    atomic_bomb_item.custom_tooltip_fields = custom_tooltip_fields
    data:extend({atomic_bomb_item})

    local atomic_warhead_item = data.raw["ammo"]["atomic-warhead"]

    custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "atomic-warhead",
    })

    atomic_warhead_item.custom_tooltip_fields = custom_tooltip_fields
    data:extend({atomic_warhead_item})
end