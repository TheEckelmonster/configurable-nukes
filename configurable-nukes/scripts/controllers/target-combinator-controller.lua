local storage

local next = next
local string = string
local string_format = string.format
local type = type

local defines = defines
local prototypes = prototypes
local script = script

local gui_type_entity = defines.gui_type.entity
local quality = prototypes.quality
local register_on_object_destroyed = script.register_on_object_destroyed
local table_size = table_size

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

local Custom_Input = require("prototypes.custom-input.custom-input")

local Event_Handler = Event_Handler
local Filters = Filters
local Log = Log

local default_filters = {
    ["signal-check"] = "launch",
    ["signal-X"] = "x",
    ["signal-Y"] = "y",
    ["signal-I"] = "surface_index",
}

local target_combinator_controller = {}
target_combinator_controller.name = "target_combinator_controller"

target_combinator_controller.filter = Filters.target_combinator_controller

function target_combinator_controller.on_entity_created(event)
    Log.debug("target_combinator_controller.on_entity_created")
    Log.info(event)

    if (not event) then return end
    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.type ~= "constant-combinator") then return end
    if (entity.name ~= "target-combinator") then return end
    local surface = entity.surface
    if (not surface or not surface.valid) then return end

    local inventory = event.consumed_items
    if (not inventory or not inventory.valid) then return end

    -- local item_stack = inventory.find_item_stack("target-combinator")
    local item_stack = inventory.find_item_stack({ name = "target-combinator", quality = entity.quality.name, comparator = "==", })
    if (not item_stack or not item_stack.valid or not item_stack.is_item_with_tags) then return end

    local item_number = item_stack.item and item_stack.item.valid and item_stack.item.item_number
    if (not item_number) then return end

    local control_behavior = entity.get_or_create_control_behavior()
    if (not control_behavior or not control_behavior.valid) then return end

    entity.combinator_description = item_stack.custom_description

    local target_tags = item_stack.get_tag("target_tags")
    if (not target_tags or not next(target_tags)) then
        target_tags = {
            {
                launch = { value = { type = "virtual", name = "signal-check", quality = "normal", }, },
                x = { value = { type = "virtual", name = "signal-X", quality = "normal", }, min = entity.position.x, },
                y = { value = { type = "virtual", name = "signal-Y", quality = "normal", }, min = entity.position.y, },
                surface_index = { value = { type = "virtual", name = "signal-I", quality = "normal", }, min = entity.surface.index, },
            },
        }
    end

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

    if (not item_stack.tags.mirv_tag_number) then return end
    local mirv_tag_number = item_stack.get_tag("mirv_tag_number")

    storage.mirv_targets = storage.mirv_targets or {}
    storage.mirv_targets[mirv_tag_number] = storage.mirv_targets[mirv_tag_number] or {}
    if (not storage.mirv_targets[mirv_tag_number][1]) then return end
    -- local mirv_target = storage.mirv_targets[mirv_tag_number]
    -- mirv_target.item = nil
    -- mirv_target.item_number = nil
    -- mirv_target.entity = entity
    -- mirv_target.unit_number = entity.unit_number
    -- mirv_target.target_tags = target_tags

    for _, mirv_target in ipairs(storage.mirv_targets[mirv_tag_number]) do
        if (not mirv_target.item_number or mirv_target.item_number ~= item_number) then goto continue end

        mirv_target.item = nil
        mirv_target.item_number = nil
        mirv_target.entity = entity
        mirv_target.unit_number = entity.unit_number
        mirv_target.target_tags = target_tags

        ::continue::
    end
end
Event_Handler:register_events({
    {
        event_name = "on_built_entity",
        source_name = "target_combinator_controller.on_entity_created",
        func_name = "target_combinator_controller.on_entity_created",
        func = target_combinator_controller.on_entity_created,
        filter = target_combinator_controller.filter,
    },
    {
        event_name = "on_robot_built_entity",
        source_name = "target_combinator_controller.on_entity_created",
        func_name = "target_combinator_controller.on_entity_created",
        func = target_combinator_controller.on_entity_created,
        filter = target_combinator_controller.filter,
    },
    {
        event_name = "script_raised_built",
        source_name = "target_combinator_controller.on_entity_created",
        func_name = "target_combinator_controller.on_entity_created",
        func = target_combinator_controller.on_entity_created,
        filter = target_combinator_controller.filter,
    },
    {
        event_name = "script_raised_revive",
        source_name = "target_combinator_controller.on_entity_created",
        func_name = "target_combinator_controller.on_entity_created",
        func = target_combinator_controller.on_entity_created,
        filter = target_combinator_controller.filter,
    },
})

