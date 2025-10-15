local Util = require("__core__.lualib.util")
-- local Item_Sounds = require("__base__.prototypes.item_sounds")

-- local Data_Utils = require("data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

local name_prefix = se_active and "se-" or ""

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = {max_count = 1, remove = true},
    }
end

local Item_Sounds = {
    atomic_bomb_inventory_move = item_sound("atomic-bomb-inventory-move.ogg", 0.6),
    atomic_bomb_inventory_pickup = item_sound("atomic-bomb-inventory-pickup.ogg", 0.6),
    planner_inventory_move = item_sound("planner-inventory-move.ogg", 0.7),
    planner_inventory_pickup = item_sound("planner-inventory-pickup.ogg", 0.7),
}

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

-- RANGE_MODIFIER
local get_range_modifier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-range-modifier"]) then
        setting = settings.startup["configurable-nukes-range-modifier"].value
    end

    return setting
end
-- ATOMIC_BOMB_COOLDOWN_MODIFIER
local get_cooldown_modifier = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER.name].value
    end

    return setting
end
-- STACK_SIZE
local get_stack_size = function ()
    local setting = 10

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-bomb-stack-size"]) then
        setting = settings.startup["configurable-nukes-atomic-bomb-stack-size"].value
    end

    return setting
end
-- WEIGHT_MODIFIER
local get_weight_modifier = function ()
    local setting = 1.5

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-bomb-weight-modifier"]) then
        setting = settings.startup["configurable-nukes-atomic-bomb-weight-modifier"].value
    end

    return setting
end
-- WARHEAD_STACK_SIZE
local get_warhead_stack_size = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-warhead-stack-size"]) then
        setting = settings.startup["configurable-nukes-atomic-warhead-stack-size"].value
    end

    return setting
end
-- WARHEAD_WEIGHT_MODIFIER
local get_warhead_weight_modifier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-warhead-weight-modifier"]) then
        setting = settings.startup["configurable-nukes-atomic-warhead-weight-modifier"].value
    end

    return setting
end
-- ROCKET_CONTROL_UNIT_STACK_SIZE
local get_rocket_control_unit_stack_size = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-rocket-control-unit-stack-size"]) then
        setting = settings.startup["configurable-nukes-rocket-control-unit-stack-size"].value
    end

    return setting
end
-- ROCKET_CONTROL_UNIT_WEIGHT_MODIFIER
local get_rocket_control_unit_weight_modifier = function ()
    local setting = 0.0025

    if (settings and settings.startup and settings.startup["configurable-nukes-rocket-control-unit-weight-modifier"]) then
        setting = settings.startup["configurable-nukes-rocket-control-unit-weight-modifier"].value
    end

    return setting
end
-- ATOMIC_WARHEAD_ENABLED
local get_atomic_warhead_enabled = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name].value
    end

    return setting
end
-- NUCLEAR_AMMO_CATEGORY
local get_nuclear_ammo_category = function ()
    local setting = false

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name].value
    end

    return setting
end
-- BALLISTIC_ROCKET_PART_STACK_SIZE
local get_ballistic_rocket_part_stack_size = function ()
    local setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_STACK_SIZE.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_STACK_SIZE.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_STACK_SIZE.name].value
    end

    return setting
end
-- BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER
local get_ballistic_rocket_part_weight_modifier = function ()
    local setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER.name].value
    end

    return setting
end
-- BALLISTIC_ROCKET_SILO_STACK_SIZE
local get_ballistic_rocket_silo_stack_size = function ()
    local setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_STACK_SIZE.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_STACK_SIZE.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_STACK_SIZE.name].value
    end

    return setting
end
-- BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER
local get_ballistic_rocket_silo_weight_modifier = function ()
    local setting = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER.name].value
    end

    return setting
end

local action =
{
    type = "direct",
    action_delivery =
    {
        type = "projectile",
        projectile = "atomic-rocket",
        starting_speed = 0.05,
        source_effects =
        {
            type = "create-entity",
            entity_name = "explosion-hit"
        }
    }
}

if (mods and mods["quality"]) then
    action =
    {
        {
            action_delivery = {
                target_effects = {
                    {
                        type = "script",
                        effect_id = "atomic-bomb-fired"
                    }
                },
                type = "instant"
            },
            trigger_from_target = true,
            type = "direct"
        },
        {
            type = "direct",
            action_delivery =
            {
                type = "projectile",
                projectile = "atomic-rocket-placeholder",
                starting_speed = 0.05,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "explosion-hit"
                }
            },
        }
    }
