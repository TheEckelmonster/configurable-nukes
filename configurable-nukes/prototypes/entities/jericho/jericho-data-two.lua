local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true

local sa_active = mods and mods["space-age"] and true

local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local __Data_Utils = require("data-utils")

-- DO_MAP_REVEAL
local function get_do_map_reveal()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.DO_MAP_REVEAL.name })
end
-- AREA_MULTIPLIER
local function get_area_multiplier()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER.name })
end
-- DAMAGE_MULTIPLIER
local function get_damage_multiplier()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_DAMAGE_MULTIPLIER.name })
end
-- REPEAT_MULTIPLIER
local function get_repeat_multiplier()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_REPEAT_MULTIPLIER.name })
end
-- SUB_ROCKET_REPEAT_MULTIPLIER
local function get_sub_rocket_repeat_multiplier()
    return Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_SUB_ROCKET_REPEAT_MULTIPLIER.name })
end

local tbl_types = require("prototypes.entities.table-types")

local do_map_reveal = get_do_map_reveal()
local area_multiplier = get_area_multiplier() * 1.355
local damage_multiplier = get_damage_multiplier() * 1.355
local repeat_multiplier = get_repeat_multiplier() * 1.355
repeat_multiplier = repeat_multiplier > 1 and repeat_multiplier ^ 0.42 or repeat_multiplier
local sub_repeat_multiplier = get_sub_rocket_repeat_multiplier()  * 1.355
sub_repeat_multiplier = sub_repeat_multiplier > 1 and sub_repeat_multiplier ^ 0.42 or sub_repeat_multiplier

-----------------------------------------------------------------------
-- Rocket PROJECTILE
-----------------------------------------------------------------------

local name = "cn-jericho"
local original_jericho = require("prototypes.entities.jericho.jericho-explosive-rocket")
original_jericho.name = name

local original_rocket = require("prototypes.entities.jericho.jericho-explosive-rocket")

local jericho = nil

