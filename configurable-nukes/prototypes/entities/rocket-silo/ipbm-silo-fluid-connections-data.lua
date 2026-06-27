require("__core__/lualib/circuit-connector-sprites")

local Util = require("__core__.lualib.util")

local defines = defines
local mods = mods

local assembler3pipepictures = assembler3pipepictures
local pipecoverspictures = pipecoverspictures

local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true

if (not sa_active and not se_active) then return end

local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]
local interplanetary_rocket_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]

if (not interplanetary_rocket_silo) then
    interplanetary_rocket_silo = Util.table.deepcopy(rocket_silo)
    interplanetary_rocket_silo.name = "ipbm-rocket-silo"
end
if (not interplanetary_rocket_silo) then return end

local positions = {
    [0]  = {
        key = "north",
        value = -1,
        position = {
            { x = -3, y = -4, },
            { x =  3, y =  4, },
        },
    },
    [4]  = {
        key = "east",
        value = 100,
        position = {
            { x =  4, y = -3, },
            { x = -4, y =  3, },
        },
    },
    [8]  = {
        key = "south",
        value = 100,
        position = {
            { x = -3, y =  4, },
            { x =  3, y = -4, },
        },
    },
    [12] = {
        key = "west",
        value = -1,
        position = {
            { x = -4, y = -3, },
            { x =  4, y =  3, },
        },
    },
}

local pipe_connections_1 = {}
local fluid_box_1 =
{
    production_type = "input",
    pipe_picture = assembler3pipepictures(),
    pipe_covers = pipecoverspictures(),
    volume = 400,
    pipe_connections = pipe_connections_1,
    secondary_draw_orders = {},
}
local pipe_connections_2 = {}
local fluid_box_2 =
{
    production_type = "input",
    pipe_picture = assembler3pipepictures(),
    pipe_covers = pipecoverspictures(),
    volume = 400,
    pipe_connections = pipe_connections_2,
    secondary_draw_orders = {},
}
local fluid_boxes =
{
    fluid_box_1,
    fluid_box_2,
}
for _, direction in pairs({ defines.direction.north, defines.direction.east, }) do

    fluid_box_1.secondary_draw_orders[positions[direction].key] = positions[direction].value
    fluid_box_1.secondary_draw_orders[positions[(direction + 8) % 16].key] = positions[(direction + 8) % 16].value

    local pipe_connection = { flow_direction = "input-output", direction = direction, position = { x = positions[direction].position[1].x, y = positions[direction].position[1].y, }, }
    pipe_connections_1[#pipe_connections_1+1] = pipe_connection

    pipe_connection = { flow_direction = "input-output", direction = (direction + 8) % 16, position = { x = positions[direction].position[2].x, y = positions[direction].position[2].y, }, }
    pipe_connections_1[#pipe_connections_1+1] = pipe_connection

    pipe_connection = { flow_direction = "input-output", direction = direction, position = { x = positions[(direction + 8) % 16].position[2].x, y = positions[(direction + 8) % 16].position[2].y, }, }
    pipe_connections_2[#pipe_connections_2+1] = pipe_connection

    pipe_connection = { flow_direction = "input-output", direction = (direction + 8) % 16, position = { x = positions[(direction + 8) % 16].position[1].x, y = positions[(direction + 8) % 16].position[1].y, }, }
    pipe_connections_2[#pipe_connections_2+1] = pipe_connection

end
interplanetary_rocket_silo.fluid_boxes = fluid_boxes

if (interplanetary_rocket_silo.fluid_boxes_off_when_no_fluid_recipe == nil) then
    interplanetary_rocket_silo.fluid_boxes_off_when_no_fluid_recipe = true
end

data:extend({interplanetary_rocket_silo})