-- If already defined, return
if _rocket_dashboard_gui_service and _rocket_dashboard_gui_service.configurable_nukes then
  return _rocket_dashboard_gui_service
end

local Log = require("libs.log.log")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local String_Utils = require("scripts.utils.string-utils")

local rocket_dashboard_gui_service = {}
rocket_dashboard_gui_service.name = "rocket_dashboard_gui_service"

function rocket_dashboard_gui_service.instantiate_guis(data)
    Log.error("rocket_dashboard_gui_service.instantiate_guis")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    rocket_dashboard_gui_service.get_or_instantiate_button_open(data)
    rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard(data)
end

function rocket_dashboard_gui_service.get_or_instantiate_button_open(data)
    Log.error("rocket_dashboard_gui_service.get_or_instantiate_button_open")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][data.gui_data_index]) then storage.gui_data[player.index][data.gui_data_index] = {} end
    if (not storage.gui_data[player.index][data.gui_data_index][data.button_open_name]) then
        local button =
        {
            type = "button",
            caption = { "cn-rocket-dashboard.button-open" },
            name = data.button_open_name,
        }

        local cn_button_open_rocket_dashboard = nil
        if (player.gui.top.children and player.gui.top.children[1]) then
            cn_button_open_rocket_dashboard = player.gui.top.children[1].add(button)
        else
            cn_button_open_rocket_dashboard = player.gui.top.add(button)
        end

        storage.gui_data[player.index][data.gui_data_index][data.button_open_name] = cn_button_open_rocket_dashboard
    end

    return storage.gui_data[player.index][data.gui_data_index][data.button_open_name]
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
    if (not storage.gui_data[player.index][data.gui_data_index]) then storage.gui_data[player.index][data.gui_data_index] = {} end
    if (not storage.gui_data[player.index][data.gui_data_index][data.frame_main_name]) then
        local cn_frame_main = player.gui.screen.add({
            type = "frame",
            name = data.frame_main_name,
            caption = "Hola", --[[ TODO: Localise ]]
            direction = "vertical"
        })
        local gui_inner_frame = cn_frame_main.add({
            type = "frame",
            name = "inner_frame",
            style = "inside_shallow_frame_with_padding",
            direction = "vertical",
        })
        local gui_inner_table = gui_inner_frame.add({
            type = "table",
            name = "inner_table",
            column_count = 5,
            draw_vertical_lines = true,
            draw_horizontal_line_after_headers = true
        })
        gui_inner_table.style.column_alignments[1] = "left"     -- Target-#
        gui_inner_table.style.column_alignments[2] = "center"   -- Source
        gui_inner_table.style.column_alignments[3] = "center"   -- Destination
        gui_inner_table.style.column_alignments[4] = "left"     -- Time remaining
        gui_inner_table.style.column_alignments[5] = "center"   -- Scrub

        cn_frame_main.visible = false

        storage.gui_data[player.index][data.gui_data_index][data.frame_main_name] = cn_frame_main

        --[[ Headers ]]

        local padding = { 1, 4 }

        local gui = gui_inner_table.add({
            type = "label",
            name = "horiz_inner_flow_headers_target_num",
            caption = { "cn-rocket-dashboard-headers.target-num", }
        })
        gui.style.padding = padding

        gui = gui_inner_table.add({
            type = "label",
            name = "horiz_inner_flow_headers_source",
            caption = { "cn-rocket-dashboard-headers.source",  }
        })
        gui.style.padding = padding

        gui = gui_inner_table.add({
            type = "label",
            name = "horiz_inner_flow_headers_destination",
            caption = { "cn-rocket-dashboard-headers.destination",  }
        })
        gui.style.padding = padding

        gui = gui_inner_table.add({
            type = "label",
            name = "horiz_inner_flow_headers_time_remaining",
            caption = { "cn-rocket-dashboard-headers.time-remaining",  }
        })
        gui.style.padding = padding

        gui = gui_inner_table.add({
            type = "label",
            name = "horiz_inner_flow_headers_scrub",
            caption = { "cn-rocket-dashboard-headers.scrub",  }
        })
        gui.style.padding = padding

        --[[ Data ]]

        local all_icbm_meta_data = ICBM_Meta_Repository.get_all_icbm_meta_data()

        if (all_icbm_meta_data) then
            for _, icbm_meta_data in pairs(all_icbm_meta_data) do
                if (type(icbm_meta_data) ~= "table") then goto continue end
                if (icbm_meta_data.icbms and type(icbm_meta_data.icbms) == "table") then
                    for _, icbm in pairs(icbm_meta_data.icbms) do
                        if (icbm.tick_launched and icbm.tick_launched > 0 and icbm.tick_to_target and icbm.tick_to_target > 0) then
                            icbm.cargo_pod = nil
                        end

                        rocket_dashboard_gui_service.add_rocket_data({
                            storage_ref = storage.gui_data[player.index][data.gui_data_index],
                            gui = gui_inner_table,
                            icbm_data = icbm,
                            frame_main_name = data.frame_main_name,
                        })
                    end
                end
                :: continue ::
            end
        end

    end

    return storage.gui_data[player.index][data.gui_data_index][data.frame_main_name]
