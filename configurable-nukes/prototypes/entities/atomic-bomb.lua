local Explosion_Animations = require("__base__.prototypes.entity.explosion-animations")
local Smoke_Animations = require("__base__.prototypes.entity.smoke-animations")
local Sounds = require("__base__.prototypes.entity.sounds")
local Util = require("__core__.lualib.util")

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

local area_multiplier = get_area_multiplier()
local damage_multiplier = get_damage_multiplier()
local repeat_multiplier = get_repeat_multiplier()

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 19 * area_multiplier

local nuke_shockwave_starting_speed_deviation = 0.075 * area_multiplier

local atomic_bomb_wave_action =
{
    type = "area",
    radius = 3 * area_multiplier,
    ignore_collision_condition = true,
    action_delivery =
    {
        type = "instant",
        target_effects =
        {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 0 * area_multiplier,
            upper_distance_threshold = 35 * area_multiplier,
            lower_damage_modifier = 1 * damage_multiplier,
            upper_damage_modifier = 0.1 * damage_multiplier,
            damage = { amount = 400 * damage_multiplier, type = "explosion" }
        }
    }
}

local atomic_bomb_ground_zero_projectile_action =
{
    type = "area",
    radius = 3 * area_multiplier,
    ignore_collision_condition = true,
    action_delivery =
    {
        type = "instant",
        target_effects =
        {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 0,
            upper_distance_threshold = 35 * area_multiplier,
            lower_damage_modifier = 1 * damage_multiplier,
            upper_damage_modifier = 0.01 * damage_multiplier,
            damage = {amount = 100 * damage_multiplier, type = "explosion"}
        }
    }
}

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

