local mods = mods
local script = script

local Util = require("__core__.lualib.util")

local Settings_Utils = require("__TheEckelmonster-core-library__.libs.utils.settings-utils")

local __Data_Utils = require("data-utils")

local k2so_active = mods and mods["Krastorio2-spaced-out"] and true or script and script.active_mods and script.active_mods["Krastorio2-spaced-out"]
local saa_s_active = mods and mods["SimpleAtomicArtillery-S"] and true or script and script.active_mods and script.active_mods["SimpleAtomicArtillery-S"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

local startup_settings_constants = {}

local prefix = "configurable-nukes-"

startup_settings_constants.settings = {}

startup_settings_constants.settings.NUCLEAR_AMMO_CATEGORY = {
    type = "bool-setting",
    name = prefix .. "nuclear-ammo-category",
    setting_type = "startup",
    order = "",
    default_value = false,
}
startup_settings_constants.settings.QUALITY_BASE_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "quality-base-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1.3,
    maximum_value = 11,
    minimum_value = 1,
}
--[[ Payload modifiers ]]
startup_settings_constants.settings.PROJECTILE_PLACEHOLDER_COLLISION = {
    type = "string-setting",
    name = prefix .. "projectile-placeholder-collision",
    setting_type = "startup",
    order = "",
    allowed_values = { "default", "all", "none", },
    default_value = "default",
}
startup_settings_constants.settings.DO_MAP_REVEAL = {
    type = "bool-setting",
    name = prefix .. "do-map-reveal-startup",
    setting_type = "startup",
    order = "",
    default_value = true,
}

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.entity.payloader-rocket")))

--[[ Bomb ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.quality.warheads.atomic-bomb")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.entity.warheads.atomic-bomb")))

--[[ Warhead ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.quality.warheads.atomic-warhead")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.entity.warheads.atomic-warhead")))

--[[ rod-from-god ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.quality.warheads.rod-from-god")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.entity.warheads.rod-from-god")))

