local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local circuit_network_rocket_silo_data = {}

circuit_network_rocket_silo_data.type = "circuit-network.rocket-silo-data"

circuit_network_rocket_silo_data.unit_number = -1
circuit_network_rocket_silo_data.entity = nil
circuit_network_rocket_silo_data.surface = nil
circuit_network_rocket_silo_data.surface_name = nil
circuit_network_rocket_silo_data.require_space_location = false


circuit_network_rocket_silo_data.signals = nil
function circuit_network_rocket_silo_data:new_signals(data)
    return
    {
        launch = { type = "virtual", name = "signal-check" },
        x = { type = "virtual", name = "signal-X" },
        y = { type = "virtual", name = "signal-Y" },
        space_location_index = { type = "virtual", name = "signal-I" },
        origin_override = { type = "virtual", name = "signal-unlock" },
    }
end

circuit_network_rocket_silo_data.orbit_to_surface_gui_selection = nil
function circuit_network_rocket_silo_data:new_orbit_to_surface_gui_selection(data)
    return
    {
        type = "cn-launch-signal-gui.orbit-to-surface-list-item",
        space_location_index = -1,
        space_location_name = nil,
        orbit_to_surface_gui_id = 1,
    }
end

circuit_network_rocket_silo_data.space_location_gui_selection = nil
function circuit_network_rocket_silo_data:new_space_location_gui_selection(data)
    return
    {
        type = "cn-launch-signal-gui.list-item",
        space_location_index = -1,
        space_location_name = nil,
        space_location_gui_id = 1,
    }
end

function circuit_network_rocket_silo_data:new(o)
    _Log.debug("circuit_network_rocket_silo_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        unit_number = self.unit_number,
        entity = self.entity,
        surface = self.surface,
        surface_name = self.surface_name,
        require_space_location = self.require_space_location,
        signals = self:new_signals(),
        orbit_to_surface_gui_selection = self:new_orbit_to_surface_gui_selection(),
        space_location_gui_selection = self:new_space_location_gui_selection(),
    }

    local obj = o or defaults

    -- Base object
    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    -- Sub-objects
    for k, v in pairs(defaults.signals) do if (obj.signals[k] == nil and type(v) ~= "function") then obj.signals[k] = v end end
    for k, v in pairs(defaults.orbit_to_surface_gui_selection) do if (obj.orbit_to_surface_gui_selection[k] == nil and type(v) ~= "function") then obj.orbit_to_surface_gui_selection[k] = v end end
    for k, v in pairs(defaults.space_location_gui_selection) do if (obj.space_location_gui_selection[k] == nil and type(v) ~= "function") then obj.space_location_gui_selection[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(circuit_network_rocket_silo_data, Data)
circuit_network_rocket_silo_data.__index = circuit_network_rocket_silo_data
return circuit_network_rocket_silo_data