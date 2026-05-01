local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = { max_count = 1, remove = true },
    }
end

local Item_Sounds = {
    combinator_inventory_move = item_sound("combinator-inventory-move.ogg", 0.5),
    combinator_inventory_pickup = item_sound("combinator-inventory-pickup.ogg", 0.6),
}

local target_combinator =
{
    type = "item-with-tags",
    name = "target-combinator",
    icon = "__configurable-nukes__/graphics/icons/combinator/target-combinator.png",
    subgroup = "circuit-network",
    order = "c[combinators]-e[target-combinator]",
    inventory_move_sound = Item_Sounds.combinator_inventory_move,
    pick_sound = Item_Sounds.combinator_inventory_pickup,
    drop_sound = Item_Sounds.combinator_inventory_move,
    stack_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_STACK_SIZE.name, }),
    weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TARGET_COMBINATOR_WEIGHT_MODIFIER.name, }) * tons,
    place_result = "target-combinator",
}

data:extend({ target_combinator, })