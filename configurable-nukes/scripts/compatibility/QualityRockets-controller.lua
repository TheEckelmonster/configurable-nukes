local quality_rockets_controller = {}
quality_rockets_controller.name = "quality_rockets_controller"

quality_rockets_controller.filter = Filters.rocket_silo_controller

local robot_cargo_inventory = defines.inventory.robot_cargo

--[[
    The following function [swap_silos] is effectively a straight copy from QualityRockets
    control.lua of the on_built function, adapted for configurable-nukes to allow
    parity with the ipbm-rocket-silos

    Credit: Moterius
    License: CC BY-NC-SA, https://creativecommons.org/licenses/by-nc-sa/4.0/
]]
local function swap_silos(event)
    if (not event) then return end

    local entity = event.entity
    local entity_name = entity.name
    local rocket_parts = entity.rocket_parts
    local products_finished = entity.products_finished

    local surface = entity.surface
    local quality = entity.quality
    local silo_to_create = {
        name = entity.quality.name .. "-" .. entity.name,
        position = entity.position,
        quality = entity.quality,
        force = entity.force,
        fast_replace = true,
        player = entity.last_user,
        raise_built = true,
    }

    script.raise_script_destroy({ entity = entity, })
    local created_entity = surface.create_entity(silo_to_create)
    if (created_entity and created_entity.valid) then
        if (rocket_parts) then created_entity.rocket_parts = rocket_parts end
        if (products_finished) then created_entity.products_finished = products_finished end
    end

    if (event.robot and event.robot.valid) then
        event.robot.get_inventory(robot_cargo_inventory).remove({ name = entity_name, count = 1, quality = quality, })
    end

    if (not event.player_index) then return end
    game.get_player(event.player_index).remove_item({ name = entity_name, count = 1, quality = quality, })
end

function quality_rockets_controller.rocket_silo_built(event)
    -- Log.debug("quality_rockets_controller.rocket_silo_built")
    -- Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end
    if (not event.entity.type == "rocket-silo") then return end
    if (event.entity.name ~= "ipbm-rocket-silo") then return end
    if (not event.entity.surface or not event.entity.surface.valid) then return end
    if (not event.entity.quality or event.entity.quality.level == 0) then return end

    swap_silos(event)
end
Event_Handler:register_events({
    {
        event_name = "on_built_entity",
        source_name = "quality_rockets_controller.rocket_silo_built",
        func_name = "quality_rockets_controller.rocket_silo_built",
        func = quality_rockets_controller.rocket_silo_built,
        filter = quality_rockets_controller.filter,
    },
    {
        event_name = "on_robot_built_entity",
        source_name = "quality_rockets_controller.rocket_silo_built",
        func_name = "quality_rockets_controller.rocket_silo_built",
        func = quality_rockets_controller.rocket_silo_built,
        filter = quality_rockets_controller.filter,
    },
    {
        event_name = "script_raised_built",
        source_name = "quality_rockets_controller.rocket_silo_built",
        func_name = "quality_rockets_controller.rocket_silo_built",
        func = quality_rockets_controller.rocket_silo_built,
        filter = quality_rockets_controller.filter,
    },
    {
        event_name = "script_raised_revive",
        source_name = "quality_rockets_controller.rocket_silo_built",
        func_name = "quality_rockets_controller.rocket_silo_built",
        func = quality_rockets_controller.rocket_silo_built,
        filter = quality_rockets_controller.filter,
    },
})

function quality_rockets_controller.on_space_platform_built_entity(event)
    -- Log.debug("quality_rockets_controller.on_space_platform_built_entity")
    -- Log.info(event)

    if (not event) then return end
    if (not event.entity or not event.entity.valid) then return end
    if (not event.entity.type == "rocket-silo") then return end
    if (event.entity.name ~= "ipbm-rocket-silo" and event.entity.name ~= "rocket-silo") then return end
    if (not event.entity.surface or not event.entity.surface.valid) then return end
    if (not event.entity.quality or event.entity.quality.level == 0) then return end

    swap_silos(event)
end
Event_Handler:register_event({
    event_name = "on_space_platform_built_entity",
    source_name = "quality_rockets_controller.on_space_platform_built_entity",
    func_name = "quality_rockets_controller.on_space_platform_built_entity",
    func = quality_rockets_controller.on_space_platform_built_entity,
    filter = quality_rockets_controller.filter,
})

return quality_rockets_controller