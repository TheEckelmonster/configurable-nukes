local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Space_Location_Data = require("scripts.data.space.space-location-data")

local asteroid_belt_data = {}

asteroid_belt_data.type = "asteroid-belt-data"

function asteroid_belt_data:new(o)
    _Log.debug("asteroid_belt_data:new")
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

function asteroid_belt_data:is_solid(data)
    _Log.debug("asteroid_belt_data:is_solid")
    _Log.info(data)

    return false
end

setmetatable(asteroid_belt_data, Space_Location_Data)
asteroid_belt_data.__index = asteroid_belt_data
return asteroid_belt_data