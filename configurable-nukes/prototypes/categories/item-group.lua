local mods = mods
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

data:extend({
    {
        type = "item-subgroup",
        name = "payload",
        group = "combat",
        order = "a[payload]-a[payload]"
    },
    {
        type = "item-subgroup",
        name = "targeting",
        group = "intermediate-products",
        order = "a[payload]-b[targeting]"
    },
    {
        type = "item-subgroup",
        name = "reformatting",
        group = "intermediate-products",
        order = "a[payload]-c[reformatting]"
    },
    {
        type = "item-subgroup",
        name = "inter-ballistic-missile",
        group = (sa_active or se_active) and "space" or "logistics",
        order = sa_active and "a" or "a[inter-ballistic-missile]"
    },
    {
        type = "item-subgroup",
        name = "ipbm-rocket-parts",
        group = "intermediate-products",
        order = "a-g[ipbm-rocket-parts]"
    },
})