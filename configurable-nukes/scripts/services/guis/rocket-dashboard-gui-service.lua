-- If already defined, return
if _rocket_dashboard_gui_service and _rocket_dashboard_gui_service.configurable_nukes then
  return _rocket_dashboard_gui_service
end

local Mod_Gui = require("__core__.lualib.mod-gui")

local Force_Launch_Data_Repository = require("scripts.repositories.force-launch-data-repository")
local Gui_Utils = require("scripts.utils.gui-utils")
local Log = require("libs.log.log")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local Rocket_Dashboard_Constants = require("scripts.constants.gui.rocket-dashboard-constants")
local String_Utils = require("scripts.utils.string-utils")

local rocket_dashboard_gui_service = {}
rocket_dashboard_gui_service.name = "rocket_dashboard_gui_service"

function rocket_dashboard_gui_service.instantiate_guis(data)
    Log.debug("rocket_dashboard_gui_service.instantiate_guis")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    rocket_dashboard_gui_service.get_or_instantiate_button_open(data)
    rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard(data)
end

function rocket_dashboard_gui_service.get_or_instantiate_button_open(data)
    Log.debug("rocket_dashboard_gui_service.get_or_instantiate_button_open")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index][Rocket_Dashboard_Constants.button_open_name]) then
        local button =
        {
            type = "button",
            caption = { "cn-rocket-dashboard.button-open" },
            name = Rocket_Dashboard_Constants.button_open_name,
            style = "mod_gui_button",
            tooltip = { "cn-rocket-dashboard.button-tooltip", }
        }

        local cn_button_open_rocket_dashboard = nil
        local mod_button_flow = Mod_Gui.get_button_flow(player)
        if (mod_button_flow) then
            if (mod_button_flow[Rocket_Dashboard_Constants.button_open_name]) then
                cn_button_open_rocket_dashboard = mod_button_flow[Rocket_Dashboard_Constants.button_open_name]
            else
                cn_button_open_rocket_dashboard = mod_button_flow.add(button)
            end
        else
            if (player.gui.top[Rocket_Dashboard_Constants.button_open_name]) then
                cn_button_open_rocket_dashboard = player.gui.top[Rocket_Dashboard_Constants.button_open_name]
            else
                cn_button_open_rocket_dashboard = player.gui.top.add(button)
            end
        end

        storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index][Rocket_Dashboard_Constants.button_open_name] = cn_button_open_rocket_dashboard
    end

    return storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index][Rocket_Dashboard_Constants.button_open_name]
end

function rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard(data)
    -- Log.debug("rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard")
    -- Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end
    local storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]
    if (not storage_ref[Rocket_Dashboard_Constants.frame_main_name]) then

        local get_or_instantiate = function (params)
            -- Log.debug("local.get_or_instantiate")
            -- Log.info(params)

            if (not params or type(params) ~= "table") then return end
            ---@diagnostic disable-next-line: undefined-field
            if (not params.gui or not params.gui.valid) then return end
            if (not params.name or type(params.name) ~= "string") then return end
            if (not params.element_to_instantiate or type(params.element_to_instantiate) ~= "table") then return end
            if (not params.element_to_instantiate.type or type(params.element_to_instantiate.type) ~= "string") then return end

            local return_val = nil
            if (params.gui[params.name]) then
                return_val = params.gui[params.name]
            else
                ---@diagnostic disable-next-line: undefined-field
                return_val = params.gui.add(params.element_to_instantiate)
            end

            return return_val
        end

        local cn_frame_main = get_or_instantiate({
            gui = player.gui.screen,
            name = Rocket_Dashboard_Constants.frame_main_name,
            element_to_instantiate =
            {
                type = "frame",
                name = Rocket_Dashboard_Constants.frame_main_name,
                direction = "vertical",
                location = { 268, 98 },
            }
        })

        local header_flow = get_or_instantiate({
            gui = cn_frame_main,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_header_flow",
            element_to_instantiate =
            {
                type = "flow",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_header_flow",
            }
        })

        local title = get_or_instantiate({
            gui = header_flow,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_header_title",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_header_title",
                style = "frame_title",
                caption = { "cn-rocket-dashboard.frame-title", }
            }
        })
        title.drag_target = cn_frame_main

        local dragger = get_or_instantiate({
            gui = header_flow,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_dragger",
            element_to_instantiate =
            {
                type = "empty-widget",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_dragger",
                style = "draggable_space_header",
            }
        })
        dragger.style.vertically_stretchable = true
        dragger.style.horizontally_stretchable = true
        dragger.drag_target = cn_frame_main

        local pin_button = get_or_instantiate({
            gui = header_flow,
            name = Rocket_Dashboard_Constants.button_pin_name,
            element_to_instantiate =
            {
                type = "sprite-button",
                style = "frame_action_button",
                name =  Rocket_Dashboard_Constants.button_pin_name,
                sprite = "utility/track_button",
                auto_toggle = true,
            }
        })
        storage_ref.pin_button = pin_button

        local close_button = get_or_instantiate({
            gui = header_flow,
            name = Rocket_Dashboard_Constants.button_close_name,
            element_to_instantiate =
            {
                type = "sprite-button",
                name =  Rocket_Dashboard_Constants.button_close_name,
                style = "frame_action_button",
                sprite = "utility/close"
            }
        })
        storage_ref.close_button = close_button

        local gui_inner_frame = get_or_instantiate({
            gui = cn_frame_main,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_inner_frame",
            element_to_instantiate =
            {
                type = "frame",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_inner_frame",
                style = "inside_shallow_frame_with_padding",
                direction = "vertical",
            }
        })
        storage_ref.inner_frame = gui_inner_frame

        local gui_inner_table = get_or_instantiate({
            gui = gui_inner_frame,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_inner_table",
            element_to_instantiate =
            {
                type = "table",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_inner_table",
                column_count = 5,
                draw_vertical_lines = true,
                draw_horizontal_line_after_headers = true,
                style = "cn_rocket_dashboard_table",
            }
        })
        storage_ref.inner_table = gui_inner_table

        cn_frame_main.visible = false

        storage_ref[Rocket_Dashboard_Constants.frame_main_name] = cn_frame_main

        --[[ Headers ]]

        local padding = { 1, 4 }

        local gui = get_or_instantiate({
            gui = gui_inner_table,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_target_num",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_target_num",
                caption = { "cn-rocket-dashboard-headers.target-num", }
            }
        })
        gui.style.padding = padding

        gui = get_or_instantiate({
            gui = gui_inner_table,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_source",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_source",
                caption = { "cn-rocket-dashboard-headers.source",  }
            }
        })
        gui.style.padding = padding

        gui = get_or_instantiate({
            gui = gui_inner_table,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_destination",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_destination",
                caption = { "cn-rocket-dashboard-headers.destination",  }
            }
        })
        gui.style.padding = padding

        gui = get_or_instantiate({
            gui = gui_inner_table,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_time_remaining",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_time_remaining",
                caption = { "cn-rocket-dashboard-headers.time-remaining",  },
                tooltip = { "cn-rocket-dashboard.time-remaining-tooltip", }
            }
        })
        gui.style.padding = padding

        gui = get_or_instantiate({
            gui = gui_inner_table,
            name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_scrub",
            element_to_instantiate =
            {
                type = "label",
                name = Rocket_Dashboard_Constants.gui_data_index .. "_horiz_inner_flow_headers_scrub",
                caption = { "cn-rocket-dashboard-headers.scrub",  },
                tooltip = { "cn-rocket-dashboard.scrub-tooltip", }
            }
        })
        gui.style.padding = padding

        --[[ Data ]]

        local all_icbm_meta_data = ICBM_Meta_Repository.get_all_icbm_meta_data()

        if (all_icbm_meta_data) then
            local icbms = {}
            for _, icbm_meta_data in pairs(all_icbm_meta_data) do
                if (type(icbm_meta_data) ~= "table") then goto continue end
                if (icbm_meta_data.icbms and type(icbm_meta_data.icbms) == "table") then
                    for _, icbm in pairs(icbm_meta_data.icbms) do
                        if (icbm.tick_launched and icbm.tick_launched > 0 and icbm.tick_to_target and icbm.tick_to_target > 0) then
                            icbm.cargo_pod = nil
                        end

                        icbms[icbm.item_number] = icbm
                    end
                end
                :: continue ::
            end

            local icbms_array = {}
            for item_number, icbm_data in pairs(icbms) do
                if (#icbms_array == 0) then
                    table.insert(icbms_array, icbm_data)
                else
                    local i = 1
                    while i <= #icbms_array do
                        if (icbms_array[i].item_number > item_number) then break end
                        i = i + 1
                    end
                    if (i > #icbms_array) then
                        table.insert(icbms_array, icbm_data)
                    else
                        table.insert(icbms_array, i, icbm_data)
                    end
                end
            end

            local i = 1
            while i <= #icbms_array do
                local icbm_data = icbms_array[i]
                if (icbm_data.force_index > 0 and icbm_data.force_index < 64) then
                    if (icbm_data.cargo_pod and not icbm_data.cargo_pod.valid) then icbm_data.cargo_pod = nil end

                    local force_launch_data = Force_Launch_Data_Repository.get_force_launch_data(icbm_data.force_index)
                    local enqueued_data = force_launch_data.launch_action_queue:enqueue({
                        data =
                        {
                            tick = game.tick,
                            icbm_data = icbm_data,
                        }
                    })
                    icbm_data.enqueued_data = enqueued_data

                    Log.warn(icbm_data)

                    icbm_data = ICBM_Repository.update_icbm_data(icbm_data)

                    rocket_dashboard_gui_service.add_rocket_data({
                        storage_ref = storage_ref,
                        gui = gui_inner_table,
                        icbm_data = icbm_data,
                    })
                end

                i = i + 1
            end
        end
    end

    return storage_ref[Rocket_Dashboard_Constants.frame_main_name]
end

function rocket_dashboard_gui_service.add_rocket_data_for_force(data)
    Log.debug("rocket_dashboard_gui_service.add_rocket_data_for_force")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    local force = data.icbm_data.force
    if (not force or not force.valid) then return end
    local players = force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
        })

        if (dashboard_gui) then
            rocket_dashboard_gui_service.add_rocket_data({
                storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index],
                icbm_data = data.icbm_data,
            })
        end
    end
