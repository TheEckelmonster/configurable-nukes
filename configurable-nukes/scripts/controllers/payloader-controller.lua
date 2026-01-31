local String_Utils = require("scripts.utils.string-utils")

local locals = {}

local payloader_controller = {}
payloader_controller.name = "payloader_controller"

payloader_controller.filter = Filters.payloader_controller

local valid_cloned = {
    ["payloader-container-input"] = true,
    ["payloader-container-output"] = true,
    ["payloader-container-input-vertical"] = true,
    ["payloader-container-output-vertical"] = true,
}

function payloader_controller.on_entity_created(event)
    Log.debug("payloader_controller.on_entity_created")
    Log.info(event)

    if (not event) then return end
    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= "payloader") then return end

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
    if (entity.name ~= "payloader") then return end

    local payloaders = storage.payloaders or {}

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]
        payloaders[entity.unit_number] = nil

        if (    event.name
            and (
                    event.name == defines.events.on_player_mined_entity
                or  event.name == defines.events.on_robot_mined_entity
            )
        ) then
            local input_inventory = payloader.containers.input.entity.get_inventory(defines.inventory.payloader)
            local output_inventory = payloader.containers.output.entity.get_inventory(defines.inventory.payloader)

            if (not input_inventory or not input_inventory.valid or input_inventory.is_empty()) then input_inventory = nil end
            if (not output_inventory or not output_inventory.valid or output_inventory.is_empty()) then output_inventory = nil end

            local player_inventory = nil
            if (event.player_index) then
                local player = game.get_player(event.player_index)
                if (player and player.valid) then
                    player_inventory = player.get_main_inventory()
                    if (not player_inventory or not player_inventory.valid) then player_inventory = nil end
                end
            end

            if (output_inventory and not output_inventory.is_empty()) then
                for i = 1, #output_inventory, 1 do
                    if (output_inventory[i] and output_inventory[i].valid) then
                        if (player_inventory and player_inventory.can_insert(output_inventory[i])) then
                            local inserted = player_inventory.insert(output_inventory[i])

                            if (output_inventory[i].valid_for_read) then
                                output_inventory.remove({ name = output_inventory[i].name, count = inserted, quality = output_inventory[i].quality, })
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

            if (input_inventory and not input_inventory.is_empty()) then
                for i = 1, #input_inventory, 1 do
                    if (input_inventory[i] and input_inventory[i].valid) then
                        if (player_inventory and player_inventory.can_insert(input_inventory[i])) then
                            local inserted = player_inventory.insert(input_inventory[i])

                            if (input_inventory[i].valid_for_read) then
                                input_inventory.remove({ name = input_inventory[i].name, count = inserted, quality = input_inventory[i].quality, })
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
        end

        payloader.containers.input.entity.destroy()
        payloader.containers.output.entity.destroy()
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
})

