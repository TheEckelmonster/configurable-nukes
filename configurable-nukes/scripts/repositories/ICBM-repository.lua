-- If already defined, return
if _icbm_repository and _icbm_repository.configurable_nukes then
    return _icbm_repository
end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Log = require("libs.log.log")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")

local icbm_repository = {}

function icbm_repository.save_icbm_data(icbm, optionals)
    Log.debug("icbm_repository.save_icbm_data")
    Log.info(icbm)
    Log.info(optionals)

    local return_val = ICBM_Data:new({ item_number = -1 })

    if (not game) then return return_val end
    if (not icbm or not icbm.valid) then return return_val end
    if (not icbm or type(icbm.type) ~= "string") then return return_val end
    if (not icbm.surface or not icbm.surface.valid) then return return_val end
    if (not icbm.item or type(icbm.item) ~= "table") then return return_val end
    if (not icbm.tick_launched or type(icbm.tick_launched) ~= "number") then return return_val end
    if (not icbm.tick_to_target or type(icbm.tick_to_target) ~= "number") then return return_val end
    if (not icbm.source_silo or not icbm.source_silo.valid) then return return_val end
    if (not icbm.target_position or type(icbm.target_position) ~= "table") then return return_val end
    if (not icbm.cargo_pod or not icbm.cargo_pod.valid) then return return_val end
    if (icbm.player_launched_index == nil or type(icbm.player_launched_index) ~= "number" or icbm.player_launched_index < 0) then return return_val end
    local player = icbm.player_launched_index > 0 and game.get_player(icbm.player_launched_index) or nil
    if (not player or not player.valid or type(player) ~= "userdata") then
        if (icbm.player_launched_index == 0) then
            player = icbm.player_launched_by
        else
            return return_val
        end
    end
    if (icbm.player_launched_by ~= player) then return return_val end

    optionals = optionals or {}

    local planet_name = icbm.surface.name
    if (not planet_name) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not ICBM_Meta_Repository.save_icbm_meta_data(planet_name).valid) then return return_val end
    end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name].icbms) then storage.configurable_nukes.icbm_meta_data[planet_name].icbms = {} end

    local icbms = storage.configurable_nukes.icbm_meta_data[planet_name].icbms

    return_val.type = icbm.type
    return_val.surface = icbm.surface
    return_val.surface_name = icbm.surface.name
    return_val.item_number = icbm.item_number
    return_val.item = icbm.item
    return_val.tick_launched = icbm.tick_launched
    return_val.tick_to_target = icbm.tick_to_target
    return_val.source_silo = icbm.source_silo
    return_val.source_position = icbm.source_silo.position
    return_val.original_target_position = icbm.original_target_position
    return_val.target_position = icbm.target_position
    return_val.target_distance = icbm.target_distance
    return_val.cargo_pod = icbm.cargo_pod
    return_val.cargo_pod_unit_number = icbm.cargo_pod.unit_number
    return_val.force = icbm.force
    return_val.force_index = icbm.force_index
    return_val.player_launched_by = icbm.player_launched_by
    return_val.player_launched_index = icbm.player_launched_index

    return_val.valid = true

    icbms[return_val.item_number] = return_val

    return icbm_repository.update_icbm_data(return_val)
end

function icbm_repository.update_icbm_data(update_data, optionals)
    Log.debug("icbm_repository.update_icbm_data")
    Log.info(update_data)
    Log.info(optionals)

    local return_val = ICBM_Data:new({ item_number = -1 })

    if (not game) then return return_val end
    if (not update_data or not update_data.valid) then return return_val end
    if (not update_data.surface or not update_data.surface.valid) then return return_val end

    optionals = optionals or {}

    local planet_name = update_data.surface.name
    if (not planet_name) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = {} end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not ICBM_Meta_Repository.save_icbm_meta_data(planet_name).valid) then return return_val end
    end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name].icbms) then storage.configurable_nukes.icbm_meta_data[planet_name].icbms = {} end

    local icbms = storage.configurable_nukes.icbm_meta_data[planet_name].icbms

    return_val = icbms[update_data.item_number]

    for k, v in pairs(update_data) do return_val[k] = v end

    return_val.updated = game.tick

    return return_val
end

function icbm_repository.delete_icbm_data_by_item_number(planet_name, item_number, optionals)
    Log.debug("icbm_repository.delete_icbm_data_by_item_number")
    Log.info(planet_name)
    Log.info(item_number)
    Log.info(optionals)

    local return_val = false

    if (not game) then return return_val end
    if (not planet_name) then return return_val end
    if (not item_number) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not ICBM_Meta_Repository.save_icbm_meta_data(planet_name).valid) then return return_val end
    end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name].icbms) then storage.configurable_nukes.icbm_meta_data[planet_name].icbms = {} end

    local icbms = storage.configurable_nukes.icbm_meta_data[planet_name].icbms

    return_val = icbms[item_number]
    icbms[item_number] = nil

    return return_val
end

function icbm_repository.get_icbm_data(planet_name, item_number, optionals)
    Log.debug("icbm_repository.get_icbm_data")
    Log.info(planet_name)
    Log.info(item_number)
    Log.info(optionals)
    log("icbm_repository.get_icbm_data")

    local return_val = ICBM_Data:new({ item_number = -1 })

    if (not game) then return return_val end
    if (not planet_name) then return return_val end
    if (not item_number) then return return_val end

    optionals = optionals or {}

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        if (not ICBM_Meta_Repository.save_icbm_meta_data(planet_name).valid) then return return_val end
    end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name].icbms) then storage.configurable_nukes.icbm_meta_data[planet_name].icbms = {} end

    local icbms = storage.configurable_nukes.icbm_meta_data[planet_name].icbms

    return icbms[item_number]
end

icbm_repository.configurable_nukes = true

local _icbm_repository = icbm_repository

return icbm_repository
