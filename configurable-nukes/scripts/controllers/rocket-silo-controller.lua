-- If already defined, return
if _rocket_silo_controller and _rocket_silo_controller.configurable_nukes then
  return _rocket_silo_controller
end

local Log = require("libs.log.log")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Spaceship_Service = require("scripts.services.spaceship-service")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_controller = {}

rocket_silo_controller.filter =
{
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "rocket-silo", mode = "and" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
}

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

function rocket_silo_controller.rocket_silo_cloned(event)
    Log.debug("rocket_silo_controller.rocket_silo_cloned")
    Log.info(event)

    if (not event) then return end
    if (not event.source or not event.source.valid) then return end
    if (not event.destination or not event.destination.valid) then return end

    local source_silo = event.source
    if (not source_silo.surface or not source_silo.surface.valid) then return end

    local source_surface = source_silo.surface
    if (String_Utils.find_invalid_substrings(source_surface.name)) then return end

    local destination_silo = event.destination
    if (not destination_silo.surface or not destination_silo.surface.valid) then return end
    Log.warn(destination_silo)

    local destination_surface = destination_silo.surface
    if (String_Utils.find_invalid_substrings(destination_surface.name)) then return end
    Log.warn(destination_surface)

    Rocket_Silo_Service.rocket_silo_cloned({
        tick = event.tick,
        destination_silo = destination_silo,
    })

    Spaceship_Service.rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    ICBM_Utils.rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })
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

function rocket_silo_controller.launch_ipbm(event)
    Log.error("rocket_silo_controller.launch_ipbm")
    Log.warn(event)

end

function rocket_silo_controller.on_player_reverse_selected_area(event)
    Log.error("rocket_silo_controller.on_player_reverse_selected_area")
    Log.warn(event)

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
    if (string.find(event.surface.name, "platform-", 1, true)) then
        Log.error("attempted to launch at a platform")
        if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
        if (not storage.rocket_silo_controller[event.player_index]) then storage.rocket_silo_controller[event.player_index] = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data) then storage.rocket_silo_controller[event.player_index].meta_data = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data.platform_target_warned) then
            storage.rocket_silo_controller[event.player_index].meta_data.platform_target_warned = true
            player.print("Targetting of platforms is not presently allowed")
        end
        return
    end
    if (string.find(event.surface.name, "starmap-", 1, true)) then
        if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
        if (not storage.rocket_silo_controller[event.player_index]) then storage.rocket_silo_controller[event.player_index] = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data) then storage.rocket_silo_controller[event.player_index].meta_data = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data.starmap_target_warned) then
            storage.rocket_silo_controller[event.player_index].meta_data.starmap_target_warned = true
            player.print("Targetting of the starmap is not allowed")
        end
        Log.warn("attempted to launch at a starmap")
        return
    end
    if (string.find(event.surface.name, "spaceship-", 1, true)) then
        --[[ TODO: Reach out about the bug caused when launching a rocket while a spaceship takes off
            -> No error on this side; rather, is coming from SE:

                The mod Space Exploration (0.7.34) caused a non-recoverable error.
                Please report this error to the mod author.

                Error while running event space-exploration::on_rocket_launched (ID 14)
                __space-exploration__/control.lua:1551: attempt to index field 'attached_cargo_pod' (a nil value)
                stack traceback:
                    __space-exploration__/control.lua:1551: in function 'callback'
                    __space-exploration__/scripts/event.lua:20: in function <__space-exploration__/scripts/event.lua:18>

            -> [Missing a '.valid' check when a cargo-pod finishes ascending]
        ]]
        if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
        if (not storage.rocket_silo_controller[event.player_index]) then storage.rocket_silo_controller[event.player_index] = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data) then storage.rocket_silo_controller[event.player_index].meta_data = {} end
        if (not storage.rocket_silo_controller[event.player_index].meta_data.spaceship_target_warned) then
            storage.rocket_silo_controller[event.player_index].meta_data.spaceship_target_warned = true
            player.print("Targetting of spaceships is not presently allowed")
        end
        Log.warn("attempted to launch at a spaceship")
        return
    end

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