local storage
local containers
local ordered_payloaders
local payloaders

local game
local create_inventory
local get_player

local Constants = Constants or require("scripts.constants.constants")

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.ordered_payloaders = storage.ordered_payloaders or {}
    ordered_payloaders = storage.ordered_payloaders

    storage.containers = storage.containers or {}
    containers = storage.containers

    storage.payloaders = storage.payloaders or {}
    payloaders = storage.payloaders

    game = __game or _ENV.game
    create_inventory = game.create_inventory
    get_player = game.get_player

    return game
end

local defines = defines
local prototypes = prototypes

local math = math
local math_ceil = math.ceil
local math_floor = math.floor
local table = table
local table_insert = table.insert
local table_remove = table.remove
local type = type

local string = string
local string_format = string.format

local defines_payload_vehicle_inventory = defines.inventory.cn_payload_vehicle
local payloader_container_inventory = defines.inventory.payloader
local payloader_inventory_input = defines.inventory.crafter_input
local payloader_inventory_output = defines.inventory.crafter_output

local entity_status_no_recipe = defines.entity_status.no_recipe

local Event_Handler = Event_Handler
local Filters = Filters
local Log = Log

-- local Payloader_Data = Circuit_Network_Payloader_Data or require("scripts.data.circuit-network.payloader-data")

local String_Utils = require("scripts.utils.string-utils")

local AMMO = "ammo"
local CAPSULE = "capsule"
local CN_PAYLOAD_VEHICLE = "cn-payload-vehicle"
local CONTAINER = "container"
local EXPLOSIVES = "explosives"
local GREATER_THAN_EQUAL_TO = ">="
local INPUT = "input"
local ITEM_WITH_INVENTORY = "item-with-inventory"
local LAND_MINE = "land-mine"
local LAUNCH = "launch"
local NORMAL = "normal"
local OUTPUT = "output"
local PAYLOADER = "payloader"
local PAYLOADER_CONTAINER_INPUT  = "payloader-container-input"
local PAYLOADER_CONTAINER_OUTPUT = "payloader-container-output"
local PAYLOADER_CONTAINER_INPUT_VERTICAL  = "payloader-container-input-vertical"
local PAYLOADER_CONTAINER_OUTPUT_VERTICAL = "payloader-container-output-vertical"
local PAYLOADER_LOAD = "payloader-load"
local PAYLOADER_UNLOAD = "payloader-unload"
local SIGNAL_CHECK = "signal-check"
local SIGNAL_X = "signal-X"
local SIGNAL_Y = "signal-Y"
local SIGNAL_I = "signal-I"
local SPACE_LOCATION_INDEX = "space_location_index"
local TARGET_COMBINATOR = "target-combinator"
local TARGET_COMBINATOR_PROGRAM = "target-combinator-program"
local TARGET_TAGS = "target_tags"
local TARGET_TAGS_FORMAT = "X: %d, Y: %d, I: %d"
local VERTICAL = "-vertical"
local VIRTUAL = "virtual"
local X = "x"
local Y = "y"

local NTH_TICK = 60

local mod_data = prototypes.mod_data
local payloader_recipe_data = mod_data[Constants.mod_name .. "-payloader-recipe-data"].data

local payloader_load_recipe_crafting_time = payloader_recipe_data.recipes[PAYLOADER_LOAD].energy_required
local payloader_load_recipe_crafting_time_60 = payloader_load_recipe_crafting_time * NTH_TICK
local payloader_unload_recipe_crafting_time = payloader_recipe_data.recipes[PAYLOADER_UNLOAD].energy_required
local payloader_unload_recipe_crafting_time_60 = payloader_unload_recipe_crafting_time * NTH_TICK
local target_combinator_program_recipe_crafting_time = payloader_recipe_data.recipes[TARGET_COMBINATOR_PROGRAM].energy_required
local target_combinator_program_recipe_crafting_time_60 = target_combinator_program_recipe_crafting_time * NTH_TICK

local land_mine_names = payloader_recipe_data[LAND_MINE]

local Payloader_Data = Circuit_Network_Payloader_Data

local circuit_networks = {
    defines.wire_connector_id.circuit_red,
    defines.wire_connector_id.circuit_green,
}

-------------------------------

local valid_payloader_types = {
    [AMMO] = 1,
    [CAPSULE] = 1,
}
local valid_payloader_items = {
    [EXPLOSIVES] = 1,
}

for name, _ in pairs(land_mine_names) do
    valid_payloader_items[name] = 1
end

local valid_payloader_recipes = {
    [PAYLOADER_LOAD] = 1,
    [PAYLOADER_UNLOAD] = 1,
    [TARGET_COMBINATOR_PROGRAM] = 1,
}
local entity_output_recipes = {
    [TARGET_COMBINATOR_PROGRAM] = 1,
}
local item_output_recipes = {
    [PAYLOADER_UNLOAD] = 1,
    [TARGET_COMBINATOR] = 1,
}

-------------------------------

local payloader_load_ingredient_filters = {}
local payloader_load_ingredient_amounts = {}

