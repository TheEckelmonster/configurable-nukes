local sa_active = mods and mods["space-age"] and true

local technology = data.raw["technology"]["physical-projectile-damage-7"]

table.insert(technology.effects, {
    type = "ammo-damage",
    ammo_category = "kinetic-weapon",
    modifier = 0.85
})

for i = 3, 6, 1 do
    local technology = data.raw["technology"]["stronger-explosives-" .. i]

    local modifier = i * 0.1

    table.insert(technology.effects, {
        type = "ammo-damage",
        ammo_category = "nuclear",
        modifier = modifier,
        hidden = true,
    })

    table.insert(technology.effects, {
        type = "ammo-damage",
        ammo_category = "ballistic-missile-payload",
        modifier = modifier,
        hidden = true,
    })
end

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