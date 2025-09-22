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
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
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
-- ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN
local get_allow_targeting_origin = function ()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name].value
    end

    return setting
end
-- PRINT_DELIVERY_MESSAGES
local get_print_delivery_messages = function()
    local setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.default_value

    log(serpent.block(setting))

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name].value
    end

    log(serpent.block(setting))

    return setting
end
-- ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES
local get_icbm_circuit_print_delivery_messages = function()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name].value
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

    if (not Constants.planets_dictionary or configurable_nukes_controller.reinitialized) then
        Constants.get_planets(true)
        configurable_nukes_controller.reinitialized = false
    end
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
            local print_message = function ()
                if (k and k.force and k.force.valid) then
                    k.force.print({ "configurable-nukes-controller.seconds-to-target", 1 })
                end
            end

            if (k.player_launched_index == 0) then
                if (get_icbm_circuit_print_delivery_messages()) then
                    print_message()
                end
            else
                if (get_print_delivery_messages()) then
                    print_message()
                end
            end
            v.one, v.two, v.three, v.five = true, true, true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 120 and not v.two) then
            local print_message = function ()
                if (k and k.force and k.force.valid) then
                    k.force.print({ "configurable-nukes-controller.seconds-to-target", 2 })
                end
            end

            if (k.player_launched_index == 0) then
                if (get_icbm_circuit_print_delivery_messages()) then
                    print_message()
                end
            else
                if (get_print_delivery_messages()) then
                    print_message()
                end
            end
            v.two, v.three, v.five = true, true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 180 and not v.three) then
            local print_message = function ()
                if (k and k.force and k.force.valid) then
                    k.force.print({ "configurable-nukes-controller.seconds-to-target", 3 })
                end
            end

            if (k.player_launched_index == 0) then
                if (get_icbm_circuit_print_delivery_messages()) then
                    print_message()
                end
            else
                if (get_print_delivery_messages()) then
                    print_message()
                end
            end
            v.three, v.five = true, true
        elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 300 and not v.five) then
            local print_message = function ()
                if (k and k.force and k.force.valid) then
                    k.force.print({ "configurable-nukes-controller.seconds-to-target-gps", 5, k.target_position.x, k.target_position.y, k.surface_name })
                end
            end

            if (k.player_launched_index == 0) then
                if (get_icbm_circuit_print_delivery_messages()) then
                    print_message()
                end
            else
                if (get_print_delivery_messages()) then
                    print_message()
                end
            end
            v.five = true
        end
    end

    local rocket_silo_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(planet.surface.name)

    for k, v in pairs(rocket_silo_data.rocket_silos) do
        if (v and v.entity and v.entity.valid) then
            local rocket_silo = v.entity

            local circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_red)
            if (not circuit_network) then circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_green) end
            if (circuit_network and circuit_network.valid and circuit_network.entity and circuit_network.entity.valid) then
                -- Check if the rocket silo has signals different from default
                local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
                if (not rocket_silo_data or not rocket_silo_data.valid) then
                    rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                    if (not rocket_silo_data or not rocket_silo_data.valid) then goto continue end
                end

                -- Look for non-default signals
                -- Use defaults if, for some reason, nothing is defined for the rocket_silo_data
                local signal_x = circuit_network.get_signal(rocket_silo_data.signals.x or Rocket_Silo_Data.signals.x)
                local signal_y = circuit_network.get_signal(rocket_silo_data.signals.y or Rocket_Silo_Data.signals.y)
                local signal_launch = circuit_network.get_signal(rocket_silo_data.signals.launch or Rocket_Silo_Data.signals.launch)
                --[[ Intentionally letting it be nil in the case of either the settings being disabled or not explicitly defined ]]
                local signal_origin_override =  get_allow_targeting_origin()
                                            and rocket_silo_data.signals.origin_override
                                            and circuit_network.get_signal(rocket_silo_data.signals.origin_override)
                                            or nil

                if (signal_x and signal_y and signal_launch) then
                    if (type(signal_x) == "number" and type(signal_y) == "number" and type(signal_launch) == "number") then
                        if (        (signal_launch > 0
                                and (  signal_x ~= 0
                                    or signal_y ~= 0))
                            or
                                   (signal_launch > 0
                                and get_allow_targeting_origin()
                                and type(signal_origin_override) == "number"
                                and signal_origin_override > 0))
                        then
                            local entity = circuit_network.entity

                            Rocket_Silo_Service.launch_rocket({
                                rocket_silo = rocket_silo,
                                tick = game.tick,
                                surface = entity.surface,
                                area = { left_top = { x = signal_x, y = signal_y }, right_bottom = { x = signal_x, y = signal_y }, },
                                --[[ Pretty sure valid player indices start at 1, so 0 should be safe for indicating a circuit launch? ]]
                                player_index = 0,
                                last_user_index = entity.last_user and entity.last_user.index,
                            })
                        end
                    end
                end

                ::continue::
            end
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
