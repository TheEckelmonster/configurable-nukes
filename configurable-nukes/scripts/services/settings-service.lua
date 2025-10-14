-- If already defined, return
if _settings_service and _settings_service.configurable_nukes then
    return _settings_service
end

local Log = require("libs.log.log")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_runtime_global_setting = function (data)
    Log.debug("get_runtime_global_setting")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = Runtime_Global_Settings_Constants.settings_dictionary[data.setting] and Runtime_Global_Settings_Constants.settings_dictionary[data.setting].default_value

    if (settings and settings.global and settings.global[data.setting]) then
        setting = settings.global[data.setting].value
    end

    return setting
end

-- local get_runtime_user_setting = function (data)
--     Log.debug("get_runtime_user_setting")
--     Log.info(data)

--     if (not data or type(data) ~= "table") then return end
--     if (not data.setting or type(data.setting) ~= "string") then return end
--     if (data.player_id ~= nil) then return end

--     local setting = Runtime_User_Settings_Constants.settings_dictionary[data.setting] and Runtime_User_Settings_Constants.settings_dictionary[data.setting].default_value

--     -- if (settings and settings.global and settings.global[data.setting]) then
--     if (settings.get_player_settings(data.player_id)[data.setting]) then
--         setting = settings.global[data.setting].value
--     end

--     return setting
-- end

local get_startup_setting = function (data)
    Log.debug("get_startup_setting")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = Startup_Settings_Constants.settings_dictionary[data.setting] and Startup_Settings_Constants.settings_dictionary[data.setting].default_value

    if (settings and settings.startup and settings.startup[data.setting]) then
        setting = settings.startup[data.setting].value
    end

    return setting
end

local settings_service = {}

function settings_service.get_runtime_global_setting(data)
    Log.debug("settings_service.get_runtime_global_setting")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    if (not storage.settings or type(storage.settings) ~= "table") then storage.settings = {} end
    if (not storage.settings["runtime-global"] or type(storage.settings["runtime-global"]) ~= "table") then storage.settings["runtime-global"] = {} end

    local setting = storage.settings["runtime-global"][data.setting]

    if (setting == nil or data.reindex) then
        setting = get_runtime_global_setting(data)
    end

    storage.settings["runtime-global"][data.setting] = setting

    return setting
end

function settings_service.get_startup_setting(data)
    Log.debug("settings_service.get_startup_setting")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    if (not storage.settings or type(storage.settings) ~= "table") then storage.settings = {} end
    if (not storage.settings["startup"] or type(storage.settings["startup"]) ~= "table") then storage.settings["startup"] = {} end

    local setting = storage.settings["startup"][data.setting]

    if (setting == nil or data.reindex) then
        setting = get_startup_setting(data)
    end

    storage.settings["startup"][data.setting] = setting

    return setting
end

settings_service.configurable_nukes = true

local _settings_service = settings_service

return settings_service