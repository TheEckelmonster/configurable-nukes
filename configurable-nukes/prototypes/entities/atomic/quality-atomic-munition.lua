local data = data
local mods = mods

local sa_active = mods and mods["space-age"] and true

local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

-- QUALITY_BASE_MODIFIER
local get_quality_base_multiplier = function ()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })
end

local __Data_Utils = require("data-utils")

local create_fire_wave = require("prototypes.entities.atomic.atomic-fire")
local create_atomic_wave_explosions = require("prototypes.entities.atomic.atomic-wave-explosion")
local create_atomic_wave_projectiles = require("prototypes.entities.atomic.atomic-wave-projectile")

local tbl_types = require("prototypes.entities.table-types")

--[[ create-quality-atomic-munition ]]
---@param params table<
---|"quality",
---|"quality_level"
---|"name"
---|"original"
---|"area_multiplier"
---|"damage_multiplier"
---|"repeat_multiplier"
---|"max_nuke_shockwave_movement_distance"
---|"max_nuke_shockwave_movement_distance_deviation"
---|"do_pollution"
---|"fire_wave"
---|"damage_type"?
---|>>
return function (params)
    -- log(serpent.block(params))
    local quality = params.quality

    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local name = params.name
        local original = params.original

        local area_multiplier = params.area_multiplier
        local damage_multiplier = params.damage_multiplier
        local repeat_multiplier = params.repeat_multiplier

        local max_nuke_shockwave_movement_distance = params.max_nuke_shockwave_movement_distance
        local max_nuke_shockwave_movement_distance_deviation = params.max_nuke_shockwave_movement_distance_deviation

        local quality_munition = nil
        local default_multiplier = get_quality_base_multiplier()

        local quality_level_multiplier = 1 + (default_multiplier - 1) * quality.level

        if (default_multiplier) then
            quality_munition = Util.table.deepcopy(original)
            quality_munition.name = name .. "-" .. k_0

            if (sa_active and false) then
                local planet_nuke_effects = tbl_types.find_planet_nuke_effects(quality_munition)
                if (planet_nuke_effects) then
                    log(serpent.block(planet_nuke_effects))

                    local nuke_effects = {
                        ["nuke-effects-fulgora"] = "fulgora",
                        ["nuke-effects-gleba"] = "gleba",
                    }

                    local planets = {}
                    for k, v in pairs(data.raw.planet or {}) do
                        local name = "nuke-effects-" .. k
                        planets[name] = { check_buildability = true, entity_name = name, type = "create-entity", }
                    end

                    for planet, effect in pairs(planets) do
                        local exists = false
                        local parent = nil
                        local start = nil

                        for i, nuke_effect in ipairs(planet_nuke_effects) do
                            log(serpent.block(nuke_effect))
                            if (not start) then start = nuke_effect.k end
                            parent = nil
                            if (nuke_effects[nuke_effect.entity_name or ""] == planet) then
                                exists = true
                                break
                            end
                            -- parent = { tbl = nuke_effect.p_tbl, i = i, }
                            parent = { tbl = nuke_effect.p_tbl, k = nuke_effect.k, }
                        end

                        -- log(serpent.block(start))
                        if (not exists and parent) then
                            local new_effect = {
                                p_tbl = parent.tbl,
                                -- k = (start - 1 or 1) + parent.i,
                                k = (start - 1 or 1) + parent.k - 1,
                                tbl = effect,
                                entity_name = effect.entity_name,
                            }

                            -- log(serpent.block(new_effect))

                            planet_nuke_effects[#planet_nuke_effects].k = planet_nuke_effects[#planet_nuke_effects].k + 1
                            -- table.insert(planet_nuke_effects, #planet_nuke_effects, effect)
                            table.insert(planet_nuke_effects, #planet_nuke_effects, new_effect)
                            -- table.insert(parent.tbl, parent.i, effect)
                            table.insert(parent.tbl, parent.k, effect)
                        end
                    end

                    log(serpent.block(planet_nuke_effects))
                    for _, nuke_effect in ipairs(planet_nuke_effects) do
                        -- nuke_effect.entity_name = nuke_effect.entity_name .. "-" .. k_0
                        -- if (k_0 ~= "normal") then
                            if (nuke_effect.k) then
                                if (nuke_effect.p_tbl[nuke_effect.k]) then
                                    if (nuke_effect.p_tbl[nuke_effect.k].entity_name and not nuke_effect.p_tbl[nuke_effect.k].entity_name:find(k_0, 1, true)) then
                                        nuke_effect.p_tbl[nuke_effect.k].entity_name = nuke_effect.p_tbl[nuke_effect.k].entity_name .. "-" .. k_0
                                    end
                                end
                            else
                                if (not nuke_effect.entity_name:find(k_0, 1, true)) then
                                    nuke_effect.entity_name = nuke_effect.entity_name .. "-" .. k_0
                                end
                            end
                        -- end
                    end
                    log(serpent.block(planet_nuke_effects))

                    local lookup_tbl = {}

                    for k, v in pairs(planet_nuke_effects) do
                        -- lookup_tbl[(v.entity_name and v.entity_name:match("nuke%-effects%-(.*)") or "") .. "-" .. k_0] = k
                        lookup_tbl[(v.entity_name and v.entity_name:match("(nuke%-effects%-.*)") or "") .. "-" .. k_0] = k
                    end

                    log(serpent.block(lookup_tbl))

                    local planet_surface_conditions = {}
                    for k, v in pairs(data.raw.planet) do
                        planet_surface_conditions[k] =
                                v.surface_properties
                            and tonumber(v.surface_properties.pressure)
                            and v.surface_properties
                            or
                                k == "nauvis"
                            and { pressure = 1000, }
                            or
                                nil
                    end

                    -- log(serpent.block(planet_surface_conditions))

                    local planet_black_list = {
                        ["space"] = 1,
                        ["vulcanus"] = 1,
                    }

                    __Data_Utils.foreach(function (tbl)
                        -- log(serpent.block(tbl))

                        -- local planet_name = tbl.entity_name:match("nuke%-effects%-(.*)%-*")
                        -- local planet_name = tbl.entity_name:match("nuke%-effects%-(.*)%-" .. k_0)
                        local planet_name = tbl.entity_name:match("nuke%-effects%-(.*)%-" .. k_0) or tbl.entity_name:match("nuke%-effects%-(.*)")
                        log(serpent.block(planet_name))

                        local base_nuke_effect = Util.table.deepcopy(data.raw["explosion"]["nuke-effects-vulcanus"])
                        log(serpent.block(base_nuke_effect))
                        if (type(base_nuke_effect) ~= "table") then return end

                        if (k_0 ~= "normal") then
                            base_nuke_effect.name = "nuke-effects-" .. planet_name
                        else
                            base_nuke_effect.name = "nuke-effects-" .. planet_name .. "-" .. k_0
                        end
                        local nuke_effect = Util.table.deepcopy(data.raw["explosion"][tbl.entity_name] or base_nuke_effect)
                        if (not data.raw["explosion"][tbl.entity_name]) then
                            nuke_effect.name = tbl.entity_name
                            data:extend({ nuke_effect })
                        end
                        log(serpent.block(nuke_effect))

                        if (    not planet_black_list[planet_name]
                            and planet_surface_conditions[planet_name]
                            and planet_surface_conditions[planet_name].pressure
                            and planet_surface_conditions[planet_name].pressure >= 800
                        ) then
                            local lava_nuke_effect = Util.table.deepcopy(data.raw["explosion"]["nuke-effects-vulcanus"])
                            -- lava_nuke_effect.name = lava_nuke_effect.name:gsub("vulcanus", planet_name) .. "-" .. k_0
                            log(serpent.block(base_nuke_effect.name))
                            lava_nuke_effect.name = base_nuke_effect.name
                            lava_nuke_effect.surface_conditions = {}
                            log(serpent.block(planet_name))
                            if (planet_surface_conditions[planet_name].pressure) then
                                lava_nuke_effect.surface_conditions[1] = { max = planet_surface_conditions[planet_name].pressure, min = planet_surface_conditions[planet_name].pressure, property = "pressure", }
                            end

                            log(serpent.block(lava_nuke_effect))
                            lava_nuke_effect = tbl_types.recursively_apply_quality(lava_nuke_effect, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
                            lava_nuke_effect.quality_applied = 1
                            log(serpent.block(lava_nuke_effect))

                            if (k_0 == "normal") then
                                local normal = Util.table.deepcopy(lava_nuke_effect)
                                normal.name = normal.name:match("(.+)%-normal$") or normal.name
                                log(serpent.block(normal.name))
                                data:extend({ normal, })
                            end

                            -- tbl.entity_name = lava_nuke_effect.name

                            data:extend({ lava_nuke_effect, })

                        else
                            log(serpent.block(nuke_effect))
                            nuke_effect = tbl_types.recursively_apply_quality(nuke_effect, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)
                            log(serpent.block(nuke_effect))

                            if (k_0 == "normal") then
                                local normal = Util.table.deepcopy(nuke_effect)
                                normal.name = normal.name:match("(.+)%-normal$") or normal.name
                                log(serpent.block(normal.name))
                                data:extend({ normal, })
                            end

                            -- if (not nuke_effect.name:find(k_0, 1, true)) then
                            if (k_0 ~= "normal" and not nuke_effect.name:find(k_0, 1, true)) then
                                nuke_effect.name = nuke_effect.name .. "-" .. k_0
                            end
                            tbl.entity_name = nuke_effect.name

                            data:extend({ nuke_effect, })
                        end
                    end, __Data_Utils.unpack(planet_nuke_effects))
                end
            end

            data:extend(
                create_atomic_wave_explosions({
                    name = name,
                    quality_name = k_0,
                    quality_level_multiplier = quality_level_multiplier,
                    max_nuke_shockwave_movement_distance = max_nuke_shockwave_movement_distance,
                    max_nuke_shockwave_movement_distance_deviation = max_nuke_shockwave_movement_distance_deviation,
                })
            )

            data:extend(
                create_atomic_wave_projectiles({
                    name = name,
                    quality_name = k_0,
                    quality_level_multiplier = quality_level_multiplier,
                    area_multiplier = area_multiplier,
                    damage_multiplier = damage_multiplier,
                    do_pollution = params.do_pollution,
                    damage_type = params.damage_type,
                })
            )

            quality_munition.action = tbl_types.recursively_apply_quality(quality_munition.action, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)

            local to_rename = tbl_types.find_by(quality_munition.action, "projectile",
                {
                    ["atomic-bomb-wave-spawns-nuke-shockwave-explosion"] = 1,
                    ["atomic-bomb-wave-spawns-fire-smoke-explosion"] = 1,
                    ["atomic-bomb-ground-zero-projectile"] = 1,
                    ["atomic-bomb-wave"] = 1,
                }
            )

            if (to_rename and #to_rename > 0) then
                __Data_Utils.foreach(function (tbl)
                    if (tbl.projectile) then 
                        -- tbl.projectile = name .. (tbl.projectile:match(name:gsub("%-", "%%-") .. "(.*)") or "") .. "-" .. k_0
                        tbl.projectile = name .. (tbl.projectile:match("atomic%-bomb(.*)") or "") .. "-" .. k_0
                    end
                end, __Data_Utils.unpack(to_rename))
            end

            if (params.fire_wave) then
                local fire_wave = create_fire_wave(
                    name,
                    k_0,
                    {
                        quality_level_multiplier = quality_level_multiplier,
                        damage_multiplier = damage_multiplier,
                        area_multiplier = area_multiplier,
                        repeat_multiplier = repeat_multiplier,
                    }
                )
                if (fire_wave) then table.insert(quality_munition.action.action_delivery.target_effects, fire_wave) end
            end
        end

        return quality_munition
    end
end