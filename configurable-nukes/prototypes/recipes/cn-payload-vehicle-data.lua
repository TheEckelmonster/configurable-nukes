local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local recipe =
{
    type = "recipe",
    name = "cn-payload-vehicle",
    icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
    enabled = false,
    requester_paste_multiplier = 1,
    subgroup = "inter-ballistic-missile",
    order = "z-payload-vehicle",
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RECIPE,
    }) or Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RESULTS,
    }) or Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RESULTS.results,
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_MACHINE.name }),
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
    auto_recycle = true,
}

data:extend({ recipe, })