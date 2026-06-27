require("__core__/lualib/circuit-connector-sprites")

local Util = require("__core__.lualib.util")

local defines = defines
local mods = mods

local assembler3pipepictures = assembler3pipepictures
local pipecoverspictures = pipecoverspictures

local cn_avionics_active = mods and mods["configurable-nukes-extended-avionics"] and true
local cn_materials_active = mods and mods["configurable-nukes-extended-materials-engineering"] and true
local cn_propulsion_active = mods and mods["configurable-nukes-extended-propulsion-systems"] and true
local eaff_active = mods and mods["enable-all-feature-flags"] and true
local sa_active = mods and mods["space-age"] and true
local se_active = mods and mods["space-exploration"] and true
local name_prefix = se_active and "se-" or ""


local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]
local interplanetary_rocket_silo = data.raw["rocket-silo"]["ipbm-rocket-silo"]

if (not interplanetary_rocket_silo) then
    interplanetary_rocket_silo = Util.table.deepcopy(rocket_silo)
    interplanetary_rocket_silo.name = "ipbm-rocket-silo"
end
if (not interplanetary_rocket_silo) then return end

-- local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]

if (sa_active or se_active) then
--     local interplanetary_rocket_silo = Util.table.deepcopy(rocket_silo)

--     interplanetary_rocket_silo.name = "ipbm-rocket-silo"
    interplanetary_rocket_silo.icon = "__configurable-nukes__/graphics/icons/ipbm-rocket-silo.png"
    interplanetary_rocket_silo.surface_conditions = nil
    interplanetary_rocket_silo.max_health = rocket_silo.max_health * 1.5
    -- interplanetary_rocket_silo.fixed_recipe = "ipbm-rocket-part-basic"
    interplanetary_rocket_silo.fixed_recipe = name_prefix .. "ipbm-rocket-part-dummy"

    --[[ TODO: Make configurable ]]
    interplanetary_rocket_silo.rocket_parts_required = 50

    interplanetary_rocket_silo.rocket_entity = "ipbm-rocket-silo-rocket"
    interplanetary_rocket_silo.minable = { mining_time = 1, result = "ipbm-rocket-silo" }

    local energy_usage = 250 * (29/7)
    local active_energy_usage = 3990 * (29/7)
    interplanetary_rocket_silo.energy_usage = energy_usage .. "kW" --energy usage used when crafting the rocket
    interplanetary_rocket_silo.active_energy_usage = active_energy_usage .. "kW"

    interplanetary_rocket_silo.resistances = {
        {
            percent = 85,
            decrease = 20,
            type = "fire"
        },
        {
            percent = 85,
            decrease = 20,
            type = "impact"
        },
        {
            percent = 85,
            decrease = 20,
            type = "explosion"
        },
        {
            percent = 50,
            decrease = 20,
            type = "electric"
        },
    }

    if (se_active) then
        table.insert(interplanetary_rocket_silo.resistances, { percent = 100, type = "meteor" })

        rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
        rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance

        interplanetary_rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
        interplanetary_rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance
    end

    interplanetary_rocket_silo.to_be_inserted_to_rocket_inventory_size = se_active and 10 or 20
    -- interplanetary_rocket_silo.logistic_trash_inventory_size = se_active and 10 or 20

    interplanetary_rocket_silo.localised_name = { "entity-name." .. name_prefix .. "ipbm-rocket-silo" }
    interplanetary_rocket_silo.localised_description = { "entity-description." .. name_prefix .. "ipbm-rocket-silo" }

    interplanetary_rocket_silo.clamps_on_trigger = {
        type = "script",
        effect_id = "clamps_on_trigger"
    }

    interplanetary_rocket_silo.door_back_sprite.filename = "__configurable-nukes__/graphics/entity/ipbm-rocket-silo/04-door-back.png"
    interplanetary_rocket_silo.door_front_sprite.filename = "__configurable-nukes__/graphics/entity/ipbm-rocket-silo/05-door-front.png"
    interplanetary_rocket_silo.base_day_sprite.filename = "__configurable-nukes__/graphics/entity/ipbm-rocket-silo/06-ipbm-rocket-silo.png"
    interplanetary_rocket_silo.base_front_sprite.filename = "__configurable-nukes__/graphics/entity/ipbm-rocket-silo/14-ipbm-rocket-silo-front.png"

    interplanetary_rocket_silo.quality_affects_energy_usage = true

    data:extend({interplanetary_rocket_silo})

    ---

    rocket_silo.surface_conditions = nil

    rocket_silo.clamps_on_trigger = {
        type = "script",
        effect_id = "clamps_on_trigger"
    }

    data:extend({rocket_silo})
-- elseif (mods and not mods["space-age"]) then
else
    rocket_silo.circuit_connector = circuit_connector_definitions["rocket-silo"]
    rocket_silo.circuit_wire_max_distance = default_circuit_wire_max_distance
    rocket_silo.to_be_inserted_to_rocket_inventory_size = 10
    -- rocket_silo.logistic_trash_inventory_size = 10
    -- rocket_silo.allow_copy_paste = true

    rocket_silo.clamps_on_trigger = {
        type = "script",
        effect_id = "clamps_on_trigger"
    }

    -- if (eaff_active) then
    --     rocket_silo.launch_to_space_platforms = true
    -- end

    data:extend({rocket_silo})
end