local mods = mods
local sa_active = mods and mods["space-age"] and true

local prefix = "configurable-nukes-"

local program_recipe = {
    energy_required = 10,
    ingredients = {
        { type = "item", name = "processing-unit", amount = 2, },
    },
    results = {
        { type = "item", name = "processing-unit", amount = 1, show_details_in_recipe_tooltip = false, },
        { type = "item", name = "processing-unit", amount = 1, probability = 100 * 0.5, show_details_in_recipe_tooltip = false, },
    }
}

local reformat_recipes = {
    dirty = {
        energy_required = 12,
        emissions_multiplier = 5/3,
        ingredients = {
            { type = "item",  name = "target-combinator", amount = 1, },
            { type = "item",  name = "stone", amount = 18, },
            { type = "fluid", name = "water", amount = 504, },
        },
        results = {
            { type = "item",  name = "target-combinator", amount = 1, probability = 100 * 0.79, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "uranium-ore", amount_min = 1, amount_max = 10, probability = 100 * 0.021, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "stone", amount_min = 0, amount_max = 4, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "raw-fish", amount = 1, probability = 100 * ((1/42)/42), show_details_in_recipe_tooltip = false, },
            { type = "fluid", name = "water", amount_min = 50, amount_max = 80, show_details_in_recipe_tooltip = false, },
            { type = "fluid", name = "crude-oil", amount_min = 38, amount_max = 46, probability = 100 * 0.042, show_details_in_recipe_tooltip = false, },
        },
    },
    acid = {
        energy_required = 24,
        emissions_multiplier = 1.05,
        ingredients = {
            { type = "item",  name = "target-combinator", amount = 1, },
            { type = "fluid", name = "sulfuric-acid", amount = 280, },
                sa_active
            and { type = "item", name = "carbon", amount = 8, }
            or  { type = "item", name = "coal",   amount = 8, },
                sa_active
            and { type = "item", name = "calcite", amount = 6, }
            or  { type = "item", name = "stone",   amount = 12, },
        },
        results = {
            { type = "item",  name = "target-combinator", amount = 1, probability = 100 * 0.958, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "uranium-ore", amount_min = 1, amount_max = 10, probability = 100 * 0.021, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "sulfur", amount_min = 1, amount_max = 10, probability = 100 * 0.6, show_details_in_recipe_tooltip = false, },
            { type = "fluid", name = "water",  amount_min = 130, amount_max = 170, probability = 100 * 0.7, show_details_in_recipe_tooltip = false, },
                sa_active
            and { type = "item", name = "calcite", amount_min = 1, amount_max = 2, probability = 100 * 0.84, show_details_in_recipe_tooltip = false, }
            or  { type = "item", name = "stone",   amount_min = 1, amount_max = 4, probability = 100 * 0.84, show_details_in_recipe_tooltip = false, },
        },
    },
    slow = {
        energy_required = 120,
        emissions_multiplier = 1,
        ingredients = {
            { type = "item",  name = "target-combinator", amount = 1, },
            { type = "item",  name = "stone", amount = 42, },
            { type = "fluid", name = "water", amount = 504, },
        },
        results = {
            { type = "item",  name = "target-combinator", amount = 1, probability = 100 * 0.999, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
            { type = "item",  name = "uranium-ore", amount_min = 1, amount_max = 10, probability = 100 * 0.14, show_details_in_recipe_tooltip = false, },
            { type = "fluid", name = "water", amount_min = 380, amount_max = 460, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
            { type = "fluid", name = "steam", amount_min = 340, amount_max = 500, temperature = 165, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
        },
    },
}

local taget_combinator_recipe_settings = {
    --[[ target-cominator-program ]]
    {
        setting = "TARGET_COMBINATOR_PROGRAM_CRAFTING_TIME",
        type = "int-setting",
        name = prefix .. "target-combinator-program-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = program_recipe.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_PROGRAM_RECIPE",
        type = "string-setting",
        name = prefix .. "target-combinator-program-recipe",
        setting_type = "startup",
        order = "",
        ingredients = program_recipe.ingredients,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_PROGRAM_RECIPE_ALLOW_NONE",
        type = "bool-setting",
        name = prefix .. "target-combinator-program-recipe-allow-none",
        setting_type = "startup",
        order = "",
        default_value = false,
    },
    {
        setting = "TARGET_COMBINATOR_PROGRAM_RESULTS",
        type = "string-setting",
        name = prefix .. "target-combinator-program-results",
        setting_type = "startup",
        order = "",
        results = program_recipe.results,
        -- default_value = nil,
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ target-cominator-reformat dirty ]]
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_TIME",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-dirty-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.dirty.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_EMISSIONS_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-dirty-emissions-multiplier",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.dirty.emissions_multiplier,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_INPUT_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-dirty-input-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_RESULT_COUNT",
        type = "int-setting",
        name = prefix .. "target-combinator-reformat-dirty-result-count",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    {
        type = "string-setting",
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_RECIPE",
        name = prefix .. "target-combinator-reformat-dirty-recipe",
        setting_type = "startup",
        order = "",
        ingredients = reformat_recipes.dirty.ingredients,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_RECIPE_ALLOW_NONE",
        type = "bool-setting",
        name = prefix .. "target-combinator-reformat-dirty-recipe-allow-none",
        setting_type = "startup",
        order = "",
        default_value = false,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_RESULTS",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-dirty-results",
        setting_type = "startup",
        order = "",
        results = reformat_recipes.dirty.results,
        default_value = nil,
        -- default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_MACHINE",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-dirty-crafting-machine",
        setting_type = "startup",
        order = "",
        default_value = sa_active and "chemistry-or-cryogenics" or "chemistry",
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
    {
        setting = "TARGET_COMBINATOR_REFORMAT_DIRTY_ADDITIONAL_CRAFTING_MACHINES",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-dirty-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ target-cominator-reformat acid ]]
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_TIME",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-acid-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.acid.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_EMISSIONS_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-acid-emissions-multiplier",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.acid.emissions_multiplier,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_INPUT_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-acid-input-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_RESULT_COUNT",
        type = "int-setting",
        name = prefix .. "target-combinator-reformat-acid-result-count",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_RECIPE",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-acid-recipe",
        setting_type = "startup",
        order = "",
        ingredients = reformat_recipes.acid.ingredients,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_RECIPE_ALLOW_NONE",
        type = "bool-setting",
        name = prefix .. "target-combinator-reformat-acid-recipe-allow-none",
        setting_type = "startup",
        order = "",
        default_value = false,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_RESULTS",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-acid-results",
        setting_type = "startup",
        order = "",
        results = reformat_recipes.acid.results,
        default_value = nil,
        -- default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_MACHINE",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-acid-crafting-machine",
        setting_type = "startup",
        order = "",
        default_value = sa_active and "organic-or-chemistry" or "chemistry",
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
    {
        setting = "TARGET_COMBINATOR_REFORMAT_ACID_ADDITIONAL_CRAFTING_MACHINES",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-acid-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    --[[ target-cominator-reformat slow ]]
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_CRAFTING_TIME",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-slow-crafting-time",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.slow.energy_required,
        maximum_value = 2 ^ 11,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_EMISSIONS_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-slow-emissions-multiplier",
        setting_type = "startup",
        order = "",
        default_value = reformat_recipes.slow.emissions_multiplier,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_INPUT_MULTIPLIER",
        type = "double-setting",
        name = prefix .. "target-combinator-reformat-slow-input-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 111,
        minimum_value = 0.0001
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_RESULT_COUNT",
        type = "int-setting",
        name = prefix .. "target-combinator-reformat-slow-result-count",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 1
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_RECIPE",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-slow-recipe",
        setting_type = "startup",
        order = "",
        ingredients = reformat_recipes.slow.ingredients,
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_RECIPE_ALLOW_NONE",
        type = "bool-setting",
        name = prefix .. "target-combinator-reformat-slow-recipe-allow-none",
        setting_type = "startup",
        order = "",
        default_value = false,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_RESULTS",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-slow-results",
        setting_type = "startup",
        order = "",
        results = reformat_recipes.slow.results,
        default_value = nil,
        -- default_value = "",
        allow_blank = true,
        auto_trim = true,
    },
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_CRAFTING_MACHINE",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-slow-crafting-machine",
        setting_type = "startup",
        order = "",
        default_value = "chemistry",
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
    {
        setting = "TARGET_COMBINATOR_REFORMAT_SLOW_ADDITIONAL_CRAFTING_MACHINES",
        type = "string-setting",
        name = prefix .. "target-combinator-reformat-slow-additional-crafting-machines",
        setting_type = "startup",
        order = "",
        default_value = "electromagnetics",
        allow_blank = true,
        auto_trim = true,
    },
}

return taget_combinator_recipe_settings