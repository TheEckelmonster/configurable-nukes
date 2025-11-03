local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Circuit_Network_Validations = require("scripts.validations.circuit-network-data.rocket-silo-validations")
local Gui_Utils = require("scripts.utils.gui-utils")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local rocket_silo_gui_service = {}

function rocket_silo_gui_service.create_rocket_silo_gui(data)
    Log.debug("rocket_silo_gui_service.on_gui_opened")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.rocket_silo_data or type(data.rocket_silo_data) ~= "table") then return end
    if (not data.player or not data.player.valid) then return end

    local sa_active = storage and storage.sa_active ~= nil and storage.sa_active or script and script.active_mods and script.active_mods["space-age"]
    local se_active = storage and storage.se_active ~= nil and storage.se_active or script and script.active_mods and script.active_mods["space-exploration"]

    --[[ Validate/reinitialize rocket-silo circuit-network-data ]]
    local is_valid = Circuit_Network_Validations.validate({ circuit_network_data = data.rocket_silo_data.circuit_network_data, })
    if (not is_valid) then
        Circuit_Network_Validations.validate({ circuit_network_data = data.rocket_silo_data.circuit_network_data, reinitialize = true, })
    end

    local signal_launch = data.rocket_silo_data.circuit_network_data.signals.launch
    local signal_x = data.rocket_silo_data.circuit_network_data.signals.x
    local signal_y = data.rocket_silo_data.circuit_network_data.signals.y
    local signal_space_location_index = data.rocket_silo_data.circuit_network_data.signals.space_location_index
    local setting_allow_targeting_origin = Settings_Service.get_runtime_global_setting({  setting = Runtime_Global_Settings_Constants.settings.ICBM_CIRCUIT_ALLOW_TARGETING_ORIGIN.name })
    local signal_origin_override = setting_allow_targeting_origin and data.rocket_silo_data.circuit_network_data.signals.origin_override -- Intentionally not getting a default from Rocket_Silo_Data
    local orbit_to_surface_gui_space_location_name = data.rocket_silo_data.circuit_network_data.orbit_to_surface_gui_selection.space_location_name
    local space_location_gui_space_location_name = data.rocket_silo_data.circuit_network_data.space_location_gui_selection.space_location_name
    local require_space_location = data.rocket_silo_data.circuit_network_data.require_space_location

    local player = data.player
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
            caption = { "cn-launch-signal-gui.signal-launch" },
            direction = "vertical",
            tooltip = { "cn-launch-signal-gui.signal-launch-tooltip" },
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
            caption = { "cn-launch-signal-gui.signal-x" },
            direction = "vertical",
            -- tooltip = { "cn-launch-signal-gui.signal-x-tooltip" },
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
            caption = { "cn-launch-signal-gui.signal-y" },
            direction = "vertical",
            -- tooltip = { "cn-launch-signal-gui.signal-y-tooltip" },
        })
        gui_flow.add({
            type = "choose-elem-button",
            name = "cn_button_signal_select_y",
            elem_type = "signal",
            signal = signal_y
        })

        if (setting_allow_targeting_origin) then
            gui_flow.add({
                type = "label",
                name = "cn_label_signal_origin_override",
                caption = { "cn-launch-signal-gui.signal-origin-override" },
                direction = "vertical",
                tooltip = { "cn-launch-signal-gui.signal-origin-override-tooltip" },
            })
            gui_flow.add({
                type = "choose-elem-button",
                name = "cn_button_signal_select_origin_override",
                elem_type = "signal",
                signal = signal_origin_override
            })
        end
        if (sa_active or se_active) then
            local target_surface = nil
            local orbit_to_surface = false

            if (se_active and not data.rocket_silo_data:is_ipbm_silo() and not Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })) then
                --[[ Check if this rocket-silo is in "orbit" ]]
                local is_orbit_surface = false
                if (data.rocket_silo_data.surface and data.rocket_silo_data.surface.valid) then
                    is_orbit_surface = data.rocket_silo_data.surface.name:lower():find(" orbit", 1, true) ~= nil
                elseif (data.rocket_silo_data.entity and data.rocket_silo_data.entity.valid and data.rocket_silo_data.entity.surface and data.rocket_silo_data.entity.surface.valid) then
                    is_orbit_surface = data.rocket_silo_data.entity.surface.name:lower():find(" orbit", 1, true) ~= nil
                end

                if (is_orbit_surface) then
                    if (not Constants.space_exploration_dictionary) then Constants.get_space_exploration_universe(true) end
                    if (not Constants.space_exploration_dictionary[data.rocket_silo_data.surface_name:lower()]) then
                        Log.error("Could not find parent surface for: " .. data.rocket_silo_data.surface_name)
                        goto continue
                    end

                    local space_location = Constants.space_exploration_dictionary[data.rocket_silo_data.surface_name:lower()]
                    if (space_location and space_location.parent and space_location.parent.surface_index and space_location.parent.surface_index > 0) then
                        target_surface = game.get_surface(space_location.parent.surface_index)
                        orbit_to_surface = true
                    end
                end
            end

            if (orbit_to_surface or data.rocket_silo_data:is_ipbm_silo() or Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.ICBM_ALLOW_MULTISURFACE.name })) then
                --[[ require-space-location ]]
                gui_flow.add({
                    type = "label",
                    name = "cn_label_require_space_location",
                    caption = { "cn-launch-signal-gui.require-space-location" },
                    direction = "vertical",
                    tooltip = { "cn-launch-signal-gui.require-space-location-tooltip" },
                })
                gui_flow.add({
                    type = "checkbox",
                    name = "cn_checkbox_require_space_location",
                    state = require_space_location,
                })
                --

                --[[ space-location-index signal ]]
                gui_flow.add({
                    type = "label",
                    name = "cn_label_signal_space_location_index",
                    caption = { "cn-launch-signal-gui.signal-space-location-index" },
                    direction = "vertical",
                })
                gui_flow.add({
                    type = "choose-elem-button",
                    name = "cn_button_signal_select_space_location_index",
                    elem_type = "signal",
                    signal = signal_space_location_index
                })
                --

                --[[ space-location selection ]]
                gui_flow.add({
                    type = "label",
                    name = "cn_label_space_location",
                    caption = { "cn-launch-signal-gui.space-location" },
                    direction = "vertical",
                })

                local space_locations = se_active and Constants["space-exploration"].surfaces or Constants.get_planets(true)
                local items = {{ "cn-launch-signal-gui.list-item-none" }}
                local items_dictionary = {}

                if (orbit_to_surface) then
                    if (target_surface and target_surface.valid) then
                        table.insert(items, { "cn-launch-signal-gui.se-list-item", target_surface.index, target_surface.name })
                        items_dictionary[target_surface.name] = 2
                    end
                    if (data.rocket_silo_data.surface and data.rocket_silo_data.surface.valid) then
                        table.insert(items, { "cn-launch-signal-gui.se-list-item", data.rocket_silo_data.surface.index, data.rocket_silo_data.surface.name })
                        items_dictionary[data.rocket_silo_data.surface.name] = 3
                    end
                else
                    local i = 2
                    for k, v in pairs(space_locations) do
                        if (v.surface and v.surface.valid) then
                            if (se_active) then
                                table.insert(items, { "cn-launch-signal-gui.se-list-item", v.surface.index, v.surface.name })
                            else
                                table.insert(items, { "cn-launch-signal-gui.list-item", v.surface.index, v.name })
                            end
                            items_dictionary[v.surface.name] = i
                            i = i + 1
                        end
                    end
                end

                Log.warn(items)
                Log.warn(items_dictionary)

                local index = 1
                local name = ""
                if (orbit_to_surface) then
                    name = "cn_dropdown_orbit_to_surface"
                    if (orbit_to_surface_gui_space_location_name and items_dictionary[orbit_to_surface_gui_space_location_name] ~= nil) then index = items_dictionary[orbit_to_surface_gui_space_location_name] end
                else
                    name = "cn_dropdown_space_location"
                    if (space_location_gui_space_location_name and items_dictionary[space_location_gui_space_location_name] ~= nil) then index = items_dictionary[space_location_gui_space_location_name] end
                end

                Gui_Utils.add_dropdown({
                    gui = gui_inner,
                    name = name,
                    items = items,
                    selected_index = index,
                    default_index = 1,
                })
                --
            end
        end

        ::continue::

        gui_inner.style.padding = { 4, 6, 4, 4 }
        gui_flow.style.padding = { 4, 6, 4, 4 }
    end
end

return rocket_silo_gui_service