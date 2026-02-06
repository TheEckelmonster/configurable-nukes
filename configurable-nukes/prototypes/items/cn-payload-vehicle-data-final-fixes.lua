local Constants = require("scripts.constants.constants")

local projectile_placeholder_data = data.raw["mod-data"][Constants.mod_name .. "-projectile-placeholder-data"].data

local cn_payload_vehicle = data.raw["item-with-inventory"]["cn-payload-vehicle"]

if (not cn_payload_vehicle) then return end

local existing_item_filters = {}
for k, v in pairs(cn_payload_vehicle.item_filters) do
    if (not existing_item_filters[v]) then
        existing_item_filters[v] = k
    end
end

for k, v in pairs(data.raw["land-mine"]) do
    if (projectile_placeholder_data[v.name]) then
        if (not existing_item_filters[v.name]) then
            table.insert(cn_payload_vehicle.item_filters, v.name)
        end
    end
end

local existing_item_subgroup_filters = {}
for k, v in pairs(cn_payload_vehicle.item_subgroup_filters) do
    if (not existing_item_subgroup_filters[v]) then
        existing_item_subgroup_filters[v] = k
    end
end

local subgroups = projectile_placeholder_data.subgroups or {}
for k, v in pairs(subgroups) do
    if (not existing_item_subgroup_filters[k]) then
        table.insert(cn_payload_vehicle.item_subgroup_filters, k)
    end
end