--[[ jericho ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.quality.warheads.jericho")))

--[[ tesla-rocket ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.quality.warheads.tesla-rocket")))

--[[ Krastorio2-spaced-out: kr-nuclear-turret-rocket ]]
startup_settings_constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_AREA_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-turret-rocket-area-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_DAMAGE_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-turret-rocket-damage-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_REPEAT_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-turret-rocket-repeat-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_TURRET_ROCKET_FIRE_WAVE = {
    type = "bool-setting",
    name = prefix .. "kr-nuclear-turret-rocket-fire-wave",
    setting_type = "startup",
    order = "",
    default_value = false,
    hidden = not k2so_active,
}

--[[ Krastorio2-spaced-out: kr-nuclear-artillery-shell ]]
startup_settings_constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AREA_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-artillery-shell-area-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_DAMAGE_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-artillery-shell-damage-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_REPEAT_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "kr-nuclear-artillery-shell-repeat-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not k2so_active,
}
startup_settings_constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_FIRE_WAVE = {
    type = "bool-setting",
    name = prefix .. "kr-nuclear-artillery-shell-fire-wave",
    setting_type = "startup",
    order = "",
    default_value = false,
    hidden = not k2so_active,
}

--[[ Krastorio2-spaced-out: kr-nuclear-artillery-shell ]]
startup_settings_constants.settings.K2_SO_NUCLEAR_ARTILLERY_SHELL_AMMO_CATEGORY = {
    type = "string-setting",
    name = prefix .. "kr-nuclear-artillery-shell-ammo-category",
    setting_type = "startup",
    order = "",
    allowed_values = { "artillery-shell", "nuclear-artillery" },
    default_value = "artillery-shell",
    hidden = not k2so_active,
}

--[[ SimpleAtomicArtillery-S: atomic-artillery-shell ]]
startup_settings_constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AREA_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "saa-s-atomic-artillery-shell-area-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not saa_s_active,
}
startup_settings_constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_DAMAGE_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "saa-s-atomic-artillery-shell-damage-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not saa_s_active,
}
startup_settings_constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_REPEAT_MULTIPLIER = {
    type = "double-setting",
    name = prefix .. "saa-s-atomic-artillery-shell-repeat-multiplier",
    setting_type = "startup",
    order = "",
    default_value = 1,
    maximum_value = 11,
    minimum_value = 1,
    hidden = not saa_s_active,
}
startup_settings_constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_FIRE_WAVE = {
    type = "bool-setting",
    name = prefix .. "saa-s-atomic-artillery-shell-fire-wave",
    setting_type = "startup",
    order = "",
    default_value = false,
    hidden = not saa_s_active,
}

--[[ SimpleAtomicArtillery-S: atomic-artillery-shell ]]
startup_settings_constants.settings.SIMPLE_ATOMIC_ARTILLERY_SHELL_AMMO_CATEGORY = {
    type = "string-setting",
    name = prefix .. "saa-s-atomic-artillery-shell-ammo-category",
    setting_type = "startup",
    order = "",
    allowed_values = { "artillery-shell", "nuclear-artillery" },
    default_value = "artillery-shell",
    hidden = not saa_s_active,
}

--[[ atomic-bomb ]]
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.warheads.atomic-bomb")))
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.warheads.atomic-bomb")()))

--[[ atomic-warhead ]]
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.warheads.atomic-warhead")))
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.warheads.atomic-warhead")))

--[[ cn-payload-vehicle ]]
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.payload-vehicle")))
__Data_Utils.foreach(
    function(params) if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.payload-vehicle")))

--[[ payloader recipes ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.payloader-recipes")))

--[[ payloader ]]
-- startup_settings_constants.settings.PAYLOADER_DO_TINT = {
--     type = "bool-setting",
--     setting_type = "startup",
--     name = prefix .. "payloader-do-tint",
--     default_value = false,
-- }
-- startup_settings_constants.settings.PAYLOADER_BASE_TINT = {
--     type = "color-setting",
--     setting_type = "startup",
--     name = prefix .. "payloader-tint-base",
--     default_value = { r = 1.0, g = 0.0, b = 0.0, a = 1, },
-- }

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.payloader")))

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.payloader")))

--[[ rod-from-god ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.warheads.rod-from-god")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.warheads.rod-from-god")))

--[[ jericho ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.warheads.jericho")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.warheads.jericho")))

--[[ tesla-rocket ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.warheads.tesla-rocket")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.warheads.tesla-rocket")))

--[[ Rocket Control Unit ]]
startup_settings_constants.settings.ROCKET_CONTROL_UNIT_STACK_SIZE = {
    type = "int-setting",
    name = prefix .. "rocket-control-unit-stack-size",
    setting_type = "startup",
    order = "",
    default_value = 10,
    maximum_value = 200,
    minimum_value = 1
}
startup_settings_constants.settings.ROCKET_CONTROL_UNIT_WEIGHT_MODIFIER = {
    type = "double-setting",
    name = prefix .. "rocket-control-unit-weight-modifier",
    setting_type = "startup",
    order = "",
    default_value = 0.2,
    maximum_value = tons,
    minimum_value = 0.0005
}

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.rocket-control-unit")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.rocket-control-unit")))

--[[ Ballistic-rocket-silo ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.ballistic-rocket-silo")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-silo")))

--[[ Ballistic-rocket-part ]]
startup_settings_constants.settings.BALLISTIC_ROCKET_PART_DO_TINT = {
    type = "bool-setting",
    setting_type = "startup",
    name = prefix .. "ballistic-rocket-part-do-tint",
    default_value = false,
}
startup_settings_constants.settings.BALLISTIC_ROCKET_PART_BASE_TINT = {
    type = "color-setting",
    setting_type = "startup",
    name = prefix .. "ballistic-rocket-part-tint-base",
    default_value = { r = 0.875, g = 0.859, b = 0.82, a = 1, },
}
startup_settings_constants.settings.BALLISTIC_ROCKET_PART_PRIMARY_TINT = {
    type = "color-setting",
    setting_type = "startup",
    name = prefix .. "ballistic-rocket-part-tint-primary",
    default_value = { r = 0.773, g = 0.698, b = 0.576, a = 1, },
}
startup_settings_constants.settings.BALLISTIC_ROCKET_PART_SECONDARY_TINT = {
    type = "color-setting",
    setting_type = "startup",
    name = prefix .. "ballistic-rocket-part-tint-secondary",
    default_value = { r = 0.31, g = 0.173, b = 0.59, a = 1, },
}
startup_settings_constants.settings.BALLISTIC_ROCKET_PART_TERTIARY_TINT = {
    type = "color-setting",
    setting_type = "startup",
    name = prefix .. "ballistic-rocket-part-tint-tertiary",
    default_value = { r = 0.545, g = 0.639, b = 0.267, a = 1, },
}

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.items.ballistic-rocket-part")))
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-parts.basic")))

