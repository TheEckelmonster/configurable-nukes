require("libs.log.log-settings")

data:extend({
  {
    type = "double-setting",
    name = "configurable-nukes-area-multiplier",
    setting_type = "startup",
    order = "cba",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 0.01
  },
  {
    type = "double-setting",
    name = "configurable-nukes-damage-multiplier",
    setting_type = "startup",
    order = "cbb",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 0.01
  },
  {
    type = "double-setting",
    name = "configurable-nukes-repeat-multiplier",
    setting_type = "startup",
    order = "cbc",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 0.01
  },
  {
    type = "double-setting",
    name = "configurable-nukes-pollution",
    setting_type = "runtime-global",
    order = "cbd",
    default_value = 0.166,
    maximum_value = 11,
    minimum_value = 0
  },
})