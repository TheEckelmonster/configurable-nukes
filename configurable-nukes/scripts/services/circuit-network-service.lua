local storage
local circuit_connected_rkt_silos
local icbm_datas
local recently_launched_rkt_silos

local game

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.circuit_connected_rkt_silos = storage.circuit_connected_rkt_silos or {}
    circuit_connected_rkt_silos = storage.circuit_connected_rkt_silos

    storage.icbm_data = storage.icbm_data or {}
    icbm_datas = storage.icbm_data

    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos
    recently_launched_rkt_silos = storage.recently_launched_rkt_silos

    game = __game or _ENV.game

    return game
end

local type = type
local next = next

local string = string
local string_find = string.find
local string_lower = string.lower

local CN_NONE = "cn-none"
local CN_PREFIX = "configurable-nukes-"
local NUMBER = "number"
local ORBIT_SUFFIX = " orbit"
local PLATFROM_PREFIX = "platform-"
local STRING = "string"
local TABLE = "table"

local Settings_Service = Settings_Service
local get_runtime_global_setting = Settings_Service.get_runtime_global_setting

local ICBM_Data = require("scripts.data.ICBM-data")
local validate_fields = ICBM_Data.validate_fields
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local get_icbm_data = ICBM_Repository.get_icbm_data
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local add_rocket_data_for_force = Rocket_Dashboard_Gui_Service.add_rocket_data_for_force
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local get_rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data
local save_rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local allow_targeting_origin = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name })
local allow_launch_when_no_surface_selected = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name })
local allow_icbm_multisurface = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })

local circuit_network_service = {}
circuit_network_service.name = "circuit_network_service"
circuit_network_service.set_game = set_game

local script = script

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local defines = defines
local rocket_ready_status = defines.rocket_silo_status.rocket_ready
local wire_connector_id = defines.wire_connector_id
local wire_connector_id_circuit_green = wire_connector_id.circuit_green
local wire_connector_id_circuit_red = wire_connector_id.circuit_red

