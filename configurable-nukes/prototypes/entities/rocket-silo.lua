require("__core__/lualib/circuit-connector-sprites")

local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]

rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance

data:extend({rocket_silo})