local payloader_load_recipe = prototypes.recipe[PAYLOADER_LOAD]
if (payloader_load_recipe.ingredients[1]) then
    for _, ingredient in ipairs(payloader_load_recipe.ingredients) do
        payloader_load_ingredient_filters[#payloader_load_ingredient_filters+1] = { name = ingredient.name, quality = NORMAL, comparator = GREATER_THAN_EQUAL_TO, }
        payloader_load_ingredient_amounts[ingredient.name] = ingredient.amount
    end
end

local num_payloader_load_ingredients = #payloader_load_ingredient_filters

local target_combinator_program_ingredient_filters = {}
local target_combinator_program_ingredient_amounts = {}

local target_combinator_program_recipe = prototypes.recipe[TARGET_COMBINATOR_PROGRAM]
if (target_combinator_program_recipe.ingredients[1]) then
    for _, ingredient in ipairs(target_combinator_program_recipe.ingredients) do
        target_combinator_program_ingredient_filters[#target_combinator_program_ingredient_filters+1] = { name = ingredient.name, quality = NORMAL, comparator = ">=", }
        target_combinator_program_ingredient_amounts[ingredient.name] = ingredient.amount
    end
end

local num_target_combinator_program_ingredients = #target_combinator_program_ingredient_filters

local locals = {}

local payloader_controller = {}
payloader_controller.name = "payloader_controller"
payloader_controller.set_game = set_game

payloader_controller.filter = Filters.payloader_controller

local valid_cloned = {
    [PAYLOADER_CONTAINER_INPUT] = true,
    [PAYLOADER_CONTAINER_OUTPUT] = true,
    [PAYLOADER_CONTAINER_INPUT_VERTICAL] = true,
    [PAYLOADER_CONTAINER_OUTPUT_VERTICAL] = true,
}

local NOT_PLUGGED_IN_ELECTRIC_NETWORK = defines.entity_status.not_plugged_in_electric_network
local NO_POWER = defines.entity_status.no_power
local LOW_POWER = defines.entity_status.low_power

local ENTITY_STATUS_NORMAL = defines.entity_status.normal

local power_statuses = {
    [NOT_PLUGGED_IN_ELECTRIC_NETWORK] = NOT_PLUGGED_IN_ELECTRIC_NETWORK,
    [NO_POWER] = NO_POWER,
    [LOW_POWER] = LOW_POWER,
}
local power_status = NOT_PLUGGED_IN_ELECTRIC_NETWORK
local function has_power(entity)
    if (entity and entity.valid) then
        if (not entity.is_connected_to_electric_network()) then return NOT_PLUGGED_IN_ELECTRIC_NETWORK end
        if (entity.energy <= 0) then return NO_POWER end
        if (entity.energy < entity.electric_buffer_size) then return LOW_POWER end

        return  ENTITY_STATUS_NORMAL
    end
end

function payloader_controller.on_entity_created(event)
    Log.debug("payloader_controller.on_entity_created")
    Log.info(event)

    if (not event) then return end
    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= PAYLOADER) then return end

    entity.active = false

    locals.create_payloader({ entity = entity, })
end
Event_Handler:register_events({
    {
        event_name = "on_built_entity",
        source_name = "payloader_controller.on_entity_created",
        func_name = "payloader_controller.on_entity_created",
        func = payloader_controller.on_entity_created,
        filter = payloader_controller.filter,
    },
    {
        event_name = "on_robot_built_entity",
        source_name = "payloader_controller.on_entity_created",
        func_name = "payloader_controller.on_entity_created",
        func = payloader_controller.on_entity_created,
        filter = payloader_controller.filter,
    },
    {
        event_name = "script_raised_built",
        source_name = "payloader_controller.on_entity_created",
        func_name = "payloader_controller.on_entity_created",
        func = payloader_controller.on_entity_created,
        filter = payloader_controller.filter,
    },
    {
        event_name = "script_raised_revive",
        source_name = "payloader_controller.on_entity_created",
        func_name = "payloader_controller.on_entity_created",
        func = payloader_controller.on_entity_created,
        filter = payloader_controller.filter,
    },
})

function payloader_controller.on_entity_mined(event)
    Log.debug("payloader_controller.on_entity_mined")
    Log.info(event)

    if (not event) then return end

    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= PAYLOADER) then return end

    payloaders = payloaders or set_game() and payloaders

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]
        payloaders[entity.unit_number] = nil

        if (    event.name
            and (
                    event.name == defines.events.on_player_mined_entity
                or  event.name == defines.events.on_robot_mined_entity
            )
        ) then
            local output_inventory = payloader.containers.output.entity.get_inventory(payloader_container_inventory)
            local input_inventory = payloader.containers.input.entity.get_inventory(payloader_container_inventory)
            local internal_inventory = payloader.internal_inventory

            if (not output_inventory or not output_inventory.valid or output_inventory.is_empty()) then output_inventory = nil end
            if (not input_inventory or not input_inventory.valid or input_inventory.is_empty()) then input_inventory = nil end
            if (not internal_inventory or not internal_inventory.valid or internal_inventory.is_empty()) then internal_inventory = nil end

            local player_inventory = nil
            if (event.player_index) then
                local player = (game or set_game()) and get_player(event.player_index)

                if (player and player.valid) then
                    player_inventory = player.get_main_inventory()
                    if (not player_inventory or not player_inventory.valid) then player_inventory = nil end
                end
            end

            if (output_inventory) then
                for i = 1, #output_inventory, 1 do
                    if (output_inventory[i] and output_inventory[i].valid) then
                        if (player_inventory and player_inventory.can_insert(output_inventory[i])) then
                            local inserted = player_inventory.insert(output_inventory[i])

                            if (output_inventory[i].valid_for_read) then
                                output_inventory.remove({
                                    name = output_inventory[i].name,
                                    count = inserted,
                                    quality = output_inventory[i].quality.name,
                                    health = output_inventory[i].health,
                                    tags = output_inventory[i].is_item_with_tags and output_inventory[i].tags or nil,
                                })
                            end
                        end
                    end
                end

                if (output_inventory.get_item_count() > 0) then
                    entity.surface.spill_inventory({
                        position = entity.position,
                        inventory = output_inventory,
                        force = entity.force,
                    })
                end
            end

            if (input_inventory) then
                for i = 1, #input_inventory, 1 do
                    if (input_inventory[i] and input_inventory[i].valid) then
                        if (player_inventory and player_inventory.can_insert(input_inventory[i])) then
                            local inserted = player_inventory.insert(input_inventory[i])

                            if (input_inventory[i].valid_for_read) then
                                input_inventory.remove({
                                    name = input_inventory[i].name,
                                    count = inserted,
                                    quality = input_inventory[i].quality.name,
                                    health = input_inventory[i].health,
                                    tags = input_inventory[i].is_item_with_tags and input_inventory[i].tags or nil,
                                })
                            end
                        end

                    end
                end

                if (input_inventory.get_item_count() > 0) then
                    entity.surface.spill_inventory({
                        position = entity.position,
                        inventory = input_inventory,
                        force = entity.force,
                    })
                end
            end

            if (internal_inventory) then
                for i = 1, #internal_inventory, 1 do
                    if (internal_inventory[i] and internal_inventory[i].valid) then
                        if (player_inventory and player_inventory.can_insert(internal_inventory[i])) then
                            local inserted = player_inventory.insert(internal_inventory[i])

                            if (internal_inventory[i].valid_for_read) then
                                internal_inventory.remove({
                                    name = internal_inventory[i].name,
                                    count = inserted,
                                    quality = internal_inventory[i].quality.name,
                                    health = internal_inventory[i].health,
                                    tags = internal_inventory[i].is_item_with_tags and internal_inventory[i].tags or nil,
                                })
                            end
                        end

                    end
                end

                if (internal_inventory.get_item_count() > 0) then
                    entity.surface.spill_inventory({
                        position = entity.position,
                        inventory = internal_inventory,
                        force = entity.force,
                    })
                end
            end
        end

        payloader.containers.input.entity.destroy()
        payloader.containers.output.entity.destroy()

        payloader.internal_inventory.destroy()
    end
