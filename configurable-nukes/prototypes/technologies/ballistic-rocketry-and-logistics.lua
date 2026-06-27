local mods = mods

local cn_av_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_me_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_pr_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local get_ballistic_rocketry_and_logistics_research_prerequisites = function ()
    local setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_PREREQUISITES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BRAL_RESEARCH_PREREQUISITES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BRAL_RESEARCH_PREREQUISITES.name].value
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

    if (#prerequisites <= 0) then
        prerequisites = {
                Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })
            and "rocket-control-unit"
            or  "icbms",
            "automation-science-pack",
            "logistic-science-pack",
            "chemical-science-pack",
            "military-science-pack",
            "production-science-pack",
            "utility-science-pack",
            "space-science-pack",
        }

        if (mods and mods["space-exploration"]) then
            prerequisites =
            {
                "icbms",
                "automation-science-pack",
                "logistic-science-pack",
                "chemical-science-pack",
                "military-science-pack",
            }
        end
    end

    return prerequisites
end
local get_ballistic_rocketry_and_logistics_research_ingredients = function (param_data)
    local setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_INGREDIENTS.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BRAL_RESEARCH_INGREDIENTS.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BRAL_RESEARCH_INGREDIENTS.name].value
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

        if (mods and mods["space-exploration"]) then
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "military-science-pack", 1 },
                { "se-rocket-science-pack", 1 },
                { "space-science-pack", 1 },
            }
        end
    end

    if (se_active) then
        local ingredients_dictionary = {}
        for k, v in pairs(ingredients) do
            ingredients_dictionary[v[1]] = true
        end

        if (param_data and type(param_data) == "table" and param_data.level and type(param_data.level) == "number") then
            if (param_data.level > 3 and not ingredients_dictionary["utility-science-pack"]) then
                table.insert(ingredients, {"utility-science-pack", 1 })
            end
            if (param_data.level > 4 and not ingredients_dictionary["production-science-pack"]) then
                table.insert(ingredients, { "production-science-pack", 1 })
            end
            if (param_data.level == 6) then
                table.insert(ingredients, { "se-astronomic-science-pack-1", 1 })
            end
            if (param_data.level == 7) then
                table.insert(ingredients, { "se-astronomic-science-pack-2", 1 })
                table.insert(ingredients, { "se-energy-science-pack-2", 1 })
            end
            if (param_data.level == 8) then
                table.insert(ingredients, { "se-astronomic-science-pack-3", 1 })
                table.insert(ingredients, { "se-energy-science-pack-3", 1 })
                table.insert(ingredients, { "se-material-science-pack-3", 1 })
            end
            if (param_data.level >= 9) then
                table.insert(ingredients, { "se-astronomic-science-pack-4", 1 })
                table.insert(ingredients, { "se-energy-science-pack-4", 1 })
                table.insert(ingredients, { "se-material-science-pack-4", 1 })
                table.insert(ingredients, { "se-biological-science-pack-4", 1 })
            end
            if (param_data.level == 10) then
                table.insert(ingredients, { "se-deep-space-science-pack-1", 1 })
            end
            if (param_data.level == 11) then
                table.insert(ingredients, { "se-deep-space-science-pack-2", 1 })
            end
            if (param_data.level == 12) then
                table.insert(ingredients, { "se-deep-space-science-pack-3", 1 })
            end
            if (param_data.level == 13) then
                table.insert(ingredients, { "se-deep-space-science-pack-4", 1 })
            end
        end
    end

    return ingredients
end

--[[ Guidance Systems Deviation Chance Reduction ]]
local ballistic_rocketry_and_logistics_levels = {}

local ballistic_rocketry_and_logistics_levels_max = 10

local guidance_effect =
{
    type = "ammo-damage",
    ammo_category = "icbm-guidance",
    modifier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_DAMAGE_MODIFIER.name }),
    icons =
    {
        {
            icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-rocket.png",
            floating = true,
        },
        {
            icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-crosshair.png",
        },
        {
            icon = "__configurable-nukes__/graphics/shortcuts/icbm-remote-tip.png",
        },
    }
}

