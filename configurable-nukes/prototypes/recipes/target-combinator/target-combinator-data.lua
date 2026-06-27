local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

-- -- INPUT_MULTIPLIER
-- local get_input_multiplier = function ()
--     return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_INPUT_MULTIPLIER.name })
-- end
-- -- TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES
-- local get_target_combinator_additional_crafting_machines = function ()
--     local setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES.default_value

--     if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES.name]) then
--         setting = settings.startup[Startup_Settings_Constants.settings.TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES.name].value
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
-- local target_combinator_recipe_string = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE.name })

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
-- local i, j, param, param_val = target_combinator_recipe_string:find(search_pattern, 1)
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

--     target_combinator_recipe_string = target_combinator_recipe_string:sub(j + 1, #target_combinator_recipe_string)

--     i, j, param, param_val = target_combinator_recipe_string:find(search_pattern, 1)
-- end

-- if (not Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE_ALLOW_NONE.name })) then
--     -- if (#ingredients <= 0) then
--     --     for k, v in pairs(possible_matches) do
--     --         table.insert(ingredients, { type = "item", name = k, amount = v.param_val * get_input_multiplier(), })
--     --     end
--     -- end

--     if (#ingredients <= 0) then
--         ingredients = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE.ingredients
--         if (ingredients) then for k, v in pairs(ingredients) do v.amount = v.amount * get_input_multiplier() end end
--     end
-- end

local recipe_target_combinator =
{
    type = "recipe",
    name = "target-combinator",
    icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
    enabled = false,
    requester_paste_multiplier = 1,
    energy_required = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_CRAFTING_TIME.name }),
    -- ingredients = ingredients,
    ingredients = Setting_Utils.get_recipe_ingredients({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE,
        -- input_multiplier_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_INPUT_MULTIPLIER,
        -- allow_none_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE_ALLOW_NONE,
    }),
     results = Setting_Utils.get_recipe_results({
        recipe_setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_RESULTS,
    }) or {},
    category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_CRAFTING_MACHINE.name }),
    -- additional_categories = get_target_combinator_additional_crafting_machines(),
    additional_categories = Setting_Utils.get_additional_crafting_machines({
        default_value = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES.name }),
    }),
    subgroup = "circuit-network",
    auto_recycle = false,
}

data:extend({ recipe_target_combinator, })

--[[ program target-combinator ]]

