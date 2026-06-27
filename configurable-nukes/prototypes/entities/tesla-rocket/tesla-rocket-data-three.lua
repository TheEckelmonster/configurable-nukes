local Util = require("__core__.lualib.util")

local __Data_Utils = require("data-utils")

local name = "cn-tesla-rocket"

local base_lightning_bolt_probability = 0.15
local duration = 24
-- local galvanic_chain_name = "cn-galvanic-chain-rocket"
local galvanic_chain_name = "cn-tesla-rocket-chain"
local cloud_name = name .. "-cloud"

local tesla_rocket_smoke_with_trigger_visual_dummy = (require("prototypes.entities.galvanic-ammo.galvanic-cloud-visual-dummy"))(name .. "-cloud-visual-dummy", duration)
data:extend({ tesla_rocket_smoke_with_trigger_visual_dummy, })

local galvanic_sticker = require("prototypes.entities.galvanic-ammo.galvanic-sticker")
data:extend({ galvanic_sticker, })

local function create_lightning_bolt_explosion_animations()
    local lightning_attractor_hit_anim = require("__space-age__.graphics.entity.lightning.lightning-attractor-hit-anim")
        or {
            width = 308,
            height = 220,
            shift = util.by_pixel( 0.5, -3.5),
            line_length = 4,
        }

    return
    {
        {
            filename = "__space-age__/graphics/entity/lightning/lightning-attractor-hit-anim.png",
            draw_as_glow = true,
            priority = "high",
            flags = { "smoke" },
            line_length = lightning_attractor_hit_anim.line_length,
            width = lightning_attractor_hit_anim.width,
            height = lightning_attractor_hit_anim.height,
            frame_count = 32,
            animation_speed = 0.5,
            shift = lightning_attractor_hit_anim.shift,
            -- scale = 1.5,
            scale = 1,
            usage = "explosion"
        },
    }
end

local cn_tesla_rocket_lightning_bolt_explosion =
{
    type = "explosion",
    name = name .. "-lightning-bolt-explosion",
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

    animations = create_lightning_bolt_explosion_animations(),
}
data:extend({ cn_tesla_rocket_lightning_bolt_explosion })

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
    radius = 9.6 + 7,
    damage = 1200 + 900,
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

local galvanic_lightning_bolt_1_target_effects_1 = {
    {
        type = "create-sticker",
        sticker = galvanic_sticker.name,
        -- show_in_tooltip = true
    },
}

