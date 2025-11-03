local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Custom_Events = require("prototypes.custom-events.custom-events")
local Custom_Input = require("prototypes.custom-input.custom-input")

local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local Rocket_Dashboard_Constants = require("scripts.constants.gui.rocket-dashboard-constants")
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local rocket_dashboard_gui_controller = {}

rocket_dashboard_gui_controller.name = "rocket_dashboard_gui_controller"

rocket_dashboard_gui_controller.nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE.name })

function rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard(event)
    Log.debug("rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (event.element and event.element.valid) then
        if ((type(event.element.name) == "string" and (event.element.name:find(Rocket_Dashboard_Constants.gui_data_index, 1, true)) == 1)) then
            return
        end
    end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    Rocket_Dashboard_Gui_Service.close_rocket_dashboard({ player_index = event.player_index, })
end
Event_Handler:register_events({
    {
        event_name = "on_gui_click",
        source_name = "rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard",
        func_name = "rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard",
        func = rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard,
    },
    {
        event_name = "on_gui_opened",
        source_name = "rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard",
        func_name = "rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard",
        func = rocket_dashboard_gui_controller.on_gui_click_close_rocket_dashboard,
    },
})


function rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard(event)
    Log.debug("rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or not Rocket_Dashboard_Constants.buttons_whitelist[event.element.name]) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local do_center = false
    if (   (event.control and event.shift)
        or (event.button == defines.mouse_button_type.middle)
    ) then
        do_center = true
    end

    Rocket_Dashboard_Gui_Service.toggle_rocket_dashboard({
        player_index = event.player_index,
        button_name = event.element.name,
        center = do_center,
        override_pinned = true,
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard",
    func_name = "rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard",
    func = rocket_dashboard_gui_controller.on_gui_click_toggle_rocket_dashboard,
})

function rocket_dashboard_gui_controller.custom_input_toggle_dashboard(event)
    Log.debug("rocket_dashboard_gui_controller.custom_input_toggle_dashboard")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.input_name or event.input_name ~= Custom_Input.TOGGLE_DASHBOARD.name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    Rocket_Dashboard_Gui_Service.toggle_rocket_dashboard({
        player_index = event.player_index,
        override_pinned = true,
    })
end
Event_Handler:register_event({
    event_name = Custom_Input.TOGGLE_DASHBOARD.name,
    source_name = "rocket_dashboard_gui_controller.custom_input_toggle_dashboard",
    func_name = "rocket_dashboard_gui_controller.custom_input_toggle_dashboard",
    func = rocket_dashboard_gui_controller.custom_input_toggle_dashboard,
})

function rocket_dashboard_gui_controller.on_gui_click_pin_rocket_dashboard(event)
    Log.debug("rocket_dashboard_gui_controller.on_gui_click_pin_rocket_dashboard")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name ~= Rocket_Dashboard_Constants.button_pin_name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    Rocket_Dashboard_Gui_Service.toggle_rocket_dashboard({
        player_index = event.player_index,
        button = event.element,
        pinned = true,
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_gui_click_pin_rocket_dashboard",
    func_name = "rocket_dashboard_gui_controller.on_gui_click_pin_rocket_dashboard",
    func = rocket_dashboard_gui_controller.on_gui_click_pin_rocket_dashboard,
})

function rocket_dashboard_gui_controller.on_scrub_button_clicked(event)
    Log.debug("rocket_dashboard_gui_controller.on_scrub_button_clicked")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name:find(Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_%d+") ~= 1) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local _, _, item_number, button_name = event.element.name:find(Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_(%d+)_(%g+)")
    item_number = item_number ~= nil and tonumber(item_number) or nil
    Log.warn(item_number)
    Log.warn(button_name)
    if (not button_name or button_name ~= "scrub_button") then return end

    local storage_ref = storage.gui_data and storage.gui_data[event.player_index] and storage.gui_data[event.player_index][Rocket_Dashboard_Constants.gui_data_index]
    if (not storage_ref) then return end

    local icbm_data = storage_ref.item_numbers and storage_ref.item_numbers[item_number] and storage_ref.item_numbers[item_number].icbm_data
    if (not icbm_data or not icbm_data.valid) then
        icbm_data = ICBM_Repository.get_icbm_data(storage_ref.item_numbers[item_number] and storage_ref.item_numbers[item_number].surface_name, item_number, { validate_fields = true })
        if (not icbm_data or not icbm_data.valid) then return end
    end

    local force = icbm_data.force
    if (not force or not force.valid) then force = game.forces[icbm_data.force_index] end
    if (not force or not force.valid) then force = game.forces["player"] end
    if (not force or not force.valid) then force = nil end

    Rocket_Dashboard_Gui_Service.remove_rocket_data_for_force({
        item_number = icbm_data.item_number,
        force = force,
        print_message = true,
        scrub = true,
    })
end
Event_Handler:register_event({
    event_name = "on_gui_click",
    source_name = "rocket_dashboard_gui_controller.on_scrub_button_clicked",
    func_name = "rocket_dashboard_gui_controller.on_scrub_button_clicked",
    func = rocket_dashboard_gui_controller.on_scrub_button_clicked,
})

function rocket_dashboard_gui_controller.on_label_clicked(event)
    Log.debug("rocket_dashboard_gui_controller.on_label_clicked")
    Log.info(event)

    if (not event or type(event) ~= "table") then return end
    if (not event.element or not event.element.valid) then return end
    if (not event.element.name or event.element.name:find(Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_%d+") ~= 1) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local _, _, item_number, label = event.element.name:find(Rocket_Dashboard_Constants.gui_data_index .. "_inner_table_(%d+)_(%g+)")
    item_number = item_number ~= nil and tonumber(item_number) or nil
    Log.warn(item_number)
    Log.warn(label)
    if (not label or not Rocket_Dashboard_Constants.clickable_labels[label]) then return end

    Rocket_Dashboard_Gui_Service.on_label_clicked({
        item_number = item_number,
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
    Log.debug("rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force")
    Log.info(event)

    if (not event) then return end
    if (not event.icbm_data or type(event.icbm_data) ~= "table") then return end

    local icbm_data = event.icbm_data
    if (not icbm_data or not icbm_data.valid) then
        icbm_data = ICBM_Repository.get_icbm_data(icbm_data.surface_name, icbm_data.item_number, { validate_fields = true })
        if (not icbm_data or not icbm_data.valid) then return end
    end

    Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
        icbm_data = event.icbm_data,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_rocket_launch_initiated_successfully.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_rocket_launch_initiated_successfully",
    func_name = "rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force",
    func = rocket_dashboard_gui_controller.add_or_update_rocket_data_for_force,
})

function rocket_dashboard_gui_controller.scrub_rocket_data_for_force(event)
    Log.debug("rocket_dashboard_gui_controller.scrub_rocket_data_for_force")
    Log.info(event)

    if (not event) then return end
    if (event.item_number == nil or type(event.item_number) ~= "number" or event.item_number < 1) then return end

    Rocket_Dashboard_Gui_Service.remove_rocket_data_for_force({
        item_number = event.item_number,
        force = event.force,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_rocket_launch_scrubbed.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_rocket_launch_scrubbed",
    func_name = "rocket_dashboard_gui_controller.scrub_rocket_data_for_force",
    func = rocket_dashboard_gui_controller.scrub_rocket_data_for_force,
})

function rocket_dashboard_gui_controller.cn_on_payload_delivered(event)
    Log.debug("rocket_dashboard_gui_controller.cn_on_payload_delivered")
    Log.info(event)

    if (not event) then return end
    if (event.item_number == nil or type(event.item_number) ~= "number" or event.item_number < 1) then return end

    Rocket_Dashboard_Gui_Service.remove_rocket_data_for_force({
        item_number = event.item_number,
        force = event.force,
        print_message = false,
    })
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_payload_delivered.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_payload_delivered",
    func_name = "rocket_dashboard_gui_controller.cn_on_payload_delivered",
    func = rocket_dashboard_gui_controller.cn_on_payload_delivered,
})

function rocket_dashboard_gui_controller.on_nth_tick(event)
    -- Log.debug("rocket_dashboard_gui_controller.on_nth_tick")
    -- Log.info(event)

    if (not event) then return end
    if (not event.tick) then return end
    if (not event.nth_tick) then return end
    if (not storage.nth_tick) then storage.nth_tick = {} end
    rocket_dashboard_gui_controller.nth_tick = event.nth_tick

    if (game and game.forces) then
        for k, force in pairs(game.forces) do
            if (Rocket_Dashboard_Constants.forces_blacklist[k] or not force.valid or Rocket_Dashboard_Constants.forces_blacklist[force.name]) then
                goto continue
            end

            Rocket_Dashboard_Gui_Service.update_time_remaining({ force = force, })
            ::continue::
        end
    end
end
--[[ Registerd in events.lua ]]

function rocket_dashboard_gui_controller.on_runtime_mod_setting_changed(event)
    Log.debug("rocket_dashboard_gui_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE.name) then
        local new_nth_tick = Settings_Service.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.DASHBOARD_REFRESH_RATE.name, reindex = true })
        if (new_nth_tick ~= nil and type(new_nth_tick) == "number" and new_nth_tick >= 1 and new_nth_tick <= 60) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = rocket_dashboard_gui_controller.nth_tick
            Event_Handler:unregister_event({
                event_name = "on_nth_tick",
                nth_tick = prev_nth_tick,
                source_name = "rocket_dashboard_gui_controller.on_nth_tick",
            })

            Event_Handler:register_event({
                event_name = "on_nth_tick",
                nth_tick = new_nth_tick,
                source_name = "rocket_dashboard_gui_controller.on_nth_tick",
                func_name = "rocket_dashboard_gui_controller.on_nth_tick",
                func = rocket_dashboard_gui_controller.on_nth_tick,
            })
            rocket_dashboard_gui_controller.nth_tick = new_nth_tick
        end
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "rocket_dashboard_gui_controller.on_runtime_mod_setting_changed",
    func_name = "rocket_dashboard_gui_controller.on_runtime_mod_setting_changed",
    func = rocket_dashboard_gui_controller.on_runtime_mod_setting_changed,
})