end

function rocket_dashboard_gui_service.add_rocket_data_for_force(data)
    Log.error("rocket_dashboard_gui_service.add_rocket_data_for_force")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    local force = data.icbm_data.force
    if (not force or not force.valid) then return end
    local players = force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
            gui_data_index = data.gui_data_index,
            frame_main_name = data.frame_main_name,
        })

        if (dashboard_gui and dashboard_gui.inner_frame and dashboard_gui.inner_frame.inner_table) then
            rocket_dashboard_gui_service.add_rocket_data({
                storage_ref = storage.gui_data[player.index][data.gui_data_index],
                icbm_data = data.icbm_data,
                gui = dashboard_gui.inner_frame.inner_table,
            })
        end
    end
end

function rocket_dashboard_gui_service.remove_rocket_data_for_force(data)
    Log.error("rocket_dashboard_gui_service.remove_rocket_data_for_force")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    local force = data.icbm_data.force
    if (not force or not force.valid) then return end
    local players = force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
            gui_data_index = data.gui_data_index,
            frame_main_name = data.frame_main_name,
        })

        if (dashboard_gui and dashboard_gui.inner_frame and dashboard_gui.inner_frame.inner_table) then
            rocket_dashboard_gui_service.remove_rocket_data({
                storage_ref = storage.gui_data[player.index][data.gui_data_index],
                icbm_data = data.icbm_data,
                gui = dashboard_gui.inner_frame.inner_table,
            })
        end
    end
end

function rocket_dashboard_gui_service.remove_rocket_data(data)
    Log.error("rocket_dashboard_gui_service.remove_rocket_data")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.storage_ref or type(data.storage_ref) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end
    if (not data.gui or not data.gui.valid) then return end

    local prefix = "inner_table_" .. data.icbm_data.item_number

    local removed = false
    -- Check if the gui element already exists
    for k, gui in pairs(data.gui.children) do
        if (gui.name and gui.name:find(prefix, 1, true) == 1) then
            gui.destroy()
            removed = true
        end
    end

    if (removed) then
        data.storage_ref[data.icbm_data.item_number] = nil
    end
end

function rocket_dashboard_gui_service.add_rocket_data(data)
    Log.error("rocket_dashboard_gui_service.add_rocket_data")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.storage_ref or type(data.storage_ref) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end
    if (not data.gui or not data.gui.valid) then return end

    local prefix = "inner_table_" .. data.icbm_data.item_number

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
    local caption_source = data.icbm_data.surface and data.icbm_data.surface.valid and data.icbm_data.surface.name or data.icbm_data.surface_name
    if (caption_source and caption_source:find("platform-", 1, true) == 1) then
        local surface = game.get_surface(caption_source)
        if (surface and surface.valid) then
            if (surface.platform and surface.platform.valid) then
                caption_source = surface.platform.name
            end
        end
    end
    caption_source = String_Utils.format_surface_name({ string_data = caption_source })

    local caption_destination = data.icbm_data.target_surface and data.icbm_data.target_surface.valid and data.icbm_data.target_surface.name or data.icbm_data.target_surface_name
    caption_destination = String_Utils.format_surface_name({ string_data = caption_destination })

    local time_remaining = math.floor((data.icbm_data.tick_to_target - game.tick) / 60)
    if (time_remaining < 0) then time_remaining = "?" end

    if (caption_target_num == nil or caption_source == nil or caption_destination == nil) then
        return
    end

    data.storage_ref[data.icbm_data.item_number] = data.icbm_data

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
        name = prefix .. "_source",
        caption = caption_source, --[[ TODO: Localise? ]]
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
        name = prefix .. "_destination",
        caption = caption_destination, --[[ TODO: Localise? ]]
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
    gui.style.left_padding = 4
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
    })
    gui.style.size = 24
    gui.style.padding = padding
    parent_gui.style.padding = padding

    ---
end

function rocket_dashboard_gui_service.on_label_clicked(data)
    Log.error("rocket_dashboard_gui_service.on_label_clicked")
    Log.warn(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index or type(data.player_index) ~= "number" or data.player_index < 1) then return end
    if (not data.item_number or type(data.item_number) ~= "number" or data.item_number < 1) then return end
    if (not data.label or type(data.label) ~= "string") then return end

    local player = game.get_player(data.player_index)
    if (not player or not player.valid) then return end

    if (not storage.gui_data) then storage.gui_data = {} end
    if (not storage.gui_data[player.index]) then storage.gui_data[player.index] = {} end
    if (not storage.gui_data[player.index][data.gui_data_index]) then storage.gui_data[player.index][data.gui_data_index] = {} end

    if (storage.gui_data[player.index][data.gui_data_index][data.item_number]) then
        local icbm_data = storage.gui_data[player.index][data.gui_data_index][data.item_number]
        if (data.label == "source") then
            if (icbm_data.source_silo and icbm_data.source_silo.valid) then
                player.print({"", { "cn-rocket-dashboard.source-silo", data.item_number}, { "cn-rocket-dashboard.gps", icbm_data.source_silo.position.x, icbm_data.source_silo.position.y, icbm_data.source_silo.surface.name }, })
            end
        elseif (data.label == "destination") then
            if (icbm_data.original_target_position and icbm_data.target_surface and icbm_data.target_surface.valid) then
                player.print({"", { "cn-rocket-dashboard.destination", data.item_number}, { "cn-rocket-dashboard.gps", icbm_data.original_target_position.x, icbm_data.original_target_position.y, icbm_data.target_surface.name }, })
            end
        end
    end
