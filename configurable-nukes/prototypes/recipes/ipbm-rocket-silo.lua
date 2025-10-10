local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (sa_active or se_active) then
    local Util = require("__core__.lualib.util")
    local name_prefix = se_active and "se-" or ""

    --[[ IPBM silo ]]
    local rocket_silo_recipe = data.raw["recipe"]["rocket-silo"]
    local interplanetary_rocket_silo_recipe = Util.table.deepcopy(rocket_silo_recipe)
    interplanetary_rocket_silo_recipe.name = "ipbm-rocket-silo"
    interplanetary_rocket_silo_recipe.localised_name = { "entity-name." .. name_prefix .. "ipbm-rocket-silo" }
    interplanetary_rocket_silo_recipe.localised_description = { "entity-description." .. name_prefix .. "ipbm-rocket-silo" }
    interplanetary_rocket_silo_recipe.ingredients =
    {
        --[[ TODO: Make configurable ]]
        { type = "item", name = "steel-plate", amount = 1000, },
        { type = "item", name = "refined-concrete", amount = 1000, },
        { type = "item", name = "pipe", amount = 100, },
        { type = "item", name = "iron-gear-wheel", amount = 100, },
        { type = "item", name = "processing-unit", amount = 200, },
        { type = "item", name = "electric-engine-unit", amount = 200, },
        { type = "item", name = "copper-cable", amount = 400, },
        { type = "item", name = "radar", amount = 10, },
        { type = "item", name = "steel-chest", amount = 10, },
    }

    if (mods and mods["space-exploration"]) then
        --[[ TODO: Make configurable ]]
        table.insert(interplanetary_rocket_silo_recipe.ingredients, { type = "item", name = "se-heat-shielding", amount = 200, })
    end

    interplanetary_rocket_silo_recipe.energy_required = 60
    interplanetary_rocket_silo_recipe.results = {{ type = "item", name = "ipbm-rocket-silo", amount = 1, }}

    data:extend({interplanetary_rocket_silo_recipe})

    local rocket_part_recipe = data.raw["recipe"]["rocket-part"]

    --[[ IPBM rocket part dummy ]]
    local ipbm_rocket_part_dummy = Util.table.deepcopy(rocket_part_recipe)
    ipbm_rocket_part_dummy.name = name_prefix .. "ipbm-rocket-part-dummy"
    ipbm_rocket_part_dummy.allow_inserter_overload = true
    ipbm_rocket_part_dummy.overload_multiplier = 2
    ipbm_rocket_part_dummy.energy_required = 4
    ipbm_rocket_part_dummy.ingredients =
    {
        --[[ TODO: Make configurable ]]
        { type = "item", name = name_prefix .. "ipbm-rocket-part", amount = 1, },
    }

    ipbm_rocket_part_dummy.hidden_in_factoriopedia = true
    ipbm_rocket_part_dummy.hidden = true
    ipbm_rocket_part_dummy.auto_recycle = false

    -- This doesn't actually matter I believe; could be any number as the craft count is what's considered, not the results of the crafts
    ipbm_rocket_part_dummy.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = 1 }}

    data:extend({
        ipbm_rocket_part_dummy,
    })
end