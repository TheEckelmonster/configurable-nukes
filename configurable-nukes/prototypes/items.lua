local item_sounds = require("__base__.prototypes.item_sounds")

-- RANGE_MODIFIER
local get_range_modifier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-range-modifier"]) then
        setting = settings.startup["configurable-nukes-range-modifier"].value
    end

    return setting
end
-- COOLDOWN_MODIFIER
local get_cooldown_modifier = function ()
    local setting = 1

    if (settings and settings.startup and settings.startup["configurable-nukes-cooldown-modifier"]) then
        setting = settings.startup["configurable-nukes-cooldown-modifier"].value
    end

    return setting
end
-- STACK_SIZE
local get_stack_size = function ()
    local setting = 10

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-bomb-stack-size"]) then
        setting = settings.startup["configurable-nukes-atomic-bomb-stack-size"].value
    end

    return setting
end
-- WEIGHT_MODIFIER
local get_weight_modifier = function ()
    local setting = 1.5

    if (settings and settings.startup and settings.startup["configurable-nukes-atomic-bomb-weight-modifier"]) then
        setting = settings.startup["configurable-nukes-atomic-bomb-weight-modifier"].value
    end

    return setting
end

local atomic_bomb_item =
{
    type = "ammo",
    name = "atomic-bomb",
    icon = "__base__/graphics/icons/atomic-bomb.png",
    pictures =
    {
        layers =
        {
            {
                size = 64,
                filename = "__base__/graphics/icons/atomic-bomb.png",
                scale = 0.5,
                mipmap_count = 4
            },
            {
                draw_as_light = true,
                size = 64,
                filename = "__base__/graphics/icons/atomic-bomb-light.png",
                scale = 0.5
            }
        }
    },
    ammo_category = "rocket",
    ammo_type =
    {
        range_modifier = 1.5 * get_range_modifier(),
        cooldown_modifier = 10 * get_cooldown_modifier(),
        target_type = "position",
        action =
        {
            type = "direct",
            action_delivery =
            {
                type = "projectile",
                projectile = "atomic-rocket",
                starting_speed = 0.05,
                source_effects =
                {
                    type = "create-entity",
                    entity_name = "explosion-hit"
                }
            }
        }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-d[atomic-bomb]",
    inventory_move_sound = item_sounds.atomic_bomb_inventory_move,
    pick_sound = item_sounds.atomic_bomb_inventory_pickup,
    drop_sound = item_sounds.atomic_bomb_inventory_move,
    stack_size = get_stack_size(),
    weight = get_weight_modifier() * tons
}

data:extend({atomic_bomb_item})