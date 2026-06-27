local Util = require("__core__.lualib.util")

local __Data_Utils = require("data-utils")

local UINT8 = 2 ^ 8 - 1
local UINT16 = 2 ^ 16 - 1
local UINT24 = 2 ^ 24 - 1
local UINT32 = 2 ^ 32 - 1
local UINT64 = 2 ^ 64 - 1

local function clamp(value, max, min)
    if (not value or type(value) ~= "number") then return end
    max = max or UINT8
    min = min or 0

    if (value < min) then value = min
    elseif (value > max) then value = max
    end

    return value
end

local num_levels = 10

local E = math.exp(1)

--[[ TODO: Add startup setting ]]
local max_num_levels = 32

-- return function (target_effects, name, quality_name, settings)
return function (name, quality_name, settings)
    if (type(name) ~= "string" or name:gsub("%s", "") == "") then return end

    local localised_name = "fire"
    if (name:find("atomic") or name:find("nuclear")) then
        localised_name = "atomic-fire"
    end

    local quality_level_multiplier = settings.quality_level_multiplier
    local damage_multiplier = settings.damage_multiplier
    local area_multiplier = settings.area_multiplier
    local repeat_multiplier = settings.repeat_multiplier

    local __num_levels = num_levels
    local num_levels = clamp(math.ceil(__num_levels * quality_level_multiplier), max_num_levels, 5)

    local max_nuke_shockwave_movement_distance_deviation = 2
    max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

    local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

    --[[ fire ]]
    local fire_flames = {}
    for i = 1, num_levels, 1 do
        local proportion_multiplier = (num_levels - i + 1) / num_levels

        fire_flames[i] = __Data_Utils.table.merge({
            name = name .. "-fire-flame-" .. i .. "-" .. quality_name,
            -- localised_name = { "entity-name.atomic-fire-flame" },
            localised_name = { "entity-name." .. localised_name .. "-flame" },

            spawn_entity = "fire-flame",

            damage_per_tick = { amount = (42 / 60) * proportion_multiplier * damage_multiplier * quality_level_multiplier, type = "fire"},
            maximum_damage_multiplier = 1 + num_levels * proportion_multiplier * damage_multiplier * quality_level_multiplier,
            damage_multiplier_increase_per_added_fuel = 1 * damage_multiplier * quality_level_multiplier,
            damage_multiplier_decrease_per_tick = 0.005 * (1 / (proportion_multiplier * damage_multiplier * quality_level_multiplier)),

            spread_delay = 300,
            spread_delay_deviation = 180,
            --[[ TODO: Add startup setting ]]
            maximum_spread_count = 100,

            --[[ TODO: Add startup setting ]]
            emissions_per_second = { pollution = 0.005 * proportion_multiplier * quality_level_multiplier },

            --[[ TODO: Add startup settings ]]
            initial_lifetime = 150 + (num_levels - i + 1) * (3 / E) * 60 * quality_level_multiplier,
            maximum_lifetime = 150 + num_levels * (E / 1.5) * 60 * quality_level_multiplier,
        }, Util.table.deepcopy(data.raw["fire"]["fire-flame"]))
    end

    __Data_Utils.foreach(function (tbl)
        tbl.on_fuel_added_action = nil
        tbl.smoke_source_pictures = nil
        tbl.smoke = nil
        tbl.smoke_fade_in_duration = nil
        tbl.smoke_fade_out_duration = nil
    end, __Data_Utils.unpack(fire_flames))

    data:extend(fire_flames)

    --[[ fire-stickers ]]
    local fire_stickers = {}
    for i = 1, num_levels, 1 do
        local proportion_multiplier = i / num_levels
        --[[ Minimum of 5 ticks ]]
        local damage_interval = 5 + math.floor((55 * (1 / (quality_level_multiplier)) * proportion_multiplier))

        fire_stickers[i] = __Data_Utils.table.merge({
            name = name .. "-fire-sticker-" .. i .. "-" .. quality_name,
            localised_name = { "entity-name.atomic-" .. localised_name .. "-sticker" },

            --[[ TODO: Add startup settings ]]
            duration_in_ticks = 150 + (num_levels - i + 1) * (3 / E) * 60 * quality_level_multiplier,
            damage_interval = damage_interval,
            target_movement_modifier = 0.8 * (1 / (quality_level_multiplier)),
            damage_per_tick = { amount = (damage_interval * (100 / 60)) * damage_multiplier * quality_level_multiplier, type = "fire" },
            -- spread_fire_entity = "fire-flame-on-tree",
            spread_fire_entity = "fire-flame",
            fire_spread_cooldown = 30,
            fire_spread_radius = 0.25
        }, Util.table.deepcopy(data.raw["sticker"]["fire-sticker"]))
    end

    -- __Data_Utils.foreach(function (tbl)
    --     tbl.damage_per_tick.amount = tbl.damage_per_tick.amount * damage_multiplier * quality_level_multiplier
    --     tbl.fire_spread_radius = 0.25
    -- end, __Data_Utils.unpack(fire_stickers))

    data:extend(fire_stickers)

    --[[ cluster-projectiles ]]
    local cluster_projectiles = {}
    for i = 1, num_levels, 1 do
        local proportion = ((num_levels - i) + 1) / num_levels
        cluster_projectiles[i] = {
            type = "projectile",
            name = name .. "-fire-wave-spawns-cluster-" .. i .. "-" .. quality_name,
            flags = { "not-on-map" },
            hidden = true,
            acceleration = 0.001,
            action =
            {
                type = "cluster",
                cluster_count = clamp(2 + math.floor(((3 / E) * repeat_multiplier + (6.66 * proportion)) * quality_level_multiplier), UINT32),
                distance = clamp(((3 / E) * area_multiplier + 1) * quality_level_multiplier, UINT24),
                distance_deviation = clamp(((3 / E) * area_multiplier + (E / 8)) * quality_level_multiplier, UINT24),
                action_delivery =
                {
                    type = "instant",
                    radius = clamp(((3 / E) + (((E / num_levels + 1) * proportion * area_multiplier)) * quality_level_multiplier), UINT16),
                    target_effects =
                    {
                        type = "nested-result",
                        action =
                        {
                            type = "area",
                            target_entities = false,
                            trigger_from_target = true,
                            ignore_collision_condition = true,
                            radius = clamp(((3 / E) + (((E / num_levels + 1) * proportion * area_multiplier)) * quality_level_multiplier), UINT16),
                            action_delivery =
                            {
                                type = "instant",
                                radius = clamp(((3 / E) + (((E / num_levels + 1) * proportion * area_multiplier)) * quality_level_multiplier), UINT16),
                                target_effects =
                                {
                                    {
                                        type = "create-fire",
                                        entity_name = name .. "-fire-flame-" .. i .. "-" .. quality_name,
                                        repeat_count = clamp((1.25 * repeat_multiplier + 1) * quality_level_multiplier, UINT16),
                                        repeat_count_deviation = clamp((2.1 * repeat_multiplier + 1) * quality_level_multiplier, UINT16),
                                        initial_ground_flame_count = clamp(3 * repeat_multiplier + 1 * quality_level_multiplier, UINT8),
                                        show_in_tooltip = true,
                                    },
                                    {
                                        type = "create-sticker",
                                        sticker = name .. "-fire-sticker-" .. i .. "-" .. quality_name,
                                        repeat_count = clamp((1.25 * repeat_multiplier + 1) * quality_level_multiplier, UINT16),
                                        repeat_count_deviation = clamp((2.1 * repeat_multiplier + 1) * quality_level_multiplier, UINT16),
                                        show_in_tooltip = true,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            animation = nil,
            shadow = nil
        }
    end
    data:extend(cluster_projectiles)

    --[[ fire-wave actions ]]
    local fire_wave_actions = {}
    for i = 1, num_levels, 1 do
        local proportion = ((num_levels - i) + 1) / num_levels
        fire_wave_actions[i] = {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            -- repeat_count = clamp_repeat_count(1.25 * repeat_multiplier + 1, quality_level_multiplier),
            radius = clamp(((3 / E) + (((E / num_levels + 1) * proportion * area_multiplier)) * quality_level_multiplier), UINT16),
            ignore_collision_condition = true,
            action_delivery =
            {
                {
                    type = "projectile",
                    projectile = cluster_projectiles[i].name,
                    starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                    starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                },
            },
        }
    end

    --[[ fire-wave projectiles ]]
    local projectiles = {}
    for i = 1, num_levels, 1 do
        projectiles[i] = {
            type = "projectile",
            name = name .. "-fire-wave-" .. i .. "-".. quality_name,
            flags = {"not-on-map"},
            hidden = true,
            -- acceleration = 0,
            -- acceleration = 0.000012,
            acceleration = 0.0005 * quality_level_multiplier,
            -- acceleration = 0.0005 * quality_level_multiplier * base_delay,
            action =
            {
                fire_wave_actions[i],
            },
            animation = nil,
            shadow = nil
        }
    end
    data:extend(projectiles)

    --[[ projectile actions ]]
    local actions = {}
    for i = 1, num_levels, 1 do
        actions[i] = {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = clamp(((i / num_levels) * 999 * repeat_multiplier + 1) * quality_level_multiplier, UINT32),
            radius = (i / num_levels) * clamp((0.8 * (34 * area_multiplier + 1)) * quality_level_multiplier, UINT64),
            action_delivery =
            {
                type = "projectile",
                projectile = name .. "-fire-wave-" .. i .. "-" .. quality_name,
                starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
            },
        }
    end

    --[[ nested-result ]]
    local nested_result =
    {
        type = "nested-result",
        action = actions,
    }

    -- table.insert(target_effects, 1, nested_result)

    return nested_result
end