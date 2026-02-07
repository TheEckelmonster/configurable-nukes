return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.7.1 Migration")
    --[[ Version 0.7.1:
        -> changed:
            storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index][item_number]
            to
            storage.gui_data[player.index][Rocket_Dashboard_Constants.gui_data_index].item_numbers[item_number]
    ]]
    if (storage.gui_data) then
        for _, gui_data in pairs(storage.gui_data) do
            for _, storage_ref in pairs(gui_data) do
                for k, v in pairs(storage_ref) do
                    if (type(k) == "number" and k >=1) then
                        if (storage_ref[k].icbm_data or storage_ref[k].surface_name) then
                            if (not storage_ref.item_numbers) then storage_ref.item_numbers = {} end
                            storage_ref.item_numbers[k] = v
                            storage_ref[k] = nil
                        end
                    end
                end
            end
        end
    end
end