local prefix = "configurable-nukes-"

local entities = {
    {
        setting = "ATOMIC_WARHEAD",
        name = "atomic-warhead",
        do_pollution = true,
        fire_wave = true,
    },
}

local settings = {}
for i = 1, #entities, 1 do
    settings[#settings+1] = {
        setting = entities[i].setting .. "_ENABLED",
        type = "bool-setting",
        name = prefix .. entities[i].name .. "-enabled",
        setting_type = "startup",
        order = "bba",
        default_value = true,
    }
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
        setting = entities[i].setting .. "_DO_POLLUTION",
        type = "bool-setting",
        name = prefix .. entities[i].name .. "-do-pollution",
        setting_type = "startup",
        order = "",
        default_value = entities[i].do_pollution or false,
    }
    settings[#settings+1] = {
        setting = entities[i].setting .. "_FIRE_WAVE",
        type = "bool-setting",
        name = prefix .. entities[i].name .. "-fire-wave",
        setting_type = "startup",
        order = "",
        default_value = entities[i].fire_wave or false,
    }
end

return settings