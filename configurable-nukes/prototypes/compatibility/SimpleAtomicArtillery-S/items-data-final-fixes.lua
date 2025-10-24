local Data_Utils = require("data-utils")

local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local quality_active = mods and mods["quality"]

if (saa_s_active and quality_active) then
    --[[ Custom Tooltips to show how quality scales the effects ]]
    --[[ atomic-artillery-shell ]]
    local saa_s_atomic_artillery_shell_ammo_item = data.raw["ammo"]["atomic-artillery-shell"]
    local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
        type = "artillery-projectile",
        name = "atomic-artillery-projectile",
    })

    saa_s_atomic_artillery_shell_ammo_item.custom_tooltip_fields = custom_tooltip_fields
end