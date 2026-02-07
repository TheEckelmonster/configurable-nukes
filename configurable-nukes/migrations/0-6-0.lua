local Circuit_Network_Rocket_Silo_Data = require("scripts.data.circuit-network.rocket-silo-data")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.6.0 Migration")
    --[[ Version 0.6.0:
        -> switched to encapsulating the gui/circuit_network_data into its own object
    ]]
    if (storage_old.configurable_nukes) then
        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
            local all_rocket_silo_meta_data = storage_old.configurable_nukes.rocket_silo_meta_data
            for k, v in pairs(all_rocket_silo_meta_data) do
                for k_2, v_2 in pairs(v.rocket_silos) do
                    if (v_2.signals) then
                        v_2.circuit_network_data = Circuit_Network_Rocket_Silo_Data:new({
                            entity = v_2.entity,
                            unit_number = v_2.entity and v_2.entity.valid and v_2.entity.unit_number,
                            surface = v_2.entity and v_2.entity.valid and v_2.entity.surface and v_2.entity.surface.valid and v_2.entity.surface,
                            surface_name = v_2.entity and v_2.entity.valid and v_2.entity.surface and v_2.entity.surface.valid and v_2.entity.surface.name,
                            signals = v_2.signals,
                        })

                        Rocket_Silo_Repository.update_rocket_silo_data(v_2.entity, v_2)
                    end
                end
            end
        end
    end
end