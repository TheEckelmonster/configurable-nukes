
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")
local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local get_runtime_global_setting = function (data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = Runtime_Global_Settings_Constants.settings_dictionary[data.setting] and Runtime_Global_Settings_Constants.settings_dictionary[data.setting].default_value

    if (settings and settings.global and settings.global[data.setting]) then
        setting = settings.global[data.setting].value
    end

    return setting
end

-- local get_runtime_user_setting = function (data)

--     if (not data or type(data) ~= "table") then return end
--     if (not data.setting or type(data.setting) ~= "string") then return end
--     if (data.player_id ~= nil) then return end

--     local setting = Runtime_User_Settings_Constants.settings_dictionary[data.setting] and Runtime_User_Settings_Constants.settings_dictionary[data.setting].default_value

--     -- if (settings and settings.global and settings.global[data.setting]) then
--     if (settings.get_player_settings(data.player_id)[data.setting]) then
--         setting = settings.global[data.setting].value
--     end

--     return setting
-- end

local get_startup_setting = function (data)

    if (not data or type(data) ~= "table") then return end
    if (not data.setting or type(data.setting) ~= "string") then return end

    local setting = Startup_Settings_Constants.settings_dictionary[data.setting] and Startup_Settings_Constants.settings_dictionary[data.setting].default_value

    if (settings and settings.startup and settings.startup[data.setting]) then
        setting = settings.startup[data.setting].value
    end

    return setting
end

local data_utils = {
    create_custom_tooltip_quality_effects_atomic = function (params)
        local name = params.name
        local entity_name = name
        if (name == "atomic-rocket") then entity_name = "atomic-bomb" end

        local type = params.type

        local raw = data.raw[type][name]
        if (not raw) then
            log("no object found in data.raw that corresponds with data.raw[" .. tostring(type) .. "][" .. tostring(name) .. "]")
            return
        end

        local name_normal_quality = name .. "-normal"

        local qualities = {}
        local object_names =
        {
            dictionary = {},
            array = {}
        }

        object_names.dictionary[name .. "-normal"] = { quality = "normal", level = 0 }
        qualities["normal"] = {}

        for k_0, quality in pairs(data.raw["quality"]) do
            if (k_0 ~= "quality-unknown" and not quality.hidden) then
                qualities[k_0] = quality
                table.insert(object_names.array, quality.level, name .. "-" .. k_0)
                object_names.dictionary[name .. "-" .. k_0] = { quality = k_0, level = quality.level }
            end
        end

        local object_entities =
        {
            dictionary = {},
            array = {},
        }

        object_entities.dictionary[name_normal_quality] = { entity = data.raw[type][name_normal_quality], quality = "normal" }
        table.insert(object_entities.array, { entity = data.raw[type][name_normal_quality], quality = "normal" })

        for k, v in pairs(object_names.array) do
            local quality_object = data.raw[type][v]

            if (quality_object) then
                table.insert(object_entities.array, { entity = quality_object, quality = object_names.dictionary[v].quality })
                object_entities.dictionary[v] = { entity = quality_object, quality = object_names.dictionary[v].quality }
            end
        end

        local target_effects_dictionary = {}

        for k, quality_object in pairs(object_entities.array) do
            local target_effects = quality_object.entity.action.action_delivery.target_effects

            local array = {}

            local i = nil
            for i = 1, #target_effects, 1 do
                array[i] = {}
                if (target_effects[i].type == "destroy-cliffs") then
                    array[i] = { type = "destroy-cliffs", radius = target_effects[i].radius }
                elseif (target_effects[i].type == "damage") then
                    array[i] = { type = "damage", damage = target_effects[i].damage }
                elseif (target_effects[i].type == "nested-result") then
                    if (target_effects[i].action.type == "area") then
                        if (target_effects[i].action.action_delivery.type == "projectile") then
                            -- log(serpent.block(target_effects[i].action.action_delivery.projectile))
                            if (target_effects[i].action.action_delivery.projectile:find(entity_name .. "-ground-zero-projectile-" .. object_entities.dictionary[quality_object.entity.name].quality, 1, true)) then
                                local ground_zero_projectile_effects = data.raw["projectile"][entity_name .. "-ground-zero-projectile-" .. object_entities.dictionary[quality_object.entity.name].quality]
                                ground_zero_projectile_effects = ground_zero_projectile_effects.action
                                ground_zero_projectile_effects = ground_zero_projectile_effects[1]

                                array[i].type = "nested-result"
                                array[i]["nested-result"] = {}
                                array[i]["nested-result"][entity_name .. "-ground-zero-projectile"] =
                                {
                                    repeat_count = target_effects[i].action.repeat_count,
                                    radius = target_effects[i].action.radius,
                                    projectile =
                                    {
                                        radius = ground_zero_projectile_effects.radius,
                                        action_delivery =
                                        {
                                            target_effects =
                                            {
                                                damage = ground_zero_projectile_effects.action_delivery.target_effects.damage
                                            }
                                        }
                                    }
                                }
                            elseif (target_effects[i].action.action_delivery.projectile:find(entity_name .. "-wave-" .. object_entities.dictionary[quality_object.entity.name].quality, 1, true)) then
                                local atomic_bomb_wave_effects = data.raw["projectile"][entity_name .. "-wave-" .. object_entities.dictionary[quality_object.entity.name].quality]
                                atomic_bomb_wave_effects = atomic_bomb_wave_effects.action
                                atomic_bomb_wave_effects = atomic_bomb_wave_effects[1]

                                array[i].type = "nested-result"
                                array[i]["nested-result"] = {}
                                array[i]["nested-result"][entity_name .. "-wave"] =
                                {
                                    repeat_count = target_effects[i].action.repeat_count,
                                    radius = target_effects[i].action.radius,
                                    projectile =
                                    {
                                        radius = atomic_bomb_wave_effects.radius,
                                        action_delivery =
                                        {
                                            target_effects =
                                            {
                                                damage = atomic_bomb_wave_effects.action_delivery.target_effects.damage
                                            }
                                        }
                                    }
                                }
                            end
                        end
                    end
                end
            end

            local indices_to_remove = {}
            for i = 1, #array, 1 do
                if (not array[i].type) then
                    table.insert(indices_to_remove, i)
                end
            end

            for i = #indices_to_remove, 1, -1 do
                table.remove(array, indices_to_remove[i])
            end

            target_effects_dictionary[object_entities.dictionary[quality_object.entity.name].quality] = array
        end
        -- log(serpent.block(target_effects_dictionary))

        local order = 1

        local quality_values = {}

        local prefix = name .. "-"
        local quality_level = "normal"
        while quality_level ~= nil and object_names.dictionary[prefix .. quality_level] do
            order = 1
            for i = 1, #target_effects_dictionary[quality_level], 1 do
                if (target_effects_dictionary[quality_level][i].type == "destroy-cliffs") then
                    if (not quality_values[quality_level]) then quality_values[quality_level] = {} end

                    local num_val = target_effects_dictionary[quality_level][i].radius
                    local suffix = ""
                    local directive = "%d"
                    if (num_val > 1000 ^ 3) then
                        suffix = "B"
                        num_val = num_val / (1000 ^ 3)
                    elseif (num_val > 1000 ^ 2) then
                        suffix = "M"
                        num_val = num_val / (1000 ^ 2)
                    elseif (num_val > 1000 ^ 1) then
                        suffix = "k"
                        num_val = num_val / (1000 ^ 1)
                    end

                    if (num_val % 1 ~= 0) then
                        if (((num_val % 0.1) - (num_val % 0.01)) ~= 0) then
                            directive = "%.2f"
                        else
                            directive = "%.1f"
                        end
                    end

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-destroy-cliffs.aoe-size" },
                        value = { "atomic-bomb-placeholder.aoe-size", string.format(directive, num_val) .. suffix, "", }
                    }
                    order = order + 1

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-destroy-cliffs.destroy-cliffs" },
                        value = ""
                    }
                    order = order + 1

                elseif (target_effects_dictionary[quality_level][i].type == "damage") then
                    if (not quality_values[quality_level]) then quality_values[quality_level] = {} end

                    local num_val = target_effects_dictionary[quality_level][i].damage.amount
                    local suffix = ""
                    local directive = "%d"
                    if (num_val > 1000 ^ 3) then
                        suffix = "B"
                        num_val = num_val / (1000 ^ 3)
                    elseif (num_val > 1000 ^ 2) then
                        suffix = "M"
                        num_val = num_val / (1000 ^ 2)
                    elseif (num_val > 1000 ^ 1) then
                        suffix = "k"
                        num_val = num_val / (1000 ^ 1)
                    end

                    if (num_val % 1 ~= 0) then
                        if (((num_val % 0.1) - (num_val % 0.01)) ~= 0) then
                            directive = "%.2f"
                        else
                            directive = "%.1f"
                        end
                    end

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-damage.damage" },
                        value = { "atomic-bomb-placeholder.damage", string.format(directive, num_val) .. suffix, "", { "damage-type." .. target_effects_dictionary[quality_level][i].damage.type } }
                    }

                    order = order + 1
                elseif (target_effects_dictionary[quality_level][i].type == "nested-result") then
                    if (not quality_values[quality_level]) then quality_values[quality_level] = {} end

                    local projectile = ""
                    if (target_effects_dictionary[quality_level][i]["nested-result"][entity_name .. "-ground-zero-projectile"]) then
                        projectile = entity_name .. "-ground-zero-projectile"
                    elseif (target_effects_dictionary[quality_level][i]["nested-result"][entity_name .. "-wave"]) then
                        projectile = entity_name .. "-wave"
                    end

                    local num_val = target_effects_dictionary[quality_level][i]["nested-result"][projectile].radius
                    local suffix = ""
                    local directive = "%d"
                    if (num_val > 1000 ^ 3) then
                        suffix = "B"
                        num_val = num_val / (1000 ^ 3)
                    elseif (num_val > 1000 ^ 2) then
                        suffix = "M"
                        num_val = num_val / (1000 ^ 2)
                    elseif (num_val > 1000 ^ 1) then
                        suffix = "k"
                        num_val = num_val / (1000 ^ 1)
                    end

                    if (num_val % 1 ~= 0) then
                        if (((num_val % 0.1) - (num_val % 0.01)) ~= 0) then
                            directive = "%.2f"
                        else
                            directive = "%.1f"
                        end
                    end

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-nested-result.aoe-size-1", },
                        value = { "atomic-bomb-placeholder.aoe-size", string.format(directive, num_val) .. suffix, },
                    }
                    order = order + 1

                    num_val = target_effects_dictionary[quality_level][i]["nested-result"][projectile].projectile.radius
                    suffix = ""
                    directive = "%d"
                    if (num_val > 1000 ^ 3) then
                        suffix = "B"
                        num_val = num_val / (1000 ^ 3)
                    elseif (num_val > 1000 ^ 2) then
                        suffix = "M"
                        num_val = num_val / (1000 ^ 2)
                    elseif (num_val > 1000 ^ 1) then
                        suffix = "k"
                        num_val = num_val / (1000 ^ 1)
                    end

                    if (num_val % 1 ~= 0) then
                        if (((num_val % 0.1) - (num_val % 0.01)) ~= 0) then
                            directive = "%.2f"
                        else
                            directive = "%.1f"
                        end
                    end

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-nested-result.aoe-size-2", },
                        value = { "atomic-bomb-placeholder.aoe-size", string.format(directive, num_val) .. suffix, },
                    }
                    order = order + 1

                    num_val = target_effects_dictionary[quality_level][i]["nested-result"][projectile].repeat_count
                    suffix = ""
                    directive = "%d"
                    if (num_val > 1000 ^ 3) then
                        suffix = "B"
                        num_val = num_val / (1000 ^ 3)
                    elseif (num_val > 1000 ^ 2) then
                        suffix = "M"
                        num_val = num_val / (1000 ^ 2)
                    elseif (num_val > 1000 ^ 1) then
                        suffix = "k"
                        num_val = num_val / (1000 ^ 1)
                    end

                    if (num_val % 1 ~= 0) then
                        if (((num_val % 0.1) - (num_val % 0.01)) ~= 0) then
                            directive = "%.2f"
                        else
                            directive = "%.1f"
                        end
                    end

                    local num_val_2 = target_effects_dictionary[quality_level][i]["nested-result"][projectile].projectile.action_delivery.target_effects.damage.amount
                    local suffix_2 = ""
                    local directive_2 = "%d"
                    if (num_val_2 > 1000 ^ 3) then
                        suffix_2 = "B"
                        num_val_2 = num_val_2 / (1000 ^ 3)
                    elseif (num_val_2 > 1000 ^ 2) then
                        suffix_2 = "M"
                        num_val_2 = num_val_2 / (1000 ^ 2)
                    elseif (num_val_2 > 1000 ^ 1) then
                        suffix_2 = "k"
                        num_val_2 = num_val_2 / (1000 ^ 1)
                    end

                    if (num_val_2 % 1 ~= 0) then
                        if (((num_val_2 % 0.1) - (num_val_2 % 0.01)) ~= 0) then
                            directive_2 = "%.2f"
                        else
                            directive_2 = "%.1f"
                        end
                    end

                    quality_values[quality_level][order] =
                    {
                        name = { "quality-nested-result.damage", },
                        value = { "atomic-bomb-placeholder.damage-mult", string.format(directive, num_val) .. suffix, string.format(directive_2, num_val_2) .. suffix_2, "", { "damage-type." .. target_effects_dictionary[quality_level][i]["nested-result"][projectile].projectile.action_delivery.target_effects.damage.type } },
                    }
                    order = order + 1
                end
            end

            quality_level = qualities[quality_level].next
        end
        -- log(serpent.block(quality_values))

        local new_custom_tooltip = function (data)
            return
            {
                name = "",
                value = "",
                quality_values = {},
                show_in_tooltip = true,
                show_in_factoriopedia = true
            }
        end

        local custom_tooltip_fields = {}

        local quality_level_outer = "normal"
        for i = 1, #quality_values[quality_level_outer], 1 do
            local custom_tooltip = new_custom_tooltip()

            custom_tooltip.name = quality_values[quality_level_outer][i].name
            custom_tooltip.value = quality_values[quality_level_outer][i].value

            quality_level = "normal"
            while quality_level ~= nil and object_names.dictionary[prefix .. quality_level] do

                custom_tooltip.quality_values[quality_level] = quality_values[quality_level][i].value

                quality_level = qualities[quality_level].next
            end

            table.insert(custom_tooltip_fields, custom_tooltip)
        end

        local custom_tooltip = new_custom_tooltip()
        custom_tooltip.name = { "quality-custom-tooltip.effect" }
        custom_tooltip.value =  ""
        table.insert(custom_tooltip_fields, 1, custom_tooltip)

        for i = #custom_tooltip_fields, 1, -1 do
            custom_tooltip_fields[i].order = ((2 ^ 8) - 1) - #custom_tooltip_fields + i
        end

        return custom_tooltip_fields
    end,
    get_runtime_global_setting = function (data)

        if (not data or type(data) ~= "table") then return end
        if (not data.setting or type(data.setting) ~= "string") then return end

        return get_runtime_global_setting(data)
    end,
    get_startup_setting = function (data)

        if (not data or type(data) ~= "table") then return end
        if (not data.setting or type(data.setting) ~= "string") then return end

        return get_startup_setting(data)
    end
}

return data_utils