local mods = mods

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true
local true_nukes_contiued = mods and mods["True-Nukes_Continued"] and true

---

require("prototypes.custom-events.custom-events")
require("prototypes.sprites")
require("prototypes.style")

require("prototypes.categories.ammo-category")
if (sa_active) then
    require("prototypes.categories.damage-type")
end
require("prototypes.categories.item-group")
require("prototypes.categories.recipe-category")

require("prototypes.custom-input.custom-input")
require("prototypes.shortcuts")

---

-- require("prototypes.entities.cargo-pod")
require("prototypes.entities.payloader-data")
require("prototypes.entities.payloader-rocket-data")
require("prototypes.entities.payloader-dummy-rocket-data")
require("prototypes.entities.rocket-silo.rocket-silo-data")
require("prototypes.entities.rocket-silo-rocket")

require("prototypes.items.cn-payload-vehicle-data")
require("prototypes.items.items-data")
require("prototypes.items.jericho-data")
require("prototypes.items.payloader-data")
require("prototypes.items.rod-from-god-data")
if (sa_active) then
    require("prototypes.items.tesla-rocket-data")
end

require("prototypes.recipes.cn-payload-vehicle-data")
require("prototypes.recipes.jericho-data")
require("prototypes.recipes.payloader.payloader-data")
require("prototypes.recipes.payloader.payloader-load-data")
require("prototypes.recipes.payloader.payloader-unload-data")

if (not se_active) then
    require("prototypes.recipes.rocket-control-unit.rocket-control-unit")
    require("prototypes.recipes.rocket-control-unit.rocket-control-unit-intermediate")
    require("prototypes.recipes.rocket-control-unit.rocket-control-unit-advanced")
end

require("prototypes.recipes.rod-from-god-data")
if (sa_active) then
    require("prototypes.recipes.tesla-rocket-data")
end

require("prototypes.technologies.technology-data")

require("prototypes.technologies.nuclear-weapons")
require("prototypes.technologies.rocket-control-unit")
require("prototypes.technologies.icbms")
if (not se_active) then
    -- require("prototypes.technologies.icbms")
    -- require("prototypes.technologies.atomic-warhead")
    -- require("prototypes.technologies.guidance-systems")
    -- require("prototypes.technologies.mirvs-data")

    if (sa_active) then
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-basic")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-intermediate")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-advanced")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond")
        require("prototypes.recipes.ballistic-rocket-parts.ballistic-rocket-part-beyond-2")
        require("prototypes.recipes.ipbm-rocket-silo")
        -- require("prototypes.technologies.ipbms")
        require("prototypes.technologies.rocket-part-productivity")
    end

    require("prototypes.technologies.ballistic-rocketry-and-logistics")

    require("prototypes.technologies.ipbms")

    require("prototypes.technologies.atomic-warhead")

    require("prototypes.technologies.jericho-data")
    require("prototypes.technologies.rod-from-god-data")
    if (sa_active) then
        require("prototypes.technologies.tesla-rocket-data")
    end
end

require("prototypes.technologies.payloader")

if (true_nukes_contiued) then
    local __stage = __STAGE
    __STAGE = "data"
    require("prototypes.entities.atomic.atomic-bomb")
    __STAGE = __stage
end