function target_combinator_controller.on_entity_mined(event)
    Log.debug("target_combinator_controller.on_entity_mined")
    Log.info(event)

    if (not event) then return end

    local entity = event.entity
    if (not entity or not entity.valid) then return end
    if (entity.type ~= "constant-combinator") then return end
    if (entity.name ~= "target-combinator") then return end

    local inventory = event.buffer
    if (not inventory or not inventory.valid) then return end

    -- local item_stack = inventory.find_item_stack("target-combinator")
    local item_stack = inventory.find_item_stack({ name = "target-combinator", quality = entity.quality.name, comparator = "==", })
    if (not item_stack or not item_stack.valid or not item_stack.is_item_with_tags) then return end

    local control_behavior = entity.get_or_create_control_behavior()
    if (not control_behavior or not control_behavior.valid) then return end

    local target_tags = {}

    local section = nil
    -- local custom_description = ""
    local custom_description = entity.combinator_description and entity.combinator_description:match("^(MIRV%-[%d]+)") or ""
    local mirv_tag_number = nil
    if (custom_description ~= "") then
        mirv_tag_number = custom_description:match("MIRV%-([%d]+)")
        log(serpent.block(mirv_tag_number))
        custom_description = custom_description .. ": "
    end
    local tag = nil
    local default_unknown = { min = "?", }
    local filters = nil
    for i = 1, control_behavior.sections_count, 1 do
        section = control_behavior.sections[i]
        if (not section or not section.valid) then break end

        filters = {}
        for j = 1, section.filters_count, 1 do
            if (
                    section.filters[j]
                and section.filters[j].value
                and section.filters[j].value.name
                and default_filters[section.filters[j].value.name]
            ) then
                filters[section.filters[j].value.name] = section.filters[j]
            end
        end

        log(serpent.block(filters))

        -- tag = {
        --     launch = section.get_slot(1) or default_unknown,
        --     x = section.get_slot(2) or default_unknown,
        --     y = section.get_slot(3) or default_unknown,
        --     surface_index = section.get_slot(4) or default_unknown,
        -- }
        tag = {
            launch = filters["signal-check"] or default_unknown,
            x = filters["signal-X"] or default_unknown,
            y = filters["signal-Y"] or default_unknown,
            surface_index = filters["signal-I"] or default_unknown,
        }
        target_tags[i] = tag
        if (i == 1) then
            custom_description = custom_description .. string_format("X: %s, Y: %s, I: %s", tag.x.min, tag.y.min, tag.surface_index.min)
        else
            custom_description = custom_description .. string_format("\nX: %s, Y: %s, I: %s", tag.x.min, tag.y.min, tag.surface_index.min)
        end
    end

    item_stack.custom_description = custom_description
    if (next(target_tags)) then
        item_stack.set_tag("target_tags", target_tags)
    else
        item_stack.remove_tag("target_tags")
    end
    -- if (mirv_tag_number) then item_stack.set_tag("mirv_tag_number", mirv_tag_number) end
    if (mirv_tag_number) then
        mirv_tag_number = tonumber(mirv_tag_number)
        log(serpent.block(mirv_tag_number))
        item_stack.set_tag("mirv_tag_number", mirv_tag_number)

        storage.mirv_targets = storage.mirv_targets or {}
        -- if (not mirv_tag_number or not storage.mirv_targets[mirv_tag_number]) then return end
        if (not mirv_tag_number) then return end
        storage.mirv_targets[mirv_tag_number] = storage.mirv_targets[mirv_tag_number] or {}
        local mirv_targets = storage.mirv_targets[mirv_tag_number]
        log(serpent.block(mirv_targets))
        -- local mirv_target = storage.mirv_targets[mirv_tag_number]
        local mirv_target = nil
        local unit_number = entity.unit_number
        for i = 1, #mirv_targets, 1 do
            mirv_target = mirv_targets[i]
            log(serpent.block(mirv_target))
            if (not mirv_target) then return end
            if (mirv_target.unit_number == unit_number) then break end
            mirv_target = nil
        end

        log(serpent.block(mirv_target))
        if (not mirv_target) then return end

        local registration_number, useful_id, defines_type = register_on_object_destroyed(item_stack.item)
        storage.registered_objects = storage.registered_objects or {}
        storage.registered_objects[registration_number] = storage.registered_objects[registration_number] or {
            registration_number = registration_number,
            useful_id = useful_id,
            defines_type = defines_type,
            tag_number = mirv_tag_number,
            -- chart_tag = mirv_target.chart_tag,
        }

        mirv_target.entity = nil
        mirv_target.unit_number = nil
        mirv_target.item = item_stack.item
        mirv_target.item_number = item_stack.item.item_number
        mirv_target.target_tags = target_tags
        mirv_target.useful_id = useful_id
    end
