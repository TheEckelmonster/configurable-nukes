local Log = require("libs.log.log")

local locals = {}
locals = {
    ["defaults"] = function (self, _, data)
        Log.debug("data.locals:defaults")
        Log.info(data)

        local index = game and game.tick or 0

        return {
            name = data and data.name,
            type = data and data.type,
            created = index,
            updated = index,
        }
    end,
    ["new"] = function (self, obj, data)
        Log.debug("data.locals:new")
        Log.info(obj)
        Log.info(data)

        local defaults = self:defaults()

        if (type(obj) ~= "table") then obj = defaults end

        for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

        return obj
    end,
}

local _data = {}

function _data:new(o, data)
    Log.debug("data:new")
    Log.info(o)
    Log.info(data)

    local defaults = locals:defaults(_, data)

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = locals:new(obj, data)

    setmetatable(obj, self)
    self.__index = function (t, k)
        if (k == nil) then return nil end

        return self[k]
    end

    if (game and obj.valid ~= nil) then obj.valid = obj:is_valid() end

    return obj
end

function _data:is_valid()
    Log.debug("data:is_valid")
    return  self.created ~= nil
        and type(self.created) == "number"
        and self.created >= 0
        and self.updated ~= nil
        and type(self.updated) == "number"
        and self.updated >= self.created
end

function _data:update(data)
    Log.debug("data:update")
    Log.info(self)
    Log.info(data)

    if (data and type(data) ~= "table") then return -1 end

    if (data and type(data.data) == "table" and next(data.data)) then for k, v in pairs(data.data) do if (type(v) ~= "function") then self[k] = v end end end
end

local Data = _data:new(Data)
Data.mt = _data

return Data