local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true
local eaff_active = mods and mods["enable-all-feature-flags"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true
local true_nukes_contiued = mods and mods["True-Nukes_Continued"] and true

require("prototypes.custom-events.custom-events")
require("prototypes.sprites")
require("prototypes.style")

require("prototypes.signals.mirv-targeting-data")

require("prototypes.entities.target-visualizer-data")

require("prototypes.categories.ammo-category")
-- require("prototypes.entities.cargo-pod")
require("prototypes.custom-input.custom-input")
require("prototypes.entities.rocket-silo.rocket-silo-data")
require("prototypes.entities.rocket-silo-rocket")
require("prototypes.items.items-data")
require("prototypes.recipes.rocket-control-unit.rocket-control-unit")
require("prototypes.recipes.rocket-control-unit.rocket-control-unit-intermediate")
require("prototypes.recipes.rocket-control-unit.rocket-control-unit-advanced")

require("prototypes.technologies.technology-data")

require("prototypes.items.cn-payload-vehicle-data")
require("prototypes.recipes.cn-payload-vehicle-data")

require("prototypes.categories.item-group")
require("prototypes.categories.recipe-category")
require("prototypes.recipes.payloader.payloader-data")
require("prototypes.recipes.payloader.payloader-load-data")
require("prototypes.recipes.payloader.payloader-unload-data")
-- require("prototypes.recipes.payloader.payloader-fuel-data")
-- require("prototypes.recipes.payloader.payloader-unfuel-data")
require("prototypes.items.payloader-data")
require("prototypes.entities.payloader-data")
require("prototypes.entities.payloader-rocket-data")
require("prototypes.entities.payloader-dummy-rocket-data")

require("prototypes.entities.target-combinator-data")
require("prototypes.items.target-combinator-data")
require("prototypes.recipes.target-combinator.target-combinator-data")
require("prototypes.recipes.target-combinator.target-combinator-program-data")
require("prototypes.recipes.target-combinator.target-combinator-reformat-acid-data")
require("prototypes.recipes.target-combinator.target-combinator-reformat-dirty-data")
require("prototypes.recipes.target-combinator.target-combinator-reformat-slow-data")

require("prototypes.mod-data.payloader-recipes-data")

-- if (sa_active or se_active) then
--     require("prototypes.recipes.advanced-rocket-control-unit")
-- end
require("prototypes.shortcuts")
require("prototypes.technologies.rocket-control-unit")
require("prototypes.technologies.nuclear-weapons")

if (not se_active) then
    require("prototypes.technologies.icbms")
end

if (sa_active) then
    require("prototypes.categories.damage-type")

    require("prototypes.items.tesla-rocket-data")

    require("prototypes.recipes.tesla-rocket-data")
end

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

    require("prototypes.technologies.atomic-warhead")

    require("prototypes.technologies.rocket-recoverability.rocket-recoverability-1")
    require("prototypes.technologies.rocket-recoverability.rocket-recoverability-2")
    require("prototypes.technologies.rocket-recoverability.rocket-recoverability-3")

    require("prototypes.items.jericho-data")
    require("prototypes.items.rod-from-god-data")

    require("prototypes.recipes.jericho-data")
    require("prototypes.recipes.rod-from-god-data")

    require("prototypes.technologies.jericho-data")
    require("prototypes.technologies.rod-from-god-data")
end

require("prototypes.technologies.payloader")

require("prototypes.technologies.mirvs-data")

if (sa_active) then
    if (not se_active) then
        require("prototypes.technologies.ipbms")
    end

    require("prototypes.technologies.tesla-rocket-data")
end

if (true_nukes_contiued) then
    -- if (not se_active) then
    --     require("prototypes.entities.rod-from-god-data")
    --     require("prototypes.entities.jericho-data")
    -- end

    local __stage = __STAGE
    __STAGE = "data"
    require("prototypes.entities.atomic.atomic-bomb")
    __STAGE = __stage
end

if (not sa_active and not se_active) then
    require("prototypes.compatibility.vanilla.technology.space-science-data")
end

if (eaff_active) then
    require("prototypes.compatibility.enable-all-feature-flags.raw-fish")
end