function rocket_dashboard_gui_controller.instantiate_if_not_exists(event)
    Log.debug("rocket_dashboard_gui_controller.instantiate_if_not_exists")
    Log.info(event)

    if (event) then
        if (event.name == defines.events.on_tick) then
            if (game and game.forces) then
                for k, force in pairs(game.forces) do
                    if (force.valid and force.players) then
                        for k_2, player in pairs(force.players) do
                            if (player.valid) then
                                Rocket_Dashboard_Gui_Service.instantiate_guis({ player_index = player.index, })
                            end
                        end
                    end
                end
            end

            Event_Handler:unregister_event({
                event_name = "on_tick",
                source_name = "rocket_dashboard_gui_controller.on_tick.instantiate_if_not_exists",
            })
        elseif (event.name == defines.events.on_player_joined_game) then

            if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

            local player = game.get_player(event.player_index)
            if (not player or not player.valid) then return end

            Rocket_Dashboard_Gui_Service.instantiate_guis({ player_index = player.index, })
        end
    end
end
Event_Handler:register_event({
    event_name = "on_player_joined_game",
    source_name = "rocket_dashboard_gui_controller.on_player_joined_game.instantiate_if_not_exists",
    func_name = "rocket_dashboard_gui_controller.instantiate_if_not_exists",
    func = rocket_dashboard_gui_controller.instantiate_if_not_exists,
})

function rocket_dashboard_gui_controller.cn_on_init_complete(event)
    Log.debug("rocket_dashboard_gui_controller.cn_on_init_complete")
    Log.info(event)

    if (game and game.forces) then
        for k, force in pairs(game.forces) do
            if (force.valid and force.players) then
                for k_2, player in pairs(force.players) do
                    if (player.valid) then
                        Rocket_Dashboard_Gui_Service.update_gui_data({ player_index = player.index, })
                    end
                end
            end
        end
    end
end
Event_Handler:register_event({
    event_name = Custom_Events.cn_on_init_complete.name,
    source_name = "rocket_dashboard_gui_controller.cn_on_init_complete",
    func_name = "rocket_dashboard_gui_controller.cn_on_init_complete",
    func = rocket_dashboard_gui_controller.cn_on_init_complete,
})

return rocket_dashboard_gui_controller