-- local Item_Sounds = require("__base__.prototypes.item_sounds")

local Data_Utils = require("data-utils")
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
        type = "item",
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
        stack_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_STACK_SIZE.name }),
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_WEIGHT_MODIFIER.name }) * tons,
        send_to_orbit_mode = "manual"
    },
})
