local Util = require("__core__.lualib.util")

local tbl_types = require("prototypes.entities.table-types")

local __Data_Utils = require("data-utils")

--[[ atomic-wave-projectile ]]
return function (params)
    -- log(serpent.block(params))
    if (type(params) ~= "table") then return end

    local name = params.name

    local quality_name = params.quality_name
    local quality_level_multiplier = params.quality_level_multiplier

    local area_multiplier = params.area_multiplier
    local damage_multiplier = params.damage_multiplier

    local ground_zero_projectile = Util.table.deepcopy(data.raw["projectile"]["atomic-bomb-ground-zero-projectile"])
    ground_zero_projectile.name = name .. "-ground-zero-projectile-" .. quality_name
    ground_zero_projectile = tbl_types.recursively_apply_quality(ground_zero_projectile, damage_multiplier, area_multiplier, 1, quality_level_multiplier)

    if (params.damage_type) then
        local to_convert = tbl_types.find_by(ground_zero_projectile.action, "damage", {})

        if (to_convert and #to_convert > 0) then
            __Data_Utils.foreach(function (tbl)
                if (tbl.damage and tbl.damage.type and tbl.damage.type == "explosion") then
                    tbl.damage.type = params.damage_type
                end
            end, __Data_Utils.unpack(to_convert))
        end
    end

    local wave_projectile = Util.table.deepcopy(data.raw["projectile"]["atomic-bomb-wave"])
    wave_projectile.name = name .. "-wave-" .. quality_name
    wave_projectile = tbl_types.recursively_apply_quality(wave_projectile, damage_multiplier, area_multiplier, 1, quality_level_multiplier)

    if (params.damage_type) then
        local to_convert = tbl_types.find_by(wave_projectile.action, "damage", {})

        if (to_convert and #to_convert > 0) then
            __Data_Utils.foreach(function (tbl)
                if (tbl.damage and tbl.damage.type and tbl.damage.type == "explosion") then
                    tbl.damage.type = params.damage_type
                end
            end, __Data_Utils.unpack(to_convert))
        end
    end

    if (params.do_pollution) then
        if (not wave_projectile.action[1]) then wave_projectile.action = { wave_projectile.action, } end
        table.insert(wave_projectile.action,
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "script",
                            effect_id = name .. "-pollution"
                        },
                    },
                },
            }
        )
    end

    return { ground_zero_projectile, wave_projectile, }
end