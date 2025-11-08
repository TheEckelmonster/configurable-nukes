local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Custom_Input = require("prototypes.custom-input.custom-input")

local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")
local Rocket_Dashboard_Gui_Service = require("scripts.services.guis.rocket-dashboard-gui-service")
local Rocket_Silo_Constants = require("scripts.constants.rocket-silo-constants")
local Rocket_Silo_Service = require("scripts.services.rocket-silo-service")
local Rocket_Silo_Validations = require("scripts.validations.rocket-silo-validations")
local Spaceship_Service = require("scripts.services.spaceship-service")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_controller = {}
rocket_silo_controller.name = "rocket_silo_controller"

rocket_silo_controller.filter = Rocket_Silo_Constants.event_filter
-- {
--     { filter = "type", type = "rocket-silo" },
--     { filter = "name", name = "rocket-silo", mode = "and" },
--     { filter = "type", type = "rocket-silo" },
--     { filter = "name", name = "ipbm-rocket-silo", mode = "and" },
-- }

function rocket_silo_controller.rocket_silo_built(event)
    Log.debug("rocket_silo_controller.rocket_silo_built")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
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
    if (not event.source or not event.source.valid) then return end
    if (not event.destination or not event.destination.valid) then return end

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

    Rocket_Silo_Service.rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    Spaceship_Service.rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })

    ICBM_Utils.rocket_silo_cloned({
        tick = event.tick,
        source_silo = source_silo,
        destination_silo = destination_silo,
    })
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
        tick = game.tick,
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
        tick = game.tick,
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
        tick = game.tick,
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

function rocket_silo_controller.launch_rocket(event)
    Log.debug("rocket_silo_controller.launch_rocket")
    Log.info(event)

    if (not event) then return end
    if (not event.tick) then return end

    if (not event.item or event.item ~= "ICBM-remote") then return end
    if (not event.player_index or not event.area) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    if (not Rocket_Silo_Validations.is_targetable_surface({ surface = event.surface, player = player })) then return end

    local return_val, return_data = Rocket_Silo_Service.launch_rocket(event)

    if (type(return_val) == "number" and return_val == 1) then
        if (type(return_data) == "table" and return_data.valid) then
            local icbm_data = ICBM_Repository.get_icbm_data(return_data.surface_name, return_data.item_number, { validate_fields = true })
            if (not icbm_data or not icbm_data.valid) then return end

            Rocket_Dashboard_Gui_Service.add_rocket_data_for_force({
                icbm_data = icbm_data,
            })
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
    Log.debug("rocket_silo_controller.on_cargo_pod_finished_ascending")
    Log.info(event)

    if (not event) then return end
    if (not event.cargo_pod or not event.cargo_pod.valid) then return end
    if (not event.cargo_pod.surface or not event.cargo_pod.surface.valid) then return end

    --[[ The right idea, but not quite the needed implementation
        -> Need one specific for "launchable" surfaaces
        TODO: Above
    ]]
    -- if (not Rocket_Silo_Validations.is_targetable_surface({ surface = event.cargo_pod.surface, })) then return end

    Rocket_Silo_Service.on_cargo_pod_finished_ascending(event)
end
Event_Handler:register_event({
    event_name = "on_cargo_pod_finished_ascending",
    source_name = "rocket_silo_controller.on_cargo_pod_finished_ascending",
    func_name = "rocket_silo_controller.on_cargo_pod_finished_ascending",
    func = rocket_silo_controller.on_cargo_pod_finished_ascending,
})

function rocket_silo_controller.on_space_platform_built_entity(event)
    Log.debug("rocket_silo_controller.on_space_platform_built_entity")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.rocket_silo_built(rocket_silo)
end
Event_Handler:register_event({
    event_name = "on_space_platform_built_entity",
    source_name = "rocket_silo_controller.on_space_platform_built_entity",
    func_name = "rocket_silo_controller.on_space_platform_built_entity",
    func = rocket_silo_controller.on_space_platform_built_entity,
    filter = rocket_silo_controller.filter,
})

function rocket_silo_controller.on_space_platform_mined_entity(event)
    Log.debug("rocket_silo_controller.on_space_platform_mined_entity")
    Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end

    local rocket_silo = event.entity
    if (not rocket_silo.surface or not rocket_silo.surface.valid) then return end
    local surface = rocket_silo.surface

    if (String_Utils.find_invalid_substrings(surface.name)) then return end

    Rocket_Silo_Service.on_space_platform_mined_entity(event)
end
Event_Handler:register_event({
    event_name = "on_space_platform_mined_entity",
    source_name = "rocket_silo_controller.on_space_platform_mined_entity",
    func_name = "rocket_silo_controller.on_space_platform_mined_entity",
    func = rocket_silo_controller.on_space_platform_mined_entity,
    filter = rocket_silo_controller.filter,
})

return rocket_silo_controller