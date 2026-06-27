local tonumber = tonumber
local type = type

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local possible_item_types = {
    ["ammo"] = 1,
    ["blueprint"] = 1,
    ["blueprint-book"] = 1,
    ["capsule"] = 1,
    ["gun"] = 1,
    ["item"] = 1,
    ["item-with-label"] = 1,
    ["item-with-tags"] = 1,
    ["item-with-inventory"] = 1,
    ["item-with-entity-data"] = 1,
    ["fluid"] = 1,
    ["module"] = 1,
    ["rail-planner"] = 1,
    ["repair-tool"] = 1,
    ["spidertron-reote"] = 1,
    ["armor"] = 1,
    ["tool"] = 1,
    ["upgrade-item"] = 1,
}

local settings_utils = {}

function settings_utils.get_additional_crafting_machines(params)
    params = params or {}

    local crafting_machines = {}

    local default_value = params.default_value
    if (type(default_value) ~= "string" or default_value:gsub("%s", "") == "") then return crafting_machines end

    --[[ Looks for:
            >= 0 commas,
            >= 0 space characters,
            >= 1 alphanumerics/dashes/space characters,
            >= 0 space characters,
            >= 0 commas,
    ]]
    local search_pattern = ",*%s*([%w%-%s]+)%s*,*"
    local i, j, param = string.find(default_value, search_pattern, 1)
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
        param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false
            if (k == "recipe-category") then
                found_func(param, v, "recipe-category")
            end

            if (found_match) then break end
        end

        if (found_match) then table.insert(crafting_machines, param) end

        default_value = string.sub(default_value, j + 1, #default_value)

        i, j, param = string.find(default_value, search_pattern, 1)
    end

    -- if (#crafting_machines <= 0) then
    --     for k, v in pairs(possible_matches) do
    --         table.insert(crafting_machines, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
    --     end
    -- end

    if (#crafting_machines <= 0) then crafting_machines = nil end

    return crafting_machines
end

function settings_utils.get_recipe_ingredients(params)
    -- log(serpent.block(params))
    params = params or {}

    local ingredients = params.ingredients or {}

    local recipe_setting = params.recipe_setting
    if (not recipe_setting or type(recipe_setting) ~= "table") then return ingredients end

    local input_multiplier = 1

    local recipe_string = Data_Utils.get_startup_setting({ setting = recipe_setting.name })

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
    local i, j, param, param_val = recipe_string:find(search_pattern, 1)
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
        param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false

            if (possible_item_types[k]) then found_func(param, param_val, v, k) end

            if (found_match) then break end
        end

        if (found_match) then table.insert(ingredients, { type = ingredient_type or "item", name = param, amount = param_val * input_multiplier, }) end

        recipe_string = recipe_string:sub(j + 1, #recipe_string)

        i, j, param, param_val = recipe_string:find(search_pattern, 1)
    end

    return ingredients
end

function settings_utils.get_recipe_results(params)
    -- log(serpent.block(params))
    params = params or {}

    local results = params.results or {}

    local recipe_setting = params.recipe_setting
    if (not recipe_setting or type(recipe_setting) ~= "table") then return results end

    local input_multiplier = 1

    local recipe_string = Data_Utils.get_startup_setting({ setting = recipe_setting.name })

    --[[ Looks for:
            >= 0 commas,
            >= 0 space characters,
            >= 1 alphanumerics/dashes/space characters,
            >= 0 space characters,
            == 1 equals,
            >= 0 space characters,
            >= 1 digits,
            >= 0 space characters,
            >= 0 dashes,
            >= 0 digits
            >= 0 % sign
            >= 0 space characters,
            >= 0 digits
            >= 0 commas,
            >= 0 space characters,
    ]]
    local search_pattern = ",*%s*([%w%-%s]+)%s*=%s*(%d+)%s*%-*(%d*)%s*%%*%s*([%d%.]*)%s*({*),*"
    local params_pattern = ",*%s*([%w%-%s]+)%s*=%s*(%d+)%s*%-*(%d*)%s*%%*%s*([%d%.]*)%s*(%b{}),*"
    local i, j, param, param_val, param_max, param_probability, param_params = recipe_string:find(search_pattern, 1)
    if (param_params and param_params ~= "") then
        _, _, _, _, param_params = recipe_string:match(params_pattern)
    end
    local possible_matches = {}
    local found_match = false
    local ingredient_type = "item"

    local function found_func(param, param_val, t, type)
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

    local ignored_by_productivity = params.ignored_by_productivity or {}

    while param ~= nil and param_val ~= nil do

        --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
        param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

        for k, v in pairs(data.raw) do
            found_match = false

            if (possible_item_types[k]) then found_func(param, param_val, v, k) end

            if (found_match) then break end
        end

        if (found_match) then
            local param_temp = param_params and param_params ~= "" and param_params:match("temperature=([%d%.]+)[Cc]*")
            local param_spoiled = param_params and param_params ~= "" and param_params:match("percent_spoiled=([%d%.]+)")

            if (ignored_by_productivity[param]) then
                table.insert(results,
                        type(tonumber(param_max)) == "number"
                    and {
                            type = ingredient_type or "item",
                            name = param,
                            amount_min = param_val * input_multiplier,
                            amount_max = param_max * input_multiplier,
                            probability = (tonumber(param_probability) or 100) / 100,
                            show_details_in_recipe_tooltip = false,
                            ignored_by_productivity = ignored_by_productivity[param].val or 2 ^ 16 - 1,
                            temperature = ingredient_type == "fluid" and tonumber(param_temp) or nil,
                            percent_spoiled = param_spoiled and (tonumber(param_spoiled) or 0) / 100 or nil,
                        }
                    or
                        {
                            type = ingredient_type or "item",
                            name = param, amount = param_val * input_multiplier,
                            probability = (tonumber(param_probability) or 100) / 100,
                            show_details_in_recipe_tooltip = false,
                            ignored_by_productivity = ignored_by_productivity[param].val or 2 ^ 16 - 1,
                            temperature = ingredient_type == "fluid" and tonumber(param_temp) or nil,
                            percent_spoiled = param_spoiled and (tonumber(param_spoiled) or 0) / 100 or nil,
                        }
                )
            else
                table.insert(results,
                        type(tonumber(param_max)) == "number"
                    and {
                            type = ingredient_type or "item",
                            name = param,
                            amount_min = param_val * input_multiplier,
                            amount_max = param_max * input_multiplier,
                            probability = (tonumber(param_probability) or 100) / 100,
                            show_details_in_recipe_tooltip = false,
                            temperature = ingredient_type == "fluid" and tonumber(param_temp) or nil,
                            percent_spoiled = param_spoiled and (tonumber(param_spoiled) or 0) / 100 or nil,
                        }
                    or
                        {
                            type = ingredient_type or "item",
                            name = param,
                            amount = param_val * input_multiplier,
                            probability = (tonumber(param_probability) or 100) / 100,
                            show_details_in_recipe_tooltip = false,
                            temperature = ingredient_type == "fluid" and tonumber(param_temp) or nil,
                            percent_spoiled = param_spoiled and (tonumber(param_spoiled) or 0) / 100 or nil,
                        }
                )
            end

        end

        recipe_string = recipe_string:sub(j + 1, #recipe_string)

        i, j, param, param_val, param_max, param_probability, param_params = recipe_string:find(search_pattern, 1)
        if (param_params and param_params ~= "") then
            _, _, _, _, param_params = recipe_string:match(params_pattern)
        end
    end

    return results
end

function settings_utils.get_research_prerequisites(params)
    if (type(params) ~= "table") then return end
    if (type(params.setting) ~= "table") then return end

    local setting = params.setting.default_value

    if (params.setting.name and settings and settings.startup and settings.startup[params.setting.name]) then
        setting = settings.startup[params.setting.name].value
    end
    setting = setting or ""

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

    if (#prerequisites <= 0) then
        prerequisites = params.setting.prerequisites or {}
    end

    return prerequisites
end

function settings_utils.get_research_ingredients(params)
    if (type(params) ~= "table") then return end
    if (type(params.setting) ~= "table") then return end

    local setting = params.setting.default_value

    if (params.setting.name and settings and settings.startup and settings.startup[params.setting.name]) then
        setting = settings.startup[params.setting.name].value
    end
    setting = setting or ""

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

    if (#ingredients <= 0) then
        ingredients = params.setting.ingredients or {}
    end

    return ingredients
end


return settings_utils