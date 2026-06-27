local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_atomic_bomb =
{
    type = "recipe",
    name = "atomic-bomb",
    enabled = false,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE,
    }) or Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULTS,
    }) or Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULTS.results,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE.name }),
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_ADDITIONAL_CRAFTING_MACHINES.name }),
    })
}

data:extend({recipe_atomic_bomb})