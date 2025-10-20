local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local planet_data = {}

planet_data.type = "planet-data"

planet_data.planet_gravity_well = nil

function planet_data:new(o)
    Log.debug("planet_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
        planet_gravity_well = self.planet_gravity_well,
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

function planet_data:is_solid(data)
    Log.debug("planet_data:is_solid")
    Log.info(data)

    return true
end

function planet_data:restore_metatable(data)
    Log.debug("planet_data:restore_metatable")
    Log.info(data)

    -- setmetatable(self, planet_data)
    self.__index = self
    -- setmetatable(planet_data, Space_Location_Data)
end

setmetatable(planet_data, Space_Location_Data)
planet_data.__index = planet_data
return planet_data
-- local Planet_Data = planet_data:new(Planet_Data)
-- Planet_Data.mt = planet_data

-- return Planet_Data