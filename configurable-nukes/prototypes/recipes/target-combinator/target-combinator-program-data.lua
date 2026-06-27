local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_target_combinator_program =
{
    type = "recipe",
    name = "target-combinator-program",
    icons = {
        {
            icon = "__base__/graphics/item-group/signals.png",
            icon_size = 128,
            shift = { -12, -12 },
            scale = (1 / 4),
            draw_background = true,
        },
        {
            icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
            icon_size = 64,
            scale = (1 / 2),
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
        {
            icon = "__base__/graphics/icons/signal/signal-lightning.png",
            icon_size = 64,
            scale = (1 / 2),
            shift = { 8, -8 },
            draw_background = true,
            floating = true,
        },
    },
    category = "payload-change",
    subgroup = "targeting",
    enabled = false,
    crafting_machine_tint = {
        primary     = { r = 75,  g = 0,   b = 130, a = 0.8, }, -- (Deep Indigo)
        secondary   = { r = 93,  g = 63,  b = 211, a = 0.7, }, -- (Quantum Indigo)
        tertiary    = { r = 38,  g = 43,  b = 226, a = 0.6, }, -- (Violet)
        quaternary  = { r = 0,   g = 255, b = 255, a = 0.4, }, -- (Electric Cyan)
    },
    hide_from_player_crafting = true,
    hide_rom_flow_stats = true,
    hide_from_signal_gui = false,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RECIPE,
    }) or Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RESULTS,
    }) or {},
    allow_speed = false,
    allow_productivity = false,
    allow_quality = false,
    allowed_module_categories = { "efficiency", },
}

data:extend({ recipe_target_combinator_program, })