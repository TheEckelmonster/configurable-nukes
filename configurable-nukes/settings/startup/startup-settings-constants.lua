-- If already defined, return
if _startup_settings_constants and _startup_settings_constants.configurable_nukes then
    return _startup_settings_constants
end

local Util = require("__core__.lualib.util")

local startup_settings_constants = {}

local prefix = "configurable-nukes-"

local default_recipe_atomic_bomb = {
    { name = "processing-unit", amount = 10 },
    { name = "explosives", amount = 10 },
    { name = "uranium-235", amount = 30 },
}

local default_recipe_rocket_control_unit =
{
    { type = "item", name = "processing-unit", amount = 2 },
    { type = "item", name = "speed-module", amount = 1 },
    { type = "item", name = "radar", amount = 1 },
    { type = "item", name = "battery", amount = 4 },
}

if (mods and mods["space-age"]) then
    default_recipe_atomic_bomb[3].amount = 100
end

local default_recipe_atomic_warhead = Util.table.deepcopy(default_recipe_atomic_bomb)

for k, v in pairs(default_recipe_atomic_warhead) do v.amount = v.amount * 5 end

table.insert(default_recipe_atomic_warhead, { name = "rocket-control-unit", amount = 10 })

local default_technology_prerequisites_atomic_warhead = {
    "atomic-bomb",
    "rocket-control-unit",
}

local default_technology_ingredients_atomic_warhead = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

local default_technology_prerequisites_ICBMs = {
    "production-science-pack",
    "utility-science-pack",
    "space-science-pack",
}

local default_technology_ingredients_ICBMs = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

local default_technology_prerequisites_rocket_control_unit = {
    "icbms",
}

local default_technology_ingredients_rocket_control_unit = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

local default_technology_prerequisites_nuclear_weapons = {
    "atomic-bomb",
    "space-science-pack",
}

local default_technology_ingredients_nuclear_weapons = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

