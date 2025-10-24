-- If already defined, return
if _runtime_global_settings_constants and _runtime_global_settings_constants.configurable_nukes then
    return _runtime_global_settings_constants
end

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true or scripts and scripts.active_mods and scripts.active_mods["Krastorio2-spaced-out"]
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true or scripts and scripts.active_mods and scripts.active_mods["SimpleAtomicArtillery-S"]
local sa_active = mods and mods["space-age"] and true or scripts and scripts.active_mods and scripts.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or scripts and scripts.active_mods and scripts.active_mods["space-exploration"]

local order_struct = {
    order_array = {
        -- "a", "b", "c", "d", "e",  "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        [0] = "a",
        [1] = "b",
        [2] = "c",
        [3] = "d",
        [4] = "e",
        [5] = "f",
        [6] = "g",
        [7] = "h",
        [8] = "i",
        [9] = "j",
        [10] = "k",
        [11] = "l",
        [12] = "m",
        [13] = "n",
        [14] = "o",
        [15] = "p",
        [16] = "q",
        [17] = "r",
        [18] = "s",
        [19] = "t",
        [20] = "u",
        [21] = "v",
        [22] = "w",
        [23] = "x",
        [24] = "y",
        [25] = "z",
    },
    order_dictionary = {},
}

for k, v in pairs(order_struct.order_array) do
    order_struct.order_dictionary[v] = k
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
    K2_SO_NUCLEAR_TURRET_ROCKET_POLLUTION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-turret-rocket-pollution",
        setting_type = "runtime-global",
        order = "cbe",
        default_value = 0.166,
        maximum_value = 11,
        minimum_value = 0,
        hidden = not k2so_active,
    },
    K2_SO_NUCLEAR_ARTILLERY_POLLUTION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-artillery-pollution",
        setting_type = "runtime-global",
        order = "cbf",
        default_value = 0.166,
        maximum_value = 11,
        minimum_value = 0,
        hidden = not k2so_active,
    },
    SIMPLE_ATOMIC_ARTILLERY_POLLUTION = {
        type = "double-setting",
        name = prefix .. "saa-s-atomic-artillery-pollution",
        setting_type = "runtime-global",
        order = "cbf",
        default_value = 0.166,
        maximum_value = 11,
        minimum_value = 0,
        hidden = not saa_s_active,
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
    PRINT_LAUNCH_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-print-launch-messages",
        setting_type = "runtime-global",
        order = "ccc",
        default_value = true,
    },
    PRINT_DELIVERY_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-print-delivery-messages",
        setting_type = "runtime-global",
        order = "ccd",
        default_value = true,
    },
    --[[ ICBM ]]
    ATOMIC_BOMB_BASE_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-base-damage-modifier",
        setting_type = "runtime-global",
        order = "cce",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    ATOMIC_BOMB_BASE_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-base-damage-addition",
        setting_type = "runtime-global",
        order = "ccf",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-bonus-damage-modifier",
        setting_type = "runtime-global",
        order = "cdd",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    ATOMIC_BOMB_BONUS_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "atomic-bomb-bonus-damage-addition",
        setting_type = "runtime-global",
        order = "cde",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    ATOMIC_WARHEAD_BASE_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-base-damage-modifier",
        setting_type = "runtime-global",
        order = "ced",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    ATOMIC_WARHEAD_BASE_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-base-damage-addition",
        setting_type = "runtime-global",
        order = "cee",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    ATOMIC_WARHEAD_BONUS_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-bonus-damage-modifier",
        setting_type = "runtime-global",
        order = "cfd",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    ATOMIC_WARHEAD_BONUS_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "atomic-warhead-bonus-damage-addition",
        setting_type = "runtime-global",
        order = "cfe",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-rocket-turret-base-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-rocket-turret-base-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-rocket-turret-bonus-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-rocket-turret-bonus-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-artillery-base-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-artillery-base-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-artillery-bonus-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "kr-nuclear-artillery-bonus-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "saa-s-atomic-artillery-base-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "saa-s-atomic-artillery-base-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "saa-s-atomic-artillery-bonus-damage-modifier",
        setting_type = "runtime-global",
        order = "",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 11,
    },
    SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_ADDITION = {
        type = "double-setting",
        name = prefix .. "saa-s-atomic-artillery-bonus-damage-addition",
        setting_type = "runtime-global",
        order = "",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 2 ^ 42,
    },
    ICBM_ALLOW_MULTISURFACE = {
        type = "bool-setting",
        name = prefix .. "icbms-allow-multisurface",
        setting_type = "runtime-global",
        order = "cjd",
        default_value = false,
    },
    ICBM_MULTISURFACE_TRAVEL_TIME_MODIFIER = {
        type = "double-setting",
        name = prefix .. "icbms-multisurface-travel-time-modifier",
        setting_type = "runtime-global",
        order = "cjd",
        default_value = 1,
        maximum_value = 2 ^ 11,
        minimum_value = 0,
    },
    MULTISURFACE_BASE_DISTANCE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "multisurface-base-distance-modifier",
        setting_type = "runtime-global",
        order = "cje",
        default_value = 3000,
        maximum_value = 2 ^ 42,
        minimum_value = 0,
    },
    MULTISURFACE_ORBIT_BASE_DISTANCE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "multisurface-orbit-base-distance-modifier",
        setting_type = "runtime-global",
        order = "cjf",
        default_value = 10,
        maximum_value = 2 ^ 42,
        minimum_value = 0,
    },
    ALWAYS_USE_CLOSEST_SILO = {
        type = "bool-setting",
        name = prefix .. "always-use-closest-silo",
        setting_type = "runtime-global",
        order = "ckd",
        default_value = false,
    },
    ICBM_PERFECT_GUIDANCE = {
        type = "bool-setting",
        name = prefix .. "icbms-perfect-guidance",
        setting_type = "runtime-global",
        order = "cke",
        default_value = false,
    },
    ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME = {
        type = "bool-setting",
        name = prefix .. "icbms-planet-magnitude-affects-travel-time",
        setting_type = "runtime-global",
        order = "cld",
        default_value = true,
    },
    ICBM_PLANET_MAGNITUDE_MODIFIER = {
        type = "double-setting",
        name = prefix .. "icbms-magnitude-modifier",
        setting_type = "runtime-global",
        order = "cle",
        default_value = 1,
        minimum_value = (1 / 2) ^ 11,
        maximum_value = 11,
    },
    ICBM_TRAVEL_MULTIPLIER = {
        type = "double-setting",
        name = prefix .. "icbms-travel-multiplier",
        setting_type = "runtime-global",
        order = "cmd",
        default_value = 1,
        minimum_value = 0,
        maximum_value = 2 ^ 11
    },
    ICBM_GUIDANCE_DEVIATION_THRESHOLD = {
        type = "double-setting",
        name = prefix .. "icbms-guidance-deviation-threshold",
        setting_type = "runtime-global",
        order = "cme",
        default_value = 0.45,
        minimum_value = 0,
        maximum_value = 1
    },
    ICBM_DEVIATION_SCALING_FACTOR = {
        type = "double-setting",
        name = prefix .. "icbms-deviation-scaling-factor",
        setting_type = "runtime-global",
        order = "cmf",
        default_value = 0.55,
        minimum_value = 0,
        maximum_value = 2
    },
    ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-allow-targeting-origin",
        setting_type = "runtime-global",
        order = "dcc",
        default_value = false,
    },
    -- ICBM_CIRCUIT_PRINT_FLIGHT_MESSAGES = {
    --     type = "bool-setting",
    --     name = prefix .. "icbms-circuit-print-flight-messages",
    --     setting_type = "runtime-global",
    --     order = "dcd",
    --     default_value = false,
    -- },
    ICBM_CIRCUIT_PRINT_LAUNCH_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-print-launch-messages",
        setting_type = "runtime-global",
        order = "dcd",
        default_value = false,
    },
    ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-print-delivery-messages",
        setting_type = "runtime-global",
        order = "dce",
        default_value = false,
    },
    ICBM_CIRCUIT_PIN_TARGETS = {
        type = "bool-setting",
        name = prefix .. "icbms-circuit-print-pin-targets",
        setting_type = "runtime-global",
        order = "dcf",
        default_value = false,
    },
    ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED = {
        type = "bool-setting",
        name = prefix .. "circuit-allow-launch-when-no-surface-selected",
        setting_type = "runtime-global",
        order = "dcg",
        default_value = true,
    },
    NUM_SURFACES_PROCESSED_PER_TICK = {
        type = "int-setting",
        name = prefix .. "num-surfaces-processed-per-tick",
        setting_type = "runtime-global",
        order = "gcc",
        default_value = se_active and 12 or sa_active and 3 or 1,
        minimum_value = 1,
        maximum_value = 2 ^ 11
    },
    DASHBOARD_REFRESH_RATE = {
        type = "int-setting",
        name = prefix .. "dashboard-refresh-rate",
        setting_type = "runtime-global",
        order = "",
        default_value = 6,
        minimum_value = 1,
        maximum_value = 60
    },
}

runtime_global_settings_constants.settings_dictionary  = {}
runtime_global_settings_constants.settings_array = {}

local i = 1
for k, v in pairs(runtime_global_settings_constants.settings) do
    table.insert(runtime_global_settings_constants.settings_array, v)
    runtime_global_settings_constants.settings_dictionary[v.name] = v
    v.order_num = i
    i = i + 1
end

runtime_global_settings_constants.configurable_nukes = true

local _runtime_global_settings_constants = runtime_global_settings_constants

return runtime_global_settings_constants