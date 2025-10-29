local Circuit_Network_Rocket_Silo_Data = require("scripts.data.circuit-network.rocket-silo-data")
local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Configurable_Nukes_Repository = require("scripts.repositories.configurable-nukes-repository")
local Constants = require("scripts.constants.constants")
local Custom_Events = require("prototypes.custom-events.custom-events")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Meta_Data = require("scripts.data.ICBM-meta-data")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Log = require("libs.log.log")
local Rocket_Silo_Constants = require("scripts.constants.rocket-silo-constants")
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Meta_Data = require("scripts.data.rocket-silo-meta-data")
local Rocket_Silo_Meta_Repository = require("scripts.repositories.rocket-silo-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local String_Utils = require("scripts.utils.string-utils")
local Version_Service = require("scripts.services.version-service")

local locals = {}

local initialization = {}

initialization.last_version_result = nil

function initialization.init(data)
    log({ "initialization.init" })
    Log.debug("initialization.init")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Expllicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(true, data.maintain_data) -- from_scratch
end

function initialization.reinit(data)
    log({ "initialization.reinit" })
    Log.debug("initialization.reinit")
    Log.info(data)

    if (not data or type(data) ~= "table") then data = { maintain_data = false} end

    if (data and data.maintain_data) then data.maintain_data = true -- Expllicitly set maintain_data to be a boolean value of true
    else data.maintain_data = false
    end

    return locals.initialize(false, data.maintain_data) -- as is
end

function locals.initialize(from_scratch, maintain_data)
    Log.debug("locals.initialize")
    Log.info(from_scratch)
    Log.info(maintain_data)

    local configurable_nukes_data = Configurable_Nukes_Repository.get_configurable_nukes_data()
    Log.info(configurable_nukes_data)

    configurable_nukes_data.do_nth_tick = false

    from_scratch = from_scratch or false
    maintain_data = maintain_data or false

    if (not from_scratch) then
        -- Version check
        local version_data = configurable_nukes_data.version_data
        if (version_data and not version_data.valid) then
            local version = initialization.last_version_result
            if (not version) then goto initialize end
            if (not version.major or not version.minor or not version.bug_fix) then goto initialize end
            if (not version.major.valid) then goto initialize end
            if (not version.minor.valid or not version.bug_fix.valid) then
                return locals.initialize(true, true)
            end

            ::initialize::
            return locals.initialize(true)
        else
            local version = Version_Service.validate_version()
            initialization.last_version_result = version
            if (not version or not version.valid) then
                version_data.valid = false
                return configurable_nukes_data
            end
        end
    end

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    -- Configurable Nukes
    if (from_scratch) then
        log({ "initialization.initialization-anew", Constants.mod_name })
        if (game) then game.print({ "initialization.initialization-anew", Constants.mod_name }) end

        local _storage = storage
        _storage.storage_old = nil

        storage = {}
        configurable_nukes_data = Configurable_Nukes_Data:new()
        storage.configurable_nukes = configurable_nukes_data

        storage.storage_old = _storage

        -- do migrations
        locals.migrate({ maintain_data = maintain_data, new_version_data = configurable_nukes_data.version_data })

        local version_data = configurable_nukes_data.version_data
        version_data.valid = true
    else
        if (not configurable_nukes_data) then
            storage.configurable_nukes = Configurable_Nukes_Data:new()
            configurable_nukes_data = storage.configurable_nukes
        end
        if (not configurable_nukes_data.icbm_meta_data) then configurable_nukes_data.icbm_meta_data = {} end
        if (not configurable_nukes_data.rocket_silo_meta_data) then configurable_nukes_data.rocket_silo_meta_data = {} end
    end

    storage.sa_active = sa_active ~= nil and sa_active or storage.sa_active
    storage.se_active = se_active ~= nil and se_active or storage.se_active

    locals.reindex_and_save_mod_data()

    if (game) then
        for name, surface in pairs(game.surfaces) do
            Log.warn(name)
            Log.warn(surface)
            Log.warn(surface.name)
            Log.warn(surface.valid)
            -- Search through all available surfaces for rocket-silos
            if (surface and surface.valid and not String_Utils.find_invalid_substrings(surface.name)) then
                local surface_name = surface.name
                local rocket_silo_meta_data = {}
                if (from_scratch or not configurable_nukes_data.rocket_silo_meta_data[surface_name]) then
                    if (not maintain_data) then
                        rocket_silo_meta_data = Rocket_Silo_Meta_Repository.save_rocket_silo_meta_data(surface_name)
                    else
                        rocket_silo_meta_data = Rocket_Silo_Meta_Repository.get_rocket_silo_meta_data(surface_name)
                    end
                end
                Log.debug(rocket_silo_meta_data)

                if (not rocket_silo_meta_data.surface_name) then rocket_silo_meta_data.surface_name = surface_name end

                local rocket_silos = surface.find_entities_filtered(Rocket_Silo_Constants.entity_filter)
                Log.debug(serpent.block(rocket_silos))
                for i = 1, #rocket_silos do
                    local rocket_silo = rocket_silos[i]
                    Log.debug(serpent.block(rocket_silo))
                    if (rocket_silo and rocket_silo.valid and rocket_silo.surface and (rocket_silo.name == "rocket-silo" or rocket_silo.name == "ipbm-rocket-silo")) then
                        locals.add_rocket_silo(rocket_silo_meta_data, rocket_silo)
                    end
                end

                if (rocket_silo_meta_data.valid and rocket_silo_meta_data.rocket_silos) then
                    if (not next(rocket_silo_meta_data.rocket_silos, nil)) then
                        Rocket_Silo_Meta_Repository.delete_rocket_silo_meta_data(surface_name)
                    end
                end
            end
        end
    end

    if (storage and storage.configurable_nukes) then
        storage.configurable_nukes.do_nth_tick = true
    end

    storage.configurable_nukes.valid = true

    script.raise_event(
        Custom_Events.cn_on_init_complete.name,
        {
            name = defines.events[Custom_Events.cn_on_init_complete.name],
            tick = game.tick,
        }
    )

    if (from_scratch) then log({ "initialization.initialization-complete", Constants.mod_name }) end
    if (from_scratch and game) then game.print({ "initialization.initialization-complete", Constants.mod_name }) end
    Log.info(storage)

    return configurable_nukes_data
end

function locals.add_rocket_silo(rocket_silo_meta_data, rocket_silo)
    Log.debug("add_rocket_silo")
    Log.info(rocket_silo_meta_data)
    Log.info(rocket_silo)

    if (not rocket_silo or not rocket_silo.valid or not rocket_silo.surface or not rocket_silo.surface.valid) then
        Log.warn("Call to add_rocket_silo with an invalid rocket-silo")
        Log.debug(rocket_silo)
        return
    end

    if (not rocket_silo_meta_data or not rocket_silo_meta_data.valid or not rocket_silo_meta_data.rocket_silos) then
        Log.warn("Call to add_rocket_silo with invalid meta data")
        Log.debug(rocket_silo_meta_data)
        return
    end

    if (rocket_silo_meta_data.rocket_silos[rocket_silo.unit_number]) then

        Log.debug("updating rocket silo")
        local update_data =
        {
            type = Rocket_Silo_Data.type,
            unit_number = rocket_silo.unit_number,
            entity = rocket_silo.valid and rocket_silo or nil,
            surface = rocket_silo.valid and rocket_silo.surface and rocket_silo.surface.valid and rocket_silo.surface or nil,
            surface_name = rocket_silo.valid and rocket_silo.surface and rocket_silo.surface.valid and rocket_silo.surface.name or nil,
            surface_index = rocket_silo.valid and rocket_silo.surface and rocket_silo.surface.valid and rocket_silo.surface.index or -1,
        }

        Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo, update_data, { reinitialize_soft = true } )
    else
        Log.debug("saving rocket silo")
        Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
    end
