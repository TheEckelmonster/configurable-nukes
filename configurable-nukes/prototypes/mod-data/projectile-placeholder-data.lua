local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
local __Data_Utils = require("data-utils")

local __debug = DEBUG
DEBUG = Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.DEBUG_PAYLOAD_STARTUP_PROCESSING.name })
local debug_count = 1

local true_nukes_continued = mods and mods["True-Nukes_Continued"] and true

local Mod_Data = require("__TheEckelmonster-core-library__.libs.mod-data.mod-data")

local Constants = require("scripts.constants.constants")

local collate_trigger_data = require("prototypes.entities.collate-trigger-data")
local make_projectile_placeholder = require("prototypes.entities.projectile-placeholder")

local projectile_placeholder_data = Mod_Data.create({
    name = Constants.mod_name .. "-projectile-placeholder-data",
})

local projectile_placeholders = {}
local projectile_placeholders_dictionary = {}

local warhead_mapping = {}
if (true_nukes_continued) then
    if (type(warheads) == "table") then
        for k, v in pairs(warheads) do
            warhead_mapping[v.appendName] = {
                key = k,
                k = k,
                value = v,
                v = v,
                final_effect = v.final_effect
            }
        end
    end
end

if (DEBUG) then log(serpent.block(warhead_mapping)) end

local name_mapping = {}

