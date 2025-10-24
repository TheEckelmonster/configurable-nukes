local Data_Utils = require("data-utils")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true

if (saa_s_active) then
    local saa_s_atomic_artillery_shell_ammo_item = data.raw["ammo"]["atomic-artillery-shell"]
    if (Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY.name })) then
        saa_s_atomic_artillery_shell_ammo_item.ammo_category = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AMMO_CATEGORY.name })

        for _, artillery_turret_object in pairs(data.raw["artillery-turret"]) do
            local artillery_turret_object_gun = data.raw["gun"][artillery_turret_object.gun]

            if (not artillery_turret_object_gun.attack_parameters.ammo_categories) then artillery_turret_object_gun.attack_parameters.ammo_categories = {} end
            if (artillery_turret_object_gun.attack_parameters.ammo_category) then
                table.insert(artillery_turret_object_gun.attack_parameters.ammo_categories, artillery_turret_object_gun.attack_parameters.ammo_category)
            end
            table.insert(artillery_turret_object_gun.attack_parameters.ammo_categories, "nuclear-artillery")
            artillery_turret_object_gun.attack_parameters.ammo_category = nil
        end
    end
    local action =
    {
        {
            action_delivery = {
                target_effects = {
                    {
                        type = "script",
                        effect_id = "saa-s-atomic-artillery-projectile-fired"
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
                projectile = "saa-s-atomic-artillery-projectile-placeholder",
                starting_speed = 1,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "artillery-cannon-muzzle-flash"
                }
            },
        }
    }

    saa_s_atomic_artillery_shell_ammo_item.ammo_type.action = action
end