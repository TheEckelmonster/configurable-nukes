local Data = require("scripts.data.data")

local cache_attribute_data = {}

cache_attribute_data.type = "cache-attribute"
cache_attribute_data.no_attr = true
cache_attribute_data.time_to_live = 2 ^ 64 - 1

cache_attribute_data.created = game and game.tick or 1
cache_attribute_data.updated = game and game.tick or 1

function cache_attribute_data:new(o, opts)
    -- Log.debug("cache_attribute_data:new")
    -- Log.info(o)

    local defaults = {
        type = self.type,
        time_to_live = self.time_to_live,
        created = game and game.tick or 1,
        updated = game and game.tick or 1,
    }

    opts = type(opts) == "table" and opts or { attrs = {} }
    opts.attrs = type(opts.attrs) == "table" and opts.attrs or {}

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end
    for k, v in pairs(opts.attrs) do if ((obj[k] == nil or opts.overwrite) and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self

    obj.valid = game and game.tick and game.tick > obj.time_to_live

    return obj
end

setmetatable(cache_attribute_data, Data)
cache_attribute_data.__index = cache_attribute_data

return cache_attribute_data