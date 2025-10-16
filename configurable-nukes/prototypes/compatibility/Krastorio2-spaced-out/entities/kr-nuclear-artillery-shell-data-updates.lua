local Util = require("__core__.lualib.util")

local Data_Utils = require("data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

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

local area_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AREA_MULTIPLIER.name })
local damage_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_DAMAGE_MULTIPLIER.name })
local repeat_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_REPEAT_MULTIPLIER.name })

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 19 * area_multiplier

local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------
local original_nuclear_artillery_shell = Util.table.deepcopy(data.raw["artillery-projectile"]["kr-atomic-artillery-projectile"])

local nuclear_artillery_shell = nil

local create_quality_nuclear_artillery_shell = function (params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_nuclear_artillery_shell = nil
        local default_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })

        if (default_multiplier) then
            quality_nuclear_artillery_shell = Util.table.deepcopy(original_nuclear_artillery_shell)

            local quality_level_multiplier = default_multiplier ^ quality.level

            data:extend(
            {
                {
                    type = "projectile",
                    name = "kr-atomic-artillery-projectile-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
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
                    name = "kr-atomic-artillery-projectile-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
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

            local nuclear_artillery_shell_ground_zero_projectile_action =
            {
                type = "area",
                radius = 3 * area_multiplier * quality_level_multiplier,
                ignore_collision_condition = true,
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        type = "damage",
                        vaporize = true,
                        lower_distance_threshold = 0,
                        upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                        lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                        upper_damage_modifier = 0.01 * damage_multiplier * quality_level_multiplier,
                        damage = {amount = 100 * damage_multiplier * quality_level_multiplier, type = "explosion"}
                    }
                }
            }

            local nuclear_artillery_shell_wave_action =
            {
                type = "area",
                radius = 3 * area_multiplier * quality_level_multiplier,
                ignore_collision_condition = true,
                action_delivery =
                {
                    type = "instant",
                    target_effects =
                    {
                        type = "damage",
                        vaporize = false,
                        lower_distance_threshold = 0,
                        upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                        lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                        upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                        damage = { amount = 400 * damage_multiplier * quality_level_multiplier, type = "explosion" }
                    }
                }
            }

            nuclear_artillery_shell_wave_action.action_delivery =
            {
                type = "instant",
                target_effects = {
                    type = "damage",
                    vaporize = false,
                    lower_distance_threshold = 0,
                    upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                    damage = { amount = 100 * damage_multiplier * quality_level_multiplier, type = "explosion" },
                },
                {
                    type = "damage",
                    vaporize = false,
                    lower_distance_threshold = 0,
                    upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.25 * damage_multiplier * quality_level_multiplier,
                    damage = { amount = 100 * damage_multiplier * quality_level_multiplier, type = "kr-radioactive" },
                },
                {
                    type = "damage",
                    vaporize = false,
                    lower_distance_threshold = 0,
                    upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                    damage = { amount = 100 * damage_multiplier * quality_level_multiplier, type = "kr-explosion" },
                },
            }

            data:extend({
                {
                    type = "projectile",
                    name = "kr-atomic-artillery-projectile-ground-zero-projectile-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        nuclear_artillery_shell_ground_zero_projectile_action
                    },
                    animation = nil,
                    shadow = nil
                },
                {
                    type = "projectile",
                    name = "kr-atomic-artillery-projectile-wave-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        nuclear_artillery_shell_wave_action
                    },
                    animation = nil,
                    shadow = nil
                },
            })

            for k_1, v_1 in pairs(quality_nuclear_artillery_shell.action.action_delivery.target_effects) do
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
                                        projectile = "kr-atomic-artillery-projectile-ground-zero-projectile-" .. k_0,
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
                                            projectile = "kr-atomic-artillery-projectile-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
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
                                        projectile = "kr-atomic-artillery-projectile-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
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
                                        projectile = "kr-atomic-artillery-projectile-wave-" .. k_0,
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            end
                        end
                    end
                end
            end

            -- if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_ARTILLERY_SHELL_POLUTION.name })) then
                local target_effects = quality_nuclear_artillery_shell.action.action_delivery.target_effects
                table.insert(target_effects,
                    {
                        type = "nested-result",
                        action = {
                            action_delivery = {
                                target_effects = {
                                    {
                                        type = "script",
                                        effect_id = "k2-atomic-artillery-pollution"
                                    }
                                },
                                type = "instant"
                            },
                            radius = (26 * area_multiplier + 1) * quality_level_multiplier,
                            repeat_count = clamp_repeat_count((1000 * repeat_multiplier + 1), quality_level_multiplier),
                            repeat_count_deviation = clamp_repeat_count((42 * repeat_multiplier), quality_level_multiplier),
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                    }
                )
                quality_nuclear_artillery_shell.action.action_delivery.target_effects = target_effects
            -- end

            if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_FIRE_WAVE.name })) then
                local target_effects = quality_nuclear_artillery_shell.action.action_delivery.target_effects
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
                quality_nuclear_artillery_shell.action.action_delivery.target_effects = target_effects
            end
        end

        if (quality_nuclear_artillery_shell ~= nil) then
            if (k_0 == "normal") then
                nuclear_artillery_shell = Util.table.deepcopy(quality_nuclear_artillery_shell)
                local nuclear_artillery_shell_ammo_item = data.raw["ammo"]["kr-nuclear-artillery-shell"]

                if (nuclear_artillery_shell_ammo_item.icon) then
                    nuclear_artillery_shell.icon = Util.table.deepcopy(nuclear_artillery_shell_ammo_item.icon)
                else
                    nuclear_artillery_shell.icons = Util.table.deepcopy(nuclear_artillery_shell_ammo_item.icons)
                end

                if (not nuclear_artillery_shell.icon and not nuclear_artillery_shell.icons) then
                    nuclear_artillery_shell.icon = "__Krastorio2Assets__/icons/ammo/nuclear-artillery-shell.png"
                end

                data:extend({nuclear_artillery_shell})
            end

            quality_nuclear_artillery_shell.name = quality_nuclear_artillery_shell.name .. "-" .. k_0
            data:extend({quality_nuclear_artillery_shell})

            return quality_nuclear_artillery_shell
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        nuclear_artillery_shell = create_quality_nuclear_artillery_shell({ quality_level = k_0, quality = quality })
    end
