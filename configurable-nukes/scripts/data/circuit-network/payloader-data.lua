local Log = Log

local Data = require("scripts.data.data")

local circuit_network_payloader_data = {}

circuit_network_payloader_data.type = "circuit-network.payloader-data"

circuit_network_payloader_data.unit_number = -1
circuit_network_payloader_data.entity = nil
circuit_network_payloader_data.surface = nil
circuit_network_payloader_data.surface_index = -1
circuit_network_payloader_data.surface_name = nil

circuit_network_payloader_data.signals = nil
function circuit_network_payloader_data:new_signals(data)
    return
    {
        launch = { type = "virtual", name = "signal-check" },
        x = { type = "virtual", name = "signal-X" },
        y = { type = "virtual", name = "signal-Y" },
        space_location_index = { type = "virtual", name = "signal-I" },
    }
end

function circuit_network_payloader_data:new(o)
    -- _Log.debug("circuit_network_payloader_data:new")
    -- _Log.info(o)

    local defaults = {
        type = self.type,
        unit_number = self.unit_number,
        entity = self.entity,
        surface = self.surface,
        surface_index = self.surface_index,
        surface_name = self.surface_name,
        signals = self:new_signals(),
    }

    local obj = o or defaults

    -- Base object
    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    -- Sub-objects
    for k, v in pairs(defaults.signals) do if (obj.signals[k] == nil and type(v) ~= "function") then obj.signals[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(circuit_network_payloader_data, Data)
circuit_network_payloader_data.__index = circuit_network_payloader_data

return circuit_network_payloader_data