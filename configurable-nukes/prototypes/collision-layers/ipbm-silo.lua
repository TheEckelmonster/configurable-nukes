local se_active = mods and mods["space-exploration"] and true

if (se_active) then
    local ipbm_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]
    ipbm_silo.collision_mask.layers["moving_tile"] = nil
end