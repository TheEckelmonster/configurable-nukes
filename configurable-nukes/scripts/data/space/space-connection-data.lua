local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local space_connection_data = {}

space_connection_data.type = "space-connection-data"

space_connection_data.forward = nil
space_connection_data.reverse = nil
space_connection_data.length = 0

function space_connection_data:new(o)
    _Log.debug("space_connection_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        forward = self.forward,
        reverse = self.reverse,
        length = self.length,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(space_connection_data, Data)
space_connection_data.__index = space_connection_data
return space_connection_data