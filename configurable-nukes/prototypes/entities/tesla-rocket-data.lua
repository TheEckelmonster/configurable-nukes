local Util = require("__core__.lualib.util")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TESLA_ROCKET_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TESLA_ROCKET_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.TESLA_ROCKET_REPEAT_MULTIPLIER.name })
end

local function clamp_max_distance(value)
    local return_val = value

    if (return_val > 65535) then
        return_val = 65535
    end

    return return_val
end

local function clamp_repeat_count(value)
    local return_val = value

    if (return_val > 65535) then
        return_val = 65535
    end

    return return_val
end

local function clamp_percent_count(value)
    local return_val = value

    if (return_val > 1) then
        return_val = 1
    end

    if (return_val < 0) then
        return_val = 0
    end

    return return_val
end

local area_multiplier = get_area_multiplier()
local damage_multiplier = get_damage_multiplier()
local repeat_multiplier = get_repeat_multiplier()

local max_shockwave_movement_distance_deviation = 2
max_shockwave_movement_distance_deviation = max_shockwave_movement_distance_deviation * area_multiplier

local max_shockwave_movement_distance = 19 + max_shockwave_movement_distance_deviation / 6
max_shockwave_movement_distance = 19 * area_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------

local original_tesla_rocket = Util.table.deepcopy(data.raw["projectile"]["rocket"])
original_tesla_rocket.name = "cn-tesla-rocket"

local original_tesla_beam_chain_bounce = Util.table.deepcopy(data.raw["beam"]["chain-tesla-turret-beam-bounce"])
original_tesla_beam_chain_bounce.name = "cn-chain-tesla-rocket-beam-bounce"

local tesla_rocket = nil

