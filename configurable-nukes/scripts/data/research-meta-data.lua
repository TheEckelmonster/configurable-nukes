local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local research_meta_data = Data:new()

research_meta_data.force = nil
research_meta_data.force_index = -1
research_meta_data.force_name = nil
research_meta_data.research_level = 0

function research_meta_data:new(o)
    Log.debug("research_meta_data:new")
    Log.info(o)

    local defaults = {
        force = self.force,
        force_index = self.force_index,
        force_name = self.force_name,
        research_level = self.research_level,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(research_meta_data, Data)
local Research_Meta_Data = research_meta_data:new(Research_Meta_Data)

return Research_Meta_Data