local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local asteroid_belt_data = {}

asteroid_belt_data.type = "asteroid-belt-data"

function asteroid_belt_data:new(o)
    Log.debug("asteroid_belt_data:new")
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

function asteroid_belt_data:is_solid(data)
    Log.debug("asteroid_belt_data:is_solid")
    Log.info(data)

    return false
end

setmetatable(asteroid_belt_data, Space_Location_Data)
asteroid_belt_data.__index = asteroid_belt_data
return asteroid_belt_data
-- local Asteroid_Belt_Data = asteroid_belt_data:new(Asteroid_Belt_Data)
-- -- Asteroid_Belt_Data.mt = asteroid_belt_data

-- return Asteroid_Belt_Data