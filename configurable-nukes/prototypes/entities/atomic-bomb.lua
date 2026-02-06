local __stage = __STAGE or nil

local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local true_nukes_contiued = mods and mods["True-Nukes_Continued"] and true

-- AREA_MULTIPLIER
local get_area_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-area-multiplier"]) then
        setting = settings.startup["configurable-nukes-area-multiplier"].value
    end

    return setting
end

-- DAMAGE_MULTIPLIER
local get_damage_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-damage-multiplier"]) then
        setting = settings.startup["configurable-nukes-damage-multiplier"].value
    end

    return setting
end

-- REPEAT_MULTIPLIER
local get_repeat_multiplier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-repeat-multiplier"]) then
        setting = settings.startup["configurable-nukes-repeat-multiplier"].value
    end

    return setting
end

-- FIRE_WAVE
local get_fire_wave = function ()
    local setting = false

    if (settings and settings.startup and settings.startup["configurable-nukes-fire-wave"]) then
        setting = settings.startup["configurable-nukes-fire-wave"].value
    end

    return setting
end

-- QUALITY_BASE_MODIFIER
local get_quality_base_multiplier = function ()
    local setting = 1.3

    if (settings and settings.startup and settings.startup["configurable-nukes-quality-base-multiplier"]) then
        setting = settings.startup["configurable-nukes-quality-base-multiplier"].value
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

if (true_nukes_contiued) then
    area_multiplier = area_multiplier * 6.66
    repeat_multiplier = repeat_multiplier * 6.66
end

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 19 * area_multiplier

local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

local atomic_bomb_fire_action =
{
    type = "nested-result",
    action = {
        {
            type = "area",
            radius = 26 * area_multiplier + 1,
            repeat_count = 10 * repeat_multiplier + 1,
            action_delivery =
            {
                type = "instant",
                radius = 2.5 * area_multiplier + 1,
                repeat_count = 10 * repeat_multiplier + 1,
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
                        repeat_count = 10 * repeat_multiplier + 1,
                        repeat_count_deviation = 42 * repeat_multiplier,
                        show_in_tooltip = true,
                        initial_ground_flame_count = 2
                    }
                }
            }
        }
    },
}

if (not get_fire_wave()) then
    atomic_bomb_fire_action = nil
end

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------
local original_atomic_bomb = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

if (not original_atomic_bomb) then
    original_atomic_bomb = Util.table.deepcopy(data.raw["projectile"]["atomic-bomb"])
end

local damage =
{
    default =
    {
        type = "damage",
        damage = { amount = 400 * 1, type = "explosion" }
    },
    k2so =
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
}

local atomic_bomb = nil

