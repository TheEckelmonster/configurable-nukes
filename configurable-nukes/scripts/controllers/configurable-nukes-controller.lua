-- If already defined, return
if _configurable_nukes_controller and _configurable_nukes_controller.configurable_nukes then
    return _configurable_nukes_controller
end

local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local Constants = require("scripts.constants.constants")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Service = require("scripts.services.settings-service")
local String_Utils = require("scripts.utils.string-utils")
local Version_Validations = require("scripts.validations.version-validations")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick = nil

configurable_nukes_controller.initialized =     storage
                                            and storage.configurable_nukes_controller
                                            and storage.configurable_nukes_controller.initialized
                                        or false

configurable_nukes_controller.reinitialized = false

configurable_nukes_controller.checked_research = false

function configurable_nukes_controller.on_tick(event)
    -- Log.debug("configurable_nukes_controller.on_tick")
    -- Log.info(event)

    local tick = event.tick
    --[[ TODO: Impement this ]]
    -- local nth_tick = Settings_Service.get_nth_tick()
    local nth_tick = configurable_nukes_controller.nth_tick or 4
    local tick_modulo = tick % nth_tick

    local sa_active = storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    if (tick_modulo ~= 0) then return end

    -- Check/validate the storage version
    if (not configurable_nukes_controller.initialized) then
        -- Previously initialized?
        if (storage and (not storage.configurable_nukes_controller or not storage.configurable_nukes_controller.initialized)) then
            Initialization.init({ maintain_data = true })
            configurable_nukes_controller.reinitialized = true
            configurable_nukes_controller.reinit_tick = tick
            sa_active = script and script.active_mods and script.active_mods["space-age"]
            se_active = script and script.active_mods and script.active_mods["space-exploration"]

            storage.sa_active = sa_active
            storage.se_active = se_active
        end
        configurable_nukes_controller.initialized = true
        configurable_nukes_controller.init_tick = tick

        if (not storage.constants) then Constants.get_mod_data(true) end

        return
    else
        if (not Version_Validations.validate_version()) then
            Initialization.reinit()
            configurable_nukes_controller.reinitialized = true
            configurable_nukes_controller.init_tick = tick

            if (not storage.constants) then Constants.get_mod_data(true) end

            sa_active = script and script.active_mods and script.active_mods["space-age"]
            se_active = script and script.active_mods and script.active_mods["space-exploration"]

            storage.sa_active = sa_active
            storage.se_active = se_active

            return
        end
    end

    if (configurable_nukes_controller and configurable_nukes_controller.active_mod_check_tick) then
        if (tick - 60 > configurable_nukes_controller.active_mod_check_tick) then
            configurable_nukes_controller.active_mod_check_tick = tick

            sa_active = script and script.active_mods and script.active_mods["space-age"]
            se_active = script and script.active_mods and script.active_mods["space-exploration"]

            storage.sa_active = sa_active
            storage.se_active = se_active
        end
    end

    if ((not se_active and not Constants.planets_dictionary) or configurable_nukes_controller.reinitialized) then
        -- Constants.get_planets(true)
        Constants.get_planets(not Constants.planets_dictionary)
        configurable_nukes_controller.reinitialized = false
    end

    ICBM_Utils.print_space_launched_time_to_target_message()

    local num_surfaces_to_process = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.NUM_SURFACES_PROCESSED_PER_TICK.name, })
    local failure_limit = (num_surfaces_to_process * 4) ^ 0.75 + num_surfaces_to_process / 2
    local i, loops, failures = 0, 0, 0
    while i < num_surfaces_to_process do
        if (not sa_active and se_active and i > 0) then
            break
        end

        if (loops > 2 ^ 11) then break end
        if (failures > failure_limit) then break end
        loops = loops + 1
        if (se_active) then
            configurable_nukes_controller.surface_name, configurable_nukes_controller.surface = next(Constants.get_space_exploration_surfaces(), configurable_nukes_controller.surface_name)
        else
            configurable_nukes_controller.planet_index, configurable_nukes_controller.planet = next(Constants.get_planets(), configurable_nukes_controller.planet_index)
        end

        local space_location = se_active and configurable_nukes_controller.surface or configurable_nukes_controller.planet
        -- Log.debug(space_location and space_location.name)

        if (not space_location or (not configurable_nukes_controller.planet_index and not configurable_nukes_controller.surface_name)) then
            failures = failures + 1
            if (se_active) then
                goto continue
            else
                break
            end
        end
        if (not space_location) then
            --[[ This shouldn't be necessary, but syntax parser is flagging subsequent lines as needing a nil check without this ]]
            failures = failures + 1
            goto continue
        end
        if (not space_location.surface or not space_location.surface.valid) then
            failures = failures + 1
            goto continue
        end
        if (se_active and String_Utils.find_invalid_substrings(space_location.name)) then
            failures = failures + 1
            goto continue
        end
        local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(space_location.surface.name)
        if (not icbm_meta_data or not icbm_meta_data.valid) then
            failures = failures + 1
            goto continue
        end
        i = i + 1

        -- for k, v in pairs(icbm_meta_data.in_transit) do
        --     if (v and v.target_surface and v.target_surface.valid and v.tick_to_target and game.tick >= v.tick_to_target) then
        --         if (    k.target_surface
        --             and k.target_surface.valid
        --             and ICBM_Utils.payload_arrived({ icbm = k, surface = space_location.surface, target_surface = k.target_surface }))
        --         then
        --             icbm_meta_data.in_transit[k] = nil
        --         else
        --             -- log(serpent.block(storage))
        --             -- error("Payload failed to arrive successfully")
        --         end
        --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 1 and not v.one) then
        --         local print_message = function (k, v)
        --             if (k and k.force and k.force.valid) then
        --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 1 })
        --             end
        --         end

        --         if (k.player_launched_index == 0) then
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         else
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         end
        --         v.one, v.two, v.three, v.five = true, true, true, true
        --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 2 and not v.two) then
        --         local print_message = function (k, v)
        --             if (k and k.force and k.force.valid) then
        --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 2 })
        --             end
        --         end

        --         if (k.player_launched_index == 0) then
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         else
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         end
        --         v.two, v.three, v.five = true, true, true
        --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 3 and not v.three) then
        --         local print_message = function (k, v)
        --             if (k and k.force and k.force.valid) then
        --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 3 })
        --             end
        --         end

        --         if (k.player_launched_index == 0) then
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         else
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         end
        --         v.three, v.five = true, true
        --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 5 and not v.five) then
        --         local print_message = function (k, v)
        --             if (k and k.force and k.force.valid and v.target_surface_name) then
        --                 k.force.print({ "configurable-nukes-controller.seconds-to-target-gps", 5, k.target_position.x, k.target_position.y, v.target_surface_name })
        --                 v.five = true
        --             end
        --         end

        --         if (k.player_launched_index == 0) then
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         else
        --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                 print_message(k, v)
        --             end
        --         end
        --         -- v.five = true
        --     end
        -- end

        -- if (space_location.surface.planet and sa_active) then
        --     for _, space_platform in pairs(space_location.surface.planet.get_space_platforms("player")) do
        --         if (not space_platform.surface or not space_platform.surface.valid) then goto continue end
        --         local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(space_platform.surface.name)
        --         if (not icbm_meta_data or not icbm_meta_data.valid) then goto continue end

        --         for k, v in pairs(icbm_meta_data.in_transit) do
        --             if (v and v.target_surface and v.target_surface.valid and v.tick_to_target and game.tick >= v.tick_to_target) then
        --                 if (    k.target_surface
        --                     and k.target_surface.valid
        --                     and ICBM_Utils.payload_arrived({ icbm = k, surface = space_location.surface, target_surface = k.target_surface }))
        --                 then
        --                     icbm_meta_data.in_transit[k] = nil
        --                 else
        --                     -- log(serpent.block(storage))
        --                     -- error("Payload failed to arrive successfully")
        --                 end
        --             elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 and not v.one) then
        --                 local print_message = function (k, v)
        --                     if (k and k.force and k.force.valid) then
        --                         k.force.print({ "configurable-nukes-controller.seconds-to-target", 1 })
        --                     end
        --                 end

        --                 if (k.player_launched_index == 0) then
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 else
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 end
        --                 v.one, v.two, v.three, v.five = true, true, true, true
        --             elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 120 and not v.two) then
        --                 local print_message = function (k, v)
        --                     if (k and k.force and k.force.valid) then
        --                         k.force.print({ "configurable-nukes-controller.seconds-to-target", 2 })
        --                     end
        --                 end

        --                 if (k.player_launched_index == 0) then
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 else
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 end
        --                 v.two, v.three, v.five = true, true, true
        --             elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 180 and not v.three) then
        --                 local print_message = function (k, v)
        --                     if (k and k.force and k.force.valid) then
        --                         k.force.print({ "configurable-nukes-controller.seconds-to-target", 3 })
        --                     end
        --                 end

        --                 if (k.player_launched_index == 0) then
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 else
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 end
        --                 v.three, v.five = true, true
        --             elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 300 and not v.five) then
        --                 local print_message = function (k, v)
        --                     if (k and k.force and k.force.valid and v.target_surface_name) then
        --                         k.force.print({ "configurable-nukes-controller.seconds-to-target-gps", 5, k.target_position.x, k.target_position.y, v.target_surface_name })
        --                         v.five = true
        --                     end
        --                 end

        --                 if (k.player_launched_index == 0) then
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 else
        --                     if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
        --                         print_message(k, v)
        --                     end
        --                 end
        --                 -- v.five = true
        --             end
        --         end

        --         ::continue::
        --     end
        -- end

        local circuit_connected_silos_on_platforms = {}

        if (sa_active) then
            if (game.forces["player"] and game.forces["player"].platforms) then
                local all_rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_all_rocket_silo_meta_data()

                for _, space_platform in pairs(game.forces["player"].platforms) do
                    if (not space_platform.surface or not space_platform.surface.valid) then goto continue end

                    local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_platform.surface.name, { create = false })
                    if (rocket_silo_meta_data and rocket_silo_meta_data.valid) then
                        if (rocket_silo_meta_data.rocket_silos and next(rocket_silo_meta_data.rocket_silos, nil)) then
                            for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
                                if (v.circuit_network_data) then
                                    circuit_connected_silos_on_platforms[k] = v
                                end
                            end
                        end
                    else
                        goto continue
                    end

                    if (not rocket_silo_meta_data.rocket_silos or not next(rocket_silo_meta_data.rocket_silos, nil)) then
                        all_rocket_silo_meta_data[space_platform.surface.name] = nil
                        goto continue
                    end

                    local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(space_platform.surface.name)
                    if (not icbm_meta_data or not icbm_meta_data.valid) then goto continue end

                    -- for k, v in pairs(icbm_meta_data.in_transit) do
                    --     if (v and v.target_surface and v.target_surface.valid and v.tick_to_target and game.tick >= v.tick_to_target) then
                    --         if (    k.target_surface
                    --             and k.target_surface.valid
                    --             and ICBM_Utils.payload_arrived({ icbm = k, surface = space_location.surface, target_surface = k.target_surface }))
                    --         then
                    --             icbm_meta_data.in_transit[k] = nil
                    --         else
                    --             -- log(serpent.block(storage))
                    --             -- error("Payload failed to arrive successfully")
                    --         end
                    --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 1 and not v.one) then
                    --         local print_message = function (k, v)
                    --             if (k and k.force and k.force.valid) then
                    --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 1 })
                    --             end
                    --         end

                    --         if (k.player_launched_index == 0) then
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         else
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         end
                    --         v.one, v.two, v.three, v.five = true, true, true, true
                    --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 2 and not v.two) then
                    --         local print_message = function (k, v)
                    --             if (k and k.force and k.force.valid) then
                    --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 2 })
                    --             end
                    --         end

                    --         if (k.player_launched_index == 0) then
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         else
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         end
                    --         v.two, v.three, v.five = true, true, true
                    --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 3 and not v.three) then
                    --         local print_message = function (k, v)
                    --             if (k and k.force and k.force.valid) then
                    --                 k.force.print({ "configurable-nukes-controller.seconds-to-target", 3 })
                    --             end
                    --         end

                    --         if (k.player_launched_index == 0) then
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         else
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         end
                    --         v.three, v.five = true, true
                    --     elseif (v and v.tick_to_target and game.tick >= v.tick_to_target - 60 * 5 and not v.five) then
                    --         local print_message = function (k, v)
                    --             if (k and k.force and k.force.valid and v.target_surface_name) then
                    --                 k.force.print({ "configurable-nukes-controller.seconds-to-target-gps", 5, k.target_position.x, k.target_position.y, v.target_surface_name })
                    --                 v.five = true
                    --             end
                    --         end

                    --         if (k.player_launched_index == 0) then
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         else
                    --             if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PRINT_DELIVERY_MESSAGES.name, })) then
                    --                 print_message(k, v)
                    --             end
                    --         end
                    --         -- v.five = true
                    --     end
                    -- end

                    ::continue::
                end
            end
        end

        local rocket_silo_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(space_location.surface.name)
        Circuit_Network_Service.attempt_launch_silos({ rocket_silos = rocket_silo_data.rocket_silos })

        if (sa_active) then
            Circuit_Network_Service.attempt_launch_silos({ rocket_silos = circuit_connected_silos_on_platforms })
        end

        ::continue::
    end

    configurable_nukes_controller.nth_tick = nth_tick

    storage.configurable_nukes_controller = {
        planet_index = configurable_nukes_controller.planet_index,
        surface_name = configurable_nukes_controller.surface_name,
        space_location = configurable_nukes_controller.space_location,
        nth_tick = nth_tick,
        tick = tick,
        prev_tick = configurable_nukes_controller.tick,
        active_mod_check_tick = configurable_nukes_controller.active_mod_check_tick,
        initialized = true,
        initialized_tick = configurable_nukes_controller.init_tick,
        reinitialized = false,
        reinitialized_tick = configurable_nukes_controller.reinit_tick,
    }
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "configurable_nukes_controller.on_tick",
    func_name = "configurable_nukes_controller.on_tick",
    func = configurable_nukes_controller.on_tick,
})

