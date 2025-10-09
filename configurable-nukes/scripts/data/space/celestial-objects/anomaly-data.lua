local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local anomaly_data = {}

anomaly_data.type = "anomaly"

function anomaly_data:new(o)
    Log.debug("anomaly_data:new")
    Log.info(o)

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
    Log.debug("anomaly_data:is_solid")
    Log.info(data)

    return false
end

setmetatable(anomaly_data, Space_Location_Data)
local Anomaly_Data = anomaly_data:new(Anomaly_Data)
Anomaly_Data.mt = anomaly_data

return Anomaly_Data