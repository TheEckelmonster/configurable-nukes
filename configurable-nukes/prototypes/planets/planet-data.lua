
local sa_active = mods and mods["space-age"] and true

if (not sa_active) then return end

local exemption_rules = {}

for k, _ in pairs(defines.prototypes["entity"]) do
    -- log(serpent.block(k))
    if (data and data.raw and data.raw[k]) then
        for _, v in pairs(data.raw[k]) do
            table.insert(exemption_rules, { type = "prototype", string = v.name, })
        end
    end
end

local _lightning_properties =
{
    lightnings_per_chunk_per_tick = 0,
    search_radius = 0,
    lightning_types = { "lightning", },
    lightning_warning_icon =
    {
        filename = "__configurable-nukes__/graphics/icons/empty.png",
        size = 64,
    },
    -- exemption_rules = exemption_rules,
}

for k, v in pairs(data.raw["planet"]) do
    local lightning_properties = v.lightning_properties

    if (not lightning_properties) then
        v.lightning_properties = _lightning_properties
    else
        if (lightning_properties.lightning_types) then
            local found = false
            for i, j in pairs(lightning_properties.lightning_types) do
                if (j == "lightning") then
                    found = true
                    break
                end
            end

            if (not found) then
                table.insert(lightning_properties.lightning_types, "lightning")
            end
        end
    end
end