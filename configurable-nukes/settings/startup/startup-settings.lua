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
    --[[ payload related ]]
    Startup_Settings_Constants.settings.PROJECTILE_PLACEHOLDER_COLLISION,
    Startup_Settings_Constants.settings.DO_MAP_REVEAL,
    Startup_Settings_Constants.settings.USE_WHOLE_ROCKET_SPRITE,
})

data:extend({
    --[[ atomic-bomb ]]
    Startup_Settings_Constants.settings.ATOMIC_BOMB_AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_DO_POLLUTION,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_FIRE_WAVE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RANGE_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_COOLDOWN_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_STACK_SIZE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RECIPE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_RESULTS,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ATOMIC_BOMB_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ atomic-warhead ]]
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ENABLED,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_AREA_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DAMAGE_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_REPEAT_MULTIPLIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_DO_POLLUTION,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_FIRE_WAVE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_STACK_SIZE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_TIME,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RECIPE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESULTS,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ payload-vehicle ]]
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_INVENTORY_SIZE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RECIPE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_RESULTS,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ payloader recipes]]
    Startup_Settings_Constants.settings.PAYLOADER_LOAD_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOADER_LOAD_EMISSIONS_MULTIPLIER,
    Startup_Settings_Constants.settings.PAYLOADER_LOAD_RECIPE,

    Startup_Settings_Constants.settings.PAYLOADER_UNLOAD_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOADER_UNLOAD_EMISSIONS_MULTIPLIER,
    Startup_Settings_Constants.settings.PAYLOADER_UNLOAD_RECIPE,
})

data:extend({
    --[[ payloader ]]
    -- Startup_Settings_Constants.settings.PAYLOADER_DO_TINT,
    -- Startup_Settings_Constants.settings.PAYLOADER_BASE_TINT,
    Startup_Settings_Constants.settings.PAYLOADER_STACK_SIZE,
    Startup_Settings_Constants.settings.PAYLOADER_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_TIME,
    Startup_Settings_Constants.settings.PAYLOADER_RECIPE,
    Startup_Settings_Constants.settings.PAYLOADER_RESULTS,
    Startup_Settings_Constants.settings.PAYLOADER_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.PAYLOADER_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
    --[[ payloader research ]]
    Startup_Settings_Constants.settings.PAYLOADER_RESEARCH_COUNT,
    Startup_Settings_Constants.settings.PAYLOADER_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.PAYLOADER_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.PAYLOADER_RESEARCH_TIME,
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
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RECIPE,
    Startup_Settings_Constants.settings.ROD_FROM_GOD_RESULTS,
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
    Startup_Settings_Constants.settings.JERICHO_HANDHELD_FIREABLE,
    Startup_Settings_Constants.settings.JERICHO_RANGE_MODIFIER,
    Startup_Settings_Constants.settings.JERICHO_COOLDOWN_MODIFIER,
    Startup_Settings_Constants.settings.JERICHO_STACK_SIZE,
    Startup_Settings_Constants.settings.JERICHO_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.JERICHO_CRAFTING_TIME,
    Startup_Settings_Constants.settings.JERICHO_RECIPE,
    Startup_Settings_Constants.settings.JERICHO_RESULTS,
    Startup_Settings_Constants.settings.JERICHO_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.JERICHO_ADDITIONAL_CRAFTING_MACHINES,
})

data:extend({
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
        Startup_Settings_Constants.settings.TESLA_ROCKET_RECIPE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESULTS,
        Startup_Settings_Constants.settings.TESLA_ROCKET_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.TESLA_ROCKET_ADDITIONAL_CRAFTING_MACHINES,
    })

    data:extend({
        --[[ jericho research ]]
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_PREREQUISITES,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_INGREDIENTS,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_TIME,
        Startup_Settings_Constants.settings.TESLA_ROCKET_RESEARCH_COUNT,
    })
end

data:extend({
    --[[ target-combinator ]]
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_STACK_SIZE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_WEIGHT_MODIFIER,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_CRAFTING_TIME,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_RECIPE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_RESULTS,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_ADDITIONAL_CRAFTING_MACHINES,

    --[[ recipes ]]
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_CRAFTING_TIME,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RECIPE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RECIPE_ALLOW_NONE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_PROGRAM_RESULTS,

    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_TIME,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RESULT_COUNT,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RECIPE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_RESULTS,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_DIRTY_ADDITIONAL_CRAFTING_MACHINES,

    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_TIME,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RESULT_COUNT,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RECIPE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_RESULTS,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_ACID_ADDITIONAL_CRAFTING_MACHINES,

    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_CRAFTING_TIME,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_INPUT_MULTIPLIER,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_RESULT_COUNT,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_RECIPE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_RESULTS,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.TARGET_COMBINATOR_REFORMAT_SLOW_ADDITIONAL_CRAFTING_MACHINES,
})

