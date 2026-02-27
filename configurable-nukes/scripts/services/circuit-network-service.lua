local Cache_Attributes_Data = require("scripts.data.cache.cache-attribute-data")
local CU = require("scripts.utils.cache-utils")
local Cache_Utils, Reinit_Cache = CU[1], CU[2]
local Custom_Events = require("prototypes.custom-events.custom-events")
local Hash_Key_Data = require("scripts.data.hash-key-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local Rhythm = require("scripts.rhythm")
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local circuit_network_service = {}
circuit_network_service.name = "circuit_network_service"

circuit_network_service.rhythm = { name = circuit_network_service.name, }
local rhythm = Rhythm.new(circuit_network_service.rhythm, circuit_network_service.rhythm)
local Prime_Random = Rhythm.prime_random

Event_Handler:register_events({
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = circuit_network_service.name .. ".init_rhythm",
        func_name = rhythm.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_reset_cache.name,
        source_name = circuit_network_service.name .. ".init_rhythm",
        func_name = rhythm.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_on_init_complete.name,
        source_name = circuit_network_service.name .. ".init_rhythm",
        func_name = circuit_network_service.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_reset_cache.name,
        source_name = circuit_network_service.name .. ".init_rhythm",
        func_name = circuit_network_service.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
        func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
    },
    {
        event_name = Custom_Events.cn_init_cache.name,
        source_name = circuit_network_service.name .. ".init_rhythm",
        func_name = circuit_network_service.name .. ".init_rhythm",
        func = rhythm.init_rhythm,
    },
})

local cache_handle = Cache_Utils.register_cache({ name = circuit_network_service.name, })
circuit_network_service.cache_handle = cache_handle
Event_Handler:register_events(
{
    event_name = Custom_Events.cn_init_cache.name,
    source_name = circuit_network_service.name .. ".reinit_cache",
    func_name = circuit_network_service.name .. ".reinit_cache",
    func = circuit_network_service.reinit_cache,
})

local hash_keys = nil
local cache, cache_attributes = nil, nil

circuit_network_service.__reinit_cache = Reinit_Cache
function circuit_network_service.reinit_cache()
    cache_handle.__reinit_cache()
    cache, cache_attributes = circuit_network_service:__reinit_cache()

    storage.hash_keys = storage.hash_keys or Hash_Key_Data:new({})
    Hash.keys = Hash.keys or storage.hash_keys

    storage.hash_keys[cache_handle.name] = storage.hash_keys[cache_handle.name] or Hash_Key_Data:new({ name = cache_handle.name, })
    hash_keys = storage.hash_keys[cache_handle.name]

    hash_keys["surfaces"] = Hash.keys[hash_keys["surfaces"] or false] and hash_keys[hash_string] or Hash.hash("surfaces", { persist = true, })
    cache[hash_keys["surfaces"]] = cache[hash_keys["surfaces"]] or {}
    cache_attributes[cache[hash_keys["surfaces"]]] = cache_attributes[cache[hash_keys["surfaces"]]] or Cache_Attributes_Data:new({ cas = cache_attributes, k = cache[hash_keys["surfaces"]], })

    hash_keys["rocket_silos"] = Hash.keys[hash_keys["rocket_silos"] or false] and hash_keys[hash_string] or Hash.hash("rocket_silos", { persist = true, })
    cache[hash_keys["rocket_silos"]] = cache[hash_keys["rocket_silos"]] or {}
    cache_attributes[cache[hash_keys["rocket_silos"]]] = cache_attributes[cache[hash_keys["rocket_silos"]]] or Cache_Attributes_Data:new({ cas = cache_attributes, k = cache[hash_keys["rocket_silos"]], })
end
cache_handle.reinit_cache = circuit_network_service.reinit_cache

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local rocket_ready_status = defines.rocket_silo_status.rocket_ready

