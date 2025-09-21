-- If already defined, return
if _runtime_global_settings_constants and _runtime_global_settings_constants.configurable_nukes then
    return _runtime_global_settings_constants
end

local prefix = "configurable-nukes-"

local runtime_global_settings_constants = {}

runtime_global_settings_constants.settings = {
    ATOMIC_BOMB_ROCKET_LAUNCHABLE = {
        type = "bool-setting",
        name = prefix .. "atomic-bomb-rocket-launchable",
        setting_type = "runtime-global",
        order = "cbd",
        default_value = false,
    },
    POLLUTION = {
        type = "double-setting",
        name = prefix .. "pollution",
        setting_type = "runtime-global",
        order = "cbe",
        default_value = 0.166,
        maximum_value = 11,
        minimum_value = 0
    },
    ATOMIC_WARHEAD_POLLUTION = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-pollution",
        setting_type = "runtime-global",
        order = "cbf",
        default_value = 0.542,
        maximum_value = 11,
        minimum_value = 0,
    },
    PIN_TARGETS = {
        type = "bool-setting",
        name = prefix .. "pin-targets",
        setting_type = "runtime-global",
        order = "cca",
        default_value = true,
    },
    DO_ICBMS_REVEAL_TARGET = {
        type = "bool-setting",
        name = prefix .. "do-icbms-reveal-target",
        setting_type = "runtime-global",
        order = "ccb",
        default_value = true,
    },
    PRINT_FLIGHT_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-print-flight-messages",
        setting_type = "runtime-global",
        order = "ccc",
        default_value = true,
    },
    --[[ ICBM ]]
    ICBM_PERFECT_GUIDANCE = {
        type = "bool-setting",
        name = prefix .. "icbms-perfect-guidance",
        setting_type = "runtime-global",
        order = "ccd",
        default_value = false,
    },
    ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME = {
        type = "bool-setting",
        name = prefix .. "icbms-planet-magnitude-affects-travel-time",
        setting_type = "runtime-global",
        order = "cce",
        default_value = true,
    },
    ICBM_PLANET_MAGNITUDE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "icbms-magnitude-modifier",
        setting_type = "runtime-global",
        order = "ccf",
        default_value = 1,
        minimum_value = (1 / 2) ^ 11,
        maximum_value = 11,
    },
    ICBM_TRAVEL_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "icbms-travel-multiplier",
        setting_type = "runtime-global",
        order = "ccg",
        default_value = 1,
        minimum_value = 0,
        maximum_value = 2 ^ 11
    },
    ICBM_GUIDANCE_DEVIATION_THRESHOLD = {
        type = "double-setting",
        name = prefix .. "icbms-guidance-deviation-threshold",
        setting_type = "runtime-global",
        order = "cch",
        default_value = 0.25,
        minimum_value = 0,
        maximum_value = 1
    },
    ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-allow-targeting-origin",
        setting_type = "runtime-global",
        order = "dcc",
        default_value = false,
    },
    ICBM_CIRCUIT_PRINT_FLIGHT_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-print-flight-messages",
        setting_type = "runtime-global",
        order = "dcd",
        default_value = false,
    },
    ICBM_CIRCUIT_PIN_TARGETS = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-print-pin-targets",
        setting_type = "runtime-global",
        order = "dce",
        default_value = false,
    },
}

runtime_global_settings_constants.configurable_nukes = true

local _runtime_global_settings_constants = runtime_global_settings_constants

return runtime_global_settings_constants