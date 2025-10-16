local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (k2so_active) then
    require("prototypes.compatibility.Krastorio2-spaced-out.items-data-updates")
    require("prototypes.compatibility.Krastorio2-spaced-out.entities.kr-nuclear-artillery-shell-data-updates")
    require("prototypes.compatibility.Krastorio2-spaced-out.entities.kr-nuclear-turret-rocket-projectile-data-updates")
end

require("prototypes.entities.atomic-bomb")
require("prototypes.entities.atomic-warhead")

require("prototypes.recipes.atomic-bomb")
require("prototypes.recipes.atomic-warhead")