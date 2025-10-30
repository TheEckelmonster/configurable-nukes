local Util = require("__core__.lualib.util")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_REPEAT_MULTIPLIER.name })
end

local clamp_max_distance = function (value, multiplier)
    local modified_value = value * multiplier

    if (modified_value > 65535) then
        modified_value = 65535
    end

    return modified_value
end

local clamp_repeat_count = function (value, multiplier)
    local modified_value = value * multiplier

    if (modified_value > 65535) then
        modified_value = 65535
    end

    return modified_value
end

local clamp_initial_ground_ground_flame_count = function (value, multiplier)
    local modified_value = value * multiplier

    if (modified_value > 255) then
        modified_value = 255
    end

    return modified_value
end

local area_multiplier = get_area_multiplier()
local damage_multiplier = get_damage_multiplier()
local repeat_multiplier = get_repeat_multiplier()

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 19 * area_multiplier

local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------

local original_rod_from_god = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

original_rod_from_god.name = "cn-rod-from-god"

for k, v in pairs(original_rod_from_god.animation.layers) do
    if (v.filename == "__base__/graphics/entity/rocket/rocket-tinted-tip.png") then
        v.tint = { 31, 7, 81, 95 }
    end
end

local target_effects = original_rod_from_god.action.action_delivery.target_effects
local i, num_loops = 1, 1
while i <= #target_effects do
    if (num_loops > 2 ^ 10) then break end
    local do_increment = true

    if (target_effects[i].type == "damage" and target_effects[i].damage and target_effects[i].damage.type and target_effects[i].damage.type == "explosion") then
        target_effects[i].damage.amount = target_effects[i].damage.amount / 2
        local physical_damage = Util.table.deepcopy(target_effects[i])
        physical_damage.damage.type = "physical"
        table.insert(target_effects, i + 1, physical_damage)
        i = i + 1
    elseif (target_effects[i].type == "create-entity" and target_effects[i].entity_name and target_effects[i].entity_name == "nuke-explosion") then
        table.remove(target_effects, i)
        do_increment = false
    elseif (target_effects[i].type == "create-decorative" and target_effects[i].decorative and target_effects[i].decorative == "nuclear-ground-patch") then
        table.remove(target_effects, i)
        do_increment = false
    end

    if (do_increment) then i = i + 1 end
    num_loops = num_loops + 1
end

local rod_from_god = nil

