local mods = mods

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true
local quality_active = mods and mods["quality"]

if ((sa_active or se_active) and quality_active) then
    local interplanetary_rocket_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]

    local quality_multipliers = {}
    for k, quality in pairs(data.raw["quality"]) do
        -- if (not quality.hidden) then
            --[[ TODO: Make this configurable ]]
            local multiplier = 0.3

            log(serpent.block(quality))
            quality_multipliers[quality.name] = (1 - multiplier) ^ quality.level
            quality.crafting_maching_energy_usage_multiplier = quality_multipliers[quality.name]
            log(serpent.block(quality))
        -- end
    end

    log(serpent.block(quality_multipliers))
    interplanetary_rocket_silo.quality_affects_energy_usage = true
    -- interplanetary_rocket_silo.energy_usage_quality_multiplier = quality_multipliers
    -- log(serpent.block(interplanetary_rocket_silo))
    data:extend({ interplanetary_rocket_silo, })
end