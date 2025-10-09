-- If already defined, return
if _initialization and _initialization.configurable_nukes then
    return _initialization
end

local Util = require("__core__.lualib.util")

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
local Constants = require("scripts.constants.constants")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local Log = require("libs.log.log")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local String_Utils = require("scripts.utils.string-utils")
local Version_Service = require("scripts.services.version-service")

local locals = {}

local initialization = {}

initialization.last_version_result = nil

function initialization.init(data)
    log({ "initialization.init" })
    Log.debug("initialization.init")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true
    else data.maintain_data = false
    end

    return locals.initialize(true, data.maintain_data) -- from_scratch
end

function initialization.reinit(data)
    log({ "initialization.reinit" })
    Log.debug("initialization.reinit")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true
    else data.maintain_data = false
    end

    return locals.initialize(false, data.maintain_data) -- as is
end

function locals.initialize(from_scratch, maintain_data)
    Log.debug("locals.initialize")
    Log.info(from_scratch)
    Log.info(maintain_data)

    local configurable_nukes_data = Configurable_Nukes_Repository.get_configurable_nukes_data()
    Log.info(configurable_nukes_data)

    configurable_nukes_data.do_nth_tick = false

    from_scratch = from_scratch or false
    maintain_data = maintain_data or false

    if (not from_scratch) then
        -- Version check
        local version_data = configurable_nukes_data.version_data
        if (version_data and not version_data.valid) then
            local version = initialization.last_version_result
            if (not version) then goto initialize end
            if (not version.major or not version.minor or not version.bug_fix) then goto initialize end
            if (not version.major.valid) then goto initialize end
            if (not version.minor.valid or not version.bug_fix.valid) then
                return locals.initialize(true, true)
            end

            ::initialize::
            return locals.initialize(true)
        else
            local version = Version_Service.validate_version()
            initialization.last_version_result = version
            if (not version or not version.valid) then
                version_data.valid = false
                return configurable_nukes_data
            end
        end
    end

    -- Configurable Nukes
    if (from_scratch) then
        log({ "initialization.initialization-anew", Constants.mod_name })
        if (game) then game.print({ "initialization.initialization-anew", Constants.mod_name }) end

        local _storage = storage
        _storage.storage_old = nil

        storage = {}
        configurable_nukes_data = Configurable_Nukes_Data:new()
        storage.configurable_nukes = configurable_nukes_data

        storage.storage_old = _storage

        -- do migrations
        locals.migrate({ maintain_data = maintain_data, new_version_data = configurable_nukes_data.version_data })

        local version_data = configurable_nukes_data.version_data
        version_data.valid = true
    else
        if (not configurable_nukes_data) then
            storage.configurable_nukes = Configurable_Nukes_Data:new()
            configurable_nukes_data = storage.configurable_nukes
        end
        if (not configurable_nukes_data.icbm_meta_data) then configurable_nukes_data.icbm_meta_data = {} end
        if (not configurable_nukes_data.rocket_silo_meta_data) then configurable_nukes_data.rocket_silo_meta_data = {} end
    end

    -- Planet/rocket-silo data
    local planets = Constants.get_planets(true)
    for k, planet in pairs(planets) do
        -- Search for planets
        if (planet and not String_Utils.find_invalid_substrings(planet.name)) then
            if (from_scratch or not configurable_nukes_data.rocket_silo_meta_data[planet.name]) then
                if (not maintain_data) then
                    Rocket_Silo_Meta_Repository.save_rocket_silo_meta_data(planet.name)
                else
                    Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(planet.name)
                end
            end

            local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(planet.name)

            if (not rocket_silo_meta_data.planet_name) then rocket_silo_meta_data.planet_name = planet.name end

            if (planet.surface) then
                local rocket_silos = planet.surface.find_entities_filtered({ type = "rocket-silo" })
                for i = 1, #rocket_silos do
                    local rocket_silo = rocket_silos[i]
                    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
                        locals.add_rocket_silo(rocket_silo_meta_data, rocket_silo)
                    end
                end
            end
        end
    end

    for name, surface in pairs(game.surfaces) do
        Log.warn(name)
        Log.debug(surface)
        Log.debug(surface.name)
        Log.debug(surface.valid)
        -- Search through all available surfaces for rocket-silos
        if (surface and not String_Utils.find_invalid_substrings(surface.name)) then
            local surface_name = surface.name:lower()
            if (from_scratch or not configurable_nukes_data.rocket_silo_meta_data[surface_name]) then
                if (not maintain_data) then
                    Rocket_Silo_Meta_Repository.save_rocket_silo_meta_data(surface_name)
                else
                    Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(surface_name)
                end
            end

            local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(surface_name)
            Log.debug(rocket_silo_meta_data)
            if (not rocket_silo_meta_data.surface_name) then rocket_silo_meta_data.surface_name = surface_name end

            local rocket_silos = surface.find_entities_filtered({ type = "rocket-silo" })
            for i = 1, #rocket_silos do
                local rocket_silo = rocket_silos[i]
                if (rocket_silo and rocket_silo.valid and rocket_silo.surface and (rocket_silo.name == "rocket-silo" or "ipbm-rocket-silo")) then
                    locals.add_rocket_silo(rocket_silo_meta_data, rocket_silo)
                end
            end
        end
    end

    if (script and script.active_mods["space-exploration"]) then
        locals.process_space_exploration_universe()
        script.on_event(remote.call("space-exploration", "get_on_zone_surface_created_event"), Planet_Controller.on_surface_created)
    end

    if (storage and storage.configurable_nukes) then
        storage.configurable_nukes.do_nth_tick = true
    end

    storage.configurable_nukes.valid = true

    if (from_scratch) then log({ "initialization.initialization-complete", Constants.mod_name }) end
    if (from_scratch and game) then game.print({ "initialization.initialization-complete", Constants.mod_name }) end
    Log.info(storage)

    return configurable_nukes_data
