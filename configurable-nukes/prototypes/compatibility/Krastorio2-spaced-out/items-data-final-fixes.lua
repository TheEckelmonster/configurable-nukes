local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local quality_active = mods and mods["quality"]

if (k2so_active and quality_active) then
    --[[ Custom Tooltips to show how quality scales the effects ]]
    --[[ kr-nuclear-turret-rocket ]]
    local kr_nuclear_turret_rocket_ammo_item = data.raw["ammo"]["kr-nuclear-turret-rocket"]
    local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "projectile",
        name = "kr-nuclear-turret-rocket-projectile",
    })

    kr_nuclear_turret_rocket_ammo_item.custom_tooltip_fields = custom_tooltip_fields

    --[[ kr-nuclear-artillery-shell ]]
    local kr_nuclear_artillery_shell_ammo_item = data.raw["ammo"]["kr-nuclear-artillery-shell"]
    local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "artillery-projectile",
        name = "kr-atomic-artillery-projectile",
    })

    kr_nuclear_artillery_shell_ammo_item.custom_tooltip_fields = custom_tooltip_fields
end