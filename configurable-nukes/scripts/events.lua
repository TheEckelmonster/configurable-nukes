local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-controller")
local Constants = require("scripts.constants.constants")
local Custom_Input = require("prototypes.custom-input.custom-input")
local Initialization = require("scripts.initialization")
local Rocket_Silo_Gui_Controller = require("scripts.controllers.guis.rocket-silo-gui-controller")
local Rocket_Dashboard_Gui_Controller = require("scripts.controllers.guis.rocket-dashboard-gui-controller")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Log = require("libs.log.log")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Settings_Controller = require("scripts.controllers.settings-controller")
local Settings_Service = require("scripts.services.settings-service")

local valid_event_effect_ids =
{
    ["atomic-bomb-pollution"] = true,
    ["atomic-warhead-pollution"] = true,
    ["k2-nuclear-turret-rocket-pollution"] = true,
    ["k2-atomic-artillery-pollution"] = true,
    ["saa-s-atomic-artillery-pollution"] = true,
    ["atomic-bomb-fired"] = true,
    ["kr-nuclear-turret-rocket-projectile-fired"] = true,
    ["kr-atomic-artillery-projectile-fired"] = true,
    ["saa-s-atomic-artillery-projectile-fired"] = true,
}

local events = {
    [Configurable_Nukes_Controller.name] = Configurable_Nukes_Controller,
    [Custom_Input.name] = Custom_Input,
    [Rocket_Silo_Gui_Controller.name] = Rocket_Silo_Gui_Controller,
    [Rocket_Dashboard_Gui_Controller.name] = Rocket_Dashboard_Gui_Controller,
    [ICBM_Utils.name] = ICBM_Utils,
    [Planet_Controller.name] = Planet_Controller,
    [Rocket_Silo_Controller.name] = Rocket_Silo_Controller,
    [Settings_Controller.name] = Settings_Controller,
}

--[[ TODO: Move this to its own controller/service/utils? ]]
script.on_event(defines.events.on_script_trigger_effect, function (event)
    Log.debug("script.on_event(defines.events.on_script_trigger_effect,...)")
    Log.info(event)

    if (    event and event.effect_id
        and not valid_event_effect_ids[event.effect_id]
    ) then
        Log.debug("returning")
        return
    end
    if (not game or not event.surface_index or game.get_surface(event.surface_index) == nil) then return end

    local surface = game.get_surface(event.surface_index)

    if (event.effect_id == "atomic-bomb-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and prototypes.quality[quality] and quality or "normal"

        local orientation = event.source_entity and event.source_entity.valid and (event.source_entity.type == "spider-vehicle" and event.source_entity.torso_orientation or event.source_entity.orientation)
        local _orientation = orientation
        orientation = math.floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "atomic-rocket" .. "-" .. quality,
                position = source,
                direction = defines.direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math.exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
            })
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
        end
    elseif (event.effect_id == "kr-nuclear-turret-rocket-projectile-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and prototypes.quality[quality] and quality or "normal"

        local orientation = event.source_entity and event.source_entity.valid and (event.source_entity.type == "spider-vehicle" and event.source_entity.torso_orientation or event.source_entity.orientation)
        local _orientation = orientation
        orientation = math.floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "kr-nuclear-turret-rocket-projectile" .. "-" .. quality,
                position = source,
                direction = defines.direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math.exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
            })
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
        end
    elseif (event.effect_id == "kr-atomic-artillery-projectile-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and prototypes.quality[quality] and quality or "normal"

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "kr-atomic-artillery-projectile" .. "-" .. quality,
                position = source,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
                base_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    radius_modifier = 1,
                },
            })
        end
    elseif (event.effect_id == "saa-s-atomic-artillery-projectile-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and prototypes.quality[quality] and quality or "normal"

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "atomic-artillery-projectile" .. "-" .. quality,
                position = source,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
                base_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    radius_modifier = 1,
                },
            })
        end
    else
        local position = event.source_position or event.target_position

        if (position) then
            if (event.effect_id == "atomic-bomb-pollution") then
                surface.pollute(position, Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.POLLUTION.name }), "atomic-rocket")
            elseif (event.effect_id == "atomic-warhead-pollution") then
                surface.pollute(position, Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_POLLUTION.name }), "atomic-warhead")
            elseif (event.effect_id == "k2-nuclear-turret-rocket-pollution") then
                surface.pollute(position, Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_POLLUTION.name }), "kr-nuclear-turret-rocket-projectile")
            elseif (event.effect_id == "k2-atomic-artillery-pollution") then
                surface.pollute(position, Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_POLLUTION.name }), "kr-atomic-artillery-projectile")
            elseif (event.effect_id == "saa-s-atomic-artillery-pollution") then
                surface.pollute(position, Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_POLLUTION.name }), "atomic-artillery-projectile")
            end
        end
    end
