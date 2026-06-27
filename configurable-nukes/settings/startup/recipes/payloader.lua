local mods = mods
local script = script

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local ingredient_multiplier = se_active and 2 or 1

local recipes = {
    {
        setting_name = "PAYLOADER",
        name = "payloader",
        energy_required = 6,
        stack_size = 10,
        result_amount = 1,
        weight_modifier = 1/5,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item",  name = "bulk-inserter",        amount = 4, },
            { type = "item",  name = "pump",                 amount = 2, },
            { type = "item",  name = "processing-unit",      amount = 20 * ingredient_multiplier, },
            { type = "item",  name = "electric-engine-unit", amount = 10 * ingredient_multiplier, },
            { type = "fluid", name = "lubricant",            amount = 200, },
        },
        results = {
            { type = "item", name = "payloader", amount = 1, },
        },
    },
}

if (se_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "space-assembling-machine", amount = 2,  })
    table.insert(recipes[1].ingredients, { type = "item", name = "refined-concrete",         amount = 50, })
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heat-shielding",        amount = 20, })
else
    table.insert(recipes[1].ingredients, { type = "item", name = "assembling-machine-3", amount = 2,  })
    table.insert(recipes[1].ingredients, { type = "item", name = "concrete",             amount = 50, })
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 20, })
    end
end

local settings = {}
for i = 1, #recipes, 1 do
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_STACK_SIZE",
        type = "int-setting",
        name = prefix .. recipes[i].name .. "-stack-size",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].stack_size,
        maximum_value = 200,
        minimum_value = 1
    }
    settings[#settings+1] = {
        setting = recipes[i].setting_name .. "_WEIGHT_MODIFIER",
        type = "double-setting",
        name = prefix .. recipes[i].name .. "-weight-modifier",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].weight_modifier,
        maximum_value = 11,
        minimum_value = 0.0005
    }
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
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    }
end

return settings