local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_atomic_warhead_enabled = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name].value
    end

    return setting
end
local get_guidance_systems_research_modifier = function ()
    local setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER.name].value
    end

    return setting
end
local get_guidance_systems_research_formula = function ()
    local setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_FORMULA.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_FORMULA.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_FORMULA.name].value
    end

    return setting
end
local get_guidance_systems_research_prerequisites = function ()
    local setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES.name].value
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
            get_atomic_warhead_enabled() and "rocket-control-unit" or "icbms"
        }
    end

    return prerequisites
end
local get_guidance_systems_research_ingredients = function ()
    local setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS.name].value
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
            { "logistic-science-pack",   1 },
            { "chemical-science-pack",   1 },
            { "military-science-pack",   1 },
            { "utility-science-pack",    1 },
            { "production-science-pack", 1 },
            { "space-science-pack",      1 },
        }
    end

    return ingredients
end
local get_guidance_systems_research_time = function ()
    local setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TIME.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TIME.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TIME.name].value
    end

    return setting
end

--[[ Guidance Systems Deviation Chance Reduction ]]
local guidance_systems_levels = {}

for i = 1, 10, 1 do
    table.insert(guidance_systems_levels, {
        type = "technology",
        name = i < 2 and "guidance-systems" or "guidance-systems-" .. i,
        icons = Util.technology_icon_constant_range("__configurable-nukes__/graphics/technology/rocket-control-unit.png"),
        localised_description = { "technology-description.guidance-systems" },
        effects =
        {
            {
                type = "ammo-damage",
                ammo_category = "icbm-guidance",
                modifier = get_guidance_systems_research_modifier(),
                icons =
                {
                    {
                        icon = "__base__/graphics/icons/signal/signal-damage.png",
                    },
                    {
                        icon = "__base__/graphics/icons/atomic-bomb.png",
                        floating = true,
                    },
                }
            },
        },
        prerequisites = i < 2 and get_guidance_systems_research_prerequisites() or i == 2 and { "guidance-systems" } or { "guidance-systems-" .. (i - 1) },
        unit =
        {
            count_formula = get_guidance_systems_research_formula(),
            ingredients = get_guidance_systems_research_ingredients(),
            time = get_guidance_systems_research_time(),
        },
        upgrade = i > 1 and true
    })
end

data:extend(guidance_systems_levels)