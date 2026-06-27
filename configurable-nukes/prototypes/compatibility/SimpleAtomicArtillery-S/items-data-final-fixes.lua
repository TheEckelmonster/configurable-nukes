local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local create_custom_tooltip_quality_effects = require("prototypes.items.custom-tooltips-quality-effects")

local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local quality_active = mods and mods["quality"]

-- if (saa_s_active and quality_active) then
--     --[[ Custom Tooltips to show how quality scales the effects ]]
--     --[[ atomic-artillery-shell ]]
--     local saa_s_atomic_artillery_shell_ammo_item = data.raw["ammo"]["atomic-artillery-shell"]
--     local custom_tooltip_fields = create_custom_tooltip_quality_effects({
--         type = "artillery-projectile",
--         entity_name = "atomic-artillery-projectile-normal",
--         name = "atomic-artillery-projectile",
--     })

--     saa_s_atomic_artillery_shell_ammo_item.custom_tooltip_fields = custom_tooltip_fields
-- end