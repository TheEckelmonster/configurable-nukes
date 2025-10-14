-- If already defined, return
if _circuit_network_service and _circuit_network_service.configurable_nukes then
  return _circuit_network_service
end

local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Service = require("scripts.services.settings-service")

local circuit_network_service = {}

function circuit_network_service.attempt_launch_silos(data)
    Log.debug("circuit_network_service.attempt_launch_silos")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end

    local sa_active = storage and storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage and storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    local rocket_silos = data.rocket_silos

    local allow_targeting_origin = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name })
    local allow_launch_when_no_surface_selected = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name })
    local allow_icbm_multisurface = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })

    for k, v in pairs(rocket_silos) do
        if (v and v.entity and v.entity.valid) then
            local rocket_silo = v.entity

            if (rocket_silo.rocket_silo_status == defines.rocket_silo_status.rocket_ready) then
                local circuit_network_red = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_red)
                local circuit_network_green = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_green)
                if (not circuit_network_red and not circuit_network_green) then goto continue end
                if (   (circuit_network_red and circuit_network_red.valid and circuit_network_red.entity and circuit_network_red.entity.valid)
                    or (circuit_network_green and circuit_network_green.valid and circuit_network_green.entity and circuit_network_green.entity.valid))
                then
                    -- Check if the rocket silo has signals different from default
                    local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
                    if (not rocket_silo_data or not rocket_silo_data.valid) then
                        rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                        if (not rocket_silo_data or not rocket_silo_data.valid) then goto continue end
                    end

                    local is_orbit_surface = false
                    if (rocket_silo_data.surface and rocket_silo_data.surface.valid) then
                        is_orbit_surface = rocket_silo_data.surface.name:lower():find(" orbit", 1, true) ~= nil
                    end

                    local space_location_gui_available =   allow_icbm_multisurface
                                                        or rocket_silo_data:is_ipbm_silo()

                    local orbit_to_surface_gui_available =      not space_location_gui_available
                                                            and not rocket_silo_data:is_ipbm_silo()
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
                        red_signal_x = rocket_silo_data.circuit_network_data.signals.x ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.x) or 0
                        red_signal_y = rocket_silo_data.circuit_network_data.signals.y ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.y) or 0
                        red_signal_space_location_index = rocket_silo_data.circuit_network_data.signals.space_location_index ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.space_location_index) or 0
                        red_signal_launch = rocket_silo_data.circuit_network_data.signals.launch ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.launch) or 0
                        red_signal_origin_override = rocket_silo_data.circuit_network_data.signals.origin_override ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.origin_override) or 0
                    end

                    local green_signal_x = 0
                    local green_signal_y = 0
                    local green_signal_space_location_index = 0
                    local green_signal_launch = 0
                    local green_signal_origin_override = 0

                    -- Check for signals from the green circuit-network if it exists
                    if (circuit_network_green and circuit_network_green.valid) then
                        green_signal_x = rocket_silo_data.circuit_network_data.signals.x and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.x) or 0
                        green_signal_y = rocket_silo_data.circuit_network_data.signals.y and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.y) or 0
                        green_signal_space_location_index = rocket_silo_data.circuit_network_data.signals.space_location_index and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.space_location_index) or 0
                        green_signal_launch = rocket_silo_data.circuit_network_data.signals.launch and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.launch) or 0
                        green_signal_origin_override = rocket_silo_data.circuit_network_data.signals.origin_override ~= nil and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.origin_override) or 0
                    end

                    --[[ Aggregate the signals from the red and/or green circuit-netowks
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
                        if (type(signal_x) == "number" and type(signal_y) == "number" and type(signal_launch) == "number") then
                            if (        (signal_launch > 0
                                    and (  signal_x ~= 0
                                        or signal_y ~= 0))
                                or
                                    (signal_launch > 0
                                    and allow_targeting_origin
                                    and type(signal_origin_override) == "number"
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
                                    target_surface_name = "cn-none"
                                    target_index = -1
                                end
                                if (target_index == nil) then
                                    target_index = -1
                                end

                                local target_surface = nil
                                local orbit_to_surface = nil

                                --[[ Check is a space-location-index is being provided via circuit-network signal ]]
                                if ((space_location_gui_available or orbit_to_surface_gui_available) and signal_space_location_index ~= nil and type(signal_space_location_index) == "number" and signal_space_location_index >= 1) then
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
                                                -> Nameley trying to avoid targetting a surface that isn't actually supposed to be targetable
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
                                local from_platform = rocket_silo.surface.name:find("platform-", 1, true) ~= nil and sa_active
                                local from_se_orbit = rocket_silo.surface.name:lower():find(" orbit", 1, true) ~= nil and se_active

                                if (target_surface == nil) then
                                    --[[ Can the player even select a space-location to target? ]]
                                    if (space_location_gui_available or orbit_to_surface_gui_available) then
                                        if (target_surface_name == "cn-none") then
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
                                    Rocket_Silo_Service.launch_rocket({
                                        circuit_launched = true,
                                        circuit_launched_space_location_name = rocket_silo.surface.name,
                                        rocket_silo_data = rocket_silo_data,
                                        rocket_silo = rocket_silo,
                                        tick = game.tick,
                                        surface = target_surface,
                                        area = { left_top = { x = signal_x, y = signal_y }, right_bottom = { x = signal_x, y = signal_y }, },
                                        --[[ Pretty sure valid player indices start at 1, so 0 should be safe for indicating a circuit launch? ]]
                                        player_index = 0,
                                        last_user_index = entity and entity.valid and entity.last_user and entity.last_user.index,
                                        orbit_to_surface = orbit_to_surface,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
        ::continue::
    end
end

circuit_network_service.configurable_nukes = true

local _circuit_network_service = circuit_network_service

return circuit_network_service