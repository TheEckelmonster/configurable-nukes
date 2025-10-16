-- If already defined, return
if _log_settings and _log_settings.configurable_nukes then
  return _log_settings
end

local Log_Constants = require("libs.log.log-constants")
local Log_Constants_Functions = require("libs.log.log-constants-functions")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local order_struct = {
    order_array = {
        -- "a", "b", "c", "d", "e",  "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        [0] = "a",
        [1] = "b",
        [2] = "c",
        [3] = "d",
        [4] = "e",
        [5] = "f",
        [6] = "g",
        [7] = "h",
        [8] = "i",
        [9] = "j",
        [10] = "k",
        [11] = "l",
        [12] = "m",
        [13] = "n",
        [14] = "o",
        [15] = "p",
        [16] = "q",
        [17] = "r",
        [18] = "s",
        [19] = "t",
        [20] = "u",
        [21] = "v",
        [22] = "w",
        [23] = "x",
        [24] = "y",
        [25] = "z",
    },
    order_dictionary = {},
}

for k, v in pairs(order_struct.order_array) do
    order_struct.order_dictionary[v] = k
end

local log_settings = {}

log_settings.settings =
{
    {
        type = "string-setting",
        name = Log_Constants.settings.DEBUG_LEVEL.name,
        setting_type = "runtime-global",
        order = "aba",
        default_value = Log_Constants.settings.DEBUG_LEVEL.value,
        allowed_values = Log_Constants_Functions.levels.get_names()
    },
    Log_Constants.settings.DO_TRACEBACK,
    Log_Constants.settings.DO_NOT_PRINT,
}

local runtime_settings_list_ordered = {}

for k, v in pairs(log_settings.settings) do table.insert(runtime_settings_list_ordered, v) end
for k, v in pairs(Runtime_Global_Settings_Constants.settings_array) do table.insert(runtime_settings_list_ordered, v) end

for k, v in ipairs(runtime_settings_list_ordered) do
    local order_1 = ((k - 1) % 26)
    local order_2 = math.floor((k - 1) / 26) % 26
    local order_3 = math.floor((k - 1) / 676) % 26

    local order = order_struct.order_array[order_3] .. order_struct.order_array[order_2] .. order_struct.order_array[order_1]
    v.order = order
end

data:extend(log_settings.settings)

log_settings.configurable_nukes = true

local _log_settings = log_settings

return log_settings