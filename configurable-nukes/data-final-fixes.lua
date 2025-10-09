local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

require("prototypes.mod-data")

if (se_active) then
    require("prototypes.entities.data-final-fixes.rocket-silo")
    require("prototypes.collision-layers.ipbm-silo")
    require("prototypes.technologies.icbms")
    require("prototypes.technologies.atomic-warhead")
    require("prototypes.technologies.guidance-systems")
    if (not sa_active) then
        require("prototypes.recipes.ipbm-rocket-silo")
        require("prototypes.technologies.ipbms")
    else
        --[[ TODO: Handle this situation
            -> Don't think this is currently possible without manual changes
        ]]
    end
end