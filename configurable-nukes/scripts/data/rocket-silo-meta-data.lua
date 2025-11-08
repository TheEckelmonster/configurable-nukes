local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local rocket_silo_meta_data = Data:new()

rocket_silo_meta_data.type = "rocket-silo-meta-data"

rocket_silo_meta_data.planet_name = nil
rocket_silo_meta_data.surface_name = nil
rocket_silo_meta_data.space_location_name = nil
rocket_silo_meta_data.surface = nil
rocket_silo_meta_data.rocket_silos = {}
rocket_silo_meta_data.surface_index = -1

function rocket_silo_meta_data:new(o)
    _Log.debug("rocket_silo_meta_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        planet_name = self.planet_name,
        surface_name = self.surface_name,
        space_location_name = self.space_location_name,
        surface = self.surface,
        rocket_silos = {},
        surface_index = self.surface_index,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(rocket_silo_meta_data, Data)
rocket_silo_meta_data.__index = rocket_silo_meta_data
return rocket_silo_meta_data