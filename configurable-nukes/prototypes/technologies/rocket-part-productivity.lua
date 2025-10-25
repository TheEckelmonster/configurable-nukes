if (mods and mods["space-age"]) then
    local rocket_part_productivity_technology = data.raw["technology"]["rocket-part-productivity"]
    if (rocket_part_productivity_technology) then
        table.insert(rocket_part_productivity_technology.effects,
        {
            type = "change-recipe-productivity",
            recipe = "ipbm-rocket-part-dummy",
            change = 0.1
        })

        table.insert(rocket_part_productivity_technology.effects,
        {
            type = "change-recipe-productivity",
            recipe = "cn-payload-vehicle",
            change = 0.1
        })

        data:extend({rocket_part_productivity_technology})
    end
end