local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe =
{
    type = "recipe",
    name = "payloader-unfuel",
    icons = {
        {
            icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
            icon_size = 64,
            shift = { -12, -12, },
            draw_background = true,
        },
        {
            icon = "__base__/graphics/technology/flammables.png",
            icon_size = 256,
            shift = { 6, 6, },
            scale = (1 / 5),
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
    category = "payload-change",
    subgroup = "payload",
    enabled = false,
    order = "fuel[fuel]",
    hide_from_player_crafting = true,
    hide_rom_flow_stats = true,
    hide_from_signal_gui = false,
    emissions_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_UNFUEL_EMISSIONS_MULTIPLIER.name }) or 1,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_UNFUEL_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOADER_UNFUEL_RECIPE,
    }) or Startup_Settings_Constants.settings.PAYLOADER_UNFUEL_RECIPE.ingredients,
    results = Startup_Settings_Constants.settings.PAYLOADER_UNFUEL_RECIPE.results,
    allow_speed = false,
    allow_productivity = false,
    allow_quality = false,
    allowed_module_categories = { "efficiency", },
}

data:extend({ recipe, })