local sounds = require("__base__.prototypes.entity.sounds")

local Util = require("__core__.lualib.util")

local galvanic_land_mine = data.raw["land-mine"]["cn-galvanic-land-mine"]

if (not galvanic_land_mine) then
    galvanic_land_mine = data.raw["land-mine"]["land-mine"]
    if (not galvanic_land_mine) then return end

    galvanic_land_mine = Util.table.deepcopy(galvanic_land_mine)

    galvanic_land_mine.name = "cn-galvanic-land-mine"
end

if (galvanic_land_mine.action and not galvanic_land_mine.action[1]) then galvanic_land_mine.action = { galvanic_land_mine.action, } end

-- log(serpent.block(galvanic_land_mine))

local duration = 6
local galvanic_chain_name = "cn-galvanic-chain-land-mine"
local galvanic_sticker = require("prototypes.entities.galvanic-ammo.galvanic-sticker")

local galvanic_smoke_with_trigger_visual_dummy = (require("prototypes.entities.galvanic-ammo.galvanic-cloud-visual-dummy"))("cn-galvanic-cloud-visual-dummy", duration)
-- local galvanic_smoke_with_trigger_visual_dummy =
-- {
--     type = "smoke-with-trigger",
--     name = "cn-galvanic-cloud-visual-dummy",
--     flags = { "not-on-map" },
--     hidden = true,
--     show_when_smoke_off = true,
--     particle_count = 24,
--     particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
--     particle_distance_scale_factor = 0.5,
--     particle_scale_factor = { 1, 0.707 },
--     particle_duration_variation = 60 * 3,
--     wave_speed = { 0.5 / 80, 0.5 / 60 },
--     wave_distance = { 1, 0.5 },
--     spread_duration_variation = 300 - duration,

--     render_layer = "object",

--     affected_by_wind = false,
--     cyclic = true,
--     duration = 60 * duration + 3 * 60,
--     fade_away_duration = 2 * 60,
--     spread_duration = (300 - 6) / 2,
--     color = { r = 0.1647, g = 0.2666, b = 0.78039, a = 0.6 }, -- #2642c8

--     animation =
--     {
--         width = 152,
--         height = 120,
--         line_length = 5,
--         frame_count = 60,
--         shift = { -0.53125, -0.4375 },
--         priority = "high",
--         animation_speed = 0.25,
--         filename = "__base__/graphics/entity/smoke/smoke.png",
--         flags = { "smoke" }
--     },
--     working_sound =
--     {
--         sound = { filename = "__base__/sound/fight/poison-cloud.ogg", volume = 0.5, audible_distance_modifier = 0.8 },
--         max_sounds_per_prototype = 1,
--         match_volume_to_activity = true
--     }
-- }

local function count(base_val)
    local self = {
        count = base_val or 0
    }

    return {
        ["get"] = function () return self.count end,
        ["++"]  = function () local ret = self.count; self.count = self.count + 1; return ret end,
        ["--"]  = function () local ret = self.count; self.count = self.count - 1; return ret end,
    }
end

local counter1 = count(0)
local counter2 = count(7)
local counter3 = count(3)

local base = {
    radius = 9.6,
    damage = 1200,
}

local function create_action(radius)
    radius = radius or base.radius ^ 2

    return {
        type = "area",
        radius = base.radius * (1 / (radius ^ (counter1["++"]()))),
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    damage = {
                        amount = base.damage * (1 / (counter2["--"]() ^ (counter3["--"]()))),
                        type = "electric"
                    },
                    type = "damage"
                }
            },
        },
    }
end

