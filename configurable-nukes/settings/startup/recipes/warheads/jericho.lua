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
        setting_name = "JERICHO",
        name = "jericho",
        energy_required = 50,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item", name = "explosive-rocket", amount = 100, },
            { type = "item", name = "processing-unit", amount = 12,  },
        },
        results = {
            { type = "item",  name = "cn-jericho", amount = 1, },
        },
    },
}

if (sa_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "carbon-fiber", amount = 24, })
    table.insert(recipes[1].ingredients, { type = "item", name = "pentapod-egg", amount = 3,  })
    if (cn_avionics_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "rocket-control-unit", amount = 1, })
    end
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 12, })
    end
    if (cn_propulsion_active) then
        table.insert(recipes[1].ingredients, { type = "fluid", name = "cn-liquid-rocket-fuel", amount = 400, })
    end
elseif (se_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "se-aeroframe-pole", amount = 24, })
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heat-shielding", amount = 12, })
else
    table.insert(recipes[1].ingredients, { type = "item", name = "low-density-structure", amount = 12, })
    if (cn_avionics_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "rocket-control-unit", amount = 1, })
    end
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 12, })
    end
    if (cn_propulsion_active) then
        table.insert(recipes[1].ingredients, { type = "fluid", name = "cn-liquid-rocket-fuel", amount = 400, })
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
        minimum_value = 1 / (10 ^ 5)
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