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
        setting_name = "TESLA_ROCKET",
        name = "tesla-rocket",
        energy_required = 75,
        crafting_machine = "crafting-with-fluid",
        ingredients = {
            { type = "item",  name = "lightning-collector",  amount = 10,    },
            { type = "item",  name = "processing-unit",      amount = 400,   },
            not cn_avionics_active and { type = "item",  name = "tesla-ammo", amount = 100, }
            or { type = "item",  name = "cn-galvanic-grenade", amount = 42,  },
            { type = "item",  name = "rocket-control-unit",  amount = 25,    },
            { type = "fluid", name = "electrolyte",          amount = 1600,  },
            cn_materials_active and { type = "item",  name = "cn-heat-shielding", amount = 25, }
            or nil,
        },
        results = {
            { type = "item",  name = "cn-tesla-rocket", amount = 1, },
        },
    },
}

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