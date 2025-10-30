local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")

local configurable_nukes_repository = {}

function configurable_nukes_repository.save_configurable_nukes_data(optionals)
    Log.debug("configurable_nukes_repository.save_configurable_nukes_data")
    Log.info(optionals)

    local return_val = Configurable_Nukes_Data:new()

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = return_val end

    return_val = storage.configurable_nukes

    return configurable_nukes_repository.update_configurable_nukes_data(return_val)
end

function configurable_nukes_repository.update_configurable_nukes_data(update_data, optionals)
    Log.debug("configurable_nukes_repository.update_configurable_nukes_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Configurable_Nukes_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then
        -- If it doesn't exist, generate it
        storage.configurable_nukes = return_val
        configurable_nukes_repository.save_configurable_nukes_data()
    end

    return_val = storage.configurable_nukes

    for k, v in pairs(update_data) do
        return_val[k] = v
    end

    return_val.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes = return_val

    return return_val
end

function configurable_nukes_repository.delete_configurable_nukes_data(optionals)
    Log.debug("configurable_nukes_repository.delete_configurable_nukes_data")
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (storage.configurable_nukes ~= nil) then
        storage.configurable_nukes = nil
    end
    return_val = true

    return return_val
end

function configurable_nukes_repository.get_configurable_nukes_data(optionals)
    Log.debug("configurable_nukes_repository.get_configurable_nukes_data")
    Log.info(optionals)

    local return_val = Configurable_Nukes_Data:new()

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then
        -- If it doesn't exist, generate it
        storage.configurable_nukes = return_val
        configurable_nukes_repository.save_configurable_nukes_data()
    end

    return_val = storage.configurable_nukes

    return return_val
end

return configurable_nukes_repository