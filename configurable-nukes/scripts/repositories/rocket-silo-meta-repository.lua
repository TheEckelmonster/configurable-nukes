-- If already defined, return
if _rocket_silo_meta_repository and _rocket_silo_meta_repository.configurable_nukes then
    return _rocket_silo_meta_repository
end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
local Rocket_Silo_Meta_Data = require("scripts.data.rocket-silo-meta-data")
local String_Utils = require("scripts.utils.string-utils")

local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local rocket_silo_meta_repository = {}

function rocket_silo_meta_repository.save_rocket_silo_meta_data(space_location_name, optionals)
    Log.debug("rocket_silo_meta_repository.save_rocket_silo_meta_data")
    Log.info(space_location_name)
    Log.info(optionals)

    local return_val = Rocket_Silo_Meta_Data:new()

    if (not game) then return return_val end
    if (not space_location_name or type(space_location_name) ~= "string") then return return_val end
    if (String_Utils.find_invalid_substrings(space_location_name)) then return return_val end

    if (not se_active) then
        if (not Constants.planets_dictionary) then Constants.get_planets(true) end
        if (not Constants.planets_dictionary[space_location_name:lower()]) then return return_val end
    else
        if (not space_location_name:find("spaceship-", 1, true) and not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
        if (not space_location_name:find("spaceship-", 1, true) and not Constants.space_exploration_dictionary[space_location_name:lower()]) then return return_val end
    end

    optionals = optionals or {
        surface = game.get_surface(space_location_name)
    }

    local surface = optionals.surface or game.get_surface(space_location_name)
    if (not surface or not surface.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.rocket_silo_meta_data) then storage.configurable_nukes.rocket_silo_meta_data = {} end
    if (not storage.configurable_nukes.rocket_silo_meta_data[space_location_name]) then storage.configurable_nukes.rocket_silo_meta_data[space_location_name] = return_val end

    return_val = storage.configurable_nukes.rocket_silo_meta_data[space_location_name]
    return_val.space_location_name = space_location_name
    return_val.surface_index = surface.index

    return_val.valid = true

    return rocket_silo_meta_repository.update_rocket_silo_meta_data(optionals.update_data or return_val)
end

function rocket_silo_meta_repository.update_rocket_silo_meta_data(update_data, optionals)
    Log.debug("rocket_silo_meta_repository.update_rocket_silo_meta_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = Rocket_Silo_Meta_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end
    if (not update_data.space_location_name or type(update_data.space_location_name) ~= "string") then return return_val end

    optionals = optionals or {}

    local space_location_name = update_data.space_location_name

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.rocket_silo_meta_data) then storage.configurable_nukes.rocket_silo_meta_data = {} end
    if (not storage.configurable_nukes.rocket_silo_meta_data[space_location_name]) then
        -- If it doesn't exist, generate it
        return rocket_silo_meta_repository.save_rocket_silo_meta_data(space_location_name, { update_data = update_data })
    end

    local rocket_silo_meta_data = storage.configurable_nukes.rocket_silo_meta_data[space_location_name]

    for k, v in pairs(update_data) do
        rocket_silo_meta_data[k] = v
    end

    rocket_silo_meta_data.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes.rocket_silo_meta_data[space_location_name] = rocket_silo_meta_data

    return rocket_silo_meta_data
end

function rocket_silo_meta_repository.delete_rocket_silo_meta_data(space_location_name, optionals)
    Log.debug("rocket_silo_meta_repository.delete_rocket_silo_meta_data")
    Log.info(space_location_name)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (not space_location_name or type(space_location_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.rocket_silo_meta_data) then storage.configurable_nukes.rocket_silo_meta_data = {} end
    if (storage.configurable_nukes.rocket_silo_meta_data[space_location_name] ~= nil) then
        storage.configurable_nukes.rocket_silo_meta_data[space_location_name] = nil
    end
    return_val = true

    return return_val
end

function rocket_silo_meta_repository.get_rocket_silo_meta_data(space_location_name, optionals)
    Log.debug("rocket_silo_meta_repository.get_rocket_silo_meta_data")
    Log.info(space_location_name)
    Log.info(optionals)

    local return_val = Rocket_Silo_Meta_Data:new()

    if (not game) then return return_val end
    if (not space_location_name or type(space_location_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.rocket_silo_meta_data) then storage.configurable_nukes.rocket_silo_meta_data = {} end
    if (not storage.configurable_nukes.rocket_silo_meta_data[space_location_name]) then
        -- If it doesn't exist, generate it
        return rocket_silo_meta_repository.save_rocket_silo_meta_data(space_location_name)
    end

    return storage.configurable_nukes.rocket_silo_meta_data[space_location_name]
end

function rocket_silo_meta_repository.get_all_rocket_silo_meta_data(optionals)
    Log.debug("rocket_silo_meta_repository.get_all_rocket_silo_meta_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.rocket_silo_meta_data) then storage.configurable_nukes.rocket_silo_meta_data = {} end

    return storage.configurable_nukes.rocket_silo_meta_data
end

rocket_silo_meta_repository.configurable_nukes = true

local _rocket_silo_meta_repository = rocket_silo_meta_repository

return rocket_silo_meta_repository
