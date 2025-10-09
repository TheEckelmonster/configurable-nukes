local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local spaceship_data = {}

spaceship_data.type = "spaceship"
spaceship_data.previous_space_location = nil
spaceship_data.previous_surface = nil
spaceship_data.previous_surface_index = -1
spaceship_data.previous_surface_name = nil

function spaceship_data:new(o)
    Log.debug("spaceship_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
        previous_space_location = self.previous_space_location,
        previous_surface = self.previous_surface,
        previous_surface_index = self.previous_surface_index,
        previous_surface_name = self.previous_surface_name,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Space_Location_Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function spaceship_data:is_solid(data)
    Log.debug("spaceship_data:is_solid")
    Log.info(data)

    return true
end

setmetatable(spaceship_data, Space_Location_Data)
local Spacehip_Data = spaceship_data:new(Spacehip_Data)
Spacehip_Data.mt = spaceship_data

return Spacehip_Data