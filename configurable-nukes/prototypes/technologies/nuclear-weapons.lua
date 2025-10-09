local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_nuclear_weapons_research_damage_modifier = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER.name].value
    end

    return setting
end
local get_nuclear_weapons_research_formula = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_FORMULA.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_FORMULA.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_FORMULA.name].value
    end

    return setting
end
local get_nuclear_weapons_research_prerequisites = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES.name].value
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
        param = param:gsub("(%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

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

    if (#prerequisites <= 0) then
        prerequisites = {
            "atomic-bomb",
            "space-science-pack",
        }
    end

    return prerequisites
end
local get_nuclear_weapons_research_ingredients = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS.name].value
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
        param = param:gsub("(%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false
            if (k == "tool") then found_func(param, param_val, v, "tool")
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
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "military-science-pack", 1 },
            { "utility-science-pack", 1 },
            { "production-science-pack", 1 },
            { "space-science-pack", 1 },
        }

        if (mods and mods["atan-nuclear-science"]) then
            table.insert(ingredients, { "nuclear-science-pack", 1 })
        end
    end

    return ingredients
end
local get_nuclear_weapons_research_time = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_TIME.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_TIME.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_TIME.name].value
    end

    return setting
end
-- NUCLEAR_AMMO_CATEGORY
local get_ammo_category = function ()
    local setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name].value
    end

    return setting
end

--[[ Nuclear Ammo Type Bonuses ]]
data:extend({
    {
        type = "technology",
        name = "nuclear-damage",
        icons = Util.technology_icon_constant_damage("__base__/graphics/technology/atomic-bomb.png"),
        localised_description = { "technology-description.nuclear-damage" },
        effects =
        {
            {
                type = "ammo-damage",
                ammo_category = "nuclear",
                modifier = get_nuclear_weapons_research_damage_modifier(),
            },
        },
        prerequisites = get_nuclear_weapons_research_prerequisites(),
        unit =
        {
            count_formula = get_nuclear_weapons_research_formula(),
            ingredients = get_nuclear_weapons_research_ingredients(),
            time = get_nuclear_weapons_research_time(),
        },
        max_level = "infinite",
        upgrade = true,
        hidden = not get_ammo_category(),
        hidden_in_factoriopedia = not get_ammo_category(),
        enabled = get_ammo_category(),
    },
})