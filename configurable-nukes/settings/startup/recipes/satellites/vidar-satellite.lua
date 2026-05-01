local mods = mods
local script = script
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "VIDAR_SATELLITE",
        name = "vidar-satellite",
        energy_required = 10,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "fluid", name = "cn-liquid-rocket-fuel",     amount = 1000, },
            { type = "item",  name = "satellite",                 amount = 1,    },
            { type = "item",  name = "supercapacitor",            amount = 100,  },
            { type = "item",  name = "carbon-fiber",              amount = 150,  },
            { type = "item",  name = "cn-heat-shielding",         amount = 50,   },
            { type = "item",  name = "cn-target-combinator",      amount = 1,    },
            { type = "item",  name = "fission-reactor-equipment", amount = 2,    },
            { type = "item",  name = "rocket-control-unit",       amount = 5,    },
        },
        results = {
            { type = "item",  name = "cn-vidar-satellite", amount = 1, },
        },
    },
    {
        setting_name = "VIDAR_SATELLITE_REFURBISHMENT",
        name = "vidar-satellite-refurbishment",
        energy_required = 10,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "fluid", name = "cn-liquid-rocket-fuel",        amount = 100, },
            { type = "item",  name = "cn-deorbited-vidar-satellite", amount = 1,   },
            { type = "item",  name = "repair-pack",                  amount = 10,  },
            { type = "item",  name = "uranium-fuel-cell",            amount = 10,  },
        },
        results = {
            { type = "item",  name = "cn-vidar-satellite",         amount = 1,  },
            { type = "item",  name = "depleted-uranium-fuel-cell", amount = 10, },
        },
    },
}

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