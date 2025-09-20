local Data = require("scripts.data.data")
local Log = require("libs.log.log")

local icbm_data = {}

icbm_data.type = nil
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
icbm_data.item = nil
icbm_data.cargo_pod = nil
icbm_data.cargo_pod_unit_number = -1
icbm_data.force = nil
icbm_data.force_index = -1
icbm_data.tick_launched = -1
icbm_data.tick_to_target = -1
icbm_data.source_silo = nil
icbm_data.source_position = nil
icbm_data.original_target_position = nil
icbm_data.target_position = nil
icbm_data.target_distance = -1
icbm_data.player_launched_by = nil
icbm_data.player_launched_index = -1

function icbm_data:new(o)
    Log.debug("icbm_data:new")
    Log.info(o)

    local defaults = {
        type = nil,
        surface = nil,
        surface_name = nil,
        item_number = icbm_data.item_number.get(),
        item = nil,
        cargo_pod = nil,
        cargo_pod_unit_number = self.cargo_pod_unit_number,
        force = nil,
        force_index = self.force_index,
        tick_launched = -1,
        tick_to_target = -1,
        source_silo = nil,
        original_target_position = nil,
        source_position = nil,
        target_position = nil,
        target_distance = self.target_distance,
        player_launched_by = self.player_launched_by,
        player_launched_index = self.player_launched_index,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    if (obj.item_number >= 0) then icbm_data.item_number.increment() end

    return obj
end

setmetatable(icbm_data, Data)
local ICBM_Data = icbm_data:new(ICBM_Data)

function ICBM_Data:next_item_number()
    return icbm_data.item_number.get()
end

return ICBM_Data