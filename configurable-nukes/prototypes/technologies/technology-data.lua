local technology = data.raw["technology"]["physical-projectile-damage-7"]

table.insert(technology.effects, {
    type = "ammo-damage",
    ammo_category = "kinetic-weapon",
    modifier = 0.85
})