local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local rocket_silo_data = {}

rocket_silo_data.unit_number = -1
rocket_silo_data.entity = nil
rocket_silo_data.signals = {
    x = { type = "virtual", name = "signal-X" },
    y = { type = "virtual", name = "signal-Y" },
    launch = { type = "virtual", name = "signal-check" },
    origin_override = nil,
}
rocket_silo_data.planet_gui_id = 0

function rocket_silo_data:new(o)
    Log.debug("rocket_silo_data:new")
    Log.info(o)

    local defaults = {
        unit_number = self.unit_number,
        entity = self.entity,
        signals = {
            x = { type = "virtual", name = "signal-X" },
            y = { type = "virtual", name = "signal-Y" },
            launch = { type = "virtual", name = "signal-check" },
            origin_override = nil,
        },
        planet_gui_id = self.planet_gui_id,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(rocket_silo_data, Data)
local Rocket_Silo_Data = rocket_silo_data:new(Rocket_Silo_Data)

return Rocket_Silo_Data