end

function locals.migrate(data)
    Log.debug("migrate")
    Log.info(data)

    local storage_old = storage.storage_old
    if (not storage_old) then return end
    if (not type(storage_old) == "table") then return end

    local reassign = function (table_old, table_new, data)
        if (type(table_old) == "table" and table_old[data.field] and type(table_new) == "table") then
            table_new[data.field] = table_old[data.field]
            table_old[data.field] = nil
        end
    end
    reassign(storage_old, storage, { field = "configurable_nukes_controller" })
    reassign(storage_old, storage, { field = "event_handlers" })
    reassign(storage_old, storage, { field = "gui_data" })
    reassign(storage_old, storage, { field = "icbm_data" })
    reassign(storage_old, storage, { field = "nth_tick" })

    if (not data or type(data) ~= "table") then return end
    if (not data.maintain_data) then return end
    if (not data.new_version_data) then
        if (storage.configurable_nukes and storage.configurable_nukes.version_data) then
            data.new_version_data = storage.configurable_nukes.version_data
        else
            return
        end
    end

    if (type(storage_old.configurable_nukes) == "table") then
        local migration_start_message_printed = false
        if (storage_old.configurable_nukes.version_data and storage_old.configurable_nukes.version_data.created) then
            if (storage_old.configurable_nukes.version_data.created >= 0) then
                if (storage.tick and type(storage.tick) == "number" and storage.tick > 0) then
                    Log.debug(storage_old.configurable_nukes.version_data)
                    Log.debug(Constants.mod_name .. ": Migrating existing data")
                    game.print({ "initialization.migrate-start", Constants.mod_name})
                    migration_start_message_printed = true
                end
            end
        end

        if (storage_old.configurable_nukes.version_data) then
            local prev_version_data = storage_old.configurable_nukes.version_data
            local new_version_data = data.new_version_data
            if (prev_version_data.major.value == 0) then
                if (prev_version_data.minor.value <= 4) then
                    --[[ Version 0.5.0 changed from using "planet_name" to using "space_location_name" ]]
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 5) then
                        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
                            local all_rocket_silo_meta_data = storage_old.configurable_nukes.rocket_silo_meta_data
                            for k, v in pairs(all_rocket_silo_meta_data) do
                                if (v.planet_name) then
                                    v.space_location_name = v.planet_name
                                    --[[
                                        I think, by not setting the previous value of v.planet_name to nil,
                                        that ?should? maintain backwards compatability if someone were to
                                        downgrade, rather than only upgrade
                                        Really not sure on this; need to test, but not highest priority.
                                        TODO: See above
                                    ]]
                                end
                            end
                        end
                    end
                end

                if (prev_version_data.minor.value <= 5) then
                    Log.warn(prev_version_data.minor.value)
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 6) then
                        Log.warn(new_version_data.major.value)
                        Log.warn(new_version_data.minor.value)
                        --[[ Version 0.6.0 switched to encapsulating the gui/circuit_network_data into its own object ]]
                        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
                            local all_rocket_silo_meta_data = storage_old.configurable_nukes.rocket_silo_meta_data
                            for k, v in pairs(all_rocket_silo_meta_data) do
                                for k_2, v_2 in pairs(v.rocket_silos) do
                                    if (v_2.signals) then
                                        v_2.circuit_network_data = Circuit_Network_Rocket_Silo_Data:new({
                                            entity = v_2.entity,
                                            unit_number = v_2.entity and v_2.entity.valid and v_2.entity.unit_number,
                                            surface = v_2.entity and v_2.entity.valid and v_2.entity.surface and v_2.entity.surface.valid and v_2.entity.surface,
                                            surface_name = v_2.entity and v_2.entity.valid and v_2.entity.surface and v_2.entity.surface.valid and v_2.entity.surface.name,
                                            signals = v_2.signals,
                                        })

                                        Rocket_Silo_Repository.update_rocket_silo_data(v_2.entity, v_2)
                                    end
                                end
                            end
                        end
                    end
                end

                if (prev_version_data.minor.value <= 6) then
                    Log.warn(prev_version_data.minor.value)
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 7) then
                        Log.warn(new_version_data.major.value)
                        Log.warn(new_version_data.minor.value)
                        --[[ Version 0.7.0:
                            -> removed item_numbers from icbm_meta_data
                            -> changed/enforced icbm_meta_data.surface_name instead of icbm_meta_data.planet_name

                            -> Event_Handler system indtroduced
                              -> Move existing inflight rockets to registered scheduled events
                              -> icbm_data.event_handlers field introduced
                        ]]
                        if (storage_old.configurable_nukes.icbm_meta_data) then
                            local all_icbm_meta_data = storage_old.configurable_nukes.icbm_meta_data
                            for k, icbm_meta_data in pairs(all_icbm_meta_data) do
                                icbm_meta_data.item_numbers = nil
                                icbm_meta_data.surface_name = icbm_meta_data.planet_name
                                icbm_meta_data.planet_name = nil
                                ICBM_Meta_Repository.update_icbm_meta_data(icbm_meta_data)

                                if (icbm_meta_data.in_transit) then
                                    for icbm_data, _  in pairs(icbm_meta_data.in_transit) do
                                        icbm_data.event_handlers = {}
                                        ICBM_Utils.register_delivery_data({ icbm_data = icbm_data })
                                        icbm_meta_data.in_transit[icbm_data] = nil
                                        ICBM_Repository.update_icbm_data(icbm_data)
                                    end
                                end

                                if (icbm_meta_data.icbms) then
                                    for k_2, icbm_data in pairs(icbm_meta_data.icbms) do
                                        icbm_data.event_handlers = {}
                                        ICBM_Repository.update_icbm_data(icbm_data)
                                    end
                                end
                            end
                        end
                    end
                end

                if (prev_version_data.minor.value <= 7) then
                    Log.warn(prev_version_data.minor.value)
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 7) then
                        Log.warn(new_version_data.major.value)
                        Log.warn(new_version_data.minor.value)
                        --[[ Version 0.7.1:
                            -> changed:
                                storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index][item_number]
                                to
                                storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index].item_numbers[item_number]
                        ]]
                        if (storage.gui_data) then
                            for _, gui_data in pairs(storage.gui_data) do
                                for _, storage_ref in pairs(gui_data) do
                                    for k, v in pairs(storage_ref) do
                                        if (type(k) == "number" and k >=1) then
                                            if (storage_ref[k].icbm_data or storage_ref[k].surface_name) then
                                                if (not storage_ref.item_numbers) then storage_ref.item_numbers = {} end
                                                storage_ref.item_numbers[k] = v
                                                storage_ref[k] = nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if (prev_version_data.minor.value <= 7) then
                    Log.warn(prev_version_data.major.value)
                    Log.warn(prev_version_data.minor.value)
                    Log.warn(prev_version_data.bug_fix.value)
                    if (new_version_data.major.value <= 0 and new_version_data.minor.value >= 8) then
                        Log.warn(new_version_data.major.value)
                        Log.warn(new_version_data.minor.value)
                        Log.warn(new_version_data.bug_fix.value)
                        --[[ Version 0.8.0:
                            -> changed:
                                icbm_data.type
                                to
                                icbm_data.item_name
                        ]]
                        if (storage_old.configurable_nukes.icbm_meta_data) then
                            local all_icbm_meta_data = storage_old.configurable_nukes.icbm_meta_data
                            for k, icbm_meta_data in pairs(all_icbm_meta_data) do
                                if (type(icbm_meta_data) == "table" and icbm_meta_data.valid and icbm_meta_data.icbms) then
                                    for k_2, icbm_data in pairs(icbm_meta_data.icbms) do
                                        if (icbm_data.valid) then
                                            icbm_data.item_name = icbm_data.type
                                            icbm_data.type = ICBM_Data.type
                                            ICBM_Repository.update_icbm_data(icbm_data)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if (type(storage_old.configurable_nukes.rocket_silo_meta_data) == "table") then
            for k, v in pairs(storage_old.configurable_nukes.rocket_silo_meta_data) do
                if (type(v) == "table" and v.valid) then
                    if (type(v.rocket_silos) == "table") then
                        for k_2, v_2 in pairs(v.rocket_silos) do
                            Rocket_Silo_Repository.update_rocket_silo_data(v_2.entity, v_2)
                        end
                    end
                end
            end
        end

        if (storage_old.configurable_nukes.force_launch_data) then
            for force_index, force_launch_data in pairs(storage_old.configurable_nukes.force_launch_data) do
                if (    type(force_launch_data) == "table"
                    and force_launch_data.valid
                    and type(force_launch_data.launch_action_queue == "table")
                    and type(force_launch_data.launch_action_queue.count) == "number"
                    and force_launch_data.launch_action_queue.count > 0
                ) then
                    if (type(force_launch_data.launch_action_queue.data_array) == "table") then
                        local i, num_loops = 1, 1
                        while i <= #force_launch_data.launch_action_queue.data_array do
                            if (num_loops > 2 ^ 11) then break end
                            local value = force_launch_data.launch_action_queue.data_array[i]
                            local should_increment = true
                            if (type(value) == "table") then
                                if (type(value.icbm_data) == "table") then
                                    if (value.icbm_data.cargo_pod) then value.icbm_data.cargo_pod = nil end
                                    if (type(value.icbm_data.cargo_pod_unit_number) == "number" and value.icbm_data.cargo_pod_unit_number < 1) then
                                        force_launch_data.launch_action_queue:remove({ data = value.icbm_data.enqueued_data })
                                        should_increment = false
                                    end
                                end
                            end

                            if (should_increment) then
                                i = i + 1
                            end
                            num_loops = num_loops + 1
                        end
                    end
                end
            end
        end
        reassign(storage_old.configurable_nukes, storage.configurable_nukes, { field = "force_launch_data" })

        local se_active = script and script.active_mods and script.active_mods["space-exploration"]
        local dictionary =     not se_active and Constants.get_planets(true) and Constants.planets_dictionary
                            or Constants.get_space_exploration_universe(true) and Constants.space_exploration_dictionary

        if (Log.get_log_level().level.num_val <= 2) then
            log(serpent.block(dictionary))
        end

        if (type(storage_old.configurable_nukes.icbm_meta_data) == "table") then
            for k, v in pairs(storage_old.configurable_nukes.icbm_meta_data) do
                if (dictionary[k]) then
                    ICBM_Meta_Repository.update_icbm_meta_data(v)
                    storage_old.configurable_nukes.icbm_meta_data[k] = nil
                end
            end
        end

        if (migration_start_message_printed) then
            Log.debug(Constants.mod_name .. ": Migration complete")
            game.print({ "initialization.migrate-finish", Constants.mod_name})
        end
    end
end

function locals.reindex_and_save_mod_data(data)
    Log.debug("locals.reindex_and_save_mod_data")
    Log.info(data)

    if (not storage.constants) then storage.constants = {} end
    storage.constants.mod_data = Constants.get_mod_data(true)
end

return initialization
