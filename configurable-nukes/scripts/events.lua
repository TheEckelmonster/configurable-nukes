--[[ Globals ]]
Did_Init = false

Constants = require("scripts.constants.constants")
Custom_Events = require("prototypes.custom-events.custom-events")
Filters = require("scripts.constants.filters")

Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Settings_Service = require("__TheEckelmonster-core-library__.scripts.services.settings-serivce")

Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

Payloads = {}
Projectile_Placeholders = {}
Payloader_Recipe_Prototypes = {}

Instantiable = {}

---

defines.inventory.cn_payload_vehicle = 1
defines.inventory.payloader = 1

---

local defines = defines

local direction = defines.direction
local prototypes = prototypes
local remote = remote
local script = script

local ipairs = ipairs
local pairs = pairs
local type = type
local next = next

local string = string
local string_format = string.format

local table = table
local table_insert = table.insert
local table_remove = table.remove

local math = math
local math_abs = math.abs
local math_exp = math.exp
local math_ceil = math.ceil
local math_cos = math.cos
local math_floor = math.floor
local math_random = math.random
local math_sin = math.sin

local PI = math.pi
local TWO_PI = 2 * PI

local Event_Handler = Event_Handler
local Settings_Service = Settings_Service
local get_runtime_global_setting = Settings_Service.get_runtime_global_setting

local true_nukes_contiued = script and script.active_mods and script.active_mods["True-Nukes_Continued"]

local Custom_Events = require("prototypes.custom-events.custom-events")
local Custom_Input = require("prototypes.custom-input.custom-input")

local Configurable_Nukes_Controller = require("scripts.controllers.configurable-nukes-controller")
local on_clamps_on_trigger = Configurable_Nukes_Controller.on_clamps_on_trigger

local Initialization = require("scripts.initialization")
local Rocket_Silo_Gui_Controller = require("scripts.controllers.guis.rocket-silo-gui-controller")
local Rocket_Dashboard_Gui_Controller = require("scripts.controllers.guis.rocket-dashboard-gui-controller")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Payload_Controller = require("scripts.controllers.payload-controller")
local Payloader_Controller = require("scripts.controllers.payloader-controller")
local Payloader_Gui_Controller = require("scripts.controllers.guis.payloader-gui-controller")
local Planet_Controller = require("scripts.controllers.planet-controller")
local Research_Controller = require("scripts.controllers.research-controller")
-- local Rhythm = require("scripts.rhythm")
local Rocket_Silo_Controller = require("scripts.controllers.rocket-silo-controller")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Target_Combinator_Controller = require("scripts.controllers.target-combinator-controller")

local Log_Settings = require("__TheEckelmonster-core-library__.libs.log.log-settings")
local Settings_Controller = require("__TheEckelmonster-core-library__.scripts.controllers.settings-controller")

local locals = {}
locals.name = "locals"

local valid_event_effect_ids =
{
    ["clamps_on_trigger"] = true,

    ["map-reveal"] = true,

    ["payload-delivered"] = true,

    ["atomic-bomb-pollution"] = true,
    ["atomic-warhead-pollution"] = true,
    ["k2-nuclear-turret-rocket-pollution"] = true,
    ["k2-atomic-artillery-pollution"] = true,
    ["saa-s-atomic-artillery-pollution"] = true,

    ["cn-jericho-fired"] = true,
    ["cn-tesla-rocket-fired"] = true,

    ["atomic-bomb-fired"] = true,
    ["kr-nuclear-turret-rocket-projectile-fired"] = true,
    ["kr-atomic-artillery-projectile-fired"] = true,
    ["atomic-artillery-shell-fired"] = true,
    ["cn-tesla-rocket-lightning"] = true,

    ["Atomic Weapon hit 20t"] = true_nukes_contiued and true or nil
}

-- if (script and script.active_mods and script.active_mods["quality"]) then
--     for k, quality in pairs(prototypes.quality) do
--         if (not quality.hidden) then
--             valid_event_effect_ids["jericho-delivered-" .. k] = true
--         end
--     end
-- else
--     valid_event_effect_ids["jericho-delivered-normal"] = true
-- end

