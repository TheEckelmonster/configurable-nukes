-- If already defined, return
if _configurable_nukes_controller and _configurable_nukes_controller.configurable_nukes then
    return _configurable_nukes_controller
end

local Constants = require("scripts.constants.constants")
local Guidance_Service = require("scripts.services.guidance-service")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
local Version_Validations = require("scripts.validations.version-validations")

-- NUCLEAR_AMMO_CATEGORY
local get_nuclear_ammo_category = function ()
    local setting = false

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name].value
    end

    return setting
end

local configurable_nukes_controller = {}

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick = nil

configurable_nukes_controller.initialized =     storage
                                            and storage.configurable_nukes_controller
                                            and storage.configurable_nukes_controller.initialized
                                        or false

configurable_nukes_controller.reinitialized = false

configurable_nukes_controller.checked_research = false

function configurable_nukes_controller.do_tick(event)
    local tick = event.tick
    -- local nth_tick = Settings_Service.get_nth_tick()
    local nth_tick = configurable_nukes_controller.nth_tick or 4
    local tick_modulo = tick % nth_tick

    if (tick_modulo ~= 0) then return end

    -- Check/validate the storage version
    if (not configurable_nukes_controller.initialized) then
        -- Previously initialized?
        if (storage and (not storage.configurable_nukes_controller or not storage.configurable_nukes_controller.initialized)) then
            Initialization.init()
            configurable_nukes_controller.reinitialized = true
        end
        configurable_nukes_controller.initialized = true
        return
    else
        if (not Version_Validations.validate_version()) then
            Initialization.reinit()
            configurable_nukes_controller.reinitialized = true
            return
        end
    end

    if (not configurable_nukes_controller.checked_research) then
        if (game.forces["player"].technologies["nuclear-damage"]) then
            game.forces["player"].technologies["nuclear-damage"].enabled = get_nuclear_ammo_category()
        end
        configurable_nukes_controller.checked_research = true
    end

    if (not Constants.planets_dictionary or configurable_nukes_controller.reinitialized) then Constants.get_planets(true) end
    configurable_nukes_controller.planet_index, configurable_nukes_controller.planet = next(Constants.planets_dictionary, configurable_nukes_controller.planet_index)

    local planet = configurable_nukes_controller.planet

    if (not planet or not configurable_nukes_controller.planet_index) then return end
    if (not planet.surface or not planet.surface.valid) then return end
    local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(planet.surface.name)
    if (not icbm_meta_data or not icbm_meta_data.valid) then return end

    for k, v in pairs(icbm_meta_data.in_transit) do
        if (v and v.tick_to_target and game.tick >= v.tick_to_target) then
            if (ICBM_Utils.payload_arrived({ icbm = k, surface = planet.surface })) then
                icbm_meta_data.in_transit[k] = nil
            else
                -- log(serpent.block(storage))
                -- error("Payload failed to arrive successfully")
            end
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 and not v.one) then
            if (k and k.force and k.force.valid) then
                k.force.print({ "configurable-nukes-controller.seconds-to-target", 1 })
            end
            v.one, v.two, v.three, v.five = true, true, true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 120 and not v.two) then
            if (k and k.force and k.force.valid) then
                k.force.print({ "configurable-nukes-controller.seconds-to-target", 2 })
            end
            v.two, v.three, v.five = true, true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 180 and not v.three) then
            if (k and k.force and k.force.valid) then
                k.force.print({ "configurable-nukes-controller.seconds-to-target", 3 })
            end
            v.three, v.five = true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 300 and not v.five) then
            if (k and k.force and k.force.valid) then
                k.force.print({ "configurable-nukes-controller.seconds-to-target-gps", 5, k.target_position.x, k.target_position.y, k.surface_name })
            end
            v.five = true
        end
    end

    configurable_nukes_controller.nth_tick = nth_tick

    storage.configurable_nukes_controller = {
        planet_index = configurable_nukes_controller.planet_index,
        planet = configurable_nukes_controller.planet,
        nth_tick = nth_tick,
        initialized = true,
        reinitialized = false,
    }
end

function configurable_nukes_controller.research_finished(event)
    Log.debug("configurable_nukes_controller.research_finished")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.research or not event.research.valid or type(event.research) ~= "userdata") then return end

    local research = event.research
    if (not string.find(research.name, "ICBM-guidance-systems-", 1, true)) then return end

    if (event.by_script == nil or type(event.by_script) ~= "boolean") then return end
    if (not event.name or event.name ~= defines.events.on_research_finished) then return end
    if (not event.tick or type(event.tick) ~= "number" or event.tick < 0) then return end

    Guidance_Service.research_finished(event)
end

configurable_nukes_controller.configurable_nukes = true

local _configurable_nukes_controller = configurable_nukes_controller

return configurable_nukes_controller
