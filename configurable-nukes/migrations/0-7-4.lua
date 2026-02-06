local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Repository = require("scripts.repositories.ICBM-repository")

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.7.4 Migration")
    --[[ Version 0.7.4:
        -> changed:
            icbm_data.type
            to
            icbm_data.item_name
    ]]
    if (storage_old.configurable_nukes.icbm_meta_data) then
        local all_icbm_meta_data = storage_old.configurable_nukes.icbm_meta_data
        if (type(all_icbm_meta_data) == "table") then
            for k, icbm_meta_data in pairs(all_icbm_meta_data) do
                if (type(icbm_meta_data) == "table" and icbm_meta_data.valid and icbm_meta_data.icbms) then
                    if (type(icbm_meta_data.icbms) == "table") then
                        for k_2, icbm_data in pairs(icbm_meta_data.icbms) do
                            if (type(icbm_data) == "table" and icbm_data.valid) then
                                icbm_data.item_name = icbm_data.type
                                icbm_data.type = ICBM_Data.type
                                ICBM_Repository.update_icbm_data(icbm_data)
                            end
                        end
                    end
                end
            end
        end
    end
end