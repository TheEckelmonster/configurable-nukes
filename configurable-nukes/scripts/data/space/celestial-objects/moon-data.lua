local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Space_Location_Data = require("scripts.data.space.space-location-data")

local moon_data = {}

moon_data.type = "moon-data"

function moon_data:new(o)
    _Log.debug("moon_data:new")
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

function moon_data:is_solid(data)
    _Log.debug("moon_data:is_solid")
    _Log.info(data)

    return true
end

setmetatable(moon_data, Space_Location_Data)
moon_data.__index = moon_data
return moon_data