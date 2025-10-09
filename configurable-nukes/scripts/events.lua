--[[ Data types and metatables ]]
local Anomaly_Data = require("scripts.data.space.celestial-objects.anomaly-data")
local Asteroid_Belt_Data = require("scripts.data.space.celestial-objects.asteroid-belt-data")
local Asteroid_Field_Data = require("scripts.data.space.celestial-objects.asteroid-field-data")
local Data = require("scripts.data.data")
local Moon_Data = require("scripts.data.space.celestial-objects.moon-data")
local Orbit_Data = require("scripts.data.space.celestial-objects.orbit-data")
local Planet_Data = require("scripts.data.space.celestial-objects.planet-data")
local Spaceship_Data = require("scripts.data.space.spaceship-data")
local Space_Location_Data = require("scripts.data.space.space-location-data")
local Star_Data = require("scripts.data.space.celestial-objects.star-data")

script.register_metatable("Anomaly_Data", Anomaly_Data.mt)
script.register_metatable("Asteroid_Belt_Data", Asteroid_Belt_Data.mt)
script.register_metatable("Asteroid_Field_Data", Asteroid_Field_Data.mt)
script.register_metatable("Data", Data.mt)
script.register_metatable("Moon_Data", Moon_Data.mt)
script.register_metatable("Orbit_Data", Orbit_Data.mt)
script.register_metatable("Planet_Data", Planet_Data.mt)
script.register_metatable("Spaceship_Data", Spaceship_Data.mt)
script.register_metatable("Space_Location_Data", Space_Location_Data.mt)
script.register_metatable("Star_Data", Star_Data.mt)

---

local Constants = require("scripts.constants.constants")
-- local Custom_Input = require("prototypes.custom-input.custom-input")
local Log = require("libs.log.log")
local Gui_Controller = require("scripts.controllers.gui-controller")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-contoller")

-- POLLUTION
local get_pollution = function ()
    local setting = 0

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.POLLUTION.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.POLLUTION.name].value
    end

    return setting
end
-- ATOMIC_WARHEAD_POLLUTION
local get_atomic_warhead_pollution = function ()
    local setting = 0

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_POLLUTION.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_POLLUTION.name].value
    end

    return setting
end
-- ATOMIC_BOMB_BASE_DAMAGE_MODIFIER
local get_atomic_bomb_base_damage_modifier = function()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.default_value

    log(serpent.block(setting))

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name].value
    end

    log(serpent.block(setting))

    return setting
end
-- ATOMIC_BOMB_BASE_DAMAGE_ADDITION
local get_atomic_bomb_base_damage_addition = function()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.default_value

    log(serpent.block(setting))

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name].value
    end

    log(serpent.block(setting))

    return setting
end
-- -- ATOMIC_BOMB_BASE_DAMAGE_RADIUS_MODIFIER
-- local get_atomic_bomb_base_damage_radius_modifier = function()
--     local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_RADIUS_MODIFIER.default_value

--     log(serpent.block(setting))

--     if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_RADIUS_MODIFIER.name]) then
--         setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_RADIUS_MODIFIER.name].value
--     end

--     log(serpent.block(setting))

--     return setting
-- end
-- ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER
local get_atomic_bomb_bonus_damage_modifier = function()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name].value
    end

    return setting
end
-- ATOMIC_BOMB_BONUS_DAMAGE_ADDITION
local get_atomic_bomb_bonus_damage_addition = function()
    local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name].value
    end

    return setting
end
-- -- ATOMIC_BOMB_BONUS_DAMAGE_RADIUS_MODIFIER
-- local get_atomic_bomb_bonus_damage_radius_modifier = function()
--     local setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_RADIUS_MODIFIER.default_value

--     log(serpent.block(setting))

--     if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_RADIUS_MODIFIER.name]) then
--         setting = settings.global[Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_RADIUS_MODIFIER.name].value
--     end

--     log(serpent.block(setting))

--     return setting
-- end

script.on_event(defines.events.on_script_trigger_effect, function (event)
    Log.debug("script.on_event(defines.events.on_script_trigger_effect,...)")
    Log.info(event)

    if (    event and event.effect_id
        and event.effect_id ~= "atomic-bomb-pollution"
        and event.effect_id ~= "atomic-warhead-pollution"
        and event.effect_id ~= "atomic-bomb-fired")
    then
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
                    damage_modifier = get_atomic_bomb_base_damage_modifier(),
                    damage_addition = get_atomic_bomb_base_damage_addition(),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_atomic_bomb_bonus_damage_modifier(),
                    damage_addition = get_atomic_bomb_bonus_damage_addition(),
                    radius_modifier = 1,
                },
            })
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
        end
    else
        local position = event.source_position or event.target_position

        if (position) then
            Log.debug("detonation; polluting")
            if (event.effect_id == "atomic-bomb-pollution") then
                surface.pollute(position, get_pollution(), "atomic-rocket")
            elseif(event.effect_id == "atomic-bomb-pollution") then
                surface.pollute(position, get_atomic_warhead_pollution(), "atomic-warhead")
            end
        end
    end
end)


script.on_event(defines.events.on_tick, Configurable_Nukes_Controller.do_tick)

script.on_event(defines.events.on_research_finished, Configurable_Nukes_Controller.research_finished)

script.on_event(defines.events.on_surface_created, Planet_Controller.on_surface_created)

script.on_event(defines.events.on_player_selected_area, Rocket_Silo_Controller.launch_rocket)
-- script.on_event(defines.events.on_player_reverse_selected_area, Rocket_Silo_Controller.on_player_reverse_selected_area)
script.on_event(defines.events.on_cargo_pod_finished_ascending, Rocket_Silo_Controller.cargo_pod_finished_ascending)

--[[ custom-inputs-events ]]

-- script.on_event(Custom_Input.LAUNCH_IPBM.name, Rocket_Silo_Controller.launch_ipbm)

--[[ GUI ]]

script.on_event(defines.events.on_gui_opened, Gui_Controller.on_gui_opened)
script.on_event(defines.events.on_gui_closed, Gui_Controller.on_gui_closed)
script.on_event(defines.events.on_gui_elem_changed, Gui_Controller.on_gui_elem_changed)
-- script.on_event(defines.events.on_gui_selection_state_changed, Gui_Controller.on_gui_selection_state_changed)
script.on_event(defines.events.on_entity_settings_pasted, Gui_Controller.on_entity_settings_pasted)

--[[ rocket-silo tracking ]]
script.on_event(defines.events.on_entity_died, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_entity_cloned, Rocket_Silo_Controller.rocket_silo_cloned, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)