else
    nuclear_artillery_shell = create_quality_nuclear_artillery_shell({ quality_level = "normal", quality = { level = 0 } })
end

if (nuclear_artillery_shell) then
    data:extend({nuclear_artillery_shell})
end

nuclear_artillery_shell = data.raw["artillery-projectile"]["kr-atomic-artillery-projectile"]

local nuclear_artillery_shell_placeholder = Util.table.deepcopy(nuclear_artillery_shell)
nuclear_artillery_shell_placeholder.name = "kr-atomic-artillery-projectile-placeholder"

nuclear_artillery_shell_placeholder.animation = nil
nuclear_artillery_shell_placeholder.shadow = nil
nuclear_artillery_shell_placeholder.smoke = nil

local indices_to_remove = {}
for k, v in pairs(nuclear_artillery_shell_placeholder.action.action_delivery.target_effects) do
    if (    v.type ~= "destroy-cliffs"
        and v.type ~= "damage"
        and v.type ~= "nested-result"
        )
    then
        table.insert(indices_to_remove, k)
    elseif (v.type == "nested-result") then
        if (    v.action.action_delivery
            and v.action.action_delivery.projectile
            and v.action.action_delivery.projectile ~= "kr-atomic-artillery-projectile-ground-zero-projectile"
            and v.action.action_delivery.projectile ~= "kr-atomic-artillery-projectile-ground-zero-projectile-normal"
            and v.action.action_delivery.projectile ~= "kr-atomic-artillery-projectile-wave"
            and v.action.action_delivery.projectile ~= "kr-atomic-artillery-projectile-wave-normal"
        ) then
            table.insert(indices_to_remove, k)
        end
    end
end

for i = #indices_to_remove, 1, -1 do
    table.remove(nuclear_artillery_shell_placeholder.action.action_delivery.target_effects, indices_to_remove[i])
end

data:extend({nuclear_artillery_shell_placeholder})