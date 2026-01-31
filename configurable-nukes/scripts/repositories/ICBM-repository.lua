local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")

local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local icbm_repository = {}

function icbm_repository.save_icbm_data(icbm, optionals)
    Log.debug("icbm_repository.save_icbm_data")
    Log.info(icbm)
    Log.info(optionals)

    local return_val = ICBM_Data:new({ item_number = -1 })

    if (not game) then return return_val end
    if (not icbm or not icbm.valid) then return return_val end
    if ((not icbm.item_name or type(icbm.item_name) ~= "string") and (not icbm.items or type(icbm.items) ~= "table")) then return return_val end
    if (not icbm.cargo or type(icbm.cargo) ~= "table") then icbm.cargo = {} end
    if (not icbm.cargo_dictionary or type(icbm.cargo_dictionary) ~= "table") then icbm.cargo_dictionary = {} end
    if (icbm.total_payload_items == nil or type(icbm.total_payload_items) ~= "number") then icbm.total_payload_items = Constants.BIG_INTEGER end
    if (not icbm.surface or not icbm.surface.valid) then return return_val end
    if ((not icbm.item and not icbm.items) or (type(icbm.item) ~= "table" and type(icbm.items) ~= "table")) then return return_val end
    if (not icbm.tick_launched or type(icbm.tick_launched) ~= "number") then return return_val end
    if (not icbm.tick_to_target or type(icbm.tick_to_target) ~= "number") then return return_val end
    if (not icbm.same_surface or type(icbm.same_surface) ~= "boolean") then icbm.same_surface = false end
    if (not icbm.source_silo or not icbm.source_silo.valid) then return return_val end
    if (not icbm.silo_type or not type(icbm.silo_type) == "string") then icbm.silo_type = icbm.source_silo.name end
    if (not icbm.target_position or type(icbm.target_position) ~= "table") then return return_val end
    if (not icbm.target_surface or not icbm.target_surface.valid or type(icbm.target_surface) ~= "userdata") then return return_val end
    if (not icbm.cargo_pod or not icbm.cargo_pod.valid) then return return_val end
    if (not icbm.circuit_launch or type(icbm.circuit_launch) ~= "boolean") then icbm.circuit_launch = false end
    if (icbm.player_launched_index == nil or type(icbm.player_launched_index) ~= "number" or icbm.player_launched_index < 0) then return return_val end
    local player = icbm.player_launched_index > 0 and game.get_player(icbm.player_launched_index) or nil
    if (not player or not player.valid or type(player) ~= "userdata") then
        if (icbm.player_launched_index ~= 0) then return return_val end
    end
    if (icbm.player_launched_by ~= player and not icbm.circuit_launch) then return return_val end
    if (not icbm.launched_from or type(icbm.launched_from) ~= "string") then return return_val end
    if (icbm.launched_from_space == nil or type(icbm.launched_from_space) ~= "boolean") then icbm.launched_from_space = false end
    if (icbm.base_target_distance == nil or type(icbm.base_target_distance) ~= "number") then icbm.base_target_distance = false end
    if (icbm.speed == nil or type(icbm.speed) ~= "number") then icbm.speed = 0 end
    if (icbm.is_travelling == nil or type(icbm.is_travelling) ~= "boolean") then icbm.is_travelling = false end
    if (icbm.space_origin_pos ~= nil and (type(icbm.space_origin_pos) ~= "table" or not icbm.space_origin_pos.x or type(icbm.space_origin_pos.x) ~= "number" or not icbm.space_origin_pos.y or type(icbm.space_origin_pos.y) ~= "number")) then return return_val end
    if (icbm.se_active and (icbm.source_system == nil or type(icbm.source_system) ~= "string")) then
        if (not Constants.space_exploration_dictionary[icbm.surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
        local space_location = Constants.space_exploration_dictionary[icbm.surface.name:lower()]

        if (not space_location) then return return_val end

        local parent_system_name = space_location:get_stellar_system()
        icbm.source_system = parent_system_name
        if (icbm.source_system == nil or type(icbm.source_system) ~= "string") then return return_val end

        -- if (not Constants.space_exploration_dictionary[parent_system_name]) then Constants.get_space_exploration_universe(true) end
        -- local parent_system = Constants.space_exploration_dictionary[parent_system_name]

        -- if (not parent_system) then return return_val end

        -- icbm.source_system = parent_system
        -- if (icbm.source_system == nil or type(icbm.source_system) ~= "table") then return return_val end
    end
    if (icbm.se_active and (icbm.target_system == nil or type(icbm.target_system) ~= "string")) then
        if (not Constants.space_exploration_dictionary[icbm.surface.name:lower()]) then Constants.get_space_exploration_universe(true) end
        local space_location = Constants.space_exploration_dictionary[icbm.target_surface.name:lower()]

        if (not space_location) then return return_val end

        local parent_system_name = space_location:get_stellar_system()
        icbm.target_system = parent_system_name
        if (icbm.target_system == nil or type(icbm.target_system) ~= "string") then return return_val end

        -- if (not Constants.space_exploration_dictionary[parent_system_name]) then Constants.get_space_exploration_universe(true) end
        -- local parent_system = Constants.space_exploration_dictionary[parent_system_name]

        -- if (not parent_system) then return return_val end

        -- icbm.target_system = parent_system
        -- if (icbm.target_system == nil or type(icbm.target_system) ~= "table") then return return_val end
    end

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

    return_val.item_name = icbm.item_name
    return_val.type = ICBM_Data.type
    return_val.surface = icbm.surface
    return_val.surface_name = icbm.surface.name
    return_val.item_number = icbm.item_number
    return_val.item = icbm.item
    return_val.items = icbm.items
    return_val.cargo = icbm.cargo
    return_val.cargo_dictionary = icbm.cargo_dictionary
    return_val.total_payload_items = icbm.total_payload_items
    return_val.tick_launched = icbm.tick_launched
    return_val.tick_to_target = icbm.tick_to_target
    return_val.same_surface = icbm.same_surface
    return_val.source_silo = icbm.source_silo
    return_val.silo_type = icbm.silo_type
    return_val.source_position = icbm.source_silo.position
    -- return_val.source_system = icbm.source_system
    return_val.original_target_position = icbm.original_target_position
    return_val.target_position = icbm.target_position
    return_val.target_distance = icbm.target_distance
    return_val.target_surface = icbm.target_surface
    return_val.target_surface_name = icbm.target_surface.name
    return_val.target_surface_index = icbm.target_surface.index
    -- return_val.target_system = icbm.target_system
    return_val.cargo_pod = icbm.cargo_pod
    return_val.cargo_pod_unit_number = icbm.cargo_pod.unit_number
    return_val.force = icbm.force
    return_val.force_index = icbm.force_index
    return_val.circuit_launch = icbm.circuit_launch
    return_val.player_launched_by = icbm.player_launched_by
    return_val.player_launched_index = icbm.player_launched_index
    return_val.launched_from = icbm.launched_from
    return_val.launched_from_space = icbm.launched_from_space
    return_val.base_target_distance = icbm.base_target_distance
    return_val.speed = icbm.speed
    return_val.is_travelling = icbm.is_travelling
    return_val.space_origin_pos = icbm.space_origin_pos

    return_val.valid = true

    icbms[return_val.item_number] = return_val

    local item_numbers = ICBM_Data:get_item_numbers()
    if (item_numbers) then item_numbers.set(return_val.item_number) end

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
    if (update_data.item_number == nil or type(update_data.item_number) ~= "number") then return return_val end

    optionals = optionals or {}

    local planet_name = update_data.surface.name
    if (not planet_name) then return return_val end

    if (not storage) then return return_val end
    if (not storage.configurable_nukes) then storage.configurable_nukes = Configurable_Nukes_Data:new() end
    if (not storage.configurable_nukes.icbm_meta_data) then storage.configurable_nukes.icbm_meta_data = {} end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name]) then
        -- If it doesn't exist, generate it
        local icbm_meta_data = ICBM_Meta_Repository.save_icbm_meta_data(planet_name)
        if (not icbm_meta_data or not icbm_meta_data.valid) then
            return return_val
        end
    end
    if (not storage.configurable_nukes.icbm_meta_data[planet_name].icbms) then storage.configurable_nukes.icbm_meta_data[planet_name].icbms = {} end

    local icbms = storage.configurable_nukes.icbm_meta_data[planet_name].icbms

    return_val = icbms[update_data.item_number] or {}

    for k, v in pairs(update_data) do return_val[k] = v end

    return_val.updated = game.tick

    icbms[update_data.item_number] = return_val

    local item_numbers = ICBM_Data:get_item_numbers()
    if (not item_numbers.get(return_val.item_number)) then item_numbers.set(return_val.item_number) end

    ICBM_Data.validate_fields(return_val)

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

    local item_numbers = ICBM_Data:get_item_numbers()
    item_numbers.remove(item_number)

    return return_val
end

function icbm_repository.get_icbm_data(planet_name, item_number, optionals)
    Log.debug("icbm_repository.get_icbm_data")
    Log.info(planet_name)
    Log.info(item_number)
    Log.info(optionals)

    local return_val = ICBM_Data:new({ item_number = -1 })

    if (not game) then return return_val end
    if (not planet_name or type(planet_name) ~= "string") then return return_val end
    if (not item_number) then return return_val end

    if (optionals and type(optionals) ~= "table") then optionals = {} end
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

    if (optionals.validate_fields) then ICBM_Data.validate_fields(return_val) end

    return return_val
end

return icbm_repository
