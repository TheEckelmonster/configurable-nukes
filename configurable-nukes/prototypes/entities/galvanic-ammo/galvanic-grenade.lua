local Util = require("__core__.lualib.util")

local galvanic_grenade = data.raw.capsule["cn-galvanic-grenade"]

if (not galvanic_grenade) then
    galvanic_grenade = data.raw.capsule.grenade
    if (not galvanic_grenade) then return end

    galvanic_grenade = Util.table.deepcopy(galvanic_grenade)

    galvanic_grenade.name = "cn-galvanic-grenade"
end

local galvanic_sticker = require("prototypes.entities.galvanic-ammo.galvanic-sticker")

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

table.insert(galvanic_lightning_bolt_2.action_delivery, 1,  {
    type = "chain",
    chain = "cn-galvanic-chain-2",
    repeat_count = 5,
    probability = 0.15,
})

table.insert(galvanic_lightning_bolt.action_delivery, 1,  {
    type = "chain",
    chain = "cn-galvanic-chain",
    repeat_count = 5,
    probability = 0.15,
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
galvanic_beam.name = "cn-galvanic-beam-bounce"

--[[ beam-chain-bounce ]]
for k_1, v_1 in pairs(galvanic_beam.action.action_delivery.target_effects) do
    if (v_1.type) then
        if (v_1.type == "damage") then
            v_1.damage.amount = 32 * 1
            v_1.damage.show_in_tooltip = true
        end
    end
end

local galvanic_chain   = make_tesla_chain_lightning_chain("cn-galvanic-chain",   galvanic_beam.name, 10, 12, 0.3, 0.05, 30)
local galvanic_chain_2 = make_tesla_chain_lightning_chain("cn-galvanic-chain-2", galvanic_beam.name, 8,  10, 0.3, 0.05, 30)

table.insert(galvanic_chain.action, 1, galvanic_lightning_bolt_2)

data:extend({ galvanic_beam, galvanic_chain, galvanic_chain_2, })

local base_grenade_projectile = Util.table.deepcopy(galvanic_grenade.capsule_action.attack_parameters.ammo_type.action[1])

-- local galvanic_projectile = Util.table.deepcopy(data.raw.projectile["cn-tesla-rocket-ground-zero-projectile-normal"])
-- galvanic_projectile.name = "cn-galvanic-grenade-projectile"

-- data:extend({ galvanic_sticker, })

-- galvanic_projectile.action[1].action_delivery[1].target_effects = {
--     {
--         sticker = galvanic_sticker.name,
--         type = "create-sticker",
--         show_in_tooltip = true,
--     },
--     {
--         entity_name = "cn-galvanic-cloud",
--         type = "create-smoke",
--         initial_height = 0,
--         show_in_tooltip = true,
--     },
-- }

-- data:extend({ galvanic_projectile, })

local galvanic_grenade_projectile = Util.table.deepcopy(data.raw.projectile.grenade)
-- galvanic_grenade_projectile.name = "cn-galvanic-grenade-projectile"
galvanic_grenade_projectile.name = "cn-galvanic-grenade"
galvanic_grenade_projectile.action = {
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "create-entity",
                    entity_name = "grenade-explosion"
                },
                {
                    type = "create-entity",
                    entity_name = "small-scorchmark-tintable",
                    check_buildability = true
                },
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
                {
                    type = "destroy-decoratives",
                    from_render_layer = "decorative",
                    to_render_layer = "object",
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = false,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                    radius = 2.25                          -- large radius for demostrative purposes
                },
            },
        },
    },
    {
        type = "area",
        radius = 6.5,
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "nested-result",
                    repeat_count = 5,
                    action = {
                        galvanic_lightning_bolt,
                    },
                },
                {
                    type = "damage",
                    damage = { amount = 35, type = "electric" }
                },
                {
                    type = "create-entity",
                    entity_name = "explosion"
                },
            },
        },
    },
}

data:extend({ galvanic_grenade_projectile, })


galvanic_grenade.capsule_action.attack_parameters.ammo_type.action[1] = Util.table.deepcopy(base_grenade_projectile)
galvanic_grenade.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile = galvanic_grenade_projectile.name

galvanic_grenade.capsule_action.attack_parameters.ammo_category = "tesla-munition"

galvanic_grenade.capsule_action.attack_parameters.range = galvanic_grenade.capsule_action.attack_parameters.range * (4/3)

galvanic_grenade.enabled = true


data:extend({ galvanic_grenade, })
