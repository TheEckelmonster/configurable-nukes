local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

data:extend({
    {
        type = "item-subgroup",
        name = "payload",
        group = "combat",
        order = "b"
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