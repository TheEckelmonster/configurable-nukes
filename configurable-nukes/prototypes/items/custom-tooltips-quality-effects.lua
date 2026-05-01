local __Data_Utils = require("data-utils")

local function new_quality_levels()
    local levels = {}
    for k_0, quality in pairs(data.raw["quality"]) do
        if (quality.level == 0 or quality.hidden) then goto continue end
            levels[k_0] = { name = k_0, level = quality.level, next = quality.next, }
        ::continue::
    end

    return levels
end

--[[ create-custom-tooltip-quality-effects ]]
return function (params)
    -- log(serpent.block(quality_values))

    local quality_levels = new_quality_levels()
    -- log(serpent.block(quality_levels))

    local __type = type
    local type = params.type
    local name = params.name
    local entity_name = params.entity_name

    local raw = type and data.raw[type] and (data.raw[type][entity_name] or data.raw[type][name])
    if (not raw) then
        log("no object found in data.raw that corresponds with data.raw[" .. tostring(type) .. "][" .. tostring(entity_name) .. "], or data.raw[" .. tostring(type) .. "][" .. tostring(name) .. "]")
        return
    end

    -- log(serpent.block(raw.action))
    -- log(serpent.block(raw))

    local actions_to_process, attrs = __Data_Utils.find_by(raw.action, "type",
    {
        -- ["action"] = 1,
        ["direct"] = 1,
        ["area"] = 1,
        ["line"] = 1,
        ["cluster"] = 1,
        -- ["action_delivery"] = 1,
        -- ["instant"] = 1,
        -- ["projectile"] = 1,
        -- ["beam"] = 1,
        -- ["stream"] = 1,
        -- ["artillery"] = 1,
        -- ["chain"] = 1,
        -- ["delayed"] = 1,
        -- ["target_effects"] = 1,
        -- ["source_effects"] = 1,
        ["damage-entity"] = 1,
        ["create-fire"] = 1,
        ["create-sticker"] = 1,
        ["nested-result"] = 1,
    })

    -- local actions = {
    --     ["direct"] = "action",
    --     ["area"] = "action",
    --     ["line"] = "action",
    --     ["cluster"] = "action",
    -- }

    -- local target_effects = {
    --     ["damage-entity"] = "target_effects",
    --     ["create-fire"] = "target_effects",
    --     ["create-sticker"] = "target_effects",
    --     ["nested-result"] = "target_effects",
    -- }

    -- local source_effects = {
    --     ["damage-entity"] = "source_effects",
    --     ["create-fire"] = "source_effects",
    --     ["create-sticker"] = "source_effects",
    --     ["nested-result"] = "source_effects",
    -- }

    -- log(serpent.block(actions_to_process))
    -- for k, v in pairs(actions_to_process) do
    --     log(serpent.block(k))
    --     log(serpent.block(v))
    -- end

    for i = #actions_to_process, #actions_to_process, -1 do

    end

    -- local function new_custom_tooltip()
    --     return
    --     {
    --         name = "",
    --         value = "",
    --         quality_values = {},
    --         show_in_tooltip = true,
    --         show_in_factoriopedia = true
    --     }
    -- end

    -- local custom_tooltip_fields = {}

    -- -- local quality_level_outer = "normal"
    -- -- for i = 1, #quality_values[quality_level_outer], 1 do
    -- --     local custom_tooltip = new_custom_tooltip()

    -- --     custom_tooltip.name = quality_values[quality_level_outer][i].name
    -- --     custom_tooltip.value = quality_values[quality_level_outer][i].value

    -- --     quality_level = "normal"
    -- --     while quality_level ~= nil and object_names.dictionary[prefix .. quality_level] do

    -- --         if (quality_values and quality_values[quality_level] and quality_values[quality_level][i]) then
    -- --             custom_tooltip.quality_values[quality_level] = quality_values[quality_level][i].value
    -- --         end

    -- --         quality_level = qualities[quality_level].next
    -- --     end

    -- --     table.insert(custom_tooltip_fields, custom_tooltip)
    -- -- end

    -- local custom_tooltip = new_custom_tooltip()
    -- custom_tooltip.name = { "quality-custom-tooltip.effect" }
    -- custom_tooltip.value =  ""
    -- table.insert(custom_tooltip_fields, 1, custom_tooltip)

    -- for i = #custom_tooltip_fields, 1, -1 do
    --     custom_tooltip_fields[i].order = ((2 ^ 8) - 1) - #custom_tooltip_fields + i
    -- end

    -- return custom_tooltip_fields
end