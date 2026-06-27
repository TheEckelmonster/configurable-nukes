local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true
local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local quality_active = mods and mods["quality"]
local quality_rockets_active = mods and mods["QualityRockets"] and true
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true
local StopgapNukes_active = mods and mods["StopgapNukes"] and true
local true_nukes_contiued = mods and mods["True-Nukes_Continued"] and true

if (quality_active) then
    require("prototypes.entities.rocket-silo.rocket-silo-data-updates")
end

if (quality_rockets_active) then
    require("prototypes.compatibility.QualityRockets.rocket-silos-updates")
end

if (k2so_active) then
    require("prototypes.compatibility.Krastorio2-spaced-out.items-data-updates")
    require("prototypes.compatibility.Krastorio2-spaced-out.entities.kr-nuclear-artillery-shell-data-updates")
    require("prototypes.compatibility.Krastorio2-spaced-out.entities.kr-nuclear-turret-rocket-projectile-data-updates")
end
if (saa_s_active) then
    require("prototypes.compatibility.SimpleAtomicArtillery-S.items-data-updates")
    require("prototypes.compatibility.SimpleAtomicArtillery-S.entities.atomic-artillery-shell-data-updates")
end

require("prototypes.entities.atomic.atomic-warhead")
-- if (not se_active) then
    require("prototypes.entities.rod-from-god-data")
    -- require("prototypes.entities.jericho.jericho-data")
    require("prototypes.entities.jericho.jericho-data-two")
-- end

if (sa_active or se_active) then
    require("prototypes.entities.rocket-silo.ipbm-silo-fluid-connections-data")
end

if (sa_active) then
    -- require("prototypes.entities.tesla-rocket.tesla-rocket-data")
    require("prototypes.entities.tesla-rocket.tesla-rocket-data-two")
    -- if (not cn_avionics_active) then
    --     require("prototypes.entities.galvanic-ammo.galvanic-sticker")
    --     require("prototypes.entities.galvanic-ammo.galvanic-grenade")
    --     require("prototypes.entities.galvanic-ammo.galvanic-land-mine")
    -- end
    require("prototypes.entities.tesla-rocket.tesla-rocket-data-three")
end

if (not true_nukes_contiued) then
    -- if (not se_active) then
    --     require("prototypes.entities.rod-from-god-data")
    --     require("prototypes.entities.jericho-data")
    -- end

    local __stage = __STAGE
    __STAGE = "data-updates"
    require("prototypes.entities.atomic.atomic-bomb")
    __STAGE = __stage
end

-- require("prototypes.entities.atomic.atomic-warhead")

if (not StopgapNukes_active) then
    require("prototypes.recipes.atomic-bomb")
end
require("prototypes.recipes.atomic-warhead")