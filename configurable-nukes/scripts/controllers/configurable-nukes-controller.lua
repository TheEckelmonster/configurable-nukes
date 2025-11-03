local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Circuit_Network_Service = require("scripts.services.circuit-network-service")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local String_Utils = require("scripts.utils.string-utils")

local configurable_nukes_controller = {}
configurable_nukes_controller.name = "configurable_nukes_controller"

configurable_nukes_controller.planet_index = nil
configurable_nukes_controller.planet = nil
configurable_nukes_controller.nth_tick = nil

configurable_nukes_controller.checked_research = false

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

function configurable_nukes_controller.on_tick(event)
    -- Log.debug("configurable_nukes_controller.on_tick")
    -- Log.info(event)

    local tick = event.tick
    --[[ TODO: Impement this ]]
    -- local nth_tick = Settings_Service.get_nth_tick()
    local nth_tick = configurable_nukes_controller.nth_tick or 4
    local tick_modulo = tick % nth_tick


    if (tick_modulo ~= 0) then return end

    if (not se_active and not Constants.planets_dictionary) then
        Constants.get_planets(not Constants.planets_dictionary)
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
    }
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "configurable_nukes_controller.on_tick",
    func_name = "configurable_nukes_controller.on_tick",
    func = configurable_nukes_controller.on_tick,
})

return configurable_nukes_controller