function configurable_nukes_controller.on_configuration_changed(event)
    Log.debug("configurable_nukes_controller.on_configuration_changed")
    Log.info(event)

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    storage.sa_active = sa_active
    storage.se_active = se_active

    if (event.mod_changes) then
        --[[ Check if our mod updated ]]
        if (event.mod_changes["configurable-nukes"]) then
            game.print({ "configurable-nukes-controller.on-configuration-changed", Constants.mod_name })

            Initialization.init({ maintain_data = true })

            local cn_controller_data = storage and storage.configurable_nukes_controller or configurable_nukes_controller

            cn_controller_data.reinitialized = true
            cn_controller_data.reinit_tick = game.tick

            cn_controller_data.initialized = true
            cn_controller_data.init_tick = game.tick

            -- Constants.get_mod_data(true)

            storage.configurable_nukes_controller = {
                planet_index = cn_controller_data.planet_index,
                surface_name = cn_controller_data.surface_name,
                space_location = cn_controller_data.space_location,
                tick = game.tick,
                prev_tick = cn_controller_data.tick,
                initialized = true,
                initialized_tick = cn_controller_data.init_tick,
                reinitialized = false,
                reinitialized_tick = cn_controller_data.reinit_tick,
            }
        end
    end
end
Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "configurable_nukes_controller.on_configuration_changed",
    func_name = "configurable_nukes_controller.on_configuration_changed",
    func = configurable_nukes_controller.on_configuration_changed,
})

configurable_nukes_controller.configurable_nukes = true

local _configurable_nukes_controller = configurable_nukes_controller

return configurable_nukes_controller