local create_quality_atomic_bomb = function (params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_atomic_bomb = nil
        local default_multiplier = get_quality_base_multiplier()

        if (default_multiplier) then
            quality_atomic_bomb = Util.table.deepcopy(original_atomic_bomb)

            local quality_level_multiplier = default_multiplier ^ quality.level

            data:extend(
            {
                {
                    type = "projectile",
                    name = "atomic-bomb-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
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
                    name = "atomic-bomb-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
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

            local atomic_bomb_ground_zero_projectile_action =
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

            local atomic_bomb_wave_action =
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

            if (k2so_active) then
                atomic_bomb_wave_action.action_delivery =
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
            end

            data:extend({
                {
                    type = "projectile",
                    name = "atomic-bomb-ground-zero-projectile-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        atomic_bomb_ground_zero_projectile_action
                    },
                    animation = nil,
                    shadow = nil
                },
                {
                    type = "projectile",
                    name = "atomic-bomb-wave-" .. k_0,
                    flags = {"not-on-map"},
                    hidden = true,
                    acceleration = 0,
                    speed_modifier = { 1.0, 0.707 },
                    action =
                    {
                        atomic_bomb_wave_action
                    },
                    animation = nil,
                    shadow = nil
                },
            })

            for k_1, v_1 in pairs(quality_atomic_bomb.action.action_delivery.target_effects) do
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
                            if (v_1.action.action_delivery.projectile == "atomic-bomb-ground-zero-projectile") then
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
                                        projectile = "atomic-bomb-ground-zero-projectile-" .. k_0,
                                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier
                                    },
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave") then
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
                                            projectile = "atomic-bomb-wave-" .. k_0,
                                            starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                        },
                                    },
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-cluster-nuke-explosion") then
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
                                        projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    },
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-fire-smoke-explosion") then
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
                                        projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion" .. "-" .. k_0,
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    },
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuke-shockwave-explosion") then
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
                                        projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion" .. "-" .. k_0,
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    },
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuclear-smoke") then
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
                                        projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    },
                                }
                            end
                        end
                    end
                end
            end

            -- if (get_atomic_bomb_pollution()) then
                local target_effects = quality_atomic_bomb.action.action_delivery.target_effects
                table.insert(target_effects,
                    {
                        type = "nested-result",
                        action = {
                            action_delivery = {
                                target_effects = {
                                    {
                                        type = "script",
                                        effect_id = "atomic-bomb-pollution"
                                    }
                                },
                                type = "instant"
                            },
                            radius = (35 * area_multiplier + 1) * quality_level_multiplier,
                            repeat_count = clamp_repeat_count((1000 * repeat_multiplier + 1), quality_level_multiplier),
                            repeat_count_deviation = clamp_repeat_count((42 * repeat_multiplier), quality_level_multiplier),
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                    }
                )
                quality_atomic_bomb.action.action_delivery.target_effects = target_effects
            -- end

            if (get_fire_wave()) then
                local target_effects = quality_atomic_bomb.action.action_delivery.target_effects
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
                                            initial_ground_flame_count = clamp_initial_ground_ground_flame_count(3, quality_level_multiplier)
                                        }
                                    }
                                }
                            }
                        },
                    }
                )
                quality_atomic_bomb.action.action_delivery.target_effects = target_effects
            end
        end

        if (quality_atomic_bomb ~= nil) then
            if (k_0 == "normal" and (type(__stage) ~= "string" or __stage ~= "data")) then
                atomic_bomb = Util.table.deepcopy(quality_atomic_bomb)

                local atomic_bomb_ammo_item = data.raw["ammo"]["atomic-bomb"]

                if (atomic_bomb_ammo_item.icon) then
                    atomic_bomb.icon = Util.table.deepcopy(atomic_bomb_ammo_item.icon)
                else
                    atomic_bomb.icons = Util.table.deepcopy(atomic_bomb_ammo_item.icons)
                end

                if (not atomic_bomb.icon and not atomic_bomb.icons) then
                    if (k2so_active) then
                        atomic_bomb.icon = "__Krastorio2Assets__/icons/ammo/atomic-bomb.png"
                    else
                        atomic_bomb.icons =
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

                data:extend({atomic_bomb})
            end

            quality_atomic_bomb.name = quality_atomic_bomb.name .. "-" .. k_0
            data:extend({quality_atomic_bomb})

            return quality_atomic_bomb
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        atomic_bomb = create_quality_atomic_bomb({ quality_level = k_0, quality = quality })
    end
else
    atomic_bomb = create_quality_atomic_bomb({ quality_level = "normal", quality = { level = 0 } })

    if (atomic_bomb) then
        data:extend({atomic_bomb})
    end
end

local atomic_bomb_placeholder = Util.table.deepcopy(original_atomic_bomb)
atomic_bomb_placeholder.name = "atomic-rocket-placeholder"

atomic_bomb_placeholder.animation = nil
atomic_bomb_placeholder.shadow = nil
atomic_bomb_placeholder.smoke = nil


local atomic_bomb_placeholder_map = {
    {
        type = "damage",
        damage = { amount = 400 * damage_multiplier, type = "explosion" }
    },
    {
        type = "destroy-cliffs",
        radius = 9 * area_multiplier,
        explosion_at_trigger = "explosion"
        -- show_in_tooltip = mods and mods["quality"] ~= nil,
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
    atomic_bomb_fire_action,
}
local atomic_bomb_placeholder_target_effects = {}

for _, v in pairs(atomic_bomb_placeholder_map) do table.insert(atomic_bomb_placeholder_target_effects, v) end

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
    table.remove(atomic_bomb_placeholder.action.action_delivery.target_effects, 1)

    table.insert(atomic_bomb_placeholder.action.action_delivery.target_effects, 1, damage.k2so.explosion)
    table.insert(atomic_bomb_placeholder.action.action_delivery.target_effects, 2, damage.k2so.radioactive)
end

data:extend({atomic_bomb_placeholder})