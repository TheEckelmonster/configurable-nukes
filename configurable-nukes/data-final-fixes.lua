local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (k2so_active) then
    require("prototypes.compatibility.Krastorio2-spaced-out.ballistic-rocket-parts-data-final-fixes")
    require("prototypes.compatibility.Krastorio2-spaced-out.items-data-final-fixes")
end
if (saa_s_active) then
    require("prototypes.compatibility.SimpleAtomicArtillery-S.items-data-final-fixes")
end

require("prototypes.mod-data")

if (se_active) then
    require("prototypes.entities.rocket-silo.rocket-silo-data-final-fixes")
    require("prototypes.collision-layers.ipbm-silo")
    require("prototypes.technologies.icbms")
    require("prototypes.technologies.atomic-warhead")
    require("prototypes.technologies.guidance-systems")
    if (not sa_active) then
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-basic")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-intermediate")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-advanced")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond-2")
        require("prototypes.recipes.ipbm-rocket-silo")
        require("prototypes.technologies.ipbms")
    else
        --[[ TODO: Handle this situation
            -> Don't think this is currently possible without manual changes
        ]]
    end
end

--[[ Create the custom tooltips for atomic-bombs and atomic-warheads to display quality effects ]]
require("prototypes.items.items-data-final-fixes")