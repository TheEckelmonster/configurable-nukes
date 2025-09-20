local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local planet_data = Data:new()

planet_data.name = nil
planet_data.surface = nil
planet_data.magnitude = 1

function planet_data:new(o)
    Log.debug("planet_data:new")
    Log.info(o)

    local defaults = {
        name = self.name,
        surface = self.surface,
        magnitude = self.magnitude,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(planet_data, Data)
local Planet_Data = planet_data:new(Planet_Data)

return Planet_Data