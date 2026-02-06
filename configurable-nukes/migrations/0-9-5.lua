return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    if (not storage_old) then return end
    if (type(storage_old) ~= "table") then return end

    log("Version 0.9.5 Migration")
    --[[ Version 0.9.5:
        -> changed:
    ]]
end