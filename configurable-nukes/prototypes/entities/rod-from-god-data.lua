local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local create_quality_atomic_munitions = require("prototypes.entities.atomic.quality-atomic-munition")

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
-- FIRE_WAVE
local get_fire_wave = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ROD_FROM_GOD_FIRE_WAVE.name })
end

local area_multiplier = get_area_multiplier() * 1.57
local damage_multiplier = get_damage_multiplier() * 1.57
local repeat_multiplier = get_repeat_multiplier() * 1.57

local max_nuke_shockwave_movement_distance_deviation = 2
max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation * area_multiplier

local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
max_nuke_shockwave_movement_distance = 19 * area_multiplier


-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------

local name = "cn-rod-from-god"
local original_munition = Util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])

original_munition.name = name

for k, v in pairs(original_munition.animation.layers) do
    if (v.filename == "__base__/graphics/entity/rocket/rocket-tinted-tip.png") then
        v.tint = { 31, 7, 81, 95 }
    end
end

local target_effects = original_munition.action.action_delivery.target_effects
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

local munition = nil

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "quality-unknown" or quality.hidden) then goto continue end

        local quality_munition = create_quality_atomic_munitions({
            quality = quality,
            quality_level = k_0,
            name = name,
            original = original_munition,
            area_multiplier = area_multiplier,
            damage_multiplier = damage_multiplier,
            repeat_multiplier = repeat_multiplier,
            max_nuke_shockwave_movement_distance = max_nuke_shockwave_movement_distance,
            max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
            --[[ TODO: Add startup settings for this ]]
            do_pollution = false,
            fire_wave = get_fire_wave(),
            damage_type = "physical",
        })

        if (quality_munition ~= nil) then
            if (k_0 == "normal" or quality.level == 0) then
                munition = Util.table.deepcopy(quality_munition)
                munition.name = original_munition.name

                local quality_munition_ammo_item = data.raw["ammo"]["cn-rod-from-god"]

                if (quality_munition_ammo_item.icon) then
                    munition.icon = Util.table.deepcopy(quality_munition_ammo_item.icon)
                else
                    munition.icons = Util.table.deepcopy(quality_munition_ammo_item.icons)
                end

                data:extend({ munition, })
            end

            quality_munition.name = original_munition.name .. "-" .. k_0
            data:extend({quality_munition})
        end

        ::continue::
    end
else
    local quality_munition = create_quality_atomic_munitions({
        quality = { level = 0 },
        quality_level = "normal",
        name = name,
        original = original_munition,
        area_multiplier = area_multiplier,
        damage_multiplier = damage_multiplier,
        repeat_multiplier = repeat_multiplier,
        max_nuke_shockwave_movement_distance = max_nuke_shockwave_movement_distance,
        max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
        --[[ TODO: Add startup settings for this ]]
        do_pollution = false,
        fire_wave = get_fire_wave(),
        damage_type = "physical",
    })

    data:extend({ quality_munition, })
end