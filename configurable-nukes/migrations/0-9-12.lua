local pairs = pairs

local PAYLOADER_TECHNOLOGY = "cn-payloader"

return function(params)
    params = params or {}

    local storage_old = params.storage_old or storage and storage.storage_old
    local storage = storage

    log("Version 0.9.12 Migration")
    --[[ Version 0.9.11:
        -> changed:
            Guidance Systems -> Ballistic Rocketry and Logistics
              -> Payload Automation
    ]]

    local game = game
    local forces = game.forces
    for _, force in pairs(forces or {}) do
        if (force.valid and force.technologies.icbms.researched) then
            force.technologies[PAYLOADER_TECHNOLOGY].research_recursive()
        end
    end
end