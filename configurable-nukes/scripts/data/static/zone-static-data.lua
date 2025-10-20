local Data = require("scripts.data.data")
local Log = require("libs.log.log")

--[[ From "Space-Exploration" v 0.7.34
    -> zone.lua
    -> function Zone.get_travel_delta_v_sub(origin, destination)

    Zone.travel_cost_interstellar = 400 -- stellar position distance, roughly 50 distance between stars, can be up to 300 apart
    Zone.travel_cost_star_gravity = 500 -- roughly 10-20 base for a star
    Zone.travel_cost_planet_gravity = 100 -- roughly 10-20 base for a planet
    Zone.travel_cost_space_distortion = Zone.travel_cost_interstellar * 25 -- based on 0-1 range_deviation

    -- expected ranges:
        -- 1500 planetary system
        -- 15000 solar system
        -- 50000 interstellarsystem
        -- 50000 to/from anomaly_data
]]
--[[ TODO: Make configurable ]]
-- local travel_cost_multiplier = get_travel_cost_multiplier()
local travel_cost_multiplier = 1
local travel_cost_interstellar = 600 --400

local zone_static_data = Data:new({
    type = "zone-static-data",
    travel_cost = Data:new({
        interstellar = travel_cost_interstellar * travel_cost_multiplier,
        star_gravity = 500 * travel_cost_multiplier,
        planet_gravity = 100 * travel_cost_multiplier,
        space_distortion = travel_cost_interstellar * 25 * travel_cost_multiplier,
    }),
    expected_ranges = Data:new({
        planetary_system = 1500,
        solar_system = 15000,
        intersterllar_sytstem = 50000,
        anomaly = 50000,
    })
})

return zone_static_data