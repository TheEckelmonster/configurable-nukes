local se_active = mods and mods["space-exploration"] and true

if (se_active) then
    local payloader = data.raw["assembling-machine"]["payloader"]
    if (payloader) then
        payloader.collision_mask.layers["space_tile"] = nil
        payloader.collision_mask.layers["moving_tile"] = nil
        payloader.collision_mask.layers["meltable"] = nil

        if (payloader.custom_tooltip_fields) then
            for k, v in pairs(payloader.custom_tooltip_fields) do
                if (v.key == "cannot-be-placed-on") then
                    if (v[1] and v[2] and v[2][1]) then
                        if (v[1] == "space-exploration.cannot_be_placed_on_line" and v[2][1] == "space-exploration.collision_mask_spaceship") then
                            payloader.custom_tooltip_fields[k] = nil
                        end
                    end
                end
            end
            payloader.custom_tooltip_fields = nil
        end
    end
end