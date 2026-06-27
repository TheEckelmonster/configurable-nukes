local Entity_Utils = require("settings.startup.entity.entity-utils")

return Entity_Utils.make_settings({
    {
        setting = "ATOMIC_BOMB",
        fire_wave = false,
        name = "atomic-bomb",
        pollution = 0.005,
        max_spread_count = 100,
        base_lifetime = 150,
        intial_lifetime = (3 / math.exp(1)) * 60,
        max_lifetime = (math.exp(1) / 1.5) * 60,
    },
})