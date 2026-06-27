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
local ipbm_rocket_part_beyond_2 = Util.table.deepcopy(rocket_part_recipe)

ipbm_rocket_part_beyond_2.name = "ipbm-rocket-part-beyond-2"
ipbm_rocket_part_beyond_2.energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_TIME.name })
ipbm_rocket_part_beyond_2.ingredients = Setting_Utils.get_recipe_ingredients({
    recipe_setting = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE,
}) or Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.ingredients
ipbm_rocket_part_beyond_2.category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.name })
ipbm_rocket_part_beyond_2.additional_categories = Setting_Utils.get_additional_crafting_machines({
    default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.name }),
})
ipbm_rocket_part_beyond_2.hide_from_player_crafting = false
ipbm_rocket_part_beyond_2.auto_recycle = false
ipbm_rocket_part_beyond_2.overload_multiplier = 2
ipbm_rocket_part_beyond_2.allow_inserter_overload = true
ipbm_rocket_part_beyond_2.results = Setting_Utils.get_recipe_results({
    recipe_setting = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RESULTS,
}) or Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RESULTS.results
ipbm_rocket_part_beyond_2.enabled = false
ipbm_rocket_part_beyond_2.subgroup = "ipbm-rocket-parts"
ipbm_rocket_part_beyond_2.order = "zzzz[ipbm-rocket-part-beyond-2]-zzzz[ipbm-rocket-part-beyond-2]"
ipbm_rocket_part_beyond_2.localised_name = { "recipe-name.ipbm-rocket-part-beyond-2" }
ipbm_rocket_part_beyond_2.allowed_effects = {
    "consumption",
    "speed",
    "productivity",
    "pollution"
}

ipbm_rocket_part_beyond_2.hidden = not sa_active or se_active
ipbm_rocket_part_beyond_2.hidden_in_factoriopedia = not sa_active or se_active

data:extend({ipbm_rocket_part_beyond_2})