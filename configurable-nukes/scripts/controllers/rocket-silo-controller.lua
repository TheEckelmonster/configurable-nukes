local storage

local string = string
local table = table

local defines = defines
local helpers = helpers
local prototypes = prototypes
local rendering = rendering
local script = script

local cargo_unit_inventory = defines.inventory.cargo_unit
local register_on_object_destroyed = script.register_on_object_destroyed
local string_format = string.format
local table_remove = table.remove
local table_size = table_size
local target_type_item = defines.target_type.item
local unclaimed_cargo_alert = defines.alert_type.unclaimed_cargo

local controller_types = {
    [defines.controllers.ghost]       = { name = "ghost",     type = defines.controllers.ghost,     },
    [defines.controllers.character]   = { name = "character", type = defines.controllers.character, },
    [defines.controllers.god]         = { name = "god",       type = defines.controllers.god,       },
    [defines.controllers.editor]      = { name = "editor",    type = defines.controllers.editor,    },
    [defines.controllers.cutscene]    = { name = "cutscene",  type = defines.controllers.cutscene,  },
    [defines.controllers.spectator]   = { name = "spectator", type = defines.controllers.spectator, },
    [defines.controllers.remote]      = { name = "remote",    type = defines.controllers.remote,    },
}

local controllers_with_inventories = {
    [defines.controllers.character] = { name = "character", type = defines.controllers.character, },
    [defines.controllers.god]       = { name = "god",       type = defines.controllers.god,       },
    [defines.controllers.editor]    = { name = "editor",    type = defines.controllers.editor,    },
}

local character_inventory = defines.inventory.character_main
local god_inventory = defines.inventory.god_main
local quality = prototypes.quality

local quality_array = {}

local qualities = {}
local highest_level = 0

for k, v in pairs(quality) do
    if (k ~= "quality-unknown" and not v.hidden) then
        qualities[v.level] = v
        if (v.level > highest_level) then highest_level = v.level end
    end
end

