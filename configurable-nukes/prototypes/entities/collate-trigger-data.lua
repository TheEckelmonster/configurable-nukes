--[[ collate_trigger_data ]]
return function (params)
    -- log(serpent.block(params))
    params = type(params) and params or {}

    local effects = {
        ["action"] = {},
        ["action_delivery"] = {},
        ["target_effects"] = {},
        ["source_effects"] = {},
        ["artillery-projectile"] = {},
        ["projectile"] = {},
        ["stream"] = {},
        ["beam"] = {},
    }

    local dictionaries = {
        ["action"] = {},
        ["action_delivery"] = {},
        ["target_effects"] = {},
        ["source_effects"] = {},
        ["artillery-projectile"] = {},
        ["projectile"] = {},
        ["beam"] = {},
        ["stream"] = {},
    }

    local ammo_data = {
        effects = effects,
        dictionaries = dictionaries,
    }

    local function find_trigger_data(params_outer)
        local found = {}
        local loops = 0
        local order = 1
        local depth = 0

        ammo_data.found = found

        local function recurse(value, _table, key)

            if (loops > 2 ^ 12) then return else loops = loops + 1 end
            depth = depth + 1

            value = type(value) == "table" and value or nil
            if (not value) then return end

            for k, v in pairs(value) do
                if (type(v) == "table" and not found[v]) then
                    found[v] = { order = order, depth = depth, table = value, key = k, value = v, parent = _table, }
                    order = order + 1
                    recurse(v, value, k)
                end
                if (type(k) == "string" and effects[k]) then
                    table.insert(effects[k], v)
                    if (dictionaries[k] and not (dictionaries[k])[v]) then
                        dictionaries[k][v] = { order = order, depth = depth, index = #(effects[k]), table = value, key = k, value = v, parent = _table, }
                        order = order + 1
                    end
                end
            end
            depth = depth - 1
        end

        if (type(params_outer) == "table") then recurse(params_outer.action, params_outer.parent, params_outer.key) end
    end

    find_trigger_data(params)

    return ammo_data
end