-- If already defined, return
if _initialization and _initialization.configurable_nukes then
    return _initialization
end

local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
local Constants = require("scripts.constants.constants")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local Log = require("libs.log.log")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local String_Utils = require("scripts.utils.string-utils")
local Version_Service = require("scripts.services.version-service")

local locals = {}

local initialization = {}

initialization.last_version_result = nil


function initialization.init()
    log("Initializing Configurable Nukes")
    Log.debug("Initializing Configurable Nukes")

    return locals.initialize(true) -- from_scratch
end

function initialization.reinit()
    log("Reinitializing Configurable Nukes")
    Log.debug("Reinitializing Configurable Nukes")

    return locals.initialize(false) -- as is
end

function locals.initialize(from_scratch, maintain_data)
    Log.debug("initialize")
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
        log("configurable-nukes: Initializing anew")
        if (game) then game.print("configurable-nukes: Initializing anew") end

        local _storage = storage
        _storage.storage_old = nil

        storage = {}
        configurable_nukes_data = Configurable_Nukes_Data:new()
        storage.configurable_nukes = configurable_nukes_data

        storage.storage_old = _storage

        -- do migrations
        locals.migrate(maintain_data)

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

    if (storage and storage.configurable_nukes) then
        storage.configurable_nukes.do_nth_tick = true
    end

    storage.configurable_nukes.valid = true

    if (from_scratch) then log("configurable-nukes: Initialization complete") end
    if (from_scratch and game) then game.print("configurable-nukes: Initialization complete") end
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

function locals.migrate(maintain_data)
    Log.debug("migrate")
    Log.info(maintain_data)

    local storage_old = storage.storage_old
    if (not storage_old) then return end
    if (not type(storage_old) == "table") then return end

    if (storage_old.configurable_nukes) then
        Constants.get_planets(true)
        if (storage_old.configurable_nukes.icbm_meta_data) then
            for k, v in pairs(storage_old.configurable_nukes.icbm_meta_data) do
                if (Constants.planets_dictionary[k]) then
                    ICBM_Meta_Repository.update_icbm_meta_data(v)
                    storage_old.configurable_nukes.icbm_meta_data[k] = nil
                end
            end
        end
        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
            for k, v in pairs(storage_old.configurable_nukes.rocket_silo_meta_data) do
                if (Constants.planets_dictionary[k]) then
                    Rocket_Silo_Meta_Repository.update_rocket_silo_meta_data(v)
                    storage_old.configurable_nukes.rocket_silo_meta_data[k] = nil
                end
            end
        end
    end
end

initialization.configurable_nukes = true

local _initialization = initialization

return initialization
