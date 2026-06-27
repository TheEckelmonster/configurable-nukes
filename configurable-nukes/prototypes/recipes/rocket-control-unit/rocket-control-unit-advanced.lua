local mods = mods

local sa_active = mods and mods["space-age"]
local se_active = mods and mods["space-exploration"]

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe =
{
    type = "recipe",
    name = "cn-rocket-control-unit-advanced",
    icon = "__configurable-nukes__/graphics/icons/rocket-control-unit.png",
    icon_size = 64,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_CRAFTING_MACHINE.name }),
    subgroup = not se_active and "intermediate-product" or "rocket-part",
    order = "n[rocket-control-unit]-d[advanced]",
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RECIPE,
    }) or Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RESULTS,
    }) or Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RESULTS.results,
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
}

if (sa_active or se_active or Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })) then
    data:extend({recipe})
end