local placeholders = {
    ["atomic-rocket"] = "atomic-rocket-normal",
    ["atomic-bomb"] = true_nukes_contiued and "atomic-bomb" or "atomic-rocket",
    ["kr-nuclear-artillery-shell"] = "kr-atomic-artillery-projectile",
    ["atomic-artillery-shell"] = "atomic-artillery-shell",
    ["cn-jericho"] = "jericho-payloader-rocket",
    ["Atomic Weapon hit 20t"] = true_nukes_contiued and "atomic-bomb" or nil,
}

local quality_affected_prototypes = {
    ["atomic-bomb"] = not true_nukes_contiued and "atomic-rocket" or nil,

    ["atomic-warhead"] = "atomic-warhead",
    ["cn-rod-from-god"] = "cn-rod-from-god",
    -- ["cn-jericho"] = "jericho-payloader-rocket",
    -- ["cn-jericho"] = "cn-jericho",
    ["cn-jericho"] = "cn-jericho-rocket",
    ["jericho-payloader-rocket"] = "jericho-payloader-rocket",
    ["cn-tesla-rocket"] = "cn-tesla-rocket",

    ["kr-nuclear-artillery-shell"] = "kr-nuclear-artillery-shell",
    ["atomic-artillery-shell"] = "atomic-artillery-shell",

    ["Atomic Weapon hit 20t"] = true_nukes_contiued and "atomic-rocket" or nil
}

local Quality_Prototypes = prototypes.quality

local to_init_storage = {
    -- Constants,
    Configurable_Nukes_Controller,
    Rocket_Silo_Gui_Controller,
    Payloader_Gui_Controller,
    Rocket_Dashboard_Gui_Controller,
    Payload_Controller,
    Payloader_Controller,
    -- Planet_Controller,
    Research_Controller,
    Rocket_Silo_Controller,
    -- Settings_Controller,
    Target_Combinator_Controller,
    require("scripts.data.ICBM-data"),
    require("scripts.repositories.configurable-nukes-repository"),
    require("scripts.repositories.force-launch-data-repository"),
    require("scripts.repositories.ICBM-meta-repository"),
    require("scripts.repositories.ICBM-repository"),
    require("scripts.repositories.rocket-silo-meta-repository"),
    require("scripts.repositories.rocket-silo-repository"),
    require("scripts.repositories.version-repository"),
    require("scripts.services.guis.rocket-dashboard-gui-service"),
    require("scripts.services.guis.payloader-gui-service"),
    require("scripts.services.guis.rocket-silo-gui-service"),
    require("scripts.services.circuit-network-service"),
    require("scripts.services.planet-service"),
    require("scripts.services.rocket-silo-service"),
    require("scripts.utils.ICBM-utils"),
    require("scripts.utils.rocket-silo-utils"),
    require("scripts.validations.rocket-silo-validations"),
    require("scripts.rhythm"),
}

function to_init_storage.reinit_all(event)
    for _, v in ipairs(to_init_storage) do
        v.init(storage)
    end
end
Event_Handler:register_events({
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = "to_init_storage.reinit_all",
        func_name = "to_init_storage.reinit_all",
        func = to_init_storage.reinit_all,
    },
    -- {
    --     event_name = Custom_Events.cn_migrations_applied.name,
    --     source_name = "to_init_storage.reinit_all",
    --     func_name = "to_init_storage.reinit_all",
    --     func = to_init_storage.reinit_all,
    -- },
    {
        event_name = "on_configuration_changed",
        source_name = "to_init_storage.on_configuration_changed",
        func_name = "to_init_storage.on_configuration_changed",
        func = to_init_storage.reinit_all,
    }
})

local events = {
    name = "events",
    [locals.name] = locals,
    [Configurable_Nukes_Controller.name] = Configurable_Nukes_Controller,
    [Custom_Input.name] = Custom_Input,
    [Rocket_Silo_Gui_Controller.name] = Rocket_Silo_Gui_Controller,
    [Rocket_Dashboard_Gui_Controller.name] = Rocket_Dashboard_Gui_Controller,
    [ICBM_Utils.name] = ICBM_Utils,
    [Payload_Controller.name] = Payload_Controller,
    [Payloader_Controller.name] = Payloader_Controller,
    [Planet_Controller.name] = Planet_Controller,
    [Research_Controller.name] = Research_Controller,
    [Rocket_Silo_Controller.name] = Rocket_Silo_Controller,
    [Settings_Controller.name] = Settings_Controller,
    [Target_Combinator_Controller.name] = Target_Combinator_Controller,
}