local create_quality_rod_from_god = function (params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_rod_from_god = nil
        local default_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })

        if (default_multiplier) then
            quality_rod_from_god = Util.table.deepcopy(original_rod_from_god)

            local quality_level_multiplier = default_multiplier ^ quality.level

            data:extend(
            {
                {
                    type = "projectile",
                    name = "cn-rod-from-god-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
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
                                entity_name = "atomic-nuke-shockwave",
                                max_movement_distance = max_nuke_shockwave_movement_distance * quality_level_multiplier,
                                max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * quality_level_multiplier,
                                inherit_movement_distance_from_projectile = true,
                                cycle_while_moving = true
                                }
                            }
                        }
                    }
                    },
                    animation = nil,
                    shadow = nil
                },
                {
                    type = "projectile",
                    name = "cn-rod-from-god-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
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
                                entity_name = "atomic-fire-smoke",
                                max_movement_distance = max_nuke_shockwave_movement_distance * quality_level_multiplier,
                                max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * quality_level_multiplier,
                                inherit_movement_distance_from_projectile = true,
                                cycle_while_moving = true
                                }
                            }
                        }
                    }
                    },
                    animation = nil,
                    shadow = nil
                },
            })

            local rod_from_god_ground_zero_projectile_action =
            {
                type = "area",
                radius = 3 * area_multiplier * quality_level_multiplier,
                ignore_collision_condition = true,
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        {
                            type = "damage",
                            vaporize = true,
                            lower_distance_threshold = 0,
                            upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                            lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                            upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                            damage = {amount = 50 * damage_multiplier * quality_level_multiplier, type = "physical"},
                        },
                        {
                            type = "damage",
                            vaporize = true,
                            lower_distance_threshold = 0,
                            upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                            lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                            upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                            damage = {amount = 50 * damage_multiplier * quality_level_multiplier, type = "explosion"}
                        },
                    }
                }
            }

            local rod_from_god_wave_action =
            {
                type = "area",
                radius = 3 * area_multiplier * quality_level_multiplier,
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
                            upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                            lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                            upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                            damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "physical" },
                        },
                        {
                            type = "damage",
                            vaporize = false,
                            lower_distance_threshold = 0,
                            upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                            lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                            upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                            damage = { amount = 200 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                        },
                    },
                }
            }


            data:extend({
                {
                    type = "projectile",
                    name = "cn-rod-from-god-ground-zero-projectile-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        rod_from_god_ground_zero_projectile_action
                    },
                    animation = nil,
                    shadow = nil
                },
                {
                    type = "projectile",
                    name = "cn-rod-from-god-wave-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        rod_from_god_wave_action
                    },
                    animation = nil,
                    shadow = nil
                },
            })

            for k_1, v_1 in pairs(quality_rod_from_god.action.action_delivery.target_effects) do
                if (v_1.type) then
                    if (v_1.type == "destroy-cliffs") then
                        v_1.radius = v_1.radius * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "camera-effect") then
                        v_1.full_strength_max_distance = clamp_max_distance(v_1.full_strength_max_distance, area_multiplier * quality_level_multiplier)
                        v_1.max_distance = clamp_max_distance(v_1.max_distance, area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "play-sound") then
                        v_1.max_distance = clamp_max_distance(v_1.max_distance, area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "destroy-decoratives") then
                        v_1.radius = v_1.radius * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "create-decoratives") then
                        v_1.spawn_min = v_1.spawn_min * area_multiplier * quality_level_multiplier
                        v_1.spawn_max = v_1.spawn_max * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "damage") then
                        v_1.damage.amount = v_1.damage.amount * damage_multiplier * quality_level_multiplier
                    elseif (v_1.type == "nested-result" and v_1.action.type == "area") then
                        if (v_1.action.action_delivery and v_1.action.action_delivery.type == "projectile") then
                            if (v_1.action.action_delivery.projectile:find("atomic-bomb-ground-zero-projectile", 1, true)) then
                                v_1.action =
                                {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                    radius = 7 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "cn-rod-from-god-ground-zero-projectile-" .. k_0,
                                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-bomb-wave-spawns-cluster-nuke-explosion", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                    radius = v_1.action.radius * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-bomb-wave-spawns-fire-smoke-explosion", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                    radius = v_1.action.radius * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                        {
                                            type = "projectile",
                                            projectile = "cn-rod-from-god-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
                                            starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                        }
                                    }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-bomb-wave-spawns-nuke-shockwave-explosion", 1, true)) then
                                v_1.action = {
                                type = "area",
                                show_in_tooltip = false,
                                target_entities = false,
                                trigger_from_target = true,
                                repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                radius = v_1.action.radius * area_multiplier * quality_level_multiplier,
                                action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "cn-rod-from-god-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-bomb-wave-spawns-nuclear-smoke", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                    radius = v_1.action.radius * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-bomb-wave", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(v_1.action.repeat_count, repeat_multiplier * quality_level_multiplier),
                                    radius = v_1.action.radius * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "cn-rod-from-god-wave-" .. k_0,
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            end
                        end
                    end
                end
            end

            local target_effects = quality_rod_from_god.action.action_delivery.target_effects
            local indices_to_remove = {}

            for k, v in pairs(target_effects) do
                if (v.type and v.type == "nested-result") then
                    if (    v.action
                        and v.action.action_delivery
                        and v.action.action_delivery.target_effects
                        and v.action.action_delivery.target_effects[1]
                        and v.action.action_delivery.target_effects[1].type == "script"
                        and v.action.action_delivery.target_effects[1].effect_id
                        and v.action.action_delivery.target_effects[1].effect_id:find("%-pollution$")
                    ) then
                        table.insert(indices_to_remove, k)
                    end
                end
            end
            local i = #indices_to_remove
            while i >= 1 do
                table.remove(target_effects, indices_to_remove[i])
                i = i - 1
            end

            quality_rod_from_god.action.action_delivery.target_effects = target_effects

            if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_FIRE_WAVE.name })) then
                local target_effects = quality_rod_from_god.action.action_delivery.target_effects
                table.insert(target_effects,
                    {
                        type = "nested-result",
                        action = {
                            {
                                type = "area",
                                radius = clamp_max_distance((26 * area_multiplier + 1), quality_level_multiplier),
                                repeat_count = clamp_repeat_count((10 * repeat_multiplier + 1), quality_level_multiplier),
                                action_delivery =
                                {
                                    type = "instant",
                                    radius = (2.5 * area_multiplier + 1), quality_level_multiplier,
                                    repeat_count = clamp_repeat_count((10 * repeat_multiplier + 1), quality_level_multiplier),
                                    target_effects =
                                    {
                                        {
                                            type = "create-sticker",
                                            sticker = "fire-sticker",
                                            show_in_tooltip = true
                                        },
                                        {
                                            type = "create-fire",
                                            entity_name = "fire-flame",
                                            repeat_count = clamp_repeat_count((10 * repeat_multiplier + 1), quality_level_multiplier),
                                            repeat_count_deviation = clamp_repeat_count((42 * repeat_multiplier), quality_level_multiplier),
                                            show_in_tooltip = true,
                                            initial_ground_flame_count = clamp_initial_ground_ground_flame_count(3, quality_level_multiplier)
                                        }
                                    }
                                }
                            }
                        },
                    }
                )
                quality_rod_from_god.action.action_delivery.target_effects = target_effects
            end
        end

        if (quality_rod_from_god ~= nil) then
            if (k_0 == "normal") then
                rod_from_god = Util.table.deepcopy(quality_rod_from_god)

                local rod_from_god_item = data.raw["ammo"]["cn-rod-from-god"]

                if (rod_from_god_item.icon) then
                    rod_from_god.icon = Util.table.deepcopy(rod_from_god_item.icon)
                else
                    rod_from_god.icons = Util.table.deepcopy(rod_from_god_item.icons)
                end

                data:extend({rod_from_god})
            end

            quality_rod_from_god.name = quality_rod_from_god.name .. "-" .. k_0
            data:extend({quality_rod_from_god})

            return quality_rod_from_god
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "normal") then
            rod_from_god = create_quality_rod_from_god({ quality_level = "normal", quality = { level = quality.level }})
        else
            rod_from_god = create_quality_rod_from_god({ quality_level = k_0, quality = quality })
        end
    end
else
    rod_from_god = create_quality_rod_from_god({ quality_level = "normal", quality = { level = 0 } })

    if (rod_from_god) then
        data:extend({rod_from_god})
    end
end