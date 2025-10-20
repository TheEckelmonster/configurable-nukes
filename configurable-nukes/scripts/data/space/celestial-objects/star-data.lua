local Space_Location_Data = require("scripts.data.space.space-location-data")
local Log = require("libs.log.log")

local star_data = {}

star_data.type = "star-data"

star_data.star_gravity_well = nil

function star_data:new(o)
    Log.debug("star_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
        star_gravity_well = self.star_gravity_well,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Space_Location_Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function star_data:is_solid(data)
    Log.debug("star_data:is_solid")
    Log.info(data)

    return false
end

setmetatable(star_data, Space_Location_Data)
star_data.__index = star_data
return star_data
-- local Star_Data = star_data:new(Star_Data)
-- -- Star_Data.mt = star_data

-- return Star_Data