local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local space_location_data = {}

space_location_data.type = "space-location-data"

space_location_data.name = nil
space_location_data.surface = nil
space_location_data.surface_index = -1
space_location_data.magnitude = 1
space_location_data.gravity_pull = 0
space_location_data.orientation = nil
space_location_data.star_distance = nil
space_location_data.orbit = nil
space_location_data.orbit_index = -1
space_location_data["space-connection"] = {}
space_location_data.x = 0
space_location_data.y = 0

--[[ Space-Exploration specific ]]
space_location_data.hierarchy = nil
space_location_data.hierarchy_index = nil
space_location_data.parent = nil
space_location_data.parent_index = nil
space_location_data.orbit = nil
space_location_data.orbit_index = nil
space_location_data.child_indices = {}
space_location_data.children = {}
space_location_data.zone = {}
space_location_data.zone_index = nil
space_location_data.special_type = nil
space_location_data.radius = nil
space_location_data.radius_multiplier = nil

function space_location_data:new(o)
    _Log.debug("space_location_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        name = self.name,
        surface = self.surface,
        surface_index = self.surface_index,
        magnitude = self.magnitude,
        gravity_pull = self.gravity_pull,
        orientation = self.orientation,
        star_distance = self.star_distance,
        x = self.x,
        y = self.y,
        ["space-connection"] = ((mods and not mods["space-exploration"]) or (script and script.active_mods and not script.active_mods["space-exploration"])) and {} or nil,

        --[[ Space-Exploration specific ]]
        hierarchy = self.hierarchy,
        hierarchy_index = self.hierarchy_index,
        parent = self.parent,
        parent_index = self.parent_index,
        orbit = self.orbit,
        orbit_index = self.orbit_index,
        child_indices = ((mods and mods["space-exploration"]) or (script and script.active_mods and script.active_mods["space-exploration"])) and {} or nil,
        children = ((mods and mods["space-exploration"]) or (script and script.active_mods and script.active_mods["space-exploration"])) and {} or nil,
        zone = self.zone,
        zone_index = self.zone_index,
        special_type = self.special_type,
        radius = self.radius,
        radius_multiplier = self.radius_multiplier,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function space_location_data:get_stellar_system(data)
    _Log.debug("space_location_data:get_stellar_system")
    _Log.info(data)

    if (data and type(data) ~= "table") then return end
    if (not data) then data = {} end
    if (not data.count) then data.count = 1 end
    --[[ Pretty sure this should at most only recursively call itself ~4 times?
        -> Regardless, quit after 2 ^ 3 (8) calls
    ]]
    if (data.count > 2 ^ 3) then return end
    if (not self.type) then return end
    if (not self.parent) then
        if (self.type == "anomaly-data" or self.type == "star-data" or self.type == "asteroid-field-data") then
            return self.name:lower()
        end
    else
        return self.parent:get_stellar_system({ count = data.count + 1})
    end
end

function space_location_data:is_solid(data)
    _Log.debug("space_location_data:is_solid")
    _Log.info(data)

    return true
end

setmetatable(space_location_data, Data)
space_location_data.__index = space_location_data
return space_location_data