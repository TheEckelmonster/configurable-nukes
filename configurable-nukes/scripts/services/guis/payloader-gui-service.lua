local storage

local next = next
local type = type

local defines = defines

local relative_gui_payloader = defines.relative_gui_type.assembling_machine_gui
local gui_position_right = defines.relative_gui_position.right

local Log = Log
local Payloader_Data = Circuit_Network_Payloader_Data

-- local Payloader_Data = require("scripts.data.circuit-network.payloader-data")

local payloader_gui_service = {}

function payloader_gui_service.create_payloader_gui(params)
    -- Log.debug("payloader_gui_service.create_payloader_gui")
    -- Log.info(params)

    if (not params or type(params) ~= "table") then return end
    if (not params.unit_number or type(params.unit_number) ~= "number") then return end

    local player = params.player
    if (not player or not player.valid) then return end

    storage.payloaders = storage.payloaders or {}
    local payloader = storage.payloaders[params.unit_number]
    if (not payloader or not payloader.entity or not payloader.entity.valid) then return end

    payloader.circuit_network_data = payloader.circuit_network_data or Payloader_Data:new({
        unit_number = params.unit_number,
        surface_index = params.surface_index,
        surface_name = params.surface_name,
    })
    local circuit_network_data = payloader.circuit_network_data

    circuit_network_data.manual_entry = circuit_network_data.manual_entry or {
        launch = 0,
        x = 0,
        y = 0,
        space_location_index = params.surface_index,
    }
    local manual_entry = circuit_network_data.manual_entry

    local signal_launch = circuit_network_data.signals.launch
    local signal_x = circuit_network_data.signals.x
    local signal_y = circuit_network_data.signals.y
    local signal_space_location_index = circuit_network_data.signals.space_location_index

    local gui = player.gui.relative.cn_payloader_frame_outer

    if (not gui) then
        gui = player.gui.relative.add({
            type = "frame",
            name = "cn_payloader_frame_outer",
            caption = { "cn-launch-signal-gui.payloader-title", },
            direction = "vertical",
            index = 0,
            anchor = {
                gui = relative_gui_payloader,
                position = gui_position_right
            },
            -- visible = params.ui_visible,
        })
        local gui_inner = gui.add({
            type = "frame",
            name = "cn_payloader_frame_inner",
            style = "inside_shallow_frame_with_padding",
            direction = "vertical",
        })

        ---

        local gui_table = gui_inner.add({
            type = "table",
            name = "cn_payloader_table",
            column_count = 2,
        })

        ---

        local gui_flow_inner = gui_table.add({
            type = "flow",
            name = "cn_payloader_flow_inner_x",
            -- style = "inside_shallow_frame_with_padding",
            direction = "vertical",
        })

        gui_flow_inner.add({
            type = "label",
            name = "cn_payloader_label_signal_x",
            caption = { "cn-launch-signal-gui.signal-x" },
            direction = "vertical",
            -- tooltip = { "cn-launch-signal-gui.signal-x-tooltip" },
        })
        gui_flow_inner.add({
            type = "choose-elem-button",
            name = "cn_payloader_button_signal_select_x",
            elem_type = "signal",
            signal = signal_x
        })

        local gui_flow_col_2 = gui_table.add({
            type = "flow",
            name = "cn_payloader_col_x_manual",
            style = "player_input_horizontal_flow",
        })
        gui_flow_col_2.add({
            type = "textfield",
            name = "cn_payloader_flow_row_text_box_x",
            text = manual_entry.x ~= 0 and manual_entry.x or "",
            style = "short_number_textfield",
            numeric = true,
            lose_focus_on_confirm = true,
        })

        ---

        local gui_flow_inner = gui_table.add({
            type = "flow",
            name = "cn_payloader_flow_inner_y",
            -- style = "inside_shallow_frame_with_padding",
            direction = "vertical",
        })

        gui_flow_inner.add({
            type = "label",
            name = "cn_payloader_label_signal_y",
            caption = { "cn-launch-signal-gui.signal-y" },
            direction = "vertical",
            -- tooltip = { "cn-launch-signal-gui.signal-y-tooltip" },
        })
        gui_flow_inner.add({
            type = "choose-elem-button",
            name = "cn_payloader_button_signal_select_y",
            elem_type = "signal",
            signal = signal_y
        })

        local gui_flow_col_2 = gui_table.add({
            type = "flow",
            name = "cn_payloader_col_y_manual",
            style = "player_input_horizontal_flow",
        })
        gui_flow_col_2.add({
            type = "textfield",
            name = "cn_payloader_flow_row_text_box_y",
            text = manual_entry.y ~= 0 and manual_entry.y or "",
            style = "short_number_textfield",
            numeric = true,
            lose_focus_on_confirm = true,
        })

        ---

        local gui_flow_inner = gui_table.add({
            type = "flow",
            name = "cn_payloader_flow_inner_z",
            direction = "vertical",
        })

        gui_flow_inner.add({
            type = "label",
            name = "cn_payloader_label_signal_z",
            caption = { "cn-launch-signal-gui.signal-z" },
            direction = "vertical",
        })
        gui_flow_inner.add({
            type = "choose-elem-button",
            name = "cn_payloader_button_signal_select_z",
            elem_type = "signal",
            signal = signal_space_location_index
        })

        local gui_flow_col_2 = gui_table.add({
            type = "flow",
            name = "cn_payloader_col_z_manual",
            style = "player_input_horizontal_flow",
        })
        gui_flow_col_2.add({
            type = "textfield",
            name = "cn_payloader_flow_row_text_box_z",
            text = manual_entry.z ~= 0 and manual_entry.space_location_index or "",
            style = "short_number_textfield",
            numeric = true,
            lose_focus_on_confirm = true,
        })

        ---

        gui_inner.style.padding = { 4, 6, 4, 4 }
        gui_table.style.padding = { 4, 6, 4, 4 }

        if (signal_x and signal_x ~= 0 and signal_y and signal_y ~= 0) then
            manual_entry.manually_entered = true
        else
            manual_entry.manually_entered = nil
        end
    end
end

function payloader_gui_service.init(__storage)
    storage = __storage
end

return payloader_gui_service