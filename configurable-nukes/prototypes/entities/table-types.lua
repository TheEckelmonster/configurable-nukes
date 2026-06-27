local UINT8 = 2 ^ 8 - 1
local UINT16 = 2 ^ 16 - 1
local UINT24 = 2 ^ 24 - 1
local UINT32 = 2 ^ 32 - 1
local UINT64 = 2 ^ 64 - 1

local function clamp(value, max, min)
    if (not value or type(value) ~= "number") then return end
    max = max or UINT8
    min = min or 0

    if (value < min) then value = min
    elseif (value > max) then value = max
    end

    return value
end

local tbl_type = {}

tbl_type.area_multiplier = 1
tbl_type.repeat_multiplier = 1
tbl_type.damage_multiplier = 1

tbl_type.types = {
    --[[ trigger ]]
    -- ["action"] = function (tbl, quality_level_multiplier)
    --     if (not tbl or type(tbl) ~= "table") then return end
    --     if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then return end

    --     if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    -- end,
    ["direct"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT32) end
    end,
    ["area"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.radius = clamp(tbl.radius * area_multiplier * quality_level_multiplier, UINT64)
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT32) end
    end,
    ["line"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.range = clamp(tbl.range * area_multiplier * quality_level_multiplier, UINT64)
        tbl.width = clamp(tbl.width * area_multiplier * quality_level_multiplier, UINT64)
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT32) end
    end,
    ["range_effects"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT32) end
    end,
    ["cluster"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.cluster = clamp(tbl.cluster * repeat_multiplier * quality_level_multiplier, UINT32, 2)
        tbl.distance = clamp(tbl.distance * area_multiplier * quality_level_multiplier, UINT24)
        if (tbl.distance_deviation) then tbl.distance = clamp(tbl.distance * area_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT32) end
    end,

    --[[ trigger-delivery ]]
    -- ["action_delivery"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
    --     if (not tbl or type(tbl) ~= "table") then return end
    --     if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then return end


    --     if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    -- end,
    ["instant"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["projectile"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, projectile)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (projectile) then tbl.projectile = projectile end
        if (tbl.starting_speed) then tbl.starting_speed = clamp(tbl.starting_speed * area_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.max_range) then tbl.max_range = clamp(tbl.max_range * area_multiplier * quality_level_multiplier, UINT64) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["beam"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, beam)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (beam) then tbl.projectile = beam end
        if (tbl.duration) then tbl.duration = clamp(tbl.duration * repeat_multiplier * quality_level_multiplier, UINT32) end
        if (tbl.max_length) then tbl.max_length = clamp(tbl.max_length * area_multiplier * quality_level_multiplier, UINT32) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["stream"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, stream)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (stream) then tbl.stream = stream end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["artillery"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, projectile)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (projectile) then tbl.projectile = projectile end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["chain"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, chain)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (chain) then tbl.chain = chain end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["delayed"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, delayed_trigger)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (delayed_trigger) then tbl.delayed_trigger = delayed_trigger end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,

    --[[ trigger-effect ]]
    ["target_effects"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["source_effects"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["damage"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.damage.amount = clamp(tbl.damage.amount * damage_multiplier * quality_level_multiplier, UINT24)
        if (tbl.lower_distance_threshold) then tbl.lower_distance_threshold = clamp(tbl.lower_distance_threshold * repeat_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.upper_distance_threshold) then tbl.upper_distance_threshold = clamp(tbl.upper_distance_threshold * repeat_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.lower_damage_modifier) then tbl.lower_damage_modifier = clamp(tbl.lower_damage_modifier * repeat_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.upper_damage_modifier) then tbl.upper_damage_modifier = clamp(tbl.upper_damage_modifier * repeat_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["damage-tile"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.damage.amount = clamp(tbl.damage.amount * damage_multiplier * quality_level_multiplier, UINT24)
        if (tbl.radius) then tbl.radius = clamp(tbl.radius * area_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-entity"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-explosion"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.max_movement_distance) then tbl.max_movement_distance = clamp(tbl.max_movement_distance * area_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-fire"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.initial_ground_flame_count) then tbl.initial_ground_flame_count = clamp(tbl.initial_ground_flame_count * repeat_multiplier * quality_level_multiplier, UINT8) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-smoke"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-trivial-smoke"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-asteroid-chunk"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-particle"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-sticker"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["create-decorative"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.spawn_max = clamp(tbl.spawn_max * area_multiplier * quality_level_multiplier, UINT16)
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["nested-result"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["play-sound"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.max_distance) then tbl.max_distance = clamp(tbl.max_distance * area_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["push-back"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.distance) then tbl.distance = clamp(tbl.distance * repeat_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["destroy-cliffs"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.radius = clamp(tbl.radius * area_multiplier * quality_level_multiplier, UINT16)
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["show-explosion-on-chart"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.scale) then tbl.scale = tbl.scale * area_multiplier * quality_level_multiplier end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["insert-item"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        --[[ Gut feeling to do nothing in this case, not sure why ]]
        -- if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["script"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["set-tile"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.radius) then tbl.radius = clamp(tbl.radius * area_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["invoke-tile-trigger"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["destroy-decoratives"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        tbl.radius = tbl.radius * area_multiplier * quality_level_multiplier
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["camera-effect"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.full_strength_max_distance) then tbl.full_strength_max_distance = clamp(tbl.full_strength_max_distance * area_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.max_distance) then tbl.max_distance = clamp(tbl.max_distance * area_multiplier * quality_level_multiplier, UINT16) end
        if (tbl.strength) then tbl.strength = clamp(tbl.strength * area_multiplier * quality_level_multiplier, UINT24) end
        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
    ["activate-impact"] = function (tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
        if (not tbl or type(tbl) ~= "table") then return end
        if (not damage_multiplier or type(damage_multiplier) ~= "number") then damage_multiplier = 1 end
        if (not area_multiplier or type(area_multiplier) ~= "number") then area_multiplier = 1 end
        if (not repeat_multiplier or type(repeat_multiplier) ~= "number") then repeat_multiplier = 1 end
        if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

        if (tbl.repeat_count) then tbl.repeat_count = clamp(tbl.repeat_count * repeat_multiplier * quality_level_multiplier, UINT16) end
    end,
}

function tbl_type.recursively_apply_quality(tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, name)
    if (not tbl or type(tbl) ~= "table") then return tbl end
    if (not quality_level_multiplier or type(quality_level_multiplier) ~= "number") then quality_level_multiplier = 1 end

    local found = {}

    local function r(_tbl)
        if (not _tbl or type(_tbl) ~= "table") then return end

        if (not found[_tbl]) then found[_tbl] = 1 end

        for k, v in pairs(_tbl) do
            if (type(v) == "table") then
                if (not found[v]) then
                    found[v] = 1
                    r(v)
                end
            end
        end

        if (_tbl.type) then
            if (tbl_type.types[_tbl.type]) then
                tbl_type.types[_tbl.type](_tbl, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier, name)
            end
        end
    end

    r(tbl)

    return tbl
end

function tbl_type.find_planet_nuke_effects(nuke)
    if (not nuke or type(nuke) ~= "table") then return end

    local found = {}

    local ret = {}
    local function recurse(tbl, opt)
        if (not tbl or type(tbl) ~= "table") then return end
        opt = opt or {}
        opt.p_tbl = opt.p_tbl or ret

        if (not found[tbl]) then found[tbl] = 1 end

        for k, v in pairs(tbl) do
            if (type(v) == "table") then
                if (not found[v]) then
                    found[v] = 1
                    recurse(v, { p_tbl = tbl, k = k, })
                end
            end
        end

        if (tbl.type and tbl.type == "create-entity") then
            if (tbl.entity_name and tbl.entity_name:find("nuke%-effects%-")) then
                -- ret[#ret+1] = tbl
                ret[#ret+1] = { p_tbl = opt.p_tbl, tbl = tbl, entity_name = tbl.entity_name, k = opt.k, }
            end
        end

        -- return ret
    end

    recurse(nuke.action)

    return ret
end

function tbl_type.find_by(tbl, by, to_find)
    if (type(tbl) ~= "table") then return end
    if (type(by) ~= "string" or by:gsub("%s", "") == "") then return end
    if (type(to_find) ~= "table") then return end

    local found = {}

    local ret = {}
    local function recurse(_tbl)
        if (not _tbl or type(_tbl) ~= "table") then return end

        if (not found[_tbl]) then found[_tbl] = 1 end

        for k, v in pairs(_tbl) do
            if (type(v) == "table") then
                if (not found[v]) then
                    found[v] = 1
                    recurse(v)
                end
            end
        end

        if (_tbl[by] and (to_find[_tbl[by]] or table_size(to_find) == 0)) then
            ret[#ret+1] = _tbl
        end

        return ret
    end

    recurse(tbl)

    return ret
end

return tbl_type