end
Event_Handler:register_events({
    {
        event_name = "on_entity_died",
        source_name = "target_combinator_controller.on_entity_mined",
        func_name = "target_combinator_controller.on_entity_mined",
        func = target_combinator_controller.on_entity_mined,
        filter = target_combinator_controller.filter,
    },
    {
        event_name = "on_player_mined_entity",
        source_name = "target_combinator_controller.on_entity_mined",
        func_name = "target_combinator_controller.on_entity_mined",
        func = target_combinator_controller.on_entity_mined,
        filter = target_combinator_controller.filter,
    },
    {
        event_name = "on_robot_mined_entity",
        source_name = "target_combinator_controller.on_entity_mined",
        func_name = "target_combinator_controller.on_entity_mined",
        func = target_combinator_controller.on_entity_mined,
        filter = target_combinator_controller.filter,
    },
})

function target_combinator_controller.on_gui_closed(event)
    -- Log.debug("target_combinator_controller.on_gui_closed")
    -- Log.info(event)

    -- log(serpent.block(event))
    -- game.print(serpent.block(event))

    if (not event or not type(event) == "table") then return end
    if (not event.gui_type or event.gui_type ~= gui_type_entity) then return end
    local entity = event.entity
    if (not entity or not entity.valid or entity.name ~= "target-combinator") then return end

    log(serpent.block(entity.combinator_description))
    game.print(serpent.block(entity.combinator_description))
    game.print(serpent.block(entity.combinator_description:match("^MIRV%-([%d]+)")))
    local mirv_tag_number = entity.combinator_description:match("^MIRV%-([%d]+)")
    mirv_tag_number = mirv_tag_number and tonumber(mirv_tag_number)
    if (not mirv_tag_number) then return end


    local control_behavior = entity.get_or_create_control_behavior()
    if (not control_behavior or not control_behavior.valid) then return end

    local target_tags = {}

    local section = nil
    local tag = nil
    local default_unknown = { min = "?", }
    local filters = nil
    for i = 1, control_behavior.sections_count, 1 do
        section = control_behavior.sections[i]
        if (not section or not section.valid) then break end

        filters = {}
        for j = 1, section.filters_count, 1 do
            if (
                    section.filters[j]
                and section.filters[j].value
                and section.filters[j].value.name
                and default_filters[section.filters[j].value.name]
            ) then
                filters[section.filters[j].value.name] = section.filters[j]
            end
        end

        tag = {
            launch = filters["signal-check"] or default_unknown,
            x = filters["signal-X"] or default_unknown,
            y = filters["signal-Y"] or default_unknown,
            surface_index = filters["signal-I"] or default_unknown,
        }
        target_tags[i] = tag
    end
    log(serpent.block(target_tags))

    storage.mirv_targets = storage.mirv_targets or {}
    if (not storage.mirv_targets[mirv_tag_number]) then return end
    storage.mirv_targets[mirv_tag_number] = storage.mirv_targets[mirv_tag_number] or {}
    if (not storage.mirv_targets[mirv_tag_number][1]) then return end
    local mirv_targets = storage.mirv_targets[mirv_tag_number]

    local mirv_target = nil
    local unit_number = entity.unit_number
    for i = 1, #mirv_targets, 1 do
        mirv_target = mirv_targets[i]
        log(serpent.block(mirv_target))
        if (not mirv_target) then return end
        if (mirv_target.unit_number == unit_number) then break end
        mirv_target = nil
    end

    log(serpent.block(mirv_target))
    if (not mirv_target) then
        mirv_targets[#mirv_targets+1] = {
            chart_tag = mirv_targets[1].chart_tag,
            tag_number = mirv_tag_number,
            entity = entity,
            unit_number = entity.unit_number,
            target_tags = target_tags,
        }
    else
        mirv_target.target_tags = target_tags
    end
end
Event_Handler:register_event({
    event_name = "on_gui_closed",
    source_name = "target_combinator_controller.on_gui_closed",
    func_name = "target_combinator_controller.on_gui_closed",
    func = target_combinator_controller.on_gui_closed,
})

function target_combinator_controller.init(__storage)
    storage = __storage
end

return target_combinator_controller