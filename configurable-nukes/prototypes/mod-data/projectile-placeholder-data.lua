local DEBUG = false
local debug_count = 1

local true_nukes_continued = mods and mods["True-Nukes_Continued"] and true

local Mod_Data = require("__TheEckelmonster-core-library__.libs.mod-data.mod-data")

local Constants = require("scripts.constants.constants")

local make_projectile_placeholder = require("prototypes.entities.projectile-placeholder")

local projectile_placeholder_data = Mod_Data.create({
    name = Constants.mod_name .. "-projectile-placeholder-data",
})

local projectile_placeholders = {}
local projectile_placeholders_dictionary = {}

local types = {
    ["projectile"] = "projectile",
    ["stream"] = "stream",
    ["beam"] = "beam",
}

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

    if (ammo_type.action) then
        if (ammo_type.action[1]) then
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            for _, action in ipairs(ammo_type.action) do
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                if (action.action_delivery and action.action_delivery.type and types[action.action_delivery.type]) then
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    params.type = types[action.action_delivery.type]
                end
                table.insert(params.target_effects, { type = "nested-result", action = action})
            end
        else
            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
            if (ammo_type.action[1]) then
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                for _, action in pairs(ammo_type.action) do
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    if (action.action_delivery) then
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        if (action.action_delivery[1]) then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            for _, action_delivery in pairs(ammo_type.action.action_delivery) do
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                table.insert(params.target_effects, action_delivery.target_effects)
                            end
                        else
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            if (action.action_delivery.projectile) then
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                table.insert(params.target_effects, ammo_type.action)
                            elseif (ammo_type.action.action_delivery.stream) then
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                table.insert(params.target_effects, ammo_type.action)
                            elseif (ammo_type.action.action_delivery.beam) then
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                table.insert(params.target_effects, ammo_type.action)
                            else
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                table.insert(params.target_effects, ammo.ammo_type.action)
                            end
                        end
                    end
                end
            else
                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                if (ammo_type.action.action_delivery[1]) then
                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                    for _, action_delivery in pairs(ammo_type.action.action_delivery) do
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        if (action_delivery.projectile) then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            params.projectile = action_delivery.projectile
                            table.insert(params.target_effects, { type = "nested-result", action = action_delivery.target_effects, })
                        elseif (action_delivery.stream) then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            params.stream = action_delivery.stream
                            params.stream_action = ammo_type.action
                            table.insert(params.target_effects, { type = "nested-result", action = ammo_type.action, })
                        elseif (ammo_type.action.action_delivery.beam) then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            params.beam = action.action_delivery.beam
                            params.beam_action = ammo_type.action
                            table.insert(params.target_effects, { type = "nested-result", action = action_delivery.target_effects, })
                        else
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            if (action_delivery.target_effects) then
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                if (action_delivery.target_effects[1]) then
                                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                    for  i  =  1,  #action_delivery.target_effects, 1  do
                                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                        table.insert(params.target_effects, action_delivery.target_effects[i])
                                    end
                                else
                                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                    table.insert(params.target_effects, action_delivery.target_effects)
                                end
                            else
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            end
                        end
                    end
                else
                    if (ammo_type.action.action_delivery.projectile) then
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        params.projectile = ammo_type.action.action_delivery.projectile
                        table.insert(params.target_effects, { type = "nested-result", action = ammo_type.action, })
                    elseif (ammo_type.action.action_delivery.stream) then
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        params.stream = ammo_type.action.action_delivery.stream
                        params.stream_action = ammo_type.action
                        table.insert(params.target_effects, { type = "nested-result", action = ammo_type.action, })
                    elseif (ammo_type.action.action_delivery.beam) then
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        params.beam = ammo_type.action.action_delivery.beam
                        params.beam_action = ammo_type.action
                        table.insert(params.target_effects, { type = "nested-result", action = ammo_type.action, })
                    else
                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                        if (ammo.type == "ammo") then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            table.insert(params.target_effects, { type = "nested-result", action = ammo_type.action, })
                        elseif (ammo.type == "land-mine") then
                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            params.type = "land-mine"

                            if (ammo_type.action.action_delivery.source_effects[1]) then
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                for i_s = 1, #ammo_type.action.action_delivery.source_effects, 1 do
                                    if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                    local source_effect = ammo_type.action.action_delivery.source_effects[i_s]
                                    if (source_effect.action and source_effect.action[1]) then
                                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                        for _, action in pairs(ammo_type.action.action_delivery.source_effects[i_s].action) do
                                            if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                            table.insert(params.target_effects, { type = "nested-result", action = action, })
                                        end
                                    else
                                        if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                                        table.insert(params.target_effects, ammo_type.action.action_delivery.source_effects[i_s])
                                    end
                                end
                            else
                                if (DEBUG) then log(debug_count); debug_count = debug_count + 1 end
                            end
                        end
                    end
                end
            end
        end
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
        name = k,
        type = returned_params.type or nil,
        target_effects = returned_params.target_effects or target_effects,
        magazine_size = magazine_size,
        stream_action = returned_params.stream_action or nil,
        beam_action = returned_params.beam_action or nil,
        no_collision = returned_params.type and true or nil
    }

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

    local projectile_placeholder = returned_params and (not returned_params.projectile or warhead_projectile) and make_projectile_placeholder(params) or nil

    if (DEBUG) then log(serpent.block(projectile_placeholder or "nil")) end

    if (projectile_placeholder) then
        if (not projectile_placeholders_dictionary[projectile_placeholder.name]) then
            projectile_placeholders_dictionary[projectile_placeholder.name] = projectile_placeholder
            table.insert(projectile_placeholders, projectile_placeholder)
        else
            local existing_projectile_placeholder = projectile_placeholders_dictionary[projectile_placeholder.name]
            for _, target_effect in pairs(projectile_placeholder.action.action_delivery.target_effects) do
                table.insert(existing_projectile_placeholder.action.action_delivery.target_effects, target_effect)
            end
        end

        projectile_placeholder_data.data[name_check({name = k, })] = { name = projectile_placeholder.name, speed = 1, warhead_projectile = warhead_projectile, }
    else
        if (returned_params and returned_params.projectile) then
            if (not projectile_placeholder_data.data[k]) then
                projectile_placeholder_data.data[k] = { name = returned_params.projectile, speed = 1, }
            end
        end

        if (returned_params and returned_params.stream) then
            if (not projectile_placeholder_data.data[k]) then
                projectile_placeholder_data.data[k] = { name = returned_params.stream, speed = 1, }
            end
        end

        if (returned_params and returned_params.beam) then
            if (not projectile_placeholder_data.data[k]) then
                projectile_placeholder_data.data[k] = { name = returned_params.beam, speed = 1, }
            end
        end
    end
end

for _, possible_payload in pairs({ data.raw.ammo, data.raw["land-mine"], }) do
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
    data:extend(projectile_placeholders)
end

data:extend({ projectile_placeholder_data, })

if (DEBUG) then log(serpent.block(projectile_placeholder_data)) end