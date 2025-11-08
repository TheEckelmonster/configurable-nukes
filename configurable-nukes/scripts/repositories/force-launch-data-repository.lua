local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Force_Launch_Data = require("scripts.data.force-launch-data")

local force_launch_data_repository = {}

function force_launch_data_repository.save_force_launch_data(force_index, optionals)
    Log.debug("force_launch_data_repository.save_force_launch_data")
    Log.info(force_index)
    Log.info(optionals)

    local return_val = Force_Launch_Data:new()

    if (not game) then return return_val end
    if (force_index == nil or type(force_index) ~= "number" or force_index < 1) then return return_val end
    if (force_index < 0 or force_index > 2 ^ 6 - 1) then return return_val end

    optionals = optionals or {
        force = game.forces[force_index],
    }

    local force = optionals.force or game.forces[force_index]
    if (not force or not force.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.force_launch_data) then storage.configurable_nukes.force_launch_data = {} end
    if (not storage.configurable_nukes.force_launch_data[force.index]) then storage.configurable_nukes.force_launch_data[force.index] = return_val end

    return_val = storage.configurable_nukes.force_launch_data[force.index]

    return_val.force = force
    return_val.force_index = force.index
    return_val.force_name = force.name

    return_val.valid = true

    return force_launch_data_repository.update_force_launch_data(return_val)
end

function force_launch_data_repository.update_force_launch_data(update_data, optionals)
    Log.debug("force_launch_data_repository.update_force_launch_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Force_Launch_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end
    if (update_data.force_index == nil or type(update_data.force_index) ~= "number") then return return_val end
    if (update_data.force_index < 0 or update_data.force_index > 2 ^ 6 - 1) then return return_val end

    optionals = optionals or {}

    local force_index = update_data.force_index

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.force_launch_data) then storage.configurable_nukes.force_launch_data = {} end
    if (not storage.configurable_nukes.force_launch_data[force_index]) then
        -- If it doesn't exist, generate it
        return force_launch_data_repository.save_force_launch_data(force_index)
    end

    local force_launch_data = storage.configurable_nukes.force_launch_data[force_index]

    for k, v in pairs(update_data) do force_launch_data[k] = v end

    force_launch_data.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes.force_launch_data[force_index] = force_launch_data

    return force_launch_data
end

function force_launch_data_repository.delete_force_launch_data(force_index, optionals)
    Log.debug("force_launch_data_repository.delete_force_launch_data")
    Log.info(force_index)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (force_index == nil or type(force_index) ~= "number") then return return_val end
    if (force_index < 0 or force_index > 2 ^ 6 - 1) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.force_launch_data) then storage.configurable_nukes.force_launch_data = {} end
    if (storage.configurable_nukes.force_launch_data[force_index] ~= nil) then
        storage.configurable_nukes.force_launch_data[force_index] = nil
    end
    return_val = true

    return return_val
end

function force_launch_data_repository.get_force_launch_data(force_index, optionals)
    Log.debug("force_launch_data_repository.get_force_launch_data")
    Log.info(force_index)
    Log.info(optionals)

    local return_val = Force_Launch_Data:new()

    if (not game) then return return_val end
    if (force_index == nil or type(force_index) ~= "number") then return return_val end
    if (force_index < 0 or force_index > 2 ^ 6 - 1) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.force_launch_data) then storage.configurable_nukes.force_launch_data = {} end
    if (not storage.configurable_nukes.force_launch_data[force_index]) then
        -- If it doesn't exist, generate it
        return force_launch_data_repository.save_force_launch_data(force_index)
    end

    return storage.configurable_nukes.force_launch_data[force_index]
end

function force_launch_data_repository.get_all_force_launch_data(optionals)
    Log.debug("force_launch_data_repository.get_all_force_launch_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.force_launch_data) then storage.configurable_nukes.force_launch_data = {} end

    return storage.configurable_nukes.force_launch_data
end

return force_launch_data_repository
