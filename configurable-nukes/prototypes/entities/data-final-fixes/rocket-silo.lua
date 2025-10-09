local se_active = mods and mods["space-exploration"] and true

if (se_active) then
    local interplanetary_rocket_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]
    if (interplanetary_rocket_silo and interplanetary_rocket_silo.custom_tooltip_fields) then
        for k, v in pairs(interplanetary_rocket_silo.custom_tooltip_fields) do
            if (v.key == "cannot-be-placed-on") then
                if (v[1] and v[2] and v[2][1]) then
                    if (v[1] == "space-exploration.cannot_be_placed_on_line" and v[2][1] == "space-exploration.collision_mask_spaceship") then
                        interplanetary_rocket_silo.custom_tooltip_fields[k] = nil
                    end
                end
            end
        end
        interplanetary_rocket_silo.custom_tooltip_fields = nil
    end
end