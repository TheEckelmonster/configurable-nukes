local mods = mods

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (not sa_active and not se_active) then
    return
end

local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local rocket_part_recipe = data.raw["recipe"]["rocket-part"]
local ipbm_rocket_part_intermediate = Util.table.deepcopy(rocket_part_recipe)

ipbm_rocket_part_intermediate.name = "ipbm-rocket-part-intermediate"
ipbm_rocket_part_intermediate.energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_TIME.name })
ipbm_rocket_part_intermediate.ingredients = Setting_Utils.get_recipe_ingredients({
    recipe_setting = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE,
}) or Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.ingredients
ipbm_rocket_part_intermediate.category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.name })
ipbm_rocket_part_intermediate.additional_categories = Setting_Utils.get_additional_crafting_machines({
    default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.name }),
})
ipbm_rocket_part_intermediate.hide_from_player_crafting = false
ipbm_rocket_part_intermediate.auto_recycle = false
ipbm_rocket_part_intermediate.overload_multiplier = 2
ipbm_rocket_part_intermediate.allow_inserter_overload = true
ipbm_rocket_part_intermediate.results = Setting_Utils.get_recipe_results({
    recipe_setting = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULTS,
}) or Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULTS.results
ipbm_rocket_part_intermediate.enabled = false
ipbm_rocket_part_intermediate.subgroup = "ipbm-rocket-parts"
ipbm_rocket_part_intermediate.order = "wzzz[ipbm-rocket-part-intermediate]-wzzz[ipbm-rocket-part-intermediate]"
ipbm_rocket_part_intermediate.localised_name = { "recipe-name.ipbm-rocket-part-intermediate" }
ipbm_rocket_part_intermediate.allowed_effects = {
    "consumption",
    "speed",
    "productivity",
    "pollution"
}

data:extend({ipbm_rocket_part_intermediate})