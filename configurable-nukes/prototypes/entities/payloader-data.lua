local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local se_active = mods and mods["space-exploration"] and true

--[[ payloader-corpse ]]
local payloader_corpse = Util.table.deepcopy(data.raw["corpse"]["assembling-machine-3-remnants"])
payloader_corpse.name = "payloader-remnants"
payloader_corpse.icon = "__configurable-nukes__/graphics/icons/payloader.png"
payloader_corpse.animation = make_rotated_animation_variations_from_sheet(3,
{
    filename = "__configurable-nukes__/graphics/entity/payloader/remnants/payloader-remnants.png",
    line_length = 1,
    width = 328,
    height = 282,
    direction_count = 1,
    shift = Util.by_pixel(0, 9.5),
    scale = 0.5
})

data:extend({ payloader_corpse, })

--[[ payloader ]]
local payloader = Util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])

payloader.name = "payloader"
payloader.icon = "__configurable-nukes__/graphics/icons/payloader.png"
payloader.flags = { "placeable-neutral", "placeable-player", "player-creation", "no-automated-item-removal", "no-automated-item-insertion", }
payloader.minable.result = "payloader"
payloader.max_health = payloader.max_health * 1.25
payloader.corpse = "payloader-remnants"
payloader.resistances =
{
    {
        type = "fire",
        percent = 85,
    },
    {
        type = "impact",
        percent = 35,
    },
    {
        type = "explosion",
        percent = 50,
    },
    {
        type = "electric",
        percent = 35,
    },
}

payloader.fluid_boxes_off_when_no_fluid_recipe = false

for _, pipe_connections in ipairs(payloader.fluid_boxes) do
    for _, t in pairs({
        pipe_connections.pipe_covers or {},
        pipe_connections.pipe_covers_frozen or {},
        pipe_connections.pipe_picture or {},
        pipe_connections.pipe_picture_frozen or {},
    }) do
        for _, pipe_connection in pairs(t) do
            if (pipe_connection.layers) then
                for _, layer in ipairs(pipe_connection.layers) do
                    layer.filename = "__configurable-nukes__/graphics/icons/empty.png"
                    layer.height = 64
                    layer.width = 64
                end
            else
                pipe_connection.filename = "__configurable-nukes__/graphics/icons/empty.png"
                pipe_connection.height = 64
                pipe_connection.width = 64
            end
        end
    end
end

payloader.collision_box = {{-1.3, -1.3}, {1.3, 1.3}}
payloader.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}

local layers =
{
    {
        filename = "__configurable-nukes__/graphics/entity/payloader/payloader.png",
        priority = "high",
        width = 214,
        height = 237,
        frame_count = 32,
        line_length = 8,
        shift = Util.by_pixel(0, -0.75),
        scale = 0.5,
    },
    {
        filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3-shadow.png",
        priority = "high",
        width = 260,
        height = 162,
        frame_count = 32,
        line_length = 8,
        draw_as_shadow = true,
        shift = Util.by_pixel(28, 4),
        scale = 0.5,
    },
}

payloader.graphics_set =
{
    animation_progress = 0.5,
    animation =
    {
        north = { layers = Util.table.deepcopy(layers), },
        east = { layers = Util.table.deepcopy(layers), },
        south = { layers = Util.table.deepcopy(layers), },
        west = { layers = Util.table.deepcopy(layers), },
    },
}

payloader.crafting_categories = { "payload-change", }
payloader.crafting_speed = 1
payloader.energy_source =
{
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 2, },
    buffer_capacity = "1kJ",
    drain = "100kW",
}
payloader.energy_usage = "500kW"
payloader.ingredient_count = 0
payloader.module_slots = 2
payloader.allowed_effects = { "consumption", "pollution" }

data:extend({ payloader, })

--[[ containers ]]

data:extend({
    {
        type = "container",
        name = "payloader-container-input",
        icon = "__configurable-nukes__/graphics/icons/payloader.png",
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "not-on-map" },
        hidden = true,
        factoriopedia_alternative = "payloader",
        max_health = payloader.max_health,
        resistances = payloader.resistances,
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        collision_mask = {
            layers = {},
        },
        collision_box = { { -1.5, -0.5 }, { 1.5, 0.5 }, },
        selection_box = { { -1.5, -0.5 }, { 1.5, 0.5 }, },
        picture = {
            filename = "__configurable-nukes__/graphics/icons/empty.png",
            size = 1,
        },
        inventory_size = 2,
        inventory_type = "with_filters_and_bar",
        circuit_connector = circuit_connector_definitions["offshore-pump"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        selection_priority = 52,
    },
    {
        type = "container",
        name = "payloader-container-output",
        icon = "__configurable-nukes__/graphics/icons/payloader.png",
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "not-on-map" },
        hidden = true,
        factoriopedia_alternative = "payloader",
        max_health = payloader.max_health,
        resistances = payloader.resistances,
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        collision_mask = {
            layers = {},
        },
        collision_box = { { -1.5, -0.5 }, { 1.5, 0.5 }, },
        selection_box = { { -1.5, -0.5 }, { 1.5, 0.5 }, },
        picture = {
            filename = "__configurable-nukes__/graphics/icons/empty.png",
            size = 1,
        },
        inventory_size = 2,
        inventory_type = "with_filters_and_bar",
        circuit_connector = circuit_connector_definitions["offshore-pump"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        selection_priority = 52,
    },
    {
        type = "container",
        name = "payloader-container-input-vertical",
        icon = "__configurable-nukes__/graphics/icons/payloader.png",
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "not-on-map" },
        hidden = true,
        factoriopedia_alternative = "payloader",
        max_health = payloader.max_health,
        resistances = payloader.resistances,
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        collision_mask = {
            layers = {},
        },
        collision_box = { { -0.5, -1.5 }, { 0.5, 1.5, }, },
        selection_box = { { -0.5, -1.5 }, { 0.5, 1.5, }, },
        picture = {
            filename = "__configurable-nukes__/graphics/icons/empty.png",
            size = 1,
        },
        inventory_size = 2,
        inventory_type = "with_filters_and_bar",
        circuit_connector = circuit_connector_definitions["offshore-pump"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        selection_priority = 52,
    },
    {
        type = "container",
        name = "payloader-container-output-vertical",
        icon = "__configurable-nukes__/graphics/icons/payloader.png",
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "not-on-map" },
        hidden = true,
        factoriopedia_alternative = "payloader",
        max_health = payloader.max_health,
        resistances = payloader.resistances,
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        collision_mask = {
            layers = {},
        },
        collision_box = { { -0.5, -1.5 }, { 0.5, 1.5, }, },
        selection_box = { { -0.5, -1.5 }, { 0.5, 1.5, }, },
        picture = {
            filename = "__configurable-nukes__/graphics/icons/empty.png",
            size = 1,
        },
        inventory_size = 2,
        inventory_type = "with_filters_and_bar",
        circuit_connector = circuit_connector_definitions["offshore-pump"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        selection_priority = 52,
    },
})