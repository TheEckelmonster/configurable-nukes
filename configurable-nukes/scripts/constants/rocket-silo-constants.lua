local rocket_silo_constants = {}

rocket_silo_constants.event_filter =
{
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "rocket-silo", mode = "and" },
    { filter = "type", type = "rocket-silo" },
    { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
}

rocket_silo_constants.entity_filter =
{
    type = "rocket-silo",
}

rocket_silo_constants.multiple_entity_filter =
{
    name =
    {
        "rocket-silo",
        "ipbm-rocket-silo",
    },
}

return rocket_silo_constants