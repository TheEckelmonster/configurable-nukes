-- If already defined, return
if _research_meta_repository and _research_meta_repository.configurable_nukes then
    return _research_meta_repository
end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Log = require("libs.log.log")
local Research_Meta_Data = require("scripts.data.rocket-silo-meta-data")

local research_meta_repository = {}

function research_meta_repository.save_research_meta_data(force_name, optionals)
    Log.debug("research_meta_repository.save_research_meta_data")
    Log.info(force_name)
    Log.info(optionals)

    local return_val = Research_Meta_Data:new()

    if (not game) then return return_val end
    if (    (not force_name or type(force_name) ~= "string")
        and (not force_index or type(force_index) ~= "number" or force_index < 1))
    then return return_val end

    optionals = optionals or {
        force = game.forces[force_name],
        research_level = 0,
    }

    local force = optionals.force or game.forces[force_name]
    if (not force or not force.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.research_meta_data) then storage.configurable_nukes.research_meta_data = {} end
    if (not storage.configurable_nukes.research_meta_data[force_name]) then storage.configurable_nukes.research_meta_data[force_name] = return_val end

    return_val = storage.configurable_nukes.research_meta_data[force_name]

    return_val.force = force
    return_val.force_index = force.index
    return_val.force_name = force_name
    return_val.research_level = optionals.research_level or 0

    return_val.valid = true

    return research_meta_repository.update_research_meta_data(return_val)
end

function research_meta_repository.update_research_meta_data(update_data, optionals)
    Log.debug("research_meta_repository.update_research_meta_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Research_Meta_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end
    if (not update_data.force_name or type(update_data.force_name) ~= "string") then return return_val end

    optionals = optionals or {}

    local force_name = update_data.force_name

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.research_meta_data) then storage.configurable_nukes.research_meta_data = {} end
    if (not storage.configurable_nukes.research_meta_data[force_name]) then
        -- If it doesn't exist, generate it
        return research_meta_repository.save_research_meta_data(force_name)
    end

    local research_meta_data = storage.configurable_nukes.research_meta_data[force_name]

    for k, v in pairs(update_data) do research_meta_data[k] = v end

    research_meta_data.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes.research_meta_data[force_name] = research_meta_data

    return research_meta_data
end

function research_meta_repository.delete_research_meta_data(force_name, optionals)
    Log.debug("research_meta_repository.delete_research_meta_data")
    Log.info(force_name)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (not force_name or type(force_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.research_meta_data) then storage.configurable_nukes.research_meta_data = {} end
    if (storage.configurable_nukes.research_meta_data[force_name] ~= nil) then
        storage.configurable_nukes.research_meta_data[force_name] = nil
    end
    return_val = true

    return return_val
end

function research_meta_repository.get_research_meta_data(force_name, optionals)
    Log.debug("research_meta_repository.get_research_meta_data")
    Log.info(force_name)
    Log.info(optionals)

    local return_val = Research_Meta_Data:new()

    if (not game) then return return_val end
    if (not force_name or type(force_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.research_meta_data) then storage.configurable_nukes.research_meta_data = {} end
    if (not storage.configurable_nukes.research_meta_data[force_name]) then
        -- If it doesn't exist, generate it
        return research_meta_repository.save_research_meta_data(force_name)
    end

    return storage.configurable_nukes.research_meta_data[force_name]
end

function research_meta_repository.get_all_research_meta_data(optionals)
    Log.debug("research_meta_repository.get_all_research_meta_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.research_meta_data) then storage.configurable_nukes.research_meta_data = {} end

    return storage.configurable_nukes.research_meta_data
end

research_meta_repository.configurable_nukes = true

local _research_meta_repository = research_meta_repository

return research_meta_repository
