-- local Item_Sounds = require("__base__.prototypes.item_sounds")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

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
        type = "item-with-inventory",
        name = "cn-payload-vehicle",
        icons =
        {
            { icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png", icon_size = 173 }
        },
        subgroup = "space-related",
        order = "d[rocket-parts]-e[satellite]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        stack_size = 1,
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_WEIGHT_MODIFIER.name }) * tons,
        send_to_orbit_mode = "manual",
        flags = flags,
        inventory_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_INVENTORY_SIZE.name }),
        item_filters = {
            "explosives",
            "land-mine",
        },
        item_group_filters = {},
        item_subgroup_filters = {
            "payload",
            "ammo",
            "capsule",
            mods and mods["bobwarfare"] and "bob-ammo" or nil,
        },
        filter_mode = "whitelist",
        filter_message_key = "item-limitation.cn-payload-vehicle",
    },
})
