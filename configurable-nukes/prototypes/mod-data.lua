local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

-- MULTISURFACE_BASE_DISTANCE_MODIFIER
local get_multisurface_base_distance_modifier = function()
    local setting = Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.default_value

    if (settings and settings.global and settings.global[Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name]) then
        setting = settings.global[Runtime_Global_Settings_Constants.settings.MULTISURFACE_BASE_DISTANCE_MODIFIER.name].value
    end

    return setting
end

local mod_data = {
    type = "mod-data",
    name = "configurable-nukes-mod-data",
    data = {
        ["planet"] = {},
        ["space-location"] = {},
        ["space-connection"] = {},
    },
}

for _, planet in pairs(data.raw.planet) do
    local planet_data = {
        type = "planet",
        name = nil,
        magnitude = 1,
        gravity_pull = 0,
        orientation = nil,
        star_distance = nil,
        x = 0,
        y = 0,
    }

    if (planet and type(planet) == "table") then
        planet_data.name = planet.name
        planet_data.magnitude = planet.magnitude
        planet_data.gravity_pull = planet.gravity_pull
        planet_data.orientation = planet.orientation
        planet_data.star_distance = planet.distance
        planet_data.x = planet.distance * math.sin((2 * math.pi) * planet.orientation)
        planet_data.y = planet.distance * math.cos((2 * math.pi) * planet.orientation)
    end

    if (planet and type(planet) == "table" and planet.name and type(planet.name) == "string" and #planet.name > 0) then
        mod_data.data["planet"][planet.name] = planet_data
    end
end

for _, space_location in pairs(data.raw["space-location"]) do
    if (space_location.type == "planet") then goto continue end
    local space_location_data = {
        type = "space-location",
        name = nil,
        magnitude = 1,
        gravity_pull = 0,
        orientation = nil,
        star_distance = nil,
        x = 0,
        y = 0,
    }

    if (space_location and type(space_location) == "table") then
        space_location_data.name = space_location.name
        space_location_data.magnitude = space_location.magnitude
        space_location_data.gravity_pull = space_location.gravity_pull
        space_location_data.orientation = space_location.orientation
        space_location_data.star_distance = space_location.distance
        space_location_data.x = space_location.distance * math.sin((2 * math.pi) * space_location.orientation)
        space_location_data.y = space_location.distance * math.cos((2 * math.pi) * space_location.orientation)
    end

    if (space_location and type(space_location) == "table" and space_location.name and type(space_location.name) == "string" and #space_location.name > 0) then
        mod_data.data["space-location"][space_location.name] = space_location_data
    end

    ::continue::
end

if (data.raw["space-connection"]) then
    for connection_id, space_connection in pairs(data.raw["space-connection"]) do
        local from = mod_data.data.planet[space_connection.from] or mod_data.data["space-location"][space_connection.from]
        local to = mod_data.data.planet[space_connection.to] or mod_data.data["space-location"][space_connection.to]

        local distance = ((from.x - to.x) ^ 2 + (from.y - to.y) ^ 2) ^ 0.5

        --[[ planet ]]
        if (mod_data.data.planet[space_connection.from]) then
            if (not mod_data.data.planet[space_connection.from]["space-connection"]) then mod_data.data.planet[space_connection.from]["space-connection"] = {} end
            if (not mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to]) then mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to] = {} end

            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].type = "space-connection"
            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].length = space_connection.length
            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].forward = space_connection.from .. "-" .. space_connection.to
            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].reverse = space_connection.to .. "-" .. space_connection.from
            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].reversed = false
            mod_data.data.planet[space_connection.from]["space-connection"][space_connection.to].distance = distance * get_multisurface_base_distance_modifier()
        end

        if (mod_data.data.planet[space_connection.to]) then
            if (not mod_data.data.planet[space_connection.to]["space-connection"]) then mod_data.data.planet[space_connection.to]["space-connection"] = {} end
            if (not mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from]) then mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from] = {} end

            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].type = "space-connection"
            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].length = space_connection.length
            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].forward = space_connection.to .. "-" .. space_connection.from
            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].reverse = space_connection.from .. "-" .. space_connection.to
            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].reversed = true
            mod_data.data.planet[space_connection.to]["space-connection"][space_connection.from].distance = distance * get_multisurface_base_distance_modifier()
        end

        --[[ space-location ]]
        if (mod_data.data["space-location"][space_connection.from]) then
            if (not mod_data.data["space-location"][space_connection.from]["space-connection"]) then mod_data.data["space-location"][space_connection.from]["space-connection"] = {} end
            if (not mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to]) then mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to] = {} end

            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].type = "space-connection"
            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].length = space_connection.length
            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].forward = space_connection.from .. "-" .. space_connection.to
            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].reverse = space_connection.to .. "-" .. space_connection.from
            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].reversed = false
            mod_data.data["space-location"][space_connection.from]["space-connection"][space_connection.to].distance = distance * get_multisurface_base_distance_modifier()
        end

        if (mod_data.data["space-location"][space_connection.to]) then
            if (not mod_data.data["space-location"][space_connection.to]["space-connection"]) then mod_data.data["space-location"][space_connection.to]["space-connection"] = {} end
            if (not mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from]) then mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from] = {} end

            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].type = "space-connection"
            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].length = space_connection.length
            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].forward = space_connection.to .. "-" .. space_connection.from
            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].reverse = space_connection.from .. "-" .. space_connection.to
            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].reversed = true
            mod_data.data["space-location"][space_connection.to]["space-connection"][space_connection.from].distance = distance * get_multisurface_base_distance_modifier()
        end

        if (not mod_data.data["space-connection"][connection_id]) then
            mod_data.data["space-connection"][connection_id] = {
                type = "space-connection",
                from = space_connection.from,
                to = space_connection.to,
                reversed = false,
                length = space_connection.length,
                distance = space_connection.distance
            }
            mod_data.data["space-connection"][space_connection.to .. "-" .. space_connection.from] = {
                type = "space-connection",
                from = space_connection.to,
                to = space_connection.from,
                reversed = true,
                length = space_connection.length,
                distance = space_connection.distance,
            }
        end
    end
end

data:extend({ mod_data })

--[[ In the event that someone wants to import this for their mod ]]
return mod_data