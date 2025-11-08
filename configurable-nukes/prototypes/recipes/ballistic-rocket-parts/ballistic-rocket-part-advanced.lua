local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (not sa_active and not se_active) then
    return
end

local Util = require("__core__.lualib.util")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

-- INPUT_MULTIPLIER
local get_input_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER.name })
end
-- ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES
local get_ballistic_rocket_part_additional_crafting_machines = function ()
    local setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES.name].value
    end

    local crafting_machines = {}

    --[[ Looks for:
            >= 0 commas,
            >= 0 space characters,
            >= 1 alphanumerics/dashes/space characters,
            >= 0 space characters,
            >= 0 commas,
    ]]
    local search_pattern = ",*%s*([%w%-%s]+)%s*,*"
    local i, j, param = string.find(setting, search_pattern, 1)
    local possible_matches = {}
    local found_match = false

    local found_func = function(param, t, type)
        for _, j in pairs(t) do
            if (j.name == param) then
                found_match = true
                break
            elseif (j.name:find(param, 1, true)) then
                possible_matches[j.name] = { param = param, }
            end
        end
    end

    while param ~= nil do
        --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
        param = param:gsub("(%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false
            if (k == "recipe-category") then
                found_func(param, v, "recipe-category")
            end

            if (found_match) then break end
        end

        if (found_match) then table.insert(crafting_machines, param) end

        setting = string.sub(setting, j + 1, #setting)

        i, j, param = string.find(setting, search_pattern, 1)
    end

    -- if (#crafting_machines <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(crafting_machines, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    if (#crafting_machines <= 0) then crafting_machines = nil end

    return crafting_machines
end

local ingredients = {}
local ballistic_rocket_part_recipe_string = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.name })

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
local i, j, param, param_val = string.find(ballistic_rocket_part_recipe_string, search_pattern, 1)
local possible_matches = {}
local found_match = false
local ingredient_type = "item"

local found_func = function (param, param_val, t, type)
    for _, j in pairs(t) do
        if (j.name == param) then
            ingredient_type = type == "fluid" and "fluid" or "item"
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
        if (k == "ammo") then found_func(param, param_val, v, "ammo")
        elseif (k == "blueprint") then found_func(param, param_val, v, "blueprint")
        elseif (k == "blueprint-book") then found_func(param, param_val, v, "blueprint-book")
        elseif (k == "capsule") then found_func(param, param_val, v, "capsule")
        elseif (k == "gun") then found_func(param, param_val, v, "gun")
        elseif (k == "item")  then found_func(param, param_val, v, "item")
        elseif (k == "item-with-entity-data") then found_func(param, param_val, v, "item-with-entity-data")
        elseif (k == "fluid")  then found_func(param, param_val, v, "fluid")
        elseif (k == "module") then found_func(param, param_val, v, "module")
        elseif (k == "rail-planner") then found_func(param, param_val, v, "rail-planner")
        elseif (k == "repair-tool") then found_func(param, param_val, v, "repair-tool")
        elseif (k == "spidertron-remote") then found_func(param, param_val, v, "spidertron-remote")
        elseif (k == "tool") then found_func(param, param_val, v, "tool")
        elseif (k == "upgrade-item") then found_func(param, param_val, v, "upgrade-item")
        end

        if (found_match) then break end
    end

    if (found_match) then table.insert(ingredients, { type = ingredient_type or "item", name = param, amount = param_val * get_input_multiplier(), }) end

    ballistic_rocket_part_recipe_string = string.sub(ballistic_rocket_part_recipe_string, j + 1, #ballistic_rocket_part_recipe_string)

    i, j, param, param_val = string.find(ballistic_rocket_part_recipe_string, search_pattern, 1)
end

if (not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE.name })) then
    -- if (#ingredients <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(ingredients, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    if (#ingredients <= 0) then
        ingredients = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.ingredients
        if (ingredients) then for k, v in pairs(ingredients) do v.amount = v.amount * get_input_multiplier() end end
    end
end

local name_prefix = se_active and "se-" or ""

local rocket_part_recipe = data.raw["recipe"]["rocket-part"]
local ipbm_rocket_part_advanced = Util.table.deepcopy(rocket_part_recipe)

-- ipbm_rocket_part_advanced.name = "ipbm-rocket-part-advanced"
ipbm_rocket_part_advanced.name = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.recipe_name
ipbm_rocket_part_advanced.energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_TIME.name })
ipbm_rocket_part_advanced.ingredients = ingredients
ipbm_rocket_part_advanced.category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE.name })
ipbm_rocket_part_advanced.additional_categories = get_ballistic_rocket_part_additional_crafting_machines()
ipbm_rocket_part_advanced.hide_from_player_crafting = false
ipbm_rocket_part_advanced.auto_recycle = false
ipbm_rocket_part_advanced.overload_multiplier = 2
ipbm_rocket_part_advanced.allow_inserter_overload = true
ipbm_rocket_part_advanced.results = {{ type = "item", name = name_prefix .. "ipbm-rocket-part", amount = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RESULT_COUNT.name }) }}
ipbm_rocket_part_advanced.enabled = false
ipbm_rocket_part_advanced.order = "yzzz[ipbm-rocket-part-advanced]-yzzz[ipbm-rocket-part-advanced]"
ipbm_rocket_part_advanced.localised_name = { "recipe-name." .. name_prefix .. "ipbm-rocket-part-advanced" }

data:extend({ipbm_rocket_part_advanced})