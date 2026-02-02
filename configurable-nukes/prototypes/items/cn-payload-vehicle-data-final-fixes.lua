local Constants = require("scripts.constants.constants")

local projectile_placeholder_data = data.raw["mod-data"][Constants.mod_name .. "-projectile-placeholder-data"].data

local cn_payload_vehicle = data.raw["item-with-inventory"]["cn-payload-vehicle"]

if (not cn_payload_vehicle) then return end

for k, v in pairs(data.raw["land-mine"]) do
    if (projectile_placeholder_data[v.name]) then
        table.insert(cn_payload_vehicle.item_filters, v.name)
    end
end