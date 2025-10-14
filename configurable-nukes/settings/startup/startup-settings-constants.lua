-- If already defined, return
if _startup_settings_constants and _startup_settings_constants.configurable_nukes then
    return _startup_settings_constants
end

local Util = require("__core__.lualib.util")

local sa_active = mods and mods["space-age"] and true or scripts and scripts.active_mods and scripts.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or scripts and scripts.active_mods and scripts.active_mods["space-exploration"]

local startup_settings_constants = {}

local order_struct = {
    order_array = {
        -- "a", "b", "c", "d", "e",  "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        [0] = "a",
        [1] = "b",
        [2] = "c",
        [3] = "d",
        [4] = "e",
        [5] = "f",
        [6] = "g",
        [7] = "h",
        [8] = "i",
        [9] = "j",
        [10] = "k",
        [11] = "l",
        [12] = "m",
        [13] = "n",
        [14] = "o",
        [15] = "p",
        [16] = "q",
        [17] = "r",
        [18] = "s",
        [19] = "t",
        [20] = "u",
        [21] = "v",
        [22] = "w",
        [23] = "x",
        [24] = "y",
        [25] = "z",
    },
    order_dictionary = {},
}

for k, v in pairs(order_struct.order_array) do
    order_struct.order_dictionary[v] = k
end

local se_multiplier = se_active and 0.4 or 1

local prefix = "configurable-nukes-"

--[[ Reminder for myself:
    -> this is a settings file
    -> data.raw doesn't exist yet
    -> hence needing to explicitly define the recipe, rather than making a copy of the vanilla one
]]
local atomic_bomb_recipe = {
    energy_required = 50,
    result_amount = 1,
    ingredients =
    {
        { name = "processing-unit", amount = 10 },
        { name = "explosives", amount = 10 },
        { name = "uranium-235", amount = 30 },
    }
}
local default_recipe_atomic_bomb = Util.table.deepcopy(atomic_bomb_recipe)

if (mods and (mods["space-age"] or se_active)) then
    if (default_recipe_atomic_bomb and default_recipe_atomic_bomb.ingredients) then
        for k, v in pairs(default_recipe_atomic_bomb.ingredients) do
            if (v.name == "uranium-235") then
                v.amount = 100
            end
        end
    end
end

local default_recipe_atomic_warhead = Util.table.deepcopy(default_recipe_atomic_bomb)

if (default_recipe_atomic_warhead) then
    for k, v in pairs(default_recipe_atomic_warhead.ingredients) do
        if (mods and (mods["space-age"] or se_active) and v.name == "uranium-235") then
            v.amount = v.amount * 2.71
        else
            v.amount = v.amount * 5
        end
    end

    if (se_active) then
        table.insert(default_recipe_atomic_warhead.ingredients, { name = "rocket-control-unit", amount = 25 })
    else
        table.insert(default_recipe_atomic_warhead.ingredients, { name = "rocket-control-unit", amount = 25 })
    end
end

