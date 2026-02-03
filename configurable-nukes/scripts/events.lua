--[[ Globals ]]
Did_Init = false

Constants = require("scripts.constants.constants")
Filters = require("scripts.constants.filters")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

Payloads = {}
Projectile_Placeholders = {}

---

defines.inventory.cn_payload_vehicle = 1
defines.inventory.payloader = 1

---

local true_nukes_contiued = script and script.active_mods and script.active_mods["True-Nukes_Continued"]

local Data = require("__TheEckelmonster-core-library__.libs.data.data")

local Custom_Input = require("prototypes.custom-input.custom-input")

local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-controller")
local Initialization = require("scripts.initialization")
local Rocket_Silo_Gui_Controller = require("scripts.controllers.guis.rocket-silo-gui-controller")
local Rocket_Dashboard_Gui_Controller = require("scripts.controllers.guis.rocket-dashboard-gui-controller")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Payload_Controller = require("scripts.controllers.payload-controller")
local Payloader_Controller = require("scripts.controllers.payloader-controller")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")
local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

local locals = {}
locals.name = "locals"

local valid_event_effect_ids =
{
    ["map-reveal"] = true,

    ["payload-delivered"] = true,

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

    ["Atomic Weapon hit 20t"] = true_nukes_contiued and true or nil
}

if (script and script.active_mods and script.active_mods["quality"]) then
    for k, quality in pairs(prototypes.quality) do
        if (not quality.hidden) then
            valid_event_effect_ids["jericho-delivered-" .. k] = true
        end
    end
else
    valid_event_effect_ids["jericho-delivered-normal"] = true
end

local placeholders = {
    ["atomic-bomb"] = true_nukes_contiued and "atomic-bomb" or "atomic-rocket",
    ["kr-nuclear-artillery-shell"] = "kr-atomic-artillery-projectile",
    ["atomic-artillery-shell"] = "atomic-artillery-projectile",
    ["cn-jericho"] = "jericho-payloader-rocket",
    ["Atomic Weapon hit 20t"] = true_nukes_contiued and "atomic-bomb" or nil,
}

local quality_affected_prototypes = {
    ["atomic-bomb"] = not true_nukes_contiued and true or false,

    ["atomic-warhead"] = true,
    ["cn-rod-from-god"] = true,
    ["cn-jericho"] = true,
    ["cn-tesla-rocket"] = true,
    ["cn-payload-vehicle"] = true,

    ["kr-nuclear-artillery-shell"] = true,

    ["atomic-artillery-shell"] = true,

    ["Atomic Weapon hit 20t"] = true_nukes_contiued and true or nil
}

local Quality_Prototypes = nil

local events = {
    [locals.name] = locals,
    [Configurable_Nukes_Controller.name] = Configurable_Nukes_Controller,
    [Custom_Input.name] = Custom_Input,
    [Rocket_Silo_Gui_Controller.name] = Rocket_Silo_Gui_Controller,
    [Rocket_Dashboard_Gui_Controller.name] = Rocket_Dashboard_Gui_Controller,
    [ICBM_Utils.name] = ICBM_Utils,
    [Payload_Controller.name] = Payload_Controller,
    [Payloader_Controller.name] = Payloader_Controller,
    [Planet_Controller.name] = Planet_Controller,
    [Rocket_Silo_Controller.name] = Rocket_Silo_Controller,
    [Settings_Controller.name] = Settings_Controller,
}

local sa_active = mods and mods["space-age"] and true

local cache = {}
local cache_attributes = {}
setmetatable(cache_attributes, { __mode = "k" })

cache.map_reveal = {}
cache.map_reveal.chunks = {}

