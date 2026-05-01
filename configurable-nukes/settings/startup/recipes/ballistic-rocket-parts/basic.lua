local mods = mods
local script = script

local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local se_multiplier = se_active and 0.4 or 1

local prefix = "configurable-nukes-"

local recipes = {
    {
        setting_name = "BALLISTIC_ROCKET_PART",
        name = "ballistic-rocket-part",
        energy_required = 6,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = "low-density-structure", amount = 6, },
            { type = "item", name = "rocket-fuel", amount = 2, },
            { type = "item", name = "rocket-control-unit", amount = 2, },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 1, },
        }
    },
}

if (se_active) then
    recipes[1].ingredients =
    {
        { type = "item", name = "low-density-structure", amount = (10 * se_multiplier), },
        { type = "item", name = "rocket-fuel",           amount = (10 * se_multiplier) / 2, },
        { type = "item", name = "rocket-control-unit",   amount = (10 * se_multiplier) / 1, },
        { type = "item", name = "se-heat-shielding",     amount = (10 * se_multiplier) / 2, },
    }
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