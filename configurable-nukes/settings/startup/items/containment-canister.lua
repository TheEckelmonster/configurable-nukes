local prefix = "configurable-nukes-"

local items = {
    {
        setting_name = "CONTAINMENT_CANISTER",
        name = "containment-canister",
        weight_modifier = 2 / 200,
        stack_size = 10 / 2,
        capacity = 5 * 50,
        order = "c-c-1",
    },
}

local settings = {}

for i = 1, #items, 1 do
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_WEIGHT_MODIFIER",
        type = "double-setting",
        name = prefix .. items[i].name .. "-weight-modifier",
        setting_type = "startup",
        order = (items[i].order or "") .. ("c[item]-c[" .. items[i].name .. "]-c[item]-c[weight-modifier]"),
        default_value = items[i].weight_modifier,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_STACK_SIZE",
        type = "int-setting",
        name = prefix .. items[i].name .. "-stack-size",
        setting_type = "startup",
        order = (items[i].order or "") .. ("c[item]-c[" .. items[i].name .. "]-c[item]-e[stack-size]"),
        default_value = items[i].stack_size,
        maximum_value = 200,
        minimum_value = 1,
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_CAPACITY",
        type = "int-setting",
        name = prefix .. items[i].name .. "-capacity",
        setting_type = "startup",
        order = (items[i].order or "") .. ("c[item]-c[" .. items[i].name .. "]-c[item]-g[capacity]"),
        default_value = items[i].capacity or (5 * 50),
        maximum_value = 2^20,
        minimum_value = 1,
    }
end

return settings