local storage

local Event_Handler = Event_Handler

local research_controller = {}
research_controller.name = "research_controller"

local names = {
    ["icbms"] = 1,
    ["ipbms"] = 1,
}

function research_controller.on_research_finished(event)
    if (not event) then return end

    local research = event.research
    if (not research or not research.valid) then return end
    if (not research.force or not research.force.valid or not research.force.index) then return end
    if (not names[research.name]) then return end

    storage[research.name .. "_researched"] = storage[research.name .. "_researched"] or {}
    storage[research.name .. "_researched"][research.force.index] = game.tick
end
Event_Handler:register_event({
    event_name = "on_research_finished",
    source_name = "research_controller.on_research_finished",
    func_name = "research_controller.on_research_finished",
    func = research_controller.on_research_finished,
})

function research_controller.on_console_command(event)
    if (not event) then return end

    local player = event.player_index and game.get_player(event.player_index) or nil
    if (not player or not player.valid) then return end

    local force = player.force
    if (not force or not force.valid) then return end

    local technologies = force.technologies
    if (not technologies or not technologies.valid) then return end

    if (#technologies == 0) then
        storage.icbms_researched = storage.icbms_researched or {}
        storage.icbms_researched[force.index] = nil
        if (not next(storage.icbms_researched)) then storage.icbms_researched = nil end

        storage.ipbms_researched = storage.ipbms_researched or {}
        storage.ipbms_researched[force.index] = nil
        if (not next(storage.ipbms_researched)) then storage.ipbms_researched = nil end
    else
        if (technologies["icbms"] and technologies["icbms"].researched) then
            storage.icbms_researched = storage.icbms_researched or {}
            storage.icbms_researched[force.index] = storage.icbms_researched[force.index] or game.tick
        else
            storage.icbms_researched = storage.icbms_researched or {}
            storage.icbms_researched[force.index] = nil
        end

        if (technologies["ipbms"] and technologies["ipbms"].researched) then
            storage.ipbms_researched = storage.ipbms_researched or {}
            storage.ipbms_researched[force.index] = storage.ipbms_researched[force.index] or game.tick
        else
            storage.ipbms_researched = storage.ipbms_researched or {}
            storage.ipbms_researched[force.index] = nil
        end
    end
end
Event_Handler:register_event({
    event_name = "on_console_command",
    source_name = "research_controller.on_console_command",
    func_name = "research_controller.on_console_command",
    func = research_controller.on_console_command,
})

function research_controller.init(__storage)
    storage = __storage
end

return research_controller