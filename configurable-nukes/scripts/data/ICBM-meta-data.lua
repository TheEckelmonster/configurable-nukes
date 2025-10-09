local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local icbm_meta_data = {}

icbm_meta_data.surface = nil
icbm_meta_data.surface_name = nil
icbm_meta_data.item_numbers = {}
icbm_meta_data.items = {}
icbm_meta_data.in_transit = {}
icbm_meta_data.icbms = {}

function icbm_meta_data:new(o)
    Log.debug("icbm_meta_data:new")
    Log.info(o)

    local defaults = {
        surface = nil,
        surface_name = nil,
        item_numbers = {},
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

setmetatable(icbm_meta_data, Data)
local ICBM_Meta_Data = icbm_meta_data:new(ICBM_Meta_Data)

return ICBM_Meta_Data