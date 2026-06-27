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
        setting_name = "ROD_FROM_GOD",
        name = "rod-from-god",
        energy_required = 75,
        crafting_machine = "crafting-with-fluid",
        ingredients = {},
        results = {
            { type = "item",  name = "cn-rod-from-god", amount = 1, },
        },
    },
}

if (sa_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "tungsten-plate",    amount = 2000, })
    table.insert(recipes[1].ingredients, { type = "item", name = "tungsten-carbide",  amount = 500,  })
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 200,  })
    end
elseif (se_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heavy-girder",   amount = 600,  })
    table.insert(recipes[1].ingredients, { type = "item", name = "se-iridium-plate",  amount = 400,  })
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heat-shielding", amount = 40,   })
    table.insert(recipes[1].ingredients, { type = "item", name = "refined-concrete",  amount = 800,  })
else
    table.insert(recipes[1].ingredients, { type = "item", name = "steel-plate", amount = 3000, })
    table.insert(recipes[1].ingredients, { type = "item", name = "concrete",    amount = 1000, })
    table.insert(recipes[1].ingredients, { type = "item", name = "stone-brick", amount = 500,  })
    if (cn_materials_active) then
        table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 100,  })
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