local function create_quality_tesla_rocket(params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_tesla_rocket = nil
        local quality_tesla_beam_chain_bounce = nil
        local default_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })

        if (default_multiplier) then
            quality_tesla_rocket = Util.table.deepcopy(original_tesla_rocket)
            quality_tesla_beam_chain_bounce = Util.table.deepcopy(original_tesla_beam_chain_bounce)

            local quality_level_multiplier = default_multiplier ^ quality.level

            --[[ rocket ]]
            for k_1, v_1 in pairs(quality_tesla_rocket.action.action_delivery.target_effects) do
                if (v_1.type) then
                    if (v_1.type == "destroy-decoratives") then
                        v_1.radius = clamp_max_distance(v_1.radius * area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "damage") then
                        v_1.damage.amount = v_1.damage.amount * damage_multiplier * quality_level_multiplier
                        v_1.damage.show_in_tooltip = true
                    end
                end
            end

            local cn_tesla_rocket_sticker_stun =
            {
                type = "sticker",
                name = "cn-tesla-rocket-stun",
                flags = { "not-on-map" },
                hidden = true,
                duration_in_ticks = 30 * quality_level_multiplier,
                target_movement_modifier = 0.05 * quality_level_multiplier,
                vehicle_speed_modifier = 0.25 * quality_level_multiplier,
            }
            data:extend({cn_tesla_rocket_sticker_stun})

            local cn_tesla_rocket_sticker_slow =
            {
                type = "sticker",
                name = "cn-tesla-rocket-slow",
                flags = { "not-on-map" },
                hidden = true,
                duration_in_ticks = 120 * quality_level_multiplier,
                target_movement_modifier = 0.5 * quality_level_multiplier,
                vehicle_speed_modifier = 0.75 * quality_level_multiplier,
            }
            data:extend({cn_tesla_rocket_sticker_slow})

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                damage = {
                    amount = 800 * damage_multiplier * quality_level_multiplier,
                    type = "electric"
                },
                type = "damage"
            })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                distance = clamp_max_distance(0.25 * area_multiplier * quality_level_multiplier),
                type = "push-back"
            })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                sticker = "cn-tesla-rocket-stun",
                type = "create-sticker"
            })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                sticker = "cn-tesla-rocket-slow",
                type = "create-sticker"
            })

            --[[ beam-chain-bounce ]]
            for k_1, v_1 in pairs(quality_tesla_beam_chain_bounce.action.action_delivery.target_effects) do
                if (v_1.type) then
                    if (v_1.type == "damage") then
                        v_1.damage.amount = 160 * ((damage_multiplier + quality_level_multiplier) ^ 0.5)
                        v_1.damage.show_in_tooltip = true
                    elseif (v_1.type == "push-back") then
                        v_1.distance = clamp_max_distance(v_1.distance * area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "create-sticker") then
                        if (v_1.sticker == "tesla-turret-stun") then
                            v_1.sticker = "cn-tesla-rocket-stun"
                        elseif (v_1.sticker == "tesla-turret-slow") then
                            v_1.sticker = "cn-tesla-rocket-slow"
                        end

                        v_1.repeat_count = clamp_repeat_count(2 * repeat_multiplier * quality_level_multiplier)
                    end
                end
            end

            quality_tesla_beam_chain_bounce.name = quality_tesla_beam_chain_bounce.name .. "-" .. k_0
            data:extend({ quality_tesla_beam_chain_bounce })

            data:extend({
                {
                    name = "cn-tesla-rocket-chain-" .. k_0,
                    type = "chain-active-trigger",
                    max_jumps = clamp_repeat_count(24 * ((repeat_multiplier * quality_level_multiplier) ^ 0.25)),
                    max_range_per_jump = clamp_max_distance(12 * ((area_multiplier * quality_level_multiplier) ^ 0.25)),
                    jump_delay_ticks = 6,
                    fork_chance = clamp_percent_count(0.35 --[[* quality_level_multiplier]]),
                    fork_chance_increase_per_quality_level = clamp_percent_count(0.04 --[[* quality_level_multiplier]]),
                    action =
                    {
                        type = "direct",
                        action_delivery =
                        {
                            type = "beam",
                            beam = "cn-chain-tesla-rocket-beam-bounce-" .. k_0,
                            max_length = clamp_max_distance(12 * ((area_multiplier * quality_level_multiplier) ^ 0.25)) + 0.5,
                            duration = 30,
                            add_to_shooter = false,
                            destroy_with_source_or_target = false,
                            source_offset = { 0, 0 }, -- should match beam's target_offset
                        },
                    },
                }
            })

            local nuke_shockwave_starting_speed_deviation = 0.075

            local cn_tesla_rocket_wave_spawns_cluster_explosion =
            {
                type = "projectile",
                name = "cn-tesla-rocket-wave-spawns-cluster-explosion-" .. k_0,
                flags = { "not-on-map" },
                hidden = true,
                acceleration = 0.001,
                speed_modifier = { 1.0, 0.707 },
                action =
                {
                    {
                        type = "direct",
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "create-entity",
                                    entity_name = "cluster-nuke-explosion",
                                }
                            }
                        }
                    }
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_tesla_rocket_wave_spawns_cluster_explosion })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    show_in_tooltip = false,
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(128 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(16 * ((area_multiplier * quality_level_multiplier) ^ 0.25)),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-tesla-rocket-wave-spawns-cluster-explosion-" .. k_0,
                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })

            local cn_tesla_rocket_ground_zero_projectile_action =
            {
                type = "projectile",
                name = "cn-tesla-rocket-ground-zero-projectile-" .. k_0,
                flags = { "not-on-map" },
                hidden = true,
                acceleration = 0,
                speed_modifier = { 1.0, 0.707 },
                action =
                {
                    {
                        type = "area",
                        radius = clamp_max_distance(3 * area_multiplier * quality_level_multiplier),
                        ignore_collision_condition = true,
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "nested-result",
                                    action =
                                    {
                                        type = "direct",
                                        action_delivery =
                                        {
                                            type = "chain",
                                            chain = "cn-tesla-rocket-chain-" .. k_0,
                                            show_in_tooltip = true,
                                        }
                                    }
                                },
                                {
                                    type = "damage",
                                    vaporize = false,
                                    lower_distance_threshold = 0,
                                    upper_distance_threshold = clamp_max_distance(3 * area_multiplier * quality_level_multiplier),
                                    lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                    upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                                    damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                                    show_in_tooltip = true,
                                },
                                {
                                    type = "damage",
                                    vaporize = false,
                                    lower_distance_threshold = 0,
                                    upper_distance_threshold = clamp_max_distance(3 * area_multiplier * quality_level_multiplier),
                                    lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                    upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                                    damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "electric" },
                                    show_in_tooltip = true,
                                },
                            },
                        },
                    },
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_tesla_rocket_ground_zero_projectile_action })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(16 * ((repeat_multiplier * quality_level_multiplier) ^ 0.25)),
                    radius = clamp_max_distance(16 * ((area_multiplier * quality_level_multiplier) ^ 0.25)),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-tesla-rocket-ground-zero-projectile-" .. k_0,
                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                type = "script",
                effect_id = "cn-tesla-rocket-lightning",
            })


            local function create_shockwave_animations()
                return
                {
                    {
                        filename = "__base__/graphics/entity/smoke/nuke-shockwave-1.png",
                        draw_as_glow = true,
                        priority = "high",
                        flags = { "smoke" },
                        line_length = 8,
                        width = 132,
                        height = 136,
                        frame_count = 32,
                        animation_speed = 0.5,
                        shift = util.by_pixel(-0.5, 0),
                        -- scale = 1.5,
                        scale = 1,
                        usage = "explosion"
                    },
                    {
                        filename = "__base__/graphics/entity/smoke/nuke-shockwave-2.png",
                        draw_as_glow = true,
                        priority = "high",
                        flags = { "smoke" },
                        line_length = 8,
                        width = 110,
                        height = 128,
                        frame_count = 32,
                        animation_speed = 0.5,
                        shift = util.by_pixel(0, 3),
                        -- scale = 1.5,
                        scale = 1,
                        usage = "explosion"
                    }
                }
            end

            local cn_tesla_rocket_shockwave_explosion =
            {
                type = "explosion",
                name = "cn-tesla-rocket-shockwave-explosion" .. k_0,
                icon = "__base__/graphics/icons/destroyer.png",
                flags = { "not-on-map" },
                hidden = true,
                subgroup = "explosions",
                height = 1.4,
                rotate = true,
                correct_rotation = true,
                fade_out_duration = 30,
                scale_out_duration = 40,
                scale_in_duration = 10,
                scale_initial = 0.1,
                -- scale = 1,
                scale = 0.5,
                scale_deviation = 0.2,
                scale_end = 0.5,
                scale_increment_per_tick = 0.005,
                scale_animation_speed = true,

                animations = create_shockwave_animations(),
            }
            data:extend({ cn_tesla_rocket_shockwave_explosion })

            local cn_tesla_rocket_wave_spawns_shockwave_explosion =
            {
                type = "projectile",
                name = "cn-tesla-rocket-wave-spawns-nuke-shockwave-explosion-" .. k_0,
                flags = {"not-on-map"},
                hidden = true,
                acceleration = 0,
                speed_modifier = { 1, 0.707 },
                action =
                {
                    {
                        type = "direct",
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "create-explosion",
                                    entity_name = "cn-tesla-rocket-shockwave-explosion" .. k_0,
                                    max_movement_distance = max_shockwave_movement_distance,
                                    max_movement_distance_deviation = max_shockwave_movement_distance_deviation,
                                    inherit_movement_distance_from_projectile = true,
                                    cycle_while_moving = true
                                }
                            }
                        }
                    }
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_tesla_rocket_wave_spawns_shockwave_explosion })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    show_in_tooltip = false,
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(512 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(16 * ((area_multiplier * quality_level_multiplier) ^ 0.25)) + 2,
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-tesla-rocket-wave-spawns-nuke-shockwave-explosion-" .. k_0,
                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier,
                    }
                }
            })

            local cn_tesla_rocket_shockwave =
            {
                type = "projectile",
                name = "cn-tesla-rocket-shockwave-" .. k_0,
                flags = { "not-on-map" },
                hidden = true,
                acceleration = 0,
                speed_modifier = { 1.0, 0.707 },
                action =
                {
                    {
                        type = "area",
                        radius = clamp_max_distance(3 * area_multiplier * quality_level_multiplier),
                        ignore_collision_condition = true,
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    vaporize = false,
                                    lower_distance_threshold = 0,
                                    upper_distance_threshold = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                                    lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                    upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                                    damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                                    show_in_tooltip = true,
                                },
                                {
                                    type = "damage",
                                    vaporize = false,
                                    lower_distance_threshold = 0,
                                    upper_distance_threshold = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                                    lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                    upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                                    damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "electric" },
                                    show_in_tooltip = true,
                                },
                            }
                        }
                    }
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_tesla_rocket_shockwave })

            table.insert(quality_tesla_rocket.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(200 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(16 * ((area_multiplier * quality_level_multiplier) ^ 0.25)),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-tesla-rocket-shockwave-" .. k_0,
                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })
        end

        if (quality_tesla_rocket ~= nil) then
            if (k_0 == "normal") then
                tesla_rocket = Util.table.deepcopy(quality_tesla_rocket)

                local tesla_rocket_item = data.raw["ammo"]["cn-tesla-rocket"]

                if (tesla_rocket_item.icon) then
                    tesla_rocket.icon = Util.table.deepcopy(tesla_rocket_item.icon)
                else
                    tesla_rocket.icons = Util.table.deepcopy(tesla_rocket_item.icons)
                end

                data:extend({tesla_rocket})
            end

            quality_tesla_rocket.name = quality_tesla_rocket.name .. "-" .. k_0

            return quality_tesla_rocket
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "normal") then
            tesla_rocket = create_quality_tesla_rocket({ quality_level = "normal", quality = { level = quality.level }})
        else
            tesla_rocket = create_quality_tesla_rocket({ quality_level = k_0, quality = quality })
        end

        if (tesla_rocket) then
            data:extend({tesla_rocket})
        end
    end
else
    tesla_rocket = create_quality_tesla_rocket({ quality_level = "normal", quality = { level = 0 } })

    if (tesla_rocket) then
        data:extend({tesla_rocket})
    end
end