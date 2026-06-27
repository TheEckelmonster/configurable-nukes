local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"] and true

local prefix = "configurable-nukes-"

local technology = {
    {
        setting = "ICBMS",
        name = "icbms",
        count = 1500,
        research_time = 60,
        prerequisites = {
            "rocket-silo",
            "radar",
            "electric-energy-accumulators",
            "rocket-control-unit",
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
    },
}

if (se_active) then
    technology[1].prerequisites = {
        "rocket-silo",
        "electric-energy-accumulators",
        "automation-science-pack",
        "logistic-science-pack",
        "chemical-science-pack",
        "military-science-pack",
        "se-rocket-science-pack",
    }

    table.insert(technology[1].ingredients, { name = "se-rocket-science-pack",  amount = 1 })
else
    if (cn_materials_active) then
        table.insert(technology[1].prerequisites, "cn-heat-shielding")
    end
    if (cn_propulsion_active) then
        table.insert(technology[1].prerequisites, "cn-liquid-rocket-fuel")
    end

    if (not sa_active) then
        table.insert(technology[1].ingredients, { name = "production-science-pack",  amount = 1 })
        table.insert(technology[1].ingredients, { name = "utility-science-pack",  amount = 1 })
    end
end

local settings = {}

for i = 1, #technology, 1 do
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_PREREQUISITES",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-prerequisites",
        setting_type = "startup",
        order = (technology[i].order or "") .. ("c[technology]-c[" .. technology[i].name .. "]-g[technology]-c[research-prerequisites]"),
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
        order = (technology[i].order or "") .. ("c[technology]-c[" .. technology[i].name .. "]-g[technology]-e[research-ingredients]"),
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
        order = (technology[i].order or "") .. ("c[technology]-c[" .. technology[i].name .. "]-g[technology]-g[research-time]"),
        default_value = technology[i].research_time,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_COUNT",
        type = "int-setting",
        name = prefix .. technology[i].name .. "-research-count",
        setting_type = "startup",
        order = (technology[i].order or "") .. ("c[technology]-c[" .. technology[i].name .. "]-g[technology]-h[research-count]"),
        default_value = technology[i].count,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
    }
end

return settings