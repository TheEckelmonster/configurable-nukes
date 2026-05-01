local prefix = "configurable-nukes-"

local items = {
    {
        setting_name = "JERICHO",
        name = "jericho",
        stack_size = 1,
        weight_modifier = 1,
        range_modifier = 1.5,
        cooldown_modifier = 8,
    },
}

local settings = {}
for i = 1, #items, 1 do
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_HANDHELD_FIREABLE",
        type = "bool-setting",
        name = prefix .. items[i].name .. "-handheld-fireable",
        setting_type = "startup",
        order = "",
        default_value = false,
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_RANGE_MODIFIER",
        type = "double-setting",
        name = prefix .. items[i].name .. "-range-modifier",
        setting_type = "startup",
        order = "",
        default_value = items[i].range_modifier or 1,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
    settings[#settings+1] = {
        setting = items[i].setting_name .. "_COOLDOWN_MODIFIER",
        type = "double-setting",
        name = prefix .. items[i].name .. "-cooldown-modifier",
        setting_type = "startup",
        order = "",
        default_value = items[i].cooldown_modifier or 1,
        maximum_value = 111,
        minimum_value = 1 / (10 ^ 10),
    }
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