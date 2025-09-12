local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

-- CRAFTING_TIME
local get_crafting_time = function ()
    local setting = 50

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_TIME.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_TIME.name].value
    end

    return setting
end
-- INPUT_MULTIPLIER
local get_input_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_INPUT_MULTIPLIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_INPUT_MULTIPLIER.name].value
    end

    return setting
end
-- RESULT_COUNT
local get_result_count = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULT_COUNT.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULT_COUNT.name].value
    end

    return setting
end
-- ATOMIC_BOMB_RECIPE
local get_atomic_bomb_recipe_string = function ()
    local setting = ""

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE.name].value
    end

    return setting
end
-- ATOMIC_BOMB_RECIPE_ALLOW_NONE
local get_atomic_bomb_recipe_allow_none = function ()
    local setting = false

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE_ALLOW_NONE.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE_ALLOW_NONE.name].value
    end

    return setting
end

local ingredients = {}
local atomic_bomb_recipe_string = get_atomic_bomb_recipe_string()

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
local i, j, param, param_val = atomic_bomb_recipe_string:find(search_pattern, 1)
local possible_matches = {}
local found_match = false

local found_func = function (param, param_val, t, type)
    for _, j in pairs(t) do
        if (j.name == param) then
            found_match = true
            -- log("found " .. type .."; breaking")
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
        elseif (k == "module") then found_func(param, param_val, v, "module")
        elseif (k == "rail-planner") then found_func(param, param_val, v, "rail-planner")
        elseif (k == "repair-tool") then found_func(param, param_val, v, "repair-tool")
        elseif (k == "spidertron-remote") then found_func(param, param_val, v, "spidertron-remote")
        elseif (k == "tool") then found_func(param, param_val, v, "tool")
        elseif (k == "upgrade-item") then found_func(param, param_val, v, "upgrade-item")
        end

        if (found_match) then log("found match; breaking"); break end
    end

    if (found_match) then table.insert(ingredients, { type = "item", name = param, amount = param_val * get_input_multiplier(), }) end

    atomic_bomb_recipe_string = atomic_bomb_recipe_string:sub(j + 1, #atomic_bomb_recipe_string)

    i, j, param, param_val = atomic_bomb_recipe_string:find(search_pattern, 1)
end

if (not get_atomic_bomb_recipe_allow_none()) then
    -- if (#ingredients <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(ingredients, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    if (#ingredients <= 0) then
        ingredients =
        {
            { type = "item", name = "processing-unit", amount = 10 * get_input_multiplier() },
            { type = "item", name = "explosives", amount = 10 * get_input_multiplier() },
            { type = "item", name = "uranium-235", amount = (mods and mods["space-age"] and 100 or 30) * get_input_multiplier() }
        }
    end
end

local recipe_atomic_bomb =
{
    type = "recipe",
    name = "atomic-bomb",
    enabled = false,
    energy_required = get_crafting_time(),
    ingredients = ingredients,
    results = {{ type = "item", name = "atomic-bomb", amount = get_result_count() }}
}

data:extend({recipe_atomic_bomb})