local default_technology_prerequisites_atomic_warhead = {
    "atomic-bomb",
    "icbms",
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

if (se_active) then
    default_technology_ingredients_atomic_warhead = {
        { name = "automation-science-pack", amount = 1 },
        { name = "logistic-science-pack",   amount = 1 },
        { name = "chemical-science-pack",   amount = 1 },
        { name = "military-science-pack",   amount = 1 },
        { name = "utility-science-pack",    amount = 1 },
        { name = "production-science-pack", amount = 1 },
        { name = "space-science-pack",      amount = 1 },
        { name = "se-rocket-science-pack",  amount = 1 },
    }
end

if (mods and mods["atan-nuclear-science"]) then
    table.insert(default_technology_ingredients_atomic_warhead, { name = "nuclear-science-pack", amount = 1 })
end

local default_technology_prerequisites_ICBMs = {
    "automation-science-pack",
    "logistic-science-pack",
    "chemical-science-pack",
    "military-science-pack",
    "utility-science-pack",
    "production-science-pack",
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

if (se_active) then
    default_technology_prerequisites_ICBMs = {
        "automation-science-pack",
        "logistic-science-pack",
        "chemical-science-pack",
        "military-science-pack",
        -- "utility-science-pack",
        -- "production-science-pack",
        "space-science-pack",
        "se-rocket-science-pack",
    }

    default_technology_ingredients_ICBMs = {
        { name = "automation-science-pack", amount = 1 },
        { name = "logistic-science-pack",   amount = 1 },
        { name = "chemical-science-pack",   amount = 1 },
        { name = "military-science-pack",   amount = 1 },
        -- { name = "utility-science-pack",    amount = 1 },
        -- { name = "production-science-pack", amount = 1 },
        { name = "space-science-pack",      amount = 1 },
        { name = "se-rocket-science-pack",   amount = 1 },
    }
end

local default_technology_prerequisites_IPBMs = {
    "icbms",
    "guidance-systems-4",
}

local default_technology_ingredients_IPBMs = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
    { name = "utility-science-pack",    amount = 1 },
    { name = "production-science-pack", amount = 1 },
    { name = "space-science-pack",      amount = 1 },
}

if (se_active) then
    default_technology_ingredients_IPBMs = {
        { name = "automation-science-pack", amount = 1 },
        { name = "logistic-science-pack",   amount = 1 },
        { name = "chemical-science-pack",   amount = 1 },
        { name = "military-science-pack",   amount = 1 },
        { name = "utility-science-pack",    amount = 1 },
        { name = "production-science-pack", amount = 1 },
        { name = "space-science-pack",      amount = 1 },
        { name = "se-rocket-science-pack",  amount = 1 },
    }
end

local default_recipe_rocket_control_unit =
{
    result_amount = 1,
    energy_required = 30,
    ingredients =
    {
        { type = "item", name = "processing-unit", amount = 4 },
        { type = "item", name = "speed-module", amount = 2 },
        { type = "item", name = "efficiency-module", amount = 2 },
        { type = "item", name = "radar", amount = 1 },
        { type = "item", name = "battery", amount = 8 },
    }
}

if (se_active) then
    default_recipe_rocket_control_unit.ingredients =
    {
        { type = "item", name = "advanced-circuit", amount = 5 },
        --[[ Should I keep this? It gets removed by SE given when this is currently loaded ]]
        -- { type = "item", name = "speed-module", amount = 1 },
        { type = "item", name = "efficiency-module", amount = 1 },
        { type = "item", name = "radar", amount = 1 },
        { type = "item", name = "battery", amount = 5 },
        { type = "item", name = "glass", amount = 5 },
        { type = "item", name = "iron-plate", amount = 5 },
    }
end

local advanced_recipe_rocket_control_unit = {
    energy_required = default_recipe_rocket_control_unit.energy_required * 2.5,
    result_amount = 25,
}

if (mods) then
    if (mods["space-age"]) then
        advanced_recipe_rocket_control_unit.ingredients =
        {
            { type = "item", name = "quantum-processor", amount = 5 },
            { type = "item", name = "radar", amount = 5 },
            { type = "item", name = "supercapacitor", amount = 10 },
            { type = "item", name = "speed-module-3", amount = 1 },
            { type = "item", name = "efficiency-module-3", amount = 1 },
            { type = "fluid", name = "fluoroketone-cold", amount = 50 },
        }
    elseif (se_active) then
        advanced_recipe_rocket_control_unit.result_amount = advanced_recipe_rocket_control_unit.result_amount - 9

        advanced_recipe_rocket_control_unit.ingredients =
        {
            { type = "item", name = "processing-unit", amount = 4 },
            { type = "item", name = "radar", amount = 4 },
            { type = "item", name = "se-holmium-solenoid", amount = 4 },
            { type = "item", name = "efficiency-module-2", amount = 4 },
            { type = "fluid", name = "se-cryonite-slush", amount = 100 },
        }
    end
end

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

if (se_active) then
    default_technology_prerequisites_rocket_control_unit =
    {
        "chemical-science-pack",
        "advanced-circuit",
        "battery",
    }
    default_technology_ingredients_rocket_control_unit = {
        { name = "automation-science-pack",    amount = 1 },
        { name = "logistic-science-pack",      amount = 1 },
        { name = "chemical-science-pack",      amount = 1 },
    }
end

 local recipe_ballistic_rocket_silo =
 {
    ingredients =
    {
        { type = "item", name = "steel-plate", amount = 1000, },
        { type = "item", name = "refined-concrete", amount = 1000, },
        { type = "item", name = "pipe", amount = 100, },
        { type = "item", name = "iron-gear-wheel", amount = 100, },
        { type = "item", name = "processing-unit", amount = 200, },
        { type = "item", name = "electric-engine-unit", amount = 200, },
        { type = "item", name = "copper-cable", amount = 400, },
        { type = "item", name = "radar", amount = 10, },
        { type = "item", name = "steel-chest", amount = 10, },
    },
    energy_required = 60,
    result_amount = 1,
    results = {{ type = "item", name = "ipbm-rocket-silo", amount = 1, }}
 }

if (se_active) then
    table.insert(recipe_ballistic_rocket_silo.ingredients, { type = "item", name = "se-heat-shielding", amount = 200, })
end

local recipe_ballistic_rocket_part_basic = {
    ingredients =
    {
        { type = "item", name = "low-density-structure", amount = 10, },
        { type = "item", name = "rocket-fuel", amount = 10, },
        { type = "item", name = "rocket-control-unit", amount = 10, },
    },
    result_amount = 1,
    energy_required = 4,
    hide_from_player_crafting = false,
    auto_recycle = false,
}

if (se_active) then
    recipe_ballistic_rocket_part_basic.ingredients =
    {
        { type = "item", name = "low-density-structure", amount = 10 * se_multiplier, },
        { type = "item", name = "rocket-fuel", amount = 10 * se_multiplier, },
        { type = "item", name = "rocket-control-unit", amount = 10 * se_multiplier, },
        { type = "item", name = "se-heat-shielding", amount = 10 * se_multiplier, },
    }
end

local recipe_ballistic_rocket_part_intermediate = {
    ingredients =
    {
        { type = "item", name = "low-density-structure", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-fuel", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-control-unit", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "nuclear-fuel", amount = math.ceil(4 / 1), }
    },
    result_amount = 5,
    energy_required = 12,
    hide_from_player_crafting = false,
    auto_recycle = false,
}

if (se_active) then
    recipe_ballistic_rocket_part_intermediate.ingredients =
    {
        { type = "item", name = "low-density-structure", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-fuel", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-control-unit", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "nuclear-fuel", amount = math.ceil(4 / 1), },
        { type = "item", name = "se-heat-shielding", amount = math.ceil((30 * se_multiplier) / 1) },
    }
end

local quantum_processor_prefix = se_active and "se-" or ""
local recipe_ballistic_rocket_part_advanced = {
    ingredients =
    {
        { type = "item", name = quantum_processor_prefix .. "quantum-processor", amount = math.floor((20 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "low-density-structure", amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-control-unit",   amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-fuel",           amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "uranium-fuel-cell",     amount = math.ceil((10) / 1), },
        { type = "item", name = "nuclear-fuel",          amount = math.ceil((8) / 1),  },
    },
    result_amount = 20,
    energy_required = 30,
    hide_from_player_crafting = false,
    auto_recycle = false,
}

if (se_active) then
    recipe_ballistic_rocket_part_advanced.ingredients =
    {
        { type = "item", name = quantum_processor_prefix .. "quantum-processor", amount = math.floor((20 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "low-density-structure", amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-control-unit",   amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-fuel",           amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "uranium-fuel-cell",     amount = math.ceil((10) / 1), },
        { type = "item", name = "nuclear-fuel",          amount = math.ceil((8) / 1),  },
        { type = "item", name = "se-heat-shielding",     amount = math.ceil(40 * (se_multiplier * 1.5)) / 1 },
        { type = "item", name = "se-aeroframe-bulkhead", amount = math.floor(25 * (se_multiplier * 1.5)) / 1 },
    }
end

local recipe_ballistic_rocket_part_beyond = {
    ingredients =
    {
        { type = "item", name = "rocket-control-unit",       amount = math.ceil((60) / 1), },
        { type = "item", name = "low-density-structure",     amount = math.ceil((60) / 1), },
        { type = "item", name = "rocket-fuel",               amount = math.ceil((60) / 1), },
        { type = "item", name = "nuclear-fuel",              amount = math.ceil((15) / 1), },
        { type = "item", name = "uranium-fuel-cell",         amount = math.ceil((20) / 1), },
        { type = "item", name = "carbon-fiber",              amount = math.ceil((30) / 1), },
        { type = "item", name = "tungsten-plate",            amount = math.ceil((12) / 1), },
        { type = "item", name = "quantum-processor",         amount = math.ceil((20) / 1), },
        { type = "item", name = "promethium-asteroid-chunk", amount = math.ceil((30) / 1), },
        { type = "item", name = "biter-egg",                 amount = 20 },
    },
    result_amount = 60,
    energy_required = 50,
    hide_from_player_crafting = false,
    auto_recycle = false,
}

local recipe_ballistic_rocket_part_beyond_2 = {
    ingredients =
    {
        { type = "item", name = "rocket-control-unit",       amount = math.ceil((60) / 1), },
        { type = "item", name = "low-density-structure",     amount = math.ceil((60) / 1), },
        { type = "item", name = "rocket-fuel",               amount = math.ceil((60) / 1), },
        { type = "item", name = "nuclear-fuel",              amount = math.ceil((15) / 1), },
        { type = "item", name = "uranium-fuel-cell",         amount = math.ceil((20) / 1), },
        { type = "item", name = "carbon-fiber",              amount = math.ceil((30) / 1), },
        { type = "item", name = "tungsten-plate",            amount = math.ceil((12) / 1), },
        { type = "item", name = "quantum-processor",         amount = math.ceil((20) / 1), },
        { type = "item", name = "promethium-asteroid-chunk", amount = math.ceil((30) / 1), },
        { type = "item", name = "pentapod-egg",              amount = 20 },
    },
    result_amount = 60,
    energy_required = 50,
    hide_from_player_crafting = false,
    auto_recycle = false,
}

if (se_active) then
    recipe_ballistic_rocket_part_beyond.ingredients =
    {
        { type = "item", name = "rocket-fuel",              amount = math.ceil((60) / 1), },
        { type = "item", name = "nuclear-fuel",             amount = math.ceil((15) / 1), },
        { type = "item", name = "uranium-fuel-cell",        amount = math.ceil((10) / 1), },
        { type = "item", name = "se-nanomaterial",          amount = math.ceil((40) / 1), },
        { type = "item", name = "se-antimatter-canister",   amount = math.ceil((5)  / 1), },
        { type = "item", name = "rocket-control-unit",      amount = math.ceil((60) / 1), },
        { type = "item", name = "se-naquium-processor",     amount = math.ceil((4)  / 1), },
        { type = "item", name = "se-aeroframe-bulkhead",    amount = math.ceil((40) / 1), },
        { type = "item", name = "se-naquium-tessaract",     amount = math.ceil((1)  / 1), },
        { type = "item", name = "se-heat-shielding",        amount = math.ceil((60) / 1), },
    }
    recipe_ballistic_rocket_part_beyond_2.ingredients = nil
end

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

if (mods and mods["atan-nuclear-science"]) then
    table.insert(default_technology_ingredients_nuclear_weapons, { name = "nuclear-science-pack", amount = 1 })
end


local default_technology_prerequisites_guidance_systems = {
    "rocket-control-unit",
    "automation-science-pack",
    "logistic-science-pack",
    "chemical-science-pack",
    "military-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "space-science-pack",
}

local default_technology_ingredients_guidance_systems = {
    { name = "automation-science-pack", amount = 1 },
    { name = "logistic-science-pack",   amount = 1 },
    { name = "chemical-science-pack",   amount = 1 },
    { name = "military-science-pack",   amount = 1 },
}

local default_guidance_systems_research_formula = "(1096+((((2.71^(L))*1000)^0.5)*0.75)*100)/1.547635"

if (se_active) then
    default_technology_prerequisites_guidance_systems = {
        "icbms",
        "automation-science-pack",
        "logistic-science-pack",
        "chemical-science-pack",
        "military-science-pack",
    }

    default_technology_ingredients_guidance_systems = {
        { name = "automation-science-pack", amount = 1 },
        { name = "logistic-science-pack",   amount = 1 },
        { name = "chemical-science-pack",   amount = 1 },
        { name = "military-science-pack",   amount = 1 },
        { name = "se-rocket-science-pack",  amount = 1 },
        { name = "space-science-pack",      amount = 1 },
    }
elseif (not se_active) then
    table.insert(default_technology_ingredients_guidance_systems, { name = "utility-science-pack",    amount = 1 })
    table.insert(default_technology_ingredients_guidance_systems, { name = "production-science-pack", amount = 1 })
    table.insert(default_technology_ingredients_guidance_systems, { name = "space-science-pack",      amount = 1 })
end

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
    --[[ Recipe Settings ]]
    --[[ Bomb ]]
    ATOMIC_BOMB_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-bomb-crafting-time",
        setting_type = "startup",
        order = "cce",
        default_value = atomic_bomb_recipe.energy_required,
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
        default_value = atomic_bomb_recipe.result_amount,
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
    ATOMIC_WARHEAD_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-crafting-time",
        setting_type = "startup",
        order = "dce",
        default_value = atomic_bomb_recipe.energy_required * 2.5,
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
        default_value = 0.2,
        maximum_value = tons,
        minimum_value = 0.0005
    },
    ROCKET_CONTROL_UNIT_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-crafting-time",
        setting_type = "startup",
        order = "dde",
        default_value = default_recipe_rocket_control_unit.energy_required,
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
    ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "advanced-rocket-control-unit-crafting-time",
        setting_type = "startup",
        order = "ddl",
        default_value = advanced_recipe_rocket_control_unit.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    ADVANCED_ROCKET_CONTROL_UNIT_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "advanced-rocket-control-unit-result-count",
        setting_type = "startup",
        order = "ddm",
        default_value = advanced_recipe_rocket_control_unit.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    ADVANCED_ROCKET_CONTROL_UNIT_RECIPE = {
        type = "string-setting",
        name = prefix .. "advanced-rocket-control-unit-recipe",
        setting_type = "startup",
        order = "ddn",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "advanced-rocket-control-unit-crafting-machine",
        setting_type = "startup",
        order = "ddo",
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
    --[[ Ballistic-rocket-silo ]]
    BALLISTIC_ROCKET_SILO_STACK_SIZE = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-silo-stack-size",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 200,
        minimum_value = 1,
    },
    BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER = {
        type = "double-setting",
        name = prefix .. "ballistic-rocket-silo-weight-modifier",
        setting_type = "startup",
        order = "",
        default_value = 2,
        maximum_value = tons,
        minimum_value = 0.0005,
    },
    BALLISTIC_ROCKET_SILO_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-silo-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = recipe_ballistic_rocket_silo.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001,
    },
    BALLISTIC_ROCKET_SILO_INPUT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "ballistic-rocket-silo-input-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001,
    },
    BALLISTIC_ROCKET_SILO_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-silo-result-count",
        setting_type = "startup",
        order = "",
        default_value = recipe_ballistic_rocket_silo.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1,
    },
    BALLISTIC_ROCKET_SILO_RECIPE = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-silo-recipe",
        setting_type = "startup",
        order = "",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_silo.ingredients,
    },
    BALLISTIC_ROCKET_SILO_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "ballistic-rocket-silo-recipe-allow-none",
        setting_type = "startup",
        order = "ddi",
        default_value = false,
    },
    BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-silo-crafting-machine",
        setting_type = "startup",
        order = "",
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
        hidden = not sa_active and not se_active,
    },
    BALLISTIC_ROCKET_SILO_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-silo-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
        hidden = not sa_active and not se_active,
    },
    --[[ Ballistic-rocket-part ]]
    BALLISTIC_ROCKET_PART_STACK_SIZE = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-part-stack-size",
        setting_type = "startup",
        order = "ddb",
        default_value = 5,
        maximum_value = 200,
        minimum_value = 1
    },
    BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER = {
        type = "double-setting",
        name = prefix .. "ballistic-rocket-part-weight-modifier",
        setting_type = "startup",
        order = "ddc",
        default_value = 0.2,
        maximum_value = tons,
        minimum_value = 0.0005
    },
    BALLISTIC_ROCKET_PART_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-part-crafting-time",
        setting_type = "startup",
        order = "dde",
        default_value = recipe_ballistic_rocket_part_basic.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "ballistic-rocket-part-input-multiplier",
        setting_type = "startup",
        order = "ddf",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    BALLISTIC_ROCKET_PART_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "ballistic-rocket-part-result-count",
        setting_type = "startup",
        order = "ddg",
        default_value = recipe_ballistic_rocket_part_basic.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    BALLISTIC_ROCKET_PART_RECIPE = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-part-recipe",
        setting_type = "startup",
        order = "ddh",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_part_basic.ingredients
    },
    BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "ballistic-rocket-part-recipe-allow-none",
        setting_type = "startup",
        order = "ddi",
        default_value = false,
    },
    BALLISTIC_ROCKET_PART_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-part-crafting-machine",
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
    BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "ballistic-rocket-part-additional-crafting-machines",
        setting_type = "startup",
        order = "ddk",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-crafting-time",
        setting_type = "startup",
        -- order = "ddl",
        default_value = recipe_ballistic_rocket_part_intermediate.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER = {
        type = "int-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-input-multiplier",
        setting_type = "startup",
        -- order = "ddl",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-result-count",
        setting_type = "startup",
        -- order = "ddm",
        default_value = recipe_ballistic_rocket_part_intermediate.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE = {
        type = "string-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-recipe",
        setting_type = "startup",
        -- order = "ddn",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_part_intermediate.ingredients
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-recipe-allow-none",
        setting_type = "startup",
        -- order = "ddi",
        default_value = false,
    },
    INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-crafting-machine",
        setting_type = "startup",
        -- order = "ddo",
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
    INTERMEDIATE_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "intermediate-ballistic-rocket-part-additional-crafting-machines",
        setting_type = "startup",
        -- order = "ddk",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ advanced ballistic-rocket-part ]]
    ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "advanced-ballistic-rocket-part-crafting-time",
        setting_type = "startup",
        -- order = "ddl",
        default_value = recipe_ballistic_rocket_part_advanced.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    ADVANCED_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER = {
        type = "int-setting",
        name = prefix .. "advanced-ballistic-rocket-part-input-multiplier",
        setting_type = "startup",
        -- order = "ddl",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    ADVANCED_BALLISTIC_ROCKET_PART_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "advanced-ballistic-rocket-part-result-count",
        setting_type = "startup",
        -- order = "ddm",
        default_value = recipe_ballistic_rocket_part_advanced.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    ADVANCED_BALLISTIC_ROCKET_PART_RECIPE = {
        type = "string-setting",
        name = prefix .. "advanced-ballistic-rocket-part-recipe",
        setting_type = "startup",
        -- order = "ddn",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_part_advanced.ingredients,
    },
    ADVANCED_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "advanced-ballistic-rocket-part-recipe-allow-none",
        setting_type = "startup",
        -- order = "ddi",
        default_value = false,
    },
    ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "advanced-ballistic-rocket-part-crafting-machine",
        setting_type = "startup",
        -- order = "ddo",
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
    ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "advanced-ballistic-rocket-part-additional-crafting-machines",
        setting_type = "startup",
        -- order = "ddk",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ beyond ballistic-rocket-part ]]
    BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "beyond-ballistic-rocket-part-crafting-time",
        setting_type = "startup",
        -- order = "ddl",
        default_value = recipe_ballistic_rocket_part_beyond.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    BEYOND_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER = {
        type = "int-setting",
        name = prefix .. "beyond-ballistic-rocket-part-input-multiplier",
        setting_type = "startup",
        -- order = "ddl",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    BEYOND_BALLISTIC_ROCKET_PART_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "beyond-ballistic-rocket-part-result-count",
        setting_type = "startup",
        -- order = "ddm",
        default_value = recipe_ballistic_rocket_part_beyond.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    BEYOND_BALLISTIC_ROCKET_PART_RECIPE = {
        type = "string-setting",
        name = prefix .. "beyond-ballistic-rocket-part-recipe",
        setting_type = "startup",
        -- order = "ddn",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_part_beyond.ingredients
    },
    BEYOND_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "beyond-ballistic-rocket-part-recipe-allow-none",
        setting_type = "startup",
        -- order = "ddi",
        default_value = false,
    },
    BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "beyond-ballistic-rocket-part-crafting-machine",
        setting_type = "startup",
        -- order = "ddo",
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
    BEYOND_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "beyond-ballistic-rocket-part-additional-crafting-machines",
        setting_type = "startup",
        -- order = "ddk",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ beyond ballistic-rocket-part-2 ]]
    BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_TIME = {
        type = "int-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-crafting-time",
        setting_type = "startup",
        -- order = "ddl",
        default_value = recipe_ballistic_rocket_part_beyond_2.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    BEYOND_2_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER = {
        type = "int-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-input-multiplier",
        setting_type = "startup",
        -- order = "ddl",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    BEYOND_2_BALLISTIC_ROCKET_PART_RESULT_COUNT = {
        type = "int-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-result-count",
        setting_type = "startup",
        -- order = "ddm",
        default_value = recipe_ballistic_rocket_part_beyond_2.result_amount,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE = {
        type = "string-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-recipe",
        setting_type = "startup",
        -- order = "ddn",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = recipe_ballistic_rocket_part_beyond_2.ingredients
    },
    BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE = {
        type = "bool-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-recipe-allow-none",
        setting_type = "startup",
        -- order = "ddi",
        default_value = false,
    },
    BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE = {
        type = "string-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-crafting-machine",
        setting_type = "startup",
        -- order = "ddo",
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
    BEYOND_2_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES = {
        type = "string-setting",
        name = prefix .. "beyond-2-ballistic-rocket-part-additional-crafting-machines",
        setting_type = "startup",
        -- order = "ddk",
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
    ICBMS_RESEARCH_INGREDIENTS = {
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
    --[[ IPBMS ]]
    IPBMS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "ipbms-research-prerequisites",
        setting_type = "startup",
        order = "dfa",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        hidden = not sa_active and not se_active,
    },
    IPBMS_RESEARCH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "ipbms-research-ingredients",
        setting_type = "startup",
        order = "dfb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        hidden = not sa_active and not se_active,
    },
    IPBMS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "ipbms-research-time",
        setting_type = "startup",
        order = "dfc",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
        hidden = not sa_active and not se_active,
    },
    IPBMS_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "ipbms-research-count",
        setting_type = "startup",
        order = "dfd",
        default_value = se_active and 20000 or 30000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
        hidden = not sa_active and not se_active,
    },
    --[[ Warhead ]]
    ATOMIC_WARHEAD_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-research-prerequisites",
        setting_type = "startup",
        order = "dga",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_WARHEAD_RESEARCH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "atomic-warhead-research-ingredients",
        setting_type = "startup",
        order = "dgb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ATOMIC_WARHEAD_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-research-time",
        setting_type = "startup",
        order = "dgc",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    ATOMIC_WARHEAD_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "atomic-warhead-research-count",
        setting_type = "startup",
        order = "dgd",
        default_value = 10000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    --[[ Rocket Control Unit ]]
    ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-research-prerequisites",
        setting_type = "startup",
        order = "dha",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "rocket-control-unit-research-ingredients",
        setting_type = "startup",
        order = "dhb",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    ROCKET_CONTROL_UNIT_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-research-time",
        setting_type = "startup",
        order = "dhc",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    ROCKET_CONTROL_UNIT_RESEARCH_COUNT = {
        type = "int-setting",
        name = prefix .. "rocket-control-unit-research-count",
        setting_type = "startup",
        order = "dhd",
        default_value = 2000,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
    --[[ Damage Research ]]
    NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "nuclear-weapons-research-damage-modifier",
        setting_type = "startup",
        order = "dia",
        default_value = 0.85,
        minimum_value = (1 / 11) ^ 11,
        maximum_value = 2 ^ 11,
    },
    NUCLEAR_WEAPONS_RESEARCH_FORMULA = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-formula",
        setting_type = "startup",
        order = "dib",
        default_value = "2^(L-1)*1000",
        allow_blank = false,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-prerequisites",
        order = "dic",
        setting_type = "startup",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "nuclear-weapons-research-ingredients",
        setting_type = "startup",
        order = "did",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    NUCLEAR_WEAPONS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "nuclear-weapons-research-time",
        setting_type = "startup",
        order = "die",
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
        order = "dja",
        default_value = -0.1,
        minimum_value = -11,
        maximum_value = 0,
    },
    GUIDANCE_SYSTEMS_RESEARCH_TOP_SPEED_MODIFIER = {
        type = "double-setting",
        name = prefix .. "guidance-systems-research-top-speed-modifier",
        setting_type = "startup",
        order = "djb",
        default_value = 0.1,
        minimum_value = 0,
        maximum_value = 11,
    },
    GUIDANCE_SYSTEMS_RESEARCH_FORMULA = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-formula",
        setting_type = "startup",
        order = "djc",
        default_value = default_guidance_systems_research_formula,
        allow_blank = false,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-prerequisites",
        order = "djd",
        setting_type = "startup",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS = {
        type = "string-setting",
        name = prefix .. "guidance-systems-research-ingredients",
        setting_type = "startup",
        order = "dje",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    GUIDANCE_SYSTEMS_RESEARCH_TIME = {
        type = "int-setting",
        name = prefix .. "guidance-systems-research-time",
        setting_type = "startup",
        order = "djf",
        default_value = 60,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    },
}

local settings_array = {}
local i = 1
for k, v in pairs(startup_settings_constants.settings) do
    settings_array[i] = v
    i = i + 1
end

for k, v in pairs(settings_array) do
    local order_1 = ((k - 1) % 26)
    local order_2 = math.floor((k - 1) / 26) % 26
    local order_3 = math.floor((k - 1) / 676) % 26

    local order = order_struct.order_array[order_3] .. order_struct.order_array[order_2] .. order_struct.order_array[order_1]
    v.order = order
end

-- Atomic Bomb
if (sa_active) then
    local sa_crafting_categories =
    {
        "captive-spawner-process",
        "chemistry-or-cryogenics",
        "cryogenics",
        "cryogenics-or-assembling",
        "crafting-with-fluid-or-metallurgy",
        "crushing",
        "electronics-or-assembling",
        "electromagnetics",
        "electronics",
        "electronics-with-fluid",
        "metallurgy",
        "metallurgy-or-assembling",
        "organic",
        "organic-or-assembling",
        "organic-or-chemistry",
        "organic-or-hand-crafting",
        "pressing",
    }

    for k, v in pairs(sa_crafting_categories) do
        table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
    end
end

if (se_active) then
    local se_crafting_categories =
    {
        "arcosphere",
        -- "condenser-turbine",
        -- "big-turbine",
        "casting",
        "kiln",
        -- "delivery-cannon",
        -- "delivery-cannon-weapon",
        -- "fixed-recipe", -- generic group for anything with a fixed recipe, not chosen by player
        "fuel-refining",
        "core-fragment-processing",
        "lifesupport", -- same as "space-lifesupport" but can be on land
        "melting",
        "nexus",
        "pulverising",
        "crafting-or-electromagnetics",
        -- "hard-recycling", -- no conflict with "recycling"
        -- "hand-hard-recycling", -- no conflict with "recycling"
        "se-electric-boiling", -- needs to be SE specific otherwise energy values will be off
        "space-accelerator",
        "space-astrometrics",
        "space-biochemical",
        "space-collider",
        "space-crafting", -- same as basic assembling but only in space
        "space-decontamination",
        "space-electromagnetics",
        "space-elevator",
        "space-materialisation",
        "space-genetics",
        "space-gravimetrics",
        "space-growth",
        "space-hypercooling",
        "space-laser",
        "space-lifesupport", -- same as "lifesupport" but can only be in space
        "space-manufacturing",
        "space-mechanical",
        "space-observation-gammaray",
        "space-observation-xray",
        "space-observation-uv",
        "space-observation-visible",
        "space-observation-infrared",
        "space-observation-microwave",
        "space-observation-radio",
        "space-plasma",
        "space-radiation",
        "space-radiator",
        -- "space-hard-recycling", -- no conflict with "recycling"
        "space-research",
        "space-spectrometry",
        "space-supercomputing-1",
        "space-supercomputing-2",
        "space-supercomputing-3",
        "space-supercomputing-4",
        "space-thermodynamics",
        -- "spaceship-console",
        -- "spaceship-antimatter-engine",
        -- "spaceship-ion-engine",
        -- "spaceship-rocket-engine",
        -- "pressure-washing",
        -- "dummy",
        -- "no-category"
    }

    for k, v in pairs(se_crafting_categories) do
        table.insert(startup_settings_constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE.allowed_values, v)

        table.insert(startup_settings_constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
        table.insert(startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.allowed_values, v)
    end
end

-- ATOMIC_BOMB_RECIPE
if (default_recipe_atomic_bomb and default_recipe_atomic_bomb.ingredients) then
    for k, v in pairs(default_recipe_atomic_bomb.ingredients) do
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
end

-- ATOMIC_WARHEAD_RECIPE
if (default_recipe_atomic_bomb and default_recipe_atomic_bomb.ingredients) then
    for k, v in pairs(default_recipe_atomic_warhead.ingredients) do
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

-- ATOMIC_WARHEAD_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_atomic_warhead) do
    if (not startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS.default_value =
            startup_settings_constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS.default_value
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

-- ICBMS_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_ICBMs) do
    if (not startup_settings_constants.settings.ICBMS_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.ICBMS_RESEARCH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.ICBMS_RESEARCH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.ICBMS_RESEARCH_INGREDIENTS.default_value =
            startup_settings_constants.settings.ICBMS_RESEARCH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- IPBMS_RESEARCH_PREREQUISITES
for k, v in pairs(default_technology_prerequisites_IPBMs) do
    if (not startup_settings_constants.settings.IPBMS_RESEARCH_PREREQUISITES.default_value or startup_settings_constants.settings.IPBMS_RESEARCH_PREREQUISITES.default_value == "") then
        startup_settings_constants.settings.IPBMS_RESEARCH_PREREQUISITES.default_value = v
    else
        startup_settings_constants.settings.IPBMS_RESEARCH_PREREQUISITES.default_value =
            startup_settings_constants.settings.IPBMS_RESEARCH_PREREQUISITES.default_value .. ",".. v
    end
end

-- IPBMS_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_IPBMs) do
    if (not startup_settings_constants.settings.IPBMS_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.IPBMS_RESEARCH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.IPBMS_RESEARCH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.IPBMS_RESEARCH_INGREDIENTS.default_value =
            startup_settings_constants.settings.IPBMS_RESEARCH_INGREDIENTS.default_value
            .. ","
            .. v.name
            .. "="
            .. v.amount
    end
end

-- ROCKET_CONTROL_UNIT_RECIPE
if (default_recipe_rocket_control_unit and default_recipe_rocket_control_unit.ingredients) then
    for k, v in pairs(default_recipe_rocket_control_unit.ingredients) do
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
end

-- ADVANCED_ROCKET_CONTROL_UNIT_RECIPE
if (advanced_recipe_rocket_control_unit and advanced_recipe_rocket_control_unit.ingredients) then
    for k, v in pairs(advanced_recipe_rocket_control_unit.ingredients) do
        if (not startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE.default_value or startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE.default_value == "") then
            startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE.default_value =
                startup_settings_constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

-- BALLISTIC_ROCKET_SILO_RECIPE
if (recipe_ballistic_rocket_silo and recipe_ballistic_rocket_silo.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_silo.ingredients) do
        if (not startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.default_value or startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.default_value == "") then
            startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.default_value =
                startup_settings_constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
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

-- ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_rocket_control_unit) do
    if (v.name and v.amount) then
        if (not startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value == "") then
            startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value =
                startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    else
        startup_settings_constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS.default_value = ""
        break
    end
end

-- BALLISTIC_ROCKET_PART_RECIPE
if (recipe_ballistic_rocket_part_basic and recipe_ballistic_rocket_part_basic.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_part_basic.ingredients) do
        if (not startup_settings_constants.settings.BALLISTIC_ROCKET_PART_RECIPE.default_value or startup_settings_constants.settings.BALLISTIC_ROCKET_PART_RECIPE.default_value == "") then
            startup_settings_constants.settings.BALLISTIC_ROCKET_PART_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.BALLISTIC_ROCKET_PART_RECIPE.default_value =
                startup_settings_constants.settings.BALLISTIC_ROCKET_PART_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

-- INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE
if (recipe_ballistic_rocket_part_intermediate and recipe_ballistic_rocket_part_intermediate.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_part_intermediate.ingredients) do
        if (not startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.default_value or startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.default_value == "") then
            startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                startup_settings_constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

-- ADVANCED_BALLISTIC_ROCKET_PART_RECIPE
if (recipe_ballistic_rocket_part_advanced and recipe_ballistic_rocket_part_advanced.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_part_advanced.ingredients) do
        if (not startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.default_value or startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.default_value == "") then
            startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                startup_settings_constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

-- BEYOND_BALLISTIC_ROCKET_PART_RECIPE
if (recipe_ballistic_rocket_part_beyond and recipe_ballistic_rocket_part_beyond.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_part_beyond.ingredients) do
        if (not startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.default_value or startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.default_value == "") then
            startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                startup_settings_constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

-- BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE
if (recipe_ballistic_rocket_part_beyond_2 and recipe_ballistic_rocket_part_beyond_2.ingredients) then
    for k, v in pairs(recipe_ballistic_rocket_part_beyond_2.ingredients) do
        if (not startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.default_value or startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.default_value == "") then
            startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.default_value =
                startup_settings_constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
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

-- NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_nuclear_weapons) do
    if (not startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value == "") then
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value =
            v.name
            .. "="
            .. v.amount
    else
        startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value =
            startup_settings_constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value
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

-- GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS
for k, v in pairs(default_technology_ingredients_guidance_systems) do
    if (v.name and v.amount) then
        if (not startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value or startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value == "") then
            startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value =
                v.name
                .. "="
                .. v.amount
        else
            startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value =
                startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    else
        startup_settings_constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS.default_value = ""
        break
    end
end

startup_settings_constants.settings_dictionary  = {}

for k, v in pairs(startup_settings_constants.settings) do
    startup_settings_constants.settings_dictionary[v.name] = v
end

startup_settings_constants.configurable_nukes = true

local _startup_settings_constants = startup_settings_constants

return startup_settings_constants