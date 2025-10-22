-- If already defined, return
if _icbm_utils and _icbm_utils.configurable_nukes then
  return _icbm_utils
end

local Constants = require("scripts.constants.constants")
local Custom_Events = require("prototypes.custom-events.custom-events")
local Force_Launch_Data_Repository = require("scripts.repositories.force-launch-data-repository")
local Log = require("libs.log.log")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Service = require("scripts.services.settings-service")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local icbm_utils = {
    space_launches_initiated = {}
}
icbm_utils.name = "icbm_utils"

local time_to_target_message = function (params)
    local print_message = function (param_1, param_2)
        if (param_1 and param_1.force and param_1.force.valid) then
            param_1.force.print({ "icbm-utils.seconds-to-target", param_1.item_number, param_2 })
        end
    end

    if (params.icbm_data.player_launched_index == 0) then
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
            print_message(params.icbm_data, params.seconds_to_target)
        end
    else
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
            print_message(params.icbm_data, params.seconds_to_target)
        end
    end
end

function icbm_utils.on_cargo_pod_finished_ascending(data)
    Log.debug("icbm_utils.on_cargo_pod_finished_ascending")
    Log.info(data)

    if (data == nil) then return -1 end
    if (data.surface == nil or not data.surface.valid) then return -1 end
    if (data.item == nil or type(data.item) ~= "table") then return -1 end
    if (data.cargo_pod == nil or not data.cargo_pod.valid) then return -1 end
    if (data.tick == nil or type(data.tick) ~= "number") then return -1 end

    local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(data.surface.name)

    local k, icbm_data = next(icbm_meta_data.icbms, nil)
    while k or (not k and icbm_data) do
        if (icbm_data and icbm_data.cargo_pod_unit_number and icbm_data.cargo_pod_unit_number == data.cargo_pod.unit_number) then
            break
        end

        if (k) then k, icbm_data = next(icbm_meta_data.icbms, k) end
    end

    if (icbm_data == nil) then
        Log.warn("icbm_data not found by cargo_pod unit_number")
        Log.warn("no icbm_data found")
        return -1
    end

    Log.warn(icbm_data)

    if (icbm_data.scrubbed) then return 0 end

    local guidance_systems_modifier = icbm_data.force.get_ammo_damage_modifier("icbm-guidance") or 0
    local top_speed_modifier = icbm_data.force.get_ammo_damage_modifier("icbm-top-speed") or 1

    local time_to_target = 0
    local magnitude = Constants.planets_dictionary[icbm_data.target_surface_name] and Constants.planets_dictionary[icbm_data.target_surface_name].magnitude or 1
    local from_ipbm_silo = icbm_data.source_silo and icbm_data.source_silo.valid and icbm_data.source_silo.name == "ipbm-rocket-silo"

    local target_distance = icbm_data.target_distance

    local destination_is_target = false
    local destination = nil
    local from, to = nil, nil
    local origin_space_location = nil

    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    --[[ Check if there is a platform attached to the given surface; and if the potential platform has a schedule with a valid destination ]]
    if (not se_active and icbm_data.source_silo and icbm_data.source_silo.valid and icbm_data.source_silo.surface.valid and icbm_data.source_silo.surface.platform and icbm_data.source_silo.surface.platform.valid) then
        local schedule = icbm_data.source_silo.surface.platform.schedule
        Log.warn(schedule)

        origin_space_location = icbm_data.source_silo.surface.platform.last_visited_space_location

        if (schedule) then
            local current = schedule.records[schedule.current]
            destination = current.station
            Log.warn(serpent.block(current))
            if (current and current.station == icbm_data.target_surface_name) then
                destination_is_target = true
            end
        end
    end

    if (icbm_data.launched_from) then
        Log.warn("launched_from = " .. icbm_data.launched_from)
        if (not se_active and not Constants.planets_dictionary[destination]) then Constants.get_planets(true) end
        local destination_planet = Constants.planets_dictionary[destination]

        --[[ Get the origin_planet orientation ]]
        local origin_planet = nil
        if (origin_space_location and origin_space_location.name) then
            if (not Constants.planets_dictionary[origin_space_location.name]) then Constants.get_planets(true) end
            origin_planet = Constants.planets_dictionary[origin_space_location.name]
        else
            if (se_active) then
                if (not Constants.space_exploration_dictionary[icbm_data.surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
                origin_planet = Constants.space_exploration_dictionary[string.lower(icbm_data.surface.name)]
                Log.warn(origin_planet and origin_planet.name)
                Log.debug(origin_planet)
                if (not origin_planet) then
                    if (not Constants.mod_data_dictionary["se-" .. icbm_data.surface.name:lower()]) then Constants.get_mod_data(true) end
                    origin_planet = Constants.mod_data_dictionary["se-" .. icbm_data.surface.name:lower()]
                    Log.warn(origin_planet and origin_planet.name)
                    Log.debug(origin_planet)
                end
            else
                --[[ This shouldn't be possible? ]]
                Log.warn("no origin planet found")
                Log.warn("defaulting to destination planet")
                origin_planet = destination_planet
            end
        end

        local platform = icbm_data.surface and icbm_data.surface.valid and icbm_data.surface.platform and icbm_data.surface.platform.valid and icbm_data.surface.platform
        local remaining_distance = 0

        if (not se_active and platform and platform.space_connection and platform.space_connection.valid) then
            if (not Constants.planets_dictionary[icbm_data.target_surface_name]) then Constants.get_planets(true) end
            local target_planet = Constants.planets_dictionary[icbm_data.target_surface_name]
            if (not Constants.space_connections_dictionary[origin_planet.name .. "-" .. target_planet.name]) then Constants.get_space_connections(true) end
            local space_connection = Constants.space_connections_dictionary[origin_planet.name .. "-" .. target_planet.name]
            if not (space_connection) then
                if (not Constants.space_connections_dictionary[platform.space_connection.name]) then Constants.get_space_connections(true) end
                space_connection = Constants.space_connections_dictionary[platform.space_connection.name]
            end
            remaining_distance = target_planet and ((icbm_data.space_origin_pos.x - target_planet.x) ^ 2 + (icbm_data.space_origin_pos.y - target_planet.y) ^ 2) ^ 0.5 or 0
            remaining_distance = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name }) * remaining_distance
        end

        target_distance = icbm_data.launched_from == "orbit" and ((math.log(1 + target_distance, 10 * (4 - 3 * (1 + guidance_systems_modifier)))) * magnitude) or target_distance

        local distance_modifier = (1 - 0.125) * (1 + guidance_systems_modifier) + 0.125
        target_distance = icbm_data.launched_from == "surface" and icbm_data.same_surface and ((target_distance * distance_modifier) * magnitude) or target_distance

        local exponent = 1 - (1/3) * guidance_systems_modifier
        local base = ((1 + target_distance) ^ (exponent)) + 1
        local base_log = math.log(1 + target_distance, base)
        target_distance = destination_is_target and icbm_data.launched_from == "interplanetary" and base_log * target_distance or target_distance

        if (icbm_data.launched_from == "interplanetary" and icbm_data.launched_from_space) then
            Log.debug("setting starting_speed_bonus")
            icbm_data.starting_speed_bonus = 2.8125
        end
    end

    if (data.tick and guidance_systems_modifier ~= nil) then
        --[[ TODO: Make in space top speed configurable? ]]
        local in_space_speed_modifier = 1.66 + (2.71 * top_speed_modifier)

        if (not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_PERFECT_GUIDANCE.name }) or math.abs(guidance_systems_modifier) < 1) then
            local distance_divisor = (32 / magnitude)

            if (icbm_data.launched_from) then
                distance_divisor = icbm_data.launched_from == "orbit" and (32 / magnitude) * 0.625 or distance_divisor
                distance_divisor = icbm_data.launched_from == "surface" and (24 / magnitude ^ 1.5) or distance_divisor
                distance_divisor = icbm_data.launched_from == "interplanetary" and (16 / magnitude ^ 2.25) * 1.25 or distance_divisor
            end

            if (from_ipbm_silo) then
                if (icbm_data.launched_from == "interplanetary") then
                    distance_divisor = distance_divisor * 24
                else
                    distance_divisor = distance_divisor * 12
                end
            else
                if (icbm_data.launched_from == "interplanetary") then
                    distance_divisor = distance_divisor * 16
                else
                    distance_divisor = distance_divisor * 8
                end
            end

            local icbm_deviation_scaling_factor = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_DEVIATION_SCALING_FACTOR.name })
            local guidance_systems_deviation_base_modifier = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER.name })
            local guidance_systems_deviation_max = 10 * math.abs(guidance_systems_deviation_base_modifier)
            local deviation_proportion = 1 - math.abs(guidance_systems_modifier) / guidance_systems_deviation_max

            local deviation_threshold = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_GUIDANCE_DEVIATION_THRESHOLD.name })
            local threshold = -(1 - deviation_threshold) * guidance_systems_modifier + deviation_threshold
            if (threshold - 1 < 0) then
                for i = 1, math.floor(target_distance / distance_divisor), 1 do
                    --[[ This shouldn't be necessary? ]]
                    if (threshold >= 1) then break end
                    local rand = math.random()

                    Log.warn("rand = " .. rand)
                    Log.warn("threshold = " .. threshold)
                    if (rand > threshold) then
                        -- Target deviation
                        Log.warn("deviating from target: " .. i)
                        local deviation_limit = 32 ^ 1

                        if (icbm_data.silo_type == "ipbm-rocket-silo") then
                            deviation_limit = ((8 + deviation_proportion * 16) * (i ^ (math.pi / 6))) ^ (0.75 * icbm_deviation_scaling_factor)
                        else
                            deviation_limit = ((16 + deviation_proportion * 16) * (i ^ (math.pi / 6))) ^ icbm_deviation_scaling_factor
                        end
                        Log.warn("deviation_limit = " .. deviation_limit)
                        deviation_limit = math.exp(1) * math.log(deviation_limit + 1, math.exp(1)) * deviation_limit ^ 0.25
                        Log.warn(deviation_limit)

                        if (not se_active) then
                            Log.warn("deviation_limit = " .. deviation_limit)
                            icbm_data.target_position = {
                                x = icbm_data.target_position.x + math.random(-deviation_limit, deviation_limit),
                                y = icbm_data.target_position.y + math.random(-deviation_limit, deviation_limit),
                            }
                        else
                            local target_surface_name = icbm_data.target_surface and icbm_data.surface.valid and icbm_data.target_surface.name:lower() or icbm_data.target_surface_name
                            if (not Constants.space_exploration_dictionary[target_surface_name]) then Constants.get_space_exploration_universe(true) end
                            local target_space_location = Constants.space_exploration_dictionary[target_surface_name]

                            if (target_space_location) then
                                local radius_max = target_space_location.radius

                                Log.warn("deviation_limit = " .. deviation_limit)
                                local previous_position = {
                                    x = icbm_data.target_position.x,
                                    y = icbm_data.target_position.y,
                                }

                                icbm_data.target_position = {
                                    x = icbm_data.target_position.x + math.random(-deviation_limit, deviation_limit),
                                    y = icbm_data.target_position.y + math.random(-deviation_limit, deviation_limit),
                                }

                                local delta_from_origin = ((icbm_data.target_position.x) ^ 2 + (icbm_data.target_position.y) ^ 2) ^ 0.5

                                -- if (delta_from_origin > radius_max) then
                                if (radius_max and delta_from_origin >= radius_max) then
                                    --[[ Taret position deviated outside of the planet's bounds]]
                                    icbm_data.target_position = previous_position
                                end
                            else
                               --[[ Couldn't find a valid taget space_location
                                    -> How?
                               ]]
                            --    log(target_surface_name)
                            --    log(serpent.block(icbm_data))
                            --    error("Could not find a valid target space_location for " .. target_surface_name)
                            end
                        end
                    end
                end
            end
        end

        local burnout_speed = 1.8125
        local starting_speed_bonus = icbm_data.starting_speed_bonus or 0

        local proportion = math.pi / 4

        if (icbm_data.launched_from == "interplanetary" and icbm_data.launched_from_space and (icbm_data.speed > 0 or starting_speed_bonus > 0)) then
            local platform = icbm_data.source_silo and icbm_data.source_silo.valid and icbm_data.source_silo.surface and icbm_data.source_silo.surface.valid and icbm_data.source_silo.surface.platform

            Log.debug("calculating starting speed bonus")
            if (not icbm_data.is_travelling) then
                Log.warn("not travelling at time of launch")
                starting_speed_bonus = (starting_speed_bonus + icbm_data.speed) * 32
            else
                Log.warn("travelling")
                --[[ Get the target orientation ]]
                if (not se_active and not Constants.planets_dictionary[icbm_data.target_surface_name]) then Constants.get_planets(true) end

                local target_planet = Constants.planets_dictionary[icbm_data.target_surface_name]
                if (platform and platform.valid and platform.space_connection and platform.space_connection.valid) then
                    from = platform.space_connection.from.name
                    to = platform.space_connection.to.name
                end

                --[[ Get the destination orientation ]]
                if (not se_active and not Constants.planets_dictionary[destination]) then Constants.get_planets(true) end
                local destination_planet = Constants.planets_dictionary[destination]
                --[[ Get the origin_planet orientation ]]
                local origin_planet = nil

                if (se_active) then
                    if (not Constants.space_exploration_dictionary[string.lower(icbm_data.surface.name)]) then Constants.get_space_exploration_universe(true) end
                    origin_planet = Constants.space_exploration_dictionary[string.lower(icbm_data.surface.name)]

                    Log.warn(origin_planet and origin_planet.name)
                    Log.debug(origin_planet)
                    if (not origin_planet) then
                        if (not Constants.mod_data_dictionary["se-" .. string.lower(icbm_data.surface.name)]) then Constants.get_mod_data(true) end
                        origin_planet = Constants.mod_data_dictionary["se-" .. string.lower(icbm_data.surface.name)]
                        Log.warn(origin_planet and origin_planet.name)
                        Log.debug(origin_planet)
                    end
                else
                    if (origin_space_location and origin_space_location.name) then
                        if (not Constants.planets_dictionary[origin_space_location.name]) then Constants.get_planets(true) end
                        origin_planet = Constants.planets_dictionary[origin_space_location.name]
                    else
                        --[[ This shouldn't be possible? ]]
                        Log.warn("no origin planet found while travelling")
                        Log.warn("defaulting to destination planet")
                        origin_planet = destination_planet
                    end
                end

                local from_planet, to_planet = nil, nil
                if (to and from) then
                    if (not Constants.planets_dictionary[from] or not Constants.planets_dictionary[to]) then Constants.get_planets(true) end
                    from_planet = Constants.planets_dictionary[from]
                    to_planet = Constants.planets_dictionary[to]
                end

                Log.debug(from_planet)
                Log.debug(to_planet)

                Log.debug(target_planet)
                Log.debug(destination_planet)
                Log.debug(origin_planet)

                local destination_is_origin = destination_planet == origin_planet
                local destination_is_from = platform and platform.valid and platform.space_connection and platform.space_connection.valid and destination_planet.name == platform.space_connection.from.name
                local destination_is_to = platform and platform.valid and platform.space_connection and platform.space_connection.valid and destination_planet.name == platform.space_connection.to.name

                Log.debug(destination_is_origin)
                Log.debug(destination_is_from)
                Log.debug(destination_is_to)

                Log.warn({ x = target_planet.x, y = target_planet.y })
                Log.warn(icbm_data.space_origin_pos)
                Log.warn({ x = destination_planet.x, y = destination_planet.y })
                Log.warn({ x = origin_planet.x, y = origin_planet.y })

                local x_diff = math.abs(target_planet.x - icbm_data.space_origin_pos.x)
                Log.warn(x_diff)
                local y_diff = math.abs(target_planet.y - icbm_data.space_origin_pos.y)
                Log.warn(y_diff)

                local d_pos_x, d_pos_y = nil, nil
                local d_neg_x, d_neg_y = nil, nil
                local d_ne, d_se = nil, nil
                local d_nw, d_sw = nil, nil
                local d_orientation = nil

                local t_pos_x, t_pos_y = nil, nil
                local t_neg_x, t_neg_y = nil, nil
                local t_ne, t_se = nil, nil
                local t_nw, t_sw = nil, nil
                local t_orientation = nil

                if (destination_planet.x > origin_planet.x) then
                    d_pos_x = true
                    d_orientation = 0.25
                    if (destination_planet.y > origin_planet.y) then
                        d_pos_y = true
                        d_ne = true
                        d_orientation = 0.25 / 2
                    elseif (destination_planet.y < origin_planet.y) then
                        d_neg_y = true
                        d_se = true
                        d_orientation = 0.25 + 0.25 / 2
                    end
                elseif (destination_planet.x < origin_planet.x) then
                    d_neg_x = true
                    d_orientation = 0.5
                    if (destination_planet.y > origin_planet.y) then
                        d_pos_y = true
                        d_nw = true
                        d_orientation = 0.75 + 0.25 / 2
                    elseif (destination_planet.y < origin_planet.y) then
                        d_neg_y = true
                        d_sw = true
                        d_orientation = 0.5 + 0.25 / 2
                    end
                end

                if (target_planet.x > icbm_data.space_origin_pos.x) then
                    t_pos_x = true
                    t_orientation = 0.25
                    if (target_planet.y > icbm_data.space_origin_pos.y) then
                        t_pos_y = true
                        t_ne = true
                        t_orientation = 0.25 / 2
                    elseif (target_planet.y < icbm_data.space_origin_pos.y) then
                        t_neg_y = true
                        t_se = true
                        t_orientation = 0.25 + 0.25 / 2
                    end
                elseif (target_planet.x < icbm_data.space_origin_pos.x) then
                    t_neg_x = true
                    t_orientation = 0.5
                    if (target_planet.y > icbm_data.space_origin_pos.y) then
                        t_pos_y = true
                        t_nw = true
                        t_orientation = 0.75 + 0.25 / 2
                    elseif (target_planet.y < icbm_data.space_origin_pos.y) then
                        t_neg_y = true
                        t_sw = true
                        t_orientation = 0.5 + 0.25 / 2
                    end
                end

                local uturn = false
                if (destination_is_origin) then
                    Log.warn("uturn = true")
                    uturn = true
                end

                Log.warn(d_pos_y)
                Log.warn(d_ne)
                Log.warn(d_pos_x)
                Log.warn(d_se)
                Log.warn(d_neg_y)
                Log.warn(d_sw)
                Log.warn(d_neg_x)
                Log.warn(d_nw)

                Log.warn(d_orientation)

                Log.warn(t_pos_y)
                Log.warn(t_ne)
                Log.warn(t_pos_x)
                Log.warn(t_se)
                Log.warn(t_neg_y)
                Log.warn(t_sw)
                Log.warn(t_neg_x)
                Log.warn(t_nw)

                local target_direction = {
                    x = 0,
                    y = 0,
                    cardinal = 0,
                    orientation = nil,
                    distance = 0,
                }
                local travelling_direction = {
                    x = 0,
                    y = 0,
                    cardinal = 0.5,
                    orientation = nil,
                    distance = 0,
                }

                if (from_planet and to_planet) then
                    travelling_direction.distance = ((from_planet.x - to_planet.x) ^ 2 + (from_planet.y - to_planet.y) ^ 2) ^ 0.5
                    local orientation = math.atan2(from_planet.y - to_planet.y, from_planet.x - to_planet.x) / math.pi
                    travelling_direction.orientation = orientation < 0 and orientation or 1 - orientation
                end

                local direction = {
                    target_direction = target_direction,
                    travelling_direction = travelling_direction,
                }

                travelling_direction.x = d_pos_x and 1 or d_neg_x and -1 or travelling_direction.x
                travelling_direction.y = d_pos_y and 1 or d_neg_y and -1 or travelling_direction.y
                travelling_direction.cardinal = d_orientation

                target_direction.x = t_pos_x and 1 or t_neg_x and -1 or target_direction.x
                target_direction.y = t_pos_y and 1 or t_neg_y and -1 or target_direction.y
                target_direction.cardinal = t_orientation

                local _t_orientation = math.atan2(target_planet.y - icbm_data.space_origin_pos.y, target_planet.x - icbm_data.space_origin_pos.x)
                local base_t_orientation = _t_orientation
                base_t_orientation = base_t_orientation / math.pi
                local base_t_orientation_was_negative = base_t_orientation < 0
                if (base_t_orientation_was_negative) then
                    if (target_direction.cardinal > 0.5) then
                        base_t_orientation = -base_t_orientation
                        base_t_orientation = base_t_orientation / 2
                    elseif (target_direction.cardinal < 0.5) then
                        base_t_orientation = -base_t_orientation
                        base_t_orientation = 1 - base_t_orientation
                        base_t_orientation = base_t_orientation / 2
                    end
                else
                    if (target_direction.cardinal > 0.5) then
                        base_t_orientation = 1 - base_t_orientation
                        base_t_orientation = 1 + base_t_orientation
                        base_t_orientation = base_t_orientation / 4
                    elseif (target_direction.cardinal < 0.5) then
                        base_t_orientation = 1 + base_t_orientation
                        base_t_orientation = base_t_orientation * (math.pi / 4)
                        base_t_orientation = base_t_orientation / 4
                    end
                end

                direction.target_planet_pos = {
                    x = target_planet.x,
                    y = target_planet.y,
                }
                direction.firing_pos = {
                    x = icbm_data.space_origin_pos.x,
                    y = icbm_data.space_origin_pos.y,
                }

                target_direction.distance = ((target_planet.x - icbm_data.space_origin_pos.x) ^ 2 + (target_planet.y - icbm_data.space_origin_pos.y) ^ 2) ^ 0.5
                target_direction.orientation = base_t_orientation

                Log.warn(direction)

                if (destination_is_target or uturn) then
                    Log.debug("0")
                    proportion = 2
                elseif (target_direction.cardinal) then
                    Log.debug("1")
                    local orientation = target_direction.orientation
                    Log.debug(orientation)
                    if ((math.abs(target_direction.cardinal - travelling_direction.cardinal) ~= 0.5)) then
                        Log.debug("1.1")
                        if (target_direction.cardinal > 0.5) then
                            Log.debug("2")
                            if (orientation <= 0.25) then
                                Log.debug("3")
                                proportion = 2 - orientation * 4
                            else
                                Log.debug("3.1")
                                proportion = 2 * (1 - (orientation / 0.5))
                            end
                        elseif (target_direction.cardinal < 0.5) then
                            Log.debug("5")
                            if (orientation <= 0.25) then
                                Log.debug("6")
                                proportion = 2 - orientation * 4
                            else
                                Log.debug("7")
                                proportion = 2 * (1 - (orientation / 0.5))
                            end
                        end
                    else
                        Log.debug("9")
                        -- Directly behind
                        proportion = 0
                    end
                end
                Log.warn(proportion)

                starting_speed_bonus = (starting_speed_bonus * 32) + (icbm_data.speed / 60) * proportion
                starting_speed_bonus = proportion * starting_speed_bonus
            end
        end

        local starting_speed = 1 + burnout_speed * (top_speed_modifier) + starting_speed_bonus
        if (icbm_data.launched_from_space) then
            starting_speed = starting_speed * in_space_speed_modifier
        end
        if (destination_is_target) then
            starting_speed = starting_speed + (icbm_data.speed / 60) * 32
        end
        Log.warn("starting_speed == " .. starting_speed)
        local current_speed = starting_speed and starting_speed > 1 and starting_speed or 1

        --[[ TODO: Make top_speed configurable? ]]
        local top_speed = 4.8 * in_space_speed_modifier
        top_speed = top_speed * (24 / magnitude)
        if (icbm_data.speed * proportion > 0) then
            top_speed = (top_speed + starting_speed_bonus)
            local modifier = 0.75 * (((1 - (1.25) * (1 + top_speed_modifier) * (-1 * top_speed_modifier)) / (math.pi / 2)) * ((math.atan((icbm_data.speed / (math.exp(1) ^ 5))) / math.pi) + 1))
            top_speed = top_speed * modifier
        end

        local top_speed_base = 0.25
        if (from_ipbm_silo) then
            if (se_active) then
                top_speed = top_speed * 2.5 * ((1 - top_speed_base) * top_speed_modifier + top_speed_base)
            else
                -- top_speed = top_speed * 1.5 * ((1 - top_speed_base) * top_speed_modifier + top_speed_base)
                top_speed = top_speed * (math.pi / 2) * ((1 - top_speed_base) * top_speed_modifier + top_speed_base)
            end
        else
            top_speed = top_speed * ((1 - top_speed_base) * top_speed_modifier + top_speed_base)
        end

        local remaining_distance = target_distance
        local distance_divisor = (32 / magnitude)
        if (icbm_data.launched_from) then
            distance_divisor = icbm_data.launched_from == "orbit" and (32 / magnitude) * 0.625 or distance_divisor
            distance_divisor = icbm_data.launched_from == "surface" and (24 / magnitude ^ 1.5) or distance_divisor
            distance_divisor = icbm_data.launched_from == "interplanetary" and (16 / magnitude ^ 2.25) * 1.25 or distance_divisor
        end

        local num_speed_checks = math.ceil(target_distance / (distance_divisor))

        local check_threshold = math.log(num_speed_checks, math.exp(1))
        local original_starting_speed = starting_speed
        local times_starting_speed_updated = 0
        local times_starting_speed_updated_limit = not from_ipbm_silo and 1 + num_speed_checks * (3/4) or (1 + num_speed_checks) ^ 0.5
        local update_proportion_modifier = icbm_data.launched_from_space and 13/9 or 2/3
        local surface_to_orbit_complete = icbm_data.launched_from == "interplanetary" or icbm_data.launched_from == "orbit"

        local top_speed_modifier_max = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TOP_SPEED_MODIFIER.name })
        top_speed_modifier_max =
                top_speed_modifier_max * 10
            +   top_speed_modifier_max * 6
            +   top_speed_modifier_max * 14
            +   top_speed_modifier_max * 25
        top_speed_modifier_max = top_speed_modifier_max * 1.5
        Log.warn(top_speed_modifier)
        Log.warn(top_speed_modifier_max)

        Log.warn(num_speed_checks)
        Log.warn(top_speed)
        for i = 1, num_speed_checks, 1 do
            Log.debug(i)
            Log.debug(current_speed)
            Log.debug(time_to_target)
            Log.debug(remaining_distance)
            if (current_speed > top_speed) then current_speed = top_speed end

            time_to_target = time_to_target + 1
            remaining_distance = remaining_distance - current_speed

            local check_proportion = i / num_speed_checks
            if (icbm_data.launched_from == "interplanetary" and not icbm_data.launched_from_space and i > check_threshold and starting_speed < top_speed * 0.25 and times_starting_speed_updated < times_starting_speed_updated_limit) then
                local update_proportion = times_starting_speed_updated / times_starting_speed_updated_limit
                if (from_ipbm_silo) then
                    starting_speed = update_proportion_modifier * update_proportion * 10/3 + original_starting_speed + ((original_starting_speed + starting_speed) / 2) * ((check_proportion) ^ 0.5) * in_space_speed_modifier
                else
                    starting_speed = update_proportion_modifier * update_proportion * 4/3 + original_starting_speed + ((original_starting_speed + starting_speed) / 2) * ((check_proportion) ^ 0.5) * in_space_speed_modifier
                end
                times_starting_speed_updated = times_starting_speed_updated + 1
            end
            if (not surface_to_orbit_complete and times_starting_speed_updated >= times_starting_speed_updated_limit) then
                surface_to_orbit_complete = true
                starting_speed = starting_speed * in_space_speed_modifier
                update_proportion_modifier = 13/9
            end

            if (remaining_distance <= 0) then break end
            if (current_speed < top_speed) then
                local pre_update_speed = current_speed
                Log.debug(current_speed)
                current_speed = starting_speed + current_speed + (((starting_speed + (current_speed > starting_speed and (current_speed - starting_speed) or 0)) * (math.exp(1) ^ 4)) * (1 - 1 / math.exp(1) ^ ((i / 6) - 1 / 6))) ^ 0.25
                Log.debug(current_speed)
                current_speed = current_speed + (i * (1 - check_proportion))
                Log.debug(current_speed)
                local top_speed_proportion = 1 - (top_speed_modifier / top_speed_modifier_max)
                Log.debug(top_speed_proportion)
                current_speed = current_speed + current_speed / (1 + (2.71 ^ 2) * top_speed_proportion)
                Log.debug(current_speed)
                current_speed = original_starting_speed + pre_update_speed + current_speed
                Log.debug(current_speed)
                if (from_ipbm_silo) then
                    if (surface_to_orbit_complete or icbm_data.launched_from_space) then
                        if (icbm_data.launched_from == "orbit" or icbm_data.launched_from == "interplanetary") then
                            current_speed = current_speed / (13/12)
                        else
                            current_speed = current_speed / (7/6)
                        end
                    else
                        current_speed = current_speed / (9/6)
                    end
                else
                    if (surface_to_orbit_complete or icbm_data.launched_from_space) then
                        if (icbm_data.launched_from == "orbit" or icbm_data.launched_from == "interplanetary") then
                            current_speed = current_speed / (20/12)
                        else
                            current_speed = current_speed / 4
                        end
                    else
                        current_speed = current_speed / (13/6)
                    end
                end
            end
        end
    end

    Log.warn("calculated base seconds to target = " .. time_to_target)
    time_to_target = 1 + 60 * 5 + 60 * time_to_target * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_TRAVEL_MULTIPLIER.name })

    if (not icbm_data.same_surface) then
        time_to_target = time_to_target * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_MULTISURFACE_TRAVEL_TIME_MODIFIER.name })
    end

    if (not se_active and icbm_data.launched_from_space) then
        local launch_duration_ticks = 511 + math.random(-1, 1) * math.random(32)
        time_to_target = time_to_target + launch_duration_ticks
        icbm_utils.space_launches_initiated[icbm_data] = {
            -- launch_duration_ticks = launch_duration_ticks,
            tick = game.tick + launch_duration_ticks,
            time_to_target = time_to_target - launch_duration_ticks,
        }

        if (not storage.icbm_utils) then storage.icbm_utils = {} end
        storage.icbm_utils.space_launches_initiated = icbm_utils.space_launches_initiated
    else
        time_to_target = time_to_target + math.random(60 * (math.log(target_distance, 2.71) * (magnitude ^ 1.66))) * magnitude
    end

    Log.warn("game.tick = " .. game.tick)
    Log.warn("time_to_target = " .. time_to_target)

    icbm_data.tick_to_target = data.tick + time_to_target
    ICBM_Repository.update_icbm_data(icbm_data)

    Log.warn(serpent.block(icbm_data))

    icbm_utils.register_delivery_data({ icbm_data = icbm_data })

    if (se_active or not icbm_data.launched_from_space) then
        if (math.floor(time_to_target / 60) >= 1) then
            if (icbm_data.player_launched_index == 0) then
                if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_LAUNCH_MESSAGES.name })) then
                    icbm_data.force.print({ "icbm-utils.seconds-to-target", icbm_data.item_number, math.floor(time_to_target / 60) })
                end
            else
                if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_LAUNCH_MESSAGES.name })) then
                    icbm_data.force.print({ "icbm-utils.seconds-to-target", icbm_data.item_number, math.floor(time_to_target / 60) })
                end
            end
        end
    end

    icbm_data.cargo_pod = nil
    -- script.raise_event(
    --     Custom_Events.cn_on_rocket_launched_successfully.name,
    --     {
    --         name = defines.events[Custom_Events.cn_on_rocket_launched_successfully.name],
    --         tick = game.tick,
    --         icbm_data = icbm_data,
    --     }
    -- )
    return 1
