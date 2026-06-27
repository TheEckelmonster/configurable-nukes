-- local Item_Sounds = require("__base__.prototypes.item_sounds")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = {max_count = 1, remove = true},
    }
end

local Item_Sounds = {
    mechanical_inventory_move = item_sound("mechanical-inventory-move.ogg", 0.7),
    mechanical_inventory_pickup = item_sound("mechanical-inventory-pickup.ogg", 0.8)
}

data:extend({
    {
        type = "ammo",
        name = "cn-jericho",
        icons =
        {
            { icon = "__base__/graphics/icons/ammo-category/rocket.png", },
            { icon = "__base__/graphics/icons/ammo-category/rocket.png", tint = { 255, 0, 0, 85 } },
        },
        ammo_category = "rocket",
        ammo_type =
        {
            range_modifier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_HANDHELD_FIREABLE.name }) and Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_RANGE_MODIFIER.name }) or -1,
            cooldown_modifier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_COOLDOWN_MODIFIER.name }) or 8,
            target_type = "position",
            action =
            {
                type = "direct",
                action_delivery =
                {
                    type = "projectile",
                    projectile = "cn-jericho",
                    starting_speed = 0.05,
                    target_effects =
                    {
                        type = "script",
                        effect_id = "cn-jericho-fired"
                    },
                    source_effects =
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit",
                    },
                },
            },
        },
        magazine_size = 10,
        subgroup = "payload",
        order = "d[warhead]-e[jericho]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        stack_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_STACK_SIZE.name }),
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_WEIGHT_MODIFIER.name }) * tons,
        send_to_orbit_mode = "manual",
    },
})
