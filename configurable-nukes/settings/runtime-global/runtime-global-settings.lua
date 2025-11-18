local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local Constants = require("scripts.constants.constants")
local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true

data:extend({
    Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE,

    Runtime_Global_Settings_Constants.settings.POLLUTION,
    Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_POLLUTION,

    Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION,
    Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION,

    Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_ADDITION,
    Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_ADDITION,

    Runtime_Global_Settings_Constants.settings.PIN_TARGETS,
    Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET,
    Runtime_Global_Settings_Constants.settings.PRINT_LAUNCH_MESSAGES,
    Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES,

    Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE,
    Runtime_Global_Settings_Constants.settings.ICBM_MULTISURFACE_TRAVEL_TIME_MODIFIER,
    Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.MULTISURFACE_ORBIT_BASE_DISTANCE_MODIFIER,

    Runtime_Global_Settings_Constants.settings.ALWAYS_USE_CLOSEST_SILO,

    Runtime_Global_Settings_Constants.settings.ICBM_PERFECT_GUIDANCE,
    Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER,
    Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME,
    Runtime_Global_Settings_Constants.settings.ICBM_TRAVEL_MULTIPLIER,
    Runtime_Global_Settings_Constants.settings.ICBM_GUIDANCE_DEVIATION_THRESHOLD,
    Runtime_Global_Settings_Constants.settings.ICBM_DEVIATION_SCALING_FACTOR,

    Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN,
    Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_LAUNCH_MESSAGES,
    Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES,
    Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PIN_TARGETS,

    Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED,

    Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE,
    Runtime_Global_Settings_Constants.settings.NUM_SURFACES_PROCESSED_PER_TICK,

    Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE,
})

if (k2so_active) then
    data:extend({
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_POLLUTION,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_POLLUTION,
        --[[ kr-nuclear-turret-rocket ]]
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_ADDITION,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_ADDITION,
        --[[ kr-nuclear-artillery-shell ]]
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_ADDITION,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_ADDITION,
    })
end

if (saa_s_active) then
    data:extend({
        Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_POLLUTION,
        --[[ saa-s-atomic-artillery-shell ]]
        Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_ADDITION,
        Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER,
        Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_ADDITION,
    })
end

data:extend(Log_Settings.create({ prefix = Constants.mod_name, settings_array = Runtime_Global_Settings_Constants.settings }))