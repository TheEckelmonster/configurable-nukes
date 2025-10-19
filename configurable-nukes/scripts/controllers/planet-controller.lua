-- If already defined, return
if _planet_controller and _planet_controller.configurable_nukes then
    return _planet_controller
end

local Event_Handler = require("scripts.event-handler")
local Log = require("libs.log.log")
local Planet_Service = require("scripts.services.planet-service")

local planet_controller = {}

function planet_controller.on_surface_created(event)
    Log.debug("planet_controller.on_surface_created")
    Log.info(event)
    Planet_Service.on_surface_created(event)
end
Event_Handler:register_event({
    event_name = "on_surface_created",
    source_name = "planet_controller.on_surface_created",
    func = planet_controller.on_surface_created,
})

function planet_controller.on_surface_deleted(event)
    Log.debug("planet_controller.on_surface_deleted")
    Log.info(event)
    Planet_Service.on_surface_deleted(event)
end
Event_Handler:register_event({
    event_name = "on_surface_deleted",
    source_name = "planet_controller.on_surface_deleted",
    func = planet_controller.on_surface_deleted,
})

function planet_controller.on_pre_surface_deleted(event)
    Log.debug("planet_controller.on_pre_surface_deleted")
    Log.info(event)
    Planet_Service.on_pre_surface_deleted(event)
end
Event_Handler:register_event({
    event_name = "on_pre_surface_deleted",
    source_name = "planet_controller.on_pre_surface_deleted",
    func = planet_controller.on_pre_surface_deleted,
})

planet_controller.configurable_nukes = true

local _planet_controller = planet_controller

return planet_controller