local sa_active = mods and mods["space-age"] and true

local technology = data.raw["technology"]["physical-projectile-damage-7"]

table.insert(technology.effects, {
    type = "ammo-damage",
    ammo_category = "kinetic-weapon",
    modifier = 0.85
})

if (sa_active) then
    local technology = data.raw["technology"]["electric-weapons-damage-3"]
    table.insert(technology.effects, {
        type = "ammo-damage",
        ammo_category = "tesla-rocket",
        modifier = 0.7
    })

    technology = data.raw["technology"]["electric-weapons-damage-4"]
    table.insert(technology.effects, {
        type = "ammo-damage",
        ammo_category = "tesla-rocket",
        modifier = 0.7
    })
end