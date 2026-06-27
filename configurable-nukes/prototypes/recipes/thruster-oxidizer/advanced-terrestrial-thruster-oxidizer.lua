local mods = mods

local sa_active = mods and mods["space-age"]
local se_active = mods and mods["space-exploration"]

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

if (sa_active) then
    local advanced_thruster_oxidizer = data.raw.recipe["advanced-thruster-oxidizer"]
    local icons = advanced_thruster_oxidizer.icons and util.table.deepcopy(advanced_thruster_oxidizer.icons) or {{ icon = advanced_thruster_oxidizer.icon, icon_size = 64, },}

    local recipe =
    {
        type = "recipe",
        name = "cn-advanced-terrestrial-thruster-oxidizer",
        icons = icons,
        category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_CRAFTING_MACHINE.name }),
        subgroup = "space-processing",
        order = "e[advanced-thruster-oxydizer-terrestrial]",
        energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_CRAFTING_TIME.name }),
        ingredients = Setting_Utils.get_recipe_ingredients({
            recipe_setting = Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_RECIPE,
        }) or Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_RECIPE.ingredients,
        results = Setting_Utils.get_recipe_results({
            recipe_setting = Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_RESULTS,
        }) or Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_RESULTS.results,
        additional_categories = Setting_Utils.get_additional_crafting_machines({
            default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_TERRESTRIAL_THRUSTER_OXIDIZER_ADDITIONAL_CRAFTING_MACHINES.name }),
        }),
        allow_productivity = true,
        always_show_products = true,
        show_amount_in_title = false,
        allow_decomposition = false,
        crafting_machine_tint =
        {
            primary    = { r = 0.082, g = 0.396, b = 0.792, a = 0.502 }, -- #1565ca80
            secondary  = { r = 0.161, g = 0.553, b = 0.796, a = 0.502 }, -- #298dcb80
            tertiary   = { r = 0.059, g = 0.376, b = 0.545, a = 0.502 }, -- #0f5f8a80
            quaternary = { r = 0.683, g = 0.915, b = 1.000, a = 0.502 }, -- #aee9ff80
        },
        surface_conditions =
        {
            {
                property = "gravity",
                min = 1,
            },
        },
    }

    data:extend({recipe})
end