end
Event_Handler:register_events({
    {
        event_name = "on_entity_died",
        source_name = "payloader_controller.on_entity_mined",
        func_name = "payloader_controller.on_entity_mined",
        func = payloader_controller.on_entity_mined,
        filter = payloader_controller.filter,
    },
    {
        event_name = "on_player_mined_entity",
        source_name = "payloader_controller.on_entity_mined",
        func_name = "payloader_controller.on_entity_mined",
        func = payloader_controller.on_entity_mined,
        filter = payloader_controller.filter,
    },
    {
        event_name = "on_robot_mined_entity",
        source_name = "payloader_controller.on_entity_mined",
        func_name = "payloader_controller.on_entity_mined",
        func = payloader_controller.on_entity_mined,
        filter = payloader_controller.filter,
    },
    {
        event_name = "script_raised_destroy",
        source_name = "payloader_controller.on_entity_mined",
        func_name = "payloader_controller.on_entity_mined",
        func = payloader_controller.on_entity_mined,
    },
})

function payloader_controller.PickerDollies_event(event)
    Log.debug("payloader_controller.PickerDollies_event")
    Log.info(event)

    if (not event) then return end

    local moved_entity = event.moved_entity
    if (not moved_entity or not moved_entity.valid) then return end

    payloader_controller.on_player_rotated_entity({ entity = moved_entity, })
end
--[[ Registered in events.lua ]]

function payloader_controller.on_player_rotated_entity(event)
    Log.debug("payloader_controller.on_player_rotated_entity")
    Log.info(event)

    if (not event) then return end

    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= PAYLOADER) then return end

    payloaders = payloaders or set_game() and payloaders

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]
        local p_containers = payloader.containers

        local input_container = p_containers.input
        local output_container = p_containers.output

        local input_position = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
        local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

        local direction =       entity.orientation == 0   and 0
                            or  entity.orientation <  0.5 and 0.25
                            or  entity.orientation == 0.5 and 0.5
                            or  entity.orientation >  0.5 and 0.75
                            or  0

        local input_name  = PAYLOADER_CONTAINER_INPUT
        local output_name = PAYLOADER_CONTAINER_OUTPUT

        if (direction == 0.0 or direction == 0.5) then
            if (entity.mirroring) then direction = 0.5 - direction end

            if (direction == 0.5) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end

            payloader.horizontal = true
        elseif (direction == 0.25 or direction == 0.75) then
            input_name = input_name .. VERTICAL
            output_name = output_name .. VERTICAL

            input_position = { x = entity.position.x + 0.5, y = entity.position.y + 0.25, }
            output_position = { x = entity.position.x - 1.5, y = entity.position.y - 0.25, }

            if (entity.mirroring) then direction = 1 - direction end

            if (direction == 0.75) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end

            payloader.horizontal = false
        end

        local new_input_container = entity.surface.create_entity({
            force = entity.force,
            name = input_name,
            position = input_position,
            create_build_effect_smoke = false,
        })
        p_containers[INPUT] = {
            entity = new_input_container,
            unit_number = new_input_container.unit_number
        }

        if (input_container.entity and input_container.entity.valid) then
            local input_inventory = input_container.entity.get_inventory(payloader_container_inventory)
            if (input_inventory and input_inventory.valid) then
                local new_input_inventory = new_input_container.get_inventory(payloader_container_inventory)
                if (new_input_inventory and new_input_inventory.valid) then
                    for i = 1, 2, 1 do
                        local item_stack = input_inventory[i]
                        if (item_stack and item_stack.valid) then
                            if (new_input_inventory.can_insert(item_stack)) then
                                new_input_inventory.insert(item_stack)
                            end
                        end
                    end
                end
            end
            local target_wire_connectors = nil
            for connector_id, wire_connector in ipairs(input_container.entity.get_wire_connectors() or {}) do
                target_wire_connectors = target_wire_connectors or new_input_container.get_wire_connectors(true)
                local connections, connection = wire_connector.real_connections, nil
                local connect_to = target_wire_connectors[connector_id] and target_wire_connectors[connector_id].connect_to or nil
                for i = 1, wire_connector.real_connection_count, 1 do
                    connection = connections[1]
                    if (connection and connect_to) then
                        connect_to(connection.target, false)
                    end
                end
            end
        end

        local new_output_container = entity.surface.create_entity({
            force = entity.force,
            name = output_name,
            position = output_position,
            create_build_effect_smoke = false,
        })
        p_containers[OUTPUT] = {
            entity = new_output_container,
            unit_number = new_output_container.unit_number
        }

        if (output_container.entity and output_container.entity.valid) then
            local output_inventory = output_container.entity.get_inventory(payloader_container_inventory)
            if (output_inventory and output_inventory.valid) then
                local new_output_inventory = new_output_container.get_inventory(payloader_container_inventory)
                if (new_output_inventory and new_output_inventory.valid) then
                    for i = 1, 2, 1 do
                        local item_stack = output_inventory[i]
                        if (item_stack and item_stack.valid) then
                            if (new_output_inventory.can_insert(item_stack)) then
                                new_output_inventory.insert(item_stack)
                            end
                        end
                    end
                end
            end
            local target_wire_connectors = nil
            for connector_id, wire_connector in ipairs(output_container.entity.get_wire_connectors() or {}) do
                target_wire_connectors = target_wire_connectors or new_output_container.get_wire_connectors(true)
                local connections, connection = wire_connector.real_connections, nil
                local connect_to = target_wire_connectors[connector_id] and target_wire_connectors[connector_id].connect_to or nil
                for i = 1, wire_connector.real_connection_count, 1 do
                    connection = connections[1]
                    if (connection and connect_to) then
                        connect_to(connection.target, false)
                    end
                end
            end
        end

        payloader.direction = direction

        input_container.entity.destroy()
        output_container.entity.destroy()
    end

end
Event_Handler:register_event({
    event_name = "on_player_rotated_entity",
    source_name = "payloader_controller.on_player_rotated_entity",
    func_name = "payloader_controller.on_player_rotated_entity",
    func = payloader_controller.on_player_rotated_entity,
})

