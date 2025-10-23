-- If already defined, return
if _icbm_meta_repository and _icbm_meta_repository.configurable_nukes then
    return _icbm_meta_repository
end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
local ICBM_Meta_Data = require("scripts.data.ICBM-meta-data")
local String_Utils = require("scripts.utils.string-utils")

local icbm_meta_repository = {}

function icbm_meta_repository.save_icbm_meta_data(surface_name, optionals)
    Log.debug("icbm_meta_repository.save_icbm_meta_data")
    Log.info(surface_name)
    Log.info(optionals)

    local return_val = ICBM_Meta_Data:new()

    if (not game) then return return_val end
    if (not surface_name or type(surface_name) ~= "string") then return return_val end
    if (String_Utils.find_invalid_substrings(surface_name)) then return return_val end
    if (not Constants.planets_dictionary) then Constants.get_planets(true) end
    if (not Constants.planets_dictionary[surface_name]) then
        local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]
        if (not se_active and not string.find(surface_name, "platform-", 1, true)) then
            return return_val
        end
    end

    optionals = optionals or {
        surface = game.get_surface(surface_name)
    }

    local surface = optionals.surface or game.get_surface(surface_name)
    if (not surface or not surface.valid) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[surface_name]) then storage.configurable_nukes.icbm_meta_data[surface_name] = return_val end

    return_val = storage.configurable_nukes.icbm_meta_data[surface_name]
    return_val.surface_name = surface_name
    return_val.surface_index = surface.index

    return_val.valid = true

    return icbm_meta_repository.update_icbm_meta_data(optionals.update_data or return_val)
end

function icbm_meta_repository.update_icbm_meta_data(update_data, optionals)
    Log.debug("icbm_meta_repository.update_icbm_meta_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = ICBM_Meta_Data:new()

    if (not game) then return return_val end
    if (not update_data) then return return_val end
    if (not update_data.surface_name or type(update_data.surface_name) ~= "string") then return return_val end

    optionals = optionals or {}

    local surface_name = update_data.surface_name

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[surface_name]) then
        -- If it doesn't exist, generate it
        local icbm_meta_data = icbm_meta_repository.save_icbm_meta_data(surface_name, { update_data = update_data })
        if (not icbm_meta_data or not icbm_meta_data.valid) then
            return return_val
        end
    end

    local icbm_meta_data = storage.configurable_nukes.icbm_meta_data[surface_name]

    for k, v in pairs(update_data) do
        icbm_meta_data[k] = v
    end

    icbm_meta_data.updated = game.tick

    -- Don't think this is necessary, but oh well
    storage.configurable_nukes.icbm_meta_data[surface_name] = icbm_meta_data

    return icbm_meta_data
end

function icbm_meta_repository.delete_icbm_meta_data(surface_name, optionals)
    Log.debug("icbm_meta_repository.delete_icbm_meta_data")
    Log.info(surface_name)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (not surface_name or type(surface_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (storage.configurable_nukes.icbm_meta_data[surface_name] ~= nil) then
        storage.configurable_nukes.icbm_meta_data[surface_name] = nil
    end
    return_val = true

    return return_val
end

function icbm_meta_repository.get_icbm_meta_data(surface_name, optionals)
    Log.debug("icbm_meta_repository.get_icbm_meta_data")
    Log.info(surface_name)
    Log.info(optionals)

    local return_val = ICBM_Meta_Data:new()

    if (not game) then return return_val end
    if (not surface_name or type(surface_name) ~= "string") then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[surface_name]) then
        -- If it doesn't exist, generate it
        local icbm_meta_data = icbm_meta_repository.save_icbm_meta_data(surface_name)
        if (not icbm_meta_data or not icbm_meta_data.valid) then
            return return_val
        end
    end

    return storage.configurable_nukes.icbm_meta_data[surface_name]
end

function icbm_meta_repository.get_all_icbm_meta_data(optionals)
    Log.debug("icbm_meta_repository.get_all_icbm_meta_data")
    Log.info(optionals)

    local return_val = {}

    if (not game) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end

    return storage.configurable_nukes.icbm_meta_data
end

icbm_meta_repository.configurable_nukes = true

local _icbm_meta_repository = icbm_meta_repository

return icbm_meta_repository