local galvanic_lightning_bolt =
{
    type = "direct",
    probability = 0.15 ^ (1 / 1),
    action_delivery =
    {
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "nested-result",
                    action = {
                        {
                            type = "area",
                            radius = base.radius / 1.5,
                            action_delivery = {
                                {
                                    type = "instant",
                                    target_effects = {
                                        {
                                            type = "create-sticker",
                                            sticker = galvanic_sticker.name,
                                            show_in_tooltip = true
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    type = "nested-result",
                    action = {
                        {
                            type = "direct",
                            action_delivery = {
                                type = "instant",
                                target_effects = {
                                    {
                                        type = "script",
                                        effect_id = "cn-tesla-rocket-lightning",
                                    },
                                },
                            },
                        },
                        create_action(1),
                        create_action(2.25),
                        create_action(3),
                        create_action(3.75),
                    },
                },
            },
        },
    },
}

local galvanic_lightning_bolt_2 = Util.table.deepcopy(galvanic_lightning_bolt)

galvanic_lightning_bolt_2.probability = 0.05

table.insert(galvanic_lightning_bolt_2.action_delivery, 1,  {
    type = "chain",
    chain = galvanic_chain_name .. "-2",
    repeat_count = 5,
    probability = 0.35,
})

table.insert(galvanic_lightning_bolt.action_delivery, 1,  {
    type = "chain",
    chain = galvanic_chain_name ,
    repeat_count = 7,
    probability = 0.10,
})

local function make_tesla_chain_lightning_chain(name, beam_name, max_jumps, jump_range, fork_chance, fork_chance_per_quality, beam_duration)
    return {
        name = name,
        type = "chain-active-trigger",
        max_jumps = max_jumps,
        max_range_per_jump = jump_range,
        jump_delay_ticks = 6,
        fork_chance = fork_chance,
        fork_chance_increase_per_quality_level = fork_chance_per_quality,
        action =
        {
            {
                type = "direct",
                action_delivery =
                {
                    {
                        type = "beam",
                        beam = beam_name,
                        max_length = jump_range + 0.5,
                        duration = beam_duration,
                        add_to_shooter = false,
                        destroy_with_source_or_target = false,
                        source_offset = { 0, 0 }, -- should match beam's target_offset
                    },
                },
            },
        },
    }
end

local galvanic_beam = Util.table.deepcopy(data.raw["beam"]["cn-chain-tesla-rocket-beam-bounce"])
galvanic_beam.name = "cn-galvanic-land-mine-beam-bounce"

--[[ beam-chain-bounce ]]
for k_1, v_1 in pairs(galvanic_beam.action.action_delivery.target_effects) do
    if (v_1.type) then
        if (v_1.type == "damage") then
            v_1.damage.amount = 32 * 1
            v_1.damage.show_in_tooltip = true
        end
    end
end

local galvanic_chain   = make_tesla_chain_lightning_chain(galvanic_chain_name ,   galvanic_beam.name, 10, 12, 0.3, 0.05, 30)
local galvanic_chain_2 = make_tesla_chain_lightning_chain(galvanic_chain_name .. "-2", galvanic_beam.name, 8,  10, 0.3, 0.05, 30)

table.insert(galvanic_chain.action, 1, galvanic_lightning_bolt_2)

data:extend({ galvanic_beam, galvanic_chain, galvanic_chain_2, })

local aoe_multiplier = 0.42
local cluster_multiplier = 0.25

local galvanic_smoke_with_trigger = (require("prototypes.entities.galvanic-ammo.galvanic-cloud"))("cn-galvanic-cloud", duration, "cn-galvanic-cloud-visual-dummy", aoe_multiplier, cluster_multiplier)
-- local galvanic_smoke_with_trigger =
-- {
--     name = "cn-galvanic-cloud",
--     type = "smoke-with-trigger",
--     flags = { "not-on-map" },
--     hidden = true,
--     show_when_smoke_off = true,
--     particle_count = 16,
--     particle_spread = { 3.6 * 1.05, 3.6 * 0.6 * 1.05 },
--     particle_distance_scale_factor = 0.5,
--     particle_scale_factor = { 1, 0.707 },
--     wave_speed = { 1 / 80, 1 / 60 },
--     wave_distance = { 0.3, 0.2 },
--     spread_duration_variation = duration,
--     particle_duration_variation = 60 * 3,
--     render_layer = "object",

--     affected_by_wind = false,
--     cyclic = true,
--     duration = 60 * duration,
--     fade_away_duration = 2 * 60,
--     spread_duration = 6,
--     -- color = { 0.239, 0.875, 0.992, 0.690 }, -- #3ddffdb0,

--     animation =
--     {
--         width = 152,
--         height = 120,
--         line_length = 5,
--         frame_count = 60,
--         shift = { -0.53125, -0.4375 },
--         priority = "high",
--         animation_speed = 0.25,
--         filename = "__base__/graphics/entity/smoke/smoke.png",
--         flags = { "smoke" }
--     },

--     created_effect =
--     {
--         {
--             type = "cluster",
--             force = "not-same",
--             cluster_count = 2 + (cluster_multiplier + 8 / 1) * cluster_multiplier,
--             distance = (4 / 1) * aoe_multiplier,
--             distance_deviation = (5 / 1) * aoe_multiplier,
--             action_delivery =
--             {
--                 type = "instant",
--                 target_effects =
--                 {
--                     {
--                         type = "create-smoke",
--                         show_in_tooltip = false,
--                         entity_name = "cn-galvanic-cloud-visual-dummy",
--                         initial_height = 0
--                     },
--                     {
--                         type = "play-sound",
--                         sound = sounds.poison_capsule_explosion
--                     }
--                 }
--             }
--         },
--         {
--             type = "cluster",
--             force = "not-same",
--             cluster_count = 2 + (cluster_multiplier + 9 / 1) * cluster_multiplier,
--             distance = ((9 * 1.1) / 1) * aoe_multiplier,
--             distance_deviation = (3 / 1) * aoe_multiplier,
--             action_delivery =
--             {
--                 type = "instant",
--                 target_effects =
--                 {
--                     {
--                         type = "create-smoke",
--                         show_in_tooltip = false,
--                         entity_name = "cn-galvanic-cloud-visual-dummy",
--                         initial_height = 0
--                     },
--                 },
--             },
--         },
--     },
--     action =
--     {
--         {
--             type = "area",
--             force = "not-same",
--             radius = (8.4 / 1) * aoe_multiplier,
--             action_delivery =
--             {
--                 {
--                     type = "chain",
--                     chain = galvanic_chain_name,
--                 },
--                 {
--                     type = "instant",
--                     target_effects =
--                     {
--                         {
--                             type = "create-sticker",
--                             sticker = galvanic_sticker.name,
--                             show_in_tooltip = true
--                         },
--                         {
--                             type = "nested-result",
--                             action = {
--                                 galvanic_lightning_bolt,
--                             },
--                         },
--                         {
--                             type = "damage",
--                             damage = { amount = 12, type = "electric" }
--                         },
--                     },
--                 },
--             },
--         },
--     },
--     action_cooldown = 25,
-- }

galvanic_smoke_with_trigger.action =
{
    {
        type = "area",
        force = "not-same",
        radius = (8.4 / 1) * aoe_multiplier,
        action_delivery =
        {
            {
                type = "chain",
                chain = galvanic_chain_name,
            },
            {
                type = "instant",
                target_effects =
                {
                    {
                        type = "create-sticker",
                        sticker = galvanic_sticker.name,
                        show_in_tooltip = true
                    },
                    {
                        type = "nested-result",
                        action = {
                            galvanic_lightning_bolt,
                        },
                    },
                    {
                        type = "damage",
                        damage = { amount = 12, type = "electric" }
                    },
                },
            },
        },
    },
}
galvanic_smoke_with_trigger.action_cooldown = 25

data:extend({ galvanic_sticker, galvanic_smoke_with_trigger_visual_dummy, galvanic_smoke_with_trigger, })

galvanic_land_mine.action[#galvanic_land_mine.action+1] = {
    type = "direct",
    force = "not-same",
    action_delivery = {
        type = "instant",
        -- source_effects = {
        target_effects = {
            {
                sticker = galvanic_sticker.name,
                type = "create-sticker",
                show_in_tooltip = true,
            },
            {
                entity_name = "cn-galvanic-cloud",
                type = "create-smoke",
                initial_height = 0,
                show_in_tooltip = true,
            },
            {
                type = "nested-result",
                action = {
                    type = "direct",
                    force = "not-same",
                    action_delivery = {
                        type = "chain",
                        chain = galvanic_chain_name,
                        show_in_tooltip = true,
                    },
                },
            },
        }
    },
}

galvanic_land_mine.ammo_category = "tesla-munition"
galvanic_land_mine.force_die_on_attack = true
galvanic_land_mine.minable.result = "cn-galvanic-land-mine"
galvanic_land_mine.max_health = galvanic_land_mine.max_health * (7/3)
galvanic_land_mine.resistances = {
    {
        percent = 50,
        decrease = 50,
        type = "fire"
    },
    {
        percent = 50,
        decrease = 50,
        type = "explosion"
    },
    {
        percent = 50,
        decrease = 50,
        type = "electric"
    },
}

-- galvanic_land_mine.trigger_interval = 8 * 60
galvanic_land_mine.trigger_radius = 3
galvanic_land_mine.timeout = 120
galvanic_land_mine.trigger_force = "enemy"

log(serpent.block(galvanic_land_mine))

galvanic_land_mine.picture_safe.filename = "__configurable-nukes-extended-avionics__/graphics/entity/galvanic-land-mine/galvanic-land-mine.png"
galvanic_land_mine.picture_set.filename = "__configurable-nukes-extended-avionics__/graphics/entity/galvanic-land-mine/galvanic-land-mine-set.png"

data:extend({ galvanic_land_mine, })