end

function rocket_dashboard_gui_service.update_time_remaining(data)
    -- Log.debug("rocket_dashboard_gui_service.update_time_remaining")
    -- Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.frame_main_name) then return end
    if (not data.force or not data.force.valid) then return end

    local players = data.force.players
    if (not players or not next(players, nil)) then return end

    for k, player in pairs(players) do
        local dashboard_gui = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard({
            player_index = player.index,
            gui_data_index = data.gui_data_index,
            frame_main_name = data.frame_main_name,
        })

        if (dashboard_gui and dashboard_gui.inner_frame and dashboard_gui.inner_frame.inner_table) then
            rocket_dashboard_gui_service.update_rocket_data({
                player_index = player.index,
                gui_data_index = data.gui_data_index,
                storage_ref = storage.gui_data[player.index][data.gui_data_index],
                gui = dashboard_gui.inner_frame.inner_table,
            })
        end
    end
end

function rocket_dashboard_gui_service.update_rocket_data(data)
    Log.debug("rocket_dashboard_gui_service.update_rocket_data")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.player_index) then return end
    if (not data.gui_data_index) then return end
    if (not data.storage_ref) then return end
    if (not data.gui or not data.gui.valid) then return end

    for k, child_gui in pairs(data.gui.children) do

        if (not child_gui or not child_gui.valid) then goto continue end

        local _, _, item_number, label = child_gui.name:find("inner_table_(%d+)_(%g+)")
        item_number = item_number ~= nil and tonumber(item_number) or nil
        if (label ~= "time_remaining_flow") then goto continue end

        if (item_number ~= nil and storage.gui_data[data.player_index][data.gui_data_index][item_number]) then
            local icbm_data = storage.gui_data[data.player_index][data.gui_data_index][item_number]
            if (icbm_data.tick_to_target <= 0) then

                local _icbm_data = ICBM_Repository.get_icbm_data(icbm_data.surface_name, icbm_data.item_number)
                if (_icbm_data and _icbm_data.valid) then
                    icbm_data = _icbm_data
                    storage.gui_data[data.player_index][data.gui_data_index][item_number] = icbm_data
                end
            end

            local time_remaining = 0
            if (icbm_data and icbm_data.tick_to_target ~= nil) then
                if (label == "time_remaining_flow") then
                    time_remaining = (icbm_data.tick_to_target - game.tick) / 60
                    local directive = "%d"

                    if (time_remaining % 1 ~= 0) then
                        directive = "%.1f"
                    end

                    if (time_remaining < 0) then time_remaining = 0 end
                    child_gui.children[1].caption = time_remaining == 0 and "?" or string.format(directive, time_remaining)
                end
            end

            if (icbm_data.tick_to_target > 0 and game.tick > icbm_data.tick_to_target) then
                rocket_dashboard_gui_service.remove_rocket_data({
                    storage_ref = data.storage_ref,
                    icbm_data = icbm_data,
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
    if (not storage.gui_data[player.index][data.gui_data_index]) then storage.gui_data[player.index][data.gui_data_index] = {} end

    local cn_button_open_rocket_dashboard = nil
    if (storage.gui_data[player.index][data.gui_data_index][data.button_open_name]) then
        cn_button_open_rocket_dashboard = storage.gui_data[player.index][data.gui_data_index][data.button_open_name]
        cn_button_open_rocket_dashboard.toggled = not cn_button_open_rocket_dashboard.toggled
    end

    local cn_frame_main = nil
    if (not storage.gui_data[player.index][data.gui_data_index][data.frame_main_name]) then
        cn_frame_main = rocket_dashboard_gui_service.get_or_instantiate_rocket_dashboard(data)
    end

    cn_frame_main = cn_frame_main or storage.gui_data[player.index][data.gui_data_index][data.frame_main_name]

    if (not cn_frame_main or not cn_frame_main.valid) then return end

    cn_frame_main.visible = cn_button_open_rocket_dashboard and cn_button_open_rocket_dashboard.toggled
end

rocket_dashboard_gui_service.configurable_nukes = true

local _rocket_dashboard_gui_service = rocket_dashboard_gui_service

return rocket_dashboard_gui_service