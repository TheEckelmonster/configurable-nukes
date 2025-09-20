local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_rocket_control_unit_research_prerequisites = function ()
    local setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES.name].value
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
            "icbms",
        }
    end

    return prerequisites
end
local get_rocket_control_unit_research_ingredients = function ()
    local setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS.name].value
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
local get_rocket_control_unit_research_time = function ()
    local setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME.name].value
    end

    return setting
end
local get_rocket_control_unit_research_count = function ()
    local setting = Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT.name].value
    end

    return setting
end
local get_atomic_warhead_enabled = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name].value
    end

    return setting
end

--[[ Rocket Control Unit Unlock ]]
if (get_atomic_warhead_enabled()) then
    data:extend({
        {
            type = "technology",
            name = "rocket-control-unit",
            -- name = "cn-rocket-control-unit",
            icons =
            {
                {
                    icon = "__configurable-nukes__/graphics/technology/rocket-control-unit.png",
                    icon_size = 256,
                },
            },
            icon_size = 256,
            localised_description = { "technology-description.rocket-control-unit" },
            effects =
            {
                {
                    type = "unlock-recipe",
                    recipe = "rocket-control-unit"
                    -- recipe = "cn-rocket-control-unit"
                }
            },
            prerequisites = get_rocket_control_unit_research_prerequisites(),
            unit =
            {
                ingredients = get_rocket_control_unit_research_ingredients(),
                time = get_rocket_control_unit_research_time(),
                count = get_rocket_control_unit_research_count(),
            }
        }
    })
end