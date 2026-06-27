local prefix = "configurable-nukes-"

local utils = {}

function utils.make_settings(entities)
    if (not entities) then return end

    local settings = {}
    for i = 1, #entities, 1 do
        settings[#settings+1] = {
            setting = entities[i].setting .. "_LAVA_CRATER",
            type = "bool-setting",
            name = prefix .. entities[i].name .. "-lava-crater",
            setting_type = "startup",
            order = "",
            default_value = entities[i].lava_crater or false,
            hidden = true
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE",
            type = "bool-setting",
            name = prefix .. entities[i].name .. "-fire-wave",
            setting_type = "startup",
            order = "",
            default_value = entities[i].fire_wave or false,
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE_POLLUTION_PER_SECOND",
            type = "double-setting",
            name = prefix .. entities[i].name .. "-fire-wave-pollution-per-second",
            setting_type = "startup",
            order = "",
            default_value = entities[i].pollution,
            maximum_value = 11^11,
            minimum_value = 0,
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE_MAX_SPREAD_COUNT",
            type = "int-setting",
            name = prefix .. entities[i].name .. "-fire-wave-max-spread-count",
            setting_type = "startup",
            order = "",
            default_value = entities[i].max_spread_count,
            maximum_value = 2^11,
            minimum_value = 0,
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE_BASE_LIFETIME",
            type = "int-setting",
            name = prefix .. entities[i].name .. "-fire-wave-base-lifetime",
            setting_type = "startup",
            order = "",
            default_value = entities[i].base_lifetime,
            maximum_value = 3^11,
            minimum_value = 0,
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE_INITIAL_LIFETIME",
            type = "int-setting",
            name = prefix .. entities[i].name .. "-fire-wave-initial-lifetime",
            setting_type = "startup",
            order = "",
            default_value = entities[i].intial_lifetime,
            maximum_value = 3^11,
            minimum_value = 0,
        }
        settings[#settings+1] = {
            setting = entities[i].setting .. "_FIRE_WAVE_MAX_LIFETIME",
            type = "int-setting",
            name = prefix .. entities[i].name .. "-fire-wave-max-lifetime",
            setting_type = "startup",
            order = "",
            default_value = entities[i].max_lifetime,
            maximum_value = 3^11,
            minimum_value = 0,
        }
    end

    return settings
end

return utils