---

To_Set_Game = require("scripts.to-set-game")

---

local epd_active = script and script.active_mods and script.active_mods["even-pickier-dollies"] and true
local quality_active = script and script.active_mods and script.active_mods["quality"] and true
local quality_rockets_active = script and script.active_mods and script.active_mods["QualityRockets"]
local sa_active = script and script.active_mods and script.active_mods["space-age"] and true
local se_active = script and script.active_mods and script.active_mods["space-exploration"] and true

if (quality_rockets_active) then
    local Quality_Rockets_Controller = require("scripts.compatibility.QualityRockets-controller")
    events[Quality_Rockets_Controller.name] = Quality_Rockets_Controller
end

local cache = {}
local cache_attributes = {}
setmetatable(cache_attributes, { __mode = "k" })

cache.map_reveal = {}
cache.map_reveal.chunks = {}

events.DO_MAP_REVEAL = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DO_MAP_REVEAL.name }) or true

function events.on_runtime_mod_setting_changed(event)
    Log.debug("events.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (    event.setting == Runtime_Global_Settings_Constants.settings.DO_MAP_REVEAL.name
    ) then
        events.DO_MAP_REVEAL = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DO_MAP_REVEAL.name })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "events.on_runtime_mod_setting_changed",
    func_name = "events.on_runtime_mod_setting_changed",
    func = events.on_runtime_mod_setting_changed,
})

local game
local get_surface

local function set_game(__game)
    --[[ game ]]
    game = __game or _ENV.game
    get_surface = game.get_surface

    log(serpent.block(game))

    return game
end

local CHARACTER = "character"
local LIGHTNING = "lightning"
local PERCENT_POINT_2_F = "%.2f"
local FORWARD_SLASH = "/"
local EXPLOSIVES = "explosives"
local NUMBER = "number"
local EMPTY_STRING = ""
local TESLA = "tesla"
local DASH = "-"

