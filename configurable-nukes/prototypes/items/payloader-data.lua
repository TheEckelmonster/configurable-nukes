local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = { max_count = 1, remove = true, },
    }
end

local Item_Sounds = {
    mechanical_inventory_move = item_sound("mechanical-inventory-move.ogg", 0.7),
    mechanical_inventory_pickup = item_sound("mechanical-inventory-pickup.ogg", 0.8)
}

data:extend({
    {
        type = "item",
        name = "payloader",
        icon = "__configurable-nukes__/graphics/icons/payloader.png",
        subgroup = "production-machine",
        order = "c[assembling-machine-3]-c[payloader]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        place_result = "payloader",
        stack_size = 10,
        weight = 200 * kg,
        enabled = false,
    },
})