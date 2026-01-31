local Mod_Data = require("__TheEckelmonster-core-library__.libs.mod-data.mod-data")

local Constants = require("scripts.constants.constants")

local make_projectile_placeholder = require("prototypes.entities.projectile-placeholder")

local projectile_placeholder_data = Mod_Data.create({
    name = Constants.mod_name .. "-projectile-placeholder-data",
})

for _, possible_payload in pairs({ data.raw.ammo, data.raw["land-mine"], }) do
    for k, ammo in pairs(possible_payload) do

        local projectile = nil
        local stream = nil
        local stream_action = nil
        local beam = nil
        local beam_action = nil

        local target_effects = nil
        if (ammo.type == "ammo" and ammo.ammo_type or ammo.type == "land-mine") then
            local ammo_type = ammo.type == "ammo" and ammo.ammo_type or ammo.action.action_delivery.source_effects
            if (ammo_type[1]) then
                ammo_type = ammo_type[1]
            end

            if (ammo_type.action) then
                if (ammo_type.action[1]) then
                    for _, action in ipairs(ammo_type.action) do
                        if (action.action_delivery) then
                            if (action.action_delivery.projectile) then
                                target_effects = target_effects or {}
                                table.insert(target_effects, action.action_delivery.projectile)
                                projectile = action.action_delivery.projectile
                            elseif (action.action_delivery.stream) then
                                target_effects = target_effects or {}
                                table.insert(target_effects, action.action_delivery.stream)
                                stream = action.action_delivery.stream
                                if (not stream_action) then stream_action = action end
                            elseif (action.action_delivery.beam) then
                                target_effects = target_effects or {}
                                table.insert(target_effects, action.action_delivery.beam)
                                beam = action.action_delivery.beam
                                if (not beam_action) then beam_action = action end
                            elseif (action.action_delivery.target_effects) then
                                target_effects = target_effects or {}
                                for _, target_effect in ipairs(action.action_delivery.target_effects) do
                                    table.insert(target_effects, target_effect)
                                end
                            end
                        elseif (action.action_delivery[1]) then
                            for _, action_delivery in ipairs(action.action_delivery) do
                                if (action.action_delivery.projectile) then
                                    target_effects = target_effects or {}
                                    table.insert(target_effects, action.action_delivery.projectile)
                                    projectile = action.action_delivery.projectile
                                elseif (action_delivery.target_effects) then
                                    target_effects = target_effects or {}
                                    for _, target_effect in ipairs(action_delivery.target_effects) do
                                        table.insert(target_effects, target_effect)
                                    end
                                end
                            end
                        end
                    end
                else
                    if (ammo_type.action[1]) then
                        for _, action in pairs(ammo_type.action) do
                            if (action.action_delivery) then
                                if (action.action_delivery[1]) then
                                    for _, action_delivery in pairs(ammo_type.action.action_delivery) do
                                        if (action_delivery.projectile) then
                                            target_effects = action_delivery.target_effects
                                        elseif (action_delivery.stream) then
                                            target_effects = action_delivery.target_effects
                                        elseif (ammo_type.action.action_delivery.beam) then
                                            target_effects = action_delivery.target_effects
                                        else
                                            target_effects = action_delivery.target_effects
                                        end
                                    end
                                else
                                    if (action.action_delivery.projectile) then
                                        target_effects = ammo_type.action.action_delivery.target_effects
                                    elseif (ammo_type.action.action_delivery.stream) then
                                        target_effects = ammo_type.action.action_delivery.target_effects
                                    elseif (ammo_type.action.action_delivery.beam) then
                                        target_effects = ammo_type.action.action_delivery.target_effects
                                    else
                                        target_effects = ammo.ammo_type.action.action_delivery.target_effects
                                    end
                                end
                            end
                        end
                    else
                        if (ammo_type.action.action_delivery[1]) then
                            for _, action_delivery in pairs(ammo_type.action.action_delivery) do
                                if (action_delivery.projectile) then
                                    projectile = action_delivery.projectile
                                elseif (action_delivery.stream) then
                                    stream = action_delivery.stream
                                    stream_action = ammo_type.action
                                elseif (ammo_type.action.action_delivery.beam) then
                                    beam = action.action_delivery.beam
                                    beam_action = ammo_type.action
                                else
                                    target_effects = action_delivery.target_effects
                                end
                            end
                        else
                            if (ammo_type.action.action_delivery.projectile) then
                                projectile = ammo_type.action.action_delivery.projectile
                            elseif (ammo_type.action.action_delivery.stream) then
                                stream = ammo_type.action.action_delivery.stream
                                stream_action = ammo_type.action
                            elseif (ammo_type.action.action_delivery.beam) then
                                beam = ammo_type.action.action_delivery.beam
                                beam_action = ammo_type.action
                            else
                                if (ammo.type == "ammo") then
                                    target_effects = ammo.ammo_type.action.action_delivery.target_effects
                                elseif (ammo.type == "land-mine") then
                                    target_effects = ammo.action.action_delivery.source_effects[1].action.action_delivery.target_effects
                                end
                            end
                        end
                    end
                end
            end
        end

        local magazine_size = type(ammo.magazine_size) == "number" and ammo.magazine_size > 0 and ammo.magazine_size or nil

        local projectile_placeholder = not projectile and make_projectile_placeholder({
            name = k,
            target_effects = target_effects,
            magazine_size = magazine_size,
            -- stream = stream,
            stream_action = stream_action,
            -- beam = beam,
            beam_action = beam_action,
            no_collision = stream_action and true or nil
        })

        if (projectile_placeholder) then
            data:extend({ projectile_placeholder, })

            projectile_placeholder_data.data[k] = { name = projectile_placeholder.name, speed = 1, }
        else
            if (projectile) then
                if (not projectile_placeholder_data.data[k]) then
                    projectile_placeholder_data.data[k] = { name = projectile, speed = 1, }
                end
            end

            if (stream) then
                if (not projectile_placeholder_data.data[k]) then
                    projectile_placeholder_data.data[k] = { name = stream, speed = 1, }
                end
            end

            if (beam) then
                if (not projectile_placeholder_data.data[k]) then
                    projectile_placeholder_data.data[k] = { name = beam, speed = 1, }
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

data:extend({ projectile_placeholder_data, })