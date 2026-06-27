local table = table
local table_insert = table.insert

local Payloader_Data = Circuit_Network_Payloader_Data

local Payloader_Controller = require("scripts.controllers.payloader-controller")
-- local Payloader_Data = require("scripts.data.circuit-network.payloader-data")

local technologies = {
    ["icbms"] = 1,
    ["ipbms"] = 1,
    ["rocket-control-unit"] = 1,
    ["cn-mirvs"] = 1,
    ["cn-atomic-warhead"] = 1,
    ["cn-jericho"] = 1,
    ["cn-rod-from-god"] = 1,
    ["cn-tesla-rocket"] = 1,
}

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.10.0 Migration: payloader")
    --[[ Version 0.10.0:
        -> changed:
            added:
              - surface_name
              - circuit_network_data (Payloader_Data)
            to -> payloaders[unit_number].

            removed from same
              - force
              - surface
            
        -> changed:
            guidance-systems -> cn-bral (ballistic-rocketry-and-logistics)

        -> Introduced CN-Extended (AV, ME, & PR)

    ]]

    local all_payloaders = {}
    local payloader_array = nil
    for k, surface in pairs(game.surfaces) do
        payloader_array = surface.find_entities_filtered({ name = "payloader", })
        for _, payloader in ipairs(payloader_array or {}) do
            if (payloader and payloader.valid) then
                all_payloaders[#payloader_array+1] = payloader
            end
        end
    end

    storage.payloaders = storage.payloaders or {}
    local payloaders = storage.payloaders
    local payloader = nil
    for _, _payloader in ipairs(all_payloaders) do
        if (_payloader and _payloader.valid) then
            payloader = payloaders[_payloader.unit_number]
            if (not payloader) then
                Payloader_Controller.on_entity_created({ entity = _payloader, })
                payloader = payloaders[_payloader.unit_number]
                if (not payloader) then goto continue end
            end

            payloader.surface_name = payloader.surface_name or payloader.entity.surface.name

            payloader.circuit_network_data = payloader.circuit_network_data or Payloader_Data:new({
                unit_number = payloader.entity.unit_number,
                -- entity = entity,
                -- surface = entity.surface,
                surface_index = payloader.entity.surface.index,
                surface_name = payloader.entity.surface.name,
                manual_entry = {
                    launch = 0,
                    x = 0,
                    y = 0,
                    space_location_index = payloader.entity.surface.index,
                },
            })

            payloader.force = nil
            payloader.surface = nil
        end
        ::continue::
    end

    -- storage.ordered_payloaders = storage.ordered_payloaders or {}
    -- local ordered_payloaders = storage.ordered_payloaders

    -- for unit_number, payloader in pairs(payloaders) do
    --     local mod = unit_number % 60
    --     ordered_payloaders[mod] = ordered_payloaders[mod] or {}
    --     table_insert(ordered_payloaders[mod], payloader)
    -- end

    --[[ Technology ]]
    for f_name, force in pairs(game.forces) do
        if (force.valid) then
            local icbms = force.technologies["icbms"]
            if (icbms and icbms.valid and icbms.researched) then
                if (force.technologies["cn-payloader"] and force.technologies["cn-payloader"].valid) then
                    force.technologies["cn-payloader"].research_recursive()
                end
            end

            for t_name, _ in pairs(technologies) do
                if (force.technologies[t_name] and force.technologies[t_name].valid) then
                    if (force.technologies[t_name].researched) then
                        force.technologies[t_name].research_recursive()
                    end
                end
            end
        end
    end
end