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
        setting_name = "BALLISTIC_ROCKET_SILO",
        name = "ballistic-rocket-silo",
        energy_required = 60,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item", name = "steel-plate", amount = 1000, },
            { type = "item", name = "refined-concrete", amount = 1000, },
            { type = "item", name = "pipe", amount = 100, },
            { type = "item", name = "iron-gear-wheel", amount = 100, },
            { type = "item", name = "processing-unit", amount = 200, },
            { type = "item", name = "electric-engine-unit", amount = 200, },
            { type = "item", name = "copper-cable", amount = 400, },
            { type = "item", name = "radar", amount = 10, },
            { type = "item", name = "storage-tank", amount = 4, },
            -- { type = "item", name = "programmable-speaker", amount = 1, },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-silo", amount = 1, },
        },
    },
}

if (se_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heat-shielding", amount = 200, })
else
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 200, })
    end
end

local settings = {}
for i = 1, #recipes, 1 do
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