local mods = mods
local script = script
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "RAGNAROK",
        name = "ragnarok",
        energy_required = 480,
        crafting_machine = "cryogenics",
        ingredients = {
            { type = "fluid", name = "water",                          amount = 25000, },
            { type = "fluid", name = "cn-liquid-rocket-fuel",          amount = 2500,  },
            { type = "fluid", name = "fluorketone-cold",               amount = 1500,  },
            { type = "item",  name = "cn-atomic-warhead",              amount = 1,     },
            { type = "item",  name = "cn-rod-from-god",                amount = 1,     },
            { type = "item",  name = "cn-jericho",                     amount = 2,     },
            { type = "item",  name = "cn-flash-steam-artillery-shell", amount = 4,     },
            { type = "item",  name = "cn-tesla-rocket",                amount = 2,     },
            { type = "item",  name = "fusion-reactor-equipment",       amount = 2,     },
            { type = "item",  name = "raw-fish",                       amount = 25,    },
            { type = "item",  name = "promethium-asteroid-chunk",      amount = 25,    },
            { type = "item",  name = "cn-contaiment-canister",         amount = 25,    },
            { type = "item",  name = "productivity-module-3",          amount = 10,    },
            { type = "item",  name = "cn-vidar-satellite",             amount = 1,     },
        },
        results = {
            { type = "item",  name = "cn-ragnarok",       amount = 1, },
            { type = "fluid", name = "steam",             amount_min = 10000, amount_max = 150000, temperature = 500, },
            { type = "fluid", name = "fluoroketone-cold", amount_min = 1,     amount_max = 100, },
            { type = "fluid", name = "fluoroketone-hot",  amount_min = 350,   amount_max = 399, },
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