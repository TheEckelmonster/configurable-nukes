local prefix = "configurable-nukes-"

local entities = {
    {
        setting = "JERICHO",
        name = "jericho",
    },
}

local settings = {}
for i = 1, #entities, 1 do
    settings[#settings+1] = {
        setting = entities[i].setting .. "_AREA_MULTIPLIER",
        type = "double-setting",
        name = prefix .. entities[i].name .. "-area-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 1
    }
    settings[#settings+1] = {
        setting = entities[i].setting .. "_DAMAGE_MULTIPLIER",
        type = "double-setting",
        name = prefix .. entities[i].name .. "-damage-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 1
    }
    settings[#settings+1] = {
        setting = entities[i].setting .. "_REPEAT_MULTIPLIER",
        type = "double-setting",
        name = prefix .. entities[i].name .. "-repeat-multiplier",
        setting_type = "startup",
        order = "",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 1
    }
    settings[#settings+1] = {
        setting = entities[i].setting .. "_SUB_ROCKET_REPEAT_MULTIPLIER",
        type = "double-setting",
        name = prefix .. entities[i].name .. "-sub-rocket-repeat-multiplier",
        setting_type = "startup",
        order = "bbd",
        default_value = 1,
        maximum_value = 11,
        minimum_value = 1
    }
end

return settings