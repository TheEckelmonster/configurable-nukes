local mods = mods
local script = script

local Util = require("__core__.lualib.util")

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local heat_shielding = { type = "item", name = "heat-shielding", amount = 20, }
local liquid_rocket_fuel = { type = "fluid", name = "liquid-rocket-fuel", amount = 250, }

if (se_active) then
    heat_shielding.name = "se-" .. heat_shielding.name
    liquid_rocket_fuel.name = "se-" .. liquid_rocket_fuel.name
else
    if (cn_materials_active)  then
        heat_shielding.name = "cn-" .. heat_shielding.name
    else
        heat_shielding = nil
    end
    if (cn_propulsion_active) then
        liquid_rocket_fuel.name = "cn-" .. liquid_rocket_fuel.name
    else
        liquid_rocket_fuel = nil
    end
end

local recipes = {
    {
        setting_name = "PAYLOAD_VEHICLE",
        name = "payload-vehicle",
        energy_required = 30,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item", name = "rocket-control-unit",   amount = 5  },
            { type = "item", name = "low-density-structure", amount = 15 },
            { type = "item", name = "rocket-fuel",           amount = 10 },
            { type = "item", name = "accumulator",  amount = 10 },
            { type = "item", name = "steel-chest",  amount = 5  } ,
            { type = "item", name = "storage-tank", amount = 2  },
        },
        results = {
            { type = "item", name = "cn-payload-vehicle", amount = 1, }
        },
    },
    {
        setting_name = "PAYLOAD_VEHICLE_EFFICIENT",
        name = "payload-vehicle-efficient",
        energy_required = 30,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item", name = "rocket-control-unit",   amount = 5 },
            { type = "item", name = "low-density-structure", amount = 8 },
            { type = "item", name = "rocket-fuel",           amount = 8 },
            { type = "item", name = "carbon-fiber",          amount = 8 },
            { type = "item", name = "accumulator",  amount = 10 },
            { type = "item", name = "steel-chest",  amount = 5  },
            { type = "item", name = "storage-tank", amount = 2  },
        },
        results = {
            { type = "item", name = "cn-payload-vehicle", amount = 1, }
        },
    },
}

if (heat_shielding) then
    table.insert(recipes[1].ingredients, heat_shielding)
    table.insert(recipes[2].ingredients, (function()
        local _heat_shielding = Util.table.deepcopy(heat_shielding)
        _heat_shielding.amount = 12
        return _heat_shielding
    end)())
end
if (liquid_rocket_fuel) then
    table.insert(recipes[1].ingredients, liquid_rocket_fuel)
    table.insert(recipes[2].ingredients, (function()
        local _liquid_rocket_fuel = Util.table.deepcopy(liquid_rocket_fuel)
        _liquid_rocket_fuel.amount = 200
        return _liquid_rocket_fuel
    end)())
end

local settings = {}
for i = 1, #recipes, 1 do
    --[[ heat-shielding ]]
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_CRAFTING_TIME",
        type = "double-setting",
        name = prefix .. recipes[i].name .. "-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_RECIPE",
        name = prefix .. recipes[i].name .. "-recipe",
        setting_type = "startup",
        order = "",
        ingredients = recipes[i].ingredients,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    }
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_RESULTS",
        type = "string-setting",
        name = prefix .. recipes[i].name .. "-results",
        setting_type = "startup",
        order = "",
        results = recipes[i].results,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    }
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_CRAFTING_MACHINE",
        type = "string-setting",
        name = prefix .. recipes[i].name .. "-crafting-machine",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].crafting_machine or "crafting-with-fluid",
        allowed_values =
        {
            "crafting",
            "advanced-crafting",
            "smelting",
            "chemistry",
            "crafting-with-fluid",
            "oil-processing",
            "rocket-building",
            "centrifuging",
            "basic-crafting",
        },
    }
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_ADDITIONAL_CRAFTING_MACHINES",
        type = "string-setting",
        name = prefix .. recipes[i].name .. "-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].additional_crafting_machines and recipes[i].additional_crafting_machines[1] or "",
        allow_blank = true,
        auto_trim = true,
    }
end

return settings