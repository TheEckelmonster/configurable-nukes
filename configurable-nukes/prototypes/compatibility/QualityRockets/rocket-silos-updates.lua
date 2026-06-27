--[[
    This file is effectively a copy of the data-updates.lua file
    from QualityRockets, adapted for configurable-nukes to allow
    parity with the ipbm-rocket-silo

    Credit: Moterius
    License: CC BY-NC-SA, https://creativecommons.org/licenses/by-nc-sa/4.0/
]]

local Util = require("__core__.lualib.util")

local ipbm_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]

ipbm_silo.fast_replaceable_group = "rocket-silo"
ipbm_silo.icon = "__configurable-nukes__/graphics/icons/ipbm-rocket-silo.png"

local qualities_to_ignore = {
    "quality-unknown",
    "normal",
}

local quality_multipliers = {}
for k, quality in pairs(data.raw["quality"]) do
    -- if (not quality.hidden) then
        --[[ TODO: Make this configurable ]]
        local multiplier = 0.3

        quality_multipliers[quality.name] = (1 - multiplier) ^ quality.level
    -- end
end

for k_0, quality in pairs(data.raw["quality"]) do
    if (qualities_to_ignore[k_0] or quality.hidden) then goto continue end

    local quality_multiplier = 1 + quality.level * 0.3
    local name = quality.name

    local rocket = Util.table.deepcopy(data.raw["rocket-silo-rocket"]["ipbm-rocket-silo-rocket"])
    rocket.name = name .."-"..rocket.name

    rocket.rising_speed = rocket.rising_speed * quality_multiplier

    rocket.engine_starting_speed = rocket.engine_starting_speed * quality_multiplier

    rocket.flying_speed = rocket.flying_speed * quality_multiplier
    rocket.flying_acceleration = rocket.flying_acceleration * quality_multiplier

    local silo = Util.table.deepcopy(data.raw["rocket-silo"]["ipbm-rocket-silo"])
    silo.name = name .."-"..silo.name
    silo.icon = "__configurable-nukes__/graphics/icons/ipbm-rocket-silo.png"

    silo.door_opening_speed = silo.door_opening_speed * quality_multiplier
    silo.rocket_entity = rocket.name

    silo.localised_name = { "entity-name.ipbm-rocket-silo", }
    silo.localised_description = { "entity-description.ipbm-rocket-silo", }

    silo.placeable_by = { item = "ipbm-rocket-silo", count = 1, }

    silo.clamps_on_trigger = {
        type = "script",
        effect_id = "clamps_on_trigger"
    }

    -- log(serpent.block(quality_multipliers))
    -- silo.quality_affects_energy_usage = true
    -- silo.energy_usage_quality_multiplier = quality_multipliers
    -- log(serpent.block(silo))

    silo.hidden = true

    data:extend({rocket, silo})

    ::continue::
end