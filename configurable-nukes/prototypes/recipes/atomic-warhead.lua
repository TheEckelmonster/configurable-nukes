local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe_atomic_warhead =
{
    type = "recipe",
    name = "atomic-warhead",
    icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
    subgroup = "payload",
    order = "d[warhead]-e[atomic-warhead]",
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RECIPE,
    }) or Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESULTS,
    }) or Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESULTS.results,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE.name }),
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ADDITIONAL_CRAFTING_MACHINES.name }),
    })
}

if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })) then
    data:extend({recipe_atomic_warhead})
end