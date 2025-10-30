local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local quality_active = mods and mods["quality"]

if (quality_active) then
    --[[ Custom tooltips ]]
    -- atomic-bomb
    local atomic_bomb_item = data.raw["ammo"]["atomic-bomb"]
    local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "atomic-rocket",
    })

    atomic_bomb_item.custom_tooltip_fields = custom_tooltip_fields

    -- atomic-warhead
    local atomic_warhead_item = data.raw["ammo"]["atomic-warhead"]
    custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "atomic-warhead",
    })

    atomic_warhead_item.custom_tooltip_fields = custom_tooltip_fields

    -- cn-rod-from-god
    local atomic_warhead_item = data.raw["ammo"]["cn-rod-from-god"]
    custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "cn-rod-from-god",
    })

    atomic_warhead_item.custom_tooltip_fields = custom_tooltip_fields
end