local galvanic_lightning_bolt =
{
    type = "direct",
    probability = base_lightning_bolt_probability ^ (1 / 1),
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
                                    target_effects = galvanic_lightning_bolt_1_target_effects_1
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
                                        effect_id = "cn-" .. name .. "-lightning",
                                    },
                                    {
                                        type = "create-explosion",
                                        entity_name = name .. "-lightning-bolt-explosion",
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

table.insert(galvanic_lightning_bolt_2.action_delivery, 1,  {
    type = "chain",
    chain = galvanic_chain_name .. "-2",
    repeat_count = 5,
    probability = base_lightning_bolt_probability,
})

-- table.insert(galvanic_lightning_bolt.action_delivery, {
table.insert(galvanic_lightning_bolt.action_delivery, 1, {
    type = "chain",
    -- chain = galvanic_chain_name .. "-normal",
    chain = galvanic_chain_name,
    repeat_count = 5,
    probability = base_lightning_bolt_probability,
})

local function make_tesla_chain_lightning_chain(name, beam_name, max_jumps, jump_range, fork_chance, fork_chance_per_quality, beam_duration)
    return {
        -- name = name .. "-normal",
        name = name,
        type = "chain-active-trigger",
        max_jumps = max_jumps,
        max_range_per_jump = jump_range,
        jump_delay_ticks = 6,
        fork_chance = fork_chance,
        fork_chance_increase_per_quality_level = fork_chance_per_quality,
        action = {
            {
                type = "direct",
                action_delivery = {
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
galvanic_beam.name = "cn-galvanic-rocket-beam-bounce"

local galvanic_beam_2 = Util.table.deepcopy(galvanic_beam)
galvanic_beam_2.name = galvanic_beam_2.name .. "-2"

-- log(serpent.block(galvanic_beam_2))

--[[ beam-chain-bounce ]]
for k_1, v_1 in pairs(galvanic_beam.action.action_delivery.target_effects) do
    if (v_1.type) then
        if (v_1.type == "damage") then
            v_1.damage.amount = 120 * 1
            v_1.damage.show_in_tooltip = true
        end
    end
end
table.insert(galvanic_beam.action.action_delivery.target_effects,
{
    type = "nested-result",
    probability = 0.025,
    action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    entity_name = cloud_name,
                    type = "create-smoke",
                    initial_height = 0,
                },
            },
        },
    },
})

--[[ beam-chain-bounce ]]
for k_1, v_1 in pairs(galvanic_beam_2.action.action_delivery.target_effects) do
    if (v_1.type) then
        if (v_1.type == "damage") then
            v_1.damage.amount = 60 * 1
            v_1.damage.show_in_tooltip = true
        end
    end
end

local galvanic_chain   = make_tesla_chain_lightning_chain(galvanic_chain_name,         galvanic_beam.name,   10, 12, 0.3, 0.05, 30)
local galvanic_chain_2 = make_tesla_chain_lightning_chain(galvanic_chain_name .. "-2", galvanic_beam_2.name, 8,  10, 0.3, 0.05, 30)

table.insert(galvanic_chain.action, 1, {
    type = "direct",
    probability = 0.025,
    action_delivery = {
        {
            type = "instant",
            target_effects = {
                {
                    entity_name = cloud_name,
                    type = "create-smoke",
                    initial_height = 0,
                },
            },
        },
    },
})

table.insert(galvanic_chain.action, 1, galvanic_lightning_bolt_2)

data:extend({ galvanic_beam, galvanic_beam_2, galvanic_chain, galvanic_chain_2, })


local aoe_multiplier = 1.0
local cluster_multiplier = 0.65

local tesla_rocket_smoke_with_trigger = (require("prototypes.entities.galvanic-ammo.galvanic-cloud"))(cloud_name, duration, name .. "-cloud-visual-dummy", aoe_multiplier, cluster_multiplier)
tesla_rocket_smoke_with_trigger.action =
{
    {
        type = "area",
        force = "not-same",
        radius = (8.4 / 1) * aoe_multiplier,
        action_delivery =
        {
            {
                type = "chain",
                -- chain = galvanic_chain_name .. "-normal",
                -- chain = galvanic_chain.name,
                chain = galvanic_chain_2.name,
            },
            {
                type = "instant",
                target_effects =
                {
                    {
                        type = "nested-result",
                        action = {
                            type = "direct",
                            repeat_count = 4,
                            repeat_count_deviation = 2,
                            probability = base_lightning_bolt_probability,
                            action_delivery = {
                                type = "instant",
                                target_effects = {
                                    {
                                        type = "create-sticker",
                                        sticker = galvanic_sticker.name,
                                        show_in_tooltip = true
                                    },
                                    {
                                        type = "nested-result",
                                        repeat_count = 6,
                                        repeat_count_deviation = 2,
                                        probability = base_lightning_bolt_probability,
                                        action = {
                                            galvanic_lightning_bolt,
                                            -- galvanic_lightning_bolt_2,
                                        },
                                    },
                                    {
                                        type = "damage",
                                        damage = { amount = 50, type = "electric" }
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}
tesla_rocket_smoke_with_trigger.action_cooldown = 25

data:extend({ tesla_rocket_smoke_with_trigger, })

local qualities_to_ignore = {
    "quality-unknown",
}
for k_0, quality in pairs(data.raw.quality) do
    if (qualities_to_ignore[k_0] or quality.hidden) then goto continue end

    local quality_multiplier = 1 + quality.level * 0.3
    local tesla_rocket = data.raw["projectile"][name .. "-" .. k_0]
    -- log(serpent.block(tesla_rocket))

    table.insert(tesla_rocket.action.action_delivery.target_effects[#tesla_rocket.action.action_delivery.target_effects].action.action_delivery, 2, {
        type = "instant",
        target_effects = {
            {
                type = "nested-result",
                action = {
                    (function (lightning_bolt)
                        if (lightning_bolt.action_delivery and lightning_bolt.action_delivery[1]) then
                            local action = lightning_bolt.action_delivery[1]
                            action.probability = action.probability * quality_multiplier
                            if (action.probability > 1) then
                                action.probability = 1
                            elseif (action.probability < 0) then
                                action.probability = 0
                            end
                        end

                        __Data_Utils.foreach(function (tbl)
                            if (tbl and tbl.radius and type(tbl.radius_ == "number")) then
                                tbl.radius = tbl.radius * quality_multiplier
                            end
                        end, __Data_Utils.unpack(__Data_Utils.find_by(lightning_bolt, "radius", {}) or {}))

                        return lightning_bolt
                    end)(Util.table.deepcopy(galvanic_lightning_bolt))
                },
            },
        },
    })
    log(serpent.block(tesla_rocket))

    ::continue::
end

-- local tesla_rocket = data.raw["projectile"][name]
-- -- log(serpent.block(tesla_rocket))

-- table.insert(tesla_rocket.action.action_delivery.target_effects[#tesla_rocket.action.action_delivery.target_effects].action.action_delivery, 2, {
--     type = "instant",
--     target_effects = {
--         {
--             type = "nested-result",
--             action = {
--                 galvanic_lightning_bolt
--             },
--         },
--     },
-- })