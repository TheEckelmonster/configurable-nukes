local mods = mods
local script = script
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "PAYLOADER_LOAD",
        name = "payloader-load",
        energy_required = 4,
        emissions_multiplier = 1,
        ingredients = {
            { type = "item",  name = "steel-plate",      amount = 2, },
            { type = "item",  name = "advanced-circuit", amount = 1, },
        },
        results = {},
    },
    {
        setting_name = "PAYLOADER_UNLOAD",
        name = "payloader-unload",
        energy_required = 9,
        emissions_multiplier = 1,
        ingredients = {},
        results = {},
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
        setting = recipes[i].setting_name .. "_EMISSIONS_MULTIPLIER",
        type = "double-setting",
        name = prefix .. recipes[i].name .. "-emissions-multiplier",
        setting_type = "startup",
        order = "",
        default_value = recipes[i].emissions_multiplier,
        maximum_value = 111,
        minimum_value = 0.0001
    }
    settings[#settings+1] = {
        type = "string-setting",
        setting = recipes[i].setting_name .. "_RECIPE",
        name = prefix .. recipes[i].name .. "-recipe",
        setting_type = "startup",
        order = "",
        ingredients = recipes[i].ingredients,
        default_value = "",
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