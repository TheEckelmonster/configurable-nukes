local mods = mods

local blacklist = CN_Containment_Canister and CN_Containment_Canister.blacklist or {}

local kg = kg or 1000

local Util = require("__core__.lualib.util")

local __Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local __Data_Utils = require("data-utils")

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = {max_count = 1, remove = true},
    }
end

local Item_Sounds = {
    metal_barrel_inventory_move = item_sound("metal-barrel-inventory-move.ogg", 0.5),
    metal_barrel_inventory_pickup = item_sound("metal-barrel-inventory-pickup.ogg", 0.5),
    energy_shield_inventory_move = item_sound("energy-shield-inventory-move.ogg", 0.4),
    energy_shield_inventory_pickup = item_sound("energy-shield-inventory-pickup.ogg", 0.4),
}

local function normalize_color(tint)
    tint = tint or {}
    tint = {
        [tint.r and "r" or tint[1] and 1 or "r"] = tint.r or tint[1] or 0,
        [tint.g and "g" or tint[2] and 2 or "g"] = tint.g or tint[2] or 0,
        [tint.b and "b" or tint[3] and 3 or "b"] = tint.b or tint[3] or 0,
        [tint.a and "a" or tint[4] and 4 or "a"] = tint.a or tint[4] or 1,
    }

    if (tint.r) then
        while type(tint.r) == "number" and tint.r > 255 do tint.r = tint.r / 255 end
        while type(tint.g) == "number" and tint.g > 255 do tint.g = tint.g / 255 end
        while type(tint.b) == "number" and tint.b > 255 do tint.b = tint.b / 255 end
        while type(tint.a) == "number" and tint.a > 255 do tint.a = tint.a / 255 end
    elseif (tint[1]) then
        while type(tint[1]) == "number" and tint[1] > 255 do tint[1] = tint[1] / 255 end
        while type(tint[2]) == "number" and tint[2] > 255 do tint[2] = tint[2] / 255 end
        while type(tint[3]) == "number" and tint[3] > 255 do tint[3] = tint[3] / 255 end
        while type(tint[4]) == "number" and tint[4] > 255 do tint[4] = tint[4] / 255 end
    end

    return tint
end

-- The technology the CC unlocks will be added to
local technology_name = {
    "cn-containment-canister",
    "cn-containment-canister-2",
}

-- The base empty CC item
local empty_CC_name = "cn-containment-canister"

-- Alpha used for CC masks
-- local mask_alpha = 0.75
local mask_alpha = 1
-- Fluid required per CC recipe
local function fluid_per_CC(Startup_Settings_Constants)
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.CONTAINMENT_CANISTER_CAPACITY.name }) or (5 * 50)
end

-- Crafting energy per CC fill recipe
local energy_per_fill = 3.75 * 0.2
-- Crafting energy per CC empty recipe
local energy_per_empty = 3.75 * 0.2

local energy_shield_inputs = {
    {
        { type = "item",  name = "battery", amount = 1, ignored_by_stats = 1, },
    },
    {
        { type = "item",  name = "supercapacitor", amount = 1, ignored_by_stats = 1, },
    },
}

local energy_shield_outputs = {
    {
        { type = "item",  name = "battery", amount = 1, ignored_by_stats = 1, },
    },
    {
        { type = "item",  name = "supercapacitor", amount = 1, ignored_by_stats = 1, },
    },
}

