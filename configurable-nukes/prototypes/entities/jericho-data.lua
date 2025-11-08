local Util = require("__core__.lualib.util")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_REPEAT_MULTIPLIER.name })
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

local area_multiplier = get_area_multiplier()
local damage_multiplier = get_damage_multiplier()
local repeat_multiplier = get_repeat_multiplier()

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------

local original_jericho = Util.table.deepcopy(data.raw["projectile"]["explosive-rocket"])

original_jericho.name = "cn-jericho"

local jericho = nil

local create_quality_jericho = function (params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_jericho = nil
        local default_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })

        if (default_multiplier) then
            quality_jericho = Util.table.deepcopy(original_jericho)

            local quality_level_multiplier = default_multiplier ^ quality.level

            local nuke_shockwave_starting_speed_deviation = 0.075

            for k_1, v_1 in pairs(quality_jericho.action.action_delivery.target_effects) do
                if (v_1.type) then
                    if (v_1.type == "create-entity") then
                        v_1.repeat_count = clamp_repeat_count(3 * repeat_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "destroy-decoratives") then
                        v_1.radius = clamp_max_distance(v_1.radius * area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "damage") then
                        v_1.damage.amount = 400 * damage_multiplier * quality_level_multiplier
                        v_1.damage.show_in_tooltip = true
                    elseif (v_1.type == "nested-result" and v_1.action.type == "area") then
                        if (v_1.action.action_delivery and v_1.action.action_delivery.type == "instant") then
                            v_1.action.radius = clamp_max_distance(v_1.action.radius * area_multiplier * quality_level_multiplier)
                            v_1.action.action_delivery.target_effects[1].damage.amount = 400 * damage_multiplier * quality_level_multiplier
                            v_1.action.action_delivery.target_effects[1].repeat_count = clamp_repeat_count(3 * repeat_multiplier * quality_level_multiplier)
                            v_1.action.action_delivery.target_effects[1].show_in_tooltip = true
                            v_1.action.action_delivery.target_effects[2].repeat_count = clamp_max_distance(3 * repeat_multiplier * quality_level_multiplier)
                        end
                    end
                end
            end

            local cn_jericho_wave_spawns_cluster_explosion =
            {
                type = "projectile",
                name = "cn-jericho-wave-spawns-cluster-explosion-" .. k_0,
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
            data:extend({ cn_jericho_wave_spawns_cluster_explosion })

            table.insert(quality_jericho.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    show_in_tooltip = false,
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(128 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-jericho-wave-spawns-cluster-explosion-" .. k_0,
                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })

            local cn_jericho_ground_zero_projectile_action =
            {
                type = "projectile",
                name = "cn-jericho-ground-zero-projectile-" .. k_0,
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
                                type = "damage",
                                vaporize = false,
                                lower_distance_threshold = 0,
                                upper_distance_threshold = clamp_max_distance(3 * area_multiplier * quality_level_multiplier),
                                lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                                damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                                show_in_tooltip = true,
                            }
                        }
                    }
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_jericho_ground_zero_projectile_action })

            table.insert(quality_jericho.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(200 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-jericho-ground-zero-projectile-" .. k_0,
                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })

            local cn_jericho_shockwave =
            {
                type = "projectile",
                name = "cn-jericho-shockwave-" .. k_0,
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
                                type = "damage",
                                vaporize = false,
                                lower_distance_threshold = 0,
                                upper_distance_threshold = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                                lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                                upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                                damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                                show_in_tooltip = true,
                            }
                        }
                    }
                },
                animation = nil,
                shadow = nil
            }
            data:extend({ cn_jericho_shockwave })

            table.insert(quality_jericho.action.action_delivery.target_effects,
            {
                type = "nested-result",
                action =
                {
                    type = "area",
                    target_entities = false,
                    trigger_from_target = true,
                    repeat_count = clamp_repeat_count(200 * repeat_multiplier * quality_level_multiplier),
                    radius = clamp_max_distance(12 * area_multiplier * quality_level_multiplier),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = "cn-jericho-shockwave-" .. k_0,
                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * area_multiplier * quality_level_multiplier
                    }
                }
            })
        end

        if (quality_jericho ~= nil) then
            if (k_0 == "normal") then
                jericho = Util.table.deepcopy(quality_jericho)

                local jericho_item = data.raw["ammo"]["cn-jericho"]

                if (jericho_item.icon) then
                    jericho.icon = Util.table.deepcopy(jericho_item.icon)
                else
                    jericho.icons = Util.table.deepcopy(jericho_item.icons)
                end

                data:extend({jericho})
            end

            quality_jericho.name = quality_jericho.name .. "-" .. k_0

            return quality_jericho
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "normal") then
            jericho = create_quality_jericho({ quality_level = "normal", quality = { level = quality.level }})
        else
            jericho = create_quality_jericho({ quality_level = k_0, quality = quality })
        end

        if (jericho) then
            data:extend({jericho})
        end
    end
else
    jericho = create_quality_jericho({ quality_level = "normal", quality = { level = 0 } })

    if (jericho) then
        data:extend({jericho})
    end
end