if (not se_active) then
    data:extend({
        --[[ rocket-control-unit-intermediate recipe ]]
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INTERMEDIATE_CRAFTING_TIME,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INTERMEDIATE_RECIPE,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INTERMEDIATE_RESULTS,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INTERMEDIATE_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_INTERMEDIATE_ADDITIONAL_CRAFTING_MACHINES,

        --[[ rocket-control-unit-advanced recipe ]]
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_CRAFTING_TIME,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RECIPE,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_RESULTS,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADVANCED_ADDITIONAL_CRAFTING_MACHINES,
    })
end

data:extend({
    --[[ ICBMs research ]]
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_COUNT,
})

if (sa_active or se_active) then
    data:extend({
        --[[ IPBMs research ]]
        Startup_Settings_Constants.settings.IPBMS_RESEARCH_PREREQUISITES,
        Startup_Settings_Constants.settings.IPBMS_RESEARCH_INGREDIENTS,
        Startup_Settings_Constants.settings.IPBMS_RESEARCH_TIME,
        Startup_Settings_Constants.settings.IPBMS_RESEARCH_COUNT,
    })
end

data:extend({
    --[[ MIRVs research ]]
    Startup_Settings_Constants.settings.MIRVS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.MIRVS_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.MIRVS_RESEARCH_TIME,
    Startup_Settings_Constants.settings.MIRVS_RESEARCH_COUNT,
})

data:extend({
    --[[ rocket-recoverability research ]]
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_RESEARCH_COUNT,
})

data:extend({
    --[[ rocket-recoverability research-2 ]]
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_2_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_2_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_2_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_2_RESEARCH_COUNT,
})

data:extend({
    --[[ rocket-recoverability research-2 ]]
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_3_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_3_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_3_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROCKET_RECOVERABILITY_3_RESEARCH_COUNT,
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
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RECIPE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESULTS,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_CRAFTING_MACHINE,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_ADDITIONAL_CRAFTING_MACHINES,
})

if (not se_active) then
    data:extend({
        --[[ rocket-control-unit research ]]
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME,
        Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT,
    })
end

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
        --[[ ballistic-rocket-silo ]]
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_WEIGHT_MODIFIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RECIPE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_RESULTS,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_SILO_ADDITIONAL_CRAFTING_MACHINES,
    })

    data:extend({
        --[[ ballistic-rocket-part ]]
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_DO_TINT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_BASE_TINT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_PRIMARY_TINT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_SECONDARY_TINT,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_TERTIARY_TINT,
    })

    data:extend({
        --[[ ballistic-rocket-part ]]
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_STACK_SIZE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_WEIGHT_MODIFIER,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RESULTS,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        --[[ ballistic-rocket-part-intermediate ]]
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULTS,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        --[[ ballistic-rocket-part-advanced ]]
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RESULTS,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,

        -- --[[ ballistic-rocket-part-beyond ]]
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RESULTS,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_CRAFTING_MACHINE,
        Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_ADDITIONAL_CRAFTING_MACHINES,
    })

    if (sa_active) then
        data:extend({
            --[[ ballistic-rocket-part-beyond 2 ]]
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_CRAFTING_TIME,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE,
            Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RESULTS,
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
    --[[ ballistic-rocketry-and-logistics research ]]
    Startup_Settings_Constants.settings.BRAL_RESEARCH_DAMAGE_MODIFIER,
    Startup_Settings_Constants.settings.BRAL_RESEARCH_TOP_SPEED_MODIFIER,
    Startup_Settings_Constants.settings.BRAL_RESEARCH_FORMULA,
    Startup_Settings_Constants.settings.BRAL_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.BRAL_RESEARCH_INGREDIENTS,
    Startup_Settings_Constants.settings.BRAL_RESEARCH_TIME,
})

--[[ misc / debug ]]
data:extend({
    Startup_Settings_Constants.settings.DEBUG_PAYLOAD_STARTUP_PROCESSING,
})