function payloader_controller.on_player_rotated_entity(event)
    Log.debug("payloader_controller.on_player_rotated_entity")
    Log.info(event)

    if (not event) then return end

    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.name ~= "payloader") then return end

    local payloaders = storage.payloaders or {}

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]

        local input_container = payloader.containers.input
        local output_container = payloader.containers.output

        local input_position = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
        local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

        local direction =       entity.orientation == 0   and 0
                            or  entity.orientation <  0.5 and 0.25
                            or  entity.orientation == 0.5 and 0.5
                            or  entity.orientation >  0.5 and 0.75
                            or  0

        local input_name = "payloader-container-input"
        local output_name = "payloader-container-output"

        if (direction == 0.0 or direction == 0.5) then
            if (entity.mirroring) then direction = 0.5 - direction end

            if (direction == 0.5) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end

            payloader.horizontal = true
        elseif (direction == 0.25 or direction == 0.75) then
            input_name = input_name .. "-vertical"
            output_name = output_name .. "-vertical"

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
        payloader.containers["input"] = {
            entity = new_input_container,
            unit_number = new_input_container.unit_number
        }

        if (input_container.entity and input_container.entity.valid) then
            local input_inventory = input_container.entity.get_inventory(defines.inventory.payloader)
            if (input_inventory and input_inventory.valid) then
                local new_input_inventory = new_input_container.get_inventory(defines.inventory.payloader)
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
        end

        local new_output_container = entity.surface.create_entity({
            force = entity.force,
            name = output_name,
            position = output_position,
            create_build_effect_smoke = false,
        })
        payloader.containers["output"] = {
            entity = new_output_container,
            unit_number = new_output_container.unit_number
        }

        if (output_container.entity and output_container.entity.valid) then
            local output_inventory = output_container.entity.get_inventory(defines.inventory.payloader)
            if (output_inventory and output_inventory.valid) then
                local new_output_inventory = new_output_container.get_inventory(defines.inventory.payloader)
                if (new_output_inventory and new_output_inventory.valid) then
                    local item_stack = output_inventory[1]
                    if (item_stack and item_stack.valid) then
                        if (new_output_inventory.can_insert(item_stack)) then
                            new_output_inventory.insert(item_stack)
                        end
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
    if (entity.name ~= "payloader") then return end

    local payloaders = storage.payloaders or {}

    if (payloaders[entity.unit_number]) then
        local payloader = payloaders[entity.unit_number]

        if (payloader.horizontal and event.horizontal or not payloader.horizontal and not event.horizontal) then return end

        local input_container = payloader.containers.input
        local output_container = payloader.containers.output

        local input_position = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
        local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

        local direction =       entity.orientation == 0   and 0
                            or  entity.orientation <  0.5 and 0.25
                            or  entity.orientation == 0.5 and 0.5
                            or  entity.orientation >  0.5 and 0.75
                            or  0

        local input_name = "payloader-container-input"
        local output_name = "payloader-container-output"

        if (direction == 0 or direction == 0.5) then
            if (direction == 0.5) then
                local temp = input_position
                input_position = output_position
                output_position = temp
            end
        elseif (direction == 0.25 or direction == 0.75) then
            input_name = input_name .. "-vertical"
            output_name = output_name .. "-vertical"

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
            payloader.containers["input"] = {
                entity = new_input_container,
                unit_number = new_input_container.unit_number
            }

            local input_inventory = input_container.entity.get_inventory(defines.inventory.payloader)
            if (input_inventory and input_inventory.valid) then
                local new_input_inventory = new_input_container.get_inventory(defines.inventory.payloader)
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

            local new_output_container = entity.surface.create_entity({
                force = entity.force,
                name = output_name,
                position = output_position,
                create_build_effect_smoke = false,
            })
            payloader.containers["output"] = {
                entity = new_output_container,
                unit_number = new_output_container.unit_number
            }

            local output_inventory = output_container.entity.get_inventory(defines.inventory.payloader)
            if (output_inventory and output_inventory.valid) then
                local new_output_inventory = new_output_container.get_inventory(defines.inventory.payloader)
                if (new_output_inventory and new_output_inventory.valid) then
                    local item_stack = output_inventory[1]
                    if (item_stack and item_stack.valid) then
                        if (new_output_inventory.can_insert(item_stack)) then
                            new_output_inventory.insert(item_stack)
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

    log(serpent.block(event))

    if (not event) then return end
    if (not event.source or not event.source.valid or (event.source.name ~= "payloader" and not valid_cloned[event.source.name])) then return end
    if (not event.destination or not event.destination.valid or (event.destination.name ~= "payloader" and not valid_cloned[event.destination.name])) then return end

    local source = event.source
    if (not source.surface or not source.surface.valid) then return end

    local source_surface = source.surface
    if (String_Utils.find_invalid_substrings(source_surface.name)) then return end

    local destination = event.destination
    if (not destination.surface or not destination.surface.valid) then return end

    local destination_surface = destination.surface
    if (String_Utils.find_invalid_substrings(destination_surface.name)) then return end

    local payloaders = storage.payloaders or {}

    if (source.name == "payloader" and payloaders[source.unit_number]) then
        local old_input_container = payloaders[source.unit_number].containers.input
        local old_output_container = payloaders[source.unit_number].containers.output

        local input_container_entities = destination_surface.find_entities_filtered({
            area = {{ destination.position.x - 1.5, destination.position.y - 1.5, }, { destination.position.x + 1.5, destination.position.y + 1.5, }},
            type = "container",
            name = { "payloader-container-input", "payloader-container-input-vertical", }
        })

        local output_container_entities = destination_surface.find_entities_filtered({
            area = {{ destination.position.x - 1.5, destination.position.y - 1.5, }, { destination.position.x + 1.5, destination.position.y + 1.5, }},
            type = "container",
            name = { "payloader-container-output", "payloader-container-output-vertical", }
        })

        locals.create_payloader({
            entity = destination,
            input_container_entity = input_container_entities and input_container_entities[1] or nil,
            output_container_entity = output_container_entities and output_container_entities[1] or nil,
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

function payloader_controller.on_nth_tick(event)
    Log.debug("payloader_controller.on_nth_tick")
    Log.info(event)

    local payloaders = storage.payloaders or {}
    for unit_num_P, payloader in pairs(payloaders) do
        if (not payloader.entity.valid) then
            if (payloader.containers) then
                if (    payloader.containers.input
                    and payloader.containers.input.entity
                    and payloader.containers.input.entity.valid
                ) then
                    payloader.containers.input.entity.destroy()
                end

                if (    payloader.containers.output
                    and payloader.containers.output.entity
                    and payloader.containers.output.entity.valid
                ) then
                    payloader.containers.input.entity.destroy()
                end
            end

            payloaders[unit_num_P] = nil
        else
            if (payloader.entity.active and payloader.activated) then
                if (game.tick - payloader.activated > 60) then
                    payloader.entity.active = false
                end
            end

            local input_container = payloader.containers.input
            local output_container = payloader.containers.output
            if (not input_container.entity.valid or not output_container.entity.valid) then
            else
                local input_inventory = input_container.entity.get_inventory(defines.inventory.payloader)
                if (input_inventory and input_inventory.valid) then
                    input_inventory.set_filter(1, { name = "cn-payload-vehicle", quality = "normal", comparator = ">=", })

                    if (not input_inventory.is_empty()) then
                        local item_stack_1 = input_inventory[1]
                        local item_stack_2 = input_inventory[2]

                        local payloader_recipe = payloader.entity.get_recipe()
                        local recipe_name = ""
                        if (payloader_recipe and payloader_recipe.valid) then
                            recipe_name = payloader_recipe.name
                        end

                        if (    recipe_name == "payload-add"
                            and item_stack_1.valid
                            and item_stack_1.valid_for_read
                            and item_stack_2.valid
                            and item_stack_2.valid_for_read
                            or
                                recipe_name == "payload-remove"
                            and (
                                    item_stack_1.valid
                                and item_stack_1.valid_for_read
                                or
                                    item_stack_2.valid
                                and item_stack_2.valid_for_read
                            )
                        ) then
                            local item_stacks = {}
                            if (recipe_name == "payload-add") then
                                item_stacks = { item_stack_1, item_stack_2, }
                            elseif(recipe_name == "payload-remove") then
                                if (item_stack_1.valid and item_stack_1.valid_for_read) then
                                    table.insert(item_stacks, item_stack_1)
                                end

                                if (item_stack_2.valid and item_stack_2.valid_for_read) then
                                    table.insert(item_stacks, item_stack_2)
                                end
                            end

                            local stats = {
                                payload_vehicle = { full = false, empty = true, count = 0},
                                ammo = { count = 0, },
                                capsule = { count = 0, },
                            }
                            local type = nil
                            for i, item_stack in ipairs(item_stacks) do
                                if (item_stack.type == "item-with-inventory" and item_stack.name == "cn-payload-vehicle") then
                                    local item_stack_inventory = item_stack.get_inventory(defines.inventory.cn_payload_vehicle)
                                    if (item_stack_inventory and item_stack_inventory.valid) then
                                        stats.payload_vehicle.count = stats.payload_vehicle.count + 1

                                        if (not item_stack_inventory.is_empty()) then
                                            stats.payload_vehicle.empty = false
                                        end

                                        if (item_stack_inventory.is_full()) then
                                            stats.payload_vehicle.full = true
                                        end
                                        if (stats.payload_vehicle.count == 1) then
                                            stats.payload_vehicle.item_stack = item_stack
                                        end
                                    end
                                elseif (item_stack.type == "ammo" or item_stack.type == "capsule") then
                                    type = item_stack.type
                                    stats[item_stack.type].count = stats[item_stack.type].count + item_stack.count
                                    stats[item_stack.type].item_stack = item_stack
                                end
                            end

                            if (recipe_name == "payload-add") then
                                if (    stats.payload_vehicle.count == 1
                                    and stats.payload_vehicle.full == false
                                    and (type == "ammo" or type == "capsule")
                                    and (
                                            stats.ammo.count > 0
                                        and stats.capsule.count == 0
                                        or
                                            stats.capsule.count > 0
                                        and stats.ammo.count == 0
                                    )
                                ) then
                                    local payload_vehicle_item_stack = stats.payload_vehicle.item_stack
                                    local payload_item_stack = stats[type].item_stack

                                    local output_inventory = output_container.entity.get_inventory(defines.inventory.payloader)
                                    if (    output_inventory
                                        and output_inventory.valid
                                        and payload_vehicle_item_stack
                                        and payload_vehicle_item_stack.valid
                                    ) then
                                        if (output_inventory.can_insert(payload_vehicle_item_stack)) then
                                            local payload_vehicle_inventory = payload_vehicle_item_stack.get_inventory(defines.inventory.cn_payload_vehicle)
                                            if (payload_vehicle_inventory and payload_vehicle_inventory.valid) then
                                                if (payload_vehicle_inventory.can_insert(payload_item_stack)) then
                                                    if (payloader.entity.active) then
                                                        payloader.entity.active = false

                                                        local num_inserted = payload_vehicle_inventory.insert(payload_item_stack)
                                                        if (num_inserted > 0) then
                                                            local num_removed = input_inventory.remove({ name = payload_item_stack.name, count = num_inserted, quality = payload_item_stack.quality,  })

                                                            local count = output_inventory.insert(payload_vehicle_item_stack)
                                                            if (count > 0) then
                                                                local removed = input_inventory.remove(payload_vehicle_item_stack)
                                                            end
                                                        end

                                                        payloader.activated = nil
                                                    else
                                                        payloader.entity.active = true
                                                        payloader.activated = game.tick
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            elseif (recipe_name == "payload-remove") then
                                --[[ payload-remove ]]
                                if (    stats.payload_vehicle.count >= 1
                                    and stats.payload_vehicle.empty == false
                                ) then
                                    local payload_vehicle_item_stack = stats.payload_vehicle.item_stack

                                    if (payload_vehicle_item_stack and payload_vehicle_item_stack.valid) then
                                        local payload_vehicle_inventory = payload_vehicle_item_stack.get_inventory(defines.inventory.payloader)
                                        if (payload_vehicle_inventory and payload_vehicle_inventory.valid) then
                                            for i = #payload_vehicle_inventory, 1, -1 do
                                                local item_stack = payload_vehicle_inventory[i]
                                                if (item_stack and item_stack.valid and item_stack.count > 0) then
                                                    local output_inventory = output_container.entity.get_inventory(defines.inventory.payloader)
                                                    if (output_inventory and output_inventory.valid) then
                                                        if (output_inventory.is_empty()) then
                                                            if (payloader.entity.active) then
                                                                if (game.tick - payloader.activated >= 60) then
                                                                    payloader.entity.active = false
                                                                    local inserted = output_inventory.insert(item_stack)

                                                                    if (inserted > 0) then
                                                                        local removed = payload_vehicle_inventory.remove({ name = item_stack.name, count = inserted, quality = item_stack.quality, })
                                                                    end

                                                                    inserted = output_inventory.insert(payload_vehicle_item_stack)
                                                                    if (inserted > 0) then
                                                                        local removed = input_inventory.remove({ name = payload_vehicle_item_stack.name, coun = inserted, quality = payload_vehicle_item_stack.quality, })
                                                                    end

                                                                    payloader.activated = nil
                                                                    break
                                                                end
                                                            else
                                                                payloader.entity.active = true
                                                                payloader.activated = game.tick
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_nth_tick",
    -- nth_tick = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.PAYLOADER_UPDATE_RATE.name }) or 60,
    nth_tick = 60,
    source_name = "payloader_controller.on_nth_tick",
    func_name = "payloader_controller.on_nth_tick",
    func = payloader_controller.on_nth_tick,
})

