local quantum_processor_prefix = se_active and "se-" or ""

local se_multiplier = se_active and 0.4 or 1

local item = {
    ["basic"] = 6,
    ["intermediate"] = 15,
    ["advanced"] = 24,
    ["beyond"] = 36,
    ["rocket-fuel"] = function (recipe) end,
    ["rocket-control-unit"] = function (recipe) end,
}

local amounts = {
    ["basic"] = function (name) return name and item[name] and item[name](name) or item["basic"] end,
    ["intermediate"] = function (name) return name and item[name] and item[name](name) or item["intermediate"] end,
    ["advanced"] = function (name) return name and item[name] and item[name](name) or item["advanced"] end,
    ["beyond"] = function (name) return name and item[name] and item[name](name) or item["beyond"] end,
}

local recipes = {
    {
        setting_name = "BALLISTIC_ROCKET_PART",
        name = "ballistic-rocket-part",
        energy_required = 6,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = "low-density-structure", amount = 6, },
            { type = "item", name = "cn-heat-shielding", amount = 6, },
            { type = "item", name = "rocket-fuel", amount = 2, },
            { type = "item", name = "rocket-control-unit", amount = 2, },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 1, },
        }
    },
    {
        setting_name = "BALLISTIC_ROCKET_PART_INTERMEDIATE",
        name = "ballistic-rocket-part-intermediate",
        energy_required = 15,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = "low-density-structure", amount = math.ceil(15 * se_multiplier) / 1, },
            { type = "item", name = "cn-heat-shielding", amount = math.ceil(15 * se_multiplier) / 1, },
            { type = "item", name = "rocket-fuel", amount = math.ceil(15 * se_multiplier) / 3, },
            { type = "item", name = "rocket-control-unit", amount = math.ceil(15 * se_multiplier) / 3, },
            { type = "item", name = "nuclear-fuel", amount = math.ceil(1 / 1), }
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 3, },
        }
    },
    {
        setting_name = "BALLISTIC_ROCKET_PART_ADVANCED",
        name = "ballistic-rocket-part-advanced",
        energy_required = 30,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = quantum_processor_prefix .. "quantum-processor", amount = math.floor((20 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
            { type = "item", name = "low-density-structure", amount = math.ceil((24 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
            { type = "item", name = "cn-heat-shielding",     amount = math.ceil((24 * (se_active and se_multiplier * 1.5 or 1)) / 1), },
            { type = "item", name = "rocket-control-unit",   amount = math.ceil((24 * (se_active and se_multiplier * 1.5 or 1)) / 3), },
            { type = "item", name = "rocket-fuel",           amount = math.ceil((24 * (se_active and se_multiplier * 1.5 or 1)) / 3), },
            { type = "item", name = "uranium-fuel-cell",     amount = math.ceil((6) / 1), },
            { type = "item", name = "nuclear-fuel",          amount = math.ceil((4) / 1), },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 12, },
        },
    },
    {
        setting_name = "BALLISTIC_ROCKET_PART_BEYOND",
        name = "ballistic-rocket-part-beyond",
        energy_required = 60,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = "rocket-control-unit",       amount = math.ceil((36) / 1), },
            { type = "item", name = "low-density-structure",     amount = math.ceil((36) / 1), },
            { type = "item", name = "cn-heat-shielding",         amount = math.ceil((36) / 1), },
            { type = "item", name = "rocket-fuel",               amount = math.ceil((36) / 1), },
            { type = "item", name = "nuclear-fuel",              amount = math.ceil((9)  / 1), },
            { type = "item", name = "uranium-fuel-cell",         amount = math.ceil((12) / 1), },
            { type = "item", name = "carbon-fiber",              amount = math.ceil((18) / 1), },
            { type = "item", name = "tungsten-plate",            amount = math.ceil((8)  / 1), },
            { type = "item", name = "quantum-processor",         amount = math.ceil((12) / 1), },
            { type = "item", name = "promethium-asteroid-chunk", amount = math.ceil((18) / 1), },
            { type = "item", name = "biter-egg",                 amount = 12 },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 30, },
        },
    },
    {
        setting_name = "BALLISTIC_ROCKET_PART_BEYOND_2",
        name = "ballistic-rocket-part-beyond-2",
        energy_required = 60,
        crafting_machine = "crafting-with-fluid",
        ingredients =
        {
            { type = "item", name = "rocket-control-unit",       amount = math.ceil((36) / 1), },
            { type = "item", name = "low-density-structure",     amount = math.ceil((36) / 1), },
            { type = "item", name = "cn-heat-shielding",         amount = math.ceil((36) / 1), },
            { type = "item", name = "rocket-fuel",               amount = math.ceil((36) / 1), },
            { type = "item", name = "nuclear-fuel",              amount = math.ceil((9)  / 1), },
            { type = "item", name = "uranium-fuel-cell",         amount = math.ceil((12) / 1), },
            { type = "item", name = "carbon-fiber",              amount = math.ceil((18) / 1), },
            { type = "item", name = "tungsten-plate",            amount = math.ceil((8)  / 1), },
            { type = "item", name = "quantum-processor",         amount = math.ceil((12) / 1), },
            { type = "item", name = "promethium-asteroid-chunk", amount = math.ceil((18) / 1), },
            { type = "item", name = "pentapod-egg",              amount = 12 },
        },
        results = {
            { type = "item",  name = "ipbm-rocket-part", amount = 30, },
        },
    },
}