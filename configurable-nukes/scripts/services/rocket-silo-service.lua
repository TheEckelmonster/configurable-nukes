-- If already defined, return
if _rocket_silo_service and _rocket_silo_service.configurable_nukes then
  return _rocket_silo_service
end

local Circuit_Network_Validations = require("scripts.validations.circuit-network-data.rocket-silo-validations")
local Force_Launch_Data_Repository = require("scripts.repositories.force-launch-data-repository")
local Log = require("libs.log.log")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Service = require("scripts.services.settings-service")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local rocket_silo_service = {}

function rocket_silo_service.cargo_pod_finished_ascending(event)
    Log.debug("rocket_silo_service.cargo_pod_finished_ascending")
    Log.info(event)

    if (not event) then return end
    local se_active = storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]
    if (not event.launched_by_rocket) then
        if (not se_active) then
            return
        else
            if (not event.cargo_pod or not event.cargo_pod.valid) then return end
            if (not event.cargo_pod.surface or not event.cargo_pod.surface.valid) then return end
            local icbm_meta_data = ICBM_Meta_Repository.get_icbm_meta_data(event.cargo_pod.surface.name)

            local k, icbm_data = next(icbm_meta_data.icbms, nil)
            while k or (not k and icbm_data) do
                if (icbm_data and icbm_data.cargo_pod_unit_number and icbm_data.cargo_pod_unit_number == event.cargo_pod.unit_number) then
                    break
                end

                if (k) then k, icbm_data = next(icbm_meta_data.icbms, k) end
            end

            if (icbm_data == nil) then
                Log.warn("no icbm_data found")
                return -1
            end
        end
    end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    local cargo_pod = event.cargo_pod
    Log.warn(cargo_pod)
    Log.warn(cargo_pod.cargo_pod_destination)
    if (not cargo_pod.cargo_pod_destination) then return end


    -- Check the carge; if the cargo pod doesn't have a station and has a destination type of 1
    --   -> no station implies it was sent to "orbit"
    --   -> .type is 1 for some reason, and not defines.cargo_destination.orbit as I would have thought
    if (    cargo_pod.cargo_pod_destination
        and not cargo_pod.cargo_pod_destination.station
        and cargo_pod.cargo_pod_destination.type == defines.cargo_destination.surface)
    then
        local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)

        if (inventory) then
            for _, item in ipairs(inventory.get_contents()) do
                if (    (string.find(item.name, "atomic-bomb", 1, true) and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name }))
                    or
                        (item.name == "atomic-warhead" and Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })))
                then
                    local return_val = ICBM_Utils.cargo_pod_finished_ascending({
                        surface = cargo_pod.surface,
                        item = item,
                        tick = event.tick,
                        cargo_pod = cargo_pod,
                    })

                    if (Log.get_log_level().level.num_val <= 3) then
                        log(serpent.block(return_val))
                    end
                    if (return_val and return_val ~= 1) then
                        Log.error("cargo_pod_finished_ascending failed to process successfully")
                    end
                    Log.info("destroying cargo pod")
                    if (cargo_pod.destroy({ raise_destroy = true })) then
                        Log.debug("cargo pod destroyed")
                    end
                end
            end
        end
    end
end

function rocket_silo_service.rocket_silo_built(rocket_silo)
    Log.debug("rocket_silo_service.rocket_silo_built")
    Log.info(rocket_silo)

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        Rocket_Silo_Utils.add_rocket_silo(rocket_silo)
        Log.info("Built rocket silo")
        Log.info(rocket_silo)
    end
end

function rocket_silo_service.rocket_silo_cloned(data)
    Log.debug("rocket_silo_service.rocket_silo_cloned")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.source_silo or not data.source_silo.valid) then return end
    if (not data.destination_silo or not data.destination_silo.valid) then return end

    local source_rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(data.source_silo.surface.name, data.source_silo.unit_number)
    local destination_rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(data.destination_silo)

    destination_rocket_silo_data.circuit_network_data = source_rocket_silo_data.circuit_network_data
    destination_rocket_silo_data.circuit_network_data.entity = data.destination_silo
    destination_rocket_silo_data.circuit_network_data.unit_number = data.destination_silo.unit_number
    destination_rocket_silo_data.circuit_network_data.surface = data.destination_silo.surface
    destination_rocket_silo_data.circuit_network_data.surface_index = data.destination_silo.surface.index
    destination_rocket_silo_data.circuit_network_data.surface_name = data.destination_silo.surface.name
    destination_rocket_silo_data.circuit_network_data.updated = game.tick

    Circuit_Network_Validations.validate({
        circuit_network_data = destination_rocket_silo_data.circuit_network_data,
        reinitialize = true,
    })

    Log.debug("Cloned a rocket silo")
    Log.info(data.destination_silo)
end

function rocket_silo_service.rocket_silo_mined(event)
    Log.debug("rocket_silo_service.rocket_silo_mined")
    Log.info(event)
    Rocket_Silo_Utils.mine_rocket_silo(event)
end

function rocket_silo_service.rocket_silo_mined_script(event)
    Log.debug("rocket_silo_service.rocket_silo_mined_script")
    Log.info(event)
    Rocket_Silo_Utils.mine_rocket_silo(event)
end

function rocket_silo_service.launch_rocket(event)
    Log.debug("rocket_silo_service.launch_rocket")
    Log.info(event)
    Rocket_Silo_Utils.launch_rocket(event)
end

function rocket_silo_service.on_space_platform_mined_entity(event)
    Log.debug("rocket_silo_service.on_space_platform_mined_entity")
    Log.info(event)
    Rocket_Silo_Utils.mine_rocket_silo(event)
end

function rocket_silo_service.scrub_newest_launch(data)
    Log.debug("rocket_silo_service.scrub_newest_launch")
    Log.info(event)

    if (not data) then return end
    if (not data.tick) then return end
    if (not data.tick_event) then return end
    if (not data.player_index) then return end
    if (not data.player) then return end

    data.order = "last"
    data.space_launches_initiated = ICBM_Utils.get_space_launches_initiatied()

    Rocket_Silo_Utils.scrub_launch(data)
end

function rocket_silo_service.scrub_oldest_launch(data)
    Log.debug("rocket_silo_service.scrub_oldest_launch")
    Log.info(event)


    if (not data) then return end
    if (not data.tick) then return end
    if (not data.tick_event) then return end
    if (not data.player_index) then return end
    if (not data.player) then return end

    data.order = "first"
    data.space_launches_initiated = ICBM_Utils.get_space_launches_initiatied()

    Rocket_Silo_Utils.scrub_launch(data)
end

function rocket_silo_service.scrub_all_launches(data)
    Log.debug("rocket_silo_service.scrub_all_launches")
    Log.info(event)

    data.order = "last"
    data.print_message = false
    data.space_launches_initiated = ICBM_Utils.get_space_launches_initiatied()

    local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(data.player.force.index)

    local i = 0
    while force_launch_data.launch_action_queue.count > 0 do
        if (i > force_launch_data.launch_action_queue.limit * 1.5) then
            Log.error("rocket_silo_service.scrub_all_launches loop continued beyond it's size limit")
            return
        end
        Rocket_Silo_Utils.scrub_launch(data)
        i = i + 1
    end

    if (i > 0 and force_launch_data.force and force_launch_data.force.valid) then
        force_launch_data.force.print({ "rocket-silo-service.scrub-all-launches" })
    end
end

rocket_silo_service.configurable_nukes = true

local _rocket_silo_service = rocket_silo_service

return rocket_silo_service