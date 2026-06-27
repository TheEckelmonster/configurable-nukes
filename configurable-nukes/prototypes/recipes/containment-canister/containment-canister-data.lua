local __Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

return function (Startup_Settings_Constants)
    Startup_Settings_Constants = Startup_Settings_Constants or __Startup_Settings_Constants

    local recipe =
    {
        type = "recipe",
        name = "cn-containment-canister",
        icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister-empty.png",
        icon_size = 64,
        category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_CRAFTING_MACHINE.name }),
        subgroup = "intermediate-product",
        order = "a[basic-intermediates]-d[containment-canister]",
        energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_CRAFTING_TIME.name }),
        emissions_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_EMISSIONS_MULTIPLIER.name }) or 1,
        ingredients = Setting_Utils.get_recipe_ingredients({
            recipe_setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_RECIPE,
        }) or Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_RECIPE.ingredients,
        results = Setting_Utils.get_recipe_results({
            recipe_setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_RESULTS,
        }) or Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_RESULTS.results,
        additional_categories = Setting_Utils.get_additional_crafting_machines({
            default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_ADDITIONAL_CRAFTING_MACHINES.name }),
        }),
        allow_productivity = false,
    }

    data:extend({ recipe, })
end