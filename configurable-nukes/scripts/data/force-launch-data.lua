

local Data = require("scripts.data.data")
local Log = require("libs.log.log")
local Queue_Data = require("scripts.data.structures.queue-data")

local force_launch_data = {}

force_launch_data.type = "force-launch-data"

force_launch_data.force = nil
force_launch_data.force_index = -1
force_launch_data.force_name = nil

--[[ indexed by force_index ]]
force_launch_data.launch_action_queue = nil
function force_launch_data:new_force_launch_data_queue(data)
    return Queue_Data:new({ name = "launch_action_queue", limit = 2 ^ 5 })
end

function force_launch_data:new(o)
    Log.debug("force_launch_data:new")
    Log.info(o)

    local defaults = {
        force = nil,
        force_index = -1,
        force_name = nil,
        launch_action_queue = self:new_force_launch_data_queue(),
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

setmetatable(force_launch_data, Data)
local Force_Launch_Data = force_launch_data:new(Force_Launch_Data)

return Force_Launch_Data