function locals.create_payloader(params)
    Log.debug("locals.create_payloader")
    Log.info(params)

    if (not params) then return end

    local entity = params.entity
    if (not entity or not entity.valid) then return end

    local input_container_entity = nil
    local output_container_entity = nil

    if (params.input_container_entity and params.input_container_entity.valid) then input_container_entity = params.input_container_entity end
    if (params.output_container_entity and params.output_container_entity.valid) then output_container_entity = params.output_container_entity end

    local payloader = {
        created = game and game.tick or 0,
        updated = game and game.tick or 0,
        entity = entity,
        position = entity.position,
        direction = 0,
        unit_number = entity.unit_number,
        force = entity.force,
        force_index = entity.force.index,
        surface = entity.surface,
        surface_index = entity.surface.index,
        containers = {},
        horizontal = true,
    }

    local input_position = { x = entity.position.x - 0.25, y = entity.position.y - 1.5, }
    local output_position = { x = entity.position.x + 0.25, y = entity.position.y + 0.5, }

    local direction =       entity.orientation == 0   and 0
                        or  entity.orientation <  0.5 and 0.25
                        or  entity.orientation == 0.5 and 0.5
                        or  entity.orientation >  0.5 and 0.75
                        or  0

    local input_name = "payloader-container-input"
    local output_name = "payloader-container-output"

    if (direction == 0.5) then
        local temp = input_position
        input_position = output_position
        output_position = temp
    elseif (direction == 0.25 or direction == 0.75) then
        input_name = input_name .. "-vertical"
        output_name = output_name .. "-vertical"

        input_position = { x = entity.position.x + 0.5, y = entity.position.y + 0.25, }
        output_position = { x = entity.position.x - 1.5, y = entity.position.y - 0.25, }

        if (direction == 0.75) then
            local temp = input_position
            input_position = output_position
            output_position = temp
        end

        payloader.horizontal = false
    end

    storage.payloaders = storage.payloaders or {}
    storage.payloaders[payloader.unit_number] = payloader

    local containers = storage.containers or {}

    input_container_entity = input_container_entity or entity.surface.create_entity({
        force = entity.force,
        name = input_name,
        position = input_position,
        create_build_effect_smoke = false,
    })
    payloader.containers["input"] = {
        entity = input_container_entity,
        unit_number = input_container_entity.unit_number,
        position = input_container_entity.position,
        force = input_container_entity.force,
        force_index = input_container_entity.force.index,
        surface_index = input_container_entity.surface_index,
        surface = input_container_entity.surface,
    }
    containers[input_container_entity.unit_number] = { input = true, payloader = payloader, }

    output_container_entity = output_container_entity or entity.surface.create_entity({
        force = entity.force,
        name = output_name,
        position = output_position,
        create_build_effect_smoke = false,
    })
    payloader.containers["output"] = {
        entity = output_container_entity,
        unit_number = output_container_entity.unit_number,
        position = output_container_entity.position,
        force = output_container_entity.force,
        force_index = input_container_entity.force.index,
        surface_index = output_container_entity.surface_index,
        surface = output_container_entity.surface,
    }
    containers[output_container_entity.unit_number] = { output = true, payloader = payloader, }
end

return payloader_controller