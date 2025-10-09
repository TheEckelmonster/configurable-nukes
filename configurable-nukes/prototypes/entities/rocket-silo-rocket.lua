local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (sa_active or se_active) then
    local Util = require("__core__.lualib.util")

    local rocket_silo_rocket = data.raw["rocket-silo-rocket"]["rocket-silo-rocket"]

    local interplanetary_rocket_silo_rocket = Util.table.deepcopy(rocket_silo_rocket)
    interplanetary_rocket_silo_rocket.name = "ipbm-rocket-silo-rocket"
    interplanetary_rocket_silo_rocket.inventory_size = se_active and 10 or 20
    -- interplanetary_rocket_silo_rocket.cargo_pod_entity = "ipbm-cargo-pod"

    data:extend({interplanetary_rocket_silo_rocket})
end