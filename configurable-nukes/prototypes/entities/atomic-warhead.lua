local Util = require("__core__.lualib.util")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_AREA_MULTIPLIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_AREA_MULTIPLIER.name].value
    end

    return setting
end

-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DAMAGE_MULTIPLIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DAMAGE_MULTIPLIER.name].value
    end

    return setting
end

-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_REPEAT_MULTIPLIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_REPEAT_MULTIPLIER.name].value
    end

    return setting
end

-- FIRE_WAVE
local get_fire_wave = function ()
    local setting = false

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_FIRE_WAVE.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_FIRE_WAVE.name].value
    end

    return setting
end

-- QUALITY_BASE_MODIFIER
local get_quality_base_multiplier = function ()
    local setting = 1.3

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name].value
    end

    return setting
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

local original_atomic_warhead = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

original_atomic_warhead.name = "atomic-warhead"
original_atomic_warhead.icon = "__base__/graphics/icons/signal/signal-radioactivity.png"

for k, v in pairs(original_atomic_warhead.action.action_delivery.target_effects) do
    if (v.type == "nested-result") then
        if (v.action.type == "area") then
            local projectile_object = nil
            if (v.action.action_delivery.type == "projectile") then
                projectile_object = v.action.action_delivery
            elseif (v.action.action_delivery[1] and v.action.action_delivery[1].projectile) then
                projectile_object = v.action.action_delivery[1]
            elseif (v.action.action_delivery[1] and v.action.action_delivery[2] and v.action.action_delivery[2].projectile) then
                projectile_object = v.action.action_delivery[2]
            end

            if (projectile_object and projectile_object.projectile) then
                if (projectile_object.projectile:find("atomic-bomb", 1, true)) then
                    local raw_object = data.raw["projectile"][projectile_object.projectile]

                    if (raw_object) then
                        local atomic_warhead_object = Util.table.deepcopy(raw_object)
                        atomic_warhead_object.name = projectile_object.projectile:gsub("atomic%-bomb", "atomic-warhead")

                        projectile_object.projectile = projectile_object.projectile:gsub("atomic%-bomb", "atomic-warhead")

                        data:extend({ atomic_warhead_object })
                    end
                end
            end
        end
    end
end

local atomic_warhead = nil

