local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
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
script.on_event(defines.events.on_cargo_pod_finished_ascending, Rocket_Silo_Controller.cargo_pod_finished_ascending)

--[[ rocket-silo tracking ]]
script.on_event(defines.events.on_entity_died, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_built_entity, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_built, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_revive, Rocket_Silo_Controller.rocket_silo_built, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_player_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.on_robot_mined_entity, Rocket_Silo_Controller.rocket_silo_mined, Rocket_Silo_Controller.filter)
script.on_event(defines.events.script_raised_destroy, Rocket_Silo_Controller.rocket_silo_mined_script, Rocket_Silo_Controller.filter)