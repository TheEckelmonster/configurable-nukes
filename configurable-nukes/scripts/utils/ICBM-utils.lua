-- If already defined, return
if _icbm_utils and _icbm_utils.configurable_nukes then
  return _icbm_utils
end

local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local get_pin_targets = function()
    local setting = Runtime_Global_Settings_Constants.settings.PIN_TARGETS.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.PIN_TARGETS.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.PIN_TARGETS.name].value
    end

    return setting
end
local get_do_ICBMs_reveal_target = function()
    local setting = Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.DO_ICBMS_REVEAL_TARGET.name].value
    end

    return setting
end
local get_print_flight_messages = function()
    local setting = Runtime_Global_Settings_Constants.settings.PRINT_FLIGHT_MESSAGES.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.PRINT_FLIGHT_MESSAGES.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.PRINT_FLIGHT_MESSAGES.name].value
    end

    return setting
end
local get_icbms_perfect_guidance = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_PERFECT_GUIDANCE.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PERFECT_GUIDANCE.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PERFECT_GUIDANCE.name].value
    end

    return setting
end
local get_icbms_planet_magnitude_affects_travel_time = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_AFFECTS_TRAVEL_TIME.name].value
    end

    return setting
end
local get_icbms_magnitude_modifier = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_PLANET_MAGNITUDE_MODIFIER.name].value
    end

    return setting
end
local get_icbms_travel_multiplier = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_TRAVEL_MULTIPLIER.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_TRAVEL_MULTIPLIER.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_TRAVEL_MULTIPLIER.name].value
    end

    return setting
end
local get_icbm_guidance_deviation_threshold = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_GUIDANCE_DEVIATION_THRESHOLD.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_GUIDANCE_DEVIATION_THRESHOLD.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_GUIDANCE_DEVIATION_THRESHOLD.name].value
    end

    return setting
end
local get_icbm_circuit_print_flight_messages = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_FLIGHT_MESSAGES.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_FLIGHT_MESSAGES.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_FLIGHT_MESSAGES.name].value
    end

    return setting
end
local get_icbm_circuit_pin_targets = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PIN_TARGETS.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PIN_TARGETS.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PIN_TARGETS.name].value
    end

    return setting
end

local icbm_utils = {}

