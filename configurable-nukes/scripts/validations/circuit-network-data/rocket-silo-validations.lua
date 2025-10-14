-- If already defined, return
if _circuit_network_data_rocket_silo_validations and _circuit_network_data_rocket_silo_validations.configurable_nukes then
    return _circuit_network_data_rocket_silo_validations
end

local Circuit_Network_Data = require("scripts.data.circuit-network.rocket-silo-data")
local Log = require("libs.log.log")

local circuit_network_data_rocket_silo_validations = {}

function circuit_network_data_rocket_silo_validations.validate(data)
    Log.debug("circuit_network_data_rocket_silo_validations.validate")
    Log.info(data)

    local return_val = false

    if (not data or type(data) ~= "table") then return return_val end
    if (not data.circuit_network_data or type(data.circuit_network_data) ~= "table") then return return_val end

    return_val = true

    if (data.reinitialize) then
        if (not data.circuit_network_data.signals or type(data.circuit_network_data.signals) ~= "table") then return_val = false; data.circuit_network_data.signals = Circuit_Network_Data:new_signals() end

        if (not data.circuit_network_data.orbit_to_surface_gui_selection or type(data.circuit_network_data.orbit_to_surface_gui_selection) ~= "table") then return_val = false; data.circuit_network_data.orbit_to_surface_gui_selection = Circuit_Network_Data:new_orbit_to_surface_gui_selection() end
        if (data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name and type(data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name) ~= "string") then data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name = Circuit_Network_Data.orbit_to_surface_gui_selection.space_location_name end

        if (not data.circuit_network_data.space_location_gui_selection or type(data.circuit_network_data.space_location_gui_selection) ~= "table") then return_val = false; data.circuit_network_data.orbit_to_surface_gui_selection = Circuit_Network_Data:new_orbit_to_surface_gui_selection() end
        if (data.circuit_network_data.space_location_gui_selection.space_location_name and type(data.circuit_network_data.space_location_gui_selection.space_location_name) ~= "string") then return_val = false; data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name = Circuit_Network_Data.orbit_to_surface_gui_selection.space_location_name end

        if (data.circuit_network_data.require_space_location == nil or type(data.circuit_network_data.require_space_location) ~= "boolean") then return_val = false; data.circuit_network_data.require_space_location = Circuit_Network_Data.require_space_location end

        if (not return_val) then data.circuit_network_data.updated = game.tick end
    end

    if (return_val) then
        if (return_val and (not data.circuit_network_data.signals or type(data.circuit_network_data.signals) ~= "table")) then return_val = false end

        if (return_val and (not data.circuit_network_data.orbit_to_surface_gui_selection or type(data.circuit_network_data.orbit_to_surface_gui_selection) ~= "table")) then return_val = false end
        if (return_val and (data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name and type(data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name) ~= "string")) then return_val = false end

        if (return_val and (not data.circuit_network_data.space_location_gui_selection or type(data.circuit_network_data.space_location_gui_selection) ~= "table")) then return_val = false end
        if (return_val and (data.circuit_network_data.space_location_gui_selection.space_location_name and type(data.circuit_network_data.space_location_gui_selection.space_location_name) ~= "string")) then return_val = false end

        if (return_val and (data.circuit_network_data.require_space_location == nil or type(data.circuit_network_data.require_space_location) ~= "boolean")) then return_val = false end
    end

    return return_val
end

circuit_network_data_rocket_silo_validations.configurable_nukes = true

local _circuit_network_data_rocket_silo_validations = circuit_network_data_rocket_silo_validations

return circuit_network_data_rocket_silo_validations