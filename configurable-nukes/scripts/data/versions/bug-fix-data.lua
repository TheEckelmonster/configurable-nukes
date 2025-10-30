local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local bug_fix_data = {}

bug_fix_data.value = 0
bug_fix_data.valid = true

function bug_fix_data:new(o)
    _Log.debug("bug_fix_data:new")
    _Log.info(o)

    local defaults = {
        value = bug_fix_data.value,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(bug_fix_data, Data)
bug_fix_data.__index = bug_fix_data
return bug_fix_data