-- If already defined, return
if _rocket_silo_validations and _rocket_silo_validations.configurable_nukes then
    return _rocket_silo_validations
end

local Log = require("libs.log.log")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_validations = {}

function rocket_silo_validations.is_targetable_surface(data)
    Log.debug("rocket_silo_validations.launch_rocket")
    Log.info(data)

    local return_val = false

    if (not data or type(data) ~= "table") then return return_val end
    if (not data.surface or not data.surface.valid) then return return_val end

    if (String_Utils.find_invalid_substrings(data.surface.name)) then return return_val end

    if (data.player and not data.player.valid) then return return_val end

    if (string.find(data.surface.name, "platform-", 1, true)) then
        Log.error("attempted to launch at a platform")
        if (data.player) then
            if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
            if (not storage.rocket_silo_controller[data.player.index]) then storage.rocket_silo_controller[data.player.index] = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data) then storage.rocket_silo_controller[data.player.index].meta_data = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data.platform_target_warned) then
                storage.rocket_silo_controller[data.player.index].meta_data.platform_target_warned = true
                data.player.print("Targetting of platforms is not presently allowed")
            end
        end
        return return_val
    end
    if (string.find(data.surface.name, "starmap-", 1, true)) then
        Log.warn("attempted to launch at a starmap")
        if (data.player) then
            if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
            if (not storage.rocket_silo_controller[data.player.index]) then storage.rocket_silo_controller[data.player.index] = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data) then storage.rocket_silo_controller[data.player.index].meta_data = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data.starmap_target_warned) then
                storage.rocket_silo_controller[data.player.index].meta_data.starmap_target_warned = true
                data.player.print("Targetting of the starmap is not allowed")
            end
        end
        return return_val
    end
    if (string.find(data.surface.name, "spaceship-", 1, true)) then
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
        Log.warn("attempted to launch at a spaceship")
        if (data.player) then
            if (not storage.rocket_silo_controller) then storage.rocket_silo_controller = {} end
            if (not storage.rocket_silo_controller[data.player.index]) then storage.rocket_silo_controller[data.player.index] = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data) then storage.rocket_silo_controller[data.player.index].meta_data = {} end
            if (not storage.rocket_silo_controller[data.player.index].meta_data.spaceship_target_warned) then
                storage.rocket_silo_controller[data.player.index].meta_data.spaceship_target_warned = true
                data.player.print("Targetting of spaceships is not presently allowed")
            end
        end
        return return_val
    end

    return true
end

rocket_silo_validations.configurable_nukes = true

local _rocket_silo_validations = rocket_silo_validations

return rocket_silo_validations