local function generate_CC_item_icons(fluid, tint)
    return {
        { icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister.png", icon_size = 64, },
        { icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister-mask.png", icon_size = 64, tint = tint or Util.get_color_with_alpha(fluid.base_color, mask_alpha, true), },
    }
end

local function generate_CC_recipe_icons(fluid, tint, fluid_icon_shift)
    local icons = {
        { icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister.png", icon_size = 64, },
        { icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister-mask.png", icon_size = 64, tint = tint or Util.get_color_with_alpha(fluid.base_color, mask_alpha, true), },
    }

    if (fluid.icon) then
        table.insert(icons,
            {
                icon = fluid.icon,
                icon_size = (fluid.icon_size or defines.default_icon_size),
                scale = 16.0 / (fluid.icon_size or defines.default_icon_size), -- scale = 0.5 * 32 / icon_size simplified
                shift = fluid_icon_shift
            }
        )
    elseif fluid.icons then
        icons = util.combine_icons(icons, fluid.icons, { scale = 0.5, shift = fluid_icon_shift }, fluid.icon_size or defines.default_icon_size)
    end

    return icons
end

-- Adds the provided CC recipe and fill/empty recipes to the technology as recipe unlocks if they don't already exist
local function add_CC_to_technology(fill_recipe, empty_recipe, technology)
    if (not technology) then return end

    local unlock_key = "unlock-recipe"

    technology.effects = technology.effects or {}
    local effects = technology.effects

    local add_fill_recipe = true
    local add_empty_recipe = true

    for k, v in pairs(effects) do
        if (k == unlock_key) then
            local recipe = v.recipe
            if (not fill_recipe or recipe == fill_recipe.name) then
                add_fill_recipe = false
            elseif (not empty_recipe or recipe == empty_recipe.name) then
                add_empty_recipe = false
            end
        end
    end

    if (fill_recipe and add_fill_recipe)   then table.insert(effects, { type = unlock_key, recipe = fill_recipe.name })  end
    if (empty_recipe and add_empty_recipe) then table.insert(effects, { type = unlock_key, recipe = empty_recipe.name }) end
end

local function create_CC_item(fluid, optionals)
    if (not fluid or type(fluid) ~= "table") then return end

    optionals = optionals or {}

    local name = fluid.name .. (optionals.temperature and ("-" .. optionals.temperature) or "") .. "-cn-containment-canister"

    return
    {
        type = "item",
        name = name,
        localised_name = {"item-name.filled-cn-containment-canister", (fluid.localised_name or {"fluid-name." .. fluid.name}), (optionals.temperature and (" (" .. optionals.temperature .. ")") or ""),},
        icons = generate_CC_item_icons(fluid),
        -- enabled = true,
        enabled = false,
        icon_size = 64,
        subgroup = "containment-canister",
        order = "a[basic-intermediates]-c[filled-containment-canister]-" .. (fluid.order or ("[" .. fluid.name ..  "]")),
        weight = 2*10*kg,
        inventory_move_sound = Item_Sounds.energy_shield_inventory_move,
        pick_sound = Item_Sounds.energy_shield_inventory_pickup,
        drop_sound = Item_Sounds.energy_shield_inventory_move,
        stack_size = 10/2,
        hidden = blacklist[fluid.name],
        hidden_in_factoriopedia = blacklist[fluid.name],
    }
end

local function create_fill_CC_recipe(fluid, tints, optionals, Startup_Settings_Constants)
    if (not fluid or type(fluid) ~= "table") then return end
    Startup_Settings_Constants = Startup_Settings_Constants or __Startup_Settings_Constants

    optionals = optionals or {}

    tints = tints or {
        Util.get_color_with_alpha(fluid.base_color, mask_alpha, true),
        Util.get_color_with_alpha(fluid.flow_color, mask_alpha, true),
    }

    local auto_barrel = type(fluid.auto_barrel) == "boolean" and not fluid.auto_barrel and 2 or 1

    local name = fluid.name .. (optionals.temperature and ("-" .. optionals.temperature) or "") .. "-cn-containment-canister"

    return
    {
        type = "recipe",
        name = name,
        localised_name = { "recipe-name.fill-cn-containment-canister", fluid.localised_name or { "fluid-name." .. fluid.name, }, },
        category = "chemistry",
        energy_required = energy_per_fill,
        subgroup = "fill-containment-canister",
        order = "a[basic-intermediates]-c[filled-containment-canister]-" .. (fluid.order or ("[" .. fluid.name ..  "]")),
        enabled = false,
        icons = generate_CC_recipe_icons(fluid, nil, {-12, -12}),
        ingredients =
        {
            { type = "fluid", name = fluid.name,    amount = fluid_per_CC(Startup_Settings_Constants), temperature = tonumber(optionals.temperature) and optionals.temperature or nil, ignored_by_stats = fluid_per_CC(Startup_Settings_Constants), },
            { type = "item",  name = empty_CC_name, amount = 1, ignored_by_stats = 1, },
            __Data_Utils.unpack(energy_shield_inputs[auto_barrel]),
        },
        results =
        {
            { type = "item", name = name, amount = 1, ignored_by_stats = 1, },
        },
        allow_quality = false,
        allow_decomposition = false,
        allow_productivity = false,
        hide_from_player_crafting = true,
        factoriopedia_alternative = "cn-containment-canister",
        hide_from_signal_gui = false,
        crafting_machine_tint = {
            primary = tints[1],
            secondary = tints[2],
            tertiary = normalize_color(Util.mix_color(tints[1], tints[2])),
        },
        hidden = blacklist[fluid.name],
        hidden_in_factoriopedia = blacklist[fluid.name],
    }
end

local function create_empty_CC_recipe(fluid, tints, optionals, Startup_Settings_Constants)
    if (not fluid or type(fluid) ~= "table") then return end
    Startup_Settings_Constants = Startup_Settings_Constants or __Startup_Settings_Constants

    optionals = optionals or {}

    tints = tints or {
        Util.get_color_with_alpha(fluid.base_color, mask_alpha, true),
        Util.get_color_with_alpha(fluid.flow_color, mask_alpha, true),
    }

    local auto_barrel = type(fluid.auto_barrel) == "boolean" and not fluid.auto_barrel and 2 or 1

    local name = fluid.name .. (optionals.temperature and ("-" .. optionals.temperature) or "") .. "-cn-containment-canister"

    return {
        type = "recipe",
        name = "empty-" .. name,
        localised_name = { "recipe-name.empty-filled-cn-containment-canister", fluid.localised_name or { "fluid-name." .. fluid.name, }},
        category = "chemistry",
        energy_required = energy_per_empty,
        subgroup = "empty-containment-canister",
        order = "a[basic-intermediates]-d[empty-canister]-" .. (fluid.order or ("[" .. fluid.name ..  "]")),
        enabled = false,
        icons = generate_CC_recipe_icons(fluid, nil, { 7, 8, }),
        ingredients =
        {
            { type = "item", name = name, amount = 1, ignored_by_stats = 1, },
        },
        results =
        {
            { type = "fluid", name = fluid.name,    amount = fluid_per_CC(Startup_Settings_Constants), temperature = tonumber(optionals.temperature) and optionals.temperature or nil, ignored_by_stats = fluid_per_CC(Startup_Settings_Constants), },
            { type = "item",  name = empty_CC_name, amount = 1, ignored_by_stats = 1, },
            __Data_Utils.unpack(energy_shield_outputs[auto_barrel]),
        },
        allow_quality = false,
        allow_decomposition = false,
        allow_productivity = false,
        hide_from_player_crafting = true,
        factoriopedia_alternative = "cn-containment-canister",
        hide_from_signal_gui = false,
        unlock_results = false,
        crafting_machine_tint = {
            primary = tints[1],
            secondary = tints[2],
            tertiary = normalize_color(Util.mix_color(tints[1], tints[2])),
        },
        hidden = blacklist[fluid.name],
        hidden_in_factoriopedia = blacklist[fluid.name],
    }
end

return function (Startup_Settings_Constants)
    for name, fluid in pairs(data.raw.fluid) do
        if (fluid.parameter or fluid.subgroup and fluid.subgroup == "parameters") then goto continue end

        local tints = {
            Util.get_color_with_alpha(fluid.base_color, mask_alpha, true),
            Util.get_color_with_alpha(fluid.flow_color, mask_alpha, true),
        }

        local auto_barrel = type(fluid.auto_barrel) == "boolean" and not fluid.auto_barrel and 2 or 1

        local filled_CC_item = create_CC_item(fluid)
        local fill_CC_recipe = create_fill_CC_recipe(fluid, tints, _, Startup_Settings_Constants)
        local empty_CC_recipe = create_empty_CC_recipe(fluid, tints, _, Startup_Settings_Constants)

        if (fluid.name == "steam") then
            for _, temperature in ipairs({
                { temperature = 165, },
                { temperature = 500, },
            }) do
                local filled_CC_item = create_CC_item(fluid, temperature)
                local fill_CC_recipe = create_fill_CC_recipe(fluid, tints, temperature, Startup_Settings_Constants)
                local empty_CC_recipe = create_empty_CC_recipe(fluid, tints, temperature, Startup_Settings_Constants)

                data:extend({ filled_CC_item, fill_CC_recipe, empty_CC_recipe, })
                if (not CN_Containment_Canister.blacklist[fluid.name]) then
                    add_CC_to_technology(fill_CC_recipe, empty_CC_recipe, data.raw.technology[technology_name[2]])
                end
            end
        else
            data:extend({ filled_CC_item, fill_CC_recipe, empty_CC_recipe, })
            if (not CN_Containment_Canister.blacklist[fluid.name]) then
                add_CC_to_technology(fill_CC_recipe, empty_CC_recipe, data.raw.technology[technology_name[auto_barrel]])
            end
        end

        ::continue::
    end
end