-- If already defined, return
if _spaceship_service and _spaceship_service.configurable_nukes then
  return _spaceship_service
end

local Constants = require("scripts.constants.constants")
local Log = require("libs.log.log")

local spaceship_service = {}

function spaceship_service.rocket_silo_cloned(data)
    Log.debug("spaceship_service.rocket_silo_cloned")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.source_silo or not data.source_silo.valid) then return end
    if (not data.source_silo.surface or not data.source_silo.surface.valid) then return end
    if (not data.destination_silo or not data.destination_silo.valid) then return end
    if (not data.destination_silo.surface or not data.destination_silo.surface.valid) then return end

    local source = Constants.space_exploration_dictionary[data.source_silo.surface.name:lower()]
    local source_is_spaceship = false
    if (not source) then
        source_is_spaceship = true
        source = Constants["space-exploration"].spaceships[data.source_silo.surface.name:lower()]
    end
    if (not source) then return -1 end
    Log.warn(source.name)
    if (Log.get_log_level().level.num_val <= 2) then
        log(serpent.block(source))
    end
    local destination = Constants.space_exploration_dictionary[data.destination_silo.surface.name:lower()]
    local destination_is_spaceship = false
    if (not destination) then
        destination_is_spaceship = true
        destination = Constants["space-exploration"].spaceships[data.destination_silo.surface.name:lower()]
    end
    if (not destination) then return -1 end
    Log.warn(destination.name)
    if (Log.get_log_level().level.num_val <= 2) then
        log(serpent.block(destination))
    end

    if (source_is_spaceship) then
        Log.warn("source_is_spaceship")
    elseif (destination_is_spaceship) then
        Log.warn("destination_is_spaceship")
        destination.previous_space_location = source
        destination.previous_surface = data.source_silo.surface
        destination.previous_surface_index = data.source_silo.surface.index
        destination.previous_surface_name = data.source_silo.surface.name
    elseif(source_is_spaceship and destination_is_spaceship) then
        --[[ TODO: not sure what to do here yet ]]
        Log.warn("source and destination are spaceships")
    end
end

spaceship_service.configurable_nukes = true

local _spaceship_service = spaceship_service

return spaceship_service