function payloader_controller.on_player_flipped_entity(event)
    Log.debug("payloader_controller.on_player_flipped_entity")
    Log.info(event)

    if (not event) then return end

    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= PAYLOADER) then return end

    payloaders = payloaders or set_game() and payloaders

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]

        if (payloader.horizontal and event.horizontal or not payloader.horizontal and not event.horizontal) then return end

        local containers = payloader.containers

        local input_container = containers.input
        local output_container = containers.output

        local input_position = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
        local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

        local direction =       entity.orientation == 0   and 0
                            or  entity.orientation <  0.5 and 0.25
                            or  entity.orientation == 0.5 and 0.5
                            or  entity.orientation >  0.5 and 0.75
                            or  0

        local input_name  = PAYLOADER_CONTAINER_INPUT
        local output_name = PAYLOADER_CONTAINER_OUTPUT

        if (direction == 0 or direction == 0.5) then
            if (direction == 0.5) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end
        elseif (direction == 0.25 or direction == 0.75) then
            input_name = input_name .. VERTICAL
            output_name = output_name .. VERTICAL

            input_position = { x = entity.position.x + 0.5, y = entity.position.y + 0.25, }
            output_position = { x = entity.position.x - 1.5, y = entity.position.y - 0.25, }

            if (direction == 0.75) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end
        end

        payloader.direction = direction

        if (    (direction == 0 or direction == 0.5)
            and not event.horizontal
            or
                (direction == 0.25 or direction == 0.75)
            and event.horizontal
        ) then
            local new_input_container = entity.surface.create_entity({
                force = entity.force,
                name = input_name,
                position = input_position,
                create_build_effect_smoke = false,
            })
            payloader.containers[INPUT] = {
                entity = new_input_container,
                unit_number = new_input_container.unit_number
            }

            if (input_container.entity and input_container.entity.valid) then
                local input_inventory = input_container.entity.get_inventory(payloader_container_inventory)
                if (input_inventory and input_inventory.valid) then
                    local new_input_inventory = new_input_container.get_inventory(payloader_container_inventory)
                    if (new_input_inventory and new_input_inventory.valid) then
                        for i = 1, 2, 1 do
                            local item_stack = input_inventory[i]
                            if (item_stack and item_stack.valid) then
                                if (new_input_inventory.can_insert(item_stack)) then
                                    new_input_inventory.insert(item_stack)
                                end
                            end
                        end
                    end
                end
                local target_wire_connectors = nil
                for connector_id, wire_connector in ipairs(input_container.entity.get_wire_connectors() or {}) do
                    target_wire_connectors = target_wire_connectors or new_input_container.get_wire_connectors(true)
                    local connections, connection = wire_connector.real_connections, nil
                    local connect_to = target_wire_connectors[connector_id] and target_wire_connectors[connector_id].connect_to or nil
                    for i = 1, wire_connector.real_connection_count, 1 do
                        connection = connections[1]
                        if (connection and connect_to) then
                            connect_to(connection.target, false)
                        end
                    end
                end
            end

            local new_output_container = entity.surface.create_entity({
                force = entity.force,
                name = output_name,
                position = output_position,
                create_build_effect_smoke = false,
            })
            payloader.containers[OUTPUT] = {
                entity = new_output_container,
                unit_number = new_output_container.unit_number
            }

            if (output_container.entity and output_container.entity.valid) then
                if (output_container.entity and output_container.entity.valid) then
                    local output_inventory = output_container.entity.get_inventory(payloader_container_inventory)
                    if (output_inventory and output_inventory.valid) then
                        local new_output_inventory = new_output_container.get_inventory(payloader_container_inventory)
                        if (new_output_inventory and new_output_inventory.valid) then
                            for i = 1, 2, 1 do
                                local item_stack = output_inventory[i]
                                if (item_stack and item_stack.valid) then
                                    if (new_output_inventory.can_insert(item_stack)) then
                                        new_output_inventory.insert(item_stack)
                                    end
                                end
                            end
                        end
                    end
                end
                local target_wire_connectors = nil
                for connector_id, wire_connector in ipairs(output_container.entity.get_wire_connectors() or {}) do
                    target_wire_connectors = target_wire_connectors or new_output_container.get_wire_connectors(true)
                    local connections, connection = wire_connector.real_connections, nil
                    local connect_to = target_wire_connectors[connector_id] and target_wire_connectors[connector_id].connect_to or nil
                    for i = 1, wire_connector.real_connection_count, 1 do
                        connection = connections[1]
                        if (connection and connect_to) then
                            connect_to(connection.target, false)
                        end
                    end
                end
            end

            input_container.entity.destroy()
            output_container.entity.destroy()
        end
    end
end
Event_Handler:register_event({
    event_name = "on_player_flipped_entity",
    source_name = "payloader_controller.on_player_flipped_entity",
    func_name = "payloader_controller.on_player_flipped_entity",
    func = payloader_controller.on_player_flipped_entity,
})

function payloader_controller.on_entity_cloned(event)
    Log.debug("payloader_controller.on_entity_cloned")
    Log.info(event)

    if (not event) then return end
    if (not event.source or not event.source.valid or (event.source.name ~= PAYLOADER and not valid_cloned[event.source.name])) then return end
    if (not event.destination or not event.destination.valid or (event.destination.name ~= PAYLOADER and not valid_cloned[event.destination.name])) then return end

    local source = event.source
    if (not source.surface or not source.surface.valid) then return end

    local source_surface = source.surface
    if (String_Utils.find_invalid_substrings(source_surface.name)) then return end

    local destination = event.destination
    if (not destination.surface or not destination.surface.valid) then return end

    local destination_surface = destination.surface
    if (String_Utils.find_invalid_substrings(destination_surface.name)) then return end

    payloaders = payloaders or set_game() and payloaders

    if (source.name == PAYLOADER and payloaders[source.unit_number]) then
        local source_payloader = payloaders[source.unit_number]
        local old_input_container = source_payloader.containers.input
        local old_output_container = source_payloader.containers.output

        local input_container_entities = destination_surface.find_entities_filtered({
            area = {{ destination.position.x - 1.5, destination.position.y - 1.5, }, { destination.position.x + 1.5, destination.position.y + 1.5, }},
            type = CONTAINER,
            name = { PAYLOADER_CONTAINER_INPUT, PAYLOADER_CONTAINER_INPUT_VERTICAL, }
        })

        local output_container_entities = destination_surface.find_entities_filtered({
            area = {{ destination.position.x - 1.5, destination.position.y - 1.5, }, { destination.position.x + 1.5, destination.position.y + 1.5, }},
            type = CONTAINER,
            name = { PAYLOADER_CONTAINER_OUTPUT, PAYLOADER_CONTAINER_OUTPUT_VERTICAL, }
        })

        locals.create_payloader({
            entity = destination,
            input_container_entity = input_container_entities and input_container_entities[1] or nil,
            output_container_entity = output_container_entities and output_container_entities[1] or nil,
            internal_inventory = source_payloader.internal_inventory,
        })

        old_input_container.entity.destroy()
        old_output_container.entity.destroy()
        payloaders[source.unit_number] = nil
    end