local function create_quality_jericho(params)

    local quality = params.quality
    local k_0 = params.quality_level

    if (k_0 ~= "quality-unknown" and not quality.hidden) then
        local quality_munition = nil
        local default_multiplier = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name })

        if (default_multiplier) then
            local quality_level_multiplier = 1 + (default_multiplier - 1) * quality.level

            quality_munition = Util.table.deepcopy(original_jericho)
            quality_munition.name = name .. "-sub-rocket-" .. k_0

            quality_munition.action = tbl_types.recursively_apply_quality(quality_munition.action, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)

            local quality_jericho = Util.table.deepcopy(original_jericho)

            local delayed_active_trigger =
            {
                type = "delayed-active-trigger",
                name = name .. "-delayed-" .. k_0,
                delay = 32 + 64 * quality_level_multiplier ^ (0.35),
                repeat_count = 1 + 1.6 * sub_repeat_multiplier * quality_level_multiplier,
                repeat_delay = 32 + 32 * (1 / (quality_level_multiplier ^ (0.5))),
                action = {
                    type = "cluster",
                    cluster_count = 1 + 1.6 * sub_repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    distance = 2 + 6 * area_multiplier * quality_level_multiplier,
                    distance_deviation = 1.6 + 4 * area_multiplier * quality_level_multiplier,
                    repeat_count = 1 + 1.6 * sub_repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    probability = (0.35) ^ (1 / quality_level_multiplier),
                    ignore_collision_condition = true,
                    action_delivery = {
                        type = "projectile",
                        projectile = name .. "-sub-rocket-" .. k_0,
                        starting_speed = 0.001,
                        starting_speed_deviation = 0.0015,
                        direction_deviation = 2 * math.pi,
                        range_deviation = 1.6 + 2.4 * quality_level_multiplier,
                        max_range = 2 + 3.2 * area_multiplier * quality_level_multiplier,
                    },
                },
            }

            -- log(serpent.block(delayed_active_trigger))

            data:extend({ delayed_active_trigger, })

            quality_jericho.action.action_delivery =
            {
                {
                    type = "instant",
                    target_effects = {
                        {
                            type = "nested-result",
                            action = {
                                type = "direct",
                                action_delivery = {
                                    type = "delayed",
                                    delayed_trigger = name .. "-delayed-" .. k_0,
                                },
                            },
                        },
                        do_map_reveal and {
                            type = "script",
                            effect_id = "map-reveal"
                        } or nil,
                    }
                },
                quality_jericho.action.action_delivery,
            }

            jericho = Util.table.deepcopy(original_rocket)
            jericho.name = name .. "-rocket"

            jericho.action = tbl_types.recursively_apply_quality(jericho.action, damage_multiplier, area_multiplier, repeat_multiplier, quality_level_multiplier)

            local source_effects = jericho.action.action_delivery.target_effects
            local explosion_effect = {
                type = "create-explosion",
                entity_name = "hypergolic-explosion",
                probability = (1 / 4) ^ (1 / quality_level_multiplier),
            }
            local target_effects = { explosion_effect, }

            if (do_map_reveal) then
                table.insert(target_effects, 1, { type = "script", effect_id = "map-reveal", })
                table.insert(source_effects, 1, { type = "script", effect_id = "map-reveal", })
            end

            local cluster_projectile =
            {
                type = "projectile",
                name = name .. "-cluster-projectile-" .. k_0,
                acceleration = 0.01,
                turn_speed = 0.003,
                turning_speed_increases_exponentially_with_projectile_speed = true,
                action =
                {
                    type = "cluster",
                    cluster_count = 2 + 1.4 * sub_repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    distance = 2 + 8 * area_multiplier * quality_level_multiplier,
                    distance_deviation = 2.4 + 6 * area_multiplier * quality_level_multiplier,
                    repeat_count = 4 + 1.6 * sub_repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    probability = (0.35) ^ (1 / quality_level_multiplier),
                    action_delivery =
                    {
                        type = "projectile",
                        projectile = quality_jericho.name,
                        direction_deviation = 2 * math.pi,
                        starting_speed = 0.025,
                        starting_speed_deviation = 0.035,
                        -- source_effects = target_effects,
                        source_effects = cn_propulsion_active and source_effects or nil,
                        target_effects = cn_propulsion_active and target_effects or nil,
                        -- target_effects = do_map_reveal and {
                        --     type = "script",
                        --     effect_id = "map-reveal"
                        -- } or nil,
                    },
                },
                animation =
                {
                    filename = "__base__/graphics/entity/cluster-grenade/cluster-grenade.png",
                    draw_as_glow = true,
                    frame_count = 15,
                    line_length = 8,
                    animation_speed = 0.250,
                    width = 48,
                    height = 54,
                    shift = util.by_pixel(0.5, 0.5),
                    priority = "high",
                    scale = 0.5
                },
                shadow =
                {
                    filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
                    frame_count = 15,
                    line_length = 8,
                    animation_speed = 0.250,
                    width = 50,
                    height = 40,
                    shift = util.by_pixel(2, 6),
                    priority = "high",
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
            data:extend({ cluster_projectile, })

            jericho.action = {
                {
                    type = "cluster",
                    cluster_count = 2 + 1.4 * repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    distance = 2 + 4 * area_multiplier * quality_level_multiplier,
                    distance_deviation = 1.6 + 6 * area_multiplier * quality_level_multiplier,
                    repeat_count = 1 + 1.6 * repeat_multiplier * (quality_level_multiplier ^ 0.75),
                    ignore_collision_condition = false,
                    action_delivery = {
                        {
                            type = "projectile",
                            projectile = cluster_projectile.name,
                            direction_deviation = 2 * math.pi,
                            starting_speed = 0.025,
                            starting_speed_deviation = 0.035,
                            target_effects = do_map_reveal and {
                                type = "script",
                                effect_id = "map-reveal"
                            } or nil,
                            -- target_effects = explosion_target_effects,
                        },
                    },
                },
                jericho.action,
            }

            if (quality_munition ~= nil) then

                if (k_0 == "normal") then
                    local jericho_item = data.raw["ammo"][name]

                    local jericho = Util.table.deepcopy(quality_jericho)
                    jericho.name = name

                    if (jericho_item.icon) then
                        jericho.icon = Util.table.deepcopy(jericho_item.icon)
                    else
                        jericho.icons = Util.table.deepcopy(jericho_item.icons)
                    end

                    local to_convert = tbl_types.find_by(jericho.action, "damage", {})

                    if (to_convert and #to_convert > 0) then
                        __Data_Utils.foreach(function (tbl)
                            if (tbl.damage) then
                                tbl.show_in_tooltip = true
                            end
                        end, __Data_Utils.unpack(to_convert))
                    end

                    -- log(serpent.block(jericho))
                    jericho.animation = nil
                    jericho.shadow = nil
                    jericho.smoke = nil
                    data:extend({ jericho, })
                end

                local to_convert = tbl_types.find_by(jericho.action, "damage", {})

                if (to_convert and #to_convert > 0) then
                    __Data_Utils.foreach(function (tbl)
                        if (tbl.damage) then
                            tbl.show_in_tooltip = true
                            -- tbl.damage.amount = 1
                        end
                    end, __Data_Utils.unpack(to_convert))
                end

                jericho.name = jericho.name .. "-" .. k_0
                -- log(serpent.block(jericho))
                data:extend({jericho})

                quality_munition.name = name .. "-sub-rocket-" .. k_0
                -- log(serpent.block(quality_munition))
                data:extend({ quality_munition, })
            end
        end
    end
end

if (mods and mods["quality"]) then
    for k_0, quality in pairs(data.raw["quality"]) do
        if (k_0 == "normal") then
            create_quality_jericho({ quality_level = "normal", quality = { level = quality.level }})
        else
            create_quality_jericho({ quality_level = k_0, quality = quality })
        end
    end
else
    jericho = create_quality_jericho({ quality_level = "normal", quality = { level = 0 } })

    if (jericho) then
        data:extend({jericho})
    end
end