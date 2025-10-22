-- If already defined, return
if _rocket_dashboard_gui_controller and _rocket_dashboard_gui_controller.configurable_nukes then
  return _rocket_dashboard_gui_controller
end

local Custom_Events = require("prototypes.custom-events.custom-events")

local Log = require("libs.log.log")
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Rocket_Silo_Utils = require("scripts.utils.rocket-silo-utils")

local rocket_dashboard_gui_controller = {}

rocket_dashboard_gui_controller.name = "rocket_dashboard_gui_controller"

local gui_data_index = "cn_rocket_dashboard"
rocket_dashboard_gui_controller.gui_data_index = gui_data_index

local button_open_name = gui_data_index .. ".button_open"
local frame_main_name = gui_data_index .. ".frame_main"

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

local forces_blacklist =
{
    ["enemy"] = true,
    ["neutral"] = true,
}

local clickable_labels =
{
    ["source"] = true,
    ["destination"] = true,
}

if (se_active) then
    forces_blacklist["conquest"] = true
    forces_blacklist["ignore"] = true
    forces_blacklist["capture"] = true
    forces_blacklist["friendly"] = true
end

function rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard(event)
    Log.error("rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard")
    Log.warn(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name ~= button_open_name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    Rocket_Dashboard_Gui_Service.toggle_rocket_dashboard({
        player_index = event.player_index,
        gui_data_index = gui_data_index,
        button_open_name = button_open_name,
        frame_main_name = frame_main_name,
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard",
    func_name = "rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard",
    func = rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard,
})

function rocket_dashboard_gui_controller.on_scrub_button_clicked(event)
    Log.error("rocket_dashboard_gui_controller.on_scrub_button_clicked")
    Log.warn(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name:find("inner_table_%d+") ~= 1) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local _, _, item_number, button_name = event.element.name:find("inner_table_(%d+)_(%g+)")
    if (not button_name or button_name ~= "scrub_button") then return end

    local storage_ref = storage.gui_data and storage.gui_data[event.player_index] and storage.gui_data[event.player_index][gui_data_index]
    if (not storage_ref) then return end

    local icbm_data = storage_ref[tonumber(item_number)]
    if (not icbm_data or not icbm_data.valid) then return end

    Rocket_Silo_Utils.scrub_launch({
        tick = game.tick,
        tick_event = event.tick,
        player_index = event.player_index,
        remove = true,
        enqueued_data = icbm_data.enqueued_data,
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_scrub_button_clicked",
    func_name = "rocket_dashboard_gui_controller.on_scrub_button_clicked",
    func = rocket_dashboard_gui_controller.on_scrub_button_clicked,
})

function rocket_dashboard_gui_controller.on_label_clicked(event)
    Log.error("rocket_dashboard_gui_controller.on_label_clicked")
    Log.warn(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name:find("inner_table_%d+") ~= 1) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local _, _, item_number, label = event.element.name:find("inner_table_(%d+)_(%g+)")
    if (not label or not clickable_labels[label]) then return end

    Rocket_Dashboard_Gui_Service.on_label_clicked({
        gui_data_index = gui_data_index,
        item_number = tonumber(item_number),
        label = label,
        player_index = event.player_index
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_label_clicked",
    func_name = "rocket_dashboard_gui_controller.on_label_clicked",
    func = rocket_dashboard_gui_controller.on_label_clicked,
})

-- function rocket_dashboard_gui_controller.on_gui_closed(event)
--     Log.debug("rocket_dashboard_gui_controller.on_gui_closed")
--     Log.info(event)

--     if (not event or not type(event) == "table") then return end
--     if (not event.gui_type or event.gui_type ~= defines.gui_type.entity) then return end
--     if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

-- end
-- Event_Handler:register_event({
--     event_name = "on_gui_closed",
--     source_name = "rocket_dashboard_gui_controller.on_gui_closed",
--     func_name = "rocket_dashboard_gui_controller.on_gui_closed",
--     func = rocket_dashboard_gui_controller.on_gui_closed,
-- })

-- function rocket_dashboard_gui_controller.on_gui_checked_state_changed(event)
--     Log.debug("rocket_dashboard_gui_controller.on_gui_checked_state_changed")
--     Log.info(event)

--     if (not event or not type(event) == "table") then return end
--     if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

-- end
-- Event_Handler:register_event({
--     event_name = "on_gui_checked_state_changed",
--     source_name = "rocket_dashboard_gui_controller.on_gui_checked_state_changed",
--     func_name = "rocket_dashboard_gui_controller.on_gui_checked_state_changed",
--     func = rocket_dashboard_gui_controller.on_gui_checked_state_changed,
-- })

function rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force(event)
    Log.error("rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force")
    Log.warn(event)

    if (not event) then return end
    if (not event.icbm_data or type(event.icbm_data) ~= "table") then return end

    Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
        icbm_data = event.icbm_data,
        gui_data_index = gui_data_index,
        frame_main_name = frame_main_name,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_rocket_launch_initiated_successfully.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_rocket_launch_initiated_successfully",
    func_name = "rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force",
    func = rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force,
})

