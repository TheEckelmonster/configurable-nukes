local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Planet_Service = require("scripts.services.planet-service")

local planet_controller = {}
planet_controller.name = "planet_controller"

function planet_controller.on_surface_created(event)
    Log.debug("planet_controller.on_surface_created")
    Log.info(event)
    Planet_Service.on_surface_created(event)
end
Event_Handler:register_event({
    event_name = "on_surface_created",
    source_name = "planet_controller.on_surface_created",
    func_name = "planet_controller.on_surface_created",
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
    func_name = "planet_controller.on_surface_deleted",
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
    func_name = "planet_controller.on_pre_surface_deleted",
    func = planet_controller.on_pre_surface_deleted,
})

return planet_controller