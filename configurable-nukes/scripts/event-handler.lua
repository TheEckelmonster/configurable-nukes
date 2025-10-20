-- If already defined, return
if _event_handlers and _event_handlers.configurable_nukes then
    return _event_handlers
end

local Log = require("libs.log.log")

local event_handlers =
{
    events = {},
    event_names = {},
    restore_on_load = {},
}

local event_name_black_list =
{
    on_load = "on_load",
    on_configuration_changed = "on_configuration_changed",
    on_nth_tick = "on_nth_tick",
}

local new_event = function (data)
    return
    {
        order = {},
        dictionary = {},
        sources = {},
    }
end

local deepcopy_exclude_functions = function (object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            if (type(object) ~= "function") then
                return object
            else
                return
            end
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local process_event = function (data)
    if (not data) then return end
    if (not data.event) then return end
    if (not data.event_data) then return end

    local i, loop_count = 1, 1
    while i <= #data.event_data.order do
        if (loop_count > #data.event_data.order * 1.5) then
            Log.error("on_event.order processing overran it's order size; breaking")
            break
        end
        if (data.event_data.sources[data.event_data.order[i].source_name]) then
            -- data.event_data.order[i].func(data.event)
            if (data.event_data.order[i].func_data) then
                data.event_data.order[i].func(data.event, data.event_data.order[i].func_data)
            else
                data.event_data.order[i].func(data.event)
            end
            i = i + 1
        else
            log("removing event func as it has no existing source")
            table.remove(data.event_data.order, i)
        end
        loop_count = loop_count + 1
    end
end

function event_handlers.on_event(event)
    -- Log.debug("event_handlers.on_event")
    -- Log.info(event)
    -- log(serpent.block(event))

    if (event and event_handlers.event_names[event.name] and event_handlers.events[event_handlers.event_names[event.name]]) then
        local event_data = event_handlers.events[event_handlers.event_names[event.name]]
        process_event({ event = event, event_data = event_data })
    end
end

function event_handlers.on_nth_tick(event)
    -- Log.debug("event_handlers.on_nth_tick")
    -- Log.info(event)

    if (not event) then return end
    if (event.nth_tick == nil) then return end
    if (type(event.nth_tick) ~= "number") then return end
    if (event.nth_tick < 0) then return end

    if (event_handlers.events["on_nth_tick"] and event_handlers.events["on_nth_tick"][event.nth_tick]) then
        local event_data = event_handlers.events["on_nth_tick"][event.nth_tick]
        process_event({ event = event, event_data = event_data })
    end
end

function event_handlers.on_load()
    Log.debug("event_handlers.on_load")

    for _, v in ipairs(event_handlers.events["on_load"].order) do
        v.func(event)
    end
end

function event_handlers.on_configuration_changed(event)
    Log.debug("event_handlers.on_configuration_changed")
    Log.info(event)

    for _, v in ipairs(event_handlers.events["on_configuration_changed"].order) do
        v.func(event)
    end
end

function event_handlers:register_event(data)
    Log.debug("event_handlers:register_event")
    Log.info(data)
    log(serpent.block(data))

    if (not data or type(data) ~= "table") then return end
    if (data.event_num ~= nil and (type(data.event_num) ~= "number" or data.event_num < 0)) then return end
    if (not data.event_name or type(data.event_name) ~= "string") then
        if (data.event_num ~= nil) then
            if (data.fallback_event_name ~= nil and type(data.fallback_event_name) == "string") then
                data.event_name = data.fallback_event_name
            else
                return
            end
        else
            return
        end
    end
    data.event_name = data.event_name:lower()

    if (data.event_num == nil) then
        if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then
            log("I happened")
            defines.events[data.event_name] = script.generate_event_name()
        end
        if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then return end
    end

    if (not data.source_name or type(data.source_name) ~= "string") then return end
    data.source_name = data.source_name:lower()

    if (not data.func or type(data.func) ~= "function") then return end
    if (not data.func_name or type(data.func_name) ~= "string") then return end
    if (data.restore_on_load ~= nil and type(data.restore_on_load) ~= "boolean") then data.restore_on_load = false end

    if (not event_name_black_list[data.event_name]) then
        if (data.event_num == nil) then
            event_handlers.event_names[defines.events[data.event_name]] = data.event_name
        else
            event_handlers.event_names[data.event_num] = data.event_name
        end
    else
        event_handlers.event_names[data.event_name] = data.event_name
    end

    local event_data = nil
    local event = nil
    if (data.nth_tick and type(data.nth_tick) == "number" and data.nth_tick >= 0) then
        if (not event_handlers.events["on_nth_tick"]) then event_handlers.events["on_nth_tick"] = {} end
        if (not event_handlers.events["on_nth_tick"][data.nth_tick]) then event_handlers.events["on_nth_tick"][data.nth_tick] = new_event() end

        -- local event_data =
        event_data =
        {
            source_name = data.source_name,
            index = #(event_handlers.events["on_nth_tick"][data.nth_tick].order) + 1,
            func_name = data.func_name,
            func = data.func,
            restore_on_load = data.restore_on_load,
            func_data = data.restore_on_load and data.func_data or nil,
        }

        --[[ Array of the order individual processing should occur for a given event ]]
        table.insert(event_handlers.events["on_nth_tick"][data.nth_tick].order, event_data)
        event_data.index = #(event_handlers.events["on_nth_tick"][data.nth_tick].order)

        --[[ Index the whole event by event source_name ]]
        event_handlers.events["on_nth_tick"][data.nth_tick].dictionary[data.source_name] = event_data
        --[[ Index the order index by event source_name ]]
        event_handlers.events["on_nth_tick"][data.nth_tick].sources[data.source_name] = event_data.index
        event = event_handlers.events["on_nth_tick"][data.nth_tick]
    else
        if (not event_handlers.events[data.event_name]) then event_handlers.events[data.event_name] = new_event() end

        -- local event_data =
        event_data =
        {
            source_name = data.source_name,
            index = #event_handlers.events[data.event_name].order + 1,
            func_name = data.func_name,
            func = data.func,
            restore_on_load = data.restore_on_load,
            func_data = data.restore_on_load and data.func_data or nil,
        }

        --[[ Array of the order individual processing should occur for a given event ]]
        table.insert(event_handlers.events[data.event_name].order, event_data)

        --[[ Index the whole event by event source_name ]]
        event_handlers.events[data.event_name].dictionary[data.source_name] = event_data
        --[[ Index the order index by event source_name ]]
        event_handlers.events[data.event_name].sources[data.source_name] = event_data.index
        event = event_handlers.events[data.event_name]
    end

    local event_registered = false
    local event_name = nil

    if (not event_name_black_list[data.event_name]) then
        if (data.filter ~= nil and type(data.filter) ~= "table") then data.filter = nil end
        -- local event_name = data.event_num ~= nil and data.event_num or data.event_name
        event_name = data.event_num ~= nil and data.event_num or data.event_name

        if (data.filter) then
            script.on_event(event_name, event_handlers.on_event, data.filter)
            event_registered = true
        else
            script.on_event(event_name, event_handlers.on_event)
            event_registered = true
        end
    else
        if (data.event_name == "on_nth_tick") then
            if (data.nth_tick and type(data.nth_tick) == "number" and data.nth_tick >= 0) then
                event_name = "on_nth_tick"
                script.on_nth_tick(data.nth_tick, event_handlers.on_nth_tick)
                event_registered = true
            end
        elseif (data.event_name == "on_load") then
            event_name = "on_load"
            script.on_load(event_handlers.on_load)
            event_registered = true
        elseif (data.event_name == "on_configuration_changed") then
            event_name = "on_configuration_changed"
            script.on_configuration_changed(event_handlers.on_configuration_changed)
            event_registered = true
        end
    end

    -- log(serpent.block(event_registered))
    if (event_registered) then
        -- log(serpent.block(data.restore_on_load))
        -- log(tostring(storage))
        if (data.restore_on_load and storage) then
            -- log(serpent.block(event_data))
            -- log(serpent.block(event_name))
            log(serpent.block(event))
            if (event_data and event_name and event) then
                event_data.event_name = event_name
                -- table.insert(event_handlers.restore_on_load, event)
                if (event_name == "on_nth_tick") then
                    if (not event_handlers.restore_on_load[event_name]) then event_handlers.restore_on_load[event_name] = {} end
                    event_handlers.restore_on_load[event_name][data.nth_tick] = event
                else
                    event_handlers.restore_on_load[event_name] = event
                end

                if (data.save_to_storage) then
                    --[[ TODO: Implement specific copying/saving, rather than cloning the entire table every time ]]
                    local cleaned_event_handlers_copy = deepcopy_exclude_functions(event_handlers)
                    log(serpent.block(cleaned_event_handlers_copy))

                    if (cleaned_event_handlers_copy) then
                        storage.event_handlers = { restore_on_load = cleaned_event_handlers_copy.restore_on_load }
                    end
                end
            end
        end
    end
end

function event_handlers:register_events(data_array)
    Log.debug("event_handlers:register_events")
    Log.info(data_array)

    if (not data_array or type(data_array) ~= "table") then return end
    if (not next(data_array, nil)) then return end

    for _, v in pairs(data_array) do
        self:register_event(v)
    end
end

function event_handlers:remove_event(data)
    Log.debug("event_handlers:remove_event")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.event_name or type(data.event_name) ~= "string") then return end
    data.event_name = data.event_name:lower()

    if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then return end

    local all_nth_tick_events = false
    local event = nil
    if (data.event_name == "on_nth_tick" and event_handlers.events["on_nth_tick"]) then
        if (data.nth_tick ~= nil) then
            if (type(data.nth_tick) == "number" and data.nth_tick >= 0) then
                event = event_handlers.events["on_nth_tick"][data.nth_tick]
                event_handlers.events["on_nth_tick"][data.nth_tick] = nil
            elseif (type(data.nth_tick) == "number" and data.nth_tick < 0) then
                event = event_handlers.events["on_nth_tick"]
                event_handlers.events["on_nth_tick"] = nil
                all_nth_tick_events = true
            end
        end
    else
        local event_name = event_handlers.event_names[defines.events[data.event_name]] or event_handlers.event_names[data.event_name]
        if (event_name) then
            event = event_handlers.events[event_name]
            event_handlers.events[event_name] = nil
        end
    end

    if (event) then
        if (all_nth_tick_events) then
            for k, v in pairs(event) do
                local i = 1
                while v.order ~= nil and i <= #v.order do
                    self:unregister_event({
                        source_name = v.order[i].source_name,
                        event_name = data.event_name,
                        nth_tick = k,
                    })
                    i = i + 1
                end
            end
        else
            local i = 1
            while event.order ~= nil and i <= #event.order do
                self:unregister_event({
                    source_name = event.order[i].source_name,
                    event_name = data.event_name,
                    nth_tick = data.nth_tick,
                })
                i = i + 1
            end
        end

        local event_removed = false
        if (not event_name_black_list[data.event_name]) then
            script.on_event(data.event_name, nil)
            event_removed = true
        else
            if (data.event_name == "on_nth_tick") then
                if (all_nth_tick_events) then
                    script.on_nth_tick(nil)
                    event_removed = true
                else
                    if (data.nth_tick ~= nil and type(data.nth_tick) == "number") then
                        if (data.nth_tick >= 0) then
                            script.on_nth_tick(data.nth_tick, nil)
                            event_removed = true
                        else
                            script.on_nth_tick(nil)
                            event_removed = true
                        end
                    end
                end
            elseif (data.event_name == "on_load") then
                script.on_load(nil)
                event_removed = true
            elseif (data.event_name == "on_configuration_changed") then
                script.on_configuration_changed(nil)
                event_removed = true
            end
        end

        if (event_removed) then
            --[[ TODO: Implement specific copying/saving, rather than clonging the entire table every time ]]
            local cleaned_event_handlers_copy = deepcopy_exclude_functions(event_handlers)
            log(serpent.block(cleaned_event_handlers_copy))

            storage.event_handlers = cleaned_event_handlers_copy
        end
    end
end

function event_handlers:unregister_event(data)
    Log.debug("event_handlers:unregister_event")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.event_name or type(data.event_name) ~= "string") then return end
    if (not data.source_name or type(data.source_name) ~= "string") then return end
    data.event_name = data.event_name:lower()
    data.source_name = data.source_name:lower()

    if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then return end

    local event = nil
    if (data.event_name == "on_nth_tick" and event_handlers.events["on_nth_tick"]) then
        if (data.nth_tick ~= nil) then
            if (type(data.nth_tick) == "number" and data.nth_tick >= 0) then
                event = event_handlers.events["on_nth_tick"][data.nth_tick]
            end
        end
    else
        local event_name = event_handlers.event_names[defines.events[data.event_name]] or event_handlers.event_names[data.event_name]
        if (event_name) then
            event = event_handlers.events[event_name]
        end
    end

    if (event and event.sources[data.source_name]) then
        table.remove(event.order, event.sources[data.source_name])

        event.sources[data.source_name] = nil

        local new_sources = {}
        local new_dictionary = {}

        local i = 1
        while i <= #event.order do
            if (event.sources[event.order[i].source_name] == nil) then
                table.remove(event.order, i)
            else
                event.order[i].index = i
                new_sources[event.order[i].source_name] = i
                new_dictionary[event.order[i].source_name] = event.order[i]
                i = i + 1
            end
        end
        event.sources = new_sources
        event.dictionary = new_dictionary

        --[[ Completely unregister the event if nothing remains in the events.order ]]
        if (#event.order == 0) then
            if (not event_name_black_list[data.event_name]) then
                script.on_event(data.event_name, nil)
                local event_name = event_handlers.event_names[defines.events[data.event_name]] or event_handlers.event_names[data.event_name]
                if (event_name) then
                    event_handlers.event[event_name] = nil
                end
            else
                if (data.event_name == "on_nth_tick") then
                    if (data.nth_tick ~= nil and type(data.nth_tick) == "number") then
                        if (data.nth_tick >= 0) then
                            script.on_nth_tick(data.nth_tick, nil)
                            event_handlers.events["on_nth_tick"][data.nth_tick] = nil
                        else
                            script.on_nth_tick(nil)
                            event_handlers.events["on_nth_tick"] = nil
                        end
                    end
                elseif (data.event_name == "on_load") then
                    script.on_load(nil)
                    event_handlers.event["on_load"] = nil
                elseif (data.event_name == "on_configuration_changed") then
                    script.on_configuration_changed(nil)
                    event_handlers.event["on_configuration_changed"] = nil
                end
            end
        end

        --[[ TODO: Implement specific copying/saving, rather than clonging the entire table every time ]]
        local cleaned_event_handlers_copy = deepcopy_exclude_functions(event_handlers)
        log(serpent.block(cleaned_event_handlers_copy))

        storage.event_handlers = cleaned_event_handlers_copy
    end
end

function event_handlers:get_event_position(data)
    Log.debug("event_handlers:get_event_position")
    Log.info(data)
    -- log(serpent.block(data))

    if (not data or type(data) ~= "table") then return end
    if (not data.event_name or type(data.event_name) ~= "string") then return end
    if (not data.source_name or type(data.source_name) ~= "string") then return end
    data.event_name = data.event_name:lower()
    data.source_name = data.source_name:lower()

    if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then return end

    local event = nil
    if (data.event_name == "on_nth_tick" and event_handlers.events["on_nth_tick"]) then
        if (data.nth_tick ~= nil) then
            if (type(data.nth_tick) == "number" and data.nth_tick >= 0) then
                event = event_handlers.events["on_nth_tick"][data.nth_tick]
            end
        end
    else
        local event_name = event_handlers.event_names[defines.events[data.event_name]] or event_handlers.event_names[data.event_name]
        if (event_name) then
            event = event_handlers.events[event_name]
        end
    end

    if (    event
        and event.sources
        and event.sources[data.source_name]
        and type(event.sources[data.source_name]) == "number"
        and event.sources[data.source_name] > 0
    ) then
        if (event.order and event.order[event.sources[data.source_name]]) then
            return event.sources[data.source_name]
        end
    end
    -- log(serpent.block(event))
end

function event_handlers:set_event_position(data)
    Log.debug("event_handlers:set_event_position")
    Log.info(data)
    log(serpent.block(data))

    if (not data or type(data) ~= "table") then return end
    if (data.new_position == nil or type(data.new_position) ~= "number") then return end
    if (not data.event_name or type(data.event_name) ~= "string") then return end
    if (not data.source_name or type(data.source_name) ~= "string") then return end
    data.event_name = data.event_name:lower()
    data.source_name = data.source_name:lower()

    if (defines.events[data.event_name] == nil and not event_name_black_list[data.event_name]) then return end

    local event = nil
    if (data.event_name == "on_nth_tick" and event_handlers.events["on_nth_tick"]) then
        if (data.nth_tick ~= nil) then
            if (type(data.nth_tick) == "number" and data.nth_tick >= 0) then
                event = event_handlers.events["on_nth_tick"][data.nth_tick]
            end
        end
    else
        local event_name = event_handlers.event_names[defines.events[data.event_name]] or event_handlers.event_names[data.event_name]
        if (event_name) then
            event = event_handlers.events[event_name]
        end
    end

    -- log(serpent.block(event))
    if (    event
        and event.sources
        and event.sources[data.source_name]
        and type(event.sources[data.source_name]) == "number"
        and event.sources[data.source_name] > 0
    ) then
        if (event.order and event.order[event.sources[data.source_name]]) then
            local original_position = event.sources[data.source_name]
            -- log(serpent.block(original_position))
            if (original_position == data.new_position) then
                return 0
            else
                local event_data = event.dictionary[data.source_name]
                table.remove(event.order, original_position)
                if (data.new_position > 0) then
                    if (data.new_position > #event.order) then
                        table.insert(event.order, event_data)
                    else
                        table.insert(event.order, data.new_position, event_data)
                    end
                else
                    --[[ "1 + " because of the table.remove call above ]]
                    local new_position = 1 + #event.order + data.new_position
                    if (new_position < 1) then new_position = 1 end
                    table.insert(event.order, new_position, event_data)
                end

                local new_dictionary, new_sources = {}, {}
                local i = 1
                while event.order and i <= #event.order do
                    event.order[i].index = i
                    new_sources[event.order[i].source_name] = i
                    new_dictionary[event.order[i].source_name] = event.order[i]

                    i = i + 1
                end

                event.sources = new_sources
                event.dictionary = new_dictionary
            end
        end
    end
    -- log(serpent.block(event))
end

event_handlers.configurable_nukes = true

local _event_handlers = event_handlers

return event_handlers