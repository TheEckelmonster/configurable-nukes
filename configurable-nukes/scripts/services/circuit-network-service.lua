local storage

local script = script

local next = next
local type = type

local Data_Utils = Data_Utils
local Log = Log
local Settings_Service = Settings_Service

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local required_signals = {
    ["x"] = 1,
    ["y"] = 1,
    ["launch"] = 1,
}

local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local circuit_network_service = {}
circuit_network_service.name = "circuit_network_service"

circuit_network_service.allow_targeting_origin = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name, }) or false
circuit_network_service.allow_launch_when_no_surface_selected = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name, }) or true
circuit_network_service.allow_icbm_multisurface = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name, }) or false

function circuit_network_service.attempt_launch_silos(params)
    -- Log.debug("circuit_network_service.attempt_launch_silos")
    -- Log.info(params)
    if (not params or type(params) ~= "table") then return end
    if (not params.rocket_silos or not params.rocket_silos[1]) then return end

    local return_val = 0

    local param = nil
    local circuit_network_data = nil
    for i = 1, #params.rocket_silos, 1 do
        param = params.rocket_silos[i]
        circuit_network_data = param and param.circuit_network_data or nil
        if (not circuit_network_data) then goto continue end

        local stored_signals = {
            [(circuit_network_data.signals["launch"] or {}).name or ""]               = "launch",
            [(circuit_network_data.signals["x"] or {}).name or ""]                    = "x",
            [(circuit_network_data.signals["y"] or {}).name or ""]                    = "y",
            [(circuit_network_data.signals["origin_override"] or {}).name or ""]      = "origin_override",
            [(circuit_network_data.signals["space_location_index"] or {}).name or ""] = "space_location_index",
        }
        stored_signals[""] = nil
        local found_signals = nil
        local found_count = 0
        local required_count = 0
        if (next(stored_signals)) then
            for _, signal_and_count in ipairs(param.signals or {}) do
                if (signal_and_count.signal.name and stored_signals[signal_and_count.signal.name]) then
                    found_signals = found_signals or {}
                    found_signals[stored_signals[signal_and_count.signal.name]] = signal_and_count.count
                    found_count = found_count + 1
                    if (required_signals[stored_signals[signal_and_count.signal.name]]) then required_count = required_count + 1 end
                    if (found_count >= 5) then break end
                end
            end
        else
            goto continue
        end
        if (required_count < 2 or not found_signals or not found_signals["launch"]) then goto continue end

        local signal_x = found_signals["x"] or 0
        local signal_y = found_signals["y"] or 0
        local signal_space_location_index = found_signals["space_location_index"] or 0
        local signal_launch = found_signals["launch"]

        --[[ Intentionally letting it be nil in the case of either the settings being disabled ]]
        local signal_origin_override =  circuit_network_service.allow_targeting_origin
                                    and found_signals["origin_override"]
                                    or
                                        0

        local require_space_location = circuit_network_data.require_space_location

        local is_ipbm_silo = circuit_network_data:is_ipbm_silo()

        local space_location_gui_available =   circuit_network_service.allow_icbm_multisurface
                                            or is_ipbm_silo

        local orbit_to_surface_gui_available =      not space_location_gui_available
                                                and not is_ipbm_silo
                                                and se_active
                                                and circuit_network_data.surface_name:lower():find(" orbit", 1, true)

        if (signal_x and signal_y and signal_launch) then
            if (type(signal_x) == "number" and type(signal_y) == "number" and type(signal_launch) == "number") then
                if ((       signal_launch > 0
                        and (
                                signal_x ~= 0
                            or
                                signal_y ~= 0
                        )
                    )
                    or
                    (
                            signal_launch > 0
                        and circuit_network_service.allow_targeting_origin
                        and signal_origin_override
                        and signal_origin_override > 0
                    )
                ) then
                    local entity = circuit_network_data.entity
                    if (not entity or not entity.valid) then goto continue end

                    local target_surface_name = circuit_network_data.space_location_gui_selection.space_location_name
                    if (not space_location_gui_available and orbit_to_surface_gui_available) then
                        target_surface_name = circuit_network_data.orbit_to_surface_gui_selection.space_location_name
                    end
                    local target_index = circuit_network_data.space_location_gui_selection.space_location_index

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
                                    if (not Constants.space_exploration_dictionary[entity.surface.name:lower()]) then
                                        Log.error("Could not find parent surface for: " .. entity.surface.name)
                                        goto continue
                                    end

                                    local space_location = Constants.space_exploration_dictionary[entity.surface.name:lower()]
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
                    local from_platform = entity.surface.name:find("platform-", 1, true) ~= nil and sa_active
                    local from_se_orbit = entity.surface.name:lower():find(" orbit", 1, true) ~= nil and se_active

                    if (target_surface == nil) then
                        --[[ Can the player even select a space-location to target? ]]
                        if (space_location_gui_available or orbit_to_surface_gui_available) then
                            if (target_surface_name == "cn-none") then
                                --[[ and if self-surface targeting allowed when no target explicitly selected ]]
                                if (circuit_network_service.allow_launch_when_no_surface_selected) then
                                    --[[ and if explicit space_location not required for this rocket-silo]]
                                    if (not require_space_location) then
                                        if (from_platform) then
                                            if (entity.surface.platform) then
                                                local space_location = entity.surface.platform.space_location

                                                if (space_location and space_location.valid and space_location.name ~= nil) then
                                                    target_surface = game.get_surface(space_location.name)
                                                    orbit_to_surface = true
                                                end
                                            end
                                        elseif (from_se_orbit) then
                                            if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                            if (not Constants.space_exploration_dictionary[entity.surface.name:lower()]) then
                                                Log.error("Could not find parent surface for: " .. entity.surface.name)
                                                goto continue
                                            end

                                            local space_location = Constants.space_exploration_dictionary[entity.surface.name:lower()]
                                            if (space_location and space_location.parent and space_location.parent.surface_index and space_location.parent.surface_index > 0) then
                                                target_surface = game.get_surface(space_location.parent.surface_index)
                                                orbit_to_surface = true
                                            end
                                        else
                                            target_surface = game.get_surface(entity.surface.name)
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
                                if (entity.surface.platform) then
                                    local space_location = entity.surface.platform.space_location

                                    if (space_location and space_location.valid and space_location.name ~= nil) then
                                        target_surface = game.get_surface(space_location.name)
                                        orbit_to_surface = true
                                    end
                                end
                            elseif (from_se_orbit) then
                                if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                if (not Constants.space_exploration_dictionary[entity.surface.name:lower()]) then
                                    Log.error("Could not find parent surface for: " .. entity.surface.name)
                                    goto continue
                                end

                                local space_location = Constants.space_exploration_dictionary[entity.surface.name:lower()]
                                if (space_location.surface_index and space_location.surface_index > 0) then
                                    target_surface = game.get_surface(space_location.surface_index)
                                    orbit_to_surface = true
                                end
                            else
                                target_surface = game.get_surface(entity.surface.name)
                            end
                        end
                    end

                    --[[ Ensure the surface exists, and is a valid target surface ]]
                    if (target_surface and target_surface.valid and Rocket_Silo_Validations.is_targetable_surface({ surface = target_surface })) then
                        storage.rocket_silos = storage.rocket_silos or {}
                        local rocket_silo_data = storage.rocket_silos[circuit_network_data.unit_number]
                        if (not rocket_silo_data or not rocket_silo_data.valid) then goto continue end

                        local return_val, return_data = Rocket_Silo_Service.launch_rocket({
                            circuit_launched = true,
                            circuit_launched_space_location_name = circuit_network_data.surface_name,
                            rocket_silo_data = rocket_silo_data,
                            rocket_silo = entity,
                            tick = params.tick,
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

                        if (type(return_val) == "number" and return_val == 1) then
                            if (type(return_data) == "table" and return_data[1] and return_data[#return_data].valid) then
                                storage.icbm_data = storage.icbm_data or {}
                                storage.icbm_data.item_numbers = storage.icbm_data.item_numbers or {}
                                local icbm_data
                                for _, v in ipairs(return_data) do
                                    icbm_data = storage.icbm_data.item_numbers[v.item_number]
                                    if (icbm_data) then
                                        ICBM_Data.validate_fields(icbm_data)
                                    elseif (not icbm_data) then
                                        icbm_data = ICBM_Repository.get_icbm_data(v.surface_name, v.item_number, { validate_fields = true })
                                    end
                                    if (not icbm_data or not icbm_data.valid) then goto next_return_data end

                                    Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
                                        icbm_data = icbm_data,
                                    })

                                    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
                                    storage.recently_launched_rkt_silos[circuit_network_data.unit_number] = params.tick

                                    return_val = return_val + 1

                                    ::next_return_data::
                                end
                            end
                        end
                    end
                end
            end
        end

        ::continue::
    end

    return return_val
end

function circuit_network_service.on_runtime_mod_setting_changed(event)
    -- Log.debug("circuit_network_service.on_runtime_mod_setting_changed")
    -- Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name) then
        circuit_network_service.allow_targeting_origin = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name) then
        circuit_network_service.allow_launch_when_no_surface_selected = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name, reindex = true })
    elseif (event.setting == Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name) then
        circuit_network_service.allow_icbm_multisurface = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "circuit_network_service.on_runtime_mod_setting_changed",
    func_name = "circuit_network_service.on_runtime_mod_setting_changed",
    func = circuit_network_service.on_runtime_mod_setting_changed,
})

function circuit_network_service.init(__storage)
    storage = __storage
end

return circuit_network_service