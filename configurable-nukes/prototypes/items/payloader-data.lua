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

local icon = { icon = "__configurable-nukes__/graphics/icons/payloader/payloader.png", size = 64, scale = 1, }
local icons = { icon, }

if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_DO_TINT.name, })) then
    icon.tint = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_BASE_TINT.name, })

    icons =
    {
        {
            icon = "__configurable-nukes__/graphics/icons/payloader/payloader-base-grayscale.png",
            size = 64,
            scale = 1,
        },
        {
            icon = "__configurable-nukes__/graphics/icons/payloader/payloader-base-grayscale.png",
            size = 64,
            scale = 1,
            tint = { r = icon.tint.r, g = icon.tint.g, b = icon.tint.b, a = icon.tint.a * 0.85},
        },
        {
            icon = "__configurable-nukes__/graphics/icons/payloader/payloader-base-alpha.png",
            size = 64,
            scale = 1,
        },
        {
            icon = "__configurable-nukes__/graphics/icons/payloader/payloader-final-overlay.png",
            size = 64,
            scale = 1,
        },
    }
end

data:extend({
    {
        type = "item",
        name = "payloader",
        icon = nil,
        icons = icons,
        subgroup = "production-machine",
        order = "c[assembling-machine-3]-c[payloader]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        place_result = "payloader",
        stack_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_STACK_SIZE.name }),
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOADER_WEIGHT_MODIFIER.name }) * tons,
        enabled = false,
    },
})