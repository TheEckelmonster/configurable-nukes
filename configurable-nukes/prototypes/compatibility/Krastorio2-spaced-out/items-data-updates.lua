local Data_Utils = require("data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local sa_active = mods and mods["space-age"] and true

if (k2so_active) then
    if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED.name })) then
        local atomic_warhead_ammo_item = data.raw["ammo"]["atomic-warhead"]
        atomic_warhead_ammo_item.ammo_category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name }) and "nuclear" or "kr-heavy-rocket"
    end

    local atomic_bomb_ammo_item = data.raw["ammo"]["atomic-bomb"]

    atomic_bomb_ammo_item.ammo_type.range_modifier = 1.5 * Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_RANGE_MODIFIER.name })
    atomic_bomb_ammo_item.ammo_type.cooldown_modifier = 10 * Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER.name })

    local action =
    {
        {
            action_delivery = {
                target_effects = {
                    {
                        type = "script",
                        effect_id = "kr-nuclear-turret-rocket-projectile-fired"
                    }
                },
                type = "instant"
            },
            trigger_from_target = true,
            type = "direct"
        },
        {
            type = "direct",
            action_delivery =
            {
                type = "projectile",
                projectile = "kr-nuclear-turret-rocket-projectile-placeholder",
                starting_speed = 0.05,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "explosion-gunshot"
                }
            },
        }
    }

    local kr_nuclear_turret_rocket_ammo_item = data.raw["ammo"]["kr-nuclear-turret-rocket"]
    kr_nuclear_turret_rocket_ammo_item.ammo_type.action = action

    if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name })) then
        atomic_bomb_ammo_item.ammo_category = "nuclear"
        kr_nuclear_turret_rocket_ammo_item.ammo_category = "nuclear"

        local kr_nuclear_artillery_shell_ammo_item = data.raw["ammo"]["kr-nuclear-artillery-shell"]
        kr_nuclear_artillery_shell_ammo_item.ammo_category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AMMO_CATEGORY.name })

        local heavy_rocket_launcher = data.raw["gun"]["kr-heavy-rocket-launcher"]
        heavy_rocket_launcher.attack_parameters.ammo_categories = { heavy_rocket_launcher.attack_parameters.ammo_category, "nuclear" }
        heavy_rocket_launcher.attack_parameters.ammo_category = nil

        for _, artillery_turret_object in pairs(data.raw["artillery-turret"]) do
            local artillery_turret_object_gun = data.raw["gun"][artillery_turret_object.gun]

            if (not artillery_turret_object_gun.attack_parameters.ammo_categories) then artillery_turret_object_gun.attack_parameters.ammo_categories = {} end
            if (artillery_turret_object_gun.attack_parameters.ammo_category) then
                table.insert(artillery_turret_object_gun.attack_parameters.ammo_categories, artillery_turret_object_gun.attack_parameters.ammo_category)
            end
            table.insert(artillery_turret_object_gun.attack_parameters.ammo_categories, "nuclear-artillery")
            artillery_turret_object_gun.attack_parameters.ammo_category = nil
        end

        if (sa_active) then
            local rocket_turret = data.raw["ammo-turret"]["rocket-turret"]

            if (not rocket_turret.attack_parameters.ammo_categories) then rocket_turret.attack_parameters.ammo_categories = {} end
            if (rocket_turret.attack_parameters.ammo_category) then
                table.insert(rocket_turret.attack_parameters.ammo_categories, rocket_turret.attack_parameters.ammo_category)
            end
            table.insert(rocket_turret.attack_parameters.ammo_categories, "nuclear")
            rocket_turret.attack_parameters.ammo_category = nil
        end
    end
    local action =
    {
        {
            action_delivery = {
                target_effects = {
                    {
                        type = "script",
                        effect_id = "kr-atomic-artillery-projectile-fired"
                    }
                },
                type = "instant"
            },
            trigger_from_target = true,
            type = "direct"
        },
        {
            type = "direct",
            action_delivery =
            {
                type = "artillery",
                projectile = "kr-atomic-artillery-projectile-placeholder",
                starting_speed = 1,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "artillery-cannon-muzzle-flash"
                }
            },
        }
    }

    local kr_nuclear_artillery_shell_ammo_item = data.raw["ammo"]["kr-nuclear-artillery-shell"]
    kr_nuclear_artillery_shell_ammo_item.ammo_type.action = action
end