local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end


local Anomaly_Data = require("scripts.data.space.celestial-objects.anomaly-data")
local Asteroid_Belt_Data = require("scripts.data.space.celestial-objects.asteroid-belt-data")
local Asteroid_Field_Data = require("scripts.data.space.celestial-objects.asteroid-field-data")
local Orbit_Data = require("scripts.data.space.celestial-objects.orbit-data")
local Moon_Data = require("scripts.data.space.celestial-objects.moon-data")
local Planet_Data = require("scripts.data.space.celestial-objects.planet-data")
local Space_Location_Data = require("scripts.data.space.space-location-data")
local Space_Connection_Data = require("scripts.data.space.space-connection-data")
local Star_Data = require("scripts.data.space.celestial-objects.star-data")
local String_Utils = require("scripts.utils.string-utils")

local locals = {}

local default_space_exploration = function (data)
    return
    {
        ["star-data"]            = {},
        ["planet-data"]          = {},
        ["orbit-data"]           = {},
        ["moon-data"]            = {},
        ["asteroid-belt-data"]   = {},
        ["asteroid-field-data"]  = {},
        ["anomaly-data"]         = {},
        ["surfaces"]             = {},
    }
end

local default_mod_data = function (data)
    return
    {
        ["planet"] = {},
        ["space-location"] = {},
        ["space-connection"] = {},
        ["space-exploration"] = default_space_exploration(),
    }
end

local constants = {
    mod_name = "configurable-nukes",
    mod_data = default_mod_data(),
    ["planet"] = {},
    ["space-location"] = {},
    ["space-connection"] = {},
    ["space-exploration"] = default_space_exploration(),
    mod_data_dictionary = {},
    planets_dictionary = {},
    space_locations_dictionary = {},
    space_connections_dictionary = {},
    space_exploration_dictionary = {},
}

constants["space-exploration"].spaceships = {}

constants.direction_table = {}

for k, v in pairs(defines.direction) do
    constants.direction_table[v] = k
end

local depth = function ()
    local self = { depth = 0 }
    local get = function () return self.depth end
    local increment = function () self.depth = self.depth + 1 end
    local decrement = function () self.depth = self.depth - 1 end
    local reset = function () self.depth = 0 end

    return {
        get = get,
        increment = increment,
        decrement = decrement,
        reset = reset,
    }
end

