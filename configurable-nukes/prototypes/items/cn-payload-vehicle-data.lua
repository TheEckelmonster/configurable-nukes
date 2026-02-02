-- local Item_Sounds = require("__base__.prototypes.item_sounds")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local function item_sound(filename, volume)
    return
    {
        filename = "__base__/sound/item/" .. filename,
        volume = volume,
        aggregation = {max_count = 1, remove = true},
    }
end

local Item_Sounds = {
    mechanical_inventory_move = item_sound("mechanical-inventory-move.ogg", 0.7),
    mechanical_inventory_pickup = item_sound("mechanical-inventory-pickup.ogg", 0.8)
}

local function mod_added()
    local function return_list_as_params(...)
        local return_arg = (...) and table.remove((...))

        if (return_arg) then
            return return_arg, return_list_as_params((...))
        else
            return
        end
    end

    local mod_added_subgroups = {
        mods and mods["bobwarfare"] and "bob-ammo" or nil,
        mods and mods["Krastorio2-spaced-out"] and {
            "kr-railgun-turret",
            "kr-rocket-turret",
        } or nil,
        mods and mods["RampantArsenalFork"] and "launcher-capsule" or nil,
        mods and mods["strategy-mortar-turret"] and "mortar-ammo" or nil,
    }

    local mod_added_array = {}
    for _, v in pairs(mod_added_subgroups) do
        if (type(v) == "table") then
            if (v[1]) then
                for __, _v in pairs(v) do
                    table.insert(mod_added_array, _v)
                end
            end
        else
            table.insert(mod_added_array, v)
        end
    end

    return return_list_as_params(mod_added_array)
end

data:extend({
    {
        type = "item-with-inventory",
        name = "cn-payload-vehicle",
        icons =
        {
            { icon = "__configurable-nukes__/graphics/icons/payload-vehicle.png", icon_size = 173 }
        },
        subgroup = "space-related",
        order = "d[rocket-parts]-e[satellite]",
        inventory_move_sound = Item_Sounds.mechanical_inventory_move,
        pick_sound = Item_Sounds.mechanical_inventory_pickup,
        drop_sound = Item_Sounds.mechanical_inventory_move,
        stack_size = 1,
        weight = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_WEIGHT_MODIFIER.name }) * tons,
        send_to_orbit_mode = "manual",
        flags = flags,
        inventory_size = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PAYLOAD_VEHICLE_INVENTORY_SIZE.name }),
        item_filters = {
            "explosives",
            "land-mine",
        },
        item_group_filters = {},
        item_subgroup_filters = {
            "payload",
            "ammo",
            "capsule",
            mod_added(),
        },
        filter_mode = "whitelist",
        filter_message_key = "item-limitation.cn-payload-vehicle",
    },
})