function rocket_dashboard_gui_controller.scrub_rocket_data_for_force(event)
    Log.error("rocket_dashboard_gui_controller.scrub_rocket_data_for_force")
    Log.warn(event)

    if (not event) then return end
    if (not event.icbm_data or type(event.icbm_data) ~= "table") then return end

    Rocket_Dashboard_Gui_Service.remove_rocket_data_for_force({
        icbm_data = event.icbm_data,
        gui_data_index = gui_data_index,
        frame_main_name = frame_main_name,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_rocket_launch_scrubbed.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_rocket_launch_scrubbed",
    func_name = "rocket_dashboard_gui_controller.scrub_rocket_data_for_force",
    func = rocket_dashboard_gui_controller.scrub_rocket_data_for_force,
})

function rocket_dashboard_gui_controller.cn_on_payload_delivered(event)
    Log.error("rocket_dashboard_gui_controller.cn_on_payload_delivered")
    Log.warn(event)

    if (not event) then return end
    if (not event.icbm_data or type(event.icbm_data) ~= "table") then return end

    Rocket_Dashboard_Gui_Service.remove_rocket_data_for_force({
        icbm_data = event.icbm_data,
        gui_data_index = gui_data_index,
        frame_main_name = frame_main_name,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_payload_delivered.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_payload_delivered",
    func_name = "rocket_dashboard_gui_controller.cn_on_payload_delivered",
    func = rocket_dashboard_gui_controller.cn_on_payload_delivered,
})

function rocket_dashboard_gui_controller.on_tick(event)
    -- Log.debug("rocket_dashboard_gui_controller.on_tick")
    -- log(serpent.block("rocket_dashboard_gui_controller.on_tick"))

    if (not event) then return end
    if (not event.tick) then return end
    --[[ TODO: Make configurable ]]
    -- if (event.tick % 10 ~= 0) then return end

    if (game and game.forces) then
        for k, force in pairs(game.forces) do
            if (forces_blacklist[k] or not force.valid or forces_blacklist[force.name]) then
                goto continue
            end

            Rocket_Dashboard_Gui_Service.update_time_remaining({
                gui_data_index = gui_data_index,
                frame_main_name = frame_main_name,
                force = force,
            })
            ::continue::
        end
    end
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "rocket_dashboard_gui_controller.on_tick",
    func_name = "rocket_dashboard_gui_controller.on_tick",
    func = rocket_dashboard_gui_controller.on_tick,
})

function rocket_dashboard_gui_controller.instantiate_if_not_exists(event)
    Log.debug("rocket_dashboard_gui_controller.instantiate_if_not_exists")
    Log.info(event)

    if (game and game.forces) then
        for k, force in pairs(game.forces) do
            if (force.valid and force.players) then
                for k_2, player in pairs(force.players) do
                    if (player.valid) then
                        Rocket_Dashboard_Gui_Service.instantiate_guis({
                            player_index = player.index,
                            gui_data_index = gui_data_index,
                            button_open_name = button_open_name,
                            frame_main_name = frame_main_name,
                        })
                    end
                end
            end
        end
    end

    Event_Handler:unregister_event({
        event_name = "on_nth_tick",
        nth_tick = 1,
        source_name = "rocket_dashboard_gui_controller.on_nth_tick.instantiate_if_not_exists",
    })
end
Event_Handler:register_event({
    event_name = "on_nth_tick",
    nth_tick = 1,
    source_name = "rocket_dashboard_gui_controller.on_nth_tick.instantiate_if_not_exists",
    func_name = "rocket_dashboard_gui_controller.instantiate_if_not_exists",
    func = rocket_dashboard_gui_controller.instantiate_if_not_exists,
})

rocket_dashboard_gui_controller.configurable_nukes = true

local _rocket_dashboard_gui_controller = rocket_dashboard_gui_controller

return rocket_dashboard_gui_controller