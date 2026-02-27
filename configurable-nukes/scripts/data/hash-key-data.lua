local Data = require("scripts.data.data")

local hash_key_data = {}

hash_key_data.type = "hash-key"
hash_key_data.no_attr = true
hash_key_data.tick = 0
hash_key_data.tick_count = 0

hash_key_data.created = game and game.tick or 1
hash_key_data.updated = game and game.tick or 1
hash_key_data.valid = false

function hash_key_data:new(o)
    -- Log.debug("hash_key_data:new")
    -- Log.info(o)

    local defaults = {
        type = self.type,
        tick = 0,
        tick_count = 0,
        created = game and game.tick or 1,
        updated = game and game.tick or 1
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    setmetatable(obj, self)
    self.__index = self

    obj.valid = obj.created and obj.updated and obj.updated >= obj.created

    return obj
end

setmetatable(hash_key_data, Data)
hash_key_data.__index = hash_key_data

return hash_key_data