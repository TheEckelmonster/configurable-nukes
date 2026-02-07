return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.5.0 Migration")
    --[[ Version 0.5.0:
        -> changed from using "planet_name" to using "space_location_name"
    ]]
    if (storage_old.configurable_nukes) then
        if (storage_old.configurable_nukes.rocket_silo_meta_data) then
            local all_rocket_silo_meta_data = storage_old.configurable_nukes.rocket_silo_meta_data
            for k, v in pairs(all_rocket_silo_meta_data) do
                if (v.planet_name) then
                    v.space_location_name = v.planet_name
                    --[[
                        I think, by not setting the previous value of v.planet_name to nil,
                        that ?should? maintain backwards compatability if someone were to
                        downgrade, rather than only upgrade
                        Really not sure on this; need to test, but not highest priority.
                        TODO: See above
                    ]]
                end
            end
        end
    end
end