--[[ TODO: Move this to its own controller/service/utils? ]]
script.on_event(defines.events.on_script_trigger_effect, function (event)
    Log.debug("script.on_event(defines.events.on_script_trigger_effect,...)")
    Log.info(event)

    if (    event and event.effect_id
        and not valid_event_effect_ids[event.effect_id]
    ) then
        -- Log.debug("returning")
        return
    end
    if (not game or not event.surface_index or game.get_surface(event.surface_index) == nil) then return end

    local surface = game.get_surface(event.surface_index)

    if (event.effect_id == "map-reveal") then
        local position = event.target_position

        if (position == nil and event.target_entity and event.target_entity.valid) then
            position = event.target_entity.position
        end

        if (position) then
            local chunk_string = math.floor(position.x / 32) .. "/" .. math.floor(position.y / 32)
            if (not cache.map_reveal.chunks[chunk_string] or not cache_attributes[cache.map_reveal.chunks[chunk_string]] or cache_attributes[cache.map_reveal.chunks[chunk_string]].time_to_live < game.tick) then
                cache.map_reveal.chunks[chunk_string] = { count = 0, }
                cache_attributes[cache.map_reveal.chunks[chunk_string]] = Data:new({ time_to_live = game.tick + 75, valid = true })
            end

            if (cache.map_reveal.chunks[chunk_string].count < 2) then
                cache.map_reveal.chunks[chunk_string].count = cache.map_reveal.chunks[chunk_string].count + 1

                surface.request_to_generate_chunks(position, 3)
                surface.force_generate_chunk_requests()
            end
        end
    elseif (event.effect_id == "cn-tesla-rocket-lightning") then
        if (not sa_active) then return end

        local target = event.target_position

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        surface.execute_lightning({ name = "lightning", position = target })
    elseif (event.effect_id == "atomic-bomb-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

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
    elseif (event.effect_id == "Atomic Weapon hit 20t") then
        local target = event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

        if (quality == "normal") then return end

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (target ~= nil) then
            local entity = surface.create_entity({
                name = "atomic-rocket" .. "-" .. quality,
                position = target,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = target,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
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
        end
    elseif (event.effect_id == "kr-nuclear-turret-rocket-projectile-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

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
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

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
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

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
    elseif (event.effect_id:find("-pollution", 1, true)) then
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
    elseif (event.effect_id:find("jericho-delivered-", 1, true)) then
        local target_position = event.target_position
        local _, _, quality = event.effect_id:find("jericho%-delivered%-(%a+)")

        if (not quality or quality == "") then quality = "normal" end

        if (target_position and target_position.x and target_position.y) then

            local explosives = 0
            local explosives_aoe_modifier = 0
            local settings_modifier = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_SUB_ROCKET_REPEAT_MULTIPLIER.name, reindex = true })
            if (settings_modifier == nil) then settings_modifier = 1 end

            local target =
            {
                x = target_position.x,
                y = target_position.y,
            }
            local _target = { x = target.x, y = target.y }
            local function reset_target()
                return { x = _target.x, y = _target.y }
            end
            local function random_scaling()
                return math.random(10000) * .0001355
            end

            local area_setting = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER.name, reindex = true })
            if (area_setting == nil) then area_setting = 1 end

            if (not Quality_Prototypes) then Quality_Prototypes = prototypes.quality end
            local quality_factor = Quality_Prototypes[quality].level or 0
            local repititions = 3 + math.ceil(quality_factor / 3)

            local targets = {}
            local ticks = {}

            local threshold = 100

            local rockets_created = 0
            local random_additional_ticks = 1

            local do_break = false
            for i = 0, repititions, 1 do
                if (do_break) then break end

                local loop_count = 2 ^ i + quality_factor + settings_modifier
                for j = 0, loop_count, 1 do

                    if (threshold < 1) then do_break = true; break end
                    if (math.random(100) <= threshold) then
                        threshold = threshold - 0.5
                        for k = 0, settings_modifier, 1 do
                            target = reset_target()

                            local factor = ((i) * 5 + 4 * (quality_factor + 1) * area_setting) + math.random(5)

                            if (rockets_created % 5 > 0 and rockets_created % 5 ~= 3) then
                                target.x = target.x + random_scaling() * factor * math.cos(2 * math.pi * (j / loop_count))
                                target.y = target.y + random_scaling() * factor * math.sin(2 * math.pi * (j / loop_count))
                            else
                                target.x = target.x + factor * math.cos(2 * math.pi * (j / loop_count))
                                target.y = target.y + factor * math.sin(2 * math.pi * (j / loop_count))
                            end

                            if (rockets_created > 0) then
                                random_additional_ticks = random_additional_ticks + math.random(10)
                            end

                            local nth_tick = game.tick + random_additional_ticks
                            local source_name = "icbm_utils.spawn_jericho_event-"
                                                .. rockets_created .. "-"
                                                .. "on_nth_tick-"
                                                .. nth_tick

                            rockets_created = rockets_created + 1

                            table.insert(targets, { x = target.x, y = target.y })
                            table.insert(ticks, { nth_tick = nth_tick, source_name = source_name })
                        end
                    end
                end
            end

            for i = 1, #ticks, 1 do
                if (i == 1) then
                    target = reset_target()
                else
                    if (targets and #targets > 0) then
                        local rand = math.random(#targets)
                        target = table.remove(targets, rand)
                    else
                        target = reset_target()
                    end
                end

                local nth_tick = ticks[i].nth_tick
                local source_name = ticks[i].source_name

                if (target and nth_tick and source_name) then
                    Event_Handler:register_event({
                        event_name = "on_nth_tick",
                        nth_tick = nth_tick,
                        restore_on_load = true,
                        source_name = source_name,
                        func = ICBM_Utils.spawn_jericho_event,
                        func_name = "icbm_utils.spawn_jericho_event",
                        func_data =
                        {
                            nth_tick = nth_tick,
                            source_name = source_name,
                            payload_item = "cn-jericho-" .. quality,
                            surface = surface,
                            source_position = target_position,
                            payload_spawn_position = {
                                x = target_position.x,
                                y = target_position.y,
                            },
                            target = {
                                x = target.x + math.random(-1 * (1 + explosives_aoe_modifier * explosives) - 1, (1 + explosives_aoe_modifier * explosives) + 1) * (explosives_aoe_modifier --[[* (total_delivered / payload.icbm.total_payload_items)]]) * (explosives > 0 and explosives_aoe_modifier * math.random(explosives + 1) or 0) * math.cos((2 * math.random()) * math.pi * (i / #ticks)),
                                y = target.y + math.random(-1 * (1 + explosives_aoe_modifier * explosives) - 1, (1 + explosives_aoe_modifier * explosives) + 1) * (explosives_aoe_modifier --[[* (total_delivered / payload.icbm.total_payload_items)]]) * (explosives > 0 and explosives_aoe_modifier * math.random(explosives + 1) or 0) * math.sin((2 * math.random()) * math.pi * (i / #ticks)),
                            },
                        },
                        save_to_storage = true,
                    })
                end
            end
        end
    elseif (event.effect_id == "payload-delivered") then
        local target_position = event.target_position
        local source_position = event.source_position

        if (target_position and target_position.x and target_position.y) then
            local position_key = string.format("%.2f", math.floor(target_position.x * 100) / 100) .. "/" .. string.format("%.2f", math.floor(target_position.y * 100) / 100)
            local position_key_target = string.format("%.2f", math.floor(target_position.x * 100) / 100) .. "/" .. string.format("%.2f", math.floor(target_position.y * 100) / 100)
            local position_key_source = string.format("%.2f", math.floor(source_position.x * 100) / 100) .. "/" .. string.format("%.2f", math.floor(source_position.y * 100) / 100)
            local payload = nil
            local removed = false
            local i = 1
            while payload == nil and i <= 6 do
                position_key_target = string.format("%.2f", math.floor(target_position.x * 100) / 100) .. "/" .. string.format("%.2f", math.floor(target_position.y * 100) / 100) .. "-" .. i
                if (Payloads[position_key_target] and Payloads[position_key_target][1]) then
                    payload = table.remove(Payloads[position_key_target], 1)
                    removed = true
                    position_key = position_key_target
                end
                payload = payload or Payloads[position_key_target] or nil

                if (not payload) then
                    position_key_source = string.format("%.8f", math.floor(source_position.x * 100) / 100) .. "/" .. string.format("%.2f", math.floor(source_position.y * 100) / 100) ..  "-" ..i
                    if (Payloads[position_key_source]) then
                        if (Payloads[position_key_source][1]) then
                            payload = table.remove(Payloads[position_key_source], 1)
                            removed = payload and true or false
                            if (removed) then
                                position_key = position_key_source
                            end
                        else
                            payload = Payloads[position_key_source]
                        end
                    end
                end

                if (payload and payload[1]) then
                    payload = table.remove(payload, 1)
                    removed = true
                end

                if (Payloads[position_key] and #Payloads[position_key] and not removed) then Payloads[position_key] = Payloads[position_key][1] end

                i = i + 1
            end

            local payloads = payload and payload.icbm and payload.icbm.cargo and payload.icbm.cargo[1] and payload.icbm.cargo or payload and payload.cargo and (payload.cargo[1] and payload.cargo or { payload.cargo, }) or nil
            if (payloads and not next(payloads)) then payloads = nil end

            if (Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.LEGACY_LAUNCH_SYSTEM_ENABLED.name, })) then
                payload = payload or { cargo = {}, }
                payloads = payloads or {}

                if (payloads ~= payload.cargo) then
                    if (payload.cargo and payload.cargo[1]) then
                        for i, cargo in pairs(payload.cargo) do
                            table.insert(payloads, cargo)
                        end
                    else
                        local existing = false
                        for _, _payload in pairs(payloads) do
                            if (_payload == payload.cargo) then existing = true; break end
                        end

                        if (not existing) then
                            table.insert(payloads, payload.cargo)
                        end
                    end
                end
            end

            if (not payload or not payloads) then return end

            if (payload) then
                if (payload.delivered and game.tick - payload.updated > 150) then
                    return
                elseif (
                        not payload.tick
                    or
                        payload.icbm
                    and payload.icbm.tick_to_target
                    and payload.icbm.tick_to_target <= game.tick
                    and game.tick - payload.icbm.tick_to_target >= 150
                    or
                        game.tick > payload.tick
                    and game.tick - payload.tick >= 150
                ) then
                    return
                end
            end

            local delivered = 0
            local total_delivered = 0

            local explosives = 0
            local explosives_aoe_modifier = 0
            explosives_aoe_modifier = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_EXPLOSIVES_AOE_MULTIPLIER.name, })
            if (payload.icbm and payload.icbm.cargo_dictionary and payload.icbm.cargo_dictionary["explosives"]) then
                explosives = payload.icbm.cargo_dictionary["explosives"].count
            end

            local area_setting = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER.name, reindex = true })
            if (area_setting == nil) then area_setting = 1 end

            for _, cargo in ipairs(payloads) do
                cargo.count = type(cargo.count) == "number" and cargo.count > 0 and cargo.count or 1
                local stage_threshold = math.ceil(cargo.count / 8)

                local name = Projectile_Placeholders[cargo.name] and Projectile_Placeholders[cargo.name].name or ""

                if (placeholders[cargo.name]) then name = placeholders[cargo.name] end
                if (name == "") then goto continue end

                local tesla_munition = false
                if (name:find("tesla")) then tesla_munition = true end

                for i = 1, cargo.count, 1 do
                    --[[ Not really sure what this should be named, as I don't fully understand/remember why introducing this variable fixed things ]]
                    local qwer = (((i % stage_threshold) + 1) / stage_threshold) / (stage_threshold / (stage_threshold + cargo.count))

                    local rand_x = qwer * (0 + explosives_aoe_modifier * explosives) * (((Prime_Random(2) + Rhythm.poly_index) % 2) == 1 and 1 or -1)
                    local rand_y = qwer * (0 + explosives_aoe_modifier * explosives) * (((Prime_Random(2) + Rhythm.poly_index) % 2) == 1 and 1 or -1)

                    local x_offset = 0
                    local y_offset = 0

                    if (i > 1) then
                        x_offset = rand_x * math.cos(2 * math.pi * ((((i % 32) + 0) / 1) / (cargo.count / 32)))
                        y_offset = rand_y * math.sin(2 * math.pi * ((((i % 32) + 0) / 1) / (cargo.count / 32)))
                    end

                    local target = {
                        x = target_position.x + x_offset,
                        y = target_position.y + y_offset,
                    }

                    local explosives_radius_limit = (explosives / 6.25) * (32 / (3 - explosives_aoe_modifier))

                    local loops = 64
                    local abs_x_offset = math.abs(x_offset)
                    local abs_y_offset = math.abs(y_offset)
                    while (((target_position.x - target.x) ^ 2 + (target_position.y - target.y) ^ 2) ^ 0.5) > explosives_radius_limit do
                        if (loops < 1) then break end

                        local rand = (Prime_Random(3) + Rhythm.poly_index) % 3

                        if (rand == 1) then
                            target.x = target_position.x + (Prime_Random(-1 - abs_x_offset, 1 + abs_x_offset)) * Rhythm.poly_sign
                            target.y = target_position.y + (Prime_Random(-1 - abs_y_offset, 1 + abs_y_offset)) * Rhythm.poly_sign

                            abs_x_offset = abs_x_offset ^ 0.9
                            abs_y_offset = abs_y_offset ^ 0.9
                        elseif (rand == 2) then
                            target.x = target_position.x + (Prime_Random(-1 - abs_x_offset, 1 + abs_x_offset)) * Rhythm.poly_sign
                            abs_x_offset = abs_x_offset ^ 0.9
                        else
                            target.y = target_position.y + (Prime_Random(-1 - abs_y_offset, 1 + abs_y_offset)) * Rhythm.poly_sign
                            abs_y_offset = abs_y_offset ^ 0.9
                        end
                        loops = loops - 1
                    end

                    local asdf = payload.icbm.target_surface.create_entity({
                        name = not quality_affected_prototypes[cargo.name] and name or name .. "-" .. (cargo.quality or "normal"),
                        position =  true_nukes_contiued
                                and Projectile_Placeholders[cargo.name]
                                and Projectile_Placeholders[cargo.name].warhead_projectile
                                and target
                                or
                                    target_position,
                        direction = defines.direction.south,
                        force = payload.force,
                        target = target,
                        source =    tesla_munition
                                and target
                                or
                                    true_nukes_contiued
                                and Projectile_Placeholders[cargo.name]
                                and Projectile_Placeholders[cargo.name].warhead_projectile
                                and target
                                or
                                    target_position,
                        --[[ TODO: Make configurable ]]
                        cause = payload.icbm.same_surface and payload.icbm.source_silo and payload.icbm.source_silo.valid and payload.icbm.source_silo or payload.force,
                        speed = Projectile_Placeholders[cargo.name] and Projectile_Placeholders[cargo.name].speed or 0.025 * math.exp(1) + 0.075 * math.exp(1) * ((0.001 * (Prime_Random(100))) ^ 0.666),
                        base_damage_modifiers = {
                            damage_modifier = name == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name }) or name == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_MODIFIER.name }) or 1,
                            damage_addition = name == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name }) or name == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BASE_DAMAGE_ADDITION.name }) or 1,
                            radius_modifier = 1,
                        },
                        bonus_damage_modifiers = {
                            damage_modifier = name == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name }) or payload.name == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_MODIFIER.name }) or 1,
                            damage_addition = name == "atomic-rocket" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name }) or payload.name == "atomic-warhead" and Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_BONUS_DAMAGE_ADDITION.name }) or 1,
                            radius_modifier = 1,
                        },
                    })
                end

                if (delivered < explosives) then
                    delivered = delivered + 1
                else
                    delivered = 0
                end

                total_delivered = total_delivered + 1

                :: continue ::
            end

            if (not payload.delivered) then payload.delivered = game.tick end
            payload.updated = game.tick

            for k, v in pairs(payload.keys) do
                if (Payloads[k]) then
                    if (Payloads[k][1]) then
                        local to_remove_indices = {}
                        for _i, _v in pairs(Payloads[k]) do
                            if (_v.rhythm_count and _v.rhythm_count == v) then
                                table.insert(to_remove_indices, _i)
                            end
                        end
                        if (#to_remove_indices > 0) then
                            for index = to_remove_indices[#to_remove_indices], 1, -1 do
                                local dgfs = table.remove(Payloads[k], index)
                            end
                        end

                        if (Payloads[k][1]) then
                            if (#Payloads[k] == 1) then
                                Payloads[k] = Payloads[k][1]
                            end
                        else
                            if (not next(Payloads[k])) then
                                Payloads[k] = nil
                            end
                        end
                    else
                        if (Payloads[k].rhythm_count and Payloads[k].rhythm_count == v) then
                            Payloads[k] = nil
                        end
                    end
                end
            end
        end
    end
end)

local did_init = false

-- function events.on_singleplayer_init(event)
--     log("events.on_singleplayer_init")

--     storage.is_multiplayer = false

--     Is_Singleplayer = true
--     Is_Multiplayer = false
-- end
-- Event_Handler:register_event({
--     event_name = "on_singleplayer_init",
--     source_name = "events.on_singleplayer_init",
--     func_name = "events.on_singleplayer_init",
--     func = events.on_singleplayer_init,
-- })

-- function events.on_multiplayer_init(event)
--     log("events.on_multiplayer_init")

--     storage.is_multiplayer = true

--     Is_Singleplayer = false
--     Is_Multiplayer = true
-- end
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

    Random = storage.random
    Prime_Indices = storage.prime_indices
    Rhythms.init_rhythm()
    Payloads = storage.payloads
    Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
    Quality_Prototypes = prototypes.quality

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
        event_name = "on_nth_tick",
        nth_tick = Configurable_Nukes_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name }) or 6,
        source_name = "configurable_nukes_controller.on_nth_tick",
        func_name = "configurable_nukes_controller.on_nth_tick",
        func = Configurable_Nukes_Controller.on_nth_tick,
    })

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

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = Payload_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name }) or (15 * 60),
        source_name = "payload_controller.on_nth_tick",
        func_name = "payload_controller.on_nth_tick",
        func = Payload_Controller.on_nth_tick,
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