-- data:extend({
--     -- {
--     --     type = "recipe",
--     --     name = "target-combinator-program",
--     --     icons = {
--     --         {
--     --             icon = "__base__/graphics/item-group/signals.png",
--     --             icon_size = 128,
--     --             shift = { -12, -12 },
--     --             scale = (1 / 4),
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
--     --             -- icon = "__base__/graphics/icons/constant-combinator.png",
--     --             -- icon_size = 173,
--     --             icon_size = 64,
--     --             scale = (1 / 2),
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
--     --     subgroup = "targeting",
--     --     enabled = false,
--     --     crafting_machine_tint = {
--     --         primary     = { r = 75,  g = 0,   b = 130, a = 0.8, }, -- (Deep Indigo)
--     --         secondary   = { r = 93,  g = 63,  b = 211, a = 0.7, }, -- (Quantum Indigo)
--     --         tertiary    = { r = 38,  g = 43,  b = 226, a = 0.6, }, -- (Violet)
--     --         quaternary  = { r = 0,   g = 255, b = 255, a = 0.4, }, -- (Electric Cyan)
--     --     },
--     --     hide_from_player_crafting = true,
--     --     hide_rom_flow_stats = true,
--     --     hide_from_signal_gui = false,
--     --     energy_required = 10,
--     --     ingredients = {
--     --         { type = "item", name = "processing-unit", amount = 2, },
--     --     },
--     --     results = {
--     --         { type = "item", name = "processing-unit", amount = 1, show_details_in_recipe_tooltip = false, },
--     --         { type = "item", name = "processing-unit", amount = 1, probability = 0.5, show_details_in_recipe_tooltip = false, },
--     --     },
--     --     allow_speed = false,
--     --     allow_productivity = false,
--     --     allow_quality = false,
--     --     allowed_module_categories = { "efficiency", },
--     -- },
--     -- {
--     --     type = "recipe",
--     --     name = "target-combinator-reformat-slow",
--     --     icons = {
--     --         {
--     --             icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
--     --             icon_size = 64,
--     --             scale = (1 / 2),
--     --             shift = { -12, -12 },
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__base__/graphics/item-group/signals.png",
--     --             icon_size = 128,
--     --             shift = { -12, -12 },
--     --             scale = (1 / 4),
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__base__/graphics/icons/signal/signal-recycle.png",
--     --             icon_size = 64,
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
--     --     category = "chemistry",
--     --     additional_categories = sa_active and { "electromagnetics", } or se_active and { "space-electromagnetics", } or nil,
--     --     subgroup = "reformatting",
--     --     enabled = false,
--     --     crafting_machine_tint = {
--     --         primary     = { r = 64,  g = 224, b = 208, a = 0.6, }, -- (Muted Aqua)
--     --         secondary   = { r = 224, g = 255, b = 255, a = 0.4, }, -- (Light Cyan)
--     --         tertiary    = { r = 175, g = 238, b = 238, a = 0.3, }, -- (Pale Blue)
--     --         quaternary  = { r = 255, g = 255, b = 255, a = 0.2, }, -- (White)
--     --     },
--     --     hide_from_player_crafting = true,
--     --     hide_rom_flow_stats = true,
--     --     hide_from_signal_gui = false,
--     --     energy_required = 120,
--     --     emissions_multiplier = 1,
--     --     ingredients = {
--     --         { type = "item",  name = "target-combinator", amount = 1, },
--     --         { type = "fluid", name = "water", amount = 504, },
--     --     },
--     --     results = {
--     --         { type = "item",  name = "target-combinator", amount = 1, probability = 0.999, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "uranium-ore", amount = 1, probability = 0.007, show_details_in_recipe_tooltip = false, },
--     --         { type = "fluid", name = "water", amount_min = 380, amount_max = 460, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
--     --         { type = "fluid", name = "steam", amount_min = 340, amount_max = 500, temperature = 165, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
--     --     },
--     --     allow_productivity = false,
--     -- },
--     -- {
--     --     type = "recipe",
--     --     name = "target-combinator-reformat-dirty",
--     --     icons = {
--     --         {
--     --             icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
--     --             icon_size = 64,
--     --             scale = (1 / 2),
--     --             shift = { -12, -12 },
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__base__/graphics/item-group/signals.png",
--     --             icon_size = 128,
--     --             shift = { -12, -12 },
--     --             scale = (1 / 4),
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__base__/graphics/icons/signal/signal-recycle.png",
--     --             icon_size = 64,
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
--     --     category = sa_active and "chemistry-or-cryogenics" or "chemistry",
--     --     subgroup = "reformatting",
--     --     enabled = false,
--     --     crafting_machine_tint = {
--     --         primary     = { r = 60,  g = 45,  b = 30,  a = 0.9, }, -- (Deep Muddy Brown)
--     --         secondary   = { r = 20,  g = 20,  b = 20,  a = 0.8, }, -- (Near-Black Umber)
--     --         tertiary    = { r = 160, g = 140, b = 100, a = 0.6, }, -- (Sandy Tan/Ochre)
--     --         quaternary  = { r = 210, g = 210, b = 0,   a = 0.3, }, -- (Sulfur Yellow)
--     --     },
--     --     hide_from_player_crafting = true,
--     --     hide_rom_flow_stats = true,
--     --     hide_from_signal_gui = false,
--     --     emissions_multiplier = 5/3,
--     --     energy_required = 12,
--     --     ingredients = {
--     --         { type = "item",  name = "target-combinator", amount = 1, },
--     --         { type = "item",  name = "stone", amount = 18, },
--     --         { type = "fluid", name = "water", amount = 504, },
--     --     },
--     --     results = {
--     --         { type = "item",  name = "target-combinator", amount = 1, probability = 0.79, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "uranium-ore", amount = 1, probability = 0.007, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "stone", amount_min = 0, amount_max = 4, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "raw-fish", amount = 1, probability = (1/42)/42, show_details_in_recipe_tooltip = false, },
--     --         { type = "fluid", name = "water", amount_min = 50, amount_max = 80, show_details_in_recipe_tooltip = false, },
--     --         { type = "fluid", name = "crude-oil", amount_min = 38, amount_max = 46, probability = 0.042, show_details_in_recipe_tooltip = false, },
--     --     },
--     -- },
--     -- {
--     --     type = "recipe",
--     --     name = "target-combinator-reformat-acid",
--     --     icons = {
--     --         {
--     --             icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
--     --             -- icon = "__base__/graphics/icons/constant-combinator.png",
--     --             -- icon_size = 173,
--     --             icon_size = 64,
--     --             scale = (1 / 2),
--     --             shift = { -12, -12 },
--     --             draw_background = true,
--     --         },
--     --         {
--     --             icon = "__base__/graphics/item-group/signals.png",
--     --             icon_size = 128,
--     --             shift = { -12, -12 },
--     --             scale = (1 / 4),
--     --             draw_background = true,
--     --         },
--     --         {
--     --             -- icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png",
--     --             icon = "__base__/graphics/icons/signal/signal-recycle.png",
--     --             -- icon_size = 173,
--     --             icon_size = 64,
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
--     --     category = sa_active and "organic-or-chemistry" or "chemistry",
--     --     subgroup = "reformatting",
--     --     enabled = false,
--     --     crafting_machine_tint = {
--     --         primary     = { r = 75,  g = 0,   b = 130, a = 0.8, }, -- (Deep Indigo)
--     --         secondary   = { r = 93,  g = 63,  b = 211, a = 0.7, }, -- (Quantum Indigo)
--     --         tertiary    = { r = 38,  g = 43,  b = 226, a = 0.6, }, -- (Violet)
--     --         quaternary  = { r = 0,   g = 255, b = 255, a = 0.4, }, -- (Electric Cyan)
--     --     },
--     --     hide_from_player_crafting = true,
--     --     hide_rom_flow_stats = true,
--     --     hide_from_signal_gui = false,
--     --     energy_required = 24,
--     --     emissions_multiplier = 1.05,
--     --     ingredients = {
--     --         { type = "item",  name = "target-combinator", amount = 1, },
--     --         { type = "fluid", name = "sulfuric-acid", amount = 280, },
--     --             sa_active
--     --         and { type = "item", name = "carbon", amount = 8, }
--     --         or  { type = "item", name = "coal",   amount = 8, },
--     --             sa_active
--     --         and { type = "item", name = "calcite", amount = 6, }
--     --         or  { type = "item", name = "stone",   amount = 12, },
--     --     },
--     --     results = {
--     --         { type = "item",  name = "target-combinator", amount = 1, probability = 0.958, ignored_by_productivity = 2 ^ 16 - 1, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "uranium-ore", amount = 1, probability = 0.007, show_details_in_recipe_tooltip = false, },
--     --         { type = "item",  name = "sulfur", amount_min = 0, amount_max = 10, probability = 2/3, },
--     --         { type = "fluid", name = "water",  amount = 90, show_details_in_recipe_tooltip = false, },
--     --         { type = "fluid", name = "water",  amount_min = 40, amount_max = 80, probability = 0.7, show_details_in_recipe_tooltip = false, },
--     --             sa_active
--     --         and { type = "item", name = "calcite", amount_min = 1, amount_max = 2, probability = 0.84, show_details_in_recipe_tooltip = false, }
--     --         or  { type = "item", name = "stone",   amount_min = 1, amount_max = 4, probability = 0.84, show_details_in_recipe_tooltip = false, },
--     --     },
--     -- },
-- })