end

function rocket_dashboard_gui_service.remove_rocket_data_for_force(data)
    Log.debug("rocket_dashboard_gui_service.remove_rocket_data_for_force")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    local force = data.icbm_data.force
    if (not force or not force.valid) then return end
    local players = force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
        })

        if (dashboard_gui) then
            rocket_dashboard_gui_service.remove_rocket_data({
                storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index],
                item_number = data.icbm_data.item_number,
            })
        end
    end
end

function rocket_dashboard_gui_service.remove_rocket_data(data)
    Log.debug("rocket_dashboard_gui_service.remove_rocket_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.storage_ref or type(data.storage_ref) ~= "table") then return end
    if (not data.storage_ref.item_numbers or type(data.storage_ref.item_numbers) ~= "table") then return end
    if (not data.item_number or type(data.item_number) ~= "number" or data.item_number < 1) then return end
    if (not data.gui or not data.gui.valid) then
        data.gui = data.storage_ref.inner_table
        if (not data.gui or not data.gui.valid) then return end
    end

    local prefix = Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_" .. data.item_number

    local removed = false
    -- Check if the gui element already exists
    for k, gui in pairs(data.gui.children) do
        if (gui.name and gui.name:find(prefix, 1, true) == 1) then
            gui.destroy()
            removed = true
        end
    end

    if (removed) then
        data.storage_ref.item_numbers[data.item_number] = nil
    end
end

function rocket_dashboard_gui_service.add_rocket_data(data)
    Log.debug("rocket_dashboard_gui_service.add_rocket_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.storage_ref or type(data.storage_ref) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end
    if (not data.gui or not data.gui.valid) then
        data.gui = data.storage_ref.inner_table
        if (not data.gui or not data.gui.valid) then return end
    end

    local prefix = Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_" .. data.icbm_data.item_number

    -- Check if the gui element already exists
    local existing_guis = {}
    for k, gui in pairs(data.gui.children) do
        if (gui.name and gui.name:find(prefix, 1, true) == 1) then
            gui.clear()
            existing_guis[gui] = gui.name
            existing_guis[gui.name] = gui
        end
    end

    local padding = { 1, 4 }
    local caption_target_num = data.icbm_data.item_number
    local source_name = data.icbm_data.surface and data.icbm_data.surface.valid and data.icbm_data.surface.name or data.icbm_data.surface_name
    local caption_source = String_Utils.format_surface_name({
        string_data = Gui_Utils.get_platform_name_from_surface({
            icbm_data = data.icbm_data
        })
    })

    local caption_destination = data.icbm_data.target_surface and data.icbm_data.target_surface.valid and data.icbm_data.target_surface.name or data.icbm_data.target_surface_name
    caption_destination = String_Utils.format_surface_name({ string_data = caption_destination })

    local time_remaining = math.floor((data.icbm_data.tick_to_target - game.tick) / 60)
    if (time_remaining < 0) then time_remaining = "?" end

    if (caption_target_num == nil or caption_source == nil or caption_destination == nil) then
        return
    end

    if (not data.storage_ref.item_numbers) then data.storage_ref.item_numbers = {} end
    data.storage_ref.item_numbers[data.icbm_data.item_number] =
    {
        icbm_data = data.icbm_data,
        surface_name = source_name,
    }

    local gui = nil
    local parent_gui = nil

    if (existing_guis[prefix .. "_target_num_flow"] and existing_guis[prefix .. "_target_num_flow"].valid) then
        parent_gui = existing_guis[prefix .. "_target_num_flow"]
    else
        parent_gui = data.gui.add({
            type = "flow",
            name = prefix .. "_target_num_flow",
            direction = "horizontal",
        })
    end
    gui = parent_gui.add({
        type = "label",
        name = prefix .. "_target_num",
        caption = { "cn-rocket-dashboard-data.target-num", caption_target_num },
    })
    parent_gui.style.padding = padding

    ---

    if (existing_guis[prefix .. "_source_flow"] and existing_guis[prefix .. "_source_flow"].valid) then
        parent_gui = existing_guis[prefix .. "_source_flow"]
    else
        parent_gui = data.gui.add({
            type = "flow",
            name = prefix .. "_source_flow",
            direction = "horizontal",
        })
    end

    gui = parent_gui.add({
        type = "label",
        name = prefix .. "_source_label",
        caption = caption_source, --[[ TODO: Localise? ]]
        tooltip = { "cn-rocket-dashboard-data.source-label-tooltip", }
    })
    gui.style.hovered_font_color = { 0, 31, 191 }
    parent_gui.style.padding = padding

    ---

    if (existing_guis[prefix .. "_destination_flow"] and existing_guis[prefix .. "_destination_flow"].valid) then
        parent_gui = existing_guis[prefix .. "_destination_flow"]
    else
        parent_gui = data.gui.add({
            type = "flow",
            name = prefix .. "_destination_flow",
            direction = "horizontal",
        })
    end

    gui = parent_gui.add({
        type = "label",
        name = prefix .. "_destination_label",
        caption = caption_destination, --[[ TODO: Localise? ]]
        tooltip = { "cn-rocket-dashboard-data.destination-label-tooltip", }
    })
    gui.style.hovered_font_color = { 0, 31, 191 }
    parent_gui.style.padding = padding

    ---

    if (existing_guis[prefix .. "_time_remaining_flow"] and existing_guis[prefix .. "_time_remaining_flow"].valid) then
        parent_gui = existing_guis[prefix .. "_time_remaining_flow"]
    else
        parent_gui = data.gui.add({
            type = "flow",
            name = prefix .. "_time_remaining_flow",
            direction = "horizontal",
        })
    end

    gui = parent_gui.add({
        type = "label",
        name = prefix .. "_time_remaining",
        caption = time_remaining, --[[ TODO: Localise? ]]
    })
    parent_gui.style.padding = padding

    ---

    if (existing_guis[prefix .. "_scrub_flow"] and existing_guis[prefix .. "_scrub_flow"].valid) then
        parent_gui = existing_guis[prefix .. "_scrub_flow"]
    else
        parent_gui = data.gui.add({
            type = "flow",
            name = prefix .. "_scrub_flow",
            direction = "horizontal",
        })
    end

    gui = parent_gui.add({
        type = "sprite-button",
        sprite = "cn-close-icon",
        name = prefix .. "_scrub_button",
        tooltip = { "cn-rocket-dashboard-data.scrub-button-tooltip", data.icbm_data.item_number }
    })
    gui.style.size = 24
    gui.style.padding = padding
    parent_gui.style.padding = padding

    ---
end

function rocket_dashboard_gui_service.on_label_clicked(data)
    Log.debug("rocket_dashboard_gui_service.on_label_clicked")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end
    if (not data.item_number or type(data.item_number) ~= "number" or data.item_number < 1) then return end
    if (not data.label or type(data.label) ~= "string") then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end

    local storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]
    if (not storage_ref.item_numbers) then storage_ref.item_numbers = {} end

    if (storage_ref.item_numbers[data.item_number]) then
        local icbm_data = storage_ref.item_numbers[data.item_number].icbm_data
        if (icbm_data and icbm_data.valid) then
            if (data.label == "source_label") then
                if (icbm_data.source_silo and icbm_data.source_silo.valid) then
                    player.print({"", { "cn-rocket-dashboard.source-silo", data.item_number}, { "cn-rocket-dashboard.gps", icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, icbm_data.source_silo.surface.name }, })
                end
            elseif (data.label == "destination_label") then
                if (icbm_data.original_target_position and icbm_data.target_surface and icbm_data.target_surface.valid) then
                    player.print({"", { "cn-rocket-dashboard.destination", data.item_number}, { "cn-rocket-dashboard.gps", icbm_data.original_target_position.x, icbm_data.original_target_position.y, icbm_data.target_surface.name }, })
                end
            end
        end
    end
end

function rocket_dashboard_gui_service.update_time_remaining(data)
    -- Log.debug("rocket_dashboard_gui_service.update_time_remaining")
    -- Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.force or not data.force.valid) then return end

    local players = data.force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
        })

        if (dashboard_gui) then
            rocket_dashboard_gui_service.update_rocket_data({
                player_index = player.index,
                storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index],
            })
        end
    end
