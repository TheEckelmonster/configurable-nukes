-- If already defined, return
if _rocket_silo_service and _rocket_silo_service.configurable_nukes then
  return _rocket_silo_service
end

local Log = require("libs.log.log")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_atomic_bomb_rocket_launchable = function ()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name].value
    end

    return setting
end
local get_atomic_warhead_enabled = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name].value
    end

    return setting
end

local rocket_silo_service = {}

function rocket_silo_service.cargo_pod_finished_ascending(event)
    Log.debug("rocket_silo_service.cargo_pod_finished_ascending")
    Log.info(event)

    log("rocket_silo_service.cargo_pod_finished_ascending")

    if (not event) then return end
    if (not event.launched_by_rocket) then return end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    local cargo_pod = event.cargo_pod
    if (not cargo_pod.cargo_pod_destination) then return end

    -- Check the carge; if the cargo pod doesn't have a station and has a destination type of 1
    --   -> no station implies it was sent to "orbit"
    --   -> .type is 1 for some reason, and not defines.cargo_destination.orbit as I would have thought
    if (cargo_pod.cargo_pod_destination
            and not cargo_pod.cargo_pod_destination.station
            and (cargo_pod.cargo_pod_destination.type == 1 or cargo_pod.cargo_pod_destination.type == defines.cargo_destination.orbit)
            and event.launched_by_rocket)
    then
        local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)

        if (inventory) then
            for _, item in ipairs(inventory.get_contents()) do
                if (    (string.find(item.name, "atomic-bomb", 1, true) and get_atomic_bomb_rocket_launchable())
                    or
                        (item.name == "atomic-warhead" and get_atomic_warhead_enabled()))
                then
                    ICBM_Utils.cargo_pod_finished_ascending({
                        surface = cargo_pod.surface,
                        item = item,
                        tick = event.tick,
                        cargo_pod = cargo_pod,
                    })

                    Log.info("destroying cargo pod")
                    if (cargo_pod.destroy()) then
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

rocket_silo_service.configurable_nukes = true

local _rocket_silo_service = rocket_silo_service

return rocket_silo_service