end

function locals.add_rocket_silo(rocket_silo_meta_data, rocket_silo)
    Log.debug("add_rocket_silo")
    Log.info(rocket_silo_meta_data)
    Log.info(rocket_silo)

    if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface) then
        Log.warn("Call to add_rocket_silo with invalid input")
        Log.debug(rocket_silo)
        return
    end

    Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function locals.migrate(data)
    Log.debug("migrate")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.maintain_data) then return end
    if (not data.new_version_data) then
        if (storage.configurable_nukes and storage.configurable_nukes.version_data) then
            data.new_version_data = storage.configurable_nukes.version_data
        else
            return
        end
    end

    local storage_old = storage.storage_old
    if (not storage_old) then return end
    if (not type(storage_old) == "table") then return end

    if (storage_old.configurable_nukes) then
        local migration_start_message_printed = false
        if (storage_old.configurable_nukes.version_data and storage_old.configurable_nukes.version_data.created) then
            if (storage_old.configurable_nukes.version_data.created > 0) then
                Log.debug(storage_old.configurable_nukes.version_data)
                Log.debug(Constants.mod_name .. ": Migrating existing data")
                game.print({ "initialization.migrate-start", Constants.mod_name})
                migration_start_message_printed = true
            end
        end

        if (storage_old.configurable_nukes.version_data) then
            local prev_version_data = storage_old.configurable_nukes.version_data
            local new_version_data = data.new_version_data
            if (prev_version_data.major.value <= 0 and prev_version_data.minor.value <= 4) then
                --[[ Version 0.5.0 changed from using "planet_name" to using "space_location_name" ]]
                if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 5) then
                    if (storage_old.configurable_nukes.rocket_silo_meta_data) then
                        local all_rocket_silo_meta_data = storage_old.configurable_nukes.rocket_silo_meta_data
                        for k, v in pairs(all_rocket_silo_meta_data) do
                            if (v.planet_name) then
                                v.space_location_name = v.planet_name
                                --[[
                                    I think, by not setting the previous value of v.planet_name to nil,
                                    that ?should? maintain backwards compatability if someone were to
                                    downgrade, rather than only upgrade
                                    Really not sure on this; need to test, but not highest priority.
                                    TODO: See above
                                ]]
                            end
                        end
                    end
                end
            end
        end

        local se_active = script and script.active_mods and script.active_mods["space-exploration"]
        local dictionary =     not se_active and Constants.get_planets(true) and Constants.planets_dictionary
                            or Constants.get_space_exploration_universe(true) and Constants.space_exploration_dictionary

        if (Log.get_log_level().level.num_val <= 2) then
            log(serpent.block(dictionary))
        end

        if (storage_old.configurable_nukes.icbm_meta_data) then
            for k, v in pairs(storage_old.configurable_nukes.icbm_meta_data) do
                if (dictionary[k]) then
                    ICBM_Meta_Repository.update_icbm_meta_data(v)
                    storage_old.configurable_nukes.icbm_meta_data[k] = nil
                end
            end
        end

        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
            for k, v in pairs(storage_old.configurable_nukes.rocket_silo_meta_data) do
                if (dictionary[k]) then
                    if (not v.signals) then v.signals = {} end

                    v.signals.launch = Util.table.deepcopy(Rocket_Silo_Data.signals.launch)
                    v.signals.x = Util.table.deepcopy(Rocket_Silo_Data.signals.x)
                    v.signals.y = Util.table.deepcopy(Rocket_Silo_Data.signals.y)
                    v.signals.origin_override = Util.table.deepcopy(Rocket_Silo_Data.signals.origin_override)

                    Rocket_Silo_Meta_Repository.update_rocket_silo_meta_data(v)

                    storage_old.configurable_nukes.rocket_silo_meta_data[k] = nil
                end
            end
        end

        if (storage_old.icbm_data) then
            storage.icbm_data = storage_old.icbm_data
            storage_old.icbm_data = nil
        end

        if (migration_start_message_printed) then
            Log.debug(Constants.mod_name .. ": Migration complete")
            game.print({ "initialization.migrate-finish", Constants.mod_name})
        end
    end
end

function locals.process_space_exploration_universe(data)
    Log.debug("locals.process_space_exploration_universe")
    Log.info(data)

    if (not storage.constants) then storage.constants = {} end
    storage.constants.mod_data = Constants.get_mod_data(true)
end

initialization.configurable_nukes = true

local _initialization = initialization

return initialization
