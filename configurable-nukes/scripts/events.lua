--[[ Globals ]]
Did_Init = false

Constants = require("scripts.constants.constants")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

---

local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-controller")
local Custom_Input = require("prototypes.custom-input.custom-input")
local Initialization = require("scripts.initialization")
local Rocket_Silo_Gui_Controller = require("scripts.controllers.guis.rocket-silo-gui-controller")
local Rocket_Dashboard_Gui_Controller = require("scripts.controllers.guis.rocket-dashboard-gui-controller")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")
local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

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
    ["cn-tesla-rocket-lightning"] = true,
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

local sa_active = mods and mods["space-age"] and true

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

    if (event.effect_id == "cn-tesla-rocket-lightning") then
        if (not sa_active) then return end

        local target = event.target_position

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        surface.execute_lightning({ name = "lightning", position = target })
    elseif (event.effect_id == "atomic-bomb-fired") then
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
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
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

local did_init = false

function events.on_singleplayer_init(event)

    Is_Singleplayer = true
    Is_Multiplayer = false
end
-- Event_Handler:register_event({
--     event_name = "on_singleplayer_init",
--     source_name = "events.on_singleplayer_init",
--     func_name = "events.on_singleplayer_init",
--     func = events.on_singleplayer_init,
-- })

function events.on_multiplayer_init(event)

    Is_Singleplayer = false
    Is_Multiplayer = true
end
-- Event_Handler:register_event({
--     event_name = "on_multiplayer_init",
--     source_name = "events.on_multiplayer_init",
--     func_name = "events.on_multiplayer_init",
--     func = events.on_multiplayer_init,
-- })

function events.on_init()
    if (type(storage) ~= "table") then return end

    local return_val = 0

    storage.handles = {
        log_handle = {},
        setting_handle = {},
    }

    return_val = Settings_Service.init({ storage_ref = storage.handles.setting_handle })
    return_val = Settings_Controller.init({ settings_service = Settings_Service })

    local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

    return_val = Log.init({
        storage_ref = storage.handles.log_handle,
        debug_level_name = log_settings[1].name,
        traceback_setting_name = log_settings[2].name,
        do_not_print_setting_name = log_settings[3].name,
    })
    Log.ready()

    Initialization.init({ maintain_data = false })

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

    Event_Handler:register_event({
        event_name = "on_tick",
        source_name = "rocket_dashboard_gui_controller.on_tick.instantiate_if_not_exists",
        func_name = "rocket_dashboard_gui_controller.instantiate_if_not_exists",
        func = Rocket_Dashboard_Gui_Controller.instantiate_if_not_exists,
    })

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = Rocket_Dashboard_Gui_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE.name }) or 6,
        source_name = "rocket_dashboard_gui_controller.on_nth_tick",
        func_name = "rocket_dashboard_gui_controller.on_nth_tick",
        func = Rocket_Dashboard_Gui_Controller.on_nth_tick,
    })

    Constants.get_mod_data(true, { on_load = true })

    Did_Init = true
end
Event_Handler:register_event({
    event_name = "on_init",
    source_name = "events.on_init",
    func_name = "events.on_init",
    func = events.on_init,
})

local initialized_from_load = false

function events.on_load()

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    local return_val = 0

    if (type(storage.handles) == "table") then
        initialized_from_load = true
        return_val = initialized_from_load and Settings_Service.init({ storage_ref = storage.handles.setting_handle })
        if (not return_val) then initialized_from_load = false end
        return_val = initialized_from_load and Settings_Controller.init({ settings_service = Settings_Service })
        if (not return_val) then initialized_from_load = false end

        local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

        return_val = initialized_from_load and Log.init({
            storage_ref = storage.handles.log_handle,
            debug_level_name = log_settings[1].name,
            traceback_setting_name = log_settings[2].name,
            do_not_print_setting_name = log_settings[3].name,
        })
        if (not return_val) then initialized_from_load = false end

        if (initialized_from_load) then Log.ready() end
    end

    if (se_active) then
        local event_num = remote.call("space-exploration", "get_on_zone_surface_created_event")

        if (type(event_num) == "number") then
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

    Event_Handler:register_event({
        event_name = "on_tick",
        source_name = "rocket_dashboard_gui_controller.on_tick.instantiate_if_not_exists",
        func_name = "rocket_dashboard_gui_controller.instantiate_if_not_exists",
        func = Rocket_Dashboard_Gui_Controller.instantiate_if_not_exists,
    })

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = Rocket_Dashboard_Gui_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE.name }) or 6,
        source_name = "rocket_dashboard_gui_controller.on_nth_tick",
        func_name = "rocket_dashboard_gui_controller.on_nth_tick",
        func = Rocket_Dashboard_Gui_Controller.on_nth_tick,
    })

    Constants.get_mod_data(true, { on_load = true })

    Event_Handler:on_load_restore({ events = events })
end
Event_Handler:register_event({
    event_name = "on_load",
    source_name = "events.on_load",
    func_name = "events.on_load",
    func = events.on_load,
})

function events.on_configuration_changed(event)
    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    storage.sa_active = sa_active
    storage.se_active = se_active

    if (event.mod_changes) then
        --[[ Check if our mod updated ]]
        if (event.mod_changes["configurable-nukes"]) then
            if (not Did_Init) then
                game.print({ Constants.mod_name .. ".on-configuration-changed", Constants.mod_name })

                if (type(storage.handles) ~= "table" or not initialized_from_load) then
                    storage.handles = {
                        log_handle = {},
                        setting_handle = {},
                    }

                    local return_val = 0
                    return_val = Settings_Service.init({ storage_ref = storage.handles.setting_handle })
                    return_val = Settings_Controller.init({ settings_service = Settings_Service })

                    local log_settings = Log_Settings.create({ prefix = Constants.mod_name })

                    return_val = Log.init({
                        storage_ref = storage.handles.log_handle,
                        debug_level_name = log_settings[1].name,
                        traceback_setting_name = log_settings[2].name,
                        do_not_print_setting_name = log_settings[3].name,
                    })

                    Log.ready()
                end

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
end
Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "events.on_configuration_changed",
    func_name = "events.on_configuration_changed",
    func = events.on_configuration_changed,
})