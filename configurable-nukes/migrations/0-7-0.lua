local ICBM_Meta_Repository = require("scripts.repositories.ICBM-meta-repository")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")
local ICBM_Utils = require("scripts.utils.ICBM-utils")

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.7.0 Migration")
    --[[ Version 0.7.0:
        -> removed item_numbers from icbm_meta_data
        -> changed/enforced icbm_meta_data.surface_name instead of icbm_meta_data.planet_name

        -> Event_Handler system indtroduced
        -> Move existing inflight rockets to registered scheduled events
        -> icbm_data.event_handlers field introduced
    ]]
    if (storage_old.configurable_nukes.icbm_meta_data) then
        local all_icbm_meta_data = storage_old.configurable_nukes.icbm_meta_data
        for k, icbm_meta_data in pairs(all_icbm_meta_data) do
            icbm_meta_data.item_numbers = nil
            icbm_meta_data.surface_name = icbm_meta_data.planet_name
            icbm_meta_data.planet_name = nil
            ICBM_Meta_Repository.update_icbm_meta_data(icbm_meta_data)

            if (icbm_meta_data.in_transit) then
                for icbm_data, _  in pairs(icbm_meta_data.in_transit) do
                    icbm_data.event_handlers = {}
                    ICBM_Utils.register_delivery_data({ icbm_data = icbm_data })
                    icbm_meta_data.in_transit[icbm_data] = nil
                    ICBM_Repository.update_icbm_data(icbm_data)
                end
            end

            if (icbm_meta_data.icbms) then
                for k_2, icbm_data in pairs(icbm_meta_data.icbms) do
                    icbm_data.event_handlers = {}
                    ICBM_Repository.update_icbm_data(icbm_data)
                end
            end
        end
    end
end