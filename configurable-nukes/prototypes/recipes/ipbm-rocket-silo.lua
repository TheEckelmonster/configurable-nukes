local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (not sa_active and not se_active) then return end

local Utils = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local name_prefix = se_active and "se-" or ""

--[[ IPBM silo ]]
local rocket_silo_recipe = data.raw["recipe"]["rocket-silo"]
local interplanetary_rocket_silo_recipe = Utils.table.deepcopy(rocket_silo_recipe)
interplanetary_rocket_silo_recipe.name = "ipbm-rocket-silo"

interplanetary_rocket_silo_recipe.energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_TIME.name })
interplanetary_rocket_silo_recipe.ingredients = Setting_Utils.get_recipe_ingredients({
    recipe_setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RECIPE,
}) or Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RECIPE.ingredients
interplanetary_rocket_silo_recipe.category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE.name })
interplanetary_rocket_silo_recipe.additional_categories = Setting_Utils.get_additional_crafting_machines({
    default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_ADDITIONAL_CRAFTING_MACHINES.name }),
})
interplanetary_rocket_silo_recipe.hide_from_player_crafting = false
interplanetary_rocket_silo_recipe.overload_multiplier = 2
interplanetary_rocket_silo_recipe.allow_inserter_overload = true

interplanetary_rocket_silo_recipe.results = Setting_Utils.get_recipe_results({
    recipe_setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RESULTS,
}) or Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RESULTS.results

interplanetary_rocket_silo_recipe.localised_name = { "entity-name." .. name_prefix .. "ipbm-rocket-silo" }
interplanetary_rocket_silo_recipe.localised_description = { "entity-description." .. name_prefix .. "ipbm-rocket-silo" }

interplanetary_rocket_silo_recipe.enabled = false

data:extend({interplanetary_rocket_silo_recipe})


--[[ Dummy recipe for the ipbm-rocket-silo ]]
local rocket_part_recipe = data.raw["recipe"]["rocket-part"]

--[[ IPBM rocket part dummy ]]
local ipbm_rocket_part_dummy = Utils.table.deepcopy(rocket_part_recipe)
ipbm_rocket_part_dummy.name = name_prefix .. "ipbm-rocket-part-dummy"
ipbm_rocket_part_dummy.allow_inserter_overload = true
ipbm_rocket_part_dummy.overload_multiplier = 6
ipbm_rocket_part_dummy.energy_required = 6

local rocket_fuel_name = se_active and "se-liquid-rocket-fuel" or "cn-liquid-rocket-fuel"
local fluid_2_name = sa_active and "thruster-oxidizer" or "water"

ipbm_rocket_part_dummy.ingredients =
{
    --[[ TODO: Make configurable ]]
    { type = "item",  name = "ipbm-rocket-part", amount = 1,   },
}

if (cn_avionics_active) then
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "item",  name = "advanced-circuit", amount = 1,   })
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "item",  name = "copper-cable", amount = 10,  })
end
if (cn_materials_active) then
    local prefix = se_active and "se-" or "cn-"
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "item",  name = prefix .. "heat-shielding", amount = 1,   })
end
if (cn_propulsion_active) then
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "item",  name = "pipe", amount = 2,   })
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "fluid", name = rocket_fuel_name, amount = 100, })
    table.insert(ipbm_rocket_part_dummy.ingredients, { type = "fluid", name = fluid_2_name, amount = 100, })
end

ipbm_rocket_part_dummy.enabled = false
ipbm_rocket_part_dummy.auto_recycle = false

-- This doesn't actually matter I believe; could be any number as the craft count is what's considered, not the results of the crafts
-- ipbm_rocket_part_dummy.results = {{ type = "item", name = "ipbm-rocket-part", amount = 1 }}
ipbm_rocket_part_dummy.results = {}

ipbm_rocket_part_dummy.icon = data.raw.item["rocket-part"].icon

data:extend({
    ipbm_rocket_part_dummy,
})