function circuit_network_service.attempt_launch_silos(rocket_silos, tick)
    -- Log.debug("circuit_network_service.attempt_launch_silos")
    -- Log.info(data)
    if (type(rocket_silos) ~= TABLE or not next(rocket_silos)) then return end

    tick = tick or (game or set_game()).tick

    local return_val = 0

    circuit_connected_rkt_silos = circuit_connected_rkt_silos or set_game() and circuit_connected_rkt_silos

    local k, v = next(rocket_silos)
    while (v and v.entity and v.entity.valid) do
        local rocket_silo = v.entity

        if (rocket_silo and rocket_silo.valid and rocket_silo.rocket_silo_status == rocket_ready_status) then
            local get_circuit_network = rocket_silo.get_circuit_network
            local circuit_network_red = get_circuit_network(wire_connector_id_circuit_red)
            local circuit_network_green = get_circuit_network(wire_connector_id_circuit_green)

            if (not circuit_network_red and not circuit_network_green) then goto continue end
            if (   (circuit_network_red and circuit_network_red.valid and circuit_network_red.entity and circuit_network_red.entity.valid)
                or (circuit_network_green and circuit_network_green.valid and circuit_network_green.entity and circuit_network_green.entity.valid))
            then

                local rocket_silo_data = v
                if (not rocket_silo_data or not rocket_silo_data.valid) then
                    rocket_silo_data = get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
                    if (not rocket_silo_data or not rocket_silo_data.valid) then
                        rocket_silo_data = save_rocket_silo_data(rocket_silo)
                        rocket_silo_data = rocket_silo_data and rocket_silo_data.valid and rocket_silo_data or nil
                        if (not rocket_silo_data or not rocket_silo_data.valid) then
                            if (rocket_silo_data and rocket_silo_data.unit_number) then
                                circuit_connected_rkt_silos[rocket_silo_data.unit_number] = nil
                            end
                            goto continue
                        end
                    end
                end

                circuit_connected_rkt_silos[rocket_silo_data.unit_number] = circuit_connected_rkt_silos[rocket_silo_data.unit_number] or rocket_silo_data

                local is_orbit_surface = false
                if (se_active and rocket_silo_data.surface and rocket_silo_data.surface.valid) then
                    is_orbit_surface = string_find(string_lower(rocket_silo_data.surface.name), ORBIT_SUFFIX, 1, true) ~= nil
                end

                local is_ipbm_silo = rocket_silo_data:is_ipbm_silo()

                local space_location_gui_available =   allow_icbm_multisurface
                                                    or is_ipbm_silo

                local orbit_to_surface_gui_available =      not space_location_gui_available
                                                        and not is_ipbm_silo
                                                        and se_active
                                                        and is_orbit_surface

                --[[ Get previously selected signals, if they exist ]]

                local red_signal_x = 0
                local red_signal_y = 0
                local red_signal_space_location_index = 0
                local red_signal_launch = 0
                local red_signal_origin_override = 0

                -- Check for signals from the red circuit-network if it exists
                if (circuit_network_red and circuit_network_red.valid) then
                    local get_signal = circuit_network_red.get_signal
                    local signals = rocket_silo_data.circuit_network_data.signals
                    red_signal_x = signals.x ~= nil and get_signal(signals.x) or 0
                    red_signal_y = signals.y ~= nil and get_signal(signals.y) or 0
                    red_signal_space_location_index = signals.space_location_index ~= nil and get_signal(signals.space_location_index) or 0
                    red_signal_launch = signals.launch ~= nil and get_signal(signals.launch) or 0
                    red_signal_origin_override = signals.origin_override ~= nil and get_signal(signals.origin_override) or 0
                end

                local green_signal_x = 0
                local green_signal_y = 0
                local green_signal_space_location_index = 0
                local green_signal_launch = 0
                local green_signal_origin_override = 0

                -- Check for signals from the green circuit-network if it exists
                if (circuit_network_green and circuit_network_green.valid) then
                    local get_signal = circuit_network_green.get_signal
                    local signals = rocket_silo_data.circuit_network_data.signals
                    green_signal_x = signals.x and get_signal(signals.x) or 0
                    green_signal_y = signals.y and get_signal(signals.y) or 0
                    green_signal_space_location_index = signals.space_location_index and get_signal(signals.space_location_index) or 0
                    green_signal_launch = signals.launch and get_signal(signals.launch) or 0
                    green_signal_origin_override = signals.origin_override ~= nil and get_signal(signals.origin_override) or 0
                end

                --[[ Aggregate the signals from the red and/or green circuit-networks
                    -> Currently just adding the red and green signal values together for each signal
                ]]
                local signal_x = red_signal_x + green_signal_x
                local signal_y = red_signal_y + green_signal_y
                local signal_space_location_index = red_signal_space_location_index + green_signal_space_location_index
                local signal_launch = red_signal_launch + green_signal_launch

                --[[ Intentionally letting it be nil in the case of either the settings being disabled ]]
                local signal_origin_override =  allow_targeting_origin
                                            and (red_signal_origin_override + green_signal_origin_override)
                                            or nil
                local require_space_location = rocket_silo_data.circuit_network_data.require_space_location

                if (signal_x and signal_y and signal_launch) then
                    if (type(signal_x) == NUMBER and type(signal_y) == NUMBER and type(signal_launch) == NUMBER) then
                        if (        (signal_launch > 0
                                and (  signal_x ~= 0
                                    or signal_y ~= 0))
                            or
                                (signal_launch > 0
                                and allow_targeting_origin
                                and type(signal_origin_override) == NUMBER
                                and signal_origin_override > 0))
                        then
                            local entity_red = circuit_network_red and circuit_network_red.valid and circuit_network_red.entity or nil
                            local entity_green = circuit_network_green and circuit_network_green.valid and circuit_network_green.entity or nil
                            local entity = nil
                            if (entity_red ~= nil and entity_green ~= nil) then
                                if (entity_red == entity_green) then
                                    entity = entity_red
                                end
                            else
                                if (entity_red) then
                                    entity = entity_red
                                elseif (entity_green) then
                                    entity = entity_green
                                end
                            end

                            local target_surface_name = rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_name
                            if (not space_location_gui_available and orbit_to_surface_gui_available) then
                                target_surface_name = rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name
                            end
                            local target_index = rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_index

                            if (target_surface_name == nil --[[ No surface has been selected yet ]]) then
                                target_surface_name = CN_NONE
                                target_index = -1
                            end
                            if (target_index == nil) then
                                target_index = -1
                            end

                            local target_surface = nil
                            local orbit_to_surface = nil

                            --[[ Check is a space-location-index is being provided via circuit-network signal ]]
                            if ((space_location_gui_available or orbit_to_surface_gui_available) and signal_space_location_index ~= nil and type(signal_space_location_index) == NUMBER and signal_space_location_index >= 1) then
                                --[[ Try and get the surface based on the provided space location signal index ]]
                                target_surface = game.get_surface(signal_space_location_index)
                                if (target_surface and target_surface.valid) then
                                    if (orbit_to_surface_gui_available) then
                                        if (target_surface and target_surface.valid) then
                                            if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                            if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                                Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                                goto continue
                                            end

                                            local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                            if (space_location and space_location.parent and target_surface == space_location.parent.surface) then
                                                orbit_to_surface = true
                                            else
                                                target_surface = nil
                                            end
                                        end
                                    elseif (space_location_gui_available) then
                                        --[[ Verify that the target surface is among known potential surfaces
                                            -> Namely trying to avoid targetting a surface that isn't actually supposed to be targetable
                                            -> First example: aai-signals surface
                                        ]]
                                        if (not Constants.mod_data_dictionary) then Constants.get_mod_data(true) end

                                        if (se_active) then
                                            if (not Constants.mod_data_dictionary["se-" .. target_surface.name:lower()]) then
                                                target_surface = nil
                                            end
                                        else
                                            if (not Constants.mod_data_dictionary[target_surface.name:lower()]) then
                                                target_surface = nil
                                            end
                                        end
                                    end
                                else
                                    target_surface = nil
                                end
                            end

                            --[[ Check if firing from an orbit surface ]]
                            local from_platform = string_find(rocket_silo.surface.name, PLATFROM_PREFIX, 1, true) ~= nil and sa_active
                            local from_se_orbit = string_find(string_lower(rocket_silo.surface.name), ORBIT_SUFFIX, 1, true) ~= nil and se_active

                            if (target_surface == nil) then
                                --[[ Can the player even select a space-location to target? ]]
                                if (space_location_gui_available or orbit_to_surface_gui_available) then
                                    if (target_surface_name == CN_NONE) then
                                        --[[ and if self-surface targeting allowed when no target explicitly selected ]]
                                        if (allow_launch_when_no_surface_selected) then
                                            --[[ and if explicit space_location not required for this rocket-silo]]
                                            if (not require_space_location) then
                                                if (from_platform) then
                                                    if (rocket_silo.surface.platform) then
                                                        local space_location = rocket_silo.surface.platform.space_location

                                                        if (space_location and space_location.valid and space_location.name ~= nil) then
                                                            target_surface = game.get_surface(space_location.name)
                                                            orbit_to_surface = true
                                                        end
                                                    end
                                                elseif (from_se_orbit) then
                                                    if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                                    if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                                        Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                                        goto continue
                                                    end

                                                    local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                                    if (space_location and space_location.parent and space_location.parent.surface_index and space_location.parent.surface_index > 0) then
                                                        target_surface = game.get_surface(space_location.parent.surface_index)
                                                        orbit_to_surface = true
                                                    end
                                                else
                                                    target_surface = game.get_surface(rocket_silo.surface.name)
                                                end
                                            end
                                        end
                                    else--[[ A surface is/was previously selected ]]
                                        target_surface = game.get_surface(target_surface_name)
                                    end
                                else
                                    --[[ Standard rocket-silo, can fire at:
                                        -> Same surface
                                        -> From orbit
                                    ]]

                                    --[[ Check if the origin surface is an "orbit" surface (Space-Exploration)
                                        or is in "orbit" around a planet for Space-Age
                                    ]]
                                    if (from_platform) then
                                        if (rocket_silo.surface.platform) then
                                            local space_location = rocket_silo.surface.platform.space_location

                                            if (space_location and space_location.valid and space_location.name ~= nil) then
                                                target_surface = game.get_surface(space_location.name)
                                                orbit_to_surface = true
                                            end
                                        end
                                    elseif (from_se_orbit) then
                                        if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                        if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                            Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                            goto continue
                                        end

                                        local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                        if (space_location.surface_index and space_location.surface_index > 0) then
                                            target_surface = game.get_surface(space_location.surface_index)
                                            orbit_to_surface = true
                                        end
                                    else
                                        target_surface = game.get_surface(rocket_silo.surface.name)
                                    end
                                end
                            end

                            --[[ Ensure the surface exists, and is a valid target surface ]]
                            if (target_surface and target_surface.valid and Rocket_Silo_Validations.is_targetable_surface({ surface = target_surface })) then
                                local return_val, return_data = Rocket_Silo_Service.launch_rocket({
                                    circuit_launched = true,
                                    circuit_launched_space_location_name = rocket_silo.surface.name,
                                    rocket_silo_data = rocket_silo_data,
                                    rocket_silo = rocket_silo,
                                    tick = tick,
                                    surface = target_surface,
                                    area = { left_top = { x = signal_x, y = signal_y }, right_bottom = { x = signal_x, y = signal_y }, },
                                    --[[
                                        Pretty sure valid player indices start at 1, so 0 should be safe for indicating a circuit launch?
                                            -> The above is partially correct: 0 is not used for player indices, but is also not a valid index to game.players
                                    ]]
                                    player_index = 0,
                                    last_user_index = entity and entity.valid and entity.last_user and entity.last_user.index,
                                    orbit_to_surface = orbit_to_surface,
                                })

                                if (type(return_val) == NUMBER and return_val == 1) then
                                    if (type(return_data) == TABLE and return_data.valid) then
                                        icbm_datas = icbm_datas or set_game() and icbm_datas
                                        icbm_datas.item_numbers = icbm_datas.item_numbers or {}
                                        local icbm_data = icbm_datas.item_numbers[return_data.item_number]
                                        if (icbm_data) then
                                            validate_fields(icbm_data)
                                        elseif (not icbm_data) then
                                            icbm_data = get_icbm_data(return_data.surface_name, return_data.item_number, { validate_fields = true })
                                        end
                                        if (not icbm_data or not icbm_data.valid) then return end

                                        add_rocket_data_for_force({
                                            icbm_data = icbm_data,
                                        })

                                        recently_launched_rkt_silos = recently_launched_rkt_silos or set_game() and recently_launched_rkt_silos
                                        recently_launched_rkt_silos[rocket_silo_data.unit_number] = tick

                                        return_val = return_val + 1
                                    end
                                end
                            end
                        end
                    end
                end
            else
                if (v.unit_number and circuit_connected_rkt_silos[v.unit_number]) then
                    circuit_connected_rkt_silos[v.unit_number] = nil
                end
            end
        end
        ::continue::

        k, v = next(rocket_silos, k)
    end

    return return_val
end

function circuit_network_service.on_runtime_mod_setting_changed(event)
    Log.debug("circuit_network_service.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= STRING) then return end
    if (not event.setting_type or type(event.setting_type) ~= STRING) then return end

    if (not (event.setting:find(CN_PREFIX, 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name) then
        allow_targeting_origin = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name) then
        allow_launch_when_no_surface_selected = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name) then
        allow_icbm_multisurface = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "circuit_network_service.on_runtime_mod_setting_changed",
    func_name = "circuit_network_service.on_runtime_mod_setting_changed",
    func = circuit_network_service.on_runtime_mod_setting_changed,
})

function circuit_network_service.init(__storage) storage = __storage or _ENV.storage end

return circuit_network_service