-- If already defined, return
if _startup_settings_constants and _startup_settings_constants.configurable_nukes then
    return _startup_settings_constants
end

local startup_settings_constants = {}

local prefix = "configurable-nukes-"

local default_recipe = {
    { name = "processing-unit", amount = 10 },
    { name = "explosives", amount = 10 },
    { name = "uranium-235", amount = 30 },
}

if (mods and mods["space-age"]) then
    default_recipe[3].amount = 100
end

startup_settings_constants.settings = {
    AREA_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "area-multiplier",
        setting_type = "startup",
        order = "cba",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    DAMAGE_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "damage-multiplier",
        setting_type = "startup",
        order = "cbb",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    REPEAT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "repeat-multiplier",
        setting_type = "startup",
        order = "cbc",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    FIRE_WAVE = {
        type = "bool-setting",
        name = prefix .. "fire-wave",
        setting_type = "startup",
        order = "cbd",
        default_value = false,
    },
    --[[ Item Settings ]]
    ATOMIC_BOMB_RANGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "range-modifier",
        setting_type = "startup",
        order = "cca",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ATOMIC_BOMB_COOLDOWN_MODIFIER = {
        type = "double-setting",
        name = prefix .. "cooldown-modifier",
        setting_type = "startup",
        order = "cca",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ATOMIC_BOMB_STACK_SIZE = {
        type = "int-setting",
        name = prefix .. "atomic-bomb-stack-size",
        setting_type = "startup",
        order = "ccb",
        default_value = 10,
        maximum_value = 200,
        minimum_value = 1
    },
    ATOMIC_BOMB_WEIGHT_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-weight-modifier",
        setting_type = "startup",
        order = "ccc",
        default_value = 1.5,
        maximum_value = 11,
        minimum_value = 0.0001
    },
    --[[ Recipe Settings ]]
    ATOMIC_BOMB_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-bomb-crafting-time",
        setting_type = "startup",
        order = "cce",
        default_value = 50,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    ATOMIC_BOMB_INPUT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-input-multiplier",
        setting_type = "startup",
        order = "ccf",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ATOMIC_BOMB_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "atomic-bomb-result-count",
        setting_type = "startup",
        order = "ccg",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    ATOMIC_BOMB_RECIPE = {
        type = "string-setting",
        name = prefix .. "atomic-bomb-recipe",
        setting_type = "startup",
        order = "cch",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_BOMB_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "atomic-bomb-recipe-allow-none",
        setting_type = "startup",
        order = "cci",
        default_value = false,
    },
}

for k, v in pairs(default_recipe) do
    if (not startup_settings_constants.settings.ATOMIC_BOMB_RECIPE.default_value or startup_settings_constants.settings.ATOMIC_BOMB_RECIPE.default_value == "") then
        startup_settings_constants.settings.ATOMIC_BOMB_RECIPE.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ATOMIC_BOMB_RECIPE.default_value =
            startup_settings_constants.settings.ATOMIC_BOMB_RECIPE.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

startup_settings_constants.configurable_nukes = true

local _startup_settings_constants = startup_settings_constants

return startup_settings_constants