--[[ TODO: Move this to its own controller/service/utils? ]]
script.on_event(defines.events.on_script_trigger_effect, function (event)
    -- Log.debug("script.on_event(defines.events.on_script_trigger_effect,...)")
    -- Log.info(event)

    if (    event and event.effect_id
        and not valid_event_effect_ids[event.effect_id]
    ) then
        -- Log.debug("returning")
        return
    end
    -- if (not game or not event.surface_index or game.get_surface(event.surface_index) == nil) then return end
    if (not game and not set_game() or not event.surface_index) then return end

    local surface = (game or set_game()) and get_surface(event.surface_index)
    if (not surface or not surface.valid) then return end

    if (event.effect_id == "clamps_on_trigger") then
        on_clamps_on_trigger(event)
    elseif (event.effect_id == "map-reveal") then
        if (not events.DO_MAP_REVEAL) then return end

        local position = event.target_position

        if (position == nil and event.target_entity and event.target_entity.valid) then
            position = event.target_entity.position
        end

        if (position) then
            local chunk_string = math_floor(position.x / 32) .. FORWARD_SLASH .. math_floor(position.y / 32)
            if (not cache.map_reveal.chunks[chunk_string] or not cache_attributes[cache.map_reveal.chunks[chunk_string]] or cache_attributes[cache.map_reveal.chunks[chunk_string]].time_to_live < game.tick) then
                cache.map_reveal.chunks[chunk_string] = { count = 0, }
                cache_attributes[cache.map_reveal.chunks[chunk_string]] = { time_to_live = game.tick + 75, valid = true }
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

        if (target == nil and event.source_position) then
            if (event.source_entity and event.cause_entity) then
                if (event.source_entity.valid and event.cause_entity.valid) then
                    if ((
                            event.source_entity == event.cause_entity
                        )
                        or (
                                event.source_entity.name == CHARACTER
                            or  event.cause_entity.name  == CHARACTER
                        )
                    ) then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            target = event.source_position
        end

        if (not target) then return end
        surface.execute_lightning({ name = LIGHTNING, position = target })
    elseif (event.effect_id == "cn-jericho-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

        local orientation = event.source_entity and event.source_entity.valid and (event.source_entity.type == "spider-vehicle" and event.source_entity.torso_orientation or event.source_entity.orientation)
        local _orientation = orientation
        orientation = math_floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                -- name = "cn-jericho" .. DASH .. quality,
                name = "cn-jericho-rocket" .. DASH .. quality,
                position = source,
                -- position = { source.x + 0.6 * math_cos(TWO_PI * ((_orientation - 0.25) % 1)), source.y + 0.6 * math_sin(TWO_PI * ((_orientation - 0.25) % 1)), },
                -- position = { source.x + 0.09 * math_cos(TWO_PI * _orientation), source.y + 0.09 * math_sin(TWO_PI * _orientation), },
                -- position = { source.x - 0.3, source.y + 0.3, },
                direction = direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                -- source = source,
                source = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math_exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = 1,
                    damage_addition = 1,
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = 1,
                    damage_addition = 1,
                    radius_modifier = 1,
                },
            })
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
        end
    elseif (event.effect_id == "cn-tesla-rocket-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

        local orientation = event.source_entity and event.source_entity.valid and (event.source_entity.type == "spider-vehicle" and event.source_entity.torso_orientation or event.source_entity.orientation)
        local _orientation = orientation
        orientation = math_floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                -- name = "cn-jericho" .. DASH .. quality,
                name = "cn-tesla-rocket" .. DASH .. quality,
                position = source,
                direction = direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math_exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = 1,
                    damage_addition = 1,
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = 1,
                    damage_addition = 1,
                    radius_modifier = 1,
                },
            })
            if (entity and entity.valid and event.source_entity.type == "spider-vehicle") then entity.orientation = _orientation end
        end
    elseif (event.effect_id == "atomic-bomb-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

        local orientation = event.source_entity and event.source_entity.valid and (event.source_entity.type == "spider-vehicle" and event.source_entity.torso_orientation or event.source_entity.orientation)
        local _orientation = orientation
        orientation = math_floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "atomic-rocket" .. DASH .. quality,
                position = source,
                direction = direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math_exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name }),
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
                name = "atomic-rocket" .. DASH .. quality,
                position = target,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = target,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
                base_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_BOMB_BONUS_DAMAGE_ADDITION.name }),
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
        orientation = math_floor(orientation * 16)

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "kr-nuclear-turret-rocket-projectile" .. DASH .. quality,
                position = source,
                direction = direction[Constants.direction_table[orientation]],
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                -- speed = 0.1 * math_exp(1),
                speed = 0.05,
                base_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_BONUS_DAMAGE_ADDITION.name }),
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
                name = "kr-atomic-artillery-projectile" .. DASH .. quality,
                position = source,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
                base_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    radius_modifier = 1,
                },
            })
        end
    elseif (event.effect_id == "atomic-artillery-shell-fired") then
        local source, target = event.source_position, event.target_position
        local quality = event.quality
        quality = quality and Quality_Prototypes[quality] and quality or "normal"

        if (target == nil and event.target_entity and event.target_entity.valid) then
            target = event.target_entity.position
        end

        if (source ~= nil and target ~= nil) then
            local entity = surface.create_entity({
                name = "atomic-artillery-shell" .. DASH .. quality,
                position = source,
                force = event.cause_entity and event.cause_entity.valid and event.cause_entity.force or "player",
                target = target,
                source = source,
                cause = event.cause_entity and event.cause_entity.valid and event.cause_entity,
                speed = 1,
                base_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BASE_DAMAGE_ADDITION.name }),
                    radius_modifier = 1,
                },
                bonus_damage_modifiers = {
                    damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_BONUS_DAMAGE_MODIFIER.name }),
                    radius_modifier = 1,
                },
            })
        end
    elseif (event.effect_id:find("%-pollution")) then
        local position = event.source_position or event.target_position

        if (position) then
            if (event.effect_id == "atomic-bomb-pollution") then
                surface.pollute(position, get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.POLLUTION.name }), "atomic-rocket-normal")
            elseif (event.effect_id == "atomic-warhead-pollution") then
                surface.pollute(position, get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ATOMIC_WARHEAD_POLLUTION.name }), "atomic-warhead-normal")
            elseif (event.effect_id == "k2-nuclear-turret-rocket-pollution") then
                surface.pollute(position, get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_POLLUTION.name }), "kr-nuclear-turret-rocket-projectile-normal")
            elseif (event.effect_id == "k2-atomic-artillery-pollution") then
                surface.pollute(position, get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_POLLUTION.name }), "kr-atomic-artillery-projectile-normal")
            elseif (event.effect_id == "saa-s-atomic-artillery-pollution") then
                surface.pollute(position, get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_POLLUTION.name }), "atomic-artillery-projectile-normal")
            end
        end
    elseif (event.effect_id == "payload-delivered") then
        local target_position = event.target_position
        local source_position = event.source_position

        if (target_position and target_position.x and target_position.y) then
            local position_key = string_format(PERCENT_POINT_2_F, math_floor(target_position.x * 100) / 100) .. FORWARD_SLASH .. string_format(PERCENT_POINT_2_F, math_floor(target_position.y * 100) / 100)
            local position_key_target = string_format(PERCENT_POINT_2_F, math_floor(target_position.x * 100) / 100) .. FORWARD_SLASH .. string_format(PERCENT_POINT_2_F, math_floor(target_position.y * 100) / 100)
            local position_key_source = string_format(PERCENT_POINT_2_F, math_floor(source_position.x * 100) / 100) .. FORWARD_SLASH .. string_format(PERCENT_POINT_2_F, math_floor(source_position.y * 100) / 100)
            local payload = nil
            local removed = false
            local i = 1
            while payload == nil and i <= 6 do
                position_key_target = string_format(PERCENT_POINT_2_F, math_floor(target_position.x * 100) / 100) .. FORWARD_SLASH .. string_format(PERCENT_POINT_2_F, math_floor(target_position.y * 100) / 100) .. DASH .. i
                if (Payloads[position_key_target] and Payloads[position_key_target][1]) then
                    payload = table.remove(Payloads[position_key_target], 1)
                    removed = true
                    position_key = position_key_target
                end
                payload = payload or Payloads[position_key_target] or nil

                if (not payload) then
                    position_key_source = string_format(PERCENT_POINT_2_F, math_floor(source_position.x * 100) / 100) .. FORWARD_SLASH .. string_format(PERCENT_POINT_2_F, math_floor(source_position.y * 100) / 100) ..  DASH ..i
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
                    payload = table_remove(payload, 1)
                    removed = true
                end

                if (Payloads[position_key] and #Payloads[position_key] and not removed) then Payloads[position_key] = Payloads[position_key][1] end

                i = i + 1
            end

            log(serpent.block(payload))
            local payloads = payload and payload.icbm and payload.icbm.cargo and payload.icbm.cargo[1] and payload.icbm.cargo or payload and payload.cargo and (payload.cargo[1] and payload.cargo or { payload.cargo, }) or nil
            log(serpent.block(payloads))
            if (payloads and not next(payloads)) then payloads = nil end

            if (get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.LEGACY_LAUNCH_SYSTEM_ENABLED.name, })) then
                payload = payload or { cargo = {}, }
                payloads = payloads or {}

                if (payloads ~= payload.cargo) then
                    if (payload.cargo and payload.cargo[1]) then
                        -- for i, cargo in pairs(payload.cargo) do
                        for i, cargo in ipairs(payload.cargo) do
                            table_insert(payloads, cargo)
                        end
                    else
                        local existing = false
                        -- for _, _payload in pairs(payloads) do
                        for _, _payload in ipairs(payloads) do
                            if (_payload == payload.cargo) then existing = true; break end
                        end

                        if (not existing) then
                            table_insert(payloads, payload.cargo)
                        end
                    end
                end
            end

            -- if (Log.get_log_level().num_val <= 3) then
                log(serpent.block(payload))
                log(serpent.block(payloads))
            -- end

            if (not payload or not payloads) then return end

            if (payload) then
                if (payload.delivered and game.tick - payload.updated > 150) then
                    return
                elseif (
                        not payload.tick
                    or
                        payload.icbm
                    and payload.icbm.tick_to_target
                    and payload.icbm.tick_to_target <= event.tick
                    and event.tick - payload.icbm.tick_to_target >= 150
                    or
                        event.tick > payload.tick
                    and event.tick - payload.tick >= 150
                ) then
                    return
                end
            end

            local delivered = 0
            local total_delivered = 0

            local explosives = 0
            local explosives_aoe_modifier = 0
            explosives_aoe_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_EXPLOSIVES_AOE_MULTIPLIER.name, })
            if (payload.icbm and payload.icbm.cargo_dictionary and payload.icbm.cargo_dictionary[EXPLOSIVES]) then
                explosives = payload.icbm.cargo_dictionary[EXPLOSIVES].count
            end

            -- local area_setting = Settings_Service.get_startup_setting({ setting = Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER.name, reindex = true })
            -- if (area_setting == nil) then area_setting = 1 end

            if (payload.cargo and payload.cargo[1] and payload.cargo[1].mirv) then
                payloads = payload.cargo or {}
                log(serpent.block(payloads))
            end

            for _, cargo in ipairs(payloads) do
                cargo.count = type(cargo.count) == NUMBER and cargo.count > 0 and cargo.count or 1
                local stage_threshold = math_ceil(cargo.count / 8)

                local name = Projectile_Placeholders[cargo.name] and Projectile_Placeholders[cargo.name].name or ""
                log(serpent.block(name))

                if (placeholders[cargo.name]) then name = placeholders[cargo.name] end
                log(serpent.block(cargo.name))
                log(serpent.block(name))
                if (name == EMPTY_STRING) then goto continue end

                local tesla_munition = false
                if (name:find(TESLA)) then tesla_munition = true end

                local final_name = not quality_affected_prototypes[cargo.name] and name or nil
                if (not final_name) then
                    -- if (quality_affected_prototypes[cargo.name]) then
                    --     final_name = quality_affected_prototypes[cargo.name] .. DASH .. cargo.quality
                    -- elseif (quality_affected_prototypes[name]) then
                    --     final_name = quality_affected_prototypes[name] .. DASH .. cargo.quality
                    -- else
                    --     final_name = name
                    -- end
                    if (quality_active) then
                        if (quality_affected_prototypes[cargo.name]) then
                            final_name = quality_affected_prototypes[cargo.name] .. DASH .. cargo.quality
                        elseif (quality_affected_prototypes[name]) then
                            final_name = quality_affected_prototypes[name] .. DASH .. cargo.quality
                        else
                            final_name = name
                        end
                    else
                        final_name = name
                    end
                end

                for i = 1, cargo.count, 1 do
                    --[[ Not really sure what this should be named, as I don't fully understand/remember why introducing this variable fixed things ]]
                    local qwer = (((i % stage_threshold) + 1) / stage_threshold) / (stage_threshold / (stage_threshold + cargo.count))

                    local rand_x = qwer * (0 + explosives_aoe_modifier * explosives) * (math_random() > 0.5 and 1 or -1)
                    local rand_y = qwer * (0 + explosives_aoe_modifier * explosives) * (math_random() > 0.5 and 1 or -1)

                    local x_offset = 0
                    local y_offset = 0

                    if (i > 1) then
                        x_offset = rand_x * math_cos(TWO_PI * ((((i % 32) + 0) / 1) / (cargo.count / 32)))
                        y_offset = rand_y * math_sin(TWO_PI * ((((i % 32) + 0) / 1) / (cargo.count / 32)))
                    end

                    local target = {
                        x = target_position.x + x_offset,
                        y = target_position.y + y_offset,
                    }

                    local explosives_radius_limit = (explosives / 6.25) * (32 / (3 - explosives_aoe_modifier))

                    local loops = 64
                    local abs_x_offset = math_abs(x_offset)
                    local abs_y_offset = math_abs(y_offset)
                    while (((target_position.x - target.x) ^ 2 + (target_position.y - target.y) ^ 2) ^ 0.5) > explosives_radius_limit do
                        if (loops < 1) then break end

                        local rand = math_random(3)

                        if (rand == 1) then
                            target.x = target_position.x + (math_random(-1 - abs_x_offset, 1 + abs_x_offset))
                            target.y = target_position.y + (math_random(-1 - abs_y_offset, 1 + abs_y_offset))

                            abs_x_offset = abs_x_offset ^ 0.9
                            abs_y_offset = abs_y_offset ^ 0.9
                        elseif (rand == 2) then
                            target.x = target_position.x + (math_random(-1 - abs_x_offset, 1 + abs_x_offset))
                            abs_x_offset = abs_x_offset ^ 0.9
                        else
                            target.y = target_position.y + (math_random(-1 - abs_y_offset, 1 + abs_y_offset))
                            abs_y_offset = abs_y_offset ^ 0.9
                        end
                        loops = loops - 1
                    end

                    log(serpent.block(final_name))

                    local asdf = payload.icbm.target_surface.create_entity({
                        name = final_name,
                        position =  true_nukes_contiued
                                and Projectile_Placeholders[cargo.name]
                                and Projectile_Placeholders[cargo.name].warhead_projectile
                                and target
                                or
                                    target_position,
                        direction = direction.south,
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
                        speed = Projectile_Placeholders[cargo.name] and Projectile_Placeholders[cargo.name].speed or 0.025 * math_exp(1) + 0.075 * math_exp(1) * ((0.001 * (math_random(100))) ^ 0.666),
                        base_damage_modifiers = {
                            damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BASE_DAMAGE_MODIFIER.name }) or 1,
                            damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BASE_DAMAGE_ADDITION.name }) or 1,
                            radius_modifier = 1,
                        },
                        bonus_damage_modifiers = {
                            damage_modifier = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BONUS_DAMAGE_MODIFIER.name }) or 1,
                            damage_addition = get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BONUS_DAMAGE_ADDITION.name }) or 1,
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
    else
        log(serpent.block(event))
        log("how?")
    end
