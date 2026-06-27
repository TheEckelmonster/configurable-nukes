local launchable_rocket_silos = {
    ["rocket-silo"] = 1,
    ["ipbm-rocket-silo"] = 1,
}

if (script and script.active_mods and script.active_mods["QualityRockets"]) then
    for k, v in pairs(prototypes.quality) do
        launchable_rocket_silos[k .. "-rocket-silo"] = 1
        launchable_rocket_silos[k .. "-ipbm-rocket-silo"] = 1
    end
end

local filters = {
    on_built_entity = {
        { filter = "name", name = "payloader" },
        { filter = "name", name = "target-combinator" },
    },
    on_robot_built_entity = {
        { filter = "name", name = "payloader" },
        { filter = "name", name = "target-combinator" },
    },
    script_raised_built = {
        { filter = "name", name = "payloader" },
        { filter = "name", name = "target-combinator" },
    },
    script_raised_revived = {
        { filter = "name", name = "payloader" },
        { filter = "name", name = "target-combinator" },
    },
}

filters.payloader_controller = {
    { filter = "name", name = "target-combinator" },
    { filter = "name", name = "payloader" },
    { filter = "name", name = "payloader-container-input" },
    { filter = "name", name = "payloader-container-output" },
    { filter = "name", name = "payloader-container-input-vertical" },
    { filter = "name", name = "payloader-container-output-vertical" },
}

filters.rocket_silo_controller = {
    { filter = "name", name = "target-combinator" },
    { filter = "name", name = "payloader" },
    { filter = "name", name = "payloader-container-input" },
    { filter = "name", name = "payloader-container-output" },
    { filter = "name", name = "payloader-container-input-vertical" },
    { filter = "name", name = "payloader-container-output-vertical" },
}

filters.target_combinator_controller = {
    { filter = "name", name = "target-combinator" },
    { filter = "name", name = "payloader" },
    { filter = "name", name = "payloader-container-input" },
    { filter = "name", name = "payloader-container-output" },
    { filter = "name", name = "payloader-container-input-vertical" },
    { filter = "name", name = "payloader-container-output-vertical" },
}

for _, filter in pairs(filters) do
    for name, _ in pairs(launchable_rocket_silos) do
        table.insert(filter, { filter = "type", type = "rocket-silo" })
        table.insert(filter, { filter = "name", name = name, mode = "and" })
    end
end

return filters