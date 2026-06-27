local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

-- -- INPUT_MULTIPLIER
-- local get_input_multiplier = function ()
--     return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_INPUT_MULTIPLIER.name })
-- end
-- -- PAYLOADER_ADDITIONAL_CRAFTING_MACHINES
-- local get_payloader_additional_crafting_machines = function ()
--     local setting = Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES.default_value

--     if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES.name]) then
--         setting = settings.startup[Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES.name].value
--     end

--     local crafting_machines = {}

--     --[[ Looks for:
--             >= 0 commas,
--             >= 0 space characters,
--             >= 1 alphanumerics/dashes/space characters,
--             >= 0 space characters,
--             >= 0 commas,
--     ]]
--     local search_pattern = ",*%s*([%w%-%s]+)%s*,*"
--     local i, j, param = string.find(setting, search_pattern, 1)
--     local possible_matches = {}
--     local found_match = false

--     local found_func = function(param, t, type)
--         for _, j in pairs(t) do
--             if (j.name == param) then
--                 found_match = true
--                 break
--             elseif (j.name:find(param, 1, true)) then
--                 possible_matches[j.name] = { param = param, }
--             end
--         end
--     end

--     while param ~= nil do
--         --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
--         param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

--         for k, v in pairs(data.raw) do
--             found_match = false
--             if (k == "recipe-category") then
--                 found_func(param, v, "recipe-category")
--             end

--             if (found_match) then break end
--         end

--         if (found_match) then table.insert(crafting_machines, param) end

--         setting = string.sub(setting, j + 1, #setting)

--         i, j, param = string.find(setting, search_pattern, 1)
--     end

--     -- if (#crafting_machines <= 0) then
--     --     for k, v in pairs(possible_matches) do
--     --         table.insert(crafting_machines, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
--     --     end
--     -- end

--     if (#crafting_machines <= 0) then crafting_machines = nil end

--     return crafting_machines
-- end

-- local ingredients = {}
-- local payloader_recipe_string = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_RECIPE.name })

-- --[[ Looks for:
--         >= 0 commas,
--         >= 0 space characters,
--         >= 1 alphanumerics/dashes/space characters,
--         >= 0 space characters,
--         == 1 equals,
--         >= 0 space characters,
--         >= 1 digits,
--         >= 0 space characters,
--         >= 0 commas,
--         >= 0 space characters,
-- ]]
-- local search_pattern = ",*%s*([%w%-%s]+)%s*=%s*(%d+)%s*,*"
-- local i, j, param, param_val = payloader_recipe_string:find(search_pattern, 1)
-- local possible_matches = {}
-- local found_match = false
-- local ingredient_type = "item"

-- local found_func = function (param, param_val, t, type)
--     for _, j in pairs(t) do
--         if (j.name == param) then
--             ingredient_type = type == "fluid" and "fluid" or "item"
--             found_match = true
--             break
--         elseif (j.name:find(param, 1, true)) then
--             possible_matches[j.name] = { param = param, param_val = param_val, }
--         end
--     end
-- end

-- while param ~= nil and param_val ~= nil do

--     --[[ Replace space characters with a dash; remove any prefixed dashes; remove any postfixed dashes ]]
--     param = param:gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", "")

--     for k, v in pairs(data.raw) do
--         found_match = false
--         if (k == "ammo") then found_func(param, param_val, v, "ammo")
--         elseif (k == "blueprint") then found_func(param, param_val, v, "blueprint")
--         elseif (k == "blueprint-book") then found_func(param, param_val, v, "blueprint-book")
--         elseif (k == "capsule") then found_func(param, param_val, v, "capsule")
--         elseif (k == "gun") then found_func(param, param_val, v, "gun")
--         elseif (k == "item")  then found_func(param, param_val, v, "item")
--         elseif (k == "item-with-label")  then found_func(param, param_val, v, "item-with-label")
--         elseif (k == "item-with-tags")  then found_func(param, param_val, v, "item-with-tags")
--         elseif (k == "item-with-inventory")  then found_func(param, param_val, v, "item-with-inventory")
--         elseif (k == "item-with-entity-data") then found_func(param, param_val, v, "item-with-entity-data")
--         elseif (k == "fluid")  then found_func(param, param_val, v, "fluid")
--         elseif (k == "module") then found_func(param, param_val, v, "module")
--         elseif (k == "rail-planner") then found_func(param, param_val, v, "rail-planner")
--         elseif (k == "repair-tool") then found_func(param, param_val, v, "repair-tool")
--         elseif (k == "spidertron-remote") then found_func(param, param_val, v, "spidertron-remote")
--         elseif (k == "armor") then found_func(param, param_val, v, "armor")
--         elseif (k == "tool") then found_func(param, param_val, v, "tool")
--         elseif (k == "upgrade-item") then found_func(param, param_val, v, "upgrade-item")
--         end

--         if (found_match) then break end
--     end

--     if (found_match) then table.insert(ingredients, { type = ingredient_type or "item", name = param, amount = param_val * get_input_multiplier(), }) end

--     payloader_recipe_string = payloader_recipe_string:sub(j + 1, #payloader_recipe_string)

--     i, j, param, param_val = payloader_recipe_string:find(search_pattern, 1)
-- end

-- if (not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_RECIPE_ALLOW_NONE.name })) then
--     -- if (#ingredients <= 0) then
--     --     for k, v in pairs(possible_matches) do
--     --         table.insert(ingredients, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
--     --     end
--     -- end

--     if (#ingredients <= 0) then
--         ingredients = Startup_Settings_Constants.settings.PAYLOADER_RECIPE.ingredients
--         if (ingredients) then for k, v in pairs(ingredients) do v.amount = v.amount * get_input_multiplier() end end
--     end
-- end

local recipe_payloader =
{
    type = "recipe",
    name = "payloader",
    icon = "__configurable-nukes__/graphics/icons/payloader/payloader.png",
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_MACHINE.name }),
    subgroup = "production-machine",
    enabled = false,
    requester_paste_multiplier = 1,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_TIME.name }),
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOADER_RECIPE,
    }) or Startup_Settings_Constants.settings.PAYLOADER_RECIPE.ingredients,
    results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.PAYLOADER_RESULTS,
    }) or Startup_Settings_Constants.settings.PAYLOADER_RESULTS.results,
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
}