end)

function events.on_init()
    -- log("events.on_init")

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

    Constants.init(storage)
    Constants.get_mod_data(true, { on_load = true })

    Initialization.init({ maintain_data = false })

    Payloads = storage.payloads
    Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
    -- Quality_Prototypes = prototypes.quality

    if (epd_active) then
        local event_num = remote.call("PickerDollies", "dolly_moved_entity_id")

        if (event_num ~= nil and type(event_num) == "number") then
            local event_position = Event_Handler:get_event_position({
                event_name = event_num,
                source_name = "payloader_controller.PickerDollies_event",
            })

            if (event_position == nil) then
                Event_Handler:register_event({
                    event_num = event_num,
                    fallback_event_name = "dolly_moved_entity_id",
                    source_name = "payloader_controller.PickerDollies_event",
                    func_name = "payloader_controller.PickerDollies_event",
                    func = Payloader_Controller.PickerDollies_event,
                })
            end
        end
    end

    if (se_active) then
        -- local event_num = remote.call("space-exploration", "get_on_zone_surface_created_event")
        local event_num = prototypes.custom_event["se-on_zone_surface_created_event"]

        if (event_num ~= nil and type(event_num) == "number") then
            local event_position = Event_Handler:get_event_position({
                event_name = event_num,
                source_name = "planet_Controller.on_surface_created",
            })

            if (event_position == nil) then
                Event_Handler:register_event({
                    event_num = event_num,
                    fallback_event_name = "on_zone_surface_created",
                    source_name = "planet_Controller.on_surface_created",
                    func_name = "planet_Controller.on_surface_created",
                    func = Planet_Controller.on_surface_created,
                })
            end
        end
    end

    -- Event_Handler:register_event({
    --     event_name = "on_nth_tick",
    --     nth_tick = Configurable_Nukes_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name }) or 6,
    --     source_name = "configurable_nukes_controller.on_nth_tick",
    --     func_name = "configurable_nukes_controller.on_nth_tick",
    --     func = Configurable_Nukes_Controller.on_nth_tick,
    -- })

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = 20,
        source_name = "rocket_dashboard_gui_controller.on_nth_tick.instantiate_if_not_exists",
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

    for _, v in ipairs(to_init_storage) do v.init(_ENV.storage) end
    Did_Init = true
