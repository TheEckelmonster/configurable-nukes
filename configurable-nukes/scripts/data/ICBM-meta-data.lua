local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local icbm_meta_data = {}

icbm_meta_data.type = "icbm-meta-data"

icbm_meta_data.surface = nil
icbm_meta_data.surface_name = nil
icbm_meta_data.items = {}
icbm_meta_data.in_transit = {}
icbm_meta_data.icbms = {}

function icbm_meta_data:new(o)
    Log.debug("icbm_meta_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
        surface = nil,
        surface_name = nil,
        items = {},
        in_transit = {},
        icbms = {},
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function icbm_meta_data:remove_data(data)
    Log.debug("icbm_meta_data:remove_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end
    if (not data.icbm_data.valid) then return end
    if (data.icbm_data.item_number == nil or type(data.icbm_data.item_number) ~= "number") then return end

    self.items[data.icbm_data.item_number] = nil
    self.icbms[data.icbm_data.item_number] = nil
    self.in_transit[data.icbm_data] = nil
end

setmetatable(icbm_meta_data, Data)
icbm_meta_data.__index = icbm_meta_data
return icbm_meta_data