--[[ intermediate ballistic-rocket-part ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-parts.intermediate")))

--[[ advanced ballistic-rocket-part ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-parts.advanced")))

--[[ beyond ballistic-rocket-part ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then
        startup_settings_constants.settings[params.setting] = params
    end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-parts.beyond")))

--[[ beyond ballistic-rocket-part-2 ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.recipes.ballistic-rocket-parts.beyond-2")))

--[[ Technology ]]
--[[ ICBMS ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.icbms")))

--[[ IPBMS ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.ipbms")))

__Data_Utils.foreach(function(params)
    if (params and params.setting) then
        startup_settings_constants.settings[params.setting] = params
    end
end, __Data_Utils.unpack(require("settings.startup.technologies.warheads.atomic-warhead")))

--[[ Rocket Control Unit ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.rocket-control-unit")))

--[[ Rod from God ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.warheads.rod-from-god")))

--[[ Jericho ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.warheads.jericho")))

--[[ tesla-rocket ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.warheads.tesla-rocket")))

--[[ Damage Research ]]

--[[ nuclear-weapons ]]
__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.nuclear-weapons")))

--[[ Ballistic-rocketry-and-logistics ]]

__Data_Utils.foreach(function(params)
    if (params and params.setting) then startup_settings_constants.settings[params.setting] = params end
end, __Data_Utils.unpack(require("settings.startup.technologies.ballistic-rocketry-and-logistics")))

startup_settings_constants.settings.DEBUG_PAYLOAD_STARTUP_PROCESSING = {
    type = "bool-setting",
    name = prefix .. "debug-payload-startup-processing",
    setting_type = "startup",
    order = "",
    default_value = false,
}

local order_settings = Settings_Utils.order_settings({ settings = startup_settings_constants.settings })
startup_settings_constants.settings_array = order_settings.array
startup_settings_constants.settings_dictionary = order_settings.dictionary

-- [[ crafting-categories ]]

if (sa_active) then
    local sa_crafting_categories =
    {
        "captive-spawner-process",
        "chemistry-or-cryogenics",
        "cryogenics",
        "cryogenics-or-assembling",
        "crafting-with-fluid-or-metallurgy",
        "crushing",
        "electronics-or-assembling",
        "electromagnetics",
        "electronics",
        "electronics-with-fluid",
        "metallurgy",
        "metallurgy-or-assembling",
        "organic",
        "organic-or-assembling",
        "organic-or-chemistry",
        "organic-or-hand-crafting",
        "pressing",
    }

    __Data_Utils.foreach(function(params)
        if (params and params.setting and params.setting:find("_CRAFTING_MACHINE$")) then
            for k, v in pairs(sa_crafting_categories) do
                table.insert(params.allowed_values, v)
            end
        end
    end, __Data_Utils.unpack(startup_settings_constants.settings))
end

if (se_active) then
    local se_crafting_categories =
    {
        "arcosphere",
        -- "condenser-turbine",
        -- "big-turbine",
        "casting",
        "kiln",
        -- "delivery-cannon",
        -- "delivery-cannon-weapon",
        -- "fixed-recipe", -- generic group for anything with a fixed recipe, not chosen by player
        "fuel-refining",
        "core-fragment-processing",
        "lifesupport", -- same as "space-lifesupport" but can be on land
        "melting",
        "nexus",
        "pulverising",
        "crafting-or-electromagnetics",
        -- "hard-recycling", -- no conflict with "recycling"
        -- "hand-hard-recycling", -- no conflict with "recycling"
        "se-electric-boiling", -- needs to be SE specific otherwise energy values will be off
        "space-accelerator",
        "space-astrometrics",
        "space-biochemical",
        "space-collider",
        "space-crafting", -- same as basic assembling but only in space
        "space-decontamination",
        "space-electromagnetics",
        "space-elevator",
        "space-materialisation",
        "space-genetics",
        "space-gravimetrics",
        "space-growth",
        "space-hypercooling",
        "space-laser",
        "space-lifesupport", -- same as "lifesupport" but can only be in space
        "space-manufacturing",
        "space-mechanical",
        "space-observation-gammaray",
        "space-observation-xray",
        "space-observation-uv",
        "space-observation-visible",
        "space-observation-infrared",
        "space-observation-microwave",
        "space-observation-radio",
        "space-plasma",
        "space-radiation",
        "space-radiator",
        -- "space-hard-recycling", -- no conflict with "recycling"
        "space-research",
        "space-spectrometry",
        "space-supercomputing-1",
        "space-supercomputing-2",
        "space-supercomputing-3",
        "space-supercomputing-4",
        "space-thermodynamics",
        -- "spaceship-console",
        -- "spaceship-antimatter-engine",
        -- "spaceship-ion-engine",
        -- "spaceship-rocket-engine",
        -- "pressure-washing",
        -- "dummy",
        -- "no-category"
    }

    startup_settings_constants.settings.TARGET_COMBINATOR_CRAFTING_MACHINE.default_value = "space-crafting"

    __Data_Utils.foreach(function(params)
        if (params and params.setting and params.setting:find("_CRAFTING_MACHINE$")) then
            for k, v in pairs(se_crafting_categories) do
                table.insert(params.allowed_values, v)
            end
        end
    end, __Data_Utils.unpack(startup_settings_constants.settings))
end

local create_recipe_string = function (data)
    if (not data or type(data) ~= "table") then return end
    if (not data.ingredients or type(data.ingredients) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "table") then return end

    for k, v in pairs(data.ingredients) do
        if (not data.setting.default_value or data.setting.default_value == "") then
            data.setting.default_value =
                v.name
                .. "="
                .. (
                        v.amount
                    or
                        v.amount_min
                        .. "-" ..
                        v.amount_max
                )
                .. (
                            v.probability
                        and "%" .. v.probability
                    or
                        ""
                )
        else
            data.setting.default_value =
                data.setting.default_value
                .. ","
                .. v.name
                .. "="
                .. (
                        v.amount
                    or
                        v.amount_min
                        .. "-" ..
                        v.amount_max
                )
                .. (
                            v.probability
                        and "%" .. v.probability
                    or
                        ""
                )
        end

        if (v.temperature or v.percent_spoiled) then
            data.setting.default_value = data.setting.default_value .. "{"
            data.setting.default_value = data.setting.default_value .. (
                        v.temperature
                    and "temperature=" .. v.temperature .. "C,"
                or
                    ""
            )
            data.setting.default_value = data.setting.default_value .. (
                        v.percent_spoiled
                    and "percent_spoiled=" .. v.percent_spoiled
                or
                    ""
            )

            data.setting.default_value = data.setting.default_value .. "}"
        end
    end
end
local create_results_string = create_recipe_string

local create_research_prerequisites_string = function (data)
    if (not data or type(data) ~= "table") then return end
    if (not data.prerequisites or type(data.prerequisites) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "table") then return end

    for k, v in pairs(data.prerequisites) do
        if (not data.setting.default_value or data.setting.default_value == "") then
            data.setting.default_value = v
        else
            data.setting.default_value = data.setting.default_value .. ",".. v
        end
    end
end

local create_research_ingredients_string = function (data)
    if (not data or type(data) ~= "table") then return end
    if (not data.ingredients or type(data.ingredients) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "table") then return end

    for k, v in pairs(data.ingredients) do
        if (not data.setting.default_value or data.setting.default_value == "") then
            data.setting.default_value =
                v.name
                .. "="
                .. v.amount
        else
            data.setting.default_value =
                data.setting.default_value
                .. ","
                .. v.name
                .. "="
                .. v.amount
        end
    end
end

for _, setting in ipairs({
    --[[ Payloader ]]
    { recipe = "PAYLOADER_RECIPE",        result = "PAYLOADER_RESULTS", },
    { recipe = "PAYLOADER_LOAD_RECIPE",   result = nil, },
    { recipe = "PAYLOADER_UNLOAD_RECIPE", result = nil, },

    --[[ Payload-Vehicle ]]
    { recipe = "PAYLOAD_VEHICLE_RECIPE", result = "PAYLOAD_VEHICLE_RESULTS", },
    { recipe = "PAYLOAD_VEHICLE_EFFICIENT_RECIPE", result = "PAYLOAD_VEHICLE_EFFICIENT_RESULTS", },

    --[[ Warheads ]]
    { recipe = "ATOMIC_BOMB_RECIPE",    result = "ATOMIC_BOMB_RESULTS", },
    { recipe = "ATOMIC_WARHEAD_RECIPE", result = "ATOMIC_WARHEAD_RESULTS", },
    { recipe = "ROD_FROM_GOD_RECIPE",   result = "ROD_FROM_GOD_RESULTS", },
    { recipe = "JERICHO_RECIPE",        result = "JERICHO_RESULTS", },
    { recipe = "TESLA_ROCKET_RECIPE",   result = "TESLA_ROCKET_RESULTS", },

    --[[ RCUs ]]
    { recipe = "ROCKET_CONTROL_UNIT_RECIPE",              result = "ROCKET_CONTROL_UNIT_RESULTS", },
    { recipe = "ROCKET_CONTROL_UNIT_INTERMEDIATE_RECIPE", result = "ROCKET_CONTROL_UNIT_INTERMEDIATE_RESULTS", },
    { recipe = "ROCKET_CONTROL_UNIT_ADVANCED_RECIPE",     result = "ROCKET_CONTROL_UNIT_ADVANCED_RESULTS", },
}) do
    if (startup_settings_constants.settings[setting.recipe]) then
        log(serpent.block(setting))
        if (setting.recipe) then create_recipe_string({  ingredients = startup_settings_constants.settings[setting.recipe].ingredients, setting = startup_settings_constants.settings[setting.recipe], }) end
        if (setting.result) then create_results_string({ ingredients = startup_settings_constants.settings[setting.result].results,     setting = startup_settings_constants.settings[setting.result], }) end
    end
end

for _, setting in ipairs({
    { prerequisites = "ATOMIC_WARHEAD_RESEARCH_PREREQUISITES",          ingredients = "ATOMIC_WARHEAD_RESEARCH_INGREDIENTS", },
    { prerequisites = "ROD_FROM_GOD_RESEARCH_PREREQUISITES",            ingredients = "ROD_FROM_GOD_RESEARCH_INGREDIENTS", },
    { prerequisites = "JERICHO_RESEARCH_PREREQUISITES",                 ingredients = "JERICHO_RESEARCH_INGREDIENTS", },
    { prerequisites = "MIRVS_RESEARCH_PREREQUISITES",                   ingredients = "MIRVS_RESEARCH_INGREDIENTS", },
    { prerequisites = "ICBMS_RESEARCH_PREREQUISITES",                   ingredients = "ICBMS_RESEARCH_INGREDIENTS", },
    { prerequisites = "NUCLEAR_WEAPONS_RESEARCH_PREREQUISITES",         ingredients = "NUCLEAR_WEAPONS_RESEARCH_INGREDIENTS", },
    { prerequisites = "PAYLOADER_RESEARCH_PREREQUISITES",               ingredients = "PAYLOADER_RESEARCH_INGREDIENTS", },
    { prerequisites = "ROCKET_CONTROL_UNIT_RESEARCH_PREREQUISITES",     ingredients = "ROCKET_CONTROL_UNIT_RESEARCH_INGREDIENTS", },
}) do
    if (startup_settings_constants.settings[setting.prerequisites or ""] or startup_settings_constants.settings[setting.ingredients or ""]) then
        if (setting.prerequisites) then create_research_prerequisites_string({ prerequisites = startup_settings_constants.settings[setting.prerequisites].prerequisites, setting = startup_settings_constants.settings[setting.prerequisites], }) end
        if (setting.ingredients) then create_research_ingredients_string({     ingredients   = startup_settings_constants.settings[setting.ingredients].ingredients,     setting = startup_settings_constants.settings[setting.ingredients],   }) end
    end
end

if (sa_active) then
    for _, setting in ipairs({
        { prerequisites = "TESLA_ROCKET_RESEARCH_PREREQUISITES", ingredients = "TESLA_ROCKET_RESEARCH_INGREDIENTS", },
    }) do
        if (startup_settings_constants.settings[setting.prerequisites or ""] or startup_settings_constants.settings[setting.ingredients or ""]) then
            if (setting.prerequisites) then create_research_prerequisites_string({ prerequisites = startup_settings_constants.settings[setting.prerequisites].prerequisites, setting = startup_settings_constants.settings[setting.prerequisites], }) end
            if (setting.ingredients) then create_research_ingredients_string({     ingredients   = startup_settings_constants.settings[setting.ingredients].ingredients,     setting = startup_settings_constants.settings[setting.ingredients],   }) end
        end
    end
end

if (sa_active or se_active) then
    for _, setting in ipairs({
        { recipe = "BALLISTIC_ROCKET_SILO_RECIPE",              result = "BALLISTIC_ROCKET_SILO_RESULTS", },
        { recipe = "BALLISTIC_ROCKET_PART_RECIPE",              result = "BALLISTIC_ROCKET_PART_RESULTS", },
        { recipe = "INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE", result = "INTERMEDIATE_BALLISTIC_ROCKET_PART_RESULTS", },
        { recipe = "ADVANCED_BALLISTIC_ROCKET_PART_RECIPE",     result = "ADVANCED_BALLISTIC_ROCKET_PART_RESULTS", },
        { recipe = "BEYOND_BALLISTIC_ROCKET_PART_RECIPE",       result = "BEYOND_BALLISTIC_ROCKET_PART_RESULTS", },
        { recipe = "BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE",     result = "BEYOND_2_BALLISTIC_ROCKET_PART_RESULTS", },
    }) do
        if (startup_settings_constants.settings[setting.recipe] or startup_settings_constants.settings[setting.result]) then
            if (setting.recipe) then create_recipe_string({  ingredients = startup_settings_constants.settings[setting.recipe].ingredients, setting = startup_settings_constants.settings[setting.recipe], }) end
            if (setting.result) then create_results_string({ ingredients = startup_settings_constants.settings[setting.result].results,     setting = startup_settings_constants.settings[setting.result], }) end
        end
    end

    for _, setting in ipairs({
        { prerequisites = "IPBMS_RESEARCH_PREREQUISITES",        ingredients = "IPBMS_RESEARCH_INGREDIENTS", },
    }) do
        if (startup_settings_constants.settings[setting.prerequisites or ""] or startup_settings_constants.settings[setting.ingredients or ""]) then
            if (setting.prerequisites) then create_research_prerequisites_string({ prerequisites = startup_settings_constants.settings[setting.prerequisites].prerequisites, setting = startup_settings_constants.settings[setting.prerequisites], }) end
            if (setting.ingredients) then create_research_ingredients_string({     ingredients   = startup_settings_constants.settings[setting.ingredients].ingredients,     setting = startup_settings_constants.settings[setting.ingredients],   }) end
        end
    end
end

for _, setting in ipairs({
    { prerequisites = "BRAL_RESEARCH_PREREQUISITES", ingredients = "BRAL_RESEARCH_INGREDIENTS", },
}) do
    if (startup_settings_constants.settings[setting.prerequisites or ""] or startup_settings_constants.settings[setting.ingredients or ""]) then
        if (setting.prerequisites) then create_research_prerequisites_string({ prerequisites = startup_settings_constants.settings[setting.prerequisites].prerequisites, setting = startup_settings_constants.settings[setting.prerequisites], }) end
        if (setting.ingredients) then create_research_ingredients_string({     ingredients   = startup_settings_constants.settings[setting.ingredients].ingredients,     setting = startup_settings_constants.settings[setting.ingredients],   }) end
    end
end

return startup_settings_constants