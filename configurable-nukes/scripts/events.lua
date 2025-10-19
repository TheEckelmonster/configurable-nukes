require("scripts.controllers.configurable-nukes-controller")
require("prototypes.custom-input.custom-input")
require("scripts.controllers.gui-controller")
require("scripts.controllers.planet-controller")
require("scripts.controllers.rocket-silo-controller")
require("scripts.controllers.settings-controller")

-- local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-controller")
local Constants = require("scripts.constants.constants")
-- local Custom_Input = require("prototypes.custom-input.custom-input")
-- local Event_Handler = require("scripts.event-handler")
-- local Gui_Controller = require("scripts.controllers.gui-controller")
local Log = require("libs.log.log")
-- local Planet_Controller = require("scripts.controllers.planet-controller")
-- local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
-- local Settings_Controller = require("scripts.controllers.settings-controller")
local Settings_Service = require("scripts.services.settings-service")

local valid_event_effect_ids =
{
    ["atomic-bomb-pollution"] = true,
    ["atomic-warhead-pollution"] = true,
    ["k2-nuclear-turret-rocket-pollution"] = true,
    ["k2-atomic-artillery-pollution"] = true,
    ["atomic-bomb-fired"] = true,
    ["kr-nuclear-turret-rocket-projectile-fired"] = true,
    ["kr-atomic-artillery-projectile-fired"] = true,
}

--[[ TODO: Move this to its own controller/service/utils ]]
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
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
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
            end
        end
    end
end)