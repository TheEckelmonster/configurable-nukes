local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local create_quality_atomic_munitions = require("prototypes.entities.atomic.quality-atomic-munition")

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_REPEAT_MULTIPLIER.name })
end
-- DO_POLLUTION
local get_do_pollution = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DO_POLLUTION.name })
end
-- FIRE_WAVE
local get_fire_wave = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_FIRE_WAVE.name })
end

local area_multiplier = get_area_multiplier() * 2.71
local damage_multiplier = get_damage_multiplier() * 2.71
local repeat_multiplier = get_repeat_multiplier() * 2.71

local do_pollution = get_do_pollution()
local fire_wave = get_fire_wave()

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 1 + 19 * area_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------
local name = "atomic-warhead"
local original_munition = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

original_munition.name = name
original_munition.icon = "__base__/graphics/icons/signal/signal-radioactivity.png"

local munition = nil

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "quality-unknown" or quality.hidden) then goto continue end

        local quality_munition = create_quality_atomic_munitions({
            quality = quality,
            quality_level = k_0,
            name = name,
            original = original_munition,
            area_multiplier = area_multiplier,
            damage_multiplier = damage_multiplier,
            repeat_multiplier = repeat_multiplier,
            max_nuke_shockwave_movement_distance = max_nuke_shockwave_movement_distance,
            max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
            --[[ TODO: Add startup settings for this ]]
            do_pollution = do_pollution,
            fire_wave = fire_wave,
        })

        if (quality_munition ~= nil) then
            if (k_0 == "normal" or quality.level == 0) then
                munition = Util.table.deepcopy(quality_munition)
                munition.name = original_munition.name

                local quality_munition_ammo_item = data.raw["ammo"][name]

                quality_munition_ammo_item.subgroup = "payload"
                quality_munition_ammo_item.order = "d[warhead]-e[atomic-warhead]"

                if (quality_munition_ammo_item.icon) then
                    munition.icon = Util.table.deepcopy(quality_munition_ammo_item.icon)
                else
                    munition.icons = Util.table.deepcopy(quality_munition_ammo_item.icons)
                end

                if (not munition.icon and not munition.icons) then
                    munition.icon = "__base__/graphics/icons/signal/signal-radioactivity.png"
                end

                munition.subgroup = "payload"
                munition.order = "d[warhead]-e[atomic-warhead]"

                data:extend({ munition, })
            end

            quality_munition.subgroup = "payload"
            quality_munition.order = "d[warhead]-e[atomic-warhead]"

            quality_munition.name = original_munition.name .. "-" .. k_0
            data:extend({quality_munition})
        end

        ::continue::
    end
else
    local quality_munition = create_quality_atomic_munitions({
        quality = { level = 0 },
        quality_level = "normal",
        name = name,
        original = original_munition,
        area_multiplier = area_multiplier,
        damage_multiplier = damage_multiplier,
        repeat_multiplier = repeat_multiplier,
        max_nuke_shockwave_movement_distance = max_nuke_shockwave_movement_distance,
        max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
        --[[ TODO: Add startup settings for this ]]
        do_pollution = do_pollution,
        fire_wave = fire_wave,
    })

    quality_munition.subgroup = "payload"
    quality_munition.order = "d[warhead]-e[atomic-warhead]"

    data:extend({ quality_munition, })
end