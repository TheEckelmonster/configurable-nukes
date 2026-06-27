local mods = mods

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

-- if (not sa_active and not se_active) then return end

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local function get_mirvs_research_count()
    local setting = Startup_Settings_Constants.settings.MIRVS_RESEARCH_COUNT.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_COUNT.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_COUNT.name].value
    end

    return setting
end
local function get_mirvs_research_prerequisites()
    local setting = Startup_Settings_Constants.settings.MIRVS_RESEARCH_PREREQUISITES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_PREREQUISITES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_PREREQUISITES.name].value
    end

    local prerequisites = {}

    --[[ Looks for:
            >= 0 commas,
            >= 0 space characters,
            >= 1 alphanumerics/dashes/space characters,
            >= 0 space characters,
            >= 0 commas,
            >= 0 space characters,
    ]]
    local search_pattern = ",*%s*([%w%-%s]+)%s*,*"
    local i, j, param = string.find(setting or "", search_pattern, 1)
    local possible_matches = {}
    local found_match = false

    local found_func = function (found_match, param, t, type)
        for _, j in pairs(t) do
            if (j.name == param) then
                found_match = true
                break
            elseif (j.name:find(param, 1, true)) then
                possible_matches[j.name] = { param = param }
            end
        end

        return found_match
    end

    while param ~= nil do

        --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
        param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false
            if (k == "technology") then found_match = found_func(found_match, param, v, "technology")
            end

            if (found_match) then break end
        end

        if (found_match) then table.insert(prerequisites, param) end

        setting = string.sub(setting or "", j + 1, #setting)

        i, j, param = setting:find(search_pattern, 1)
    end

    -- if (#prerequisites <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(prerequisites, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    -- if (#prerequisites <= 0) then
    --     prerequisites = {
    --         "icbms",
    --         "guidance-systems-6",
    --     }
    -- end
    if (#prerequisites <= 0) then
        prerequisites = Startup_Settings_Constants.settings.MIRVS_RESEARCH_PREREQUISITES.prerequisites
    end

    return prerequisites
end
local get_mirvs_research_ingredients = function ()
    local setting = Startup_Settings_Constants.settings.MIRVS_RESEARCH_INGREDIENTS.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_INGREDIENTS.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.MIRVS_RESEARCH_INGREDIENTS.name].value
    end

    local ingredients = {}

    --[[ Looks for:
            >= 0 commas,
            >= 0 space characters,
            >= 1 alphanumerics/dashes/space characters,
            >= 0 space characters,
            == 1 equals,
            >= 0 space characters,
            >= 1 digits,
            >= 0 space characters,
            >= 0 commas,
            >= 0 space characters,
    ]]
    local search_pattern = ",*%s*([%w%-%s]+)%s*=%s*(%d+)%s*,*"
    local i, j, param, param_val = string.find(setting or "", search_pattern, 1)
    local possible_matches = {}
    local found_match = false

    local found_func = function (param, param_val, t, type)
        for _, j in pairs(t) do
            if (j.name == param) then
                found_match = true
                break
            elseif (j.name:find(param, 1, true)) then
                possible_matches[j.name] = { param = param, param_val = param_val, }
            end
        end
    end

    while param ~= nil and param_val ~= nil do

        --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
        param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false
            if (k == "technology") then found_func(param, param_val, v, "technology")
            end

            if (found_match) then break end
        end

        if (found_match) then table.insert(ingredients, { param, tonumber(param_val), }) end

        setting = string.sub(setting or "", j + 1, #setting)

        i, j, param, param_val = string.find(setting or "", search_pattern, 1)
    end

    -- if (#ingredients <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(ingredients, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    if (#ingredients <= 0) then
        ingredients = Startup_Settings_Constants.settings.MIRVS_RESEARCH_INGREDIENTS.ingredients
    end

    return ingredients
end

--[[ MIRV Technology ]]
local target_combinator_recipe =
{
    type = "unlock-recipe",
    recipe = "target-combinator",
}

local target_combinator_program_recipe =
{
    type = "unlock-recipe",
    recipe = "target-combinator-program",
}

local target_combinator_reset_recipes =
{
    { type = "unlock-recipe", recipe = "target-combinator-reformat-slow", },
    { type = "unlock-recipe", recipe = "target-combinator-reformat-dirty", },
    { type = "unlock-recipe", recipe = "target-combinator-reformat-acid", },
}

local technology_effects =
{
    target_combinator_recipe,
    target_combinator_program_recipe,
    target_combinator_reset_recipes[1],
    target_combinator_reset_recipes[2],
    target_combinator_reset_recipes[3],
}

local icons =
{
    {
        -- icon = "__base__/graphics/icons/nauvis.png",
        -- icon_size = 64,
        -- scale = 1 / 2 ^ 0,
        icon = "__base__/graphics/icons/starmap-planet-nauvis.png",
        icon_size = 512,
        scale = 1 / 2 ^ 3,
        shift = { 0, 4 },
    },
    {
        icon = "__base__/graphics/technology/rocket-silo.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 0, 64 },
    },
    {
        icon = "__base__/graphics/technology/circuit-network.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        -- icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
        -- icon_size = 64,
        -- scale = 1 / 2 ^ 1,
        shift = { -36, 64 },
    },
    {
        icon = "__base__/graphics/technology/explosive-rocketry.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { -38, -24 },
    },
    {
        icon = "__configurable-nukes__/graphics/technology/mirvs-explosive-rocketry-down.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 0, -40 },
    },
    {
        icon = "__configurable-nukes__/graphics/technology/mirvs-explosive-rocketry-flipped.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 36, -24},
    },
    {
        icon = "__base__/graphics/technology/rocketry.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 32, 64 },
    },
    {
        icon = "__base__/graphics/technology/rocketry.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 38, 64 },
    },
    {
        icon = "__base__/graphics/technology/rocketry.png",
        icon_size = 256,
        scale = 1 / 2 ^ 3,
        shift = { 44, 64 },
    },
}

data:extend({
    {
        type = "technology",
        name = "cn-mirvs",
        icons = icons,
        localised_name = { "technology-name.mirvs" },
        localised_description = { "technology-description.mirvs" },
        effects = technology_effects,
        prerequisites = get_mirvs_research_prerequisites(),
        unit =
        {
            count = get_mirvs_research_count(),
            ingredients = get_mirvs_research_ingredients(),
            time = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.MIRVS_RESEARCH_TIME.name }),
        },
    },
})