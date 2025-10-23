-- If already defined, return
if _configurable_nukes_commands and _configurable_nukes_commands.configurable_nukes then
    return _configurable_nukes_commands
end

local Constants = require("scripts.constants.constants")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")

local locals = {}

local configurable_nukes_commands = {}

function configurable_nukes_commands.init(command)
    Log.debug("configurable_nukes_commands.init")
    locals.validate_command(command, function (player)
        Log.info("commands.init")
        player.print("Initializing anew")
        local maintain_data = true

        if (not (command.parameter == nil or type(command.parameter) ~= "string" and #(string.gsub(command.parameter, " ", "")) < 1)) then
            if (type(command.parameter) == "boolean") then
                maintain_data = command.parameter
            elseif (type(command.parameter == "string")) then
                if (command.parameter == "false") then
                    maintain_data = false
                else
                    maintain_data = true
                end
            end
        end

        Initialization.init({ maintain_data = maintain_data})
        player.print("Initialization complete")
    end)
end

function configurable_nukes_commands.reinit(command)
    Log.debug("configurable_nukes_commands.reinit")
    locals.validate_command(command, function (player)
        Log.info("commands.reinit")
        player.print("Reinitializing")
        local maintain_data = true

        if (not (command.parameter == nil or type(command.parameter) ~= "string" or #(string.gsub(command.parameter, " ", "")) < 1)) then
            if (type(command.parameter) == "boolean") then
                maintain_data = command.parameter
            elseif (type(command.parameter == "string")) then
                if (command.parameter == "false") then
                    maintain_data = false
                else
                    maintain_data = true
                end
            end
        end

        Initialization.reinit({ maintain_data = maintain_data})
        player.print("Reinitialization complete")
    end)
end

function configurable_nukes_commands.print_table(command)
    Log.debug("configurable_nukes_commands.print_storage")
    locals.validate_command(command, function (player)
        Log.info("commands.print_storage", true)

        if (command.parameter == nil or type(command.parameter) ~= "string" and #(string.gsub(command.parameter, " ", "")) > 0) then return end

        -- Find any passed parameters/flags
        --[[
            e.g.
            /configurable_nukes.print_table --depth=3 configurable_nukes.icbm_meta_data.nauvis
        ]]

        local parameter_string = command.parameter
        -- local max_depth = 2 ^ 8
        local max_depth = 1

        -- Should match, 2 dashes literals ('-'), 1 or more letters, '=', 1 or more digits, space character 0 or more times
        local i, j, param, param_val = parameter_string:find("%-%-(%a+)=(%d+)%s*", 1)

        while param ~= nil and param_val ~= nil do

            if (param:lower() == "depth" or param:lower() == "d") then max_depth = type(tonumber(param_val)) == "number" and tonumber(param_val) or 1 end

            parameter_string = parameter_string:sub(j + 1, #parameter_string)
            log(parameter_string)

            i, j, param, param_val = parameter_string:find("--(%a+)=(%d+)%s*", 1)
        end

        -- Get the table name(s)
        local t_name = parameter_string
        local t_parsed_name = { t = {}, a = {}, step = { t = {}, a = {}, }, reversed = { t = {}, a = {}, } }
        local i = 1
        local index = 0
        local r_index = 0
        local name = t_name
        local remainder = t_name
        local storage_prefix = false
        repeat
            local _i = t_name:find("%.", (index > 0 and index + 1 or 1)) or 0
            local r_i = t_name:reverse():find("%.", (r_index > 0 and r_index + 1 or 1)) or 0
            index = index + _i
            r_index = r_index + r_i

            name = remainder:sub(1, remainder:find("%.") and remainder:find("%.") - 1 or #remainder)
            remainder = remainder:sub(remainder:find("%.") and remainder:find("%.") + 1 or 1, #remainder)

            local current_name = t_name:sub(1, (_i - 1))
            local step_name = name
            local reversed_name = t_name:reverse():sub(1, (r_i - 1)):reverse()

            if (i == 1 and step_name == "storage") then storage_prefix = true end
            if (t_parsed_name.t[current_name] or t_parsed_name.reversed.t[reversed_name]) then break end
            t_parsed_name.t[current_name] = i
            t_parsed_name.a[i] = current_name
            if (storage_prefix) then
                t_parsed_name.step.t[step_name] = i - 1
                t_parsed_name.step.a[i - 1] = step_name
            else
                t_parsed_name.step.t[step_name] = i
                t_parsed_name.step.a[i] = step_name
            end
            t_parsed_name.reversed.t[reversed_name] = i
            t_parsed_name.reversed.a[i] = reversed_name

            i = i + 1
        until i > 2 ^ 6

        local t = { data = nil, name = t_name }


        local func; func = function (data)
            if (t_parsed_name.step.a[data.i] and t_parsed_name.step.t[t_parsed_name.step.a[data.i]]) then
                local name = data.t.a[data.i]
                if (data.table[name]) then
                    t.data = data.table[name]
                    t.name = data.name .. "." .. name
                    if (next(data.t.a, data.i)) then
                        func({ t = data.t, i = next(data.t.a, data.i), name = t.name, table = data.table[name] })
                    end
                end
            end
        end

        local depth = 1

        if (t_parsed_name.step.a[depth] and t_parsed_name.step.t[t_parsed_name.step.a[depth]]) then
            local name = t_parsed_name.step.a[depth]
            if (storage[name]) then
                t.data = storage[name]
                t.name = "storage." .. name
                if (next(t_parsed_name.step.a, depth)) then
                    func({ t = t_parsed_name.step, i = next(t_parsed_name.step.a, depth), name = "storage." .. name, table = storage[name] })
                end
            end
        end

        if (t.data == nil) then
            if (storage[t_name]) then
                if (type(storage[t_name]) == "table") then
                    t.data = { storage[t_name] }
                else
                    t.data = storage[t_name]
                end
                t.name = "storage." .. t_name
            else
                t = Constants.table.traverse_find(t_name, _, _, path, { parsed_name = t_parsed_name, max_depth = max_depth })
            end
        end

        if (t ~= nil and type(t) == "table") then
            if (t.data and type(t.data) == "table") then
                local file_name = t.name .. "_" .. game.tick
                Constants.table.traverse_print(t.data, file_name, _, { max_depth = max_depth })
                player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
            else
                player.print("Could not find table: " .. t.name)
            end
        else
            if (t) then
                player.print("Could not find table: " .. t.name)
            else
                player.print("Could not find table")
            end
        end
    end)
end

function configurable_nukes_commands.print_storage(command)
    Log.debug("configurable_nukes_commands.print_storage")
    locals.validate_command(command, function (player)
        Log.info("commands.print_storage")

        local file_name = "storage_" .. game.tick
        Constants.table.traverse_print(storage, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_mod_data(command)
    Log.debug("configurable_nukes_commands.print_mod_data")
    locals.validate_command(command, function (player)
        Log.info("commands.print_mod_data")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_mod_data(true)
        end

        local file_name = "Constants.mod_data_" .. game.tick
        Constants.table.traverse_print(Constants.mod_data, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_mod_data_dictionary(command)
    Log.debug("configurable_nukes_commands.print_mod_data_dictionary")
    locals.validate_command(command, function (player)
        Log.info("commands.print_mod_data_dictionary")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_mod_data(true)
        end

        local file_name = "Constants.mod_data_dictionary_" .. game.tick
        Constants.table.traverse_print(Constants.mod_data_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_planets(command)
    Log.debug("configurable_nukes_commands.print_planets")
    locals.validate_command(command, function (player)
        Log.info("commands.print_planets")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_planets(true)
        end

        local file_name = "Constants.planets_" .. game.tick
        Constants.table.traverse_print(Constants.get_planets(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_planets_dictionary(command)
    Log.debug("configurable_nukes_commands.print_planets_dictionary")
    locals.validate_command(command, function (player)
        Log.info("commands.print_planets_dictionary")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_planets(true)
        end

        local file_name = "Constants.planets_dictionary_" .. game.tick
        Constants.table.traverse_print(Constants.planets_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_locations(command)
    Log.debug("configurable_nukes_commands.print_space_locations")
    locals.validate_command(command, function (player)
        Log.info("commands.print_space_locations")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_space_locations(true)
        end

        local file_name = "Constants.space_locations_" .. game.tick
        Constants.table.traverse_print(Constants.get_space_locations(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_locations_dictionary(command)
    Log.debug("configurable_nukes_commands.print_space_locations_dictionary")
    locals.validate_command(command, function (player)
        Log.info("commands.print_space_locations_dictionary")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_space_locations(true)
        end

        local file_name = "Constants.space_locations_dictionary_" .. game.tick
        Constants.table.traverse_print(Constants.space_locations_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_connections(command)
    Log.debug("configurable_nukes_commands.print_space_connections")
    locals.validate_command(command, function (player)
        Log.info("commands.print_space_connections")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_space_connections(true)
        end

        local file_name = "Constants.space_connections_" .. game.tick
        Constants.table.traverse_print(Constants.get_space_connections(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_connections_dictionary(command)
    Log.debug("configurable_nukes_commands.print_space_connections_dictionary")
    locals.validate_command(command, function (player)
        Log.info("commands.print_space_connections_dictionary")

        if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
            Constants.get_space_connections(true)
        end

        local file_name = "Constants.space_connections_dictionary_" .. game.tick
        Constants.table.traverse_print(Constants.space_connections_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
    function configurable_nukes_commands.print_space_exploration_universe(command)
        Log.debug("configurable_nukes_commands.print_space_exploration_universe")
        locals.validate_command(command, function (player)
            Log.info("commands.print_space_exploration_universe")

            if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
                Constants.get_space_exploration_universe(true)
            end

            local file_name = "Constants.print_space_exploration_universe_" .. game.tick
            Constants.table.traverse_print(Constants.get_space_exploration_universe(), file_name, _, { full = true  })
            player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
        end)
    end

    function configurable_nukes_commands.print_space_exploration_dictionary(command)
        Log.debug("configurable_nukes_commands.print_space_exploration_dictionary")
        locals.validate_command(command, function (player)
            Log.info("commands.print_space_exploration_dictionary")

            if (command.parameter ~= nil and type(command.parameter) == "string" and (#string.gsub(command.parameter, " ", "") > 0)) then
                Constants.get_space_exploration_universe(true)
            end

            local file_name = "Constants.print_space_exploration_dictionary_" .. game.tick
            Constants.table.traverse_print(Constants.space_exploration_dictionary, file_name, _, { full = true  })
            player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
        end)
    end
end


function configurable_nukes_commands.print_event_handlers(command)
    Log.debug("configurable_nukes_commands.print_event_handlers")
    locals.validate_command(command, function (player)
        Log.info("commands.print_event_handlers")

        log(serpent.block(Event_Handler.event_names))
        log(serpent.block(Event_Handler.events))

        -- local file_name = "Constants.space_connections_" .. game.tick
        -- Constants.table.traverse_print(Constants.get_space_connections(), file_name, _, { full = true  })
        -- player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

locals.validate_command = function (command, fun)
    Log.debug("validate_command")
    Log.info(command)
    if (command) then
        local player_index = command.player_index

        local player = nil
        if (game and player_index > 0 and game.players) then
            -- player = game.players[player_index]
            player = game.get_player(player_index)
        end

        if (player) then
            fun(player)
        end
    end
end

commands.add_command("configurable_nukes.init", "Initialize from scratch. Will erase existing data.", configurable_nukes_commands.init)
commands.add_command("configurable_nukes.reinit", "Tries to reinitialize, attempting to preserve existing data.", configurable_nukes_commands.reinit)
commands.add_command("configurable_nukes.print_table", "", configurable_nukes_commands.print_table)
-- commands.add_command("configurable_nukes.print_event_handlers", "", configurable_nukes_commands.print_event_handlers)
commands.add_command("configurable_nukes.print_storage", "Exports to a .json file the underlying storage data.", configurable_nukes_commands.print_storage)
-- commands.add_command("configurable_nukes.print_mod_data", "Exports to a .json file the currently available mod-data.", configurable_nukes_commands.print_mod_data)
-- commands.add_command("configurable_nukes.print_mod_data_dictionary", "Exports to a .json file the mod-data dictionary.", configurable_nukes_commands.print_mod_data_dictionary)
-- commands.add_command("configurable_nukes.print_planets", "Exports to a .json file the currently available planet-data.", configurable_nukes_commands.print_planets)
-- commands.add_command("configurable_nukes.print_planets_dictionary", "Exports to a .json file the planet-data dictionary.", configurable_nukes_commands.print_planets_dictionary)
-- commands.add_command("configurable_nukes.print_space_locations", "Exports to a .json file the currently available space-location-data.", configurable_nukes_commands.print_space_locations)
-- commands.add_command("configurable_nukes.print_space_locations_dictionary", "Exports to a .json file the space-location-data dictionary.", configurable_nukes_commands.print_space_locations_dictionary)
-- commands.add_command("configurable_nukes.print_space_connections", "Exports to a .json file the currently available space-connection-data.", configurable_nukes_commands.print_space_connections)
-- commands.add_command("configurable_nukes.print_space_connections_dictionary", "Exports to a .json file the space-connection-data dictionary.", configurable_nukes_commands.print_space_connections_dictionary)
-- if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
--     commands.add_command("configurable_nukes.print_space_exploration_universe", "", configurable_nukes_commands.print_space_exploration_universe)
--     commands.add_command("configurable_nukes.print_space_exploration_dictionary", "", configurable_nukes_commands.print_space_exploration_dictionary)
-- end

configurable_nukes_commands.configurable_nukes = true

local _configurable_nukes_commands = configurable_nukes_commands

return configurable_nukes_commands