data:extend({

  -----------------------------------------------------------------------
  -- SMOKE
  -----------------------------------------------------------------------
  {
    type = "trivial-smoke",
    name = "nuclear-smoke",
    spread_duration = 100,
    duration = 30,
    fade_in_duration = 10,
    fade_away_duration = 20,
    start_scale = 2,
    -- scale_deviation = 0.5, -- MAYBE: add support for scale deviation to trivial-smoke?
    end_scale = 0.2,
    render_layer = "higher-object-under",
    color = {r = 0.627, g = 0.478, b = 0.345, a = 0.500},
    affected_by_wind = true,
    cyclic =  true,
    animation = Smoke_Animations.trivial_smoke_fast
    {
      animation_speed = 1 / 6,
      scale = 2.5,
      flags = { "smoke", "linear-magnification" }
    }
  },

  -----------------------------------------------------------------------
  -- PARTICLES
  -----------------------------------------------------------------------
  {
    type = "particle-source",
    name = "nuclear-smouldering-smoke-source",
    icon = "__base__/graphics/icons/small-scorchmark.png",
    flags = {"not-on-map"},
    hidden = true,
    subgroup = "particles",
    order = "a-a",
    time_to_live = 60 * 60,
    time_to_live_deviation = 30 * 60,
    time_before_start = 90,
    time_before_start_deviation = 60,
    height = 0.4,
    height_deviation = 0.1,
    vertical_speed = 0,
    vertical_speed_deviation = 0,
    horizontal_speed = 0,
    horizontal_speed_deviation = 0,
    smoke =
    {
      {
        name = "soft-fire-smoke",
        frequency = 0.10, --0.25,
        position = {0.0, 0}, -- -0.8},
        starting_frame_deviation = 60,
        starting_vertical_speed = 0.01,
        starting_vertical_speed_deviation = 0.005,
        vertical_speed_slowdown = 1, -- 0.99
      }
    }
  },

  -----------------------------------------------------------------------
  -- SHOCKWAVE projectiles
  -----------------------------------------------------------------------
  {
    type = "projectile",
    name = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
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
              max_movement_distance = max_nuke_shockwave_movement_distance,
              max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
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
    name = "atomic-bomb-wave-spawns-nuclear-smoke",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0,
    speed_modifier = { 1.000, 0.707 },
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
              repeat_count = 10,
              type = "create-trivial-smoke",
              smoke_name = "nuclear-smoke",
              offset_deviation = {{-2, -2}, {2, 2}},
              starting_frame = 10,
              starting_frame_deviation = 20,
              speed_from_center = 0.035
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
    name = "atomic-bomb-wave-spawns-fire-smoke-explosion",
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
              max_movement_distance = max_nuke_shockwave_movement_distance,
              max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
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
    name = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
    flags = {"not-on-map"},
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
              -- following properties are recognized only be "create-explosion" trigger
              --max_movement_distance = max_nuke_shockwave_movement_distance,
              --max_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
              --inherit_movement_distance_from_projectile = true
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
    name = "atomic-bomb-wave",
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

  {
    type = "projectile",
    name = "atomic-bomb-ground-zero-projectile",
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

  -----------------------------------------------------------------------
  -- EXPLOSIONS
  -----------------------------------------------------------------------

  {
    type = "explosion",
    name = "atomic-fire-smoke",
    flags = {"not-on-map"},
    hidden = true,
    fade_out_duration = 40,
    scale_out_duration = 50,
    scale_in_duration = 10,
    scale_initial = 0.1,
    scale = 1.5,
    scale_deviation = 0.2,
    scale_increment_per_tick = 0.005,
    correct_rotation = true,
    scale_animation_speed = true,
    animations =
    {
      {
        width = 152,
        height = 120,
        line_length = 5,
        frame_count = 60,
        shift = {-0.53125, -0.4375},
        priority = "high",
        animation_speed = 0.50,
        tint = {r = 0.627, g = 0.478, b = 0.345, a = 0.500},
        filename = "__base__/graphics/entity/smoke/smoke.png",
        flags = { "smoke" }
      }
    }
  },

  {
    type = "explosion",
    name = "atomic-nuke-shockwave",
    icon = "__base__/graphics/icons/destroyer.png",
    flags = {"not-on-map"},
    hidden = true,
    subgroup = "explosions",
    height = 1.4,
    rotate = true,
    correct_rotation = true,
    fade_out_duration = 30,
    scale_out_duration = 40,
    scale_in_duration = 10,
    scale_initial = 0.1,
    scale = 1,
    scale_deviation = 0.2,
    scale_end = 0.5,
    scale_increment_per_tick = 0.005,
    scale_animation_speed = true,

    animations = Explosion_Animations.nuke_shockwave()
  },

  {
    type = "explosion",
    name = "cluster-nuke-explosion",
    icon = "__base__/graphics/icons/atomic-bomb-light.png",
    flags = {"not-on-map"},
    hidden = true,
    subgroup = "explosions",
    order = "a-d-b",
    animations = Smoke_Animations.trivial_smoke_animation(
    {
      tint = {r = 0.627, g = 0.478, b = 0.345, a = 0.500},
      scale = 2.5,
    }),
    scale_increment_per_tick = 0.002,
    fade_out_duration = 30,
    scale_out_duration = 20,
    scale_in_duration = 10,
    scale_initial = 0.1,
    correct_rotation = true,
    scale_animation_speed = true,
  },
})


-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------
local atomic_bomb = {
    type = "projectile",
    name = "atomic-rocket",
    icon = "__base__/graphics/icons/atomic-bomb.png",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.005,
    turn_speed = 0.003,
    turning_speed_increases_exponentially_with_projectile_speed = true,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          { -- Destroy cliffs before changing tiles (so the cliff achievement works)
            type = "destroy-cliffs",
            radius = 9 * area_multiplier,
            explosion_at_trigger = "explosion"
          },
          -- Explosion entities for other surface-specific effects are added here
          {
            type = "create-entity",
            check_buildability = true,
            -- This entity can have surface conditions
            entity_name = "nuke-effects-nauvis"
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "camera-effect",
            duration = 60,
            ease_in_duration = 5,
            ease_out_duration = 60,
            delay = 0,
            strength = 6,
            -- full_strength_max_distance = 200 * area_multiplier,
            -- max_distance = 800 * area_multiplier
            full_strength_max_distance = clamp_max_distance(200, area_multiplier),
            max_distance = clamp_max_distance(800, area_multiplier)
          },
          {
            type = "play-sound",
            sound = Sounds.nuclear_explosion(0.9),
            play_on_target_position = false,
            -- max_distance = 1000 * area_multiplier,
            max_distance = clamp_max_distance(1000, area_multiplier),
          },
          {
            type = "play-sound",
            sound = Sounds.nuclear_explosion_aftershock(0.4),
            play_on_target_position = false,
            -- max_distance = 1000 * area_multiplier,
            max_distance = clamp_max_distance(1000, area_multiplier),
          },
          {
            type = "damage",
            damage = {amount = 400 * damage_multiplier, type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
            radius = 14 * area_multiplier -- large radius for demostrative purposes
          },
          {
            type = "create-decorative",
            decorative = "nuclear-ground-patch",
            spawn_min_radius = 11.5,
            spawn_max_radius = 12.5,
            spawn_min = 30 * area_multiplier,
            spawn_max = 40 * area_multiplier,
            apply_projection = true,
            spread_evenly = true
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
              }
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
              }
            }
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 1000 * repeat_multiplier,
              radius = 26 * area_multiplier,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                starting_speed = 0.5 * 0.7 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
              }
            }
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 700 * repeat_multiplier,
              radius = 4 * area_multiplier,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
                starting_speed = 0.5 * 0.65 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
              }
            }
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 1000 * repeat_multiplier,
              radius = 8 * area_multiplier,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
                starting_speed = 0.5 * 0.65 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
              }
            }
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 300 * repeat_multiplier,
              radius = 26 * area_multiplier,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                starting_speed = 0.5 * 0.65 * area_multiplier,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
              }
            }
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 10 * repeat_multiplier,
              radius = 8 * area_multiplier,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "create-entity",
                    entity_name = "nuclear-smouldering-smoke-source",
                    tile_collision_mask = {layers={water_tile=true}}
                  }
                }
              }
            },
          },
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
              radius = 26 * area_multiplier + 1,
              repeat_count = 1000 * repeat_multiplier + 1,
              repeat_count_deviation = 42 * repeat_multiplier,
              show_in_tooltip = false,
              target_entities = false,
              trigger_from_target = true,
              type = "area"
            },
          },
          atomic_bomb_fire_action,

        }
      }
    },
    --light = {intensity = 0.8, size = 15},
    animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.3, 1, 0.3}),
    shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
    smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
}