end

function icbm_utils.register_delivery_data(data)
    Log.debug("icbm_utils.register_delivery_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    -- local tick = storage and storage.tick or 0
    local tick = game and game.tick or storage and storage.tick or math.huge
    Log.warn(tick)

    local icbm_data = data.icbm_data

    local source_name =    "icbm-utils.on_cargo_pod_finished_ascending.on_nth_tick.tick_to_target."
                    .. icbm_data.tick_to_target
                    .. ".item_number."
                    .. icbm_data.item_number

    local time_to_target_5_nth_tick = icbm_data.tick_to_target - 5 * 60
    local time_to_target_3_nth_tick = icbm_data.tick_to_target - 3 * 60
    local time_to_target_2_nth_tick = icbm_data.tick_to_target - 2 * 60
    local time_to_target_1_nth_tick = icbm_data.tick_to_target - 1 * 60

    local time_to_target_5_source_name =  "icbm-utils.on_cargo_pod_finished_ascending.on_nth_tick.tick_to_target."
                                        .. time_to_target_5_nth_tick
                                        .. ".item_number."
                                        .. icbm_data.item_number
    local time_to_target_3_source_name =  "icbm-utils.on_cargo_pod_finished_ascending.on_nth_tick.tick_to_target."
                                        .. time_to_target_3_nth_tick
                                        .. ".item_number."
                                        .. icbm_data.item_number
    local time_to_target_2_source_name =  "icbm-utils.on_cargo_pod_finished_ascending.on_nth_tick.tick_to_target."
                                        .. time_to_target_2_nth_tick
                                        .. ".item_number."
                                        .. icbm_data.item_number
    local time_to_target_1_source_name =  "icbm-utils.on_cargo_pod_finished_ascending.on_nth_tick.tick_to_target."
                                        .. time_to_target_1_nth_tick
                                        .. ".item_number."
                                        .. icbm_data.item_number

    if (tick <= time_to_target_5_nth_tick) then
        local event_handler_data = Event_Handler:register_event({
            event_name = "on_nth_tick",
            nth_tick = time_to_target_5_nth_tick,
            source_name = time_to_target_5_source_name,
            restore_on_load = true,
            func = icbm_utils.time_to_target_5_event,
            func_name = "icbm_utils.time_to_target_5_event",
            func_data =
            {
                nth_tick = time_to_target_5_nth_tick,
                source_name = time_to_target_5_source_name,
                icbm_data = icbm_data,
            },
            save_to_storage = true,
        })

        if (event_handler_data) then
            icbm_data.event_handlers[event_handler_data.source_name] = event_handler_data
        end
    end

    if (tick <= time_to_target_3_nth_tick) then
        local event_handler_data = Event_Handler:register_event({
            event_name = "on_nth_tick",
            nth_tick = time_to_target_3_nth_tick,
            source_name = time_to_target_3_source_name,
            restore_on_load = true,
            func = icbm_utils.time_to_target_3_event,
            func_name = "icbm_utils.time_to_target_3_event",
            func_data =
            {
                nth_tick = time_to_target_3_nth_tick,
                source_name = time_to_target_3_source_name,
                icbm_data = icbm_data,
            },
            save_to_storage = true,
        })

        if (event_handler_data) then
            icbm_data.event_handlers[event_handler_data.source_name] = event_handler_data
        end
    end

    if (tick <= time_to_target_2_nth_tick) then
        local event_handler_data = Event_Handler:register_event({
            event_name = "on_nth_tick",
            nth_tick = time_to_target_2_nth_tick,
            source_name = time_to_target_2_source_name,
            restore_on_load = true,
            func = icbm_utils.time_to_target_2_event,
            func_name = "icbm_utils.time_to_target_2_event",
            func_data =
            {
                nth_tick = time_to_target_2_nth_tick,
                source_name = time_to_target_2_source_name,
                icbm_data = icbm_data,
            },
            save_to_storage = true,
        })

        if (event_handler_data) then
            icbm_data.event_handlers[event_handler_data.source_name] = event_handler_data
        end
    end

    if (tick <= time_to_target_1_nth_tick) then
        local event_handler_data = Event_Handler:register_event({
            event_name = "on_nth_tick",
            nth_tick = time_to_target_1_nth_tick,
            source_name = time_to_target_1_source_name,
            restore_on_load = true,
            func = icbm_utils.time_to_target_1_event,
            func_name = "icbm_utils.time_to_target_1_event",
            func_data =
            {
                nth_tick = time_to_target_1_nth_tick,
                source_name = time_to_target_1_source_name,
                icbm_data = icbm_data,
            },
            save_to_storage = true,
        })

        if (event_handler_data) then
            icbm_data.event_handlers[event_handler_data.source_name] = event_handler_data
        end
    end

    if (tick <= icbm_data.tick_to_target) then
        local event_handler_data = Event_Handler:register_event({
            event_name = "on_nth_tick",
            nth_tick = icbm_data.tick_to_target,
            restore_on_load = true,
            source_name = source_name,
            func = icbm_utils.payload_arrive_event,
            func_name = "icbm_utils.payload_arrive_event",
            func_data =
            {
                nth_tick = icbm_data.tick_to_target,
                source_name = source_name,
                icbm_data = icbm_data,
            },
            save_to_storage = true,
        })

        if (event_handler_data) then
            icbm_data.event_handlers[event_handler_data.source_name] = event_handler_data
        end
    end
end

function icbm_utils.time_to_target_5_event(event, event_data)
    Log.debug("icbm_utils.time_to_target_5_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.icbm_data.scrubbed) then return end

    local print_message = function (param)
        if (param and param.force and param.force.valid) then
            param.force.print({ "configurable-nukes-controller.seconds-to-target-gps", event_data.icbm_data.item_number, 5, param.target_position.x, param.target_position.y, param.target_surface_name })
        end
    end

    if (event_data.icbm_data.player_launched_index == 0) then
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
            print_message(event_data.icbm_data)
        end
    else
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
            print_message(event_data.icbm_data)
        end
    end
end

function icbm_utils.time_to_target_3_event(event, event_data)
    Log.debug("icbm_utils.time_to_target_3_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.icbm_data.scrubbed) then return end

    if (not game or game.tick > event_data.nth_tick) then return end
    time_to_target_message({ icbm_data = event_data.icbm_data, seconds_to_target = 3 })
end

function icbm_utils.time_to_target_2_event(event, event_data)
    Log.debug("icbm_utils.time_to_target_2_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.icbm_data.scrubbed) then return end

    if (not game or game.tick > event_data.nth_tick) then return end
    time_to_target_message({ icbm_data = event_data.icbm_data, seconds_to_target = 2 })
end

function icbm_utils.time_to_target_1_event(event, event_data)
    Log.debug("icbm_utils.time_to_target_1_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.icbm_data.scrubbed) then return end

    if (not game or game.tick > event_data.nth_tick) then return end
    time_to_target_message({ icbm_data = event_data.icbm_data, seconds_to_target = 1 })
end

function icbm_utils.payload_arrive_event(event, event_data)
    Log.debug("icbm_utils.payload_arrive_event")
    Log.info(event)
    Log.info(event_data)

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = event_data.nth_tick,
        source_name = event_data.source_name,
    })

    if (event_data.icbm_data.scrubbed) then return end

    if (icbm_utils.payload_arrived({ icbm = event_data.icbm_data, surface = event_data.icbm_data.surface, target_surface = event_data.icbm_data.target_surface })) then
        -- Success
        log("payload arrived successfully")
    else
        log("payload failed to arrive successfully")
        error("payload failed to arrive successfully")
    end
end

function icbm_utils.launch_initiated(data)
    Log.debug("icbm_utils.launch_initiated")
    Log.info(data)

    if (data == nil) then return -1 end
    if (data.type == nil or type(data.type) ~= "string") then return -1 end
    if (data.surface == nil or not data.surface.valid) then return -1 end
    if (data.target_surface == nil or not data.target_surface.valid) then return -1 end
    if (data.item == nil or type(data.item) ~= "table") then return -1 end
    if (data.tick == nil or type(data.tick) ~= "number") then return -1 end
    if (data.area == nil or type(data.area) ~= "table") then return -1 end
    if (data.cargo_pod == nil or not data.cargo_pod.valid) then return -1 end
    if (data.source_silo == nil or not data.source_silo.valid) then return -1 end
    if (data.circuit_launch == nil or type(data.circuit_launch) ~= "boolean") then data.circuit_launch = false end
    if (data.player_index == nil or type(data.player_index) ~= "number" or data.player_index < 0) then return -1 end
    local player = data.player_index > 0 and game.get_player(data.player_index) or nil
    if (data.player_index == 0) then
        player = { name = "cicruit-launched", index = 0 }
        data.circuit_launch = true
    else
        if (player == nil or not player.valid or type(player) ~= "userdata") then return -1 end
    end
    if (not player and not data.circuit_launch) then return -1 end
    if (data.distance == nil or type(data.distance) ~= "number") then return -1 end
    if (data.launched_from == nil or type(data.launched_from) ~= "string") then return -1 end
    if (data.launched_from_space == nil or type(data.launched_from_space) ~= "boolean") then data.launched_from_space = false end
    if (data.base_target_distance == nil or type(data.base_target_distance) ~= "number") then data.base_target_distance = 0 end
    if (data.speed == nil or type(data.speed) ~= "number") then data.speed = 0 end
    if (data.is_travelling == nil or type(data.is_travelling) ~= "boolean") then data.is_travelling = false end
    if (data.space_origin_pos ~= nil and (type(data.space_origin_pos) ~= "table" or not data.space_origin_pos.x or type(data.space_origin_pos.x) ~= "number" or not data.space_origin_pos.y or type(data.space_origin_pos.y) ~= "number")) then return -1 end
    -- if (se_active and data.origin_system ~= nil and type(data.origin_system) ~= "table") then return -1 end
    -- if (se_active and data.target_system ~= nil and type(data.target_system) ~= "table") then return -1 end

    local target_position = {
        x = (data.area.left_top.x + data.area.right_bottom.x) / 2,
        y = (data.area.left_top.y + data.area.right_bottom.y) / 2,
    }

    local same_surface = data.surface == data.target_surface
    local target_distance = data.distance

    if (same_surface) then
        Log.warn("from silo, target_distance = " .. target_distance)
    else
        Log.warn("from origin, target_distance = " .. target_distance)
    end

    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    local icbm_data = ICBM_Data:new({
        se_active = se_active,
        type = data.type,
        surface = data.surface,
        surface_name = data.surface.name,
        same_surface = same_surface,
        item_number = ICBM_Data:next_item_number(),
        item = data.item,
        tick_launched = data.tick,
        tick_to_target = -1,
        source_silo = data.source_silo,
        silo_type = data.source_silo and data.source_silo.valid and data.source_silo.name,
        -- origin_system = data.origin_system,
        original_target_position = target_position,
        target_position = target_position,
        target_distance = target_distance,
        target_surface = data.target_surface,
        target_surface_name = data.target_surface.name,
        -- target_system = data.target_system,
        cargo_pod = data.cargo_pod,
        force = data.cargo_pod.force,
        force_index = data.cargo_pod.force.index,
        circuit_launch = data.circuit_launch,
        player_launched_by = player,
        player_launched_index = player.index,
        launched_from = data.launched_from,
        launched_from_space = data.launched_from_space,
        base_target_distance = data.base_target_distance,
        valid = data.cargo_pod.valid,
        speed = data.speed,
        is_travelling = data.is_travelling,
        space_origin_pos = data.space_origin_pos,
    })

    Log.warn(icbm_data)

    if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME.name })) then
        if (not se_active) then
            if (not Constants.planets_dictionary[icbm_data.surface_name:lower()]) then Constants.get_planets(true) end
            local planet = Constants.planets_dictionary[icbm_data.surface_name:lower()]
            if (not same_surface) then
                if (not Constants.planets_dictionary[icbm_data.target_surface_name:lower()]) then Constants.get_planets(true) end
                planet = Constants.planets_dictionary[icbm_data.target_surface_name:lower()]
            end
            local planet_magnitude = planet and planet.mangitude or 1
            icbm_data.target_distance = icbm_data.target_distance * planet_magnitude * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER.name })
        else
            if (not Constants.space_exploration_dictionary[icbm_data.surface_name:lower()]) then Constants.get_space_exploration_universe(true) end
            local space_location = Constants.space_exploration_dictionary[icbm_data.surface_name:lower()]
            if (not same_surface) then
                if (not Constants.space_exploration_dictionary[icbm_data.target_surface_name:lower()]) then Constants.get_space_exploration_universe(true) end
                space_location = Constants.space_exploration_dictionary[icbm_data.target_surface_name:lower()]
            end
            local space_location_magnitude = space_location and space_location.mangitude or 1
            icbm_data.target_distance = icbm_data.target_distance * space_location_magnitude * Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER.name })
        end
    end

    Log.warn(icbm_data)

    icbm_data = ICBM_Repository.save_icbm_data(icbm_data)
    if (not icbm_data or not icbm_data.valid) then return -1 end

    if (icbm_data.force_index < 0 and icbm_data.force_index > 63) then return -1 end

    local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(icbm_data.force_index)
    local enqueued_data = force_launch_data.launch_action_queue:enqueue({
        data =
        {
            tick = game.tick,
            icbm_data = icbm_data,
        }
    })
    icbm_data.enqueued_data = enqueued_data

    Log.warn(icbm_data)

    icbm_data = ICBM_Repository.update_icbm_data(icbm_data)
    if (not icbm_data or not icbm_data.valid) then return -1 end

    Log.warn(enqueued_data)

    if (game.forces[icbm_data.force_index] and game.forces[icbm_data.force_index].valid) then
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET.name })) then
            game.forces[data.cargo_pod.force.index].chart(
                data.target_surface,
                {
                    --[[ TODO: Make configurable ]]
                    { x = target_position.x - 32, y = target_position.y - 32 },
                    { x = target_position.x + 32, y = target_position.y + 32 }
                }
            )
        end
    end

    if (icbm_data.player_launched_index == 0) then
        --[[ Circuit launched ]]
        local force = game.forces[icbm_data.force_index]
        if (not force or not force.valid) then return end

        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_LAUNCH_MESSAGES.name })) then
            force.print({ "icbm-utils.launch-initiated", icbm_data.item_number, icbm_data.target_position.x, icbm_data.target_position.y, icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, data.target_surface.name, icbm_data.source_silo.surface.name, })
        end
        --[[ TODO: Make this setting per player ]]
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PIN_TARGETS.name })) then
            for k, v in pairs(force.connected_players) do
                local target_type = "ICBM"

                if (icbm_data.silo_type == "ipbm-rocket-silo") then
                    target_type = "IPBM"
                    if (se_active and icbm_data.source_system and icbm_data.target_system and icbm_data.source_system ~= icbm_data.target_system ) then
                        target_type = "ISBM"
                    end
                end

                v.add_pin({ label = target_type .. " target-" .. icbm_data.item_number, surface = data.target_surface, position = target_position, preview_distance = 2 ^ 6 })
            end
        end
    else
        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_LAUNCH_MESSAGES.name })) then
            game.get_player(icbm_data.player_launched_index).print({ "icbm-utils.launch-initiated", icbm_data.item_number, icbm_data.target_position.x, icbm_data.target_position.y, icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, data.target_surface.name, icbm_data.source_silo.surface.name })
        end

        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PIN_TARGETS.name })) then
            local target_type = "ICBM"

            if (icbm_data.silo_type == "ipbm-rocket-silo") then
                target_type = "IPBM"
                if (se_active and icbm_data.source_system and icbm_data.target_system and icbm_data.source_system ~= icbm_data.target_system ) then
                    target_type = "ISBM"
                end
            end

            game.get_player(icbm_data.player_launched_index).add_pin({ label = target_type .. " target-" .. icbm_data.item_number, surface = data.target_surface, position = target_position, preview_distance = 2 ^ 6 })
        end
    end

    -- -- icbm_data.cargo_pod = nil
    script.raise_event(
        Custom_Events.cn_on_rocket_launch_initiated_successfully.name,
        {
            name = defines.events[Custom_Events.cn_on_rocket_launch_initiated_successfully.name],
            tick = game.tick,
            icbm_data = icbm_data,
        }
    )
    return 1
