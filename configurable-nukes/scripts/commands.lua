local Core_Utils = require("__TheEckelmonster-core-library__.libs.utils.core-utils")

local Initialization = require("scripts.initialization")

local locals = {}

local configurable_nukes_commands = {}

function configurable_nukes_commands.init(event)
    Log.debug("configurable_nukes_commands.init")
    locals.validate_command(event, function (player)
        Log.info("commands.init")
        player.print("Initializing anew")
        local maintain_data = true

        if (not (event.parameter == nil or type(event.parameter) ~= "string" and #(string.gsub(event.parameter, " ", "")) < 1)) then
            if (type(event.parameter) == "boolean") then
                maintain_data = event.parameter
            elseif (type(event.parameter == "string")) then
                if (event.parameter == "false") then
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

function configurable_nukes_commands.reinit(event)
    Log.debug("configurable_nukes_commands.reinit")
    locals.validate_command(event, function (player)
        Log.info("commands.reinit")
        player.print("Reinitializing")
        local maintain_data = true

        if (not (event.parameter == nil or type(event.parameter) ~= "string" or #(string.gsub(event.parameter, " ", "")) < 1)) then
            if (type(event.parameter) == "boolean") then
                maintain_data = event.parameter
            elseif (type(event.parameter == "string")) then
                if (event.parameter == "false") then
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

function configurable_nukes_commands.print_table(event)
    Log.debug("configurable_nukes_commands.print_table")
    locals.validate_command(event, function (player)
        Log.info("commands.print_table")

        Core_Utils.commands.print_table({ player = player, event = event })
    end)
end

function configurable_nukes_commands.print_storage(event)
    Log.debug("configurable_nukes_commands.print_storage")
    locals.validate_command(event, function (player)
        Log.info("commands.print_storage")

        local file_name = "storage_" .. game.tick
        local exported_file_name = Core_Utils.table.traversal.traverse_print(storage, file_name, _, { max_depth = 4,  })
        player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
    end)
end

function configurable_nukes_commands.print_mod_data(event)
    Log.debug("configurable_nukes_commands.print_mod_data")
    locals.validate_command(event, function (player)
        Log.info("commands.print_mod_data")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_mod_data(true)
        end

        local file_name = "Constants.mod_data_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.mod_data, file_name, _, { max_depth = 4,  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_mod_data_dictionary(event)
    Log.debug("configurable_nukes_commands.print_mod_data_dictionary")
    locals.validate_command(event, function (player)
        Log.info("commands.print_mod_data_dictionary")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_mod_data(true)
        end

        local file_name = "Constants.mod_data_dictionary_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.mod_data_dictionary, file_name, _, { max_depth = 3,  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_planets(event)
    Log.debug("configurable_nukes_commands.print_planets")
    locals.validate_command(event, function (player)
        Log.info("commands.print_planets")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_planets(true)
        end

        local file_name = "Constants.planets_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.get_planets(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_planets_dictionary(event)
    Log.debug("configurable_nukes_commands.print_planets_dictionary")
    locals.validate_command(event, function (player)
        Log.info("commands.print_planets_dictionary")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_planets(true)
        end

        local file_name = "Constants.planets_dictionary_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.planets_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_locations(event)
    Log.debug("configurable_nukes_commands.print_space_locations")
    locals.validate_command(event, function (player)
        Log.info("commands.print_space_locations")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_space_locations(true)
        end

        local file_name = "Constants.space_locations_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.get_space_locations(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_locations_dictionary(event)
    Log.debug("configurable_nukes_commands.print_space_locations_dictionary")
    locals.validate_command(event, function (player)
        Log.info("commands.print_space_locations_dictionary")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_space_locations(true)
        end

        local file_name = "Constants.space_locations_dictionary_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.space_locations_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_connections(event)
    Log.debug("configurable_nukes_commands.print_space_connections")
    locals.validate_command(event, function (player)
        Log.info("commands.print_space_connections")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_space_connections(true)
        end

        local file_name = "Constants.space_connections_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.get_space_connections(), file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.print_space_connections_dictionary(event)
    Log.debug("configurable_nukes_commands.print_space_connections_dictionary")
    locals.validate_command(event, function (player)
        Log.info("commands.print_space_connections_dictionary")

        if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
            Constants.get_space_connections(true)
        end

        local file_name = "Constants.space_connections_dictionary_" .. game.tick
        Core_Utils.table.traversal.traverse_print(Constants.space_connections_dictionary, file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

if (mods and mods["space-exploration"] or script and script.active_mods and script.active_mods["space-exploration"]) then
    function configurable_nukes_commands.print_space_exploration_universe(event)
        Log.debug("configurable_nukes_commands.print_space_exploration_universe")
        locals.validate_command(event, function (player)
            Log.info("commands.print_space_exploration_universe")

            if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
                Constants.get_space_exploration_universe(true)
            end

            local file_name = "Constants.print_space_exploration_universe_" .. game.tick
            Core_Utils.table.traversal.traverse_print(Constants.get_space_exploration_universe(), file_name, _, { full = true  })
            player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
        end)
    end

    function configurable_nukes_commands.print_space_exploration_dictionary(event)
        Log.debug("configurable_nukes_commands.print_space_exploration_dictionary")
        locals.validate_command(event, function (player)
            Log.info("commands.print_space_exploration_dictionary")

            if (event.parameter ~= nil and type(event.parameter) == "string" and (#string.gsub(event.parameter, " ", "") > 0)) then
                Constants.get_space_exploration_universe(true)
            end

            local file_name = "Constants.print_space_exploration_dictionary_" .. game.tick
            Core_Utils.table.traversal.traverse_print(Constants.space_exploration_dictionary, file_name, _, { full = true  })
            player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
        end)
    end
end

function configurable_nukes_commands.print_event_handlers(event)
    Log.debug("configurable_nukes_commands.print_event_handlers")
    locals.validate_command(event, function (player)
        Log.info("commands.print_event_handlers")

        if (Event_Handler) then
            local file_name = "Event_Handler.event_names_" .. game.tick
            local exported_file_name = Core_Utils.table.traversal.traverse_print(Event_Handler.event_names, file_name, _, { full = true  })
            player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))

            file_name = "Event_Handler.events_" .. game.tick
            exported_file_name = Core_Utils.table.traversal.traverse_print(Event_Handler.events, file_name, _, { full = true  })
            player.print("Exported table to: ../Factorio/script-output/" .. tostring(exported_file_name))
        end
    end)
end

function configurable_nukes_commands.print_projectile_placeholders(event)
    Log.debug("configurable_nukes_commands.print_projectile_placeholders")
    locals.validate_command(event, function (player)
        Log.info("commands.print_projectile_placeholders")

        local file_name = "mod_data.configurable_nukes_projectile_placeholders_" .. game.tick
        Core_Utils.table.traversal.traverse_print(prototypes.mod_data[Constants.mod_name .. "-projectile-placeholder-data"], file_name, _, { full = true  })
        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
    end)
end

function configurable_nukes_commands.find_functions_in_storage(event)
    Log.debug("configurable_nukes_commands.find_functions_in_storage")
    locals.validate_command(event, function (player)
        Log.info("commands.find_functions_in_storage")


        local function find_functions(_tbl)

            local found = {}
            local depth, order = 0, 0

            local funcs_found = false

            local function r(tbl, depth, path)
                if (type(tbl) ~= "table") then return end
                depth = depth or 1
                path = path or "storage"

                for k, v in pairs(tbl) do
                    if (type(k) == "table") then
                        if (not found[k]) then
                            found[k] = { order = order, depth = depth, }
                            r(k, depth + 1)
                        end
                    elseif (type(k) == "function") then
                        local file_name = "" .. game.tick
                        Core_Utils.table.traversal.traverse_print(tbl, file_name, _, { full = true  })
                        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
                        funcs_found = true
                    else
                        log(serpent.line("traversing "..tostring(k)))
                    end

                    if (type(v) == "table") then
                        if (not found[v]) then
                            found[v] = { order = order, depth = depth, }
                            r(v, depth + 1)
                        end
                    elseif (type(v) == "function") then
                        local file_name = "" .. game.tick
                        Core_Utils.table.traversal.traverse_print(tbl, file_name, _, { full = true  })
                        player.print("Exported table to file: ../Factorio/script-output/" .. file_name)
                        funcs_found = true
                    else
                        log(serpent.line("traversing "..tostring(v)))
                    end
                end
            end

            r(_tbl)

            if (funcs_found) then error("Found functions in storage") end
        end

        find_functions(storage)
    end)
end

function locals.validate_command(event, fun)
    Log.debug(event)
    if (event) then
        local player = nil

        if (game and event.player_index > 0 and game.players) then player = game.players[event.player_index] end
        if (player and player.valid) then fun(player) end
    end
end

--[[ TODO: Localise the command descriptions ]]
commands.add_command("configurable_nukes.init", "Initialize from scratch. Accepts a single parameter. Will erase existing data if said parameter is provided and equal to \"false\".", configurable_nukes_commands.init)
commands.add_command("configurable_nukes.reinit", "Tries to reinitialize, attempting to preserve existing data.", configurable_nukes_commands.reinit)
commands.add_command("configurable_nukes.print_table", "", configurable_nukes_commands.print_table)
commands.add_command("configurable_nukes.print_event_handlers", "", configurable_nukes_commands.print_event_handlers)
commands.add_command("configurable_nukes.print_storage", "", configurable_nukes_commands.print_storage)
-- commands.add_command("configurable_nukes.print_projectile_placeholders", "", configurable_nukes_commands.print_projectile_placeholders)
-- commands.add_command("configurable_nukes.find_functions_in_storage", "", configurable_nukes_commands.find_functions_in_storage)
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

Core_Utils.table.traversal.set_prefix({ prefix = Constants.mod_name })

return configurable_nukes_commands