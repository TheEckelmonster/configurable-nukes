local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local moon_data = {}

moon_data.type = "moon"

function moon_data:new(o)
    Log.debug("moon_data:new")
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

function moon_data:is_solid(data)
    Log.debug("moon_data:is_solid")
    Log.info(data)

    return true
end

setmetatable(moon_data, Space_Location_Data)
local Moon_Data = moon_data:new(Moon_Data)
Moon_Data.mt = moon_data

return Moon_Data