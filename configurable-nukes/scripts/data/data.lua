local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local locals = {}
locals = {
    ["defaults"] = function (self, _, data)
        _Log.debug("data.locals:defaults")
        _Log.info(data)

        local index = game and game.tick or 0

        return {
            type = "data",
            name = data and data.name,
            -- type = data and data.type,
            created = index,
            updated = index,
        }
    end,
    ["new"] = function (self, obj, data)
        _Log.debug("data.locals:new")
        _Log.info(obj)
        _Log.info(data)

        local defaults = self:defaults()

        if (type(obj) ~= "table") then obj = defaults end

        for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

        return obj
    end,
}

local _data = {}

function _data:new(o, data)
    _Log.debug("data:new")
    _Log.info(o)
    _Log.info(data)

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
    _Log.debug("data:is_valid")
    return  self.created ~= nil
        and type(self.created) == "number"
        and self.created >= 0
        and self.updated ~= nil
        and type(self.updated) == "number"
        and self.updated >= self.created
end

function _data:update(data)
    _Log.debug("data:update")
    _Log.info(self)
    _Log.info(data)

    if (data and type(data) ~= "table") then return -1 end

    if (data and type(data.data) == "table" and next(data.data)) then for k, v in pairs(data.data) do if (type(v) ~= "function") then self[k] = v end end end
end

local Data = _data:new(Data)
Data.mt = _data

return Data