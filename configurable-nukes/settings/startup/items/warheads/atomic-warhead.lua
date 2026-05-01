local prefix = "configurable-nukes-"

local items = {
    {
        setting_name = "ATOMIC_WARHEAD",
        name = "atomic-warhead",
        stack_size = 1,
        weight_modifier = 1,
    },
}

local settings = {}
for i = 1, #items, 1 do
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_WEIGHT_MODIFIER",
        type = "double-setting",
        name = prefix .. items[i].name .. "-weight-modifier",
        setting_type = "startup",
        order = "",
        default_value = items[i].weight_modifier or 1,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_STACK_SIZE",
        type = "int-setting",
        name = prefix .. items[i].name .. "-stack-size",
        setting_type = "startup",
        order = "",
        default_value = items[i].stack_size or 50,
        maximum_value = 200,
        minimum_value = 1,
    }
end

return settings