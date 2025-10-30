local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Space_Location_Data = require("scripts.data.space.space-location-data")

local planet_data = {}

planet_data.type = "planet-data"

planet_data.planet_gravity_well = nil

function planet_data:new(o)
    _Log.debug("planet_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        planet_gravity_well = self.planet_gravity_well,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Space_Location_Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function planet_data:is_solid(data)
    _Log.debug("planet_data:is_solid")
    _Log.info(data)

    return true
end

setmetatable(planet_data, Space_Location_Data)
planet_data.__index = planet_data
return planet_data