for i = 0, highest_level, 1 do
    if (qualities[i]) then
        quality_array[#quality_array+1] = { index = #quality_array+1, quality = qualities[i], }
        if (#quality_array >= table_size(qualities)) then break end
    end
end

local target_combinator_stack_size = prototypes.item["target-combinator"].stack_size

local type = type

local all_seeing_active = script and script.active_mods and script.active_mods["all-seeing-satellite"] and true

local Event_Handler = Event_Handler
local Log = Log

local Custom_Input = require("prototypes.custom-input.custom-input")

local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local ICBM_rocket_silo_cloned = ICBM_Utils.rocket_silo_cloned
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local rocket_silo_built = Rocket_Silo_Service.rocket_silo_built
local on_cargo_pod_finished_ascending = Rocket_Silo_Service.on_cargo_pod_finished_ascending
local RS_rocket_silo_cloned = Rocket_Silo_Service.rocket_silo_cloned
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Spaceship_Service = require("scripts.services.spaceship-service")
local SS_rocket_silo_cloned = Spaceship_Service.rocket_silo_cloned
local String_Utils = require("scripts.utils.string-utils")
local find_invalid_substrings = String_Utils.find_invalid_substrings

local default_filters = {
    ["signal-check"] = "launch",
    ["signal-X"] = "x",
    ["signal-Y"] = "y",
    ["signal-I"] = "surface_index",
}

local shorcut_names = {
    ["give-ICBM-remote"] = 1,
    ["show-processing-units-shortcut"] = 1,
    ["show-processing-units-custom-input"] = 1,
}

local rocket_silo_controller = {}
rocket_silo_controller.name = "rocket_silo_controller"

rocket_silo_controller.filter = Filters.rocket_silo_controller

function rocket_silo_controller.rocket_silo_built(event)
    -- Log.debug("rocket_silo_controller.rocket_silo_built")
    -- Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (rocket_silo.type ~= "rocket-silo") then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (find_invalid_substrings(surface.name)) then return end

    rocket_silo_built(rocket_silo)
end
Event_Handler:register_events({
    {
        event_name = "on_built_entity",
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
        filter = rocket_silo_controller.filter,
    },
    {
        event_name = "on_robot_built_entity",
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
        filter = rocket_silo_controller.filter,
    },
    {
        event_name = "script_raised_built",
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
        filter = rocket_silo_controller.filter,
    },
    {
        event_name = "script_raised_revive",
        source_name = "rocket_silo_controller.rocket_silo_built",
        func_name = "rocket_silo_controller.rocket_silo_built",
        func = rocket_silo_controller.rocket_silo_built,
        filter = rocket_silo_controller.filter,
    },
})

function rocket_silo_controller.rocket_silo_cloned(event)
    Log.debug("rocket_silo_controller.rocket_silo_cloned")
    Log.info(event)

    if (not event) then return end
    if (not event.source or not event.source.valid or event.source.type ~= "rocket-silo") then return end
    if (not event.destination or not event.destination.valid or event.destination.type ~= "rocket-silo") then return end

    local source_silo = event.source
    if (not source_silo.surface or not source_silo.surface.valid) then return end

    local source_surface = source_silo.surface
    if (String_Utils.find_invalid_substrings(source_surface.name)) then return end

    local destination_silo = event.destination
    if (not destination_silo.surface or not destination_silo.surface.valid) then return end
    Log.warn(destination_silo)

    local destination_surface = destination_silo.surface
    if (String_Utils.find_invalid_substrings(destination_surface.name)) then return end
    Log.warn(destination_surface)

    RS_rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    SS_rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    ICBM_rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    -- Rocket_Silo_Service.rocket_silo_mined({ entity = source_silo, })
    -- Rocket_Silo_Service.rocket_silo_built(destination_silo)
end
Event_Handler:register_event({
    event_name = "on_entity_cloned",
    source_name = "rocket_silo_controller.rocket_silo_cloned",
    func_name = "rocket_silo_controller.rocket_silo_cloned",
    func = rocket_silo_controller.rocket_silo_cloned,
    filter = rocket_silo_controller.filter,
})

function rocket_silo_controller.rocket_silo_mined(event)
    Log.debug("rocket_silo_controller.rocket_silo_mined")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (rocket_silo.type ~= "rocket-silo") then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_mined(event)
end
Event_Handler:register_events({
    {
        event_name = "on_entity_died",
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
        filter = rocket_silo_controller.filter,
    },
    {
        event_name = "on_player_mined_entity",
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
        filter = rocket_silo_controller.filter,
    },
    {
        event_name = "on_robot_mined_entity",
        source_name = "rocket_silo_controller.rocket_silo_mined",
        func_name = "rocket_silo_controller.rocket_silo_mined",
        func = rocket_silo_controller.rocket_silo_mined,
        filter = rocket_silo_controller.filter,
    },
})

function rocket_silo_controller.rocket_silo_mined_script(event)
    Log.debug("rocket_silo_controller.rocket_silo_mined_script")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (rocket_silo.type ~= "rocket-silo") then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_mined(event)
end
Event_Handler:register_event({
    event_name = "script_raised_destroy",
    source_name = "rocket_silo_controller.rocket_silo_mined_script",
    func_name = "rocket_silo_controller.rocket_silo_mined_script",
    func = rocket_silo_controller.rocket_silo_mined_script,
    filter = rocket_silo_controller.filter,
})

function rocket_silo_controller.scrub_newest_launch(event)
    Log.debug("rocket_silo_controller.scrub_newest_launch")
    Log.info(event)

    if (not event) then return end
    if (not event.input_name or event.input_name ~= Custom_Input.SCRUB_NEWEST_LAUNCH.name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    Rocket_Silo_Service.scrub_newest_launch({
        tick = event.tick,
        tick_event = event.tick,
        player_index = event.player_index,
        player = player,
    })
end
Event_Handler:register_event({
    event_name = Custom_Input.SCRUB_NEWEST_LAUNCH.name,
    source_name = "rocket_silo_controller.scrub_newest_launch",
    func_name = "rocket_silo_controller.scrub_newest_launch",
    func = rocket_silo_controller.scrub_newest_launch,
})

function rocket_silo_controller.scrub_oldest_launch(event)
    Log.debug("rocket_silo_controller.scrub_oldest_launch")
    Log.info(event)

    if (not event) then return end
    if (not event.input_name or event.input_name ~= Custom_Input.SCRUB_OLDEST_LAUNCH.name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    Rocket_Silo_Service.scrub_oldest_launch({
        tick = event.tick,
        tick_event = event.tick,
        player_index = event.player_index,
        player = player,
    })
end
Event_Handler:register_event({
    event_name = Custom_Input.SCRUB_OLDEST_LAUNCH.name,
    source_name = "rocket_silo_controller.scrub_oldest_launch",
    func_name = "rocket_silo_controller.scrub_oldest_launch",
    func = rocket_silo_controller.scrub_oldest_launch,
})

function rocket_silo_controller.scrub_all_launches(event)
    Log.debug("rocket_silo_controller.scrub_all_launches")
    Log.info(event)

    if (not event) then return end
    if (not event.input_name or event.input_name ~= Custom_Input.SCRUB_ALL_LAUNCHES.name) then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    Rocket_Silo_Service.scrub_all_launches({
        tick = event.tick,
        tick_event = event.tick,
        player_index = event.player_index,
        player = player,
    })
end
Event_Handler:register_event( {
    event_name = Custom_Input.SCRUB_ALL_LAUNCHES.name,
    source_name = "rocket_silo_controller.scrub_all_launches",
    func_name = "rocket_silo_controller.scrub_all_launches",
    func = rocket_silo_controller.scrub_all_launches,
})

function rocket_silo_controller.on_cargo_pod_delivered_cargo(event)
    -- log(serpent.block(event))
    -- log(serpent.block(event.cargo_pod))
    -- log(serpent.block(event.spawned_container))
    if (event.spawned_container and event.spawned_container.valid and event.spawned_container.get_inventory(cargo_unit_inventory)) then
        local inventory = event.spawned_container.get_inventory(cargo_unit_inventory)
        -- if (inventory and inventory.valid) then
        --     log(serpent.block(inventory.get_contents()))
        -- end

        local force = event.spawned_container.force
        if (force and force.valid) then
            for _, player in ipairs(force.connected_players) do
                if (player.valid) then
                    player.add_alert(event.spawned_container, unclaimed_cargo_alert)
                    player.add_pin({ label = "Recoverable Payload", surface = event.spawned_container.surface, position = event.spawned_container.position, preview_distance = 2 ^ 6 })
                end
            end
        end
    end
end
Event_Handler:register_event( {
    event_name = "on_cargo_pod_delivered_cargo",
    source_name = "rocket_silo_controller.on_cargo_pod_delivered_cargo",
    func_name = "rocket_silo_controller.on_cargo_pod_delivered_cargo",
    func = rocket_silo_controller.on_cargo_pod_delivered_cargo,
})

function rocket_silo_controller.on_player_alt_selected_area(event)
    Log.error("rocket_silo_controller.on_player_alt_selected_area")
    Log.warn(event)

end
-- Event_Handler:register_event({
--     event_name = "on_player_alt_selected_area",
--     source_name = "rocket_silo_controller.on_player_alt_selected_area",
--     func_name = "rocket_silo_controller.on_player_alt_selected_area",
--     func = rocket_silo_controller.on_player_alt_selected_area,
-- })

function rocket_silo_controller.on_player_alt_reverse_selected_area(event)
    Log.error("rocket_silo_controller.on_player_alt_reverse_selected_area")
    Log.warn(event)

end
-- Event_Handler:register_event({
--     event_name = "on_player_alt_reverse_selected_area",
--     source_name = "rocket_silo_controller.on_player_alt_reverse_selected_area",
--     func_name = "rocket_silo_controller.on_player_alt_reverse_selected_area",
--     func = rocket_silo_controller.on_player_alt_reverse_selected_area,
-- })

function rocket_silo_controller.on_player_reverse_selected_area(event)
    Log.error("rocket_silo_controller.on_player_reverse_selected_area")
    Log.warn(event)

end
-- Event_Handler:register_event({
--     event_name = "on_player_reverse_selected_area",
--     source_name = "rocket_silo_controller.on_player_reverse_selected_area",
--     func_name = "rocket_silo_controller.on_player_reverse_selected_area",
--     func = rocket_silo_controller.on_player_reverse_selected_area,
-- })

-- function rocket_silo_controller.on_player_cursor_stack_changed(event)
--     -- Log.debug("rocket_silo_controller.on_player_cursor_stack_changed")
--     -- Log.info(event)

--     if (not event) then return end
--     -- local prototype_name = event.prototype_name
--     -- if (not prototype_name) then return end
--     -- if (not shorcut_names[prototype_name]) then return end

--     local player = game.get_player(event.player_index)
--     if (not player or not player.valid) then return end

--     local cursor_stack = player.cursor_stack
--     if (not cursor_stack or not cursor_stack.valid or not cursor_stack.valid_for_read) then return end
--     if (cursor_stack.name ~= "ICBM-remote") then return end

-- end
-- Event_Handler:register_event({
--     event_name = "on_player_cursor_stack_changed",
--     source_name = "rocket_silo_controller.on_player_cursor_stack_changed",
--     func_name = "rocket_silo_controller.on_player_cursor_stack_changed",
--     func = rocket_silo_controller.on_player_cursor_stack_changed,
-- })

function rocket_silo_controller.on_target_combintor_select_target(event)

    if (not event) then return end
    if (event.input_name ~= "configurable-nukes-target-combinator-select-target") then return end

    local prototype = event.selected_prototype
    if (not prototype or not prototype.name == "ICBM-remote") then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    local inventory = player.get_inventory(character_inventory) or player.character and player.character.valid and player.character.get_inventory(character_inventory) or all_seeing_active and player.get_inventory(god_inventory)
    if (not inventory or not inventory.valid) then
        if (    storage.god_controller_inventories
            and storage.god_controller_inventories[player.index]
        ) then
            inventory = storage.god_controller_inventories[player.index].inventory
            if (not inventory or not inventory.valid) then return end
        else
            return
        end
    end

    -- log(serpent.block(quality_array))

    local quality_name = (quality_array[1] or { quality = { name = "normal", }, }).quality.name
    local target_combinator_count = inventory.get_item_count_filtered({ name = "target-combinator", quality = quality_name, comparator = ">=", })
    -- local target_combinator_item_stack, tc_index = inventory.find_item_stack({ name = "target-combinator", quality = "normal", comparator = ">="})
    local target_combinator_item_stack, tc_index = inventory.find_item_stack({ name = "target-combinator", quality = quality_name, })
    local processing_unit_count = inventory.get_item_count_filtered({ name = "processing-unit", quality = quality_name, comparator = ">=", })
    local quality_tc = "normal"

    if (not target_combinator_item_stack or not target_combinator_item_stack.valid or not target_combinator_item_stack.valid_for_read) then target_combinator_item_stack = nil end
    if (not target_combinator_item_stack and target_combinator_count > 0 or target_combinator_item_stack and target_combinator_item_stack.get_tag("target_tags")) then
        local found = false
        for i = 1, #quality_array, 1 do
            target_combinator_item_stack, tc_index = inventory.find_item_stack({ name = "target-combinator", quality = quality_array[i].quality.name, comparator = ">=", })
            -- for j = tc_index, tc_index + inventory.get_item_count_filtered({ name = "target-combinator", quality = "normal", comparator = ">=", }), 1 do
            for j = tc_index or 1, ((tc_index or 1) + inventory.get_item_count_filtered({ name = "target-combinator", quality = quality_array[i].quality.name, comparator = ">=", })) / target_combinator_stack_size, 1 do
                target_combinator_item_stack = inventory[j]
                if (not target_combinator_item_stack or not target_combinator_item_stack.valid or not target_combinator_item_stack.valid_for_read) then goto continue end

                if (not target_combinator_item_stack.get_tag("target_tags")) then
                    quality_tc = target_combinator_item_stack.quality.name
                    found = true
                    break
                end

                ::continue::
            end
            if (found) then break end
        end

        if (not found) then target_combinator_item_stack = nil end
    end

    if (target_combinator_item_stack and target_combinator_item_stack.count > 0 and processing_unit_count > 0) then
        local removed_pu = inventory.remove({ name = "processing-unit", count = 1, })
        if (removed_pu <= 0) then
            for k, _ in pairs(quality) do
                removed_pu = inventory.remove({ name = "processing-unit", count = 1, quality = k, })
                if (removed_pu > 0) then break end
            end
        end

        local removed_tc = inventory.remove({ name = "target-combinator", count = 1, quality = quality_tc})
        if (removed_tc <= 0) then
            for _, obj in ipairs(quality_array) do
                removed_tc = inventory.remove({ name = "target-combinator", count = 1, quality = obj.key, })
                quality_tc = obj.key
                if (removed_tc > 0) then break end
            end
        end

        local cursor_position = event.cursor_position
        local custom_description = ""
        if (removed_tc > 0) then
            -- local default_unknown = { min = "?", }
            custom_description = string_format("X: %d, Y: %d, I: %d", cursor_position.x, cursor_position.y, player.surface.index)
            inventory.insert({
                name = "target-combinator",
                count = 1,
                quality = quality_tc,
                tags = {
                    target_tags = {
                        {
                            launch = { value = { type = "virtual", name = "signal-check", quality = "normal", }, },
                            x = { value = { type = "virtual", name = "signal-X", quality = "normal", }, min = cursor_position.x, },
                            y = { value = { type = "virtual", name = "signal-Y", quality = "normal", }, min = cursor_position.y, },
                            surface_index = { value = { type = "virtual", name = "signal-I", quality = "normal", }, min = player.surface.index, },
                        },
                    },
                },
                custom_description = custom_description,
            })
        end


        if (removed_pu > 0 and removed_tc > 0) then

            local custom_chart_tag = player.force.add_chart_tag(player.surface, {
                position = cursor_position,
                icon = { type = "virtual", name = "mirv-targeting-signal", },
                -- text = "MIRV",
                last_user = player,
            })
            if (custom_chart_tag and custom_chart_tag.valid) then
                custom_chart_tag.text = string_format("MIRV-%d: X: %d, Y: %d, I: %d", custom_chart_tag.tag_number, custom_chart_tag.position.x, custom_chart_tag.position.y, custom_chart_tag.surface.index)
            end

            local item_stack, idx = inventory.find_item_stack("target-combinator")
            if (item_stack and item_stack.valid and item_stack.valid_for_read) then
                if (item_stack.custom_description ~= custom_description) then
                    local size = #inventory
                    while idx and idx < size do
                        idx = idx + 1
                        item_stack = inventory[idx]
                        if (    item_stack
                            and item_stack.valid
                            and item_stack.valid_for_read
                        ) then
                            if (item_stack.name == "target-combinator" and item_stack.custom_description == custom_description) then break end
                        else
                            item_stack = nil
                            break
                        end
                    end
                end

                if (item_stack and item_stack.valid and item_stack.valid_for_read) then
                    local registration_number, useful_id, defines_type = register_on_object_destroyed(item_stack.item)
                    storage.registered_objects = storage.registered_objects or {}
                    storage.registered_objects[registration_number] = storage.registered_objects[registration_number] or {
                        registration_number = registration_number,
                        useful_id = useful_id,
                        defines_type = defines_type,
                        tag_number = custom_chart_tag.tag_number,
                    }

                    storage.mirv_targets = storage.mirv_targets or {}
                    storage.mirv_targets[custom_chart_tag.tag_number] = storage.mirv_targets[custom_chart_tag.tag_number] or {}
                    storage.mirv_targets[custom_chart_tag.tag_number][#(storage.mirv_targets[custom_chart_tag.tag_number])+1] = item_stack.item.item_number and { chart_tag = custom_chart_tag, tag_number = custom_chart_tag.tag_number, item = item_stack.item, item_number = item_stack.item.item_number, target_tags = item_stack.get_tag("target_tags"), custom_description = item_stack.custom_description, } or nil

                    item_stack.set_tag("mirv_tag_number", custom_chart_tag.tag_number)
                    item_stack.custom_description = string_format("MIRV-%s: %s", custom_chart_tag.tag_number, custom_description)
                end
            end

            if (item_stack) then
                local render_object = rendering.draw_sprite({
                    sprite = "virtual-signal/mirv-targeting-signal",
                    surface = player.surface,
                    target = cursor_position,
                    scale = 80,
                    time_to_live = 600,
                    blink_interval = 30,
                    forces = player.force.index,
                    scale_with_zoom = true,
                })
            end

            local render_object = rendering.draw_text({
                text = { "?",
                    {
                        "",
                        { "shortcut-label.target-combinator-program-coordinates", string_format("X: %.2d, Y: %.2d", cursor_position.x, cursor_position.y), player.surface.name},
                        "\n",
                        { "shortcut-label.target-combinator-program-cost", },
                        "\n",
                        { "shortcut-label.target-combinator-count", target_combinator_count },
                        ", ",
                        { "shortcut-label.processing-unit-count", processing_unit_count },
                    },
                    "???",
                },
                surface = player.surface,
                target = cursor_position,
                color = {},
                scale = 5/3,
                time_to_live = 480,
                forces = player.force.index,
                scale_with_zoom = true,
                use_rich_text = true,
            })

            -- player.clear_cursor()
            -- player.cursor_ghost = target_visualizer

            if (not render_object or not render_object.valid) then return end

            player.create_local_flying_text({
                create_at_cursor = true,
                text = { "?",
                    {
                        "",
                        { "shortcut-label.target-combinator-program-coordinates", string_format("X: %.2d, Y: %.2d", cursor_position.x, cursor_position.y), player.surface.name},
                        "\n",
                        { "shortcut-label.target-combinator-program-cost", },
                        "\n",
                        { "shortcut-label.target-combinator-count", target_combinator_count },
                        ", ",
                        { "shortcut-label.processing-unit-count", processing_unit_count },
                    },
                    "???",
                },
                time_to_live = 960,
                speed = 1,
            })
        end
    else
        if (not target_combinator_item_stack) then
            if (processing_unit_count > 0) then
                player.create_local_flying_text({
                    create_at_cursor = true,
                    text = { "?", { "", { "shortcut-label.dont-panic", }, "\n", { "shortcut-label.insufficient-target-combinators", }, }, "???" },
                })
            else
                player.create_local_flying_text({
                    create_at_cursor = true,
                    text = { "?", { "", { "shortcut-label.dont-panic", }, "\n", { "shortcut-label.insufficient-target-combinators-and-processing-units", }, }, "???" },
                })
            end
        elseif (target_combinator_item_stack.count > 0) then
            player.create_local_flying_text({
                create_at_cursor = true,
                text = { "?", { "", { "shortcut-label.dont-panic", }, "\n", { "shortcut-label.insufficient-processing-units", }, }, "???" },
            })
        end
    end
end
Event_Handler:register_event({
    event_name = Custom_Input.TARGET_COMBINATOR_SELECT_TARGET.name,
    source_name = "rocket_silo_controller.on_target_combintor_select_target",
    func_name = "rocket_silo_controller.on_target_combintor_select_target",
    func = rocket_silo_controller.on_target_combintor_select_target,
})

function rocket_silo_controller.on_chart_tag_modified(event)
    log(serpent.block(event))
    if (not event) then return end

    local tag =  event.tag
    if (not tag or not tag.valid or not tag.surface or not tag.surface.valid) then return end
    log(serpent.block(tag.text))

    if (not tag.text:find("^MIRV%-[%d]+")) then return end
    if (tag.position.x == event.old_position.x and tag.position.y == event.old_position.y) then return end

    -- local player = game.get_player(event.player_index)
    -- if (not player or not player.valid) then return end
    -- if (not event.player_index or not event.old_player_index) then return end
    if (not event.player_index and not event.old_player_index) then return end

    storage.mirv_targets = storage.mirv_targets or {}
    storage.mirv_targets[tag.tag_number] = storage.mirv_targets[tag.tag_number] or {}
    local mirv_target = storage.mirv_targets[tag.tag_number][1]
    log(serpent.block(mirv_target))
    if (not mirv_target or ((not mirv_target.item or not mirv_target.item.valid) and (not mirv_target.entity or not mirv_target.entity.valid))) then return end

    local target_tags = nil

    local item = nil
    local entity = nil

    for _, mirv_target in ipairs(storage.mirv_targets[tag.tag_number]) do
        log(serpent.block(mirv_target))
        target_tags = mirv_target.target_tags

        if (not target_tags or not target_tags[1]) then
            target_tags = {
                {
                    launch = { value = { type = "virtual", name = "signal-check", quality = "normal", }, },
                    x = { value = { type = "virtual", name = "signal-X", quality = "normal", }, min = tag.position.x, },
                    y = { value = { type = "virtual", name = "signal-Y", quality = "normal", }, min = tag.position.y, },
                    surface_index = { value = { type = "virtual", name = "signal-I", quality = "normal", }, min = tag.surface.index, },
                }
            }
        else
            target_tags[1].x.min = tag.position.x
            target_tags[1].y.min = tag.position.y
            target_tags[1].surface_index.min = tag.surface.index
        end

        item = mirv_target.item
        entity = nil

        if (not item or not item.valid) then
            entity = mirv_target.entity
            if (not entity or not entity.valid) then return end
        end

        if (item) then
            item.set_tag("target_tags", target_tags)
            item.set_tag("mirv_tag_number", tag.tag_number)
            item.custom_description = string_format("MIRV-%d: X: %d, Y: %d, I: %d", tag.tag_number, tag.position.x, tag.position.y, tag.surface.index)
        elseif (entity) then
            local control_behavior = entity.get_or_create_control_behavior()
            if (not control_behavior or not control_behavior.valid) then return end

            local section = nil
            local i = 1
            for _, tags in ipairs(target_tags) do
                section = nil
                section = control_behavior.get_section(i) or control_behavior.add_section()
                if (not section or not section.valid) then goto continue end
                if (not tags) then goto continue end
                section.set_slot(1, tags.launch)
                section.set_slot(2, tags.x)
                section.set_slot(3, tags.y)
                section.set_slot(4, tags.surface_index)

                ::continue::

                i = i + 1
            end

            entity.combinator_description = string_format("MIRV-%d: X: %d, Y: %d, I: %d", tag.tag_number, tag.position.x, tag.position.y, tag.surface.index)
        else
            log("breaking")
            break
        end
    end
    if (not item and not entity) then return end

    tag.text = item and item.custom_description or entity and entity.combinator_description

    local render_object = rendering.draw_sprite({
        sprite = "virtual-signal/mirv-targeting-signal",
        surface = tag.surface,
        target = tag.position,
        scale = 80,
        time_to_live = 600,
        blink_interval = 30,
        forces = tag.force.index,
        scale_with_zoom = true,
    })
end
Event_Handler:register_event({
    event_name = "on_chart_tag_modified",
    source_name = "rocket_silo_controller.on_chart_tag_modified",
    func_name = "rocket_silo_controller.on_chart_tag_modified",
    func = rocket_silo_controller.on_chart_tag_modified,
})

function rocket_silo_controller.on_object_destroyed(event)

    if (not event or not event.type == target_type_item) then return end

    -- log(serpent.block(event))

    storage.registered_objects = storage.registered_objects or {}
    if (not storage.registered_objects[event.registration_number]) then return end

    local object_data = storage.registered_objects[event.registration_number]
    storage.registered_objects[event.registration_number] = nil

    -- log(serpent.block(object_data))

    storage.mirv_targets = storage.mirv_targets or {}
    storage.mirv_targets[object_data.tag_number] = storage.mirv_targets[object_data.tag_number] or {}
    -- local mirv_target = storage.mirv_targets[object_data.tag_number][1]
    -- log(serpent.block(mirv_target))
    -- -- if (mirv_target and (mirv_target.item and mirv_target.item.valid or mirv_target.entity and mirv_target.entity.valid)) then return end
    -- if (not mirv_target or mirv_target.entity and mirv_target.entity.valid) then return end

    local mirv_target = nil
    for i = 1, #storage.mirv_targets[object_data.tag_number], 1 do
        mirv_target = storage.mirv_targets[object_data.tag_number][i]
        log(serpent.block(mirv_target))
        if (not mirv_target) then return end
        if (mirv_target.useful_id and mirv_target.useful_id == object_data.useful_id) then
            table_remove(storage.mirv_targets[object_data.tag_number], i)
            break
        end
        mirv_target = nil
    end

    if (not mirv_target or storage.mirv_targets[object_data.tag_number][1]) then return end

    if (mirv_target.chart_tag and mirv_target.chart_tag.valid) then mirv_target.chart_tag.destroy() end
    storage.mirv_targets[object_data.tag_number] = nil
end
Event_Handler:register_event({
    event_name = "on_object_destroyed",
    source_name = "rocket_silo_controller.on_object_destroyed",
    func_name = "rocket_silo_controller.on_object_destroyed",
    func = rocket_silo_controller.on_object_destroyed,
})

function rocket_silo_controller.on_toggle_map(event)
    local player = game.get_player(event.player_index)
    if (    not player
        or  not player.valid
        or  not controllers_with_inventories[player.controller_type]
        or  not controllers_with_inventories[player.physical_controller_type]
    ) then
        return
    end

    local controller_type = player.controller_type
    if (controllers_with_inventories[controller_type]) then
        if (controllers_with_inventories[controller_type].name == "god") then
            storage.god_controller_inventories = storage.god_controller_inventories or {}
            storage.god_controller_inventories[player.index] = storage.god_controller_inventories[player.index] or {}
            storage.god_controller_inventories[player.index].inventory = player.get_inventory(god_inventory)
            if (storage.god_controller_inventories[player.index].inventory and not storage.god_controller_inventories[player.index].inventory.valid) then storage.god_controller_inventories[player.index].inventory = nil end
        end
    else
        local player_controller_type = controller_type
        controller_type = player.physical_controller_type
        if (controllers_with_inventories[controller_type]) then
            if (controller_types[player_controller_type].name == "remote" and controllers_with_inventories[controller_type].name == "god") then
                storage.god_controller_inventories = storage.god_controller_inventories or {}
                storage.god_controller_inventories[player.index] = nil
            end
        end
    end
end
Event_Handler:register_event({
    event_name = Custom_Input.TOGGLE_MAP.name,
    source_name = "rocket_silo_controller.on_toggle_map",
    func_name = "rocket_silo_controller.on_toggle_map",
    func = rocket_silo_controller.on_toggle_map,
})

function rocket_silo_controller.launch_rocket(event)
    Log.debug("rocket_silo_controller.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick) then return end

    if (not event.item or event.item ~= "ICBM-remote") then return end
    if (not event.player_index or not event.area) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    local force = player.force
    if (not force or not force.valid or not force.index) then return end

    if (not Rocket_Silo_Validations.is_targetable_surface({ surface = event.surface, player = player })) then return end

    if (not storage.icbms_researched or not storage.icbms_researched[force.index]) then return end

    local return_val, return_data = Rocket_Silo_Service.launch_rocket(event)

    if (type(return_val) == "number" and return_val == 1) then
        -- if (type(return_data) == "table" and return_data.valid) then
        --     storage.icbm_data = storage.icbm_data or {}
        --     storage.icbm_data.item_numbers = storage.icbm_data.item_numbers or {}
        --     local icbm_data = storage.icbm_data.item_numbers[return_data.item_number]
        --     if (icbm_data) then
        --         ICBM_Data.validate_fields(icbm_data)
        --     elseif (not icbm_data) then
        --         icbm_data = ICBM_Repository.get_icbm_data(return_data.surface_name, return_data.item_number, { validate_fields = true })
        --     end
        --     if (not icbm_data or not icbm_data.valid) then return end

        --     Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
        --         icbm_data = icbm_data,
        --     })
        -- end
        if (type(return_data) == "table" and return_data[1] and return_data[#return_data].valid) then
            storage.icbm_data = storage.icbm_data or {}
            storage.icbm_data.item_numbers = storage.icbm_data.item_numbers or {}
            local icbm_data
            for _, v in ipairs(return_data) do
                icbm_data = storage.icbm_data.item_numbers[v.item_number]
                if (icbm_data) then
                    ICBM_Data.validate_fields(icbm_data)
                elseif (not icbm_data) then
                    icbm_data = ICBM_Repository.get_icbm_data(v.surface_name, v.item_number, { validate_fields = true })
                end
                if (not icbm_data or not icbm_data.valid) then goto continue end

                Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
                    icbm_data = icbm_data,
                })

                ::continue::
            end
        end
    end
end
Event_Handler:register_event({
    event_name = "on_player_selected_area",
    source_name = "rocket_silo_controller.launch_rocket",
    func_name = "rocket_silo_controller.launch_rocket",
    func = rocket_silo_controller.launch_rocket,
})

function rocket_silo_controller.on_cargo_pod_finished_ascending(event)
    -- Log.debug("rocket_silo_controller.on_cargo_pod_finished_ascending")
    -- Log.info(event)

    if (not event) then return end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    if (not event.cargo_pod.surface or not event.cargo_pod.surface.valid) then return end

    --[[ The right idea, but not quite the needed implementation
        -> Need one specific for "launchable" surfaces
        TODO: Above
    ]]
    -- if (not Rocket_Silo_Validations.is_targetable_surface({ surface = event.cargo_pod.surface, })) then return end

    on_cargo_pod_finished_ascending(event)
end
Event_Handler:register_event({
    event_name = "on_cargo_pod_finished_ascending",
    source_name = "rocket_silo_controller.on_cargo_pod_finished_ascending",
    func_name = "rocket_silo_controller.on_cargo_pod_finished_ascending",
    func = rocket_silo_controller.on_cargo_pod_finished_ascending,
})

function rocket_silo_controller.on_space_platform_built_entity(event)
    -- Log.debug("rocket_silo_controller.on_space_platform_built_entity")
    -- Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (rocket_silo.type ~= "rocket-silo") then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    rocket_silo_built(rocket_silo)
end
Event_Handler:register_event({
    event_name = "on_space_platform_built_entity",
    source_name = "rocket_silo_controller.on_space_platform_built_entity",
    func_name = "rocket_silo_controller.on_space_platform_built_entity",
    func = rocket_silo_controller.on_space_platform_built_entity,
    filter = rocket_silo_controller.filter,
})

function rocket_silo_controller.on_space_platform_mined_entity(event)
    -- Log.debug("rocket_silo_controller.on_space_platform_mined_entity")
    -- Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (rocket_silo.type ~= "rocket-silo") then return end
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (find_invalid_substrings(surface.name)) then return end

    rocket_silo_built(rocket_silo)
end
Event_Handler:register_event({
    event_name = "on_space_platform_mined_entity",
    source_name = "rocket_silo_controller.on_space_platform_mined_entity",
    func_name = "rocket_silo_controller.on_space_platform_mined_entity",
    func = rocket_silo_controller.on_space_platform_mined_entity,
    filter = rocket_silo_controller.filter,
})

function rocket_silo_controller.init(__storage)
    storage = __storage
end

return rocket_silo_controller