data:extend({recipe_payloader})

--[[ payloader recipes ]]

-- data:extend({
--     -- {
--     --     type = "recipe",
--     --     name = "payload-add",
--     --     icons = {
--     --         {
--     --             icon = "__base__/graphics/item-group/military.png",
--     --             icon_size = 128,
--     --             shift = { -12, -12 },
--     --             scale = (1 / 4),
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
--     --             icon_size = 173,
--     --             shift = { 6, 6 },
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__configurable-nukes__/graphics/technology/object-to-object-arrow.png",
--     --             icon_size = 256,
--     --             shift = { -2, -2 },
--     --             scale = (1 / 5),
--     --             floating = true,
--     --         },
--     --     },
--     --     icon_size = 64,
--     --     category = "payload-change",
--     --     subgroup = "payload",
--     --     enabled = false,
--     --     hide_from_player_crafting = true,
--     --     hide_rom_flow_stats = true,
--     --     hide_from_signal_gui = false,
--     --     energy_required = 4,
--     --     ingredients = {
--     --         { type = "item", name = "steel-plate", amount = 2, },
--     --         { type = "item", name = "advanced-circuit", amount = 1, },
--     --     },
--     --     results = {},
--     -- },
--     {
--         type = "recipe",
--         -- name = "payload-remove",
--         name = "payloader-unload",
--         icons = {
--             {
--                 -- icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
--                 -- icon_size = 173,
--                 icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
--                 icon_size = 64,
--                 shift = { -12, -12 },
--                 scale = (1 / 1.5),
--                 draw_background = true,
--             },
--             {
--                 icon = "__base__/graphics/item-group/military.png",
--                 icon_size = 128,
--                 shift = { 6, 6 },
--                 draw_background = true,
--             },
--             {
--                 icon = "__configurable-nukes__/graphics/technology/object-to-object-arrow.png",
--                 icon_size = 256,
--                 shift = { -2, -2 },
--                 scale = (1 / 5),
--                 floating = true,
--             },
--         },
--         icon_size = 64,
--         category = "payload-change",
--         subgroup = "payload",
--         enabled = false,
--         hide_from_player_crafting = true,
--         hide_rom_flow_stats = true,
--         hide_from_signal_gui = false,
--         energy_required = 9,
--         ingredients = {},
--         results = {},
--     },
-- })