end

function rocket_dashboard_gui_service.update_rocket_data(data)
    -- Log.debug("rocket_dashboard_gui_service.update_rocket_data")
    -- Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index) then return end
    if (not data.storage_ref) then return end
    if (not data.storage_ref.item_numbers) then return end
    if (not data.gui or not data.gui.valid) then
        data.gui = data.storage_ref.inner_table
        if (not data.gui or not data.gui.valid) then return end
    end

    for k, child_gui in pairs(data.gui.children) do

        if (not child_gui or not child_gui.valid) then goto continue end

        local _, _, item_number, label = child_gui.name:find("inner_table_(%d+)_(%g+)")
        item_number = item_number ~= nil and tonumber(item_number) or nil

        if (label ~= "time_remaining_flow" and label ~= "source_flow") then goto continue end

        if (item_number ~= nil and data.storage_ref.item_numbers[item_number]) then
            local meta_icbm_data = data.storage_ref.item_numbers[item_number]
            local icbm_data = meta_icbm_data.icbm_data
            if (icbm_data and icbm_data.valid and icbm_data.tick_to_target <= 0) then

                local _icbm_data = ICBM_Repository.get_icbm_data(meta_icbm_data.surface_name, icbm_data.item_number)
                if (_icbm_data and _icbm_data.valid) then
                    icbm_data = _icbm_data
                    meta_icbm_data.icbm_data = icbm_data
                else
                    rocket_dashboard_gui_service.remove_rocket_data({
                        storage_ref = data.storage_ref,
                        item_number = icbm_data.item_number,
                        gui = data.gui,
                    })
                    goto continue
                end
            end

            local time_remaining = 0
            if (icbm_data and icbm_data.valid and icbm_data.tick_to_target ~= nil) then
                if (label == "source_flow") then
                    child_gui.children[1].caption = String_Utils.format_surface_name({
                        string_data = Gui_Utils.get_platform_name_from_surface({
                            icbm_data = icbm_data
                        })
                    })
                elseif (label == "time_remaining_flow") then
                    time_remaining = (icbm_data.tick_to_target - game.tick) / 60
                    local directive = "%.1f"

                    local formatted_time_remaining = "?"
                    local years = time_remaining / (60 * 60 * 24 * 365)
                    local days = (years % 1) * 365
                    local hours = (days % 1) * 24
                    local minutes = (hours % 1) * 60
                    local seconds = (minutes % 1) * 60

                    years = years - (years % 1)
                    days = days - (days % 1)
                    hours = hours - (hours % 1)
                    minutes = minutes - (minutes % 1)

                    if (years >= 1) then
                        directive = "%d Y, %d D, %d:"

                        if (minutes < 10) then directive = directive .. "0%d:"
                        else directive = directive .. "%d:"
                        end

                        if (seconds < 10) then directive = directive .. "0%.1f"
                        else directive = directive .. "%.1f"
                        end

                        formatted_time_remaining = string.format(directive, years, days, hours, minutes, seconds)

                    elseif (days >= 1) then
                        directive = "%dD, %d:"

                        if (minutes < 10) then directive = directive .. "0%d:"
                        else directive = directive .. "%d:"
                        end

                        if (seconds < 10) then directive = directive .. "0%.1f"
                        else directive = directive .. "%.1f"
                        end

                        formatted_time_remaining = string.format(directive, days, hours, minutes, seconds)
                    elseif (hours >= 1) then
                        directive = "%d:"

                        if (minutes < 10) then directive = directive .. "0%d:"
                        else directive = directive .. "%d:"
                        end

                        if (seconds < 10) then directive = directive .. "0%.1f"
                        else directive = directive .. "%.1f"
                        end

                        formatted_time_remaining = string.format(directive, hours, minutes, seconds)
                    elseif (minutes >= 1) then
                        directive = "%d:"

                        if (seconds < 10) then directive = directive .. "0%.1f"
                        else directive = directive .. "%.1f"
                        end

                        formatted_time_remaining = string.format(directive, minutes, seconds)
                    else
                        directive = "%.1f"
                        formatted_time_remaining = string.format(directive, time_remaining)
                    end

                    if (time_remaining < 0) then time_remaining = 0 end
                    child_gui.children[1].caption = time_remaining == 0 and "?" or formatted_time_remaining
                end
            end

            if (    icbm_data
                and icbm_data.valid
                and icbm_data.tick_to_target > 0
                and game.tick > icbm_data.tick_to_target
            ) then
                rocket_dashboard_gui_service.remove_rocket_data({
                    storage_ref = data.storage_ref,
                    item_number = icbm_data.item_number,
                    gui = data.gui,
                })
            end
        end

        ::continue::
    end
