local mods = mods
local script = script

local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "ROCKET_CONTROL_UNIT",
        name = "rocket-control-unit",
        energy_required = 30,
        emissions_multiplier = 1,
        crafting_machine = sa_active and "electronics-with-fluid" or "crafting-with-fluid",
        ingredients = se_active and {
            { type = "item", name = "advanced-circuit",  amount = 5, },
            { type = "item", name = "efficiency-module", amount = 1, },
            { type = "item", name = "radar",             amount = 1, },
            { type = "item", name = "battery",           amount = 5, },
            { type = "item", name = "glass",             amount = 5, },
            { type = "item", name = "iron-plate",        amount = 5, },
        }
        or {
            { type = "fluid", name = "sulfuric-acid",         amount = 20, },
            { type = "item",  name = "efficiency-module",     amount = 2,  },
            { type = "item",  name = "decider-combinator",    amount = 2,  },
            { type = "item",  name = "arithmetic-combinator", amount = 3,  },
            { type = "item",  name = "constant-combinator",   amount = 6,  },
            { type = "item",  name = "radar",                 amount = 1,  },
            { type = "item",  name = "battery",               amount = 4,  },
        },
        results = {
            { type = "item",  name = "rocket-control-unit", amount = 1, },
        },
    },
    -- not se_active and {
    {
        setting_name = "ROCKET_CONTROL_UNIT_INTERMEDIATE",
        name = "rocket-control-unit-intermediate",
        energy_required = 45,
        emissions_multiplier = 1,
        crafting_machine = sa_active and "electromagnetics" or "crafting-with-fluid",
        ingredients = {
            { type = "item",  name = "efficiency-module",     amount = 3   },
            { type = "item",  name = "selector-combinator",   amount = 1,  },
            { type = "item",  name = "decider-combinator",    amount = 4,  },
            { type = "item",  name = "arithmetic-combinator", amount = 8,  },
            { type = "item",  name = "constant-combinator",   amount = 12, },
            { type = "item",  name = "radar",                 amount = 2,  },
            { type = "item",  name = "battery",               amount = 8,  },
            { type = "fluid", name = "sulfuric-acid",         amount = 30, },
        },
        results = {
            { type = "item",  name = "rocket-control-unit", amount = 3, },
        },
    -- } or nil,
    },
    -- not se_active and {
    not se_active and {
        setting_name = "ROCKET_CONTROL_UNIT_ADVANCED",
        name = "rocket-control-unit-advanced",
        energy_required = 50,
        emissions_multiplier = 1,
        crafting_machine = sa_active and "electromagnetics" or "crafting-with-fluid",
        ingredients = {
            { type = "item",  name = "efficiency-module",     amount = 4,  },
            { type = "item",  name = "selector-combinator",   amount = 2,  },
            { type = "item",  name = "decider-combinator",    amount = 8,  },
            { type = "item",  name = "arithmetic-combinator", amount = 16, },
            { type = "item",  name = "constant-combinator",   amount = 24, },
            { type = "item",  name = "radar",                 amount = 4,  },
            { type = "item",  name = sa_active and "supercapacitor" or "battery", amount = sa_active and 12 or 16, },
                sa_active
            and { type = "item",  name = "quantum-processor", amount = 1,  }
            or nil,
                sa_active
            and { type = "fluid", name = "electrolyte", amount = 100, }
            or nil,
                sa_active
            and { type = "fluid", name = "fluoroketone-cold", amount = 50, }
            or nil,
        },
        results = {
            { type = "item",  name = "rocket-control-unit", amount = 5, },
        },
    } or nil,
}

if (not sa_active and recipes[3] and type(recipes[3].ingredients) == "table")  then
    table.insert(recipes[3].ingredients, { type = "fluid", name = "sulfuric-acid", amount = 20, })
end

local settings = {}
for i = 1, #recipes, 1 do
    settings[#settings+1] = {
        type = "double-setting",
        setting = recipes[i].setting_name .. "_CRAFTING_TIME",
        name = prefix .. recipes[i].name .. "-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001,
        hidden = recipes[i].hidden,
    }
    settings[#settings+1] = {
        type = "double-setting",
        setting = recipes[i].setting_name .. "_EMISSIONS_MULTIPLIER",
        name = prefix .. recipes[i].name .. "-emissions-multiplier",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].emissions_multiplier,
        maximum_value = 111,
        minimum_value = 0.0001,
        hidden = recipes[i].hidden,
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
        hidden = recipes[i].hidden,
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_RESULTS",
        name = prefix .. recipes[i].name .. "-results",
        setting_type = "startup",
        order = "",
        results = recipes[i].results,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        hidden = recipes[i].hidden,
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_CRAFTING_MACHINE",
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
        hidden = recipes[i].hidden,
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_ADDITIONAL_CRAFTING_MACHINES",
        name = prefix .. recipes[i].name .. "-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
        hidden = recipes[i].hidden,
    }
end

return settings