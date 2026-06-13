local pairs = pairs
local table_insert = table.insert

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    local storage = storage

    log("Version 0.9.11 Migration")
    --[[ Version 0.9.11:
        -> changed:
            storage.payloader
              - iteration on Nth tick = 60
        to
            storage.ordered_payloaders
              - iteration on tick, time sliced by unit number over 60 ticks
    ]]
    local payloaders_old = storage_old.payloaders
    local payloaders = storage.payloaders

    for k, v in pairs(payloaders_old or {}) do
        payloaders[k] = payloaders[k] or v
    end

    storage.ordered_payloaders = {}
    local create_inventory = game.create_inventory
    local ordered_payloaders = storage.ordered_payloaders
    for unit_number, payloader in pairs(payloaders or {}) do
        payloader.internal_inventory = payloader.internal_inventory or create_inventory(1)
        ordered_payloaders[unit_number % 60] = ordered_payloaders[unit_number % 60] or {}
        table_insert(ordered_payloaders[unit_number % 60], payloader)
    end
end