end

local atomic_bomb_item =
{
    type = "ammo",
    name = "atomic-bomb",
    icon = "__base__/graphics/icons/atomic-bomb.png",
    pictures =
    {
        layers =
        {
            {
                size = 64,
                filename = "__base__/graphics/icons/atomic-bomb.png",
                scale = 0.5,
                mipmap_count = 4
            },
            {
                draw_as_light = true,
                size = 64,
                filename = "__base__/graphics/icons/atomic-bomb-light.png",
                scale = 0.5
            }
        }
    },
    ammo_category = get_nuclear_ammo_category() and "nuclear" or "rocket",
    ammo_type =
    {
        range_modifier = 1.5 * get_range_modifier(),
        cooldown_modifier = 10 * get_cooldown_modifier(),
        target_type = "position",
        action = action,
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-d[atomic-bomb]",
    inventory_move_sound = Item_Sounds.atomic_bomb_inventory_move,
    pick_sound = Item_Sounds.atomic_bomb_inventory_pickup,
    drop_sound = Item_Sounds.atomic_bomb_inventory_move,
    stack_size = get_stack_size(),
    weight = get_weight_modifier() * tons,
    send_to_orbit_mode = "manual",
}

data:extend({atomic_bomb_item})

data:extend({
    {
        type = "selection-tool",
        name = "ICBM-remote",
        icons =
        {
            {
                icon = "__base__/graphics/icons/signal/signal-damage.png",
            },
            {
                icon = "__base__/graphics/icons/atomic-bomb.png",
                floating = true,
            },
        },
        flags = { "only-in-cursor", "not-stackable", "spawnable" },
        subgroup = "spawnables",
        order = "b[turret]-e[artillery-turret]-b[remote]",
        inventory_move_sound = Item_Sounds.planner_inventory_move,
        pick_sound = Item_Sounds.planner_inventory_pickup,
        drop_sound = Item_Sounds.planner_inventory_move,
        stack_size = 1,
        draw_label_for_cursor_render = false,
        skip_fog_of_war = true,
        auto_recycle = false,
        always_include_tiles = false,
        select =
        {
            border_color = { 71, 255, 73 },
            mode = { "nothing" },
            cursor_box_type = "copy",
        },
        alt_select =
        {
            border_color = { 239, 153, 34 },
            mode = { "nothing" },
            cursor_box_type = "copy",
        },
        -- super_forced_select =
        -- {
        --     border_color = { 0, 126, 255 },
        --     mode = { "nothing" },
        --     cursor_box_type = "copy",
        -- },
        -- reverse_select =
        -- {
        --     border_color = { 255 - 71, 255 - 255, 255 - 73 },
        --     mode = { "nothing" },
        --     cursor_box_type = "copy",
        -- },
        -- alt_reverse_select =
        -- {
        --     border_color = { 255 - 239, 255 - 153, 255 - 34 },
        --     mode = { "nothing" },
        --     cursor_box_type = "copy",
        -- },
        open_sound = "__base__/sound/item-open.ogg",
        close_sound = "__base__/sound/item-close.ogg"
    },
})

local atomic_warhead_item =
{
    type = "ammo",
    name = "atomic-warhead",
    icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
    pictures =
    {
        layers =
        {
            {
                size = 64,
                filename = "__base__/graphics/icons/signal/signal-radioactivity.png",
                scale = 0.5,
                mipmap_count = 4
            },
        }
    },
    ammo_category = get_nuclear_ammo_category() and "nuclear" or "rocket",
    ammo_type =
    {
        range_modifier = -1,
        cooldown_modifier = 1000,
        target_type = "position",
        target_filter = {},
        action =
        {
            type = "direct",
            action_delivery =
            {
                type = "projectile",
                projectile = "atomic-warhead",
                starting_speed = 0.0001,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "explosion-hit"
                }
            }
        }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-e[atomic-bomb]",
    inventory_move_sound = Item_Sounds.atomic_bomb_inventory_move,
    pick_sound = Item_Sounds.atomic_bomb_inventory_pickup,
    drop_sound = Item_Sounds.atomic_bomb_inventory_move,
    stack_size = 1 * get_warhead_stack_size(),
    weight = tons * get_warhead_weight_modifier(),
    hidden = not get_atomic_warhead_enabled(),
    hidden_in_factoriopedia = not get_atomic_warhead_enabled(),
    send_to_orbit_mode = "manual",
}

data:extend({atomic_warhead_item})

if (get_nuclear_ammo_category()) then
    if (not k2so_active) then
        local rocket_launcher = data.raw["gun"]["rocket-launcher"]
        rocket_launcher.attack_parameters.ammo_categories = { rocket_launcher.attack_parameters.ammo_category, "nuclear" }
        rocket_launcher.attack_parameters.ammo_category = nil

        data:extend({rocket_launcher})

        local spidertron_rocket_launcher_1 = data.raw["gun"]["spidertron-rocket-launcher-1"]
        local spidertron_rocket_launcher_2 = data.raw["gun"]["spidertron-rocket-launcher-2"]
        local spidertron_rocket_launcher_3 = data.raw["gun"]["spidertron-rocket-launcher-3"]
        local spidertron_rocket_launcher_4 = data.raw["gun"]["spidertron-rocket-launcher-4"]
        spidertron_rocket_launcher_1.attack_parameters.ammo_categories = { spidertron_rocket_launcher_1.attack_parameters.ammo_category, "nuclear" }
        spidertron_rocket_launcher_1.attack_parameters.ammo_category = nil
        spidertron_rocket_launcher_2.attack_parameters.ammo_categories = { spidertron_rocket_launcher_2.attack_parameters.ammo_category, "nuclear" }
        spidertron_rocket_launcher_2.attack_parameters.ammo_category = nil
        spidertron_rocket_launcher_3.attack_parameters.ammo_categories = { spidertron_rocket_launcher_3.attack_parameters.ammo_category, "nuclear" }
        spidertron_rocket_launcher_3.attack_parameters.ammo_category = nil
        spidertron_rocket_launcher_4.attack_parameters.ammo_categories = { spidertron_rocket_launcher_4.attack_parameters.ammo_category, "nuclear" }
        spidertron_rocket_launcher_4.attack_parameters.ammo_category = nil

        data:extend({spidertron_rocket_launcher_1, spidertron_rocket_launcher_2, spidertron_rocket_launcher_3, spidertron_rocket_launcher_4})
    end

    if (mods and mods["space-age"]) then
        local rocket_turret = data.raw["ammo-turret"]["rocket-turret"]
        rocket_turret.attack_parameters.ammo_categories = {rocket_turret.attack_parameters.ammo_category, "nuclear" }
        rocket_turret.attack_parameters.ammo_category = nil
    end
end

local rocket_control_unit =
{
    type = "item",
    name = "rocket-control-unit",
    -- name = "cn-rocket-control-unit",
    icon = "__configurable-nukes__/graphics/icons/rocket-control-unit.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "n[rocket-control-unit]",
    stack_size = get_rocket_control_unit_stack_size(),
    weight = get_rocket_control_unit_weight_modifier() * tons,
    hidden = not get_atomic_warhead_enabled() and not se_active,
    hidden_in_factoriopedia = not get_atomic_warhead_enabled() and not se_active,
}

data:extend({rocket_control_unit})

if (sa_active or se_active) then
    --[[ ipbm-rocket-silo ]]
    local ipbm_rocket_silo = Util.table.deepcopy(data.raw["item"]["rocket-silo"])
    ipbm_rocket_silo.name = "ipbm-rocket-silo"
    ipbm_rocket_silo.name = "ipbm-rocket-silo"
    ipbm_rocket_silo.order = "b[icbm-rocket-silo]"
    ipbm_rocket_silo.place_result = "ipbm-rocket-silo"

    ipbm_rocket_silo.stack_size = get_ballistic_rocket_silo_stack_size()
    ipbm_rocket_silo.weight = get_ballistic_rocket_silo_weight_modifier() * tons

    data:extend({ipbm_rocket_silo})

    --[[ ipbm-rocket-part ]]
    local ipbm_rocket_part = Util.table.deepcopy(data.raw["item"]["rocket-part"])
    ipbm_rocket_part.name = name_prefix .. "ipbm-rocket-part"

    ipbm_rocket_part.stack_size = get_ballistic_rocket_part_stack_size()
    ipbm_rocket_part.weight = get_ballistic_rocket_part_weight_modifier() * tons

    data:extend({ipbm_rocket_part})
end