end
Event_Handler:register_event({
    event_name = "on_entity_cloned",
    source_name = "payloader_controller.on_entity_cloned",
    func_name = "payloader_controller.on_entity_cloned",
    func = payloader_controller.on_entity_cloned,
    filter = payloader_controller.filter,
})

function payloader_controller.on_tick(event)
    -- Log.debug("payloader_controller.on_tick")
    -- Log.info(event)

    local tick = event.tick
    ordered_payloaders = ordered_payloaders or set_game() and ordered_payloaders
    if (not ordered_payloaders[tick % NTH_TICK]) then return end
    if (not ordered_payloaders[tick % NTH_TICK][1]) then
        ordered_payloaders[tick % NTH_TICK] = nil
        return
    end
    local payloaders = ordered_payloaders[tick % NTH_TICK]
    local payloader = nil
    for idx = 1, #payloaders, 1 do
        payloader = payloaders[idx]
        if (not payloader) then goto continue end
        if (not payloader.entity.valid) then
            if (payloader.containers) then
                if (    payloader.containers.input
                    and payloader.containers.input.entity
                    and payloader.containers.input.entity.valid
                ) then
                    payloader.containers.input.entity.destroy({ raise_destroy = true })
                end

                if (    payloader.containers.output
                    and payloader.containers.output.entity
                    and payloader.containers.output.entity.valid
                ) then
                    payloader.containers.output.entity.destroy({ raise_destroy = true })
                end
            end

            table_remove(ordered_payloaders[tick % NTH_TICK], idx)
        else
            game = game or set_game()

            -- if (not has_power(payloader.entity)) then goto continue end
            -- if (power_statuses[has_power(payloader.entity)]) then goto continue end
            power_status = has_power(payloader.entity)

            if (payloader.activated) then
                -- if (power_statuses[power_status]) then
                --     goto continue
                -- if (payloader.entity.disabled_by_control_behavior) then
                if (power_statuses[power_status] or payloader.entity.disabled_by_control_behavior) then
                -- elseif (payloader.entity.disabled_by_control_behavior) then
                    payloader.disabled_by_control_behavior = payloader.disabled_by_control_behavior or tick
                    payloader.ticks_remaining = payloader.ticks_remaining or payloader.crafting_time - (payloader.disabled_by_control_behavior - payloader.activated)

                    if (not payloader.crafting_progress) then
                        payloader.crafting_progress = payloader.ticks_remaining / payloader.crafting_time
                        payloader.entity.crafting_progress = 1 - payloader.crafting_progress
                    end

                    payloader.to_finish_crafting = tick + payloader.ticks_remaining
                    goto continue
                else
                    if (payloader.disabled_by_control_behavior) then
                        payloader.entity.crafting_progress = 1 - (payloader.ticks_remaining > NTH_TICK and ((payloader.ticks_remaining - NTH_TICK) / payloader.crafting_time) or 0)

                        payloader.crafting_progress = nil
                        payloader.disabled_by_control_behavior = nil
                        payloader.ticks_remaining = nil
                    end
                end

                if (payloader.to_finish_crafting and tick >= payloader.to_finish_crafting) then
                    payloader.entity.active = false
                    payloader.entity.crafting_progress = 0
                    payloader.activated = nil
                    payloader.crafting_time = nil
                    payloader.processing = nil
                    payloader.crafting_progress = nil
                else
                    goto continue
                end
            end

            local input_container = payloader.containers.input
            local output_container = payloader.containers.output
            if (not input_container.entity.valid or not output_container.entity.valid) then
            else

                payloader.containers.input_inventory = payloader.containers.input_inventory or payloader.containers.input.entity.get_inventory(payloader_container_inventory)
                payloader.containers.output_inventory = payloader.containers.output_inventory or payloader.containers.output.entity.get_inventory(payloader_container_inventory)

                local input_inventory = payloader.containers.input_inventory
                local output_inventory = payloader.containers.output_inventory

                if (    not input_inventory
                    or  not input_inventory.valid
                ) then
                    payloader.containers.input_inventory = nil
                    goto continue
                elseif (not output_inventory
                    or  not output_inventory.valid
                ) then
                    payloader.containers.output_inventory = nil
                    goto continue
                end

                payloader.internal_inventory = payloader.internal_inventory or (game or set_game()) and create_inventory(1)
                local internal_inventory = payloader.internal_inventory
                if (not internal_inventory or not internal_inventory.valid) then
                    payloader.internal_inventory = nil
                    goto continue
                end

                input_inventory.set_filter(1, { name = CN_PAYLOAD_VEHICLE, quality = NORMAL, comparator = GREATER_THAN_EQUAL_TO, })

                -- if (power_statuses[power_status]) then goto continue end

                payloader.recipe_tick = payloader.recipe_tick or tick

                if (not payloader.recipe_name or payloader.recipe_tick < tick - 60) then
                    local payloader_recipe = payloader.entity.get_recipe()

                    if (not payloader_recipe or not payloader_recipe.valid or not valid_payloader_recipes[payloader_recipe.name]) then
                        payloader.recipe_name = nil
                        payloader.recipe_tick = tick
                        goto continue
                    else
                        payloader.recipe_name = payloader_recipe.name
                        payloader.recipe_tick = tick
                    end
                elseif (not payloader.recipe_name or not valid_payloader_recipes[payloader.recipe_name]) then
                    goto continue
                end
                local payloader_recipe_name = payloader.recipe_name

                if (payloader.transferred_to_interal and not internal_inventory.is_empty() and not payloader.entity.disabled_by_control_behavior) then
                    local internal_item_stack = internal_inventory[1]
                    local item_stack_output_container, empty_stack_idx = output_inventory.find_empty_stack()

                    local transferred_from_payload_vehicle = false

                    if (    internal_item_stack
                        and internal_item_stack.valid
                        and internal_item_stack.valid_for_read
                        and item_stack_output_container
                        and item_stack_output_container.valid
                    ) then
                        if (item_output_recipes[payloader_recipe_name] and internal_item_stack.is_item_with_inventory) then
                            local payload_vehicle_inventory = internal_item_stack.get_inventory(defines_payload_vehicle_inventory)
                            if (not payload_vehicle_inventory or not payload_vehicle_inventory.valid) then goto continue end
                            if (not payload_vehicle_inventory.is_empty()) then
                                local payload_vehicle_item_stack = payload_vehicle_inventory[#payload_vehicle_inventory - payload_vehicle_inventory.count_empty_stacks(true, true)]
                                if (not payload_vehicle_item_stack or not payload_vehicle_item_stack.valid) then goto continue end

                                if (item_stack_output_container.transfer_stack(payload_vehicle_item_stack, payload_vehicle_item_stack.count)) then
                                    transferred_from_payload_vehicle = true
                                else
                                    payloader.entity.active = false
                                    goto continue
                                end
                            end

                            item_stack_output_container = empty_stack_idx and (not transferred_from_payload_vehicle and output_inventory[empty_stack_idx] or empty_stack_idx < #output_inventory and output_inventory[empty_stack_idx + 1])
                            if (not item_stack_output_container or not item_stack_output_container.valid) then
                                payloader.entity.active = false
                                goto continue
                            end

                            if (item_stack_output_container.transfer_stack(internal_item_stack, internal_item_stack.count)) then
                                payloader.transferred_to_interal = nil
                            else
                                payloader.entity.active = false
                                goto continue
                            end
                        else
                            if (item_stack_output_container.transfer_stack(internal_item_stack, internal_item_stack.count)) then
                                payloader.transferred_to_interal = nil
                            else
                                payloader.entity.active = false
                                goto continue
                            end
                        end
                    end
                end

                payloader.entity_output_inventory = payloader.entity_output_inventory or payloader.entity.get_inventory(payloader_inventory_output)
                if (not payloader.entity_output_inventory or not payloader.entity_output_inventory.valid) then
                    payloader.entity_output_inventory = nil
                    goto continue
                end

                if (entity_output_recipes[payloader_recipe_name]) then
                    local entity_output_inventory = payloader.entity_output_inventory
                    if (not entity_output_inventory.is_empty()) then
                        local item_stack_output_entity_1 = entity_output_inventory[1]
                        local item_stack_output_entity_2 = entity_output_inventory[2]
                        local item_stack_output_container, empty_stack_idx = output_inventory.find_empty_stack()

                        if (    item_stack_output_entity_1
                            and item_stack_output_entity_1.valid
                            and item_stack_output_entity_1.valid_for_read
                            and item_stack_output_container
                            and item_stack_output_container.valid
                        ) then
                            if (not item_stack_output_container.transfer_stack(item_stack_output_entity_1, item_stack_output_entity_1.count)) then
                                payloader.entity.active = false
                                goto continue
                            end
                        end

                        item_stack_output_container = empty_stack_idx and (output_inventory[empty_stack_idx] or empty_stack_idx < #output_inventory and output_inventory[empty_stack_idx + 1])
                        if (not item_stack_output_container or not item_stack_output_container.valid) then
                            payloader.entity.active = false
                            goto continue
                        end

                        if (    item_stack_output_entity_2
                            and item_stack_output_entity_2.valid
                            and item_stack_output_entity_2.valid_for_read
                            and item_stack_output_container
                            and item_stack_output_container.valid
                        ) then
                            if (not item_stack_output_container.transfer_stack(item_stack_output_entity_2, item_stack_output_entity_2.count)) then
                                payloader.entity.active = false
                                goto continue
                            end
                        end
                    end
                end

                if (not input_inventory.is_empty() and internal_inventory.is_empty() and not payloader.entity.disabled_by_control_behavior) then
                    local item_stack_1 = input_inventory[1]
                    local item_stack_2 = input_inventory[2]
                    local internal_item_stack = internal_inventory[1]
                    if (not internal_item_stack or not internal_item_stack.valid) then goto continue end

                    local recipe_name = payloader_recipe_name or ""

                    if (    recipe_name == PAYLOADER_LOAD
                        and item_stack_1.valid
                        and item_stack_1.valid_for_read
                        and item_stack_2.valid
                        and item_stack_2.valid_for_read
                        or
                            recipe_name == PAYLOADER_UNLOAD
                        and (
                                item_stack_1.valid
                            and item_stack_1.valid_for_read
                            or
                                item_stack_2.valid
                            and item_stack_2.valid_for_read
                        )
                    ) then
                        local item_stacks = {}
                        if (recipe_name == PAYLOADER_LOAD) then
                            item_stacks = { item_stack_1, item_stack_2, }
                        elseif(recipe_name == PAYLOADER_UNLOAD) then
                            if (item_stack_1.valid and item_stack_1.valid_for_read) then
                                -- table_insert(item_stacks, item_stack_1)
                                item_stacks[#item_stacks+1] = item_stack_1
                            end

                            if (item_stack_2.valid and item_stack_2.valid_for_read) then
                                -- table_insert(item_stacks, item_stack_2)
                                item_stacks[#item_stacks+1] = item_stack_2
                            end
                        end

                        local stats = {
                            payload_vehicle = { full = false, empty = true, count = 0},
                        }
                        local item_stack_type = nil
                        for i, item_stack in ipairs(item_stacks) do
                            log(serpent.block(item_stack.type))
                            if (item_stack.type == ITEM_WITH_INVENTORY and item_stack.name == CN_PAYLOAD_VEHICLE) then
                                local payload_vehicle_inventory = item_stack.get_inventory(defines_payload_vehicle_inventory)
                                if (payload_vehicle_inventory and payload_vehicle_inventory.valid) then
                                    stats.payload_vehicle.count = stats.payload_vehicle.count + 1

                                    stats.payload_vehicle.empty = payload_vehicle_inventory.is_empty()
                                    stats.payload_vehicle.full  = payload_vehicle_inventory.is_full()

                                    if (stats.payload_vehicle.count == 1) then stats.payload_vehicle.item_stack = item_stack end
                                end
                            elseif (valid_payloader_types[item_stack.type] or valid_payloader_items[item_stack.name]) then
                                item_stack_type = item_stack.type
                                stats[item_stack_type] = stats[item_stack_type] or {}
                                stats[item_stack_type].item_stack = item_stack
                                stats[item_stack_type].valid = item_stack.valid and item_stack.valid_for_read
                            end
                        end

                        if (recipe_name == PAYLOADER_LOAD) then
                            if (    stats.payload_vehicle.count == 1
                                and stats.payload_vehicle.full == false
                                and stats[item_stack_type]
                                and stats[item_stack_type].valid
                            ) then
                                local payload_vehicle_item_stack = stats.payload_vehicle.item_stack
                                local payload_item_stack = stats[item_stack_type].item_stack

                                payloader.entity_input_inventory = payloader.entity_input_inventory or payloader.entity.get_inventory(payloader_inventory_input)
                                local entity_input_inventory = payloader.entity_input_inventory
                                if (not payloader.entity_input_inventory or not payloader.entity_input_inventory.valid) then
                                    payloader.entity_input_inventory = nil
                                    goto continue
                                end

                                if (    output_inventory
                                    and output_inventory.valid
                                    and entity_input_inventory
                                    and entity_input_inventory.valid
                                    and payload_vehicle_item_stack
                                    and payload_vehicle_item_stack.valid
                                ) then
                                    local payload_vehicle_item_inventory = payload_vehicle_item_stack.get_inventory(defines_payload_vehicle_inventory)
                                    local payload_vehicle_empty_stack = payload_vehicle_item_inventory.find_empty_stack()

                                    if (not payload_vehicle_empty_stack or not payload_vehicle_empty_stack.valid) then goto continue end

                                    if (    not payloader.processing
                                        and (
                                                num_payloader_load_ingredients == 0
                                            or
                                                (function (entity_input_inventory, payloader_load_ingredient_filters)
                                                    local ingredient = nil
                                                    for i = 1, num_payloader_load_ingredients, 1 do
                                                        ingredient = payloader_load_ingredient_filters[i]
                                                        if (not ingredient or not (entity_input_inventory.get_item_count(ingredient) >= (payloader_load_ingredient_amounts[ingredient.name] or 0))) then return end
                                                    end
                                                    return true
                                                end)(entity_input_inventory, payloader_load_ingredient_filters)
                                            )
                                        and payload_vehicle_item_inventory.can_insert(payload_item_stack)
                                        and (
                                                payload_vehicle_empty_stack.transfer_stack(payload_item_stack, payload_item_stack.count)
                                            or
                                                payload_vehicle_empty_stack.transfer_stack(payload_item_stack, payload_vehicle_item_inventory.get_insertable_count(payload_item_stack))
                                        )
                                        and internal_item_stack.transfer_stack(payload_vehicle_item_stack)
                                    ) then
                                        payloader.transferred_to_interal = true
                                        payloader.entity.active = true
                                        payloader.activated = tick
                                        payloader.to_finish_crafting = payloader.activated + (payloader_load_recipe_crafting_time_60) * (1 - payloader.entity.crafting_progress)
                                        payloader.crafting_time = payloader_load_recipe_crafting_time_60
                                        payloader.processing = true
                                        payloader.disabled_by_control_behavior = power_statuses[power_status] and tick or nil
                                    end
                                end
                            end
                        elseif (recipe_name == PAYLOADER_UNLOAD) then
                            if (    stats.payload_vehicle.count >= 1
                                and stats.payload_vehicle.empty == false
                            ) then
                                local payload_vehicle_item_stack = stats.payload_vehicle.item_stack

                                if (payload_vehicle_item_stack and payload_vehicle_item_stack.valid) then
                                    local payload_vehicle_item_inventory = payload_vehicle_item_stack.get_inventory(defines_payload_vehicle_inventory)
                                    if (payload_vehicle_item_inventory and payload_vehicle_item_inventory.valid) then
                                        payload_vehicle_item_inventory.sort_and_merge()

                                        if (    not payloader.processing
                                            and internal_item_stack.transfer_stack(payload_vehicle_item_stack, payload_vehicle_item_stack.count)
                                        ) then
                                            payloader.transferred_to_interal = true
                                            payloader.entity.active = true
                                            payloader.activated = tick
                                            payloader.to_finish_crafting = payloader.activated + (payloader_unload_recipe_crafting_time_60) * (1 - payloader.entity.crafting_progress)
                                            payloader.crafting_time = payloader_unload_recipe_crafting_time_60
                                            payloader.processing = true
                                            payloader.disabled_by_control_behavior = power_statuses[power_status] and tick or nil

                                            goto continue
                                        end
                                    end
                                end
                            end
                        end
                    elseif (
                            recipe_name == TARGET_COMBINATOR_PROGRAM
                        and item_stack_2
                        and item_stack_2.valid
                        and item_stack_2.valid_for_read
                    ) then
                        local signals = payloader.entity.get_signals(circuit_networks[1], circuit_networks[2])
                        local circuit_network_data = payloader.circuit_network_data or Payloader_Data:new({
                            unit_number = payloader.entity.unit_number,
                            surface_index = payloader.surface_index,
                            surface_name = payloader.entity.surface.name,
                            manual_entry = {
                                launch = 0,
                                x = 0,
                                y = 0,
                                space_location_index = payloader.surface_index,
                            },
                        })

                        local payloader_signals = {
                            [circuit_network_data.signals.launch.name] = LAUNCH,
                            [circuit_network_data.signals.x.name] = X,
                            [circuit_network_data.signals.y.name] = Y,
                            [circuit_network_data.signals.space_location_index.name] = SPACE_LOCATION_INDEX,
                        }

                        local signal = {
                            launch = nil,
                            x = nil,
                            y = nil,
                            space_location_index = nil,
                        }
                        if (    signals
                            and signals[1]
                            or
                                circuit_network_data.manual_entry
                            and (
                                    circuit_network_data.manual_entry.x
                                and circuit_network_data.manual_entry.x ~= 0
                                or
                                    circuit_network_data.manual_entry.y
                                and circuit_network_data.manual_entry.y ~= 0
                            )
                            and circuit_network_data.manual_entry.manually_entered
                        ) then
                            if (not signals or not signals[1]) then
                                signal = circuit_network_data.manual_entry
                            else
                                for i = 1, #signals, 1 do
                                    if (not signals[i]) then break end
                                    if (payloader_signals[signals[i].signal.name or ""]) then signal[payloader_signals[signals[i].signal.name]] = signals[i].count end
                                end
                            end

                            signal.space_location_index = signal.space_location_index or payloader.surface_index

                            if ((signal.x or signal.y) and signal.space_location_index) then
                                local entity_input_inventory = payloader.entity.get_inventory(payloader_inventory_input)

                                if (    output_inventory
                                    and output_inventory.valid
                                    and entity_input_inventory
                                    and entity_input_inventory.valid
                                    and item_stack_2
                                    and item_stack_2.valid
                                    and item_stack_2.is_item_with_tags
                                    and item_stack_2.prototype
                                    and item_stack_2.prototype.name == TARGET_COMBINATOR
                                    and internal_item_stack
                                    and internal_item_stack.valid
                                ) then
                                    if (    not payloader.processing
                                        and (
                                                num_target_combinator_program_ingredients == 0
                                            or
                                                (function (entity_input_inventory, target_combinator_program_ingredient_filters)
                                                    local ingredient = nil
                                                    for i = 1, num_target_combinator_program_ingredients, 1 do
                                                        ingredient = target_combinator_program_ingredient_filters[i]
                                                        if (not ingredient or not (entity_input_inventory.get_item_count(ingredient) >= (target_combinator_program_ingredient_amounts[ingredient.name] or 0))) then return end
                                                    end
                                                    return true
                                                end)(entity_input_inventory, target_combinator_program_ingredient_filters)
                                            )
                                        and internal_item_stack.transfer_stack(item_stack_2, item_stack_2.count)
                                    ) then
                                        local target_tags = internal_item_stack.get_tag(TARGET_TAGS) or {}
                                        local tag = {
                                                launch = { value = { type = VIRTUAL, name = SIGNAL_CHECK, quality = NORMAL, }, min = signal.launch, },
                                                x = { value = { type = VIRTUAL, name = SIGNAL_X, quality = NORMAL, }, min = signal.x, },
                                                y = { value = { type = VIRTUAL, name = SIGNAL_Y, quality = NORMAL, }, min = signal.y, },
                                                surface_index = { value = { type = VIRTUAL, name = SIGNAL_I, quality = NORMAL, }, min = signal.space_location_index or payloader.surface_index, },
                                        }
                                        target_tags[#target_tags+1] = tag
                                        local custom_description = string_format(TARGET_TAGS_FORMAT, tag.x.min or 0, tag.y.min or 0, tag.surface_index.min or payloader.surface_index)

                                        internal_item_stack.set_tag(TARGET_TAGS, target_tags)
                                        internal_item_stack.custom_description = custom_description

                                        payloader.transferred_to_interal = true
                                        payloader.entity.active = not output_inventory.is_full() and not internal_inventory.is_empty()
                                        if (payloader.entity.active) then
                                            payloader.activated = event.tick
                                            payloader.to_finish_crafting = payloader.activated + (target_combinator_program_recipe_crafting_time_60) * (1 - payloader.entity.crafting_progress)
                                            payloader.crafting_time = target_combinator_program_recipe_crafting_time_60
                                            payloader.processing = true
                                            payloader.disabled_by_control_behavior = power_statuses[power_status] and tick or nil
                                        else
                                            payloader.activated = nil
                                            payloader.crafting_time = nil
                                            payloader.processing = nil
                                        end
                                    else
                                        if (payloader.activated) then
                                            if (    payloader.crafting_time
                                                and event.tick - payloader.activated > payloader.crafting_time
                                                or
                                                    payloader.to_finish_crafting
                                                and payloader.to_finish_crafting >= event.tick
                                            ) then
                                                payloader.entity.active = false
                                                payloader.activated = nil
                                                payloader.crafting_time = nil
                                                payloader.processing = nil
                                            else
                                                payloader.processing = true
                                                payloader.disabled_by_control_behavior = power_statuses[power_status] and tick or nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif (input_inventory.is_empty() and internal_inventory.is_empty() and not payloader.entity.disabled_by_control_behavior) then
                    payloader.entity.active = false
                    payloader.entity.crafting_progress = 0
                    payloader.activated = nil
                    payloader.crafting_time = nil
                    payloader.processing = nil
                end
            end
        end
        ::continue::
    end
end
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "payloader_controller.on_tick",
    func_name = "payloader_controller.on_tick",
    func = payloader_controller.on_tick,
})

function locals.create_payloader(params)
    -- Log.debug("locals.create_payloader")
    -- Log.info(params)

    if (not params) then return end

    local entity = params.entity
    if (not entity or not entity.valid) then return end

    local input_container_entity = params.input_container_entity and params.input_container_entity.valid or nil
    local output_container_entity = params.output_container_entity and params.output_container_entity.valid or nil

    local payloader = {
        created = (game or set_game()).tick or 0,
        updated = (game or set_game()).tick or 0,
        entity = entity,
        position = entity.position,
        direction = 0,
        unit_number = entity.unit_number,
        -- force = entity.force,
        force_index = entity.force.index,
        -- surface = entity.surface,
        surface_index = entity.surface.index,
        surface_name = entity.surface.name,
        containers = {},
        horizontal = true,
        internal_inventory = params.internal_inventory or (game or set_game()) and create_inventory(1),
        circuit_network_data = Payloader_Data:new({
            unit_number = entity.unit_number,
            -- entity = entity,
            -- surface = entity.surface,
            surface_index = entity.surface.index,
            surface_name = entity.surface.name,
            manual_entry = {
                launch = 0,
                x = 0,
                y = 0,
                space_location_index = entity.surface.index,
            },
        }),
    }

    local input_position  = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
    local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

    local direction =       entity.orientation == 0   and 0
                        or  entity.orientation <  0.5 and 0.25
                        or  entity.orientation == 0.5 and 0.5
                        or  entity.orientation >  0.5 and 0.75
                        or  0

    local input_name = PAYLOADER_CONTAINER_INPUT
    local output_name = PAYLOADER_CONTAINER_OUTPUT

    if (direction == 0.5) then
        local temp = input_position
        input_position = output_position
        output_position = temp
    elseif (direction == 0.25 or direction == 0.75) then
        input_name = input_name .. VERTICAL
        output_name = output_name .. VERTICAL

        input_position = { x = entity.position.x + 0.5, y = entity.position.y + 0.25, }
        output_position = { x = entity.position.x - 1.5, y = entity.position.y - 0.25, }

        if (direction == 0.75) then
            local temp = input_position
            input_position = output_position
            output_position = temp
        end

        payloader.horizontal = false
    end

    payloaders = payloaders or set_game() and payloaders
    payloaders[payloader.unit_number] = payloader

    containers = containers or set_game() and containers

    input_container_entity = input_container_entity or entity.surface.create_entity({
        force = entity.force,
        name = input_name,
        position = input_position,
        create_build_effect_smoke = false,
    })
    payloader.containers[INPUT] = {
        entity = input_container_entity,
        unit_number = input_container_entity.unit_number,
        position = input_container_entity.position,
        force_index = input_container_entity.force.index,
        surface_index = input_container_entity.surface_index,
    }
    containers[input_container_entity.unit_number] = { input = true, payloader = payloader, }

    output_container_entity = output_container_entity or entity.surface.create_entity({
        force = entity.force,
        name = output_name,
        position = output_position,
        create_build_effect_smoke = false,
    })
    payloader.containers[OUTPUT] = {
        entity = output_container_entity,
        unit_number = output_container_entity.unit_number,
        position = output_container_entity.position,
        force_index = input_container_entity.force.index,
        surface_index = output_container_entity.surface_index,
    }
    containers[output_container_entity.unit_number] = { output = true, payloader = payloader, }

    ordered_payloaders[payloader.unit_number % NTH_TICK] = ordered_payloaders[payloader.unit_number % NTH_TICK] or {}
    table_insert(ordered_payloaders[payloader.unit_number % NTH_TICK], payloader)
end

function payloader_controller.init(__storage) storage = __storage or _ENV.storage end

return payloader_controller