function locals.init_rhythm(event)
    Log.debug(event)

    Event_Handler:unregister_event({
        event_name = "on_tick",
        source_name = "locals.init_rhythm",
    })

    Rhythms.init_rhythm()
end

function events.on_load()

    Random = storage.random
    Prime_Indices = storage.prime_indices

    Event_Handler:register_event({
        event_name = "on_tick",
        source_name = "locals.init_rhythm",
        func_name = "locals.init_rhythm",
        func = locals.init_rhythm,
    })

    Event_Handler:set_event_position({
        event_name = "on_tick",
        source_name = "locals.init_rhythm",
        new_position = 1,
    })

    Payloads = storage.payloads
    Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
    Quality_Prototypes = prototypes.quality

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
        event_name = "on_nth_tick",
        nth_tick = Configurable_Nukes_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SURFACE_PROCESSING_RATE.name }) or 6,
        source_name = "configurable_nukes_controller.on_nth_tick",
        func_name = "configurable_nukes_controller.on_nth_tick",
        func = Configurable_Nukes_Controller.on_nth_tick,
    })

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

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = Payload_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name }) or (15 * 60),
        source_name = "payload_controller.on_nth_tick",
        func_name = "payload_controller.on_nth_tick",
        func = Payload_Controller.on_nth_tick,
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

                Random = storage.random
                Prime_Indices = storage.prime_indices
                Rhythms.init_rhythm()
                Payloads = storage.payloads
                Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
                Quality_Prototypes = prototypes.quality

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