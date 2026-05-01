local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = {max_count = 1, remove = true},
    }
end

local Item_Sounds = {
    metal_chest_inventory_move = item_sound("metal-chest-inventory-move.ogg", 0.6),
    metal_chest_inventory_pickup = item_sound("metal-chest-inventory-pickup.ogg", 0.6),
}

return function (Startup_Settings_Constants)
    local barrel = data.raw.item.barrel

    local recipe =
    {
        type = "item",
        name = "cn-containment-canister",
        icon = "__configurable-nukes__/graphics/icons/containment-canister/containment-canister-empty.png",
        icon_size = 64,
        group = "intermediate-products",
        subgroup = "barrel",
        order = "a[basic-intermediates]-d[empty-canister]",
        inventory_move_sound = Item_Sounds.metal_chest_inventory_move,
        pick_sound = Item_Sounds.metal_chest_inventory_pickup,
        drop_sound = Item_Sounds.metal_chest_inventory_move,
        stack_size = barrel.stack_size / 2 or 5,
        weight = barrel.weight * 2 or 2 * (tons / 200),
    }

    data:extend({ recipe, })
end