end

function rocket_dashboard_gui_service.toggle_rocket_dashboard(data)
    Log.error("rocket_dashboard_gui_service.toggle_rocket_dashboard")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end
    local storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]

    local cn_button_open_rocket_dashboard = nil
    if (storage_ref[Rocket_Dashboard_Constants.button_open_name]) then
        cn_button_open_rocket_dashboard = storage_ref[Rocket_Dashboard_Constants.button_open_name]

        if ((
                    not storage_ref.pinned
                or data.override_pinned
            )
                and not data.center
                and data.pinned == nil
            or
                    data.button_name
                and data.button_name == Rocket_Dashboard_Constants.button_close_name
        ) then
            cn_button_open_rocket_dashboard.toggled = not cn_button_open_rocket_dashboard.toggled
        end
    end

    local cn_frame_main = nil
    if (not storage_ref[Rocket_Dashboard_Constants.frame_main_name]) then
        cn_frame_main = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard(data)
    end

    cn_frame_main = cn_frame_main or storage_ref[Rocket_Dashboard_Constants.frame_main_name]

    if (not cn_frame_main or not cn_frame_main.valid) then return end

    cn_frame_main.visible = cn_button_open_rocket_dashboard and cn_button_open_rocket_dashboard.toggled or data.pinned ~= nil and data.pinned

    if (data.center) then cn_frame_main.force_auto_center() end
    if (data.pinned ~= nil) then
        if (data.button and data.button.valid) then
            if (data.button.name:find("_pin_button$")) then
                storage_ref.pinned = data.button.toggled
            end
        end
    end

    if (not cn_frame_main.visible) then
        if (storage_ref.pin_button) then
            storage_ref.pinned = false
            storage_ref.pin_button.toggled = storage_ref.pinned
        end
    else
        if (storage_ref.pin_button) then
            storage_ref.pinned = storage_ref.pin_button.toggled
            storage_ref.pin_button.toggled = storage_ref.pinned
        end
    end
