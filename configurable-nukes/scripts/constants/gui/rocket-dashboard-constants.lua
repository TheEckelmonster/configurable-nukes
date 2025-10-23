local rocket_dashboard_constants = {}

rocket_dashboard_constants.gui_data_index = "cn_rocket_dashboard"

rocket_dashboard_constants.frame_main_name = rocket_dashboard_constants.gui_data_index .. "_frame_main"
rocket_dashboard_constants.button_open_name = rocket_dashboard_constants.gui_data_index .. "_button_open"
rocket_dashboard_constants.button_close_name = rocket_dashboard_constants.frame_main_name .. "_close_button"
rocket_dashboard_constants.button_pin_name = rocket_dashboard_constants.frame_main_name .. "_pin_button"

rocket_dashboard_constants.buttons_whitelist =
{
    [rocket_dashboard_constants.button_open_name] = true,
    [rocket_dashboard_constants.button_close_name] = true,
}

local sa_active = script and script.active_mods and script.active_mods["space-age"]
local se_active = script and script.active_mods and script.active_mods["space-exploration"]

rocket_dashboard_constants.forces_blacklist =
{
    ["enemy"] = true,
    ["neutral"] = true,
}

rocket_dashboard_constants.clickable_labels =
{
    ["source_label"] = true,
    ["destination_label"] = true,
}

if (se_active) then
    rocket_dashboard_constants.forces_blacklist["conquest"] = true
    rocket_dashboard_constants.forces_blacklist["ignore"] = true
    rocket_dashboard_constants.forces_blacklist["capture"] = true
    rocket_dashboard_constants.forces_blacklist["friendly"] = true
end

return rocket_dashboard_constants