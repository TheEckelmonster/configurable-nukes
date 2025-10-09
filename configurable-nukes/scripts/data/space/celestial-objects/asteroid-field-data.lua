local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local asteroid_field_data = {}

asteroid_field_data.type = "asteroid-field"

function asteroid_field_data:new(o)
    Log.debug("asteroid_field_data:new")
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

function asteroid_field_data:is_solid(data)
    Log.debug("asteroid_field_data:is_solid")
    Log.info(data)

    return false
end

setmetatable(asteroid_field_data, Space_Location_Data)
local Asteroid_Field_Data = asteroid_field_data:new(Asteroid_Field_Data)
Asteroid_Field_Data.mt = asteroid_field_data

return Asteroid_Field_Data