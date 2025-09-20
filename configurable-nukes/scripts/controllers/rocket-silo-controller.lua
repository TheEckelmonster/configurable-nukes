-- If already defined, return
if _rocket_silo_controller and _rocket_silo_controller.configurable_nukes then
  return _rocket_silo_controller
end

local Log = require("libs.log.log")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_controller = {}

rocket_silo_controller.filter = {{ filter = "type", type = "rocket-silo" }}

function rocket_silo_controller.rocket_silo_built(event)
    Log.debug("rocket_silo_controller.rocket_silo_built")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
end

function rocket_silo_controller.rocket_silo_mined(event)
    Log.debug("rocket_silo_controller.rocket_silo_mined")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_mined(event)
end

function rocket_silo_controller.rocket_silo_mined_script(event)
    Log.debug("rocket_silo_controller.rocket_silo_mined_script")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_mined(event)
end

function rocket_silo_controller.launch_rocket(event)
    Log.debug("rocket_silo_controller.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick) then return end

    if (not event.item or event.item ~= "ICBM-remote") then return end
    if (not event.player_index or not event.area) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    if (not event.surface or not event.surface.valid) then return end

    Rocket_Silo_Service.launch_rocket(event)
end

function rocket_silo_controller.cargo_pod_finished_ascending(event)
    Log.debug("rocket_silo_controller.cargo_pod_finished_ascending")
    Log.info(event)

    Rocket_Silo_Service.cargo_pod_finished_ascending(event)
end

rocket_silo_controller.configurable_nukes = true

local _rocket_silo_controller = rocket_silo_controller

return rocket_silo_controller