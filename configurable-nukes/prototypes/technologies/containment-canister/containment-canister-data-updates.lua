local __Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Setting_Utils = require("settings.settings-utils")

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

local setting_name = "CONTAINMENT_CANISTER"

local containment_canister_unlock =
{
    type = "unlock-recipe",
    recipe = "cn-containment-canister",
}

local technology_effects =
{
    containment_canister_unlock,
}

return function (Startup_Settings_Constants)
    Startup_Settings_Constants = Startup_Settings_Constants or __Startup_Settings_Constants

    local technology = data.raw.technology["cn-containment-canister"] or {
        type = "technology",
        name = "cn-containment-canister",
        icon = "__configurable-nukes__/graphics/technology/containment-canister.png",
        icon_size = 256,
        effects = {},
        prerequisites = Setting_Utils.get_research_prerequisites({
            setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_PREREQUISITES"],
        }),
        unit =
        {
            ingredients = Setting_Utils.get_research_ingredients({
                setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_INGREDIENTS"],
            }),
            count = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_COUNT"].name }),
            time = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_TIME"].name }),
        },
    }

    technology.prerequisites = Setting_Utils.get_research_prerequisites({
        setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_PREREQUISITES"],
    })

    technology.unit = {
        ingredients = Setting_Utils.get_research_ingredients({
            setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_INGREDIENTS"],
        }),
        count = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_COUNT"].name }),
        time = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings[setting_name .. "_RESEARCH_TIME"].name }),
    }

    for _, v in pairs(technology_effects) do table.insert(technology.effects, 1, v) end

    data:extend({ technology, })
end