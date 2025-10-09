-- If already defined, return
if _gui_controller and _gui_controller.configurable_nukes then
  return _gui_controller
end

local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

-- ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN
local get_icbm_allow_targeting_origin = function ()
    local setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name].value
    end

    return setting
end

local gui_controller = {}

function gui_controller.on_gui_opened(event)
    Log.debug("gui_controller.on_gui_opened")
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

    local signal_launch = rocket_silo_data.signals.launch or Rocket_Silo_Data.signals.launch
    local signal_x = rocket_silo_data.signals.x or Rocket_Silo_Data.signals.x
    local signal_y = rocket_silo_data.signals.y or Rocket_Silo_Data.signals.y
    local signal_origin_override = get_icbm_allow_targeting_origin() and rocket_silo_data.signals.origin_override -- Intentionally not getting a default from Rocket_Silo_Data
    local planet_gui_id = rocket_silo_data.planet_gui_id or Rocket_Silo_Data.planet_gui_id

    local player = game.get_player(event.player_index)
    local gui = player.gui.relative.cn_frame_outer_circuit_launchable

    if (not gui) then
        gui = player.gui.relative.add({
            type = "frame",
            name = "cn_frame_outer_circuit_launchable",
            caption = { "cn-launch-signal-gui.title" },
            direction = "vertical",
            index = 0,
            anchor = {
                gui = defines.relative_gui_type.rocket_silo_gui,
                position = defines.relative_gui_position.right
            }
        })
        local gui_inner = gui.add({
            type = "frame",
            name = "cn_frame_inner",
            style = "inside_shallow_frame_with_padding",
            direction = "vertical",
        })
        local gui_flow = gui_inner.add({
            type = "flow",
            name = "cn_flow",
            style = "padded_vertical_flow",
            direction = "vertical",
        })
        gui_flow.add({
            type = "label",
            name = "cn_label_signal_launch",
            caption = { "cn-launch-signal-gui.signal_launch" },
            direction = "vertical",
        })
        gui_flow.add({
            type = "choose-elem-button",
            name = "cn_button_signal_select_launch",
            elem_type = "signal",
            signal = signal_launch
        })
        gui_flow.add({
            type = "label",
            name = "cn_label_signal_x",
            caption = { "cn-launch-signal-gui.signal_x" },
            direction = "vertical",
        })
        gui_flow.add({
            type = "choose-elem-button",
            name = "cn_button_signal_select_x",
            elem_type = "signal",
            signal = signal_x
        })
        gui_flow.add({
            type = "label",
            name = "cn_label_signal_y",
            caption = { "cn-launch-signal-gui.signal_y" },
            direction = "vertical",
        })
        gui_flow.add({
            type = "choose-elem-button",
            name = "cn_button_signal_select_y",
            elem_type = "signal",
            signal = signal_y
        })
        if (get_icbm_allow_targeting_origin()) then
            gui_flow.add({
                type = "label",
                name = "cn_label_signal_origin_override",
                caption = { "cn-launch-signal-gui.signal_origin_override" },
                direction = "vertical",
            })
            gui_flow.add({
                type = "choose-elem-button",
                name = "cn_button_signal_select_origin_override",
                elem_type = "signal",
                signal = signal_origin_override
            })
        end
        -- if (script and script.active_mods and script.active_mods["space-age"]) then
        --     gui_flow.add({
        --         type = "label",
        --         name = "cn_label_planet",
        --         caption = { "cn-launch-signal-gui.planet" },
        --         direction = "vertical",
        --     })

        --     local planets = Constants.get_planets(true)
        --     local items = {}

        --     for k, v in pairs(planets) do
        --         if (v.surface and v.surface.valid) then
        --             table.insert(items, { "cn-launch-signal-gui.list-item", v.name })
        --         end
        --     end

        --     gui_inner.add({
        --         type = "drop-down",
        --         -- type = "list-box",
        --         name = "cn_dropdown_planet",
        --         selected_index = planet_gui_id,
        --         items = items
        --     })
        -- end

        gui_inner.style.padding = { 4, 6, 4, 4 }
        gui_flow.style.padding = { 4, 6, 4, 4 }
    end
end

function gui_controller.on_gui_closed(event)
    Log.debug("gui_controller.on_gui_closed")
    Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.gui_type or event.gui_type ~= defines.gui_type.entity) then return end
    if (not event.entity or type(event.entity) ~= "userdata" or not event.entity.valid) then return end
    if (not event.entity.type == "rocket-silo") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    local gui = player.gui.relative.cn_frame_outer_circuit_launchable
    if (gui) then gui.destroy() end

end

function gui_controller.on_gui_elem_changed(event)
    Log.debug("gui_controller.on_gui_elem_changed")
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

            if (event.element.name == "cn_button_signal_select_launch") then do_update = true; rocket_silo_data.signals.launch = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_x") then do_update = true; rocket_silo_data.signals.x = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_y") then do_update = true; rocket_silo_data.signals.y = event.element.elem_value end
            if (event.element.name == "cn_button_signal_select_origin_override") then do_update = true; rocket_silo_data.signals.origin_override = event.element.elem_value end

            if (do_update) then Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data) end
        end
    end
end

function gui_controller.on_gui_selection_state_changed(event)
    Log.debug("gui_controller.on_gui_selection_state_changed")
    Log.info(event)

    --[[ Come back to, remove ths ]]
    return

    -- if (not event or not type(event) == "table") then return end
    -- if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    -- if (string.find(event.element.name, "cn_dropdown", 1, true)) then
    --     local player = game.get_player(event.player_index)
    --     local rocket_silo = player.opened
    --     if (rocket_silo and rocket_silo.valid) then
    --         local rocket_silo_data = Rocket_Silo_Repository.get_rocket_silo_data(rocket_silo.surface.name, rocket_silo.unit_number)
    --         if (not rocket_silo_data or not rocket_silo_data.valid) then
    --             rocket_silo_data = Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
    --             if (not rocket_silo_data or not rocket_silo_data.valid) then return end
    --         end
    --         local do_update = false

    --         if (event.element.name == "cn_dropdown_planet") then do_update = true; rocket_silo_data.planet_gui_id = event.element.selected_index end

    --         if (do_update) then Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data) end
    --     end
    -- end
end

function gui_controller.on_entity_settings_pasted(event)
    Log.debug("gui_controller.on_entity_settings_pasted")
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

    rocket_silo_data_destination.signals.launch = rocket_silo_data_source.signals.launch
    rocket_silo_data_destination.signals.x = rocket_silo_data_source.signals.x
    rocket_silo_data_destination.signals.y = rocket_silo_data_source.signals.y
    rocket_silo_data_destination.signals.origin_override = get_icbm_allow_targeting_origin() and rocket_silo_data_source.signals.origin_override or nil

    -- if (script and script.active_mods and script.active_mods["space-age"]) then
    --     rocket_silo_data_destination.planet_gui_id = rocket_silo_data_source.planet_gui_id
    -- end

    Rocket_Silo_Repository.update_rocket_silo_data(rocket_silo_data_destination)
end

gui_controller.configurable_nukes = true

local _gui_controller = gui_controller

return gui_controller