if (mods and mods["RampantArsenalFork"]) then
    for name, ammo in pairs(data.raw.ammo) do
        local i, j = ammo.name:find("-capsule-ammo-rampant-arsenal", 1, true)

        if (i and j and not ammo.name:find("-landmine-capsule-ammo-rampant-arsenal")) then
            local _name = ammo.name
            local parsed_name = ""

            local loops = 1
            while _name and _name:gsub("%s+", "") ~= "" do
                if (loops > 2 ^ 11) then break end
                loops = loops + 1

                local a, b = _name:find("%a+%-*")
                local token = _name:sub(a, b)
                _name = _name:sub(b + 1, #_name)

                if (token and not token:find("ammo", 1, true)) then
                    parsed_name = parsed_name .. token
                end
            end

            if (parsed_name and parsed_name:gsub("%s+", "") ~= "") then
                name_mapping[name] = parsed_name
            end
        end
    end
end

local function name_check(params)
    if (type(params) ~= "table") then return end

    local name = params.name or nil
    if (not name or type(name) ~= "string") then return end

    return name_mapping[name] or name
end

local subgroup_order = 1
local subgroups = {}

local function traverse_ammo(params)

    if (type(params) ~= "table") then return end

    local ammo = params.ammo
    if (not ammo) then return end

    local ammo_type = params.ammo_type
    if (not ammo_type) then return end

    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    if (DEBUG) then log(serpent.block(ammo)) end
    if (DEBUG) then log(serpent.block(ammo_type)) end

    if (not type(params.target_effects) ~= "table") then params.target_effects = {} end
    if (not type(params.source_effects) ~= "table") then params.source_effects = {} end

    if (ammo_type.action) then
        params.ammo_type_data = collate_trigger_data({ action = ammo_type.action, parent = ammo_type, key = "action", })
    end

    if (ammo.action) then
        params.ammo_data = collate_trigger_data({ action = ammo_type.action, parent = ammo_type, key = "action", })
    end

    if (ammo.subgroup) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        if (ammo.subgroup and not subgroups[ammo.subgroup]) then
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            subgroups[ammo.subgroup] = subgroup_order
            subgroup_order = subgroup_order + 1
        end
    end

    if (not next(params.source_effects)) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        params.source_effects = nil
    end

    return params
end

local function make_extend_ammo(params)
    if (type(params) ~= "table") then return end

    local ammo = params.ammo
    local target_effects = params.target_effects
    local returned_params = params.returned_params or {}
    local k = params.k

    local magazine_size = type(ammo.magazine_size) == "number" and ammo.magazine_size > 0 and ammo.magazine_size or nil

    if (not target_effects or not next(target_effects)) then target_effects = nil end
    if (returned_params and returned_params.target_effects and not next(returned_params.target_effects)) then returned_params.target_effects = nil end

    if (returned_params.projectile or returned_params.stream or returned_params.beam) then
        if (returned_params.projectile) then returned_params.type = "projectile"
        elseif (returned_params.stream) then returned_params.type = "stream"
        elseif (returned_params.beam) then returned_params.type = "beam"
        end
    end

    local params = {
        source = returned_params,
        name = k,
        type = returned_params.type or nil,
        target_effects = returned_params.target_effects or target_effects,
        source_effects = returned_params.source_effects,
        magazine_size = magazine_size,
        stream_action = returned_params.stream_action or nil,
        beam_action = returned_params.beam_action or nil,
        collision = not returned_params.type
    }

    if (DEBUG) then log(serpent.block(returned_params)) end
    if (DEBUG) then log(serpent.block(params)) end

    local warhead_projectile = false
    if (true_nukes_continued and (k == "atomic-bomb" or k:find("%-atomic%-"))) then
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        if (DEBUG) then log(serpent.block(k)) end
        if (k:find("artillery%-shell%-atomic%-")) then
            for key, v in pairs(warhead_mapping) do
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                if (DEBUG) then log(serpent.block(key)) end
                if (k:find(key, 1, true)) then
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    for i = 1, #v.final_effect, 1 do
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        if (DEBUG) then log(serpent.block(v.final_effect[i])) end
                        table.insert(params.target_effects, v.final_effect[i])
                    end
                end
            end
        end
        warhead_projectile = true
    end

    local projectile_placeholder, dummy_projectile = make_projectile_placeholder(params)

    if (DEBUG) then log(serpent.block(projectile_placeholder or "nil")) end

    if (projectile_placeholder) then
        local data = { name = projectile_placeholder.name, speed = 1, projectile_placeholder = projectile_placeholder, dummy_projectile = dummy_projectile, warhead_projectile = warhead_projectile, }

        if (not projectile_placeholders_dictionary[projectile_placeholder.name]) then
            projectile_placeholders_dictionary[projectile_placeholder.name] = data
            table.insert(projectile_placeholders, projectile_placeholder)
        else
            local existing_projectile_placeholder = projectile_placeholders_dictionary[projectile_placeholder.name]

            existing_projectile_placeholder.projectile_placeholder.action = __Data_Utils.table.merge(existing_projectile_placeholder.projectile_placeholder.action, projectile_placeholder.action)
        end

        projectile_placeholder_data.data[name_check({name = k, })] = data

        local parsed = k:gsub("^cn%-projectile%-placeholder%-", "")
        if (parsed) then
            projectile_placeholder_data.data[parsed] = data
        end

        local parsed = projectile_placeholder.name:find("^cn%-projectile%-placeholder%-") and projectile_placeholder.name:match("cn%-projectile%-placeholder%-(".. k:gsub("%-", "%%-") .. ")")
        if (parsed) then
            projectile_placeholder_data.data[parsed] = data
        end
    end
end

for _, possible_payload in pairs({ Util.table.deepcopy(data.raw.ammo), Util.table.deepcopy(data.raw["land-mine"]), }) do
    if (DEBUG) then log(serpent.block(_)) end
    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
    for k, ammo in pairs(possible_payload) do
        if (DEBUG) then log(serpent.block(k)) end
        if (DEBUG) then log(serpent.block(ammo)) end
        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
        local returned_params

        local target_effects = {}
        if (ammo.type == "ammo" and ammo.ammo_type or ammo.type == "land-mine") then
            local ammo_type = ammo.type == "ammo" and ammo.ammo_type or nil

            if (not ammo_type) then
                if (ammo.action and ammo.action[1]) then
                    ammo_type = { action = ammo.action, }
                else
                    ammo_type = { action = ammo.action, }
                end
            end

            if (ammo_type) then
                if (ammo_type[1]) then
                    for i = 1, #ammo_type, 1 do
                        local ammo_type = ammo_type[i]

                        returned_params = traverse_ammo({
                            ammo = ammo,
                            ammo_type = ammo_type,
                            target_effects = target_effects,
                        })

                        make_extend_ammo({
                            ammo = ammo,
                            target_effects = target_effects,
                            returned_params = returned_params,
                            k = k,
                        })
                    end
                else
                    returned_params = traverse_ammo({
                        ammo = ammo,
                        ammo_type = ammo_type,
                        target_effects = target_effects,
                    })

                    make_extend_ammo({
                        ammo = ammo,
                        target_effects = target_effects,
                        returned_params = returned_params,
                        k = k,
                    })
                end
            end
        end
    end
end

for _, v in pairs(data.raw.projectile) do
    if (not projectile_placeholder_data.data[v.name]) then
        projectile_placeholder_data.data[v.name] = { name = v.name, speed = v.speed or 1, }
    end
end

if (next(projectile_placeholders)) then
    local found = {}
    local to_extend = {}
    for k, v in pairs(projectile_placeholder_data.data) do
        if (v.projectile_placeholder and not found[v.projectile_placeholder]) then
            found[v.projectile_placeholder] = { key = k, value = v, parent = projectile_placeholders, }
            table.insert(to_extend, v.projectile_placeholder)
        end
        if (v.dummy_projectile) then
            found[v.dummy_projectile] = { key = k, value = v, parent = projectile_placeholders, }
            table.insert(to_extend, v.dummy_projectile)
        end
        if (not v.dummy_projectile or not v.projectile_placeholder) then
            -- log(serpent.block({ [k] = v, }))
        end
    end
    if (next(to_extend)) then
        data:extend(to_extend)
    end
end

if (next(subgroups)) then
    projectile_placeholder_data.data.subgroups = subgroups
end

data:extend({ projectile_placeholder_data, })

if (DEBUG) then log(serpent.block(projectile_placeholder_data)) end
-- log(serpent.block(projectile_placeholder_data))

DEBUG = __debug