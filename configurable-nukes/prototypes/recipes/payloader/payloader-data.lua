local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_payloader =
{
    type = "recipe",
    name = "payloader",
    icon = "__configurable-nukes__/graphics/icons/payloader/payloader.png",
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_MACHINE.name }),
    subgroup = "production-machine",
    enabled = false,
    requester_paste_multiplier = 1,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOADER_RECIPE,
    }) or Startup_Settings_Constants.settings.PAYLOADER_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOADER_RESULTS,
    }) or Startup_Settings_Constants.settings.PAYLOADER_RESULTS.results,
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
}

data:extend({recipe_payloader})