end)

function events.on_load()
    Log.debug("events.on_load")

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    if (se_active) then
        local event_num = remote.call("space-exploration", "get_on_zone_surface_created_event")

        if (event_num ~= nil and type(event_num) == "number") then
            local event_position = Event_Handler:get_event_position({
                event_name = event_num,
                source_name = "Planet_Controller.on_surface_created",
            })

            if (event_position == nil) then
                Event_Handler:register_event({
                    event_num = event_num,
                    fallback_event_name = "on_zone_surface_created",
                    source_name = "Planet_Controller.on_surface_created",
                    func_name = "Planet_Controller.on_surface_created",
                    func = Planet_Controller.on_surface_created,
                })
            end
        end
    end

    Constants.get_mod_data(true, { on_load = true })

    if (not storage or not storage.event_handlers or type(storage.event_handlers) ~= "table") then return end

    if (storage.event_handlers.restore_on_load) then
        local events_to_restore = storage.event_handlers.restore_on_load

        local restore_on_load = function (data)
            Log.debug("restore_on_load")
            Log.info(data)

            local i = 1
            while data.event.order and i <= #data.event.order do
                local search_pattern = "(%g+)%.(%g+)"
                local _, _, class, func_name = data.event.order[i].func_name:find(search_pattern, 1)
                local func = events and events[class] and events[class][func_name] or nil

                if (type(func) == "function") then
                    Event_Handler:register_event({
                        event_name = data.event.order[i].event_name,
                        source_name = data.event.order[i].source_name,
                        func_name = data.event.order[i].func_name,
                        nth_tick = data.nth_tick,
                        restore_on_load = true,
                        func = func,
                        func_data = data.event.order[i].func_data,
                    })
                    i = i + 1
                end
            end

            i = 1
            while data.event.order and i <= #data.event.order do
                Event_Handler:set_event_position({
                    event_name = data.event.order[i].event_name,
                    source_name = data.event.order[i].source_name,
                    new_position = data.event.order[i].index,
                })

                i = i + 1
            end
        end

        for k, v in pairs(events_to_restore) do
            if (k == "on_nth_tick") then
                for k_2, v_2 in pairs(v) do
                    restore_on_load({
                        event = v_2,
                        nth_tick = k_2
                    })
                end
            else
                restore_on_load({
                    event = v_2,
                })
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_load",
    source_name = "events.on_load",
    func_name = "events.on_load",
    func = events.on_load,
})

function events.on_configuration_changed(event)
    Log.debug("events.on_configuration_changed")
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

            local cn_controller_data = storage and storage.configurable_nukes_controller or {}

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
                initialized = cn_controller_data.initialized,
                initialized_tick = cn_controller_data.init_tick,
                reinitialized = cn_controller_data.reinitialized,
                reinitialized_tick = cn_controller_data.reinit_tick,
            }
        end
    end
end
Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "events.on_configuration_changed",
    func_name = "events.on_configuration_changed",
    func = events.on_configuration_changed,
})