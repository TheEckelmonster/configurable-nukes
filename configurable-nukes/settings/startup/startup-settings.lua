local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

data:extend({
    Startup_Settings_Constants.settings.NUCLEAR_AMMO_CATEGORY,
    Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER,
})

data:extend({
    --[[ atomic-bomb ]]
    Startup_Settings_Constants.settings.AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.FIRE_WAVE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RANGE_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_STACK_SIZE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULT_COUNT,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ atomic-warhead ]]
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_FIRE_WAVE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_STACK_SIZE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESULT_COUNT,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RECIPE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ payload-vehicle ]]
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_INVENTORY_SIZE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RESULT_COUNT,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RECIPE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ payloader ]]
    Startup_Settings_Constants.settings.PAYLOADER_STACK_SIZE,
    Startup_Settings_Constants.settings.PAYLOADER_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOADER_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.PAYLOADER_RESULT_COUNT,
    Startup_Settings_Constants.settings.PAYLOADER_RECIPE,
    Startup_Settings_Constants.settings.PAYLOADER_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ rod-from-god ]]
    Startup_Settings_Constants.settings.ROD_FROM_GOD_AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_FIRE_WAVE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_STACK_SIZE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESULT_COUNT,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RECIPE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_ADDITIONAL_CRAFTING_MACHINES,

    --[[ rod-from-god research ]]
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESEARCH_COUNT,
})

data:extend({
    --[[ jericho ]]
    Startup_Settings_Constants.settings.JERICHO_AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.JERICHO_DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.JERICHO_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.JERICHO_SUB_ROCKET_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.JERICHO_STACK_SIZE,
    Startup_Settings_Constants.settings.JERICHO_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.JERICHO_CRAFTING_TIME,
    Startup_Settings_Constants.settings.JERICHO_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.JERICHO_RESULT_COUNT,
    Startup_Settings_Constants.settings.JERICHO_RECIPE,
    Startup_Settings_Constants.settings.JERICHO_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.JERICHO_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.JERICHO_ADDITIONAL_CRAFTING_MACHINES,

    --[[ jericho research ]]
    Startup_Settings_Constants.settings.JERICHO_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.JERICHO_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.JERICHO_RESEARCH_TIME,
    Startup_Settings_Constants.settings.JERICHO_RESEARCH_COUNT,
})

if (sa_active) then
    data:extend({
        --[[ tesla-rocket ]]
        Startup_Settings_Constants.settings.TESLA_ROCKET_AREA_MULTIPLIER,
        Startup_Settings_Constants.settings.TESLA_ROCKET_DAMAGE_MULTIPLIER,
        Startup_Settings_Constants.settings.TESLA_ROCKET_REPEAT_MULTIPLIER,
        Startup_Settings_Constants.settings.TESLA_ROCKET_STACK_SIZE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_WEIGHT_MODIFIER,
        Startup_Settings_Constants.settings.TESLA_ROCKET_CRAFTING_TIME,
        Startup_Settings_Constants.settings.TESLA_ROCKET_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESULT_COUNT,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RECIPE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_ADDITIONAL_CRAFTING_MACHINES,

        --[[ jericho research ]]
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_PREREQUISITES,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_INGREDIENTS,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_TIME,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_COUNT,
    })
end

data:extend({
    --[[ ICBMs research ]]
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_COUNT,
})

data:extend({
    --[[ IPBMs research ]]
    Startup_Settings_Constants.settings.IPBMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.IPBMS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.IPBMS_RESEARCH_TIME,
    Startup_Settings_Constants.settings.IPBMS_RESEARCH_COUNT,
})

data:extend({
    --[[ atomic-warhead research ]]
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESEARCH_COUNT,
})

data:extend({
    --[[ rocket-control-unit ]]
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_STACK_SIZE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESULT_COUNT,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RECIPE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADDITIONAL_CRAFTING_MACHINES,
    --[[ rocket-control-unit research ]]
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT,
})

if (k2so_active) then
    --[[ kr-nuclear-turret-rocket ]]
    data:extend({
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_AREA_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_DAMAGE_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_REPEAT_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_FIRE_WAVE,
    })

    --[[ kr-nuclear-artillery-shell ]]
    data:extend({
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AREA_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_DAMAGE_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_REPEAT_MULTIPLIER,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_FIRE_WAVE,
        Startup_Settings_Constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AMMO_CATEGORY,
    })
end

if (saa_s_active) then
    --[[ atomic-artillery-shell ]]
    data:extend({
        Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AREA_MULTIPLIER,
        Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_DAMAGE_MULTIPLIER,
        Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_REPEAT_MULTIPLIER,
        Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_FIRE_WAVE,
        Startup_Settings_Constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AMMO_CATEGORY,
    })
end

if (sa_active or se_active) then
    data:extend({
        Startup_Settings_Constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_TIME,
        Startup_Settings_Constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RECIPE,
        Startup_Settings_Constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_RESULT_COUNT,
        Startup_Settings_Constants.settings.ADVANCED_ROCKET_CONTROL_UNIT_CRAFTING_MACHINE,
    })

    data:extend({
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_STACK_SIZE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RESULT_COUNT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RECIPE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_ADDITIONAL_CRAFTING_MACHINES,
    })

    data:extend({
        --[[ ballistic-rocket-part ]]
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_STACK_SIZE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RESULT_COUNT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        --[[ ballistic-rocket-part-intermediate ]]
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULT_COUNT,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        --[[ ballistic-rocket-part-advanced ]]
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RESULT_COUNT,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        -- --[[ ballistic-rocket-part-beyond ]]
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RESULT_COUNT,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,
    })

    if (sa_active) then
        data:extend({
            --[[ ballistic-rocket-part-beyond 2 ]]
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_INPUT_MULTIPLIER,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RESULT_COUNT,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE_ALLOW_NONE,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,
        })
    end
end

data:extend({
    --[[ nuclear-weapons research ]]
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER_ARTILLERY,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_FORMULA,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_TIME,
})

data:extend({
    --[[ guidance-systems research ]]
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TOP_SPEED_MODIFIER,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_FORMULA,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TIME,
})

--[[ misc / debug ]]
data:extend({
    Startup_Settings_Constants.settings.DEBUG_PAYLOAD_STARTUP_PROCESSING,
})