local prefix = "configurable-nukes-"

local entities = {
    {
        setting = "USE_WHOLE_ROCKET_SPRITE",
        name = "use-whole-rocket-sprite",
        do_pollution = true,
    },
}

local settings = {}
for i = 1, #entities, 1 do
    settings[#settings+1] = {
        setting = entities[i].setting .. "",
        type = "bool-setting",
        name = prefix .. entities[i].name .. "",
        setting_type = "startup",
        order = "",
        default_value = false,
    }
end

return settings