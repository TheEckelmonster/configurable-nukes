local mods = mods
local script = script

local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

--[[ IPBM rocket part dummy ]]
local rocket_fuel_name = se_active and "se-liquid-rocket-fuel" or "cn-liquid-rocket-fuel"
local fluid_2_name = sa_active and "thruster-oxidizer" or "water"


local recipes = {
    {
        setting_name = "BALLISTIC_ROCKET_PART_INTEGRATION",
        name = "ballistic-rocket-part-integration",
        energy_required = 6,
        crafting_machine = "rocket-building",
        ingredients = {
            { type = "item",  name = "ipbm-rocket-part", amount = 1,   },
            { type = "item",  name = "advanced-circuit", amount = 1,   },
            { type = "item",  name = "copper-cable",     amount = 10,  },
            { type = "item",  name = "pipe",             amount = 4,   },
            { type = "fluid", name = rocket_fuel_name,   amount = 100, },
            { type = "fluid", name = fluid_2_name,       amount = 100, },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 1, },
        }
    },
}

if (se_active) then
    table.insert(recipes[1].ingredients, { type = "item", name = "se-heat-shielding", amount = 2, })
else
    table.insert(recipes[1].ingredients, { type = "item", name = "cn-heat-shielding", amount = 2, })
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
end

return settings