end
Event_Handler:register_event({
    event_name = "on_init",
    source_name = "events.on_init",
    func_name = "events.on_init",
    func = events.on_init,
})

local initialized_from_load = false

--[[ on_load ]]
function events.on_load()
    -- log("events.on_load()")

    Payloads = storage.payloads
    Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
    -- Quality_Prototypes = prototypes.quality

    -- local se_active = script and script.active_mods and script.active_mods["space-exploration"]

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

    if (epd_active) then
        local event_num = remote.call("PickerDollies", "dolly_moved_entity_id")

        if (event_num ~= nil and type(event_num) == "number") then
            local event_position = Event_Handler:get_event_position({
                event_name = event_num,
                source_name = "payloader_controller.PickerDollies_event",
            })

            if (event_position == nil) then
                Event_Handler:register_event({
                    event_num = event_num,
                    fallback_event_name = "dolly_moved_entity_id",
                    source_name = "payloader_controller.PickerDollies_event",
                    func_name = "payloader_controller.PickerDollies_event",
                    func = Payloader_Controller.PickerDollies_event,
                })
            end
        end
    end

    if (se_active) then
        -- local event_num = remote.call("space-exploration", "get_on_zone_surface_created_event")
        local event_num = prototypes.custom_event["se-on_zone_surface_created_event"]

        if (type(event_num) == "number") then
            local event_position = Event_Handler:get_event_position({
                event_name = event_num,
                source_name = "planet_Controller.on_surface_created",
            })

            if (event_position == nil) then
                Event_Handler:register_event({
                    event_num = event_num,
                    fallback_event_name = "on_zone_surface_created",
                    source_name = "planet_Controller.on_surface_created",
                    func_name = "planet_Controller.on_surface_created",
                    func = Planet_Controller.on_surface_created,
                })
            end
        end
    end

    -- Event_Handler:register_event({
    --     event_name = "on_nth_tick",
    --     nth_tick = Configurable_Nukes_Controller.nth_tick_rocket_silo_processing or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ROCKET_SILO_PROCESSING_RATE.name }) or 6,
    --     source_name = "configurable_nukes_controller.on_nth_tick",
    --     func_name = "configurable_nukes_controller.on_nth_tick",
    --     func = Configurable_Nukes_Controller.on_nth_tick,
    -- })

    Event_Handler:register_event({
        event_name = "on_nth_tick",
        nth_tick = 20,
        source_name = "rocket_dashboard_gui_controller.on_nth_tick.instantiate_if_not_exists",
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
        nth_tick = Payload_Controller.nth_tick or Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOAD_BACKGROUND_CLEANING_RATE.name }) or (5 * 60),
        source_name = "payload_controller.on_nth_tick",
        func_name = "payload_controller.on_nth_tick",
        func = Payload_Controller.on_nth_tick,
    })

    Constants.init(_ENV.storage)
    Constants.get_mod_data(true, { on_load = true })

    Event_Handler:on_load_restore({ events = events })

    for _, v in ipairs(to_init_storage) do v.init(_ENV.storage) end
end
Event_Handler:register_event({
    event_name = "on_load",
    source_name = "events.on_load",
    func_name = "events.on_load",
    func = events.on_load,
})

function events.on_configuration_changed(event)
    -- log(serpent.block("events.on_configuration_changed"))
    -- log(serpent.block(event))

    if (event.mod_changes) then
        --[[ Check if our mod updated ]]
        if (event.mod_changes["configurable-nukes"]) then
            if (not Did_Init) then
                (game or set_game() or _ENV.game).print({ Constants.mod_name .. ".on-configuration-changed", Constants.mod_name })

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
                storage.initialized_anew = game.tick

                Payloads = storage.payloads
                Projectile_Placeholders = prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"].data
                -- Quality_Prototypes = prototypes.quality

                local cn_controller_data = storage and storage.configurable_nukes_controller or {}

                cn_controller_data.reinitialized = true
                cn_controller_data.reinit_tick = game.tick

                cn_controller_data.initialized = true
                cn_controller_data.init_tick = game.tick

                -- Constants.get_mod_data(true)

                storage.configurable_nukes_controller = {
                    tick = game.tick,
                }

                for _, v in ipairs(to_init_storage) do v.init(_ENV.storage) end
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