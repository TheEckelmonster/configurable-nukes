-- If already defined, return
if _log_settings and _log_settings.sdpr then
  return _log_settings
end

local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")

local log_settings = {}

data:extend({
  {
    type = "string-setting",
    name = Log_Constants.settings.DEBUG_LEVEL.name,
    -- name = "more-enemies-debug-level",
    setting_type = "runtime-global",
    order = "aba",
    default_value = Log_Constants.settings.DEBUG_LEVEL.value,
    allowed_values = Log_Constants_Functions.levels.get_names()
  },
  Log_Constants.settings.DO_TRACEBACK,
  Log_Constants.settings.DO_NOT_PRINT,
})

log_settings.sdpr = true

local _log_settings = log_settings

return log_settings