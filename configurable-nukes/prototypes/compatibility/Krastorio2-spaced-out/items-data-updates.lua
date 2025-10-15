local Data_Utils = require("data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true

if (k2so_active) then
    if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })) then
        local atomic_warhead_ammo_item = data.raw["ammo"]["atomic-warhead"]
        atomic_warhead_ammo_item.ammo_category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }) and "nuclear" or "kr-heavy-rocket"
    end

    local atomic_bomb_ammo_item = data.raw["ammo"]["atomic-bomb"]

    atomic_bomb_ammo_item.ammo_type.range_modifier = 1.5 * Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_RANGE_MODIFIER.name })
    atomic_bomb_ammo_item.ammo_type.cooldown_modifier = 10 * Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER.name })

    if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name })) then
        atomic_bomb_ammo_item.ammo_category = "nuclear"

        local heavy_rocket_launcher = data.raw["gun"]["kr-heavy-rocket-launcher"]
        heavy_rocket_launcher.attack_parameters.ammo_categories = { heavy_rocket_launcher.attack_parameters.ammo_category, "nuclear" }
        heavy_rocket_launcher.attack_parameters.ammo_category = nil

        data:extend({heavy_rocket_launcher})
    end
end