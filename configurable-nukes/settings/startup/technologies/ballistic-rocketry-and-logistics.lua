local mods = mods

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-avionics"]
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-materials-engineering"]
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true or script and script.active_mods and script.active_mods["configurable-nukes-extended-propulsion-systems"]
local sa_active = mods and mods["space-age"] and true or script and script.active_mods and script.active_mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true or script and script.active_mods and script.active_mods["space-exploration"] and true

local prefix = "configurable-nukes-"

local max = 40000


for _, active in ipairs({
    cn_avionics_active,
    cn_materials_active,
    cn_propulsion_active,
}) do
    if (active) then max = max - 7500 end
end

local technology = {
    {
        setting = "BRAL",
        name = "bral",
        formula = "(2000+1000*(L-1))+(" .. max .. "-(2000+1000*(L-1)))*((L^(log2(20-L))/21)/100)^(5)",
        research_time = 60,
        prerequisites = {
            "icbms",
            "rocket-control-unit",
        },
        ingredients = {
            { name = "automation-science-pack", amount = 1, },
            { name = "logistic-science-pack",   amount = 1, },
            { name = "chemical-science-pack",   amount = 1, },
            { name = "military-science-pack",   amount = 1, },
        },
        hidden = max < 25000
    }
}

if (se_active) then
    table.insert(technology[1].ingredients, { name = "se-rocket-science-pack", amount = 1 })
end

local settings = {}
for i = 1, #technology, 1 do
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_PREREQUISITES",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-prerequisites",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-c[research-prerequisites]"),
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        prerequisites = technology[i].prerequisites,
        hidden = technology[i].hidden,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_INGREDIENTS",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-ingredients",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-e[research-ingredients]"),
        default_value = nil,
        allow_blank = true,
        auto_trim = true,
        ingredients = technology[i].ingredients,
        hidden = technology[i].hidden,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_TIME",
        type = "int-setting",
        name = prefix .. technology[i].name .. "-research-time",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-g[research-time]"),
        default_value = technology[i].research_time,
        minimum_value = 1,
        maximum_value = 2 ^ 42,
        hidden = technology[i].hidden,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_FORMULA",
        type = "string-setting",
        name = prefix .. technology[i].name .. "-research-formula",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-k[research-formula]"),
        default_value = technology[i].formula,
        allow_blank = false,
        auto_trim = true,
        hidden = technology[i].hidden,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_DAMAGE_MODIFIER",
        type = "double-setting",
        name = prefix .. technology[i].name .. "-research-damage-modifier",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-m[research-damage-modifier]"),
        default_value = -0.1,
        minimum_value = -1,
        maximum_value = 0,
        hidden = technology[i].hidden or cn_avionics_active,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_TOP_SPEED_MODIFIER",
        type = "double-setting",
        name = prefix .. technology[i].name .. "-research-top-speed-modifier",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-m[research-top-speed-modifier]"),
        default_value = 0.1,
        minimum_value = 0,
        maximum_value = 2 ^ 11,
        hidden = technology[i].hidden or cn_propulsion_active,
    }
end

return settings