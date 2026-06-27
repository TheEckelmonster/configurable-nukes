local mods = mods

local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"]
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"]

if (se_active) then return end

local prefix = "configurable-nukes-"

local technology = {
    setting = "ROCKET_CONTROL_UNIT",
    name = "rocket-control-unit",
    count = 400,
    research_time = 45,
    prerequisites = {
        "advanced-ciruit",
        "circuit-network",
        "efficiency-module",
        "radar",
        "battery",
        "automation-science-pack",
        "logistic-science-pack",
        "chemical-science-pack",
        "military-science-pack",
    },
    ingredients = {
        { name = "automation-science-pack", amount = 1, },
        { name = "logistic-science-pack",   amount = 1, },
        { name = "chemical-science-pack",   amount = 1, },
        { name = "military-science-pack",   amount = 1, },
    },
}

--[[ rocket-control-unit ]]
local settings = {}

settings[#settings+1] = {
    setting = technology.setting .. "_RESEARCH_PREREQUISITES",
    type = "string-setting",
    name = prefix .. technology.name .. "-research-prerequisites",
    setting_type = "startup",
    order = "",
    default_value = nil,
    allow_blank = true,
    auto_trim = true,
    prerequisites = technology.prerequisites,
}
settings[#settings+1] = {
    setting = technology.setting .. "_RESEARCH_INGREDIENTS",
    type = "string-setting",
    name = prefix .. technology.name .. "-research-ingredients",
    setting_type = "startup",
    order = "",
    default_value = nil,
    allow_blank = true,
    auto_trim = true,
    ingredients = technology.ingredients
}
settings[#settings+1] = {
    setting = technology.setting .. "_RESEARCH_TIME",
    type = "int-setting",
    name = prefix .. technology.name .. "-research-time",
    setting_type = "startup",
    order = "",
    default_value = technology.research_time,
    minimum_value = 1,
    maximum_value = 2 ^ 42,
}
settings[#settings+1] = {
    setting = technology.setting .. "_RESEARCH_COUNT",
    type = "int-setting",
    name = prefix .. technology.name .. "-research-count",
    setting_type = "startup",
    order = "",
    default_value = technology.count,
    minimum_value = 1,
    maximum_value = 2 ^ 42,
}

return settings