startup_settings_constants.settings = {
    NUCLEAR_AMMO_CATEGORY = {
        type = "bool-setting",
        name = prefix .. "nuclear-ammo-category",
        setting_type = "startup",
        order = "aaa",
        default_value = false,
    },
    QUALITY_BASE_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "quality-base-multiplier",
        setting_type = "startup",
        order = "aab",
        default_value = 1.3,
        maximum_value = 11,
        minimum_value = 1 / 2 ^ 11,
    },
    --[[ Bomb ]]
    AREA_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "area-multiplier",
        setting_type = "startup",
        order = "aba",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    DAMAGE_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "damage-multiplier",
        setting_type = "startup",
        order = "abb",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    REPEAT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "repeat-multiplier",
        setting_type = "startup",
        order = "abc",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.01
    },
    FIRE_WAVE = {
        type = "bool-setting",
        name = prefix .. "fire-wave",
        setting_type = "startup",
        order = "abd",
        default_value = false,
    },
    --[[ Warhead ]]
    ATOMIC_WARHEAD_ENABLED = {
        type = "bool-setting",
        name = prefix .. "atomic-warhead-enabled",
        setting_type = "startup",
        order = "bba",
        default_value = true,
    },
    ATOMIC_WARHEAD_AREA_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-area-multiplier",
        setting_type = "startup",
        order = "bbb",
        default_value = 2.71,
        maximum_value = 11,
        minimum_value = 0.01
    },
    ATOMIC_WARHEAD_DAMAGE_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-damage-multiplier",
        setting_type = "startup",
        order = "bbc",
        default_value = 2.71,
        maximum_value = 11,
        minimum_value = 0.01
    },
    ATOMIC_WARHEAD_REPEAT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-repeat-multiplier",
        setting_type = "startup",
        order = "bbd",
        default_value = 2.71,
        maximum_value = 11,
        minimum_value = 0.01
    },
    ATOMIC_WARHEAD_FIRE_WAVE = {
        type = "bool-setting",
        name = prefix .. "atomic-warhead-fire-wave",
        setting_type = "startup",
        order = "bbe",
        default_value = true,
    },
    --[[ Item Settings ]]
    --[[ Bomb ]]
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
        minimum_value = 0.0005
    },
    --[[ Warhead ]]
    ATOMIC_WARHEAD_STACK_SIZE = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-stack-size",
        setting_type = "startup",
        order = "dcb",
        default_value = 1,
        maximum_value = 200,
        minimum_value = 1
    },
    ATOMIC_WARHEAD_WEIGHT_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-weight-modifier",
        setting_type = "startup",
        order = "dcc",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 0.0005
    },
    --[[ Recipe Settings ]]
    --[[ Bomb ]]
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
    ATOMIC_BOMB_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "atomic-bomb-crafting-machine",
        setting_type = "startup",
        order = "ccj",
        default_value = "crafting",
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
    },
    ATOMIC_BOMB_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "atomic-bomb-additional-crafting-machines",
        setting_type = "startup",
        order = "cck",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ Warhead ]]
    ATOMIC_WARHEAD_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-crafting-time",
        setting_type = "startup",
        order = "dce",
        default_value = 50,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    ATOMIC_WARHEAD_INPUT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-input-multiplier",
        setting_type = "startup",
        order = "dcf",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ATOMIC_WARHEAD_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-result-count",
        setting_type = "startup",
        order = "dcg",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    ATOMIC_WARHEAD_RECIPE = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-recipe",
        setting_type = "startup",
        order = "dch",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_WARHEAD_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "atomic-warhead-recipe-allow-none",
        setting_type = "startup",
        order = "dci",
        default_value = false,
    },
    ATOMIC_WARHEAD_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-crafting-machine",
        setting_type = "startup",
        order = "dcj",
        default_value = "crafting-with-fluid",
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
    },
    ATOMIC_WARHEAD_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-additional-crafting-machines",
        setting_type = "startup",
        order = "dck",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ Rocket Control Unit ]]
    ROCKET_CONTROL_UNIT_STACK_SIZE = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-stack-size",
        setting_type = "startup",
        order = "ddb",
        default_value = 10,
        maximum_value = 200,
        minimum_value = 1
    },
    ROCKET_CONTROL_UNIT_WEIGHT_MODIFIER = {
        type = "double-setting",
        name = prefix .. "rocket-control-unit-weight-modifier",
        setting_type = "startup",
        order = "ddc",
        -- default_value = 0.0025,
        default_value = 0.2,
        maximum_value = tons,
        minimum_value = 0.0005
    },
    ROCKET_CONTROL_UNIT_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-crafting-time",
        setting_type = "startup",
        order = "dde",
        default_value = 30,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    ROCKET_CONTROL_UNIT_INPUT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "rocket-control-unit-input-multiplier",
        setting_type = "startup",
        order = "ddf",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ROCKET_CONTROL_UNIT_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-result-count",
        setting_type = "startup",
        order = "ddg",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    ROCKET_CONTROL_UNIT_RECIPE = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-recipe",
        setting_type = "startup",
        order = "ddh",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ROCKET_CONTROL_UNIT_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "rocket-control-unit-recipe-allow-none",
        setting_type = "startup",
        order = "ddi",
        default_value = false,
    },
    ROCKET_CONTROL_UNIT_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-crafting-machine",
        setting_type = "startup",
        order = "ddj",
        default_value = "crafting-with-fluid",
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
    },
    ROCKET_CONTROL_UNIT_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-additional-crafting-machines",
        setting_type = "startup",
        order = "ddk",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ Technology ]]
    --[[ ICBMS ]]
    ICBMS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "icbms-research-prerequisites",
        setting_type = "startup",
        order = "dea",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ICBMS_RESERACH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "icbms-research-ingredients",
        setting_type = "startup",
        order = "deb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ICBMS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "icbms-research-time",
        setting_type = "startup",
        order = "dec",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    ICBMS_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "icbms-research-count",
        setting_type = "startup",
        order = "ded",
        default_value = 10000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    --[[ Warhead ]]
    ATOMIC_WARHEAD_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-research-prerequisites",
        setting_type = "startup",
        order = "dfa",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_WARHEAD_RESERACH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-research-ingredients",
        setting_type = "startup",
        order = "dfb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_WARHEAD_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-research-time",
        setting_type = "startup",
        order = "dfc",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    ATOMIC_WARHEAD_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-research-count",
        setting_type = "startup",
        order = "dfd",
        default_value = 10000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    --[[ Rocket Control Unit ]]
    ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-research-prerequisites",
        setting_type = "startup",
        order = "dga",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-research-ingredients",
        setting_type = "startup",
        order = "dgb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ROCKET_CONTROL_UNIT_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-research-time",
        setting_type = "startup",
        order = "dgc",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    ROCKET_CONTROL_UNIT_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-research-count",
        setting_type = "startup",
        order = "dgd",
        default_value = 2000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    --[[ Damage Research ]]
    NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "nuclear-weapons-research-damage-modifier",
        setting_type = "startup",
        order = "dha",
        default_value = 0.85,
        minimum_value = (1 / 11) ^ 11,
        maximum_value = 2 ^ 11,
    },
    NUCLEAR_WEAPONS_RESEARCH_FORMULA = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-formula",
        setting_type = "startup",
        order = "dhb",
        default_value = "2^(L-1)*1000",
        allow_blank = false,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-prerequisites",
        order = "dhc",
        setting_type = "startup",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESERACH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-ingredients",
        setting_type = "startup",
        order = "dhd",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "nuclear-weapons-research-time",
        setting_type = "startup",
        order = "dhe",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    -- NUCLEAR_WEAPONS_RESEARCH_INFINITE = {
    --     type = "bool-setting",
    --     name = prefix .. "nuclear-weapons-research-infinite",
    --     setting_type = "startup",
    --     order = "dff",
    --     default_value = true,
    -- },
    -- NUCLEAR_WEAPONS_RESEARCH_COUNT = {
    --     type = "int-setting",
    --     name = prefix .. "nuclear-weapons-research-count",
    --     setting_type = "startup",
    --     order = "dfg",
    --     default_value = 10000,
    --     minimum_value = 1,
    --     maximum_value = 2 ^ 42,
    -- },
    --[[ Guidance Systems ]]
    GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "guidance-systems-research-modifier",
        setting_type = "startup",
        order = "dia",
        default_value = -0.1,
        minimum_value = -1,
        maximum_value = 1,
    },
    GUIDANCE_SYSTEMS_RESEARCH_FORMULA = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-formula",
        setting_type = "startup",
        order = "dib",
        default_value = "2^(L)*1000",
        allow_blank = false,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-prerequisites",
        order = "dic",
        setting_type = "startup",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-ingredients",
        setting_type = "startup",
        order = "did",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "guidance-systems-research-time",
        setting_type = "startup",
        order = "die",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
}

