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
        name = "cn-rod-from-god",
        icons =
        {
            { icon = "__base__/graphics/icons/ammo-category/rocket.png", },
            { icon = "__base__/graphics/icons/ammo-category/rocket.png", tint = { 31, 7, 81, 95 } },
        },
        ammo_category = "kinetic-weapon",
        ammo_type =
        {
            range_modifier = -1,
            cooldown_modifier = 1000,
            target_type = "position",
            action =
            {
                type = "direct",
                action_delivery =
                {
                    type = "projectile",
                    projectile = "cn-rod-from-god",
                    starting_speed = 0.0001,
                    source_effects =
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit"
                    }
                }
            }
        },
        subgroup = "payload",
        order = "d[warhead]-e[rod-from-god]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        stack_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_STACK_SIZE.name }),
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_WEIGHT_MODIFIER.name }) * tons,
        send_to_orbit_mode = "manual"
    },
})
