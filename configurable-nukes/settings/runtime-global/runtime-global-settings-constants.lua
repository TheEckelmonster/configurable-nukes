-- If already defined, return
if _runtime_global_settings_constants and _runtime_global_settings_constants.configurable_nukes then
    return _runtime_global_settings_constants
end


local runtime_global_settings_constants = {}

runtime_global_settings_constants.settings = {
    POLLUTION = {
        type = "double-setting",
        name = "configurable-nukes-pollution",
        setting_type = "runtime-global",
        order = "cbd",
        default_value = 0.166,
        maximum_value = 11,
        minimum_value = 0
    },
}

runtime_global_settings_constants.configurable_nukes = true

local _runtime_global_settings_constants = runtime_global_settings_constants

return runtime_global_settings_constants