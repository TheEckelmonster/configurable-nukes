local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Space_Location_Data = require("scripts.data.space.space-location-data")

local anomaly_data = {}

anomaly_data.type = "anomaly-data"

function anomaly_data:new(o)
    _Log.debug("anomaly_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Space_Location_Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function anomaly_data:is_solid(data)
    _Log.debug("anomaly_data:is_solid")
    _Log.info(data)

    return false
end

setmetatable(anomaly_data, Space_Location_Data)
anomaly_data.__index = anomaly_data
return anomaly_data