for i = 1, ballistic_rocketry_and_logistics_levels_max, 1 do
    local technology = {
        type = "technology",
        name = i < 2 and "cn-bral" or "cn-bral-" .. i,
        icons = Util.technology_icon_constant_range("__configurable-nukes__/graphics/technology/rocket-control-unit.png"),
        localised_description = { "technology-description.cn-bral" },
        effects = {},
        prerequisites = i < 2 and get_ballistic_rocketry_and_logistics_research_prerequisites() or i == 2 and { "cn-bral" } or { "cn-bral-" .. (i - 1) },
        unit =
        {
            count_formula = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_FORMULA.name }),
            ingredients = get_ballistic_rocketry_and_logistics_research_ingredients({ level = i }),
            time = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_TIME.name }),
        },
        upgrade = i > 1 and true,
        hidden = cn_av_active and cn_me_active and cn_pr_active,
        hidden_in_factoriopedia = cn_av_active and cn_me_active and cn_pr_active,
    }

    if (not cn_av_active) then
        table.insert(technology.effects, guidance_effect)
    end

    if (not cn_pr_active) then
        local top_speed_effect =
        {
            type = "ammo-damage",
            ammo_category = "icbm-top-speed",
            modifier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.BRAL_RESEARCH_TOP_SPEED_MODIFIER.name }),
            use_icon_overlay_constant = false,
        }

        if (i <= 8) then
            table.insert(technology.effects, top_speed_effect)
        end
        if (i == 9) then
            top_speed_effect.modifier = top_speed_effect.modifier * 12
            table.insert(technology.effects, top_speed_effect)
        end
        if (i == 10) then
            top_speed_effect.modifier = top_speed_effect.modifier * 25
            table.insert(technology.effects, top_speed_effect)
        end
    end

    if (not cn_me_active) then
        if (se_active or sa_active) then
            if (i == 6) then
                table.insert(technology.effects, { type = "unlock-recipe", recipe = "ipbm-rocket-part-intermediate" })
            elseif (i == 8) then
                table.insert(technology.effects, { type = "unlock-recipe", recipe = "ipbm-rocket-part-advanced" })
            elseif (i == 10) then
                table.insert(technology.effects, { type = "unlock-recipe", recipe = "ipbm-rocket-part-beyond" })
                if (sa_active) then
                    table.insert(technology.effects, { type = "unlock-recipe", recipe = "ipbm-rocket-part-beyond-2" })
                end
            end
        end
    end

    if (sa_active) then
        if (i >= 4) then
            table.insert(technology.prerequisites, "production-science-pack")
            table.insert(technology.prerequisites, "utility-science-pack")
            table.insert(technology.prerequisites, "space-science-pack")
            table.insert(technology.unit.ingredients, { "production-science-pack", 1 })
            table.insert(technology.unit.ingredients, { "utility-science-pack", 1 })
            table.insert(technology.unit.ingredients, { "space-science-pack", 1 })
            if (mods and mods["atan-nuclear-science"]) then
                table.insert(technology.prerequisites, "nuclear-science-pack")
                table.insert(technology.unit.ingredients, { "nuclear-science-pack", 1 })
            end
        end

        if (i >= 7) then
            table.insert(technology.prerequisites, "agricultural-science-pack")
            table.insert(technology.prerequisites, "electromagnetic-science-pack")
            table.insert(technology.prerequisites, "metallurgic-science-pack")
            table.insert(technology.unit.ingredients, { "agricultural-science-pack", 1 })
            table.insert(technology.unit.ingredients, { "electromagnetic-science-pack", 1 })
            table.insert(technology.unit.ingredients, { "metallurgic-science-pack", 1 })
        end

        if (i >= 9) then
            table.insert(technology.prerequisites, "cryogenic-science-pack")
            table.insert(technology.unit.ingredients, { "cryogenic-science-pack", 1 })
        end

        if (i >= 11) then
            table.insert(technology.prerequisites, "promethium-science-pack")
            table.insert(technology.unit.ingredients, { "promethium-science-pack", 1 })
        end
    end

    if (se_active) then
        if (i > 3) then
            table.insert(technology.prerequisites, "utility-science-pack")
        end
        if (i > 4) then
            table.insert(technology.prerequisites, "production-science-pack")
        end
        if (i == 6) then
            table.insert(technology.prerequisites, "se-astronomic-science-pack-1")
        end
        if (i == 7) then
            table.insert(technology.prerequisites, "se-astronomic-science-pack-2")
            table.insert(technology.prerequisites, "se-energy-science-pack-2")
        end
        if (i == 8) then
            table.insert(technology.prerequisites, "se-astronomic-science-pack-3")
            table.insert(technology.prerequisites, "se-energy-science-pack-3")
            table.insert(technology.prerequisites, "se-material-science-pack-3")
        end
        if (i >= 9) then
            table.insert(technology.prerequisites, "se-astronomic-science-pack-4")
            table.insert(technology.prerequisites, "se-energy-science-pack-4")
            table.insert(technology.prerequisites, "se-material-science-pack-4")
            table.insert(technology.prerequisites, "se-biological-science-pack-4")
        end
        if (i == 10) then
            table.insert(technology.prerequisites, "se-deep-space-science-pack-1")
        end
        -- if (i == 11) then
        --     table.insert(technology.prerequisites, "se-deep-space-science-pack-2")
        -- end
        -- if (i == 12) then
        --     table.insert(technology.prerequisites, "se-deep-space-science-pack-3")
        -- end
        -- if (i == 13) then
        --     table.insert(technology.prerequisites, "se-deep-space-science-pack-4")
        -- end
    end

    table.insert(ballistic_rocketry_and_logistics_levels, technology)
end

data:extend(ballistic_rocketry_and_logistics_levels)