constants.table = {
    calls = 0,
    file = {
        prefix = "configurable-nukes/",
        postfix = ".json",
    },
    depth = depth(),
    SPACING = "    ",
    traverse_find  = function (t_name, data, found_data, path, optionals)
        Log.debug("constants.table.traverse_find")
        Log.info(t_name)
        Log.info(data)
        Log.info(found_data)
        Log.info(path)
        Log.info(optionals)

        if (t_name == nil or type(t_name) ~= "string" or #(string.gsub(t_name, " ", "")) <= 0) then return end
        if (data == nil or type(data) ~= "table") then data = storage end
        if (found_data == nil or type(found_data) ~= "table") then found_data = {} end
        if (path == nil or type(path) ~= "string") then path = "storage" end

        constants.table.calls = 0
        local depth = depth()

        local do_traverse; do_traverse = function (t_name, data, found_data, path, optionals)
            if (constants.table.calls > 2 ^ 16) then return end

            constants.table.calls = constants.table.calls + 1
            depth.increment()


            local t_return = { data = nil, name = path, return_val = 0, depth = 2 ^ 8 - 1 }

            local should_return; should_return = function (_t_return, optionals)

                if (type(_t_return) == "table") then
                    if (_t_return.do_return) then
                        depth.reset()
                        return _t_return
                    elseif (_t_return.return_val and t_return.return_val and _t_return.return_val > t_return.return_val) then
                        t_return = _t_return
                        return false
                    elseif (not t_return.return_val) then
                        t_return = _t_return
                        return false
                    end
                end
                return false
            end

            -- if (not found_data[data]) then
            if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
                if (not found_data[data]) then found_data[data] = {} end
                found_data[data].depth = depth.get()

                for k, v in pairs(data) do
                    if (type(v) == "table") then
                        if (optionals.parsed_name) then
                            if (path .. "." .. tostring(k)):find(t_name, 1, true) then
                                depth.reset()
                                return { data = v, name = path .. "." .. tostring(k), do_return = true }
                            end
                            if (  (optionals.parsed_name.step.t[tostring(k)] and depth.get() == optionals.parsed_name.step.a[optionals.parsed_name.step.t[tostring(k)]])
                                or optionals.parsed_name.t[path .. "." .. tostring(k)]
                                or optionals.parsed_name.reversed.t[path .. "." .. tostring(k)]) then

                                local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                                if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end

                                return { data = v, name = path .. "." .. tostring(k), return_val = optionals.parsed_name.reversed.t[k], depth = depth.get() }
                            end
                        end
                        if (tostring(k) == t_name or path .. "." .. tostring(k) == t_name) then depth.reset(); return { data = v, name = path .. "." .. tostring(k) , do_return = true, depth = depth.get() } end
                        local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                        if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end
                    end
                end
            end

            depth.decrement()
            return t_return
        end
        return do_traverse(t_name, data, found_data, path, optionals)
    end,
    traverse_print  = function (data, file_name, found_data, optionals)
        Log.debug("constants.table.traverse_print")
        Log.info(data)
        Log.info(file_name)
        Log.info(found_data)
        Log.info(optionals)

        if (data == nil or type(data) ~= "table") then return -1 end
        if (file_name == nil or type(file_name) ~= "string") then return -1 end
        if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

        optionals = type(optionals) == "table" and optionals or { max_depth = 4 }

        constants.table.calls = 0
        local depth = depth()
        if (not file_name:find(constants.table.file.prefix, 1)) then file_name = constants.table.file.prefix .. file_name end
        if (not file_name:find(constants.table.file.postfix, -5)) then file_name = file_name .. constants.table.file.postfix end


        local do_traverse; do_traverse = function(data, file_name, found_data, optionals)

            if (not optionals.full and type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

            if (depth.get() == 0) then
                helpers.write_file(file_name, "{")
            end
            if (constants.table.calls > 2 ^ 16) then return end
            constants.table.calls = constants.table.calls + 1

            depth.increment()
            if (data == nil or type(data) ~= "table") then return nil end
            if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

            local t = nil

            if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
                if (not found_data[data]) then found_data[data] = {} end
                found_data[data].depth = depth.get()
                t = {}

                for k, v in pairs(data) do
                    if (type(v) ~= "table") then
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": " .. serpent.block(v) .. ",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": " .. serpent.block(v), true)
                        end
                    else
                        local func; func = function (data, file_name, found_data, optionals)
                            if (not optionals.full and type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

                            if (constants.table.calls > 2 ^ 16) then return end
                            constants.table.calls = constants.table.calls + 1

                            local traversed_t = do_traverse(data, file_name, found_data, optionals)

                            if (traversed_t) then
                                for i, j in pairs(traversed_t) do
                                    if (type(j) ~= "table") then
                                        if (next(traversed_t, i)) then
                                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(i) .. "\": " .. serpent.block(j) .. ",", true)
                                        else
                                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(i) .. "\": " .. serpent.block(j), true)
                                        end
                                    else
                                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(i) .. "\" : {", true)
                                        depth.increment()
                                        func(j, file_name, found_data, optionals)
                                        depth.decrement()
                                        if (next(traversed_t, i)) then
                                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "},", true)
                                        else
                                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true)
                                        end
                                    end
                                end
                            end
                        end

                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": {", true)

                        func(v, file_name, found_data, optionals)

                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "},", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true)
                        end
                    end
                end
            else
                t = {}

                depth.increment()
                for k, v in pairs(data) do
                    if (type(v) ~= "table") then
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : " .. serpent.block(v) .. ",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : " .. serpent.block(v), true)
                        end
                    else
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : \"configurable-nukes_placeholder\",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : \"configurable-nukes_placeholder\"", true)
                        end
                    end
                end
                depth.decrement()
            end

            depth.decrement()
            if (depth.get() == 0) then helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true) end

            return t
        end
        return do_traverse(data, file_name, found_data, optionals)
    end,
}

