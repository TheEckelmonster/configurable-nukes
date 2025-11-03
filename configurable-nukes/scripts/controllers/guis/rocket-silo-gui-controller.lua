local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Util = require("__core__.lualib.util")

local Rocket_Silo_Gui_Service = require("scripts.services.guis.rocket-silo-gui-service")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")

local rocket_silo_gui_controller = {}
rocket_silo_gui_controller.name = "rocket_silo_gui_controller"

-- function rocket_silo_gui_controller.on_gui_click(event)
--     Log.debug("rocket_silo_gui_controller.on_gui_clicked")
--     Log.info(event)

--     if (not event or type(event) ~= "table") then return end
--     if (not event.element) then return end
--     if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

-- end
-- Event_Handler:register_event({
--     event_name = "on_gui_click",
--     source_name = "rocket_silo_gui_controller.on_gui_click",
--     func_name = "rocket_silo_gui_controller.on_gui_click",
--     func = rocket_silo_gui_controller.on_gui_click,
-- })

function rocket_silo_gui_controller.on_gui_opened(event)
    Log.debug("rocket_silo_gui_controller.on_gui_opened")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.gui_type or event.gui_type ~= defines.gui_type.entity) then return end
    if (not event.entity or type(event.entity) ~= "userdata" or not event.entity.valid) then return end
    if (event.entity.type ~= "rocket-silo") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local rocket_silo = event.entity
    local circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_red)
    if (not circuit_network) then circuit_network = rocket_silo.get_circuit_network(defines.wire_connector_id.circuit_green) end
    if (not circuit_network) then return end

    local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
    if (not rocket_silo_data or not rocket_silo_data.valid) then
        rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
        if (not rocket_silo_data or not rocket_silo_data.valid) then return end
    end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    if (not player.gui.relative.cn_frame_outer_circuit_launchable) then
        Rocket_Silo_Gui_Service.create_rocket_silo_gui({
            rocket_silo_data = rocket_silo_data,
            player = player,
        })
    end
end
Event_Handler:register_event({
    event_name = "on_gui_opened",
    source_name = "rocket_silo_gui_controller.on_gui_opened",
    func_name = "rocket_silo_gui_controller.on_gui_opened",
    func = rocket_silo_gui_controller.on_gui_opened,
})

function rocket_silo_gui_controller.on_gui_closed(event)
    Log.debug("rocket_silo_gui_controller.on_gui_closed")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.gui_type or event.gui_type ~= defines.gui_type.entity) then return end
    if (not event.entity or type(event.entity) ~= "userdata" or not event.entity.valid) then return end
    if (event.entity.type ~= "rocket-silo") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    local gui = player.gui.relative.cn_frame_outer_circuit_launchable
    if (gui) then gui.destroy() end
end
Event_Handler:register_event({
    event_name = "on_gui_closed",
    source_name = "rocket_silo_gui_controller.on_gui_closed",
    func_name = "rocket_silo_gui_controller.on_gui_closed",
    func = rocket_silo_gui_controller.on_gui_closed,
})

function rocket_silo_gui_controller.on_gui_checked_state_changed(event)
    Log.debug("rocket_silo_gui_controller.on_gui_checked_state_changed")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    if (string.find(event.element.name, "cn_checkbox_require_space_location", 1, true)) then
        local player = game.get_player(event.player_index)
        local rocket_silo = player.opened
        if (rocket_silo and rocket_silo.valid) then
            local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
            if (not rocket_silo_data or not rocket_silo_data.valid) then
                rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                if (not rocket_silo_data or not rocket_silo_data.valid) then return end
            end
            local do_update = false

            if (event.element.name == "cn_checkbox_require_space_location") then do_update = true; rocket_silo_data.circuit_network_data.require_space_location = event.element.state end

            if (do_update) then Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data.entity, rocket_silo_data) end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_gui_checked_state_changed",
    source_name = "rocket_silo_gui_controller.on_gui_checked_state_changed",
    func_name = "rocket_silo_gui_controller.on_gui_checked_state_changed",
    func = rocket_silo_gui_controller.on_gui_checked_state_changed,
})

function rocket_silo_gui_controller.on_gui_elem_changed(event)
    Log.debug("rocket_silo_gui_controller.on_gui_elem_changed")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    if (string.find(event.element.name, "cn_button_signal_select", 1, true)) then
        local player = game.get_player(event.player_index)
        local rocket_silo = player.opened
        if (rocket_silo and rocket_silo.valid) then
            local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
            if (not rocket_silo_data or not rocket_silo_data.valid) then
                rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                if (not rocket_silo_data or not rocket_silo_data.valid) then return end
            end
            local do_update = false

            if (event.element.name == "cn_button_signal_select_launch") then do_update = true; rocket_silo_data.circuit_network_data.signals.launch = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_x") then do_update = true; rocket_silo_data.circuit_network_data.signals.x = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_y") then do_update = true; rocket_silo_data.circuit_network_data.signals.y = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_space_location_index") then do_update = true; rocket_silo_data.circuit_network_data.signals.space_location_index = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_origin_override") then do_update = true; rocket_silo_data.circuit_network_data.signals.origin_override = event.element.elem_value end

            if (do_update) then Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data.entity, rocket_silo_data) end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_gui_elem_changed",
    source_name = "rocket_silo_gui_controller.on_gui_elem_changed",
    func_name = "rocket_silo_gui_controller.on_gui_elem_changed",
    func = rocket_silo_gui_controller.on_gui_elem_changed,
})