function circuit_network_service.attempt_launch_silos(data)
    Log.debug("circuit_network_service.attempt_launch_silos")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (type(data.rocket_silos) ~= "table" or not next(data.rocket_silos)) then return end

    local cache, cache_attributes = Cache(cache_handle.name), Cache_Attributes(cache_handle.name)

    storage.hash_keys = storage.hash_keys or {}
    storage.hash_keys[cache_handle.name] = storage.hash_keys[cache_handle.name] or {}
    hash_keys = storage.hash_keys[cache_handle.name]
    local hash_string = nil

    local return_val = 0

    local allow_targeting_origin = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name })
    local allow_launch_when_no_surface_selected = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ALLOW_LAUNCH_WHEN_NO_SURFACE_SELECTED.name })
    local allow_icbm_multisurface = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })

    local _, v = next(data.rocket_silos)
    if (v and v.entity and v.entity.valid) then
        local key = "unit_number=" .. tostring(v.entity.unit_number)

        hash_string = "rocket_silos"
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val = cache[hash_keys[hash_string]] or {},
        })
        local rocket_silos = cache[hash_keys["rocket_silos"]]

        hash_string = "rocket_silos." .. key
        hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
        cache[hash_keys[hash_string]], _ = cache_handle.get_or_instantiate({
            tbl = cache,
            key = hash_keys[hash_string],
            val =   cache[hash_keys[hash_string]]
                or
                    rocket_silos
                and (function ()
                    local k, v = next(rocket_silos)
                    return k and { v, } or nil
                end)()
                or
                    v.entity.valid
                and { v.entity, }
                or  {},
        })
        local rocket_silo = cache[hash_keys[hash_string]]
        rocket_silo = rocket_silo and rocket_silo[1]

        if (rocket_silo and not rocket_silo.valid) then
            cache[hash_keys[hash_string]] = nil
            if (type(_) == "table" and _.type and _.type == "cache-attribute") then
                _.valid = false
                _.ttl = game.tick - 1
                _.updated = game.tick
                cache_attributes[_.k or false] = nil
            end
        end
        if (_) then _ = nil end

        if (rocket_silo and rocket_silo.rocket_silo_status == rocket_ready_status) then
            hash_string = "rocket_silos." .. key .. ".circuit_network_red"
            hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
            cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                tbl = cache,
                key = hash_keys[hash_string],
                val =   cache[hash_keys[hash_string]] or { circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_red) },
            })

            hash_string = "rocket_silos." .. key .. ".circuit_network_green"
            hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
            cache[hash_keys[hash_string]] = cache_handle.get_or_instantiate({
                tbl = cache,
                key = hash_keys[hash_string],
                val =   cache[hash_keys[hash_string]] or { circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_green) },
            })

            local circuit_network_red = cache[hash_keys["rocket_silos." .. key .. ".circuit_network_red"]].circuit_network
            local circuit_network_green = cache[hash_keys["rocket_silos." .. key .. ".circuit_network_green"]].circuit_network

            if (not circuit_network_red and not circuit_network_green) then goto continue end
            if (   (circuit_network_red and circuit_network_red.valid and circuit_network_red.entity and circuit_network_red.entity.valid)
                or (circuit_network_green and circuit_network_green.valid and circuit_network_green.entity and circuit_network_green.entity.valid))
            then
                hash_string = "surfaces." .. rocket_silo.surface.name .. "." .. key
                hash_keys[hash_string] = Hash.keys[hash_keys[hash_string] or false] and hash_keys[hash_string] or Hash.hash(hash_string, { persist = true, })
                if (_) then _ = nil end
                cache[hash_keys[hash_string]], _ = cache_handle.get_or_instantiate({
                    tbl = cache,
                    key = hash_keys[hash_string],
                    val =   cache[hash_keys[hash_string]]
                        or  function ()
                            local ret = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
                            if (not ret or not ret.valid) then
                                ret = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                                ret = ret and ret.valid and ret or nil
                            end
                            return ret
                        end,
                    ttl =  game.tick + 200 + Prime_Random(rhythm, 100),
                })

                local rocket_silo_data, rsd_attr = cache[hash_keys["surfaces." .. rocket_silo.surface.name .. "." .. key]], _
                if (_) then _ = nil end
                if (not rocket_silo_data or not rocket_silo_data.valid) then goto continue end
                if (not rsd_attr) then
                    rsd_attr = cache_attributes[rocket_silo_data]
                    if (not rsd_attr) then
                        goto continue
                    end
                end

                local is_orbit_surface = false
                if (rocket_silo_data.surface and rocket_silo_data.surface.valid) then
                    is_orbit_surface = rsd_attr.is_orbit_surface
                    if (is_orbit_surface == nil) then
                        is_orbit_surface = rocket_silo_data.surface.name:lower():find(" orbit", 1, true) ~= nil
                    end
                    rsd_attr.is_orbit_surface = is_orbit_surface
                end

                if (rsd_attr.is_ipbm_silo == nil) then
                    rsd_attr.is_ipbm_silo = rocket_silo_data:is_ipbm_silo()
                end

                local is_ipbm_silo = rsd_attr.is_ipbm_silo

                local space_location_gui_available =   allow_icbm_multisurface
                                                    or is_ipbm_silo

                local orbit_to_surface_gui_available =      not space_location_gui_available
                                                        and not is_ipbm_silo
                                                        and se_active
                                                        and is_orbit_surface

                --[[ Get previously selected signals, if they exist ]]

                local red_signal_x = 0
                local red_signal_y = 0
                local red_signal_space_location_index = 0
                local red_signal_launch = 0
                local red_signal_origin_override = 0

                -- Check for signals from the red circuit-network if it exists
                if (circuit_network_red and circuit_network_red.valid) then
                    red_signal_x = rocket_silo_data.circuit_network_data.signals.x ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.x) or 0
                    red_signal_y = rocket_silo_data.circuit_network_data.signals.y ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.y) or 0
                    red_signal_space_location_index = rocket_silo_data.circuit_network_data.signals.space_location_index ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.space_location_index) or 0
                    red_signal_launch = rocket_silo_data.circuit_network_data.signals.launch ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.launch) or 0
                    red_signal_origin_override = rocket_silo_data.circuit_network_data.signals.origin_override ~= nil and circuit_network_red.get_signal(rocket_silo_data.circuit_network_data.signals.origin_override) or 0
                end

                local green_signal_x = 0
                local green_signal_y = 0
                local green_signal_space_location_index = 0
                local green_signal_launch = 0
                local green_signal_origin_override = 0

                -- Check for signals from the green circuit-network if it exists
                if (circuit_network_green and circuit_network_green.valid) then
                    green_signal_x = rocket_silo_data.circuit_network_data.signals.x and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.x) or 0
                    green_signal_y = rocket_silo_data.circuit_network_data.signals.y and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.y) or 0
                    green_signal_space_location_index = rocket_silo_data.circuit_network_data.signals.space_location_index and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.space_location_index) or 0
                    green_signal_launch = rocket_silo_data.circuit_network_data.signals.launch and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.launch) or 0
                    green_signal_origin_override = rocket_silo_data.circuit_network_data.signals.origin_override ~= nil and circuit_network_green.get_signal(rocket_silo_data.circuit_network_data.signals.origin_override) or 0
                end

                --[[ Aggregate the signals from the red and/or green circuit-networks
                    -> Currently just adding the red and green signal values together for each signal
                ]]
                local signal_x = red_signal_x + green_signal_x
                local signal_y = red_signal_y + green_signal_y
                local signal_space_location_index = red_signal_space_location_index + green_signal_space_location_index
                local signal_launch = red_signal_launch + green_signal_launch

                --[[ Intentionally letting it be nil in the case of either the settings being disabled ]]
                local signal_origin_override =  allow_targeting_origin
                                            and (red_signal_origin_override + green_signal_origin_override)
                                            or nil
                local require_space_location = rocket_silo_data.circuit_network_data.require_space_location


                if (signal_x and signal_y and signal_launch) then
                    if (type(signal_x) == "number" and type(signal_y) == "number" and type(signal_launch) == "number") then
                        if (        (signal_launch > 0
                                and (  signal_x ~= 0
                                    or signal_y ~= 0))
                            or
                                (signal_launch > 0
                                and allow_targeting_origin
                                and type(signal_origin_override) == "number"
                                and signal_origin_override > 0))
                        then
                            local entity_red = circuit_network_red and circuit_network_red.valid and circuit_network_red.entity or nil
                            local entity_green = circuit_network_green and circuit_network_green.valid and circuit_network_green.entity or nil
                            local entity = nil
                            if (entity_red ~= nil and entity_green ~= nil) then
                                if (entity_red == entity_green) then
                                    entity = entity_red
                                end
                            else
                                if (entity_red) then
                                    entity = entity_red
                                elseif (entity_green) then
                                    entity = entity_green
                                end
                            end

                            local target_surface_name = rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_name
                            if (not space_location_gui_available and orbit_to_surface_gui_available) then
                                target_surface_name = rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name
                            end
                            local target_index = rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_index

                            if (target_surface_name == nil --[[ No surface has been selected yet ]]) then
                                target_surface_name = "cn-none"
                                target_index = -1
                            end
                            if (target_index == nil) then
                                target_index = -1
                            end

                            local target_surface = nil
                            local orbit_to_surface = nil

                            --[[ Check is a space-location-index is being provided via circuit-network signal ]]
                            if ((space_location_gui_available or orbit_to_surface_gui_available) and signal_space_location_index ~= nil and type(signal_space_location_index) == "number" and signal_space_location_index >= 1) then
                                --[[ Try and get the surface based on the provided space location signal index ]]
                                target_surface = game.get_surface(signal_space_location_index)
                                if (target_surface and target_surface.valid) then
                                    if (orbit_to_surface_gui_available) then
                                        if (target_surface and target_surface.valid) then
                                            if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                            if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                                Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                                goto continue
                                            end

                                            local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                            if (space_location and space_location.parent and target_surface == space_location.parent.surface) then
                                                orbit_to_surface = true
                                            else
                                                target_surface = nil
                                            end
                                        end
                                    elseif (space_location_gui_available) then
                                        --[[ Verify that the target surface is among known potential surfaces
                                            -> Nameley trying to avoid targetting a surface that isn't actually supposed to be targetable
                                            -> First example: aai-signals surface
                                        ]]
                                        if (not Constants.mod_data_dictionary) then Constants.get_mod_data(true) end

                                        if (se_active) then
                                            if (not Constants.mod_data_dictionary["se-" .. target_surface.name:lower()]) then
                                                target_surface = nil
                                            end
                                        else
                                            if (not Constants.mod_data_dictionary[target_surface.name:lower()]) then
                                                target_surface = nil
                                            end
                                        end
                                    end
                                else
                                    target_surface = nil
                                end
                            end

                            --[[ Check if firing from an orbit surface ]]
                            local from_platform = rocket_silo.surface.name:find("platform-", 1, true) ~= nil and sa_active
                            local from_se_orbit = rocket_silo.surface.name:lower():find(" orbit", 1, true) ~= nil and se_active

                            if (target_surface == nil) then
                                --[[ Can the player even select a space-location to target? ]]
                                if (space_location_gui_available or orbit_to_surface_gui_available) then
                                    if (target_surface_name == "cn-none") then
                                        --[[ and if self-surface targeting allowed when no target explicitly selected ]]
                                        if (allow_launch_when_no_surface_selected) then
                                            --[[ and if explicit space_location not required for this rocket-silo]]
                                            if (not require_space_location) then
                                                if (from_platform) then
                                                    if (rocket_silo.surface.platform) then
                                                        local space_location = rocket_silo.surface.platform.space_location

                                                        if (space_location and space_location.valid and space_location.name ~= nil) then
                                                            target_surface = game.get_surface(space_location.name)
                                                            orbit_to_surface = true
                                                        end
                                                    end
                                                elseif (from_se_orbit) then
                                                    if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                                    if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                                        Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                                        goto continue
                                                    end

                                                    local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                                    if (space_location and space_location.parent and space_location.parent.surface_index and space_location.parent.surface_index > 0) then
                                                        target_surface = game.get_surface(space_location.parent.surface_index)
                                                        orbit_to_surface = true
                                                    end
                                                else
                                                    target_surface = game.get_surface(rocket_silo.surface.name)
                                                end
                                            end
                                        end
                                    else--[[ A surface is/was previously selected ]]
                                        target_surface = game.get_surface(target_surface_name)
                                    end
                                else
                                    --[[ Standard rocket-silo, can fire at:
                                        -> Same surface
                                        -> From orbit
                                    ]]

                                    --[[ Check if the origin surface is an "orbit" surface (Space-Exploration)
                                        or is in "orbit" around a planet for Space-Age
                                    ]]
                                    if (from_platform) then
                                        if (rocket_silo.surface.platform) then
                                            local space_location = rocket_silo.surface.platform.space_location

                                            if (space_location and space_location.valid and space_location.name ~= nil) then
                                                target_surface = game.get_surface(space_location.name)
                                                orbit_to_surface = true
                                            end
                                        end
                                    elseif (from_se_orbit) then
                                        if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                                        if (not Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]) then
                                            Log.error("Could not find parent surface for: " .. rocket_silo.surface.name)
                                            goto continue
                                        end

                                        local space_location = Constants.space_exploration_dictionary[rocket_silo.surface.name:lower()]
                                        if (space_location.surface_index and space_location.surface_index > 0) then
                                            target_surface = game.get_surface(space_location.surface_index)
                                            orbit_to_surface = true
                                        end
                                    else
                                        target_surface = game.get_surface(rocket_silo.surface.name)
                                    end
                                end
                            end

                            --[[ Ensure the surface exists, and is a valid target surface ]]
                            if (target_surface and target_surface.valid and Rocket_Silo_Validations.is_targetable_surface({ surface = target_surface })) then
                                local return_val, return_data = Rocket_Silo_Service.launch_rocket({
                                    circuit_launched = true,
                                    circuit_launched_space_location_name = rocket_silo.surface.name,
                                    rocket_silo_data = rocket_silo_data,
                                    rocket_silo = rocket_silo,
                                    tick = game.tick,
                                    surface = target_surface,
                                    area = { left_top = { x = signal_x, y = signal_y }, right_bottom = { x = signal_x, y = signal_y }, },
                                    --[[ Pretty sure valid player indices start at 1, so 0 should be safe for indicating a circuit launch? ]]
                                    player_index = 0,
                                    last_user_index = entity and entity.valid and entity.last_user and entity.last_user.index,
                                    orbit_to_surface = orbit_to_surface,
                                })

                                if (type(return_val) == "number" and return_val == 1) then
                                    if (type(return_data) == "table" and return_data.valid) then
                                        local icbm_data = ICBM_Repository.get_icbm_data(return_data.surface_name, return_data.item_number, { validate_fields = true })
                                        if (not icbm_data or not icbm_data.valid) then return end

                                        Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
                                            icbm_data = icbm_data,
                                        })

                                        return_val = 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    ::continue::

    return return_val
end

circuit_network_service.add_to_cache_list = true

return circuit_network_service