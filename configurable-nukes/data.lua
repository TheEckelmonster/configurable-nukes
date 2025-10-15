local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

require("prototypes.sprites")

require("prototypes.categories.ammo-category")
-- require("prototypes.entities.cargo-pod")
-- require("prototypes.custom-input.custom-input")
require("prototypes.entities.rocket-silo.rocket-silo-data")
require("prototypes.entities.rocket-silo-rocket")
require("prototypes.items.items-data")
require("prototypes.recipes.rocket-control-unit")

if (sa_active or se_active) then
    require("prototypes.recipes.advanced-rocket-control-unit")
end
require("prototypes.shortcuts")
require("prototypes.technologies.rocket-control-unit")
require("prototypes.technologies.nuclear-weapons")
if (not se_active) then
    require("prototypes.technologies.icbms")
    require("prototypes.technologies.atomic-warhead")
    require("prototypes.technologies.guidance-systems")

    if (sa_active) then
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-basic")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-intermediate")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-advanced")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond-2")
        require("prototypes.recipes.ipbm-rocket-silo")
        require("prototypes.technologies.ipbms")
        require("prototypes.technologies.rocket-part-productivity")
    end
end