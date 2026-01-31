local filters = {
    on_built_entity = {
        { filter = "name", name = "payloader" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "rocket-silo", mode = "and" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
    },
    on_robot_built_entity = {
        { filter = "name", name = "payloader" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "rocket-silo", mode = "and" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
    },
    script_raised_built = {
        { filter = "name", name = "payloader" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "rocket-silo", mode = "and" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
    },
    script_raised_revived = {
        { filter = "name", name = "payloader" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "rocket-silo", mode = "and" },
        { filter = "type", type = "rocket-silo" },
        { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
    },
}

filters.payloader_controller = {
    { filter = "name", name = "payloader" },
    { filter = "name", name = "payloader-container-input" },
    { filter = "name", name = "payloader-container-output" },
    { filter = "name", name = "payloader-container-input-vertical" },
    { filter = "name", name = "payloader-container-output-vertical" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "rocket-silo", mode = "and" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
}

filters.rocket_silo_controller = {
    { filter = "name", name = "payloader" },
    { filter = "name", name = "payloader-container-input" },
    { filter = "name", name = "payloader-container-output" },
    { filter = "name", name = "payloader-container-input-vertical" },
    { filter = "name", name = "payloader-container-output-vertical" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "rocket-silo", mode = "and" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
}

return filters