local default_technology_prerequisites_guidance_systems = {
    "rocket-control-unit",
}

local default_technology_ingredients_guidance_systems = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

-- Atomic Bomb
if (mods and mods["space-age"]) then
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "chemistry-or-cryogenics")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "pressing")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "crushing")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "crafting-with-fluid-or-metallurgy")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "metallurgy-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "metallurgy")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "organic")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "organic-or-hand-crafting")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "organic-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "organic-or-chemistry")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "captive-spawner-process")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "electronics-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "electronics")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "electronics-with-fluid")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "electromagnetics")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "cryogenics-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, "cryogenics")

    -- Atomic Warhead
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "chemistry-or-cryogenics")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "pressing")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "crushing")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "crafting-with-fluid-or-metallurgy")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "metallurgy-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "metallurgy")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "organic")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "organic-or-hand-crafting")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "organic-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "organic-or-chemistry")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "captive-spawner-process")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "electronics-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "electronics")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "electronics-with-fluid")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "electromagnetics")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "cryogenics-or-assembling")
    table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, "cryogenics")

    -- Rocket Control Unit
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "chemistry-or-cryogenics")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "pressing")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "crushing")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "crafting-with-fluid-or-metallurgy")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "metallurgy-or-assembling")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "metallurgy")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "organic")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "organic-or-hand-crafting")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "organic-or-assembling")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "organic-or-chemistry")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "captive-spawner-process")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "electronics-or-assembling")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "electronics")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "electronics-with-fluid")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "electromagnetics")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "cryogenics-or-assembling")
    table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, "cryogenics")

end

-- ATOMIC_BOMB_RECIPE
for k, v in pairs(default_recipe_atomic_bomb) do
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

-- ATOMIC_WARHEAD_RECIPE
for k, v in pairs(default_recipe_atomic_warhead) do
    if (not startup_settings_constants.settings.ATOMIC_WARHEAD_RECIPE.default_value or startup_settings_constants.settings.ATOMIC_WARHEAD_RECIPE.default_value == "") then
        startup_settings_constants.settings.ATOMIC_WARHEAD_RECIPE.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ATOMIC_WARHEAD_RECIPE.default_value =
            startup_settings_constants.settings.ATOMIC_WARHEAD_RECIPE.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- ATOMIC_WARHEAD_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_atomic_warhead) do
    if (not startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- ATOMIC_WARHEAD_RESERACH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_atomic_warhead) do
    if (not startup_settings_constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS.default_value or startup_settings_constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS.default_value =
            startup_settings_constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- ICBMS_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_ICBMs) do
    if (not startup_settings_constants.settings.ICBMS_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.ICBMS_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.ICBMS_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.ICBMS_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.ICBMS_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- ICBMS_RESERACH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_ICBMs) do
    if (not startup_settings_constants.settings.ICBMS_RESERACH_INGREDIENTS.default_value or startup_settings_constants.settings.ICBMS_RESERACH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.ICBMS_RESERACH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ICBMS_RESERACH_INGREDIENTS.default_value =
            startup_settings_constants.settings.ICBMS_RESERACH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- ROCKET_CONTROL_UNIT_RECIPE
for k, v in pairs(default_recipe_rocket_control_unit) do
    if (not startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RECIPE.default_value or startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RECIPE.default_value == "") then
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RECIPE.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RECIPE.default_value =
            startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RECIPE.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_rocket_control_unit) do
    if (not startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_rocket_control_unit) do
    if (not startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value or startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value =
            startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_nuclear_weapons) do
    if (not startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- NUCLEAR_WEAPONS_RESERACH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_nuclear_weapons) do
    if (not startup_settings_constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS.default_value or startup_settings_constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS.default_value =
            startup_settings_constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_guidance_systems) do
    if (not startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_guidance_systems) do
    if (not startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value or startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value =
            startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

startup_settings_constants.configurable_nukes = true

local _startup_settings_constants = startup_settings_constants

return startup_settings_constants