if (mods and mods["quality"]) then

    for k_0, quality in pairs(data.raw["quality"]) do
        local quality_atomic_bomb = nil
        local default_multiplier = get_quality_base_multiplier()

        if (default_multiplier) then
            quality_atomic_bomb = Util.table.deepcopy(atomic_bomb)

            local quality_level_multiplier = default_multiplier ^ quality.level

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
                        v_1.spawn_max = 40 * area_multiplier * qquality_level_multiplier
                    elseif (v_1.type == "nested-result" and v_1.action.type == "area") then
                        if (v_1.action.action_delivery and v_1.action.action_delivery.type == "projectile") then
                            if (v_1.action.action_delivery.projectile == "atomic-bomb-ground-zero-projectile") then
                                v_1.action =
                                {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = 1000 * repeat_multiplier * quality_level_multiplier,
                                    radius = 7 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-ground-zero-projectile",
                                        starting_speed = 0.6 * 0.8 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave") then
                                v_1.action = {
                                    type = "area",
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = 1000 * repeat_multiplier * quality_level_multiplier,
                                    radius = 35 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave",
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-cluster-nuke-explosion") then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = 1000 * repeat_multiplier * quality_level_multiplier,
                                    radius = 26 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                                        starting_speed = 0.5 * 0.7 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-fire-smoke-explosion") then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = 700 * repeat_multiplier * quality_level_multiplier,
                                    radius = 4 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                        {
                                            type = "projectile",
                                            projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
                                            starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                        }
                                    }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuke-shockwave-explosion") then
                                v_1.action = {
                                type = "area",
                                show_in_tooltip = false,
                                target_entities = false,
                                trigger_from_target = true,
                                repeat_count = 1000 * repeat_multiplier * quality_level_multiplier,
                                radius = 8 * area_multiplier * quality_level_multiplier,
                                action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            elseif (v_1.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuclear-smoke") then
                                v_1.action = {
                                    type = "area",
                                    show_in_tooltip = false,
                                    target_entities = false,
                                    trigger_from_target = true,
                                    repeat_count = 300 * repeat_multiplier * quality_level_multiplier,
                                    radius = 26 * area_multiplier * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "projectile",
                                        projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                                        starting_speed = 0.5 * 0.65 * area_multiplier * quality_level_multiplier,
                                        starting_speed_deviation = nuke_shockwave_starting_speed_deviation * quality_level_multiplier,
                                    }
                                }
                            end
                        elseif (    v_1.action
                                and v_1.action.action_delivery
                                and v_1.action.action_delivery.target_effects
                                and v_1.action.action_delivery.target_effects.type == "script"
                                and v_1.action.action_delivery.target_effects.effect_id
                                and v_1.action.action_delivery.target_effects.effect_id == "atomic-bomb-pollution")
                        then
                            v_1.action = {
                            action_delivery = {
                                target_effects = {
                                    {
                                        type = "script",
                                        effect_id = "atomic-bomb-pollution"
                                    }
                                },
                                type = "instant"
                            },
                                radius = (26 * area_multiplier + 1) * quality_level_multiplier,
                                repeat_count = (1000 * repeat_multiplier + 1) * quality_level_multiplier,
                                repeat_count_deviation = (42 * repeat_multiplier) * quality_level_multiplier,
                                show_in_tooltip = false,
                                target_entities = false,
                                trigger_from_target = true,
                                type = "area"
                            }
                        elseif (    v_1.action
                                and v_1.action.type
                                and v_1.action.type == "area"
                                and v_1.action.action_delivery
                                and v_1.action.action_delivery.type
                                and v_1.action.action_delivery.type == "instant"
                                and v_1.action.action_delivery.target_effects
                                and v_1.action.action_delivery.target_effects[1]
                                and v_1.action.action_delivery.target_effects[1].type
                                and v_1.action.action_delivery.target_effects[1].type == "create-sticker"
                                and v_1.action.action_delivery.target_effects[1].sticker
                                and v_1.action.action_delivery.target_effects[1].sticker == "fire-sticker"
                                and v_1.action.action_delivery.target_effects[2]
                                and v_1.action.action_delivery.target_effects[2].type
                                and v_1.action.action_delivery.target_effects[2].type == "create-fire"
                                and v_1.action.action_delivery.target_effects[2].entity_name
                                and v_1.action.action_delivery.target_effects[2].entity_name == "fire-flame")
                        then
                            v_1.action = {
                                {
                                    type = "area",
                                    radius = (26 * area_multiplier + 1) * quality_level_multiplier,
                                    repeat_count = (10 * repeat_multiplier + 1) * quality_level_multiplier,
                                    action_delivery =
                                    {
                                        type = "instant",
                                        radius = (2.5 * area_multiplier + 1) * quality_level_multiplier,
                                        repeat_count = (10 * repeat_multiplier + 1) * quality_level_multiplier,
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
                                                repeat_count = (10 * repeat_multiplier + 1) * quality_level_multiplier,
                                                repeat_count_deviation = (42 * repeat_multiplier) * quality_level_multiplier,
                                                show_in_tooltip = true,
                                                initial_ground_flame_count = (2) * quality_level_multiplier
                                            }
                                        }
                                    }
                                }
                            }
                        end
                    end
                end
            end

        end

        if (quality_atomic_bomb ~= nil) then
            quality_atomic_bomb.name = quality_atomic_bomb.name .. "-" .. k_0
            data:extend({quality_atomic_bomb})
        end
    end

    data:extend({atomic_bomb})

    local atomic_bomb_placeholder = Util.table.deepcopy(atomic_bomb)
    atomic_bomb_placeholder.name = "atomic-rocket-placeholder"

    atomic_bomb_placeholder.animation = nil
    atomic_bomb_placeholder.shadow = nil
    atomic_bomb_placeholder.smoke = nil

    atomic_bomb_placeholder.action =
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "damage",
                    damage = { amount = 400 * damage_multiplier, type = "explosion" }
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
                        }
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
                        }
                    }
                },
                atomic_bomb_fire_action,
            }
        }
    }

    data:extend({atomic_bomb_placeholder})
else
    local icbm_atomic_bomb = Util.table.deepcopy(atomic_bomb)
    icbm_atomic_bomb.name = "atomic-rocket-normal"
    data:extend({icbm_atomic_bomb})
    data:extend({atomic_bomb})
end