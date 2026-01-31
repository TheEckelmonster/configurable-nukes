local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local quality_active = mods and mods["quality"]
local true_nukes_contiued = mods and mods["True-Nukes_Continued"]


if (quality_active) then
    --[[ Custom tooltips ]]
    if (not true_nukes_contiued) then
        -- atomic-bomb
        local atomic_bomb_item = data.raw["ammo"]["atomic-bomb"]
        if (atomic_bomb_item) then
            local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
                type = "projectile",
                name = "atomic-rocket",
            })

            atomic_bomb_item.custom_tooltip_fields = custom_tooltip_fields
        end
    end

    -- atomic-warhead
    local atomic_warhead_item = data.raw["ammo"]["atomic-warhead"]
    if (atomic_warhead_item) then
        local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
            type = "projectile",
            name = "atomic-warhead",
        })

        atomic_warhead_item.custom_tooltip_fields = custom_tooltip_fields
    end

    -- cn-rod-from-god
    local cn_rod_from_god = data.raw["ammo"]["cn-rod-from-god"]
    if (cn_rod_from_god) then
        local custom_tooltip_fields = Data_Utils.create_custom_tooltip_quality_effects_atomic({
            type = "projectile",
            name = "cn-rod-from-god",
        })

        cn_rod_from_god.custom_tooltip_fields = custom_tooltip_fields
    end
end