function rocket_silo_gui_controller.on_gui_selection_state_changed(event)
    Log.debug("rocket_silo_gui_controller.on_gui_selection_state_changed")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local sa_active = storage and storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage and storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    if (not sa_active and not se_active) then return end

    if (string.find(event.element.name, "cn_dropdown", 1, true)) then
        local player = game.get_player(event.player_index)
        local rocket_silo = player.opened
        if (rocket_silo and rocket_silo.valid) then
            local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
            if (not rocket_silo_data or not rocket_silo_data.valid) then
                rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
                if (not rocket_silo_data or not rocket_silo_data.valid) then return end
            end
            local do_update = false

            if (event.element.name == "cn_dropdown_space_location") then
                do_update = true
                rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_gui_id = event.element.selected_index
                Log.warn(event.element.items[event.element.selected_index])
                rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_index = event.element.items[event.element.selected_index][2] or -1
                rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_name = event.element.items[event.element.selected_index][3] or "cn-none"
                Log.warn(rocket_silo_data)
            elseif (event.element.name == "cn_dropdown_orbit_to_surface") then
                do_update = true
                rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.orbit_to_surface_gui_id = event.element.selected_index
                Log.warn(event.element.items[event.element.selected_index])
                rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.space_location_index = event.element.items[event.element.selected_index][2] or -1
                rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name = event.element.items[event.element.selected_index][3] or "cn-none"
                Log.warn(rocket_silo_data)
            end

            if (do_update) then Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data.entity, rocket_silo_data) end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_gui_selection_state_changed",
    source_name = "rocket_silo_gui_controller.on_gui_selection_state_changed",
    func_name = "rocket_silo_gui_controller.on_gui_selection_state_changed",
    func = rocket_silo_gui_controller.on_gui_selection_state_changed,
})

function rocket_silo_gui_controller.on_entity_settings_pasted(event)
    Log.debug("rocket_silo_gui_controller.on_entity_settings_pasted")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.tick or type(event.tick)  ~= "number" or event.tick < 0) then return end
    if (not event.name or type(event.name)  ~= "number" or event.name ~= defines.events.on_entity_settings_pasted) then return end
    if (not event.player_index or type(event.player_index)  ~= "number" or event.player_index < 1) then return end
    if (not event.source or type(event.source)  ~= "userdata" or not event.source.valid) then return end
    if (not event.destination or type(event.destination)  ~= "userdata" or not event.destination.valid) then return end

    local entity_source = event.source
    local entity_destination = event.destination

    if (entity_source.type ~= "rocket-silo" or entity_destination.type ~= "rocket-silo") then return end
    if (entity_source.name ~= "rocket-silo" and entity_source.name ~= "ipbm-rocket-silo") then return end
    if (entity_destination.name ~= "rocket-silo" and entity_destination.name ~= "ipbm-rocket-silo") then return end

    local rocket_silo_data_source = Rocket_Silo_Repository.get_rocket_silo_data(entity_source.surface.name, entity_source.unit_number)
    if (not rocket_silo_data_source or not rocket_silo_data_source.valid) then
        rocket_silo_data_source = Rocket_Silo_Repository.save_rocket_silo_data(entity_source)
        if (not rocket_silo_data_source or not rocket_silo_data_source.valid) then return end
    end

    local rocket_silo_data_destination = Rocket_Silo_Repository.get_rocket_silo_data(entity_destination.surface.name, entity_destination.unit_number)
    if (not rocket_silo_data_destination or not rocket_silo_data_destination.valid) then
        rocket_silo_data_destination = Rocket_Silo_Repository.save_rocket_silo_data(entity_source)
        if (not rocket_silo_data_destination or not rocket_silo_data_destination.valid) then return end
    end

    local circuit_network_data = Util.table.deepcopy(rocket_silo_data_source.circuit_network_data)

    circuit_network_data.entity = rocket_silo_data_destination.entity and rocket_silo_data_destination.entity.valid and rocket_silo_data_destination.entity or nil
    circuit_network_data.unit_number = rocket_silo_data_destination.unit_number or rocket_silo_data_destination.entity and rocket_silo_data_destination.entity.valid and rocket_silo_data_destination.entity.unit_number or -1
    circuit_network_data.surface = rocket_silo_data_destination.surface and rocket_silo_data_destination.surface.valid and rocket_silo_data_destination.surface or nil
    circuit_network_data.surface_index = rocket_silo_data_destination.surface_index or rocket_silo_data_destination.surface and rocket_silo_data_destination.surface.valid and rocket_silo_data_destination.surface.index or -1
    circuit_network_data.surface_name = rocket_silo_data_destination.surface_name or rocket_silo_data_destination.surface and  rocket_silo_data_destination.surface.valid and rocket_silo_data_destination.surface.name or nil

    circuit_network_data.created = rocket_silo_data_destination.circuit_network_data and rocket_silo_data_destination.circuit_network_data.created or rocket_silo_data_destination.created or game.tick
    circuit_network_data.updated = game.tick

    rocket_silo_data_destination.circuit_network_data = circuit_network_data

    Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data_destination.entity, rocket_silo_data_destination)
end
Event_Handler:register_event({
    event_name = "on_entity_settings_pasted",
    source_name = "rocket_silo_gui_controller.on_entity_settings_pasted",
    func_name = "rocket_silo_gui_controller.on_entity_settings_pasted",
    func = rocket_silo_gui_controller.on_entity_settings_pasted,
})

return rocket_silo_gui_controller