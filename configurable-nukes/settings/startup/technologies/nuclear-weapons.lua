local prefix = "configurable-nukes-"

local technology = {
    {
        setting = "NUCLEAR_WEAPONS",
        name = "nuclear-weapons",
        formula = "2^(L-1)*1000",
        research_time = 60,
        prerequisites = {
            "atomic-bomb",
            "space-science-pack",
            "stronger-explosives-6"
        },
        ingredients = {
            { name = "automation-science-pack", amount = 1 },
            { name = "logistic-science-pack",   amount = 1 },
            { name = "chemical-science-pack",   amount = 1 },
            { name = "military-science-pack",   amount = 1 },
            { name = "utility-science-pack",    amount = 1 },
            { name = "production-science-pack", amount = 1 },
            { name = "space-science-pack",      amount = 1 },
        },
    },
}

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
        default_value = 0.85,
        minimum_value = (1 / 11) ^ 11,
        maximum_value = 2 ^ 11,
        hidden = technology[i].hidden,
    }
    settings[#settings+1] = {
        setting = technology[i].setting .. "_RESEARCH_DAMAGE_MODIFIER_ARTILLERY",
        type = "double-setting",
        name = prefix .. technology[i].name .. "-research-damage-modifier-artillery",
        setting_type = "startup",
        order = technology[i].order or ("c[" .. technology[i].name .. "]-g[technology]-m[research-damage-modifier-artillery]"),
        default_value = 0.15,
        minimum_value = (1 / 11) ^ 11,
        maximum_value = 2 ^ 11,
        hidden = technology[i].hidden,
    }
end

return settings