end

function icbm_utils.payload_arrived(data)
    Log.debug("icbm_utils.payload_arrived")
    Log.info(data)

    if (data == nil or type(data) ~= "table") then return -1 end
    if (data.icbm == nil or type(data.icbm) ~= "table") then return -1 end
    if (data.surface == nil or type(data.surface) ~= "userdata" or not data.surface.valid) then return -1 end
    if (data.target_surface == nil or type(data.target_surface) ~= "userdata" or not data.target_surface.valid) then return -1 end

    local icbm = data.icbm

    if (icbm and icbm.valid) then
        if (game.forces[icbm.force_index] and game.forces[icbm.force_index].valid) then
            local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(icbm.force_index)
            if (force_launch_data.valid) then
                force_launch_data.launch_action_queue:remove({ data = icbm.enqueued_data })
            end
        end

        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET.name })) then
            if (game.forces[icbm.force_index] and game.forces[icbm.force_index].valid) then
                game.forces[icbm.force.index].chart(
                    data.target_surface,
                    {
                        --[[ TODO: Make configurable ]]
                        { x = icbm.target_position.x - 32, y = icbm.target_position.y - 32 },
                        { x = icbm.target_position.x + 32, y = icbm.target_position.y + 32 },
                    }
                )
            end
        end

        local payload_spawn_position = { x = icbm.target_position.x, y = icbm.target_position.y, }

        --[[ TODO: Make configurable? ]]
        payload_spawn_position.y = payload_spawn_position.y - 2 ^ 7 + 2 ^ 5

        Log.warn(icbm)

        icbm.target_surface.create_entity({
            name = icbm.type .. "-" .. icbm.item.quality,
            position = payload_spawn_position,
            direction = defines.direction.south,
            force = icbm.source_silo.valid and icbm.source_silo.force or "player",
            target = icbm.target_position,
            source = icbm.source_position,
            --[[ TODO: Make configurable ]]
            -- cause = icbm.same_surface and icbm.source_silo or "player",
            cause = icbm.same_surface and icbm.source_silo and icbm.source_silo.valid and icbm.source_silo or "player",
            speed = 0.1 * math.exp(1),
            base_damage_modifiers = {
                damage_modifier = icbm.type == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name }) or icbm.type == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_MODIFIER.name }) or 1,
                damage_addition = icbm.type == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name }) or icbm.type == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_ADDITION.name }) or 1,
                radius_modifier = 1,
            },
            bonus_damage_modifiers = {
                damage_modifier = icbm.type == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name }) or icbm.type == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_MODIFIER.name }) or 1,
                damage_addition = icbm.type == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name }) or icbm.type == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_ADDITION.name }) or 1,
                radius_modifier = icbm.type == 1,
            },
        })

        script.raise_event(
            Custom_Events.cn_on_payload_delivered.name,
            {
                name = defines.events[Custom_Events.cn_on_payload_delivered.name],
                tick = game.tick,
                icbm_data = icbm,
            }
        )
    else
        -- log(serpent.block(icbm))
        -- log(serpent.block(storage))
        -- error("launch failed")
    end

    local deleted_1 = ICBM_Repository.delete_icbm_data_by_item_number(data.surface.name, icbm.item_number)
    local deleted_2 = ICBM_Repository.delete_icbm_data_by_item_number(icbm.target_surface_name, icbm.item_number)
    local deleted_3 = ICBM_Repository.delete_icbm_data_by_item_number(icbm.surface_name, icbm.item_number)
    return deleted_1 or deleted_2 or deleted_3, deleted_1, deleted_2, deleted_3
