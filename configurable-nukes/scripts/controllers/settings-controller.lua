-- If already defined, return
if _settings_controller and _settings_controller.configurable_nukes then
    return _settings_controller
end

local Log = require("libs.log.log")
local Settings_Service = require("scripts.services.settings-service")

local settings_controller = {}

function settings_controller.on_runtime_mod_setting_changed(event)
    Log.debug("settings_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    local sa_active = script and script.active_mods and script.active_mods["space-age"]
    local se_active = script and script.active_mods and script.active_mods["space-exploration"]

    storage.sa_active = sa_active
    storage.se_active = se_active

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (not storage.settings or type(storage.settings) ~= "table") then storage.settings = {} end
    if (event.setting_type == "runtime-global") then
        Settings_Service.get_runtime_global_setting({  reindex = true, setting = event.setting })
    elseif (event.setting_type == "runtime-user") then
    elseif (event.setting_type == "startup") then
        Settings_Service.get_startup_setting({  reindex = true, setting = event.setting })
    end
end

settings_controller.configurable_nukes = true

local _settings_controller = settings_controller

return settings_controller