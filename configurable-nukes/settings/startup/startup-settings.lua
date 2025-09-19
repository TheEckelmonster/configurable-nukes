local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

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
    --[[ rocket-control-unit research ]]
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ICBMS_RESERACH_INGREDIENTS,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ICBMS_RESEARCH_COUNT,
})

data:extend({
    --[[ atomic-warhead research ]]
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.ATOMIC_WARHEAD_RESERACH_INGREDIENTS,
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
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESERACH_INGREDIENTS,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_TIME,
    Startup_Settings_Constants.settings.ROCKET_CONTROL_UNIT_RESEARCH_COUNT,
})

data:extend({
    --[[ nuclear-weapons research ]]
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_DAMAGE_MODIFIER,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_FORMULA,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESERACH_INGREDIENTS,
    Startup_Settings_Constants.settings.NUCLEAR_WEAPONS_RESEARCH_TIME,
})

data:extend({
    --[[ guidance-systems research ]]
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_DAMAGE_MODIFIER,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_FORMULA,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_PREREQUISITES,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESERACH_INGREDIENTS,
    Startup_Settings_Constants.settings.GUIDANCE_SYSTEMS_RESEARCH_TIME,
})