end

function icbm_utils.print_space_launched_time_to_target_message(data)
    Log.debug("icbm_utils.print_space_launched_time_to_target_message")
    Log.info(data)

    if (storage.icbm_utils and storage.icbm_utils.space_launches_initiated) then
        for k, v in pairs(storage.icbm_utils.space_launches_initiated) do
            if (game.tick >= v.tick) then
                if (math.floor(v.time_to_target / 60) >= 1) then
                    if (k.player_launched_index == 0) then
                        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_LAUNCH_MESSAGES.name })) then
                            k.force.print({ "icbm-utils.seconds-to-target", k.item_number, math.floor(v.time_to_target / 60) })
                        end
                    else
                        if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_LAUNCH_MESSAGES.name })) then
                            k.force.print({ "icbm-utils.seconds-to-target", k.item_number, math.floor(v.time_to_target / 60) })
                        end
                    end

                    if (icbm_utils.space_launches_initiated and icbm_utils.space_launches_initiated[k]) then icbm_utils.space_launches_initiated[k] = nil end
                    storage.icbm_utils.space_launches_initiated[k] = nil
                end
            end
        end
    end
end

function icbm_utils.get_space_launches_initiatied(data)
    Log.debug("icbm_utils.get_space_launches_initiatied")
    Log.info(data)

    if (not storage.icbm_utils) then storage.icbm_utils = {} end
    if (not storage.icbm_utils.space_launches_initiated) then storage.icbm_utils.space_launches_initiated = {} end

    return storage.icbm_utils.space_launches_initiated
