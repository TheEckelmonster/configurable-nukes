local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_target_combinator_reformat_dirty =
{
    type = "recipe",
    name = "target-combinator-reformat-dirty",
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
            icon = "__base__/graphics/icons/stone.png",
            icon_size = 64,
            scale = (1 / 2.5),
            shift = { -12, 12 },
            floating = true,
            draw_background = true,
        },
        {
            icon = "__base__/graphics/icons/fluid/crude-oil.png",
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
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_MACHINE.name }),
    subgroup = "reformatting",
    enabled = false,
    crafting_machine_tint = {
        primary     = { r = 60,  g = 45,  b = 30,  a = 0.9, }, -- (Deep Muddy Brown)
        secondary   = { r = 20,  g = 20,  b = 20,  a = 0.8, }, -- (Near-Black Umber)
        tertiary    = { r = 160, g = 140, b = 100, a = 0.6, }, -- (Sandy Tan/Ochre)
        quaternary  = { r = 210, g = 210, b = 0,   a = 0.3, }, -- (Sulfur Yellow)
    },
    hide_from_player_crafting = true,
    hide_rom_flow_stats = true,
    hide_from_signal_gui = false,
    emissions_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_EMISSIONS_MULTIPLIER.name }) or (5/3),
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RECIPE,
    }) or Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RESULTS,
        ignored_by_productivity = {
            ["target-combinator"] = { val = 2 ^ 16 - 1, },
        }
    }) or Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RESULTS,
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
}

data:extend({recipe_target_combinator_reformat_dirty})