end

function rocket_dashboard_gui_service.close_rocket_dashboard(data)
    Log.debug("rocket_dashboard_gui_service.close_rocket_dashboard")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end
    local storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]

    local cn_frame_main = storage_ref[Rocket_Dashboard_Constants.frame_main_name]
    if (cn_frame_main and cn_frame_main.valid) then
        if (not storage_ref.pinned and cn_frame_main.visible) then
            rocket_dashboard_gui_service.toggle_rocket_dashboard({
                player_index = data.player_index,
                button_name = Rocket_Dashboard_Constants.button_close_name,
            })
        end
    end
end

function rocket_dashboard_gui_service.update_gui_data(data)
    Log.debug("rocket_dashboard_gui_service.update_gui_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]) then storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index] = {} end

    local storage_ref = storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index]
    if (not storage_ref.item_numbers) then storage_ref.item_numbers = {} end

    if (storage_ref.item_numbers) then
        for k, v in pairs(storage_ref.item_numbers) do
            local _icbm_data = ICBM_Repository.get_icbm_data(v.surface_name, k)
            if (_icbm_data and _icbm_data.valid) then
                storage_ref.item_numbers[k].icbm_data = _icbm_data
            else
                rocket_dashboard_gui_service.remove_rocket_data({
                    storage_ref = storage_ref,
                    item_number = k,
                })
            end
        end
    end
end

rocket_dashboard_gui_service.configurable_nukes = true

local _rocket_dashboard_gui_service = rocket_dashboard_gui_service

return rocket_dashboard_gui_service