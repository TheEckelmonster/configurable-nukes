-- If already defined, return
if _rocket_silo_utils and _rocket_silo_utils.configurable_nukes then
    return _rocket_silo_utils
end

local Log = require("libs.log.log")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

-- ATOMIC_BOMB_ROCKET_LAUNCHABLE
local get_atomic_bomb_rocket_launchable = function ()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_ROCKET_LAUNCHABLE.name].value
    end

    return setting
end
-- ATOMIC_WARHEAD_ENABLED
local get_atomic_warhead_enabled = function ()
    local setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.default_value

    if (settings and settings.startup and settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name]) then
        setting = settings.startup[Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name].value
    end

    return setting
end

local rocket_silo_utils = {}

function rocket_silo_utils.mine_rocket_silo(event)
    Log.debug("rocket_silo_utils.mine_rocket_silo")
    Log.info(event)
    local rocket_silo = event.entity

    if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
        Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
    end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
    Log.debug("rocket_silo_utils.add_rocket_silo")
    Log.info(rocket_silo)

    Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function rocket_silo_utils.launch_rocket(event)
    Log.debug("rocket_silo_utils.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick or not event.surface or not event.surface.valid) then return end
    if (not event.surface.name) then return end
    local surface = event.surface
    if (not surface) then return end

    local rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(surface.name)

    local target_position = {
        x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
        y = (event.area.left_top.y + event.area.right_bottom.y) / 2,
    }

    local rocket_silo_array = {}
    for k, v in pairs(rocket_silo_meta_data.rocket_silos) do
        if (v.entity and v.entity.valid and v.entity.position) then
            local position = v.entity.position
            local distance = ((target_position.x - position.x) ^ 2 + (target_position.y - position.y) ^ 2) ^ 0.5
            if (#rocket_silo_array == 0) then
                table.insert(rocket_silo_array, { entity = v.entity, distance = distance, })
            else
                local found = false
                for i, j in ipairs(rocket_silo_array) do
                    if (distance < j.distance) then
                        table.insert(rocket_silo_array, i, { entity = v.entity, distance = distance, })
                        found = true
                        break
                    end
                end

                if (not found) then
                    table.insert(rocket_silo_array, { entity = v.entity, distance = distance, })
                end
            end
        end
    end

    for _, rocket_silo_data in ipairs(rocket_silo_array) do
        local rocket_silo = nil
        local launched = false

        if (rocket_silo_data.entity and rocket_silo_data.entity.valid) then
            rocket_silo = rocket_silo_data.entity
        end

        if (rocket_silo and rocket_silo.valid) then
            local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
            if (inventory) then
                for _, item in ipairs(inventory.get_contents()) do

                    if (    (item.name == "atomic-bomb" and get_atomic_bomb_rocket_launchable())
                        or
                            (item.name == "atomic-warhead" and get_atomic_warhead_enabled()))
                    then
                        local rocket = rocket_silo.rocket

                        local cargo_pod
                        if (rocket and rocket.valid) then
                            cargo_pod = rocket.attached_cargo_pod

                            if (cargo_pod and cargo_pod.valid) then
                                cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }
                            end
                        end

                        if (rocket_silo.launch_rocket()) then
                            Log.info("Launched rocket_silo:")
                            Log.info(rocket_silo)
                            ICBM_Utils.launch_initiated({
                                type = item.name == "atomic-bomb" and "atomic-rocket" or "atomic-warhead",
                                surface = surface,
                                item = item,
                                tick = event.tick,
                                rocket_silo = rocket_silo,
                                area = event.area,
                                cargo_pod = cargo_pod and cargo_pod.valid and cargo_pod,
                                player_index = event.player_index,
                            })
                            launched = true
                            break
                        else
                            Log.info("Failed to launch rocket_silo: ")
                            Log.info(rocket_silo)
                        end
                    end
                end
            end
        end

        if (launched) then break end
    end
end

rocket_silo_utils.configurable_nukes = true

local _rocket_silo_utils = rocket_silo_utils

return rocket_silo_utils
