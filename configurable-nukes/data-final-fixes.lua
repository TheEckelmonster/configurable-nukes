local __debug = DEBUG
DEBUG = false

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

require("prototypes.recipes.payloader-data-final-fixes")

if (k2so_active) then
    require("prototypes.compatibility.Krastorio2-spaced-out.ballistic-rocket-parts-data-final-fixes")
    require("prototypes.compatibility.Krastorio2-spaced-out.items-data-final-fixes")
end
if (saa_s_active) then
    require("prototypes.compatibility.SimpleAtomicArtillery-S.items-data-final-fixes")
end

require("prototypes.mod-data.space-data")

if (se_active) then
    require("prototypes.entities.rocket-silo.rocket-silo-data-final-fixes")
    require("prototypes.compatibility.space-exploration.collision-layers.ipbm-silo")
    require("prototypes.compatibility.space-exploration.collision-layers.payloader")
    require("prototypes.technologies.icbms")
    require("prototypes.technologies.atomic-warhead")
    require("prototypes.technologies.guidance-systems")

    require("prototypes.items.rod-from-god-data")
    require("prototypes.recipes.rod-from-god-data")
    require("prototypes.entities.rod-from-god-data")
    require("prototypes.technologies.rod-from-god-data")

    require("prototypes.items.jericho-data")
    require("prototypes.recipes.jericho-data")
    require("prototypes.entities.jericho-data")
    require("prototypes.technologies.jericho-data")

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

--[[ Enable lightning generation on all planets if space-age is present ]]
if (sa_active) then
    require("prototypes.planets.planet-data")
end

require("prototypes.mod-data.projectile-placeholder-data")
require("prototypes.items.cn-payload-vehicle-data-final-fixes")

---

--[[ Fix/organize categorization ]]
if (sa_active or se_active) then
    if (se_active) then
        local payloader = data.raw.recipe.payloader
        if (payloader) then
            payloader.subgroup = "assembling"
            payloader.order = "z-a-space-assembling-machine[payloader]"
        end

        local payload_vehicle = data.raw["item-with-inventory"]["cn-payload-vehicle"]
        if (payload_vehicle) then
            payload_vehicle.subgroup = "inter-ballistic-missile"
        end
    end

    local payload_vehicle = data.raw["item-with-inventory"]["cn-payload-vehicle"]
    if (payload_vehicle) then
        payload_vehicle.subgroup = "inter-ballistic-missile"
    end
end

---

if (DEBUG) then
    local counts = {}
    local category = {}
    local subgroup = {}
    local order = {}

    for key, value in pairs(data.raw) do
        for k, v in pairs(value) do
            if (v.category) then
                if (not category[v.category]) then
                    if (not counts[category]) then counts[category] = { count = 0, recipes = {}, } end
                    counts[category].count = counts[category].count + 1
                    category[v.category] = counts[category].count
                    table.insert(counts[category].recipes, v)
                else
                    counts[category].count = counts[category].count + 1
                    table.insert(counts[category].recipes, v)
                end
            end
            if (v.subgroup) then
                if (not subgroup[v.subgroup]) then
                    if (not counts[subgroup]) then counts[subgroup] = { count = 0, recipes = {}, } end
                    counts[subgroup].count = counts[subgroup].count + 1
                    subgroup[v.subgroup] = counts[subgroup].count
                    table.insert(counts[subgroup].recipes, v)
                else
                    counts[subgroup].count = counts[subgroup].count + 1
                    table.insert(counts[subgroup].recipes, v)
                end
            end
            if (v.order) then
                if (not order[v.order]) then
                    if (not counts[order]) then counts[order] = { count = 0, recipes = {}, } end
                    counts[order].count = counts[order].count + 1
                    order[v.order] = counts[order].count
                    table.insert(counts[order].recipes, v)
                else
                    counts[order].count = counts[order].count + 1
                    table.insert(counts[order].recipes, v)
                end
            end
        end
    end

    local item_group = {}

    for k, v in pairs(data.raw["item-group"]) do
        if (not item_group[v.name]) then
            if (not counts[item_group]) then counts[item_group] = { type = "item-group", count = 0, item_group = {}, subgroups = {} } end
        end
        counts[item_group].count = counts[item_group].count + 1
        item_group[v.name] = counts[item_group].count
        table.insert(counts[item_group].item_group, v)
    end

    for k, v in pairs(data.raw["item-subgroup"]) do
        if (not counts[v.group]) then counts[v.group] = { type = "item-subgroup", count = 0, item_group = {}, subgroups = {}, } end
        if (not counts[v.group].name) then counts[v.group].name = v.group end
        counts[v.group].count = counts[v.group].count + 1
        item_group[v.group] = counts[v.group].count
        table.insert(counts[v.group].subgroups, v.name)
    end

    for k, v in pairs(counts) do
        if (type(v.item_group) ~= "table" or not next(v.item_group)) then v.item_group = nil end
        if (type(v.subgroups) ~= "table" or not next(v.subgroups)) then v.subgroups = nil end
    end

    local _subgroups = {}

    for k, v in pairs(counts) do
        if (v.type == "item-subgroup" and v.name) then _subgroups[v.name] = v end
    end

    if (DEBUG) then log(serpent.block(_subgroups)) end
    if (DEBUG) then log(serpent.block(order)) end
    if (DEBUG) then log(serpent.block(item_group)) end
end

DEBUG = __debug