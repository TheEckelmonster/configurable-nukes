local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Circuit_Network_Rocket_Silo_Data = require("scripts.data.circuit-network.rocket-silo-data")
local Data = require("scripts.data.data")

local rocket_silo_data = {}

rocket_silo_data.type = "rocket-silo-data"

rocket_silo_data.unit_number = -1
rocket_silo_data.entity = nil
rocket_silo_data.surface = nil
rocket_silo_data.surface_name = nil
rocket_silo_data.surface_index = -1

rocket_silo_data.circuit_network_data = nil

function rocket_silo_data:new(o)
    _Log.debug("rocket_silo_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        unit_number = self.unit_number,
        entity = self.entity,
        circuit_network_data = Circuit_Network_Rocket_Silo_Data:new(),
        surface = self.surface,
        surface_name = self.surface_name,
        surface_index = self.surface_index,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    if (obj.entity and obj.entity.valid) then
        if (obj and not obj.surface) then obj.surface = obj.entity.surface end
        if (obj and not obj.surface_name) then obj.surface_name = obj.entity.surface.name end
        if (obj and not obj.surface_index or obj.surface_index < 1) then obj.surface_index = obj.entity.surface.index end
    end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function rocket_silo_data:is_ipbm_silo(data)
    -- _Log.debug("rocket_silo_data:is_ipbm_silo")
    -- _Log.info(self)
    -- _Log.info(data)

    return self.entity and self.entity.valid and self.entity.name == "ipbm-rocket-silo"
end

setmetatable(rocket_silo_data, Data)
rocket_silo_data.__index = rocket_silo_data
return rocket_silo_data