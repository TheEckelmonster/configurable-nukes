require("prototypes.categories.ammo-category")
if (mods and not mods["mushroom-cloud"]) then
    require("prototypes.entities.atomic-bomb")
    require("prototypes.entities.atomic-warhead")
end
if (mods and not mods["space-age"]) then
    require("prototypes.entities.rocket-silo")
end
require("prototypes.items")
require("prototypes.recipes.rocket-control-unit")
require("prototypes.shortcuts")
require("prototypes.technologies.icbms")
require("prototypes.technologies.rocket-control-unit")
require("prototypes.technologies.atomic-warhead")
require("prototypes.technologies.guidance-systems")
require("prototypes.technologies.nuclear-weapons")