local create_quality_atomic_warhead = function (params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_atomic_warhead = nil
        local default_multiplier = get_quality_base_multiplier()

        if (default_multiplier) then
            quality_atomic_warhead = Util.table.deepcopy(original_atomic_warhead)

            local quality_level_multiplier = default_multiplier ^ quality.level

            data:extend(
            {
                {
                    type = "projectile",
                    name = "atomic-warhead-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
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
                    name = "atomic-warhead-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
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

            local atomic_warhead_ground_zero_projectile_action =
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
                        damage = { amount = 100 * damage_multiplier * quality_level_multiplier, type = "explosion" }
                    }
                }
            }

            local atomic_warhead_wave_action =
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
                        lower_distance_threshold = 0 * area_multiplier * quality_level_multiplier,
                        upper_distance_threshold = clamp_max_distance(35, area_multiplier * quality_level_multiplier),
                        lower_damage_modifier = 1 * damage_multiplier * quality_level_multiplier,
                        upper_damage_modifier = 0.1 * damage_multiplier * quality_level_multiplier,
                        damage = { amount = 400 * damage_multiplier * quality_level_multiplier, type = "explosion" }
                    },
                },
            }

            data:extend({
                {
                    type = "projectile",
                    name = "atomic-warhead-ground-zero-projectile-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        atomic_warhead_ground_zero_projectile_action
                    },
                    animation = nil,
                    shadow = nil
                },
                {
                    type = "projectile",
                    name = "atomic-warhead-wave-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        atomic_warhead_wave_action,
                    },
                    animation = nil,
                    shadow = nil
                },
            })

            for k_1, v_1 in pairs(quality_atomic_warhead.action.action_delivery.target_effects) do
                if (v_1.type) then
                    if (v_1.type == "destroy-cliffs") then
                        v_1.radius = 9 * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "camera-effect") then
                        v_1.full_strength_max_distance = clamp_max_distance(200, area_multiplier * quality_level_multiplier)
                        v_1.max_distance = clamp_max_distance(800, area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "play-sound") then
                        v_1.max_distance = clamp_max_distance(1000, area_multiplier * quality_level_multiplier)
                    elseif (v_1.type == "destroy-decoratives") then
                        v_1.radius = 14 * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "create-decoratives") then
                        v_1.spawn_min = 30 * area_multiplier * quality_level_multiplier
                        v_1.spawn_max = 40 * area_multiplier * quality_level_multiplier
                    elseif (v_1.type == "damage") then
                        if (k2so_active) then
                            v_1.damage.amount = 1500 * damage_multiplier * quality_level_multiplier
                        else
                            v_1.damage.amount = 400 * damage_multiplier * quality_level_multiplier
                        end
                    elseif (v_1.type == "nested-result" and v_1.action.type == "area") then
                        if (v_1.action.action_delivery and v_1.action.action_delivery.type == "projectile") then
                            if (v_1.action.action_delivery.projectile:find("atomic-warhead-ground-zero-projectile", 1, true)) then
                                v_1.action =
                                {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(1000, repeat_multiplier * quality_level_multiplier),
                                    radius = 7 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-warhead-ground-zero-projectile-" .. k_0,
                                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-warhead-wave-spawns-cluster-nuke-explosion", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(1000, repeat_multiplier * quality_level_multiplier),
                                    radius = 26 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-warhead-wave-spawns-cluster-nuke-explosion",
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-warhead-wave-spawns-fire-smoke-explosion", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(700, repeat_multiplier * quality_level_multiplier),
                                    radius = 4 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                        {
                                            type = "projectile",
                                            projectile = "atomic-warhead-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
                                            starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                        }
                                    }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-warhead-wave-spawns-nuke-shockwave-explosion", 1, true)) then
                                v_1.action = {
                                type = "area",
                                show_in_tooltip = false,
                                target_entities = false,
                                trigger_from_target = true,
                                repeat_count = clamp_repeat_count(1000, repeat_multiplier * quality_level_multiplier),
                                radius = 8 * area_multiplier * quality_level_multiplier,
                                action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-warhead-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-warhead-wave-spawns-nuclear-smoke", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(300, repeat_multiplier * quality_level_multiplier),
                                    radius = 26 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-warhead-wave-spawns-nuclear-smoke",
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile:find("atomic-warhead-wave", 1, true)) then
                                v_1.action = {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = clamp_repeat_count(1000, repeat_multiplier * quality_level_multiplier),
                                    radius = 35 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        {
                                            type = "instant",
                                            target_effects =
                                            {
                                                type = "script",
                                                effect_id = "map-reveal"
                                            }
                                        },
                                        {
                                            type = "projectile",
                                            projectile = "atomic-warhead-wave-" .. k_0,
                                            starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                        },
                                    },
                                }
                            end
                        elseif (    v_1.action.action_delivery[1]
                                and v_1.action.action_delivery[1].projectile
                                and v_1.action.action_delivery[1].projectile:find("atomic-warhead-wave", 1, true)
                                or
                                    v_1.action.action_delivery[1]
                                and v_1.action.action_delivery[2]
                                and v_1.action.action_delivery[2].projectile
                                and v_1.action.action_delivery[2].projectile:find("atomic-warhead-wave", 1, true)
                        ) then
                            v_1.action = {
                                type = "area",
                                target_entities = false,
                                trigger_from_target = true,
                                repeat_count = clamp_repeat_count(1000, repeat_multiplier * quality_level_multiplier),
                                radius = 35 * area_multiplier * quality_level_multiplier,
                                action_delivery =
                                {
                                    {
                                        type = "instant",
                                        target_effects =
                                        {
                                            type = "script",
                                            effect_id = "map-reveal"
                                        }
                                    },
                                    {
                                        type = "projectile",
                                        projectile = "atomic-warhead-wave-" .. k_0,
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    },
                                },
                            }
                        end
                    end
                end
            end

            -- if (get_atomic_warhead_pollution()) then
                local target_effects = quality_atomic_warhead.action.action_delivery.target_effects
                table.insert(target_effects,
                    {
                        type = "nested-result",
                        action = {
                            action_delivery = {
                                target_effects = {
                                    {
                                        type = "script",
                                        effect_id = "atomic-warhead-pollution"
                                    }
                                },
                                type = "instant"
                            },
                            radius = clamp_max_distance((35 * area_multiplier + 1), quality_level_multiplier),
                            repeat_count = clamp_repeat_count((1000 * repeat_multiplier + 1), quality_level_multiplier),
                            repeat_count_deviation = clamp_repeat_count((42 * repeat_multiplier), quality_level_multiplier),
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                    }
                )
                quality_atomic_warhead.action.action_delivery.target_effects = target_effects
            -- end

            if (get_fire_wave()) then
                local target_effects = quality_atomic_warhead.action.action_delivery.target_effects
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
                                    radius = clamp_max_distance((2.5 * area_multiplier + 1), quality_level_multiplier),
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
                                            initial_ground_flame_count = clamp_initial_ground_ground_flame_count(3, quality_level_multiplier),
                                        }
                                    }
                                }
                            }
                        },
                    }
                )
                quality_atomic_warhead.action.action_delivery.target_effects = target_effects
            end
        end

        if (quality_atomic_warhead ~= nil) then
            local atomic_warhead_ammo_item = data.raw["ammo"]["atomic-warhead"]

            if (atomic_warhead_ammo_item.icon) then
                quality_atomic_warhead.icon = Util.table.deepcopy(atomic_warhead_ammo_item.icon)
            else
                quality_atomic_warhead.icons = Util.table.deepcopy(atomic_warhead_ammo_item.icons)
            end

            if (not quality_atomic_warhead.icon and not quality_atomic_warhead.icons) then
                quality_atomic_warhead.icon = "__base__/graphics/icons/signal/signal-radioactivity.png"
            end

            if (k_0 == "normal") then
                atomic_warhead = Util.table.deepcopy(quality_atomic_warhead)
                data:extend({atomic_warhead})
            end

            quality_atomic_warhead.name = quality_atomic_warhead.name .. "-" .. k_0
            data:extend({quality_atomic_warhead})

            return quality_atomic_warhead
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        atomic_warhead = create_quality_atomic_warhead({ quality_level = k_0, quality = quality })
    end
else
    atomic_warhead = create_quality_atomic_warhead({ quality_level = "normal", quality = { level = 0 } })

    if (atomic_warhead) then
        data:extend({atomic_warhead})
    end
end