function icbm_utils.cargo_pod_finished_ascending(data)
    Log.debug("icbm_utils.cargo_pod_finished_ascending")
    Log.info(data)

    if (data == nil) then return -1 end
    if (data.surface == nil or not data.surface.valid) then return -1 end
    if (data.item == nil or type(data.item) ~= "table") then return -1 end
    if (data.cargo_pod == nil or not data.cargo_pod.valid) then return -1 end
    if (data.tick == nil or type(data.tick) ~= "number") then return -1 end

    local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(data.surface.name)

    local k, icbm_data = next(icbm_meta_data.item_numbers, nil)
    while k or (not k and icbm_data) do
        if (icbm_data and icbm_data.created <= game.tick) then
            icbm_meta_data.item_numbers[icbm_data.item_number] = nil
            break
        end

        if (k) then k, icbm_data = next(icbm_meta_data.item_numbers, k) end
    end

    if (icbm_data == nil) then
        Log.error("no icbm_data found")
        return
    end

    local guidance_systems_modifier = icbm_data.force.get_ammo_damage_modifier("icbm-guidance") or 0

    local time_to_target = 0
    if (data.tick and guidance_systems_modifier ~= nil) then
        if (not get_icbms_perfect_guidance()) then
            for i = 1, math.floor(icbm_data.target_distance / (32 * 8)), 1 do
                local rand = math.random()
                local deviation_threshold = get_icbm_guidance_deviation_threshold()
                local threshold = -(1 - deviation_threshold) * guidance_systems_modifier + deviation_threshold

                Log.warn("rand = " .. rand)
                Log.warn("threshold = " .. threshold)
                if (rand > threshold) then
                    -- Target deviation
                    Log.warn("deviating from target: " .. i)
                    --[[ TODO: Make configurable? ]]
                    local deviation_limit = 32 * i ^ (math.pi / 6) - math.log((i + 1) ^ (i ^ 0.75), math.exp(1)) + math.exp(1) ^ (-math.exp(1)/ (i ^ 2))
                    icbm_data.target_position = {
                        x = icbm_data.target_position.x + math.random(-deviation_limit, deviation_limit),
                        y = icbm_data.target_position.y + math.random(-deviation_limit, deviation_limit),
                    }
                end
            end

            local num_speed_checks = math.ceil(icbm_data.target_distance / (32 * 1))
            local burnout_speed = 1.8125
            local starting_speed = 1 + burnout_speed * (-1 * guidance_systems_modifier)
            Log.warn("starting_speed == " .. starting_speed)
            local current_speed = starting_speed or 1
            local top_speed = 4.8 * 32
            local remaining_distance = icbm_data.target_distance
            for i = 1, num_speed_checks, 1 do
                if (current_speed > top_speed) then current_speed = top_speed end

                time_to_target = time_to_target + 1
                remaining_distance = remaining_distance - current_speed

                if (remaining_distance <= 0) then break end
                if (current_speed < top_speed) then current_speed = (starting_speed * (math.exp(1) ^ 4)) * (1 - 1 / math.exp(1) ^ ((i / 6) - 1 / 6))
                end
            end
        end
    end

    time_to_target = 60 * time_to_target * get_icbms_travel_multiplier()

    icbm_data.tick_to_target = data.tick + time_to_target
    ICBM_Repository.update_icbm_data(icbm_data)

    icbm_meta_data.in_transit[icbm_data] = {
        tick_to_target = icbm_data.tick_to_target,
        item_number = icbm_data.item_number,
    }

    if (math.floor(time_to_target / 60) >= 1) then
        if (icbm_data.player_launched_index == 0) then
            if (get_icbm_circuit_print_flight_messages()) then
                icbm_data.force.print({ "icbm-utils.seconds-to-target", math.floor(time_to_target / 60) })
            end
        else
            if (get_print_flight_messages()) then
                icbm_data.force.print({ "icbm-utils.seconds-to-target", math.floor(time_to_target / 60) })
            end
        end
    end
end

