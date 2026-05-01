local prefix = "configurable-nukes-"

local items = {
    {
        setting_name = "ROCKET_CONTROL_UNIT",
        name = "rocket-control-unit",
        stack_size = 10,
        weight_modifier = 1 / 5,
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
        default_value = items[i].weight_modifier,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_STACK_SIZE",
        type = "int-setting",
        name = prefix .. items[i].name .. "-stack-size",
        setting_type = "startup",
        order = "",
        default_value = items[i].stack_size,
        maximum_value = 200,
        minimum_value = 1,
    }
end

return settings