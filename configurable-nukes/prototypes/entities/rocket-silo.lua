require("__core__/lualib/circuit-connector-sprites")

local Util = require("__core__.lualib.util")

local se_active = mods and mods["space-exploration"] and true
local name_prefix = se_active and "se-" or ""

local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]

if (mods and (mods["space-age"] or mods["space-exploration"])) then
    local interplanetary_rocket_silo = Util.table.deepcopy(rocket_silo)

    interplanetary_rocket_silo.name = "ipbm-rocket-silo"
    interplanetary_rocket_silo.surface_conditions = nil
    interplanetary_rocket_silo.max_health = rocket_silo.max_health * 1.5
    -- interplanetary_rocket_silo.fixed_recipe = "ipbm-rocket-part-basic"
    interplanetary_rocket_silo.fixed_recipe = name_prefix .. "ipbm-rocket-part-dummy"

    interplanetary_rocket_silo.rocket_parts_required = 100

    interplanetary_rocket_silo.rocket_entity = "ipbm-rocket-silo-rocket"
    interplanetary_rocket_silo.minable = { mining_time = 1, result = "ipbm-rocket-silo" }

    local energy_usage = 250 * (4/3)
    local active_energy_usage = 3990 * (4/3)
    interplanetary_rocket_silo.energy_usage = energy_usage .. "W" --energy usage used when crafting the rocket
    interplanetary_rocket_silo.active_energy_usage = active_energy_usage .. "kW"

    interplanetary_rocket_silo.resistances = {
        {
            percent = 85,
            decrease = 10,
            type = "fire"
        },
        {
            percent = 85,
            decrease = 10,
            type = "impact"
        },
        {
            percent = 37.5,
            decrease = 10,
            type = "explosion"
        },
    }

    if (se_active) then
        table.insert(interplanetary_rocket_silo.resistances, { percent = 100, type = "meteor" })
    end

    if (mods and mods["space-exploration"]) then
        rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
        rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance

        interplanetary_rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
        interplanetary_rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance
    end

    interplanetary_rocket_silo.to_be_inserted_to_rocket_inventory_size = se_active and 10 or 20
    -- interplanetary_rocket_silo.logistic_trash_inventory_size = se_active and 10 or 20

    interplanetary_rocket_silo.localised_name = { "entity-name." .. name_prefix .. "ipbm-rocket-silo" }
    interplanetary_rocket_silo.localised_description = { "entity-description." .. name_prefix .. "ipbm-rocket-silo" }

    data:extend({interplanetary_rocket_silo})

    rocket_silo.surface_conditions = nil
    data:extend({rocket_silo})
elseif (mods and not mods["space-age"]) then
    rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
    rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance

    data:extend({rocket_silo})
end