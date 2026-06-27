local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")


local recipe =
{
    type = "recipe",
    name = "cn-rod-from-god",
    enabled = false,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_RECIPE,
    }) or Startup_Settings_Constants.settings.ROD_FROM_GOD_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_RESULTS,
    }) or Startup_Settings_Constants.settings.ROD_FROM_GOD_RESULTS.results,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_CRAFTING_MACHINE.name }),
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
    auto_recycle = false,
}

data:extend({ recipe, })