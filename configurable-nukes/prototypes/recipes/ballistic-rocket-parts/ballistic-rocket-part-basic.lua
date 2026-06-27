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
local ipbm_rocket_part_basic = Util.table.deepcopy(rocket_part_recipe)

ipbm_rocket_part_basic.name = "ipbm-rocket-part-basic"
ipbm_rocket_part_basic.energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_TIME.name })
ipbm_rocket_part_basic.ingredients = Setting_Utils.get_recipe_ingredients({
    recipe_setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE,
}) or Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE.ingredients
ipbm_rocket_part_basic.category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.name })
ipbm_rocket_part_basic.additional_categories = Setting_Utils.get_additional_crafting_machines({
    default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.name }),
})
ipbm_rocket_part_basic.hide_from_player_crafting = false
ipbm_rocket_part_basic.auto_recycle = true
ipbm_rocket_part_basic.overload_multiplier = 2
ipbm_rocket_part_basic.allow_inserter_overload = true
ipbm_rocket_part_basic.results = Setting_Utils.get_recipe_results({
    recipe_setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RESULTS,
}) or Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RESULTS.results
ipbm_rocket_part_basic.enabled = false
ipbm_rocket_part_basic.subgroup = "ipbm-rocket-parts"
ipbm_rocket_part_basic.order = "vzzz[ipbm-rocket-part-basic]-vzzz[ipbm-rocket-part-basic]"
ipbm_rocket_part_basic.localised_name = { "recipe-name.ipbm-rocket-part-basic" }
ipbm_rocket_part_basic.allowed_effects = {
    "consumption",
    "speed",
    "productivity",
    "pollution"
}

data:extend({ipbm_rocket_part_basic})