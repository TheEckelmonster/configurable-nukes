local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Version_Data = require("scripts.data.version-data")

local version_repository = {}

function version_repository.save_version_data(optionals)
    Log.debug("version_repository.save_version_data")
    Log.info(optionals)

    local return_val = Version_Data:new()

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.version_data) then storage.configurable_nukes.version_data = return_val end

    return_val = storage.configurable_nukes.version_data

    return version_repository.update_version_data(return_val)
end

function version_repository.update_version_data(update_data, optionals)
    Log.debug("version_repository.update_version_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Version_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.version_data) then
        -- If it doesn't exist, generate it
        storage.configurable_nukes.version_data = return_val
        version_repository.save_version_data()
    end

    local version_data = storage.configurable_nukes.version_data

    for k, v in pairs(update_data) do
        version_data[k] = v
    end

    version_data.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes.version_data = version_data

    return version_data
end

function version_repository.get_version_data(optionals)
    Log.debug("version_repository.get_version_data")
    Log.info(optionals)

    local return_val = Version_Data:new()

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.version_data) then
        -- If it doesn't exist, generate it
        storage.configurable_nukes.version_data = return_val
        version_repository.save_version_data()
    end

    return storage.configurable_nukes.version_data
end

return version_repository
