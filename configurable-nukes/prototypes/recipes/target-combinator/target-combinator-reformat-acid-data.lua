local mods = mods
local sa_active = mods and mods["space-age"] and true

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_target_combinator_reformat_acid =
{
    type = "recipe",
    name = "target-combinator-reformat-acid",
    icons = {
        {
            icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
            icon_size = 64,
            scale = (1 / 2),
            shift = { -12, -12 },
            draw_background = true,
        },
        {
            icon = "__base__/graphics/item-group/signals.png",
            icon_size = 128,
            shift = { -12, -12 },
            scale = (1 / 4),
            draw_background = true,
        },
        {
            icon = sa_active and "__space-age__/graphics/icons/carbon.png" or "__base__/graphics/icons/coal.png",
            icon_size = 64,
            scale = (1 / 2.5),
            shift = { -12, 12 },
            floating = true,
            draw_background = true,
        },
        {
            icon = "__base__/graphics/icons/fluid/sulfuric-acid.png",
            icon_size = 64,
            scale = (1 / 2.5),
            shift = { 14, -12 },
            floating = true,
            draw_background = true,
        },
        {
            icon = "__base__/graphics/icons/signal/signal-recycle.png",
            icon_size = 64,
            shift = { 6, 6 },
            draw_background = true,
        },
        {
            icon = "__configurable-nukes__/graphics/technology/object-to-object-arrow.png",
            icon_size = 256,
            shift = { -2, -2 },
            scale = (1 / 5),
            floating = true,
        },
    },
    icon_size = 64,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_MACHINE.name }),
    subgroup = "reformatting",
    enabled = false,
    crafting_machine_tint = {
        primary     = { r = 178,  g = 212,  b = 45,  a = 0.8, }, -- (Acid green)
        secondary   = { r = 36,   g = 36,   b = 36,  a = 0.5, }, -- (Charcoal)
        tertiary    = { r = 227,  g = 204,  b = 209, a = 0.4, }, -- (Mineral white)
        quaternary  = { r = 93,   g = 63,   b = 211, a = 0.3, }, -- ("Indigo" pulse")
    },
    hide_from_player_crafting = true,
    hide_rom_flow_stats = true,
    hide_from_signal_gui = false,
    emissions_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_EMISSIONS_MULTIPLIER.name }) or 1.05,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RECIPE,
        input_multiplier_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_INPUT_MULTIPLIER,
        allow_none_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RECIPE_ALLOW_NONE,
    }) or Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RESULTS,
        ignored_by_productivity = {
            ["target-combinator"] = { val = 2 ^ 16 - 1, },
            ["water"] = { val = 2 ^ 16 - 1, },
            ["steam"] = { val = 2 ^ 16 - 1, },
        },
    }) or Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RESULTS.results,
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
}

data:extend({recipe_target_combinator_reformat_acid})