return function (Startup_Settings_Constants)
    local technology = {
        type = "technology",
        name = "cn-containment-canister",
        icon = "__configurable-nukes__/graphics/technology/containment-canister.png",
        icon_size = 256,
        effects = {},
        prerequisites = {},
        unit = {},
    }

    data:extend({ technology, })
end
