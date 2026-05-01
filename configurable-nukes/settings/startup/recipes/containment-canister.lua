local mods = mods
local script = script

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "CONTAINMENT_CANISTER",
        name = "containment-canister",
        energy_required = 5,
        emissions_multiplier = 1,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item",  name = "tungsten-plate",          amount = 2, },
            { type = "item",  name = "carbon-fiber",            amount = 2, },
            { type = "item",  name = "processing-unit",         amount = 1, },
            { type = "item",  name = "energy-shield-equipment", amount = 1, },
        },
        results = {
            { type = "item",  name = "cn-containment-canister", amount = 1, },
        },
        order = "c-c-1",
    },
}

if (cn_materials_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 2, })
end

local settings = {}

for i = 1, #recipes, 1 do
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_CRAFTING_TIME",
        type = "double-setting",
        name = prefix .. recipes[i].name .. "-crafting-time",
        setting_type = "startup",
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-c[crafting-time]"),
        default_value = recipes[i].energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_RECIPE",
        name = prefix .. recipes[i].name .. "-recipe",
        setting_type = "startup",
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-e[recipe]"),
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
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-g[results]"),
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
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-i[crafting-machine]"),
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
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-k[additional-crafting-machines]"),
        default_value = recipes[i].additional_crafting_machines and recipes[i].additional_crafting_machines[1] or "",
        allow_blank = true,
        auto_trim = true,
    }
    settings[#settings+1] = {
        type = "double-setting",
        setting = recipes[i].setting_name .. "_EMISSIONS_MULTIPLIER",
        name = prefix .. recipes[i].name .. "-emissions-multiplier",
        setting_type = "startup",
        order = (recipes[i].order or "") .. ("c[recipe]-c[" .. recipes[i].name .. "]-e[recipe]-m[emissions-multiplier]"),
        default_value = recipes[i].emissions_multiplier or 1,
        maximum_value = 111,
        minimum_value = 0.0001,
        hidden = recipes[i].hidden,
    }
end

return settings