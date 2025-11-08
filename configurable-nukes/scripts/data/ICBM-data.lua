local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local sa_active = mods and mods["space-age"] and true or scripts and scripts.active_mods and scripts.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or scripts and scripts.active_mods and scripts.active_mods["space-exploration"]

local icbm_data = {}

icbm_data.type = "icbm-data"

icbm_data.sa_active = sa_active
icbm_data.se_active = se_active

icbm_data.surface = nil
icbm_data.surface_name = nil
icbm_data.item_number = {
    get = function ()
        local return_val = 1

        if (storage) then
            if (storage.icbm_data) then
                if (storage.icbm_data.item_number) then
                    return_val = storage.icbm_data.item_number
                else
                    storage.icbm_data.item_number = return_val
                end
            else
                storage.icbm_data = { item_number = return_val }
            end
        end

        return return_val
    end,
    set = function (val)
        if (storage) then
            storage.icbm_data = { item_number = val }
        end
    end,
    increment = function ()
        local return_val = 1
        if (storage) then
            if (storage.icbm_data) then
                if (storage.icbm_data.item_number) then
                    return_val = storage.icbm_data.item_number
                    storage.icbm_data.item_number = storage.icbm_data.item_number + 1
                else
                    storage.icbm_data.item_number = return_val
                end
            else
                storage.icbm_data = { item_number = return_val }
            end
        end

        return return_val
    end,
}
icbm_data.item_numbers = {
    get = function (item_number)
        if (item_number == nil or type(item_number) ~= "number" or item_number < 1) then return end

        if (storage and storage.icbm_data and storage.icbm_data.item_numbers) then return storage.icbm_data.item_numbers[item_number] end
    end,
    set = function (item_number)
        if (item_number == nil or type(item_number) ~= "number" or item_number < 1) then return end

        if (storage) then
            if (not storage.icbm_data) then storage.icbm_data = {} end
            if (not storage.icbm_data.item_numbers) then storage.icbm_data.item_numbers = {} end

            storage.icbm_data.item_numbers[item_number] = {}
        end
    end,
    remove = function (item_number)
        if (item_number == nil or type(item_number) ~= "number" or item_number < 1) then return end

        if (storage and storage.icbm_data and storage.icbm_data.item_numbers and storage.icbm_data.item_numbers[item_number]) then storage.icbm_data.item_numbers[item_number] = nil end
    end,
    -- get_all = function ()
    --     local return_val = nil

    --     if (storage and storage.icbm_data and storage.icbm_data.item_numbers) then return_val = storage.icbm_data.item_numbers end

    --     return return_val
    -- end,
    remove_all = function ()
        if (storage and storage.icbm_data) then storage.icbm_data.item_numbers = {} end
    end,
}

icbm_data.item = nil
icbm_data.item_name = nil
icbm_data.cargo_pod = nil
icbm_data.cargo_pod_unit_number = -1
icbm_data.force = nil
icbm_data.force_index = -1
icbm_data.tick_launched = -1
icbm_data.tick_to_target = -1
icbm_data.same_surface = false
icbm_data.source_silo = nil
icbm_data.silo_type = nil
icbm_data.source_position = nil
icbm_data.source_system = nil
icbm_data.original_target_position = nil
icbm_data.target_position = nil
icbm_data.target_distance = -1
icbm_data.target_surface = nil
icbm_data.target_surface_name = nil
icbm_data.target_surface_index = -1
icbm_data.target_system = nil
icbm_data.circuit_launch = false
icbm_data.player_launched_by = nil
icbm_data.player_launched_index = -1
--[[
    Current possible values:
    -> "surface"
    -> "orbit"
    -> "inteplanetary"
]]
icbm_data.launched_from = nil
icbm_data.launched_from_space = false
icbm_data.base_target_distance = 0
icbm_data.speed = 0
icbm_data.is_travelling = false
icbm_data.space_origin_pos = nil
--[[ For knowing where in the forces launch-action-queue the given icbm-data is located
    -> Trying to avoid iterating through the queue each time a payload arrives
]]
icbm_data.enqueued_data = nil
icbm_data.event_handlers = {}

function icbm_data:new(o)
    _Log.debug("icbm_data:new")
    _Log.info(o)

    local defaults = {
        type = self.type,
        -- sa_active = self.sa_active,
        -- se_active = self.se_active,
        surface = nil,
        surface_name = nil,
        item_number = icbm_data.item_number.get(),
        item = nil,
        item_name = nil,
        cargo_pod = nil,
        cargo_pod_unit_number = self.cargo_pod_unit_number,
        force = nil,
        force_index = self.force_index,
        tick_launched = -1,
        tick_to_target = -1,
        source_silo = nil,
        silo_type = nil,
        same_surface = self.same_surface,
        source_position = nil,
        source_system = self.source_system,
        original_target_position = nil,
        target_position = nil,
        target_distance = self.target_distance,
        target_surface = self.target_surface,
        target_surface_name = self.target_surface_name,
        target_surface_index = self.target_surface_index,
        target_system = self.target_system,
        circuit_launch = self.circuit_launch,
        player_launched_by = self.player_launched_by,
        player_launched_index = self.player_launched_index,
        launched_from = self.launched_from,
        launched_from_space = self.launched_from_space,
        base_target_distance = self.base_target_distance,
        speed = self.speed,
        is_travelling = self.is_travelling,
        space_origin_pos = nil,
        enqueued_data = nil,
        event_handlers = {},
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    if (obj.item_number >= 0) then
        icbm_data.item_numbers.set(obj.item_number)
        icbm_data.item_number.increment()
    end

    return obj
end

function icbm_data:next_item_number()
    _Log.debug("icbm_data:next_item_number")

    return icbm_data.item_number.get()
end

function icbm_data:get_item_numbers()
    _Log.debug("icbm_data:get_item_numbers")
    _Log.info(item_number)

    return
    {
        get = icbm_data.item_numbers.get,
        set = icbm_data.item_numbers.set,
        remove = icbm_data.item_numbers.remove,
        -- get_all = icbm_data.item_numbers.get_all,
        remove_all = icbm_data.item_numbers.remove_all,
    }
end

function icbm_data:validate_fields()
    Log.debug("icbm_data:validate_fields")
    Log.info(self)

    if (not self or type(self) ~= "table") then return end

    if (type(self.type) == "string" and self.type == icbm_data.type) then
        if (not self.cargo_pod or not self.cargo_pod.valid) then self.cargo_pod = nil end
        if (not self.surface or not self.surface.valid) then self.surface = nil end
        if (not self.source_silo or not self.source_silo.valid) then self.source_silo = nil end
        if (not self.target_surface or not self.target_surface.valid) then self.target_surface = nil end
        if (not self.player_launched_by or not self.player_launched_by.valid) then self.player_launched_by = nil end
    end
end

setmetatable(icbm_data, Data)
icbm_data.__index = icbm_data
return icbm_data