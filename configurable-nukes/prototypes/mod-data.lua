local Space_Data = require("__TheEckelmonster-core-library__.libs.mod-data.space-data")

local Constants = require("scripts.constants.constants")
Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local space_data = Space_Data.create({
    name = Constants.mod_name .. "-mod-data",
    default_distance_modifier = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name }),
})

data:extend({
    space_data,
})