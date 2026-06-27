local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]

local prefix = "configurable-nukes-"

local technology = {
    {
        setting = "PAYLOADER",
        name = "payloader",
        count = 2000,
        research_time = 60,
        prerequisites = {
            "automation-3",
            "bulk-inserter",
            "fluid-handling",
        },
        ingredients = {
            { name = "automation-science-pack", amount = 1, },
            { name = "logistic-science-pack",   amount = 1, },
            { name = "chemical-science-pack",   amount = 1, },
            { name = "military-science-pack",   amount = 1, },
            { name = "production-science-pack", amount = 1, },
        },
    },
}

local count = 0
if (cn_avionics_active or cn_materials_active or cn_propulsion_active) then
    if (cn_avionics_active) then
        count = count + 1
        table.insert(technology[1].prerequisites, "cn-avionics-2")
        table.insert(technology[1].ingredients, { name = "space-science-pack",      amount = 1, })
    end
    if (cn_materials_active) then
        count = count + 1
        table.insert(technology[1].prerequisites, "cn-materials-engineering-2")
    end
    if (cn_propulsion_active) then
        count = count + 1
        table.insert(technology[1].prerequisites, "cn-propulsion-systems-2")
        table.insert(technology[1].ingredients, { name = "utility-science-pack",    amount = 1, })
    end
end
if (count < 3) then
    table.insert(technology[1].prerequisites, "cn-bral-2")
end

local settings = {}

for i = 1, #technology, 1 do
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_PREREQUISITES",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-prerequisites",
        setting_type = "startup",
        order = "",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        prerequisites = technology[i].prerequisites,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_INGREDIENTS",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-ingredients",
        setting_type = "startup",
        order = "",
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = technology[i].ingredients
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_TIME",
        type = "int-setting",
        name = prefix .. technology[i].name .. "-research-time",
        setting_type = "startup",
        order = "",
        default_value = technology[i].research_time,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_COUNT",
        type = "int-setting",
        name = prefix .. technology[i].name .. "-research-count",
        setting_type = "startup",
        order = "",
        default_value = technology[i].count,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    }
end

return settings