function icbm_utils.launch_initiated(data)
    Log.debug("icbm_utils.launch_initiated")
    Log.info(data)

    if (data == nil) then return -1 end
    if (data.type == nil or type(data.type) ~= "string") then return -1 end
    if (data.surface == nil or not data.surface.valid) then return -1 end
    if (data.item == nil or type(data.item) ~= "table") then return -1 end
    if (data.tick == nil or type(data.tick) ~= "number") then return -1 end
    if (data.area == nil or type(data.area) ~= "table") then return -1 end
    if (data.cargo_pod == nil or not data.cargo_pod.valid) then return -1 end
    if (data.rocket_silo == nil or not data.rocket_silo.valid) then return -1 end
    if (data.player_index == nil or type(data.player_index) ~= "number" or data.player_index < 0) then return -1 end
    local player = data.player_index > 0 and game.get_player(data.player_index) or nil
    if (data.player_index == 0) then
        player = { name = "cicruit-launched", index = 0 }
    else
        if (player == nil or not player.valid or type(player) ~= "userdata") then return -1 end
    end
    if (not player) then return -1 end

    local target_position = {
        x = (data.area.left_top.x + data.area.right_bottom.x) / 2,
        y = (data.area.left_top.y + data.area.right_bottom.y) / 2,
    }

    local target_distance = ((target_position.x - data.rocket_silo.position.x) ^ 2 + (target_position.y - data.rocket_silo.position.y) ^ 2) ^ 0.5
    Log.warn("target_distance = " .. target_distance)

    local icbm_data = ICBM_Data:new({
        type = data.type,
        surface = data.surface,
        surface_name = data.surface.name,
        item_number = ICBM_Data:next_item_number(),
        item = data.item,
        tick_launched = data.tick,
        tick_to_target = -1,
        source_silo = data.rocket_silo,
        original_target_position = target_position,
        target_position = target_position,
        target_distance = target_distance,
        cargo_pod = data.cargo_pod,
        force = data.cargo_pod.force,
        force_index = data.cargo_pod.force.index,
        player_launched_by = player,
        player_launched_index = player.index,
        valid = data.cargo_pod.valid,
    })

    if (get_icbms_planet_magnitude_affects_travel_time()) then
        local planet = Constants.planets_dictionary[icbm_data.surface_name]
        local planet_magnitude = planet and planet.mangitude or 1
        icbm_data.target_distance = icbm_data.target_distance * planet_magnitude * get_icbms_magnitude_modifier()
    end

    local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(data.surface.name)
    icbm_meta_data.item_numbers[icbm_data.item_number] = icbm_data

    icbm_data = ICBM_Repository.save_icbm_data(icbm_data)

    if (game.forces[icbm_data.force_index] and game.forces[icbm_data.force_index].valid) then
        if (get_do_ICBMs_reveal_target()) then
            game.forces[data.cargo_pod.force.index].chart(
                data.surface,
                {
                    --[[ TODO: Make configurable ]]
                    { x = target_position.x - 32, y = target_position.y - 32 },
                    { x = target_position.x + 32, y = target_position.y + 32 }
                }
            )
        end
    end

    --[[ TODO: Make configurable ]]
    if (icbm_data.player_launched_index == 0) then
        --[[ Circuit launched ]]
        local force = game.forces[icbm_data.force_index]
        if (not force or not force.valid) then return end

        if (get_icbm_circuit_print_flight_messages()) then
            force.print({ "icbm-utils.launch-initiated", icbm_data.target_position.x, icbm_data.target_position.y, icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, icbm_data.source_silo.surface.name })
        end
        for k, v in pairs(force.connected_players) do
            if (get_icbm_circuit_pin_targets()) then
                v.add_pin({ label = "ICBM target-" .. icbm_data.item_number, surface = data.surface, position = target_position, preview_distance = 2 ^ 6 })
            end
        end
    else --[[ TODO: Make configurable ]]
        if (get_print_flight_messages()) then
            game.get_player(icbm_data.player_launched_index).print({ "icbm-utils.launch-initiated", icbm_data.target_position.x, icbm_data.target_position.y, icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, icbm_data.source_silo.surface.name })
        end

        if (get_pin_targets()) then
            game.get_player(icbm_data.player_launched_index).add_pin({ label = "ICBM target-" .. icbm_data.item_number, surface = data.surface, position = target_position, preview_distance = 2 ^ 6 })
        end
    end
end

function icbm_utils.payload_arrived(data)
    Log.debug("icbm_utils.payload_arrived")
    Log.info(data)

    if (data == nil or type(data) ~= "table") then return -1 end
    if (data.icbm == nil or type(data.icbm) ~= "table") then return -1 end
    if (data.surface == nil or type(data.surface) ~= "userdata" or not data.surface.valid) then return -1 end

    local icbm = data.icbm

    if (icbm and icbm.valid) then
        if (get_do_ICBMs_reveal_target()) then
            if (game.forces[icbm.force_index] and game.forces[icbm.force_index].valid) then
                game.forces[icbm.force.index].chart(
                    data.surface,
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

        icbm.surface.create_entity({
            name = icbm.type .. "-" .. icbm.item.quality,
            position = payload_spawn_position,
            direction = defines.direction.south,
            force = icbm.source_silo.valid and icbm.source_silo.force or "player",
            target = icbm.target_position,
            source = icbm.source_position,
            --[[ TODO: Make configurable ]]
            cause = icbm.source_silo,
            speed = 0.1 * math.exp(1),
            base_damage_modifiers = nil,
            bonus_damage_modifiers = nil
        })
    else
        -- log(serpent.block(icbm))
        -- log(serpent.block(storage))
        -- error("launch failed")
    end

    return ICBM_Repository.delete_icbm_data_by_item_number(data.surface.name, icbm.item_number)
end

icbm_utils.configurable_nukes = true

local _icbm_utils = icbm_utils

return icbm_utils