function constants.get_mod_data(reindex, data)
    Log.debug("constants.get_mod_data")
    Log.info(reindex)

    if (type(reindex) ~= "boolean") then return end
    if (data and type(data) ~= "table") then return end

    local loading = data and data.on_load or not game or false

    if (not reindex) then
        if (storage.constants and storage.constants.mod_data) then
            constants.mod_data = storage.constants.mod_data
            return constants.mod_data
        elseif (constants.mod_data and table_size(constants.mod_data) > 0) then
            if (not loading) then
                if (not storage.constants) then storage.constants = {} end
                storage.constants.mod_data = constants.mod_data
            end
            return constants.mod_data
        end
    else
        Log.debug("Reindexing constants.mod_data")
        local mod_data = locals.get_mod_data()

        if (not loading) then
            if (not storage.constants) then storage.constants = {} end
            storage.constants.mod_data = mod_data
        end

        return mod_data
    end
end

function constants.get_planets(reindex)
    Log.debug("constants.get_planets")
    Log.info(reindex)

    if (not reindex and storage.constants and storage.constants.planets) then
        constants.planet = storage.constants.planet
        return constants.planet
    elseif (not reindex and constants.planet and #constants.planet > 0) then
        if (not storage.constants) then storage.constants = {} end
        storage.constants.planet = constants.planet
        return constants.planet
    end

    Log.debug("Reindexing constants.planets")
    if (not storage.constants) then storage.constants = {} end
    storage.constants.planet = locals.get_planets()
    return storage.constants.planet
end

function constants.get_space_locations(reindex)
    Log.debug("constants.get_space_locations")
    Log.info(reindex)

    if (not reindex and storage.constants and storage.constants["space-location"]) then
        constants["space-location"] = storage.constants["space-location"]
        return constants["space-location"]
    elseif (not reindex and constants["space-location"] and #constants["space-location"] > 0) then
        if (not storage.constants) then storage.constants = {} end
        storage.constants["space-location"] = constants["space-location"]
        return constants["space-location"]
    end

    Log.debug("Reindexing constants.planets")
    if (not storage.constants) then storage.constants = {} end
    storage.constants["space-location"] = locals.get_space_locations()
    return storage.constants["space-location"]
end

function constants.get_space_connections(reindex)
    Log.debug("constants.get_space_connections")
    Log.info(reindex)

    if (not reindex and storage.constants and storage.constants["space-connection"]) then
        constants["space-connection"] = storage.constants["space-connection"]
        return constants["space-connection"]
    elseif (not reindex and constants["space-connection"] and #constants["space-connection"] > 0) then
        if (not storage.constants) then storage.constants = {} end
        storage.constants["space-connection"] = constants["space-connection"]
        return constants["space-connection"]
    end

    Log.debug("Reindexing constants.planets")
    if (not storage.constants) then storage.constants = {} end
    storage.constants["space-connection"] = locals.get_space_connections()
    return storage.constants["space-connection"]
end

function constants.get_space_exploration_universe(reindex)
    Log.debug("constants.get_space_exploration_universe")
    Log.info(reindex)

    if (not reindex and storage.constants and storage.constants["space-exploration"]) then
        constants["space-exploration"] = storage.constants["space-exploration"]
        return constants["space-exploration"]
    elseif (not reindex and constants["space-exploration"] and #constants["space-exploration"] > 0) then
        if (not storage.constants) then storage.constants = {} end
        storage.constants["space-exploration"] = constants["space-exploration"]
        return constants["space-exploration"]
    end

    Log.debug("Reindexing constants.planets")
    if (not storage.constants) then storage.constants = {} end
    storage.constants["space-exploration"] = locals.get_space_exploration_universe()
    return storage.constants["space-exploration"]
end

function constants.get_space_exploration_surfaces(reindex)
    Log.debug("constants.get_space_exploration_universe")
    Log.info(reindex)

    if (not reindex and constants["space-exploration"] and constants["space-exploration"].surfaces and table_size(constants["space-exploration"].surfaces) > 0) then
        return constants["space-exploration"].surfaces
    end

    Log.debug("Reindexing constants.surfaces")
    if (not storage.constants) then storage.constants = {} end
    storage.constants["space-exploration"] = locals.get_space_exploration_universe()
    return storage.constants["space-exploration"].surfaces
end

function constants.get_space_exploration_spaceships(reindex)
    Log.debug("constants.get_space_exploration_universe")
    Log.info(reindex)

    if (not reindex and constants["space-exploration"] and constants["space-exploration"].spaceships and table_size(constants["space-exploration"].spaceships) > 0) then
        return constants["space-exploration"].spaceships
    end

    Log.debug("Reindexing constants.spaceships")
    if (not storage.constants) then storage.constants = {} end
    storage.constants["space-exploration"] = locals.get_space_exploration_universe()
    return storage.constants["space-exploration"].spaceships
end

locals.get_mod_data = function(data)
    Log.debug("constants.locals.get_mod_data")

    if (data and type(data) ~= "table") then return end

    local loading = data and data.on_load or not game or false

    if (not loading) then
        constants.mod_data = default_mod_data()

        constants["planet"] = {}
        constants["space-location"] = {}
        constants["space-connection"] = {}

        local spaceships = constants["space-exploration"].spaceships
        constants["space-exploration"] = default_space_exploration()
        if (not constants["space-exploration"].spaceships) then constants["space-exploration"].spaceships = {} end
        constants["space-exploration"].spaceships = spaceships

        constants.mod_data_dictionary = {}
        constants.planets_dictionary = {}
        constants.space_locations_dictionary = {}
        constants.space_connections_dictionary = {}
        constants.space_exploration_dictionary = {}

        if (prototypes) then
            local mod_data_prototypes = prototypes.mod_data["configurable-nukes-mod-data"]

            if (mod_data_prototypes and type(mod_data_prototypes) == "table") then
                Log.debug("Found mod_data_prototypes")
            end
            Log.info(mod_data_prototypes)

            --{{ Planets }}
            for planet_name, planet_data in pairs(mod_data_prototypes.data["planet"]) do
                if (not String_Utils.find_invalid_substrings(planet_name)
                        and planet_data and type(planet_data) == "table")
                then
                    Log.debug("Found valid planet")
                    Log.info(planet_data)
                    if (planet_name and game) then
                        local planet_surface = game.get_surface(planet_name)

                        -- Surface can be nil
                        -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                        local new_planet_data = Planet_Data:new({
                            type = planet_data.type,
                            name = planet_name,
                            surface = planet_surface,
                            surface_index = planet_surface and planet_surface.valid and planet_surface.index or -1,
                            magnitude = planet_data.magnitude,

                            gravity_pull = planet_data.gravity_pull,
                            orientation = planet_data.orientation,
                            star_distance = planet_data.star_distance,

                            ["space-connection"] = planet_data["space-connection"],

                            x = planet_data.x,
                            y = planet_data.y,

                            valid = true,
                        })

                        Log.debug("Adding planet")
                        Log.info(new_planet_data)
                        if (new_planet_data.surface and new_planet_data.surface.valid) then
                            table.insert(constants.mod_data["planet"], new_planet_data)
                            table.insert(constants["planet"], new_planet_data)
                        end
                        constants.mod_data_dictionary[planet_name] = new_planet_data
                        constants.planets_dictionary[planet_name] = new_planet_data
                    end
                end
            end

            --[[ Space Locations ]]
            for name, space_location_data in pairs(mod_data_prototypes.data["space-location"]) do
                if (not String_Utils.find_invalid_substrings(name)
                    and space_location_data and type(space_location_data) == "table")
                then
                    Log.debug("Found valid space-location")
                    Log.info(space_location_data)
                    if (name and game) then
                        local surface = game.get_surface(name)

                        -- Surface can be nil
                        -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                        local new_space_location_data = Space_Location_Data:new({
                            name = name,
                            type = space_location_data.type,
                            surface = surface,
                            surface_index = surface and surface.valid and surface.index or -1,
                            magnitude = space_location_data.magnitude,

                            gravity_pull = space_location_data.gravity_pull,
                            orientation = space_location_data.orientation,
                            star_distance = space_location_data.star_distance,

                            ["space-connection"] = space_location_data["space-connection"],

                            x = space_location_data.x,
                            y = space_location_data.y,

                            valid = true,
                        })

                        Log.debug("Adding planet")
                        Log.info(new_space_location_data)
                        table.insert(constants.mod_data["space-location"], new_space_location_data)
                        table.insert(constants["space-location"], new_space_location_data)
                        constants.mod_data_dictionary[name] = new_space_location_data
                        constants.space_locations_dictionary[name] = new_space_location_data
                    end
                end
            end

            --[[ Space Connections ]]
            for name, space_connection_data in pairs(mod_data_prototypes.data["space-connection"]) do
                if (not String_Utils.find_invalid_substrings(name)
                    and space_connection_data and type(space_connection_data) == "table")
                then
                    Log.debug("Found valid space-connection")
                    Log.info(space_connection_data)
                    if (name and game) then
                        local surface = game.get_surface(name)

                        -- Surface can be nil
                        -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                        local new_space_connection_data = Space_Connection_Data:new({
                            name = name,
                            type = space_connection_data.type,

                            from = space_connection_data.from,
                            to = space_connection_data.to,
                            length = space_connection_data.length,
                            reversed = space_connection_data.reversed,

                            valid = true,
                        })

                        Log.debug("Adding planet")
                        Log.info(new_space_connection_data)
                        table.insert(constants.mod_data["space-connection"], new_space_connection_data)
                        table.insert(constants["space-connection"], new_space_connection_data)
                        constants.mod_data_dictionary[name] = new_space_connection_data
                        constants.space_connections_dictionary[name] = new_space_connection_data
                    end
                end
            end

            if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
                locals.get_space_exploration_universe()
            end
        end

        if (not storage.constants) then storage.constants = {} end
        storage.constants.mod_data = constants.mod_data
        storage.constants.mod_data_dictionary = constants.mod_data_dictionary
        storage.constants.mod_data["planet"] = constants.mod_data["planet"]
        storage.constants.mod_data["space-connection"] = constants.mod_data["space-connection"]
        storage.constants.mod_data["space-location"] = constants.mod_data["space-location"]
        storage.constants.planets_dictionary = constants.planets_dictionary
        storage.constants.space_locations_dictionary = constants.space_locations_dictionary
        storage.constants.space_connections_dictionary = constants.space_connections_dictionary

        if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
            storage.constants.mod_data["space-exploration"] = constants.mod_data["space-exploration"]
            storage.constants["space-exploration"] = constants["space-exploration"]
            storage.constants.space_exploration_dictionary = constants.space_exploration_dictionary
        end
    else
        --[[ Called during the on_load event
            -> No access to "game" object
            -> Read-only access to storage

            Trying to reestablish references to existing data in storage.
            Should hopefully help alleviate some of the lag/lag spikes that
            occur on load - particularly when loading Space Exploration.
        ]]
        if (storage.constants) then
            constants.mod_data = storage.constants.mod_data
            constants.mod_data_dictionary = storage.constants.mod_data_dictionary

            constants.planets_dictionary = storage.constants.planets_dictionary
            constants.space_locations_dictionary = storage.constants.space_locations_dictionary
            constants.space_connections_dictionary = storage.constants.space_connections_dictionary

            if (not constants.mod_data) then constants.mod_data = {} end
            constants.mod_data["planet"] = storage.constants.mod_data["planet"]
            constants.mod_data["space-connection"] = storage.constants.mod_data["space-connection"]
            constants.mod_data["space-location"] = storage.constants.mod_data["space-location"]

            if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
                if (not constants.mod_data["space-exploration"]) then constants.mod_data["space-exploration"] = {} end
                constants.mod_data["space-exploration"] = storage.constants.mod_data["space-exploration"]
                constants["space-exploration"] = storage.constants["space-exploration"]
                constants.space_exploration_dictionary = storage.constants.space_exploration_dictionary
            end
        end
    end

    return constants.mod_data
end

locals.get_planets = function(data)
    Log.debug("constants.locals.get_planets")

    constants.mod_data["planet"] = {}
    constants["planet"] = {}
    constants.planet_dictionary = {}

    if (prototypes) then
        local planet_prototypes = prototypes.mod_data["configurable-nukes-mod-data"]

        if (planet_prototypes and type(planet_prototypes) == "table") then
            Log.debug("Found planet prototypes")
        end
        Log.info(planet_prototypes)

        for planet_name, planet_data in pairs(planet_prototypes.data["planet"]) do
            if (not String_Utils.find_invalid_substrings(planet_name)
                    and planet_data and type(planet_data) == "table")
            then
                Log.debug("Found valid planet")
                Log.info(planet_data)
                if (planet_name and game) then
                    local planet_surface = game.get_surface(planet_name)

                    -- Surface can be nil
                    -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                    local new_planet_data = Planet_Data:new({
                        name = planet_name,
                        surface = planet_surface,
                        surface_index = planet_surface and planet_surface.valid and planet_surface.index or -1,
                        magnitude = planet_data.magnitude,

                        gravity_pull = planet_data.gravity_pull,
                        orientation = planet_data.orientation,
                        star_distance = planet_data.star_distance,

                        ["space-connection"] = planet_data["space-connection"],

                        x = planet_data.x,
                        y = planet_data.y,

                        valid = true,
                    })

                    Log.debug("Adding planet")
                    Log.info(new_planet_data)
                    if (new_planet_data.surface and new_planet_data.surface.valid) then
                        table.insert(constants.mod_data["planet"], new_planet_data)
                        table.insert(constants["planet"], new_planet_data)
                    end

                    constants.mod_data_dictionary[planet_name] = new_planet_data
                    constants.planets_dictionary[planet_name] = new_planet_data
                end
            end
        end
    end

    if (not storage.constants) then storage.constants = {} end
    if (not storage.constants.mod_data) then storage.constants.mod_data = constants.mod_data end
    if (not storage.constants.mod_data_dictionary) then storage.constants.mod_data_dictionary = constants.mod_data_dictionary end
    storage.constants.planet = constants.planet
    storage.constants.planets_dictionary = constants.planets_dictionary

    return constants.planet
end

locals.get_space_locations = function(data)
    Log.debug("constants.locals.get_space_locations")

    constants.mod_data["space-location"] = {}
    constants["space-location"] = {}
    constants.space_locations_dictionary = {}

    if (prototypes) then
        local mod_data_prototypes = prototypes.mod_data["configurable-nukes-mod-data"]

        if (mod_data_prototypes and type(mod_data_prototypes) == "table") then
            Log.debug("Found mod_data_prototypes")
        end
        Log.info(mod_data_prototypes)

        --[[ Space Locations ]]
        for name, space_location_data in pairs(mod_data_prototypes.data["space-location"]) do
            if (not String_Utils.find_invalid_substrings(name)
                and space_location_data and type(space_location_data) == "table")
            then
                Log.debug("Found valid space-location")
                Log.info(space_location_data)
                if (name and game) then
                    local surface = game.get_surface(name)

                    -- Surface can be nil
                    -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                    local new_space_location_data = Space_Location_Data:new({
                        name = name,
                        type = space_location_data.type,
                        surface = surface,
                        surface_index = surface and surface.valid and surface.index or -1,
                        magnitude = space_location_data.magnitude,

                        gravity_pull = space_location_data.gravity_pull,
                        orientation = space_location_data.orientation,
                        star_distance = space_location_data.star_distance,

                        ["space-connection"] = space_location_data["space-connection"],

                        x = space_location_data.x,
                        y = space_location_data.y,

                        valid = true,
                    })

                    Log.debug("Adding space-location")
                    Log.info(new_space_location_data)
                    table.insert(constants.mod_data["space-location"], new_space_location_data)
                    table.insert(constants["space-location"], new_space_location_data)

                    constants.mod_data_dictionary[name] = new_space_location_data
                    constants.space_locations_dictionary[name] = new_space_location_data
                end
            end
        end
    end

    if (not storage.constants) then storage.constants = {} end
    if (not storage.constants.mod_data) then storage.constants.mod_data = constants.mod_data end
    if (not storage.constants.mod_data_dictionary) then storage.constants.mod_data_dictionary = constants.mod_data_dictionary end
    storage.constants["space-location"] = constants["space-location"]
    storage.constants.space_locations_dictionary = constants.space_locations_dictionary

    return constants["space-location"]
end

locals.get_space_connections = function(data)
    Log.debug("constants.locals.get_mod_data")

    constants.mod_data["space-connection"] = {}
    constants["space-connection"] = {}
    constants.space_connections_dictionary = {}

    if (prototypes) then
        local mod_data_prototypes = prototypes.mod_data["configurable-nukes-mod-data"]

        if (mod_data_prototypes and type(mod_data_prototypes) == "table") then
            Log.debug("Found mod_data_prototypes")
        end
        Log.info(mod_data_prototypes)

        --[[ Space Connections ]]
        for name, space_connection_data in pairs(mod_data_prototypes.data["space-connection"]) do
            if (not String_Utils.find_invalid_substrings(name)
                and space_connection_data and type(space_connection_data) == "table")
            then
                Log.debug("Found valid space-connection")
                Log.info(space_connection_data)
                if (name and game) then
                    local surface = game.get_surface(name)

                    -- Surface can be nil
                    -- Trying to use on_surface_created event to add them to the appropriate planet after the fact
                    local new_space_connection_data = Space_Connection_Data:new({
                        name = name,
                        type = space_connection_data.type,

                        from = space_connection_data.from,
                        to = space_connection_data.to,
                        length = space_connection_data.length,
                        reversed = space_connection_data.reversed,

                        valid = true,
                    })

                    Log.debug("Adding space-connection")
                    Log.info(new_space_connection_data)
                    table.insert(constants.mod_data["space-connection"], new_space_connection_data)
                    table.insert(constants["space-connection"], new_space_connection_data)

                    constants.mod_data_dictionary[name] = new_space_connection_data
                    constants.space_connections_dictionary[name] = new_space_connection_data
                end
            end
        end
    end

    if (not storage.constants) then storage.constants = {} end
    if (not storage.constants.mod_data) then storage.constants.mod_data = constants.mod_data end
    if (not storage.constants.mod_data_dictionary) then storage.constants.mod_data_dictionary = constants.mod_data_dictionary end
    storage.constants["space-connection"] = constants["space-connection"]
    storage.constants.space_locations_dictionary = constants.space_connections_dictionary

    return constants["space-connection"]
end

locals.get_space_exploration_universe = function(data)
    Log.debug("locals.get_space_exploration_universe")

    constants.mod_data["space-exploration"] = default_mod_data()

    local spaceships = constants["space-exploration"].spaceships
    constants["space-exploration"] = default_space_exploration()
    if (not constants["space-exploration"].spaceships) then constants["space-exploration"].spaceships = {} end
    constants["space-exploration"].spaceships = spaceships

    constants.space_exploration_dictionary = {}

    local all_zones = remote.call("space-exploration", "get_zone_index", { force_name = "player" })

    local types = {}
    if (all_zones) then
        local parents = {}
        local children = {}
        local orbits = {}

        --[[ Creating base objects ]]
        for zone_index, zone in pairs(all_zones) do
            if (not types[zone.type]) then
                types[zone.type] = {}
            end
            table.insert(types[zone.type], zone_index)

            local zone_name = zone.name:lower()

            if (not String_Utils.find_invalid_substrings(zone_name)) then
                Log.debug("Found valid zone")
                Log.info(zone)

                if (zone_name and game) then
                    local zone_surface = game.get_surface(zone.name)
                    if (not zone_surface or not zone_surface.valid) then zone_surface = game.get_surface(zone_name) end

                    local space_location = Space_Location_Data:new({ default = true})
                    space_location.valid = nil
                    if (zone.type == "star") then
                        Log.debug("Found star")
                        children[zone.index] = zone.child_indexes

                        space_location = Star_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            -- zone = zone,
                            zone_index = zone.index,

                            orbit_index = zone.orbit_index,

                            child_indices = zone.child_indexes,

                            radius = zone.radius,
                            radius_multiplier = zone.radius_multiplier,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            special_type = zone.special_type,

                            x = zone.stellar_position.x,
                            y = zone.stellar_position.y,

                            valid = true,
                        })
                    elseif (zone.type == "planet") then
                        Log.debug("Found planet")
                        parents[zone.index] = zone.parent_index
                        children[zone.index] = zone.child_indexes
                        orbits[zone.index] = zone.orbit_index

                        space_location = Planet_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            zone = zone,
                            zone_index = zone.index,

                            orbit_index = zone.orbit_index,

                            parent_index = zone.parent_index,

                            child_indices = zone.child_indexes,

                            magnitude = zone.radius / 5000 --[[ Pretty sure this is approximately the default size for Nauvis.
                                                                TODO: Should probably get this programatically ]],

                            radius = zone.radius,
                            radius_multiplier = zone.radius_multiplier,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            special_type = zone.special_type,

                            space_exploration = script and script.active_mods and script.active_mods["space_exploration"] or true,

                            valid = true,
                        })
                    elseif (zone.type == "orbit") then
                        Log.debug("Found orbit")
                        parents[zone.index] = zone.parent_index

                        space_location = Orbit_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            -- zone = zone,
                            zone_index = zone.index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            parent_index = zone.parent_index,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            valid = true,
                        })
                    elseif (zone.type == "moon") then
                        Log.debug("Found moon")
                        parents[zone.index] = zone.parent_index
                        orbits[zone.index] = zone.orbit_index

                        space_location = Moon_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            zone = zone,
                            zone_index = zone.index,

                            orbit_index = zone.orbit_index,

                            parent_index = zone.parent_index,

                            children = zone.child_indexes,

                            magnitude = zone.radius / 5000 --[[ Pretty sure this is approximately the default size for Nauvis.
                                                                TODO: Should probably get this programatically ]],

                            radius = zone.radius,
                            radius_multiplier = zone.radius_multiplier,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            special_type = zone.special_type,

                            valid = true,
                        })
                    elseif (zone.type == "asteroid-belt") then
                        Log.debug("Found asteroid-belt")
                        parents[zone.index] = zone.parent_index

                        space_location = Asteroid_Belt_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            zone = zone,
                            zone_index = zone.index,

                            parent_index = zone.parent_index,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            valid = true,
                        })
                    elseif (zone.type == "asteroid-field") then
                        Log.debug("Found asteroid-field")
                        space_location = Asteroid_Field_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            zone = zone,
                            zone_index = zone.index,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            x = zone.stellar_position.x,
                            y = zone.stellar_position.y,

                            valid = true,
                        })
                    elseif (zone.type == "anomaly") then
                        Log.debug("Found anomaly")
                        space_location = Anomaly_Data:new({
                            name = zone_name,
                            seed = zone.seed,

                            hierarchy_index = zone.hierarchy_index,

                            planet_gravity_well = zone.planet_gravity_well or 0,
                            star_gravity_well = zone.star_gravity_well or 0,

                            zone = zone,
                            zone_index = zone.index,

                            surface = zone_surface,
                            surface_name = zone_surface and zone_surface.name,
                            surface_index = zone_surface and zone_surface.valid and zone_surface.index or -1,

                            valid = true,
                        })
                    elseif (zone.type == "spaceship") then
                        Log.error("Found a spaceship zone")
                        log(serpent.block(zone))
                        log(serpent.block(storage))
                        -- error("Got your attention: spaceship zone found")
                    else
                        log(serpent.block(zone))
                        log(serpent.block(storage))
                        -- error("Type does not exist in Constants.mod_data for type = " .. zone.type)
                    end

                    if (space_location.valid) then
                        Log.debug("Adding " .. space_location.type)
                        Log.info(space_location)
                        if (not constants.mod_data["space-exploration"][space_location.type]) then constants.mod_data["space-exploration"][space_location.type] = {} end
                        table.insert(constants.mod_data["space-exploration"][space_location.type], space_location)

                        if (not constants["space-exploration"][space_location.type]) then constants["space-exploration"][space_location.type] = {} end
                        table.insert(constants["space-exploration"][space_location.type], space_location)

                        if (space_location.surface and space_location.surface.valid) then
                            constants["space-exploration"].surfaces[space_location.name] = space_location
                        end

                        constants.mod_data_dictionary["se-" .. space_location.name] = space_location
                        constants.space_exploration_dictionary[space_location.name] = space_location
                    end
                end
            end
        end

        --[[ Connect parent relationships ]]
        for zone_index, zone_parent_index in pairs(parents) do
            constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_index].name)].parent = constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_parent_index].name)]
        end

        --[[ Connect children relationships ]]
        for zone_index, zone_children_indices in pairs(children) do
            for _, zone_child_index in pairs(zone_children_indices) do
                local zone = constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_index].name)]
                local child_zone = constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_child_index].name)]
                constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_index].name)].children[zone_child_index] = constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_child_index].name)]
                zone.children[zone_child_index] = child_zone

                constants.mod_data_dictionary["se-" .. string.lower(zone.name)] = zone
                constants.space_exploration_dictionary[string.lower(zone.name)] = zone
            end
        end

        --[[ Connect orbit relationships ]]
        for zone_index, zone_orbit_index in pairs(orbits) do
            constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_index].name)].orbit = constants.mod_data_dictionary["se-" .. string.lower(all_zones[zone_orbit_index].name)]
        end
    end

    -- log(serpent.block(types))
    -- for k, v in pairs(types) do
    --     log(serpent.block(k))
    -- end

    if (not storage.constants) then storage.constants = {} end
    if (not storage.constants.mod_data) then storage.constants.mod_data = constants.mod_data end
    storage.constants.mod_data_dictionary = constants.mod_data_dictionary
    storage.constants["space-exploration"] = constants["space-exploration"]
    storage.constants.space_exploration_dictionary = constants.space_exploration_dictionary

    return constants["space-exploration"]
end

return constants