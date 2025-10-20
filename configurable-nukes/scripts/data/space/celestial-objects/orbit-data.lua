local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local orbit_data = {}

orbit_data.type = "orbit-data"

function orbit_data:new(o)
    Log.debug("orbit_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Space_Location_Data:new(obj)

    -- log(serpent.block(getmetatable(obj)))

    setmetatable(obj, self)
    self.__index = self

    -- log(serpent.block(getmetatable(obj)))

    return obj
end

function orbit_data:is_solid(data)
    Log.debug("orbit_data:is_solid")
    Log.info(data)

    return false
end

setmetatable(orbit_data, Space_Location_Data)
orbit_data.__index = orbit_data
return orbit_data
-- local Orbit_Data = orbit_data:new(Orbit_Data)
-- Orbit_Data.mt = orbit_data

-- return Orbit_Data