local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
local Spaceship_Data = require("scripts.data.space.spaceship-data")
local String_Utils = require("scripts.utils.string-utils")

local planet_service = {}

function planet_service.on_surface_created(event)
    Log.debug("planet_service.on_surface_created")
    Log.info(event)

    if (not game) then return end
    if (not event) then return end
    if (not event.surface_index or event.surface_index < 1) then return end

    local surface = game.get_surface(event.surface_index)
    if (not surface or not surface.valid) then return end

    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    if (not se_active) then
        --[[ TODO: Implement and then refernce here an update rather than full reindex ]]
        Constants.get_planets(true)
    else
        Log.debug("space exploration is active")
        if (not String_Utils.find_invalid_substrings(surface.name)) then
            Log.debug("found valid surface name")
            Log.info(surface)
            --[[ This doesn't/didn't work for some reason ]]
            -- local zone = remote.call("space-exploration", "get_zone_from_surface_index", { surface_index = surface.index })
            local zone_name = surface.name:lower()
            local is_spaceship_surface = zone_name:find("spaceship-", 1, true) == 1
            if (not Constants.space_exploration_dictionary[zone_name]) then Constants.get_space_exploration_universe(true) end
            local value = Constants.space_exploration_dictionary[zone_name]
            if (not value and is_spaceship_surface) then
                local spaceship_data = Spaceship_Data:new({
                    name = zone_name,
                })

                Log.warn(spaceship_data)

                value = spaceship_data
            elseif (not value) then
                return -1
            end
            Log.warn(value)

            value.surface = surface
            value.surface_index = surface and surface.valid and surface.index
            if (is_spaceship_surface) then
                Constants["space-exploration"].spaceships[value.name] = value
                if (not storage.constants) then storage.constants = {} end
                if (not storage.constants["space-exploration"]) then storage.constants["space-exploration"] = {} end
                if (not storage.constants["space-exploration"].spaceships) then storage.constants["space-exploration"].spaceships = {} end
                Constants["space-exploration"].spaceships[value.name] = value
                storage.constants["space-exploration"].spaceships = Constants["space-exploration"].spaceships
            else
                if (not storage.constants) then storage.constants = {} end
                if (not storage.constants["space-exploration"]) then storage.constants["space-exploration"] = {} end
                if (not storage.constants["space-exploration"].surfaces) then storage.constants["space-exploration"].surfaces = {} end
                Constants["space-exploration"].surfaces[value.name] = value
                storage.constants["space-exploration"].surfaces = Constants["space-exploration"].surfaces
            end

        end
    end

    Log.debug(space_location)
end

function planet_service.on_pre_surface_deleted(event)
    Log.debug("planet_service.on_surface_deleted")
    Log.info(event)

    if (not game) then return end
    if (not event) then return end
    if (not event.surface_index or event.surface_index < 1) then return end

    local surface = game.get_surface(event.surface_index)
    if (not surface or not surface.valid) then return end

    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    local configurable_nukes_data = Configurable_Nukes_Repository.get_configurable_nukes_data()
    --[[ Retrieving the old values, just in case they are needed for anything prior to, or after surface deletion ]]
    -- local icbm_meta_data = configurable_nukes_data.icbm_meta_data[surface.name]
    -- local rocket_silo_meta_data = configurable_nukes_data.rocket_silo_meta_data[surface.name]
    configurable_nukes_data.icbm_meta_data[surface.name] = nil
    configurable_nukes_data.rocket_silo_meta_data[surface.name] = nil

    if (not se_active) then
        --[[ TODO: Anything? ]]
        -- Constants.get_planets(true)
    else
        Log.debug("space exploration is active")
        if (not String_Utils.find_invalid_substrings(surface.name)) then
            Log.debug("found valid surface name")
            Log.info(surface)
            local zone_name = surface.name:lower()
            local is_spaceship_surface = zone_name:find("spaceship-", 1, true) == 1
            if (not Constants.space_exploration_dictionary[zone_name]) then return end
            local value = Constants.space_exploration_dictionary[zone_name]
            if (not value and is_spaceship_surface) then
                local spaceship_data = Spaceship_Data:new({
                    name = zone_name,
                })

                Log.warn(spaceship_data)

                value = spaceship_data
            elseif (not value) then
                return -1
            end
            Log.warn(value)

            if (is_spaceship_surface) then
                Constants["space-exploration"].spaceships[value.name] = nil
                if (not storage.constants) then storage.constants = {} end
                if (not storage.constants["space-exploration"]) then storage.constants["space-exploration"] = {} end
                if (not storage.constants["space-exploration"].spaceships) then storage.constants["space-exploration"].spaceships = {} end
                Constants["space-exploration"].spaceships[value.name] = nil
                storage.constants["space-exploration"].spaceships = Constants["space-exploration"].spaceships
            else
                if (not storage.constants) then storage.constants = {} end
                if (not storage.constants["space-exploration"]) then storage.constants["space-exploration"] = {} end
                if (not storage.constants["space-exploration"].surfaces) then storage.constants["space-exploration"].surfaces = {} end
                Constants["space-exploration"].surfaces[value.name] = nil
                storage.constants["space-exploration"].surfaces = Constants["space-exploration"].surfaces
            end
        end
    end

    Log.debug(space_location)
end

return planet_service
