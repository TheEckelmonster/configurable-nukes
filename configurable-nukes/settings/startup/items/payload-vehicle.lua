local prefix = "configurable-nukes-"

local items = {
    {
        setting_name = "PAYLOAD_VEHICLE",
        name = "payload-vehicle",
        inventory_size = 4,
        weight_modifier = 1 / 4,
    },
}

local settings = {}
for i = 1, #items, 1 do
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_INVENTORY_SIZE",
        type = "int-setting",
        name = prefix .. items[i].name .. "-inventory-size",
        setting_type = "startup",
        order = "",
        default_value = items[i].inventory_size,
        maximum_value = 2 ^ 7,
        minimum_value = 1,
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_WEIGHT_MODIFIER",
        type = "double-setting",
        name = prefix .. items[i].name .. "-weight-modifier",
        setting_type = "startup",
        order = "",
        default_value = items[i].weight_modifier,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
end

return settings