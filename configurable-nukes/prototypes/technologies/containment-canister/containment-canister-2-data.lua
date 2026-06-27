return function (Startup_Settings_Constants)
    local technology = {
        type = "technology",
        name = "cn-containment-canister-2",
        icon = "__configurable-nukes__/graphics/technology/containment-canister.png",
        icon_size = 256,
        localised_name = { "technology-name.cn-containment-canister-2", },
        localised_description = { "technology-description.cn-containment-canister-2", },
        effects = {},
        prerequisites = {},
        unit = {},
        upgrade = true,
    }

    data:extend({ technology, })
end