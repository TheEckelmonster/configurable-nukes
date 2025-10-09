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
    ipbm_rocket_part_dummy.auto_recycle = false

    -- This doesn't actually matter I believe, could be any number as the craft count is what's considered, not the results of the crafts
    ipbm_rocket_part_dummy.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = 1 }}

    --[[ IPBM rocket part basic ]]
    local ipbm_rocket_part_basic = Util.table.deepcopy(rocket_part_recipe)
    ipbm_rocket_part_basic.name = "ipbm-rocket-part-basic"
    ipbm_rocket_part_basic.allow_inserter_overload = true
    ipbm_rocket_part_basic.overload_multiplier = 2
    ipbm_rocket_part_basic.energy_required = 4
    local se_multiplier = mods and mods["space-exploration"] and 0.4 or 1
    ipbm_rocket_part_basic.ingredients =
    {
        --[[ TODO: Make configurable ]]
        { type = "item", name = "low-density-structure", amount = 10 * se_multiplier, },
        { type = "item", name = "rocket-fuel", amount = se_multiplier and 10 * se_multiplier, },
        { type = "item", name = "rocket-control-unit", amount = 10 * se_multiplier, },
    }

    if (mods and mods["space-exploration"]) then
        --[[ TODO: Make configurable ]]
        table.insert(ipbm_rocket_part_basic.ingredients, { type = "item", name = "se-heat-shielding", amount = 10 * se_multiplier, })
    end

    ipbm_rocket_part_basic.hide_from_player_crafting = false
    ipbm_rocket_part_basic.auto_recycle = false
    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_basic.category = "crafting-with-fluid"

    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_basic.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = 1 }}

    --[[ IPBM rocket part intermediate ]]
    local result_amount = 5
    local ipbm_rocket_part_intermediate = Util.table.deepcopy(rocket_part_recipe)
    ipbm_rocket_part_intermediate.name = "ipbm-rocket-part-intermediate"
    ipbm_rocket_part_intermediate.allow_inserter_overload = true
    ipbm_rocket_part_intermediate.overload_multiplier = 2
    ipbm_rocket_part_intermediate.energy_required = 12
    ipbm_rocket_part_intermediate.ingredients =
    {
        --[[ TODO: Make configurable ]]
        { type = "item", name = "low-density-structure", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-fuel", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "rocket-control-unit", amount = math.ceil(30 * se_multiplier) / 1, },
        { type = "item", name = "nuclear-fuel", amount = math.ceil(4 / 1), }
    }

    if (mods and mods["space-exploration"]) then
        --[[ TODO: Make configurable ]]
        table.insert(ipbm_rocket_part_intermediate.ingredients, { type = "item", name = "se-heat-shielding", amount = math.ceil((30 * se_multiplier) / 1) })
    end

    ipbm_rocket_part_intermediate.hide_from_player_crafting = false
    ipbm_rocket_part_intermediate.auto_recycle = false
    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_intermediate.category = "crafting-with-fluid"

    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_intermediate.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = result_amount }}

    --[[ IPBM rocket part advanced ]]
    result_amount = 20
    local ipbm_rocket_part_advanced = Util.table.deepcopy(rocket_part_recipe)
    ipbm_rocket_part_advanced.name = "ipbm-rocket-part-advanced"
    ipbm_rocket_part_advanced.allow_inserter_overload = true
    ipbm_rocket_part_advanced.overload_multiplier = 2
    ipbm_rocket_part_advanced.energy_required = 30
    local quantum_processor_prefix = mods and mods["space-exploration"] and "se-" or ""
    ipbm_rocket_part_advanced.ingredients =
    {
        --[[ TODO: Make configurable ]]
        { type = "item", name = quantum_processor_prefix .. "quantum-processor", amount = math.floor((20 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "low-density-structure", amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-control-unit",   amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "rocket-fuel",           amount = math.ceil((40 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
        { type = "item", name = "uranium-fuel-cell",     amount = math.ceil((10) / 1), },
        { type = "item", name = "nuclear-fuel",          amount = math.ceil((8) / 1),  },
    }

    if (mods and mods["space-exploration"]) then
        --[[ TODO: Make configurable ]]
        table.insert(ipbm_rocket_part_advanced.ingredients, { type = "item", name = "se-heat-shielding", amount = math.ceil(40 * (se_multiplier * 1.5)) / 1 })
        table.insert(ipbm_rocket_part_advanced.ingredients, { type = "item", name = "se-aeroframe-bulkhead", amount = math.floor(25 * (se_multiplier * 1.5)) / 1 })
    end

    ipbm_rocket_part_advanced.hide_from_player_crafting = false
    ipbm_rocket_part_advanced.auto_recycle = false
    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_advanced.category = "crafting-with-fluid"

    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_advanced.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = result_amount }}

    --[[ IPBM rocket part beyond ]]
    result_amount = 60
    local ipbm_rocket_part_beyond = Util.table.deepcopy(rocket_part_recipe)
    ipbm_rocket_part_beyond.name = "ipbm-rocket-part-beyond"
    ipbm_rocket_part_beyond.allow_inserter_overload = true
    ipbm_rocket_part_beyond.overload_multiplier = 2
    ipbm_rocket_part_beyond.energy_required = 45
    if (se_active) then
        ipbm_rocket_part_beyond.ingredients =
        {
            --[[ TODO: Make configurable ]]
            { type = "item", name = "rocket-fuel",              amount = math.ceil((60) / 1), },
            { type = "item", name = "nuclear-fuel",             amount = math.ceil((15) / 1), },
            { type = "item", name = "uranium-fuel-cell",        amount = math.ceil((10) / 1), },
            { type = "item", name = "se-nanomaterial",          amount = math.ceil((40) / 1), },
            { type = "item", name = "se-antimatter-canister",   amount = math.ceil((5)  / 1), },
            { type = "item", name = "rocket-control-unit",      amount = math.ceil((60) / 1), },
            { type = "item", name = "se-naquium-processor",     amount = math.ceil((4)  / 1), },
            { type = "item", name = "se-aeroframe-bulkhead",    amount = math.ceil((40) / 1), },
            { type = "item", name = "se-naquium-tessaract",     amount = math.ceil((1)  / 1), },
            { type = "item", name = "se-heat-shielding",        amount = math.ceil((60) / 1), },
        }
    else
        ipbm_rocket_part_beyond.ingredients =
        {
            --[[ TODO: Make configurable ]]
            { type = "item", name = "rocket-control-unit",       amount = math.ceil((60) / 1), },
            { type = "item", name = "low-density-structure",     amount = math.ceil((60) / 1), },
            { type = "item", name = "rocket-fuel",               amount = math.ceil((60) / 1), },
            { type = "item", name = "nuclear-fuel",              amount = math.ceil((15) / 1), },
            { type = "item", name = "uranium-fuel-cell",         amount = math.ceil((20) / 1), },
            { type = "item", name = "carbon-fiber",              amount = math.ceil((30) / 1), },
            { type = "item", name = "tungsten-plate",            amount = math.ceil((12) / 1), },
            { type = "item", name = "quantum-processor",         amount = math.ceil((20) / 1), },
            { type = "item", name = "promethium-asteroid-chunk", amount = math.ceil((30) / 1), },
        }
    end

    ipbm_rocket_part_beyond.hide_from_player_crafting = false
    ipbm_rocket_part_beyond.auto_recycle = false
    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_beyond.category = "crafting-with-fluid"

    --[[ TODO: Make configurable ]]
    ipbm_rocket_part_beyond.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = result_amount }}

    local ipbm_rocket_part_beyond_2 = Util.table.deepcopy(ipbm_rocket_part_beyond)
    ipbm_rocket_part_beyond_2.name = "ipbm-rocket-part-beyond-2"

    if (sa_active) then
        table.insert(ipbm_rocket_part_beyond.ingredients, { type = "item", name = "biter-egg", amount = 20 })
        table.insert(ipbm_rocket_part_beyond_2.ingredients, { type = "item", name = "pentapod-egg", amount = 20 })
    end

    ipbm_rocket_part_basic.order        = "vzzz[ipbm-rocket-part-basic]-vzzz[ipbm-rocket-part-basic]"
    ipbm_rocket_part_intermediate.order = "wzzz[ipbm-rocket-part-intermediate]-wzz[ipbm-rocket-part-intermediate]"
    ipbm_rocket_part_advanced.order     = "xzzz[ipbm-rocket-part-advanced]-xzzz[ipbm-rocket-part-advanced]"
    ipbm_rocket_part_beyond.order       = "yzzz[ipbm-rocket-part-beyond]-yzzz[ipbm-rocket-part-beyond]"
    ipbm_rocket_part_beyond_2.order     = "zzzz[ipbm-rocket-part-beyond-2]-zzzz[ipbm-rocket-part-beyond-2]"

    ipbm_rocket_part_basic.localised_name        = { "recipe-name." .. name_prefix .. "ipbm-rocket-part-basic" }
    ipbm_rocket_part_intermediate.localised_name = { "recipe-name." .. name_prefix .. "ipbm-rocket-part-intermediate" }
    ipbm_rocket_part_advanced.localised_name     = { "recipe-name." .. name_prefix .. "ipbm-rocket-part-advanced" }
    ipbm_rocket_part_beyond.localised_name       = { "recipe-name." .. name_prefix .. "ipbm-rocket-part-beyond" }
    ipbm_rocket_part_beyond.localised_name_2     = { "recipe-name.ipbm-rocket-part-beyond-2" }

    data:extend({
        ipbm_rocket_part_dummy,
        ipbm_rocket_part_basic,
        ipbm_rocket_part_intermediate,
        ipbm_rocket_part_advanced,
        ipbm_rocket_part_beyond,
    })

    if (sa_active) then
        data:extend({
            ipbm_rocket_part_beyond_2,
        })
    end

    rocket_part_recipe.hidden = true
end