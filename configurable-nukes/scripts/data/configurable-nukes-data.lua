

local Data = require("scripts.data.data")
local Log = require("libs.log.log")
local Version_Data = require("scripts.data.version-data")

local configurable_nukes_data = {}

configurable_nukes_data.type = "configurable-nukes-data"

configurable_nukes_data.icbm_meta_data = {}
configurable_nukes_data.research_meta_data = {}
configurable_nukes_data.rocket_silo_meta_data = {}
configurable_nukes_data.force_launch_data = {}

configurable_nukes_data.version_data = Version_Data:new()

function configurable_nukes_data:new(o)
    Log.debug("configurable_nukes_data:new")
    Log.info(o)

    local defaults = {
        type = self.type,
        icbm_meta_data = {},
        rocket_silo_meta_data = {},
        force_launch_data = {},
        version_data = Version_Data:new(),
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(configurable_nukes_data, Data)
configurable_nukes_data.__index = configurable_nukes_data
return configurable_nukes_data