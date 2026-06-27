local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local payloader_rocket = Util.table.deepcopy(data.raw["projectile"]["rocket"])
payloader_rocket.name = "payloader-rocket"

table.insert(payloader_rocket.action.action_delivery.target_effects, { type = "script", effect_id = "payload-delivered",  })

data:extend({ payloader_rocket, })