end

function icbm_utils.rocket_silo_cloned(data)
    Log.debug("icbm_utils.rocket_silo_cloned")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.source_silo or not data.source_silo.valid) then return end
    if (not data.source_silo.surface or not data.source_silo.surface.valid) then return end
    if (not data.destination_silo or not data.destination_silo.valid) then return end
    if (not data.destination_silo.surface or not data.destination_silo.surface.valid) then return end

    local source_icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(data.source_silo.surface.name)
    local icbms = {}

    for k, v in pairs(source_icbm_meta_data.icbms) do
        if (v.source_silo == data.source_silo) then
            v.surface = data.destination_silo.surface
            v.surface_name = data.destination_silo.surface.name
            v.source_silo = data.destination_silo
            icbms[k] = v
            source_icbm_meta_data.icbms[k] = nil
            source_icbm_meta_data.item_numbers[k] = nil
        end
    end

    local destination_icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(data.destination_silo.surface.name)

    Log.warn(serpent.block(icbms))
    Log.debug(destination_icbm_meta_data)

    for k, v in pairs(icbms) do
        destination_icbm_meta_data.icbms[k] = v
        destination_icbm_meta_data.item_numbers[k] = v
    end
end

icbm_utils.configurable_nukes = true

local _icbm_utils = icbm_utils

return icbm_utils