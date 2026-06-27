local __stage = __STAGE or nil

local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local true_nukes_contiued = mods and mods["True-Nukes_Continued"] and true

local create_quality_atomic_munitions = require("prototypes.entities.atomic.quality-atomic-munition")

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_REPEAT_MULTIPLIER.name })
end
-- DO_POLLUTION
local get_do_pollution = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_DO_POLLUTION.name })
end
-- FIRE_WAVE
local get_fire_wave = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_FIRE_WAVE.name })
end

local area_multiplier = get_area_multiplier()
local damage_multiplier = get_damage_multiplier()
local repeat_multiplier = get_repeat_multiplier()

local do_pollution = get_do_pollution()
local fire_wave = get_fire_wave()

if (true_nukes_contiued) then
    area_multiplier = area_multiplier * 6.66
    repeat_multiplier = repeat_multiplier * 6.66
end

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 1 + 19 * area_multiplier

local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------
local name = "atomic-bomb"
local original_munition = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

if (not original_munition) then
    original_munition = Util.table.deepcopy(data.raw["projectile"]["atomic-bomb"])
end

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
            fire_wave = fire_wave and {
                maximum_spread_count = maximum_spread_count,
                pollution = fire_wave_pollution,
                base_lifetime = base_lifetime,
                initial_lifetime = initial_lifetime,
                maximum_lifetime = maximum_lifetime,
                num_levels = num_levels,
                max_num_levels = max_num_levels,
                min_num_levels = min_num_levels,
            },
        })

        if (quality_munition ~= nil) then
            if (k_0 == "normal" or quality.level == 0) then
                if (type(__stage) ~= "string" or __stage ~= "data") then
                    munition = Util.table.deepcopy(quality_munition)
                    munition.name = original_munition.name

                    local quality_munition_ammo_item = data.raw["ammo"][name]

                    if (quality_munition_ammo_item.icon) then
                        munition.icon = Util.table.deepcopy(quality_munition_ammo_item.icon)
                    else
                        munition.icons = Util.table.deepcopy(quality_munition_ammo_item.icons)
                    end

                    if (not munition.icon and not munition.icons) then
                        if (k2so_active) then
                            munition.icon = "__Krastorio2Assets__/icons/ammo/atomic-bomb.png"
                        else
                            munition.icons =
                            {
                                {
                                    size = 64,
                                    filename = "__base__/graphics/icons/atomic-bomb.png",
                                    scale = 0.5,
                                    mipmap_count = 4
                                },
                                {
                                    draw_as_light = true,
                                    size = 64,
                                    filename = "__base__/graphics/icons/atomic-bomb-light.png",
                                    scale = 0.5
                                }
                            }
                        end
                    end

                    data:extend({munition})
                end
            end

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

    data:extend({ quality_munition, })
end

local atomic_bomb_placeholder = Util.table.deepcopy(original_munition)
atomic_bomb_placeholder.name = "atomic-rocket-placeholder"

atomic_bomb_placeholder.animation = nil
atomic_bomb_placeholder.shadow = nil
atomic_bomb_placeholder.smoke = nil



local atomic_bomb_placeholder_array = {
    {
        type = "damage",
        damage = { amount = 400 * damage_multiplier, type = "explosion" }
    },
    {
        type = "destroy-cliffs",
        radius = 9 * area_multiplier,
        explosion_at_trigger = "explosion"
    },
    {
        type = "nested-result",
        action =
        {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = 1000 * repeat_multiplier,
            radius = 7 * area_multiplier,
            action_delivery =
            {
                type = "projectile",
                projectile = "atomic-bomb-ground-zero-projectile",
                starting_speed = 0.6 * 0.8 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
            },
        }
    },
    {
        type = "nested-result",
        action =
        {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = 1000 * repeat_multiplier,
            radius = 35 * area_multiplier,
            action_delivery =
            {
                type = "projectile",
                projectile = "atomic-bomb-wave",
                starting_speed = 0.5 * 0.7 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
            },
        }
    },
}
local atomic_bomb_placeholder_target_effects = {}

for _, v in pairs(atomic_bomb_placeholder_array) do table.insert(atomic_bomb_placeholder_target_effects, v) end

atomic_bomb_placeholder.action =
{
    type = "direct",
    action_delivery =
    {
        type = "instant",
        target_effects = atomic_bomb_placeholder_target_effects
    }
}

if (k2so_active) then
    local damage =
    {
        explosion =
        {
            type = "damage",
            damage = { amount = 1500 * 1, type = "explosion" },
        },
        radioactive =
        {
            type = "damage",
            damage = { amount = 1500 * 1, type = "kr-radioactive" },
        },
    }

    table.remove(atomic_bomb_placeholder.action.action_delivery.target_effects, 1)

    table.insert(atomic_bomb_placeholder.action.action_delivery.target_effects, 1, damage.explosion)
    table.insert(atomic_bomb_placeholder.action.action_delivery.target_effects, 2, damage.radioactive)
end

data:extend({atomic_bomb_placeholder})