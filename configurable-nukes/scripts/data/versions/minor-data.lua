local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local minor_data = {}

minor_data.value = 0
minor_data.valid = true

function minor_data:new(o)
    _Log.debug("minor_data:new")
    _Log.info(o)

    local defaults = {
        value = minor_data.value,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(minor_data, Data)
minor_data.__index = minor_data
return minor_data