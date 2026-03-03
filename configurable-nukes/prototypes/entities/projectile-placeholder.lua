__CN_PROJECTILE_PLACEHOLDER = __CN_PROJECTILE_PLACEHOLDER or {}
local __cn = __CN_PROJECTILE_PLACEHOLDER

local Util = require("__core__.lualib.util")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")
local __Data_Utils = require("data-utils")

local PROJECTILE_PLACEHOLDER_COLLISION = __cn.PROJECTILE_PLACEHOLDER_COLLISION or Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.PROJECTILE_PLACEHOLDER_COLLISION.name })
local QUALITY_BASE_MULTIPLIER = __cn.QUALITY_BASE_MULTIPLIER or Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.name, })
local DO_MAP_REVEAL = __cn.DO_MAP_REVEAL or Data_Utils.get_startup_setting({ setting = Startup_Settings_Constants.settings.DO_MAP_REVEAL.name, })

__cn.PROJECTILE_PLACEHOLDER_COLLISION = PROJECTILE_PLACEHOLDER_COLLISION
__cn.QUALITY_BASE_MULTIPLIER = QUALITY_BASE_MULTIPLIER
__cn.DO_MAP_REVEAL = DO_MAP_REVEAL

local lilys_mm_active = mods and mods["lilys-mm"]

local DEBUG = DEBUG or false
local debug = DEBUG or __SEEBUG

local debug_count = 0
local function get_debug_count(params)
    -- return debug.get_debug_count(params)
    if (params) then debug_count = debug_count + 1 end
    return debug_count
end

local GDCAI = function () return get_debug_count("Get debug_count and increment") end

local function create_new_action(params)
    if (DEBUG) then log(serpent.block(params)) end
    params = type(params) == "table" and params or nil
    local depth = params and params.depth or 1

    local action_array = false
    if (params and params.action and type(params.action) == "table" and params.action[1]) then
        if (not params.action[2]) then
            params.action = params.action[1]
        else
            action_array = true
        end
    end

    local effect_array = false
    if (params and params.effect and type(params.effect) == "table" and params.effect[1]) then
        if (not params.effect[2]) then
            params.effect = params.effect[1]
        else
            effect_array = true
        end
    end

    if (not effect_array) then
        if (params and params.effect and (params.effect.source_effects or params.effect.target_effects)) then
            params.source_effects = params.effect.source_effects
            params.target_effects = params.effect.target_effects
            params.__effect = params.effect
            params.effect = nil
        end
    end

    local return_t = nil

    if (
            params
        and params.action
        and not action_array
    ) then
        return_t = { action = params.action, type = "instant", }
    elseif(
            action_array
        and params
        and params.action
    ) then
        return_t = {}
        for _, _action in ipairs(params.action) do table.insert(return_t,
            {
                action_delivery = {
                    {
                        action =
                        {
                            action_delivery  =
                            {
                                type = "instant",
                                _action,
                            },
                            type = "direct"
                        },
                        type = "nested-result",
                    },
                    type = "instant",
                },
                type = "direct",
            }
        ) end
    elseif (params and params.effect) then
        return_t = {}
        if (effect_array) then
            for _, _effect in ipairs(params.effect) do
                if (depth > 0) then
                    table.insert(return_t,
                        {
                            type = "instant",
                            _effect,
                        }
                    )
                else
                    table.insert(return_t,
                        {
                            action =
                            {
                                action_delivery  =
                                {
                                    type = "instant",
                                    _effect,
                                },
                                type = "direct",
                            },
                            type = "nested-result",
                        }
                    )
                end
            end
        else
            return_t =
            {
                action =
                {
                    action_delivery =
                    {
                        type = "instant",
                        action = params.effect,
                    },
                    type = "direct",
                },
                type = "nested-result",
            }
        end
    elseif (params and (params.target_effects or params.source_effects)) then
        return_t =
        {
            action = {
                action_delivery  = {
                    target_effects = params.target_effects,
                    source_effects = params.source_effects,
                    type = "instant",
                },
                type = "direct",
            },
            type = "nested-result",
        }
    else
        return_t =
        {
            target_effects =
            {
                params
            },
            type = "direct",
        }
    end

    return return_t
end

local function dummy_projectile_action(params)
    if (type(params) == "string" and params:gsub("%s+", "") ~= "") then params = { name = params, } end
    if (type(params) ~= "table") then params = { name = params, } end

    params.type =   (
                        params.name:find("artillery")
                    or
                        params.name:find("landmine")
                    or
                        params.name:find("land%-mine")
                )
                and "artillery"
                or
                    "projectile"

    local __self = {}
    __self.name = params.name
    __self.type = params.type

    __self.dummy_projectile_rocket = Util.table.deepcopy(data.raw["projectile"]["payloader-dummy-rocket"])
    __self.dummy_projectile_rocket.name = __self.name

    __self.dummy_projectile_action =
    {
        action_delivery =
        {
            type = params.type,
            projectile = __self.name,
            starting_speed = 1,
        },
        type = "direct",
    }

    local function set_self(self, _params)
        self = self or __self
        if (not _params and self ~= __self) then
            _params = self
            self = __self
        end
        return self, _params
    end

    function __self.make(self, _params)
        self, _params = set_self(self, _params)

        if (type(_params) == "string" and _params:gsub("%s+", ""):lower() == "raw") then _params = { raw = true, }end
        local raw = type(_params) == "table" and type(_params.raw) == "boolean" and _params.raw or false

        if (self.dummy_projectile_action.type:find("artillery")) then
            self.dummy_projectile_action.type = "artillery"
        end

        return raw and self.dummy_projectile_action or Util.table.deepcopy(self.dummy_projectile_action or {})
    end
    function __self.make_final_action(self, _params)
        self, _params = set_self(self, _params)

        if (type(_params) == "string" and _params:gsub("%s+", ""):lower() == "raw") then _params = { raw = true, }end
        local raw = type(_params) == "table" and type(_params.raw) == "boolean" and _params.raw or false

        local projectile = self.dummy_projectile_rocket

        self.final_action =
        {
            action_delivery =
            {
                type = projectile.type:find("artillery") and "artillery" or "projectile",
                projectile = projectile.name,
                starting_speed = 1,
            },
            type = "direct",
        }

        return raw and self.final_action or Util.table.deepcopy(self.final_action or {})
    end
    function __self.get(self, _params)
        self, _params = set_self(self, _params)

        if (type(_params) == "string" and _params:gsub("%s+", ""):lower() == "raw") then _params = { raw = true, }end
        local copy = type(_params) == "table" and type(_params.copy) == "boolean" and _params.copy or false

        local projectile = self.dummy_projectile_rocket

        return copy and Util.table.deepcopy(projectile or {}) or projectile
    end

    local raw = type(params) == "table" and type(params.raw) == "boolean" and params.raw or false
    return __self:make({ raw = raw, }),
        {
            get                 = __self.get,
            make                = __self.make,
            make_action         = __self.make,
            create              = __self.make,
            create_action       = __self.make,
            make_final_action   = __self.make_final_action,
            create_final_action = __self.make_final_action,
        }
end

local progression = {
    ["action"] = "action_delivery",
    ["action_delivery"] = {
        ["target_effects"] = "target_effects",
        ["source_effects"] = "source_effects",
    },
    ["target_effects"] = "action",
    ["source_effects"] = "action",
}

local function map_reveal_action()
    if (DO_MAP_REVEAL) then
        return
        {
            type = "nested-result",
            action = {
                {
                    type = "direct",
                    action_delivery =
                    {
                        {
                            type = "instant",
                            target_effects =
                            {
                                type = "script",
                                effect_id = "map-reveal"
                            }
                        },
                    },
                },
            },
        }
    else
        return
    end
end

--[[ make_projectile_placeholder ]]
return function (params)
    if (DEBUG) then log(GDCAI()) end
    -- if (DEBUG) then log(serpent.block(params)) end

    if (not params or type(params) ~= "table") then return end
    if (DEBUG) then log(GDCAI()) end
    if (not params.name or type(params.name) ~= "string") then return end
    if (DEBUG) then log(GDCAI()) end
    if (lilys_mm_active and params.name:find("artillery%-pack")) then
        params.__name = params.name
        params.name = params.name:match("(.*%-artillery)%-pack")
    end

    if (DEBUG) then log(GDCAI()) end
    if (params.magazine_size and (type(params.magazine_size) ~= "number" or params.magazine_size < 1)) then params.magazine_size = nil end

    local projectile_placeholder = Util.table.deepcopy(data.raw.projectile.rocket)

    projectile_placeholder.name = "cn-projectile-placeholder-" .. params.name
    projectile_placeholder.icon = "__core__/graphics/empty.png"
    projectile_placeholder.icons = nil
    if (params.collision) then
        if (DEBUG) then log(GDCAI()) end
        projectile_placeholder.collision_box = {
            { -0.3, -1.1, },
            { 0.3, 1.1, }
        }
    end

    projectile_placeholder.animation = nil
    projectile_placeholder.shadow = nil
    projectile_placeholder.smoke = nil

    local function __dummy_projectile()
        local _, closure = dummy_projectile_action("cn-payloader-dummy-projectile-" .. params.name)

        return closure
    end
    local dummy_projectile = __dummy_projectile()

    projectile_placeholder.__action = projectile_placeholder.action
    projectile_placeholder.action = nil
    dummy_projectile.get().__action = dummy_projectile.get().action
    dummy_projectile.get().action = nil

    local target_effects = { map_reveal_action(), }
    local source_effects = { map_reveal_action(), }
    local action_delivery =
    {
        target_effects = target_effects,
        source_effects = source_effects,
        type = "instant",
    }
    local action =
    {
        action_delivery = action_delivery,
        type = "direct",
    }
    local trigger_effects = {
        ["target_effects"] = target_effects,
        ["source_effects"] = source_effects,
        ["action_delivery"] = action_delivery,
        ["action"] = action,
    }
    trigger_effects.action = Util.table.deepcopy(trigger_effects.action)
    trigger_effects.action_delivery = trigger_effects.action.action_delivery
    trigger_effects.action_delivery.source_effects = trigger_effects.action.action_delivery.source_effects
    trigger_effects.action_delivery.target_effects = trigger_effects.action.action_delivery.target_effects

    if (DEBUG) then log(GDCAI()) end
    if (params.source) then

        if (DEBUG) then log(GDCAI()) end
        local entity = nil
        if (params.source.ammo.ammo_category == "artillery-shell") then
            if (DEBUG) then log(GDCAI()) end
            entity = data.raw["artillery-projectile"][params.name] or nil
        else
            if (DEBUG) then log(GDCAI()) end
            if (data.raw["projectile"]) then
                if (DEBUG) then log(GDCAI()) end
                entity = data.raw["projectile"][params.name] or nil
            end
            if (not entity and data.raw["beam"]) then
                if (DEBUG) then log(GDCAI()) end
                entity = data.raw["beam"][params.name] or nil
            end
            if (not entity and data.raw["stream"]) then
                if (DEBUG) then log(GDCAI()) end
                entity = data.raw["stream"][params.name] or nil
            end
            if (not entity) then
                if (DEBUG) then log(GDCAI()) end
                entity = data.raw.ammo[params.name] or nil
            end
            if (DEBUG) then log(GDCAI()) end
        end
        if (DEBUG) then log(GDCAI()) end
        if (not entity) then entity = params.source.ammo end

        entity = type(entity) == "table" and entity or nil

        if (DEBUG) then log(GDCAI()) end
        --[[ TODO: Add configurable startup settings for controlling this ]]
        if (entity and (entity.collision_box or entity.type == "ammo")) then
            if (DEBUG) then log(GDCAI()) end
            local non_zero = false
            if (entity.collision_box) then
                for k_o, v_o in pairs(entity.collision_box) do
                    local inner_non_zero = false
                    for k_i, v_i in pairs(v_o) do
                        if (v_i ~= 0) then inner_non_zero = true end
                        if (inner_non_zero) then break end
                    end
                    if (inner_non_zero) then non_zero = true end
                    if (non_zero) then break end
                end
            end

            if (non_zero) then
                projectile_placeholder.collision_box = entity.collision_box or {{ -0.3, -1.1, }, { 0.3, 1.1, }}
            end
        end

        if (
                params.source.ammo.ammo_category == "flamethrower"
            or  params.source.ammo.ammo_category == "mortar-bomb"
            or  params.source.ammo.subgroup == "mortar-ammo"
        ) then
            projectile_placeholder.collision_box = nil
            projectile_placeholder.collision_mask = nil
        end

        if (
            --[[ Startup_Settings_Constants.settings.PROJECTILE_PLACEHOLDER_COLLISION ]]
            PROJECTILE_PLACEHOLDER_COLLISION == "all"
        ) then
            projectile_placeholder.collision_box = projectile_placeholder.collision_box or {{ -0.3, -1.1, }, { 0.3, 1.1, }}
        elseif (
            PROJECTILE_PLACEHOLDER_COLLISION == "none"
        ) then
            projectile_placeholder.collision_box = nil
        end

        local function collate_trigger_effects(_params)
            if (type(_params) ~= "table") then return end

            local effects = _params.effects
            local stage = _params.stage or "action"
            local parent = _params.parent or entity

            if (type(effects) ~= "table") then return end

            local depth = 0
            local order = 1

            local added = {}

            local function recurse(__params)
                if (type(__params) ~= "table") then return end
                if (depth > 3) then return end

                local t = __params.table
                local k = __params.key
                local p = __params.parent

                local stage = k or "action"
                local next_stage = progression[stage]

                if (type(t) ~= "table") then return end
                depth = depth + 1

                if (type(next_stage) == "table") then
                    for _, _stage in pairs(next_stage) do
                        local gathered_effects = {}
                        for key, value in pairs(t) do
                            if (key == _stage and type(value) == "table") then
                                recurse({ table = value, key = key, parent = t, })
                                if (trigger_effects[key]) then
                                    added[trigger_effects[key]] = added[trigger_effects[key]] or {}
                                    if (not added[trigger_effects[key]][value]) then
                                        local nested_result = create_new_action({ effect = value, depth = depth, })
                                        if (nested_result) then
                                            if (nested_result[1]) then
                                                for _, result in ipairs(nested_result) do
                                                    table.insert(gathered_effects, Util.table.deepcopy(result))
                                                end
                                            else
                                                table.insert(gathered_effects, Util.table.deepcopy(nested_result))
                                            end
                                            added[trigger_effects[key]][value] = { depth = depth, order = order, value = value, key = key, parent = t, }
                                            added[trigger_effects[key]][nested_result or value] = { depth = depth, order = order, value = value, key = key, parent = t, }
                                        end
                                    end
                                end
                            end
                        end
                        if (not added[gathered_effects]) then
                            if (next(gathered_effects) and gathered_effects[1] and #gathered_effects == 1) then gathered_effects = gathered_effects[1] end
                            if (next(gathered_effects)) then
                                local nested_result = create_new_action({ effect = gathered_effects, depth = depth, })
                                if (nested_result) then
                                    if (nested_result[1]) then
                                        for _, result in ipairs(nested_result) do
                                            table.insert(trigger_effects[stage], Util.table.deepcopy(result))
                                        end
                                    else
                                        table.insert(trigger_effects[stage], Util.table.deepcopy(nested_result))
                                    end
                                    added[nested_result] = { depth = depth, order = order, value = nested_result, key = stage, parent = t, }
                                end
                            end
                        end
                    end
                else
                    if (DEBUG) then log(GDCAI()) end
                    local gathered_effects = {}
                    for key, value in pairs(t) do
                        if (DEBUG) then log(GDCAI()) end
                        if (key == next_stage and type(value) == "table") then
                            if (DEBUG) then log(GDCAI()) end
                            recurse({ table = value, key = key, parent = t, })
                            if (trigger_effects[key]) then
                                order = order + 1
                                added[trigger_effects[key]] = added[trigger_effects[key]] or {}
                                if (not added[trigger_effects[key]][value]) then
                                    local nested_result = create_new_action({ effect = value, depth = depth, })
                                    if (nested_result) then
                                        if (nested_result[1]) then
                                            for _, result in ipairs(nested_result) do
                                                table.insert(gathered_effects, Util.table.deepcopy(result))
                                            end
                                        else
                                            table.insert(gathered_effects, Util.table.deepcopy(nested_result))
                                        end
                                        added[trigger_effects[key]][value] = { depth = depth, order = order, value = value, key = key, parent = t, }
                                        added[trigger_effects[key]][nested_result or value] = { depth = depth, order = order, value = value, key = key, parent = t, }
                                    end
                                end
                            end
                        end
                    end
                    if (DEBUG) then log(GDCAI()) end
                    if (not added[gathered_effects]) then
                        if (DEBUG) then log(GDCAI()) end
                        if (next(gathered_effects) and gathered_effects[1] and #gathered_effects == 1) then gathered_effects = gathered_effects[1] end
                        if (DEBUG) then log(GDCAI()) end
                        if (next(gathered_effects)) then
                            if (DEBUG) then log(GDCAI()) end
                            local nested_result = create_new_action({ effect = gathered_effects, depth = depth, })
                            if (DEBUG) then log(GDCAI()) end
                            if (nested_result) then
                                if (DEBUG) then log(GDCAI()) end
                                if (nested_result[1]) then
                                    if (DEBUG) then log(GDCAI()) end
                                    for _, result in ipairs(nested_result) do
                                        if (DEBUG) then log(GDCAI()) end
                                        table.insert(trigger_effects[stage], Util.table.deepcopy(result))
                                    end
                                    if (DEBUG) then log(GDCAI()) end
                                else
                                    if (DEBUG) then log(GDCAI()) end
                                    table.insert(trigger_effects[stage], Util.table.deepcopy(nested_result))
                                end
                                if (DEBUG) then log(GDCAI()) end
                                added[nested_result] = { depth = depth, order = order, value = nested_result, key = stage, parent = t, }
                            end
                        end
                    end
                end

                if (DEBUG) then log(GDCAI()) end
                depth = depth - 1
            end
            recurse({ table = effects, key = stage, parent = parent, })

            local effects_t = { ["target_effects"] = target_effects, ["source_effects"] = source_effects, }
            for trigger_effect, effects_array  in pairs(effects_t) do

                if (DEBUG) then log(GDCAI()) end
                if (effects[trigger_effect]) then
                    if (DEBUG) then log(GDCAI()) end
                    if (effects[trigger_effect][1]) then
                        if (DEBUG) then log(GDCAI()) end
                        local gathered_effects = {}
                        for _, effect in ipairs(effects[trigger_effect]) do
                            if (DEBUG) then log(GDCAI()) end
                            if (effect[1]) then
                                if (DEBUG) then log(GDCAI()) end
                                for _, sub_effect in ipairs(effect) do
                                    added[gathered_effects] = added[gathered_effects] or {}
                                    if (not added[gathered_effects][sub_effect]) then
                                        added[gathered_effects][sub_effect] = { value = sub_effect, key = sub_effect, parent = added[gathered_effects], }
                                        if (DEBUG) then log(GDCAI()) end
                                        table.insert(gathered_effects, sub_effect )
                                    end
                                end
                            else
                                if (DEBUG) then log(GDCAI()) end
                                added[gathered_effects] = added[gathered_effects] or {}
                                if (not added[gathered_effects][effect]) then
                                    added[gathered_effects][effect] = { value = effect, key = effect, parent = added[gathered_effects], }
                                    table.insert(gathered_effects, effect )
                                end
                            end
                        end
                        if (DEBUG) then log(GDCAI()) end
                        if (next(gathered_effects) and gathered_effects[1] and #gathered_effects == 1) then gathered_effects = gathered_effects[1] end
                        if (next(gathered_effects)) then
                            if (DEBUG) then log(GDCAI()) end
                            local nested_result = create_new_action({ effect = gathered_effects, depth = depth, })
                            added[gathered_effects] = added[gathered_effects] or {}
                            if (nested_result and not added[gathered_effects][nested_result]) then
                                if (DEBUG) then log(GDCAI()) end
                                added[gathered_effects][nested_result] = { value = nested_result, key = nested_result, parent = added[gathered_effects], }
                                if (nested_result[1]) then
                                    for _, result in ipairs(nested_result) do
                                        table.insert(effects_array, Util.table.deepcopy(result))
                                    end
                                else
                                    table.insert(effects_array, Util.table.deepcopy(nested_result))
                                end
                            end
                        end
                        if (DEBUG) then log(GDCAI()) end
                    else
                        if (DEBUG) then log(GDCAI()) end
                        if (next(effects[trigger_effect]) and effects[trigger_effect][1] and #effects[trigger_effect] == 1) then effects[trigger_effect] = effects[trigger_effect][1] end
                        if (next(effects[trigger_effect])) then
                            if (DEBUG) then log(GDCAI()) end
                            local nested_result = create_new_action({ effect = effects[trigger_effect], depth = depth, })
                            if (nested_result and not added[nested_result]) then
                                if (DEBUG) then log(GDCAI()) end
                                added[nested_result] = { value = nested_result, key = nested_result, parent = effects[nested_result], }
                                if (nested_result[1]) then
                                    for _, result in ipairs(nested_result) do
                                        table.insert(effects_array, Util.table.deepcopy(result))
                                    end
                                else
                                    table.insert(effects_array, Util.table.deepcopy(nested_result))
                                end
                            end
                        end
                        if (DEBUG) then log(GDCAI()) end
                    end
                    if (DEBUG) then log(GDCAI()) end
                elseif (effects[1]) then
                    for i, effect in ipairs(effects) do
                        if (DEBUG) then log(GDCAI()) end
                        if (effect[1]) then
                            if (DEBUG) then log(GDCAI()) end
                            local gathered_effects = {}
                            for _, _effect in ipairs(effect) do
                                if (_effect[1]) then
                                    if (DEBUG) then log(GDCAI()) end
                                    for _, sub_effect in ipairs(_effect) do
                                        added[gathered_effects] = added[gathered_effects] or {}
                                        if (not added[gathered_effects][sub_effect]) then
                                            added[gathered_effects][sub_effect] = { value = sub_effect, key = sub_effect, parent = added[gathered_effects], }
                                            if (DEBUG) then log(GDCAI()) end
                                            table.insert(gathered_effects, sub_effect )
                                        end
                                    end
                                else
                                    if (DEBUG) then log(GDCAI()) end
                                    added[gathered_effects] = added[gathered_effects] or {}
                                    if (not added[gathered_effects][_effect]) then
                                        added[gathered_effects][_effect] = { value = _effect, key = _effect, parent = added[gathered_effects], }
                                        table.insert(gathered_effects, _effect )
                                    end
                                end
                            end
                            if (DEBUG) then log(GDCAI()) end
                            if (next(gathered_effects)) then
                                if (DEBUG) then log(GDCAI()) end
                                local nested_result = create_new_action({ effect = gathered_effects, depth = depth, })
                                added[gathered_effects] = added[gathered_effects] or {}
                                if (nested_result and not added[gathered_effects][nested_result]) then
                                    if (DEBUG) then log(GDCAI()) end
                                    added[gathered_effects][nested_result] = { value = nested_result, key = nested_result, parent = added[gathered_effects], }
                                    if (nested_result[1]) then
                                        for _, result in ipairs(nested_result) do
                                            table.insert(effects_array, Util.table.deepcopy(result))
                                        end
                                    else
                                        table.insert(effects_array, Util.table.deepcopy(nested_result))
                                    end
                                end
                            end
                            if (DEBUG) then log(GDCAI()) end
                        else
                            if (DEBUG) then log(GDCAI()) end
                            if (next(effect) and effect[1] and #effect == 1) then effect = effect[1] end
                            if (next(effect)) then
                                local nested_result = create_new_action({ effect = effect, depth = depth, })
                                if (nested_result and not added[nested_result]) then
                                    if (DEBUG) then log(GDCAI()) end
                                    added[nested_result] = { value = nested_result, key = nested_result, parent = effects[nested_result], }
                                    if (nested_result[1]) then
                                        for _, result in ipairs(nested_result) do
                                            table.insert(effects_array, Util.table.deepcopy(result))
                                        end
                                    else
                                        table.insert(effects_array, Util.table.deepcopy(nested_result))
                                    end
                                end
                            end
                            if (DEBUG) then log(GDCAI()) end
                        end
                        if (DEBUG) then log(GDCAI()) end
                    end
                end
                if (DEBUG) then log(GDCAI()) end
            end
        end

        if (DEBUG) then log(GDCAI()) end
        if (params.source.ammo_type_data and params.source.ammo_type_data.effects) then
            collate_trigger_effects({ effects = params.source.ammo_type_data.effects, })
        end
        if (params.source.ammo_data and params.source.ammo_data.effects) then
            collate_trigger_effects({ effects = params.source.ammo_data.effects, })
        end

        if (DEBUG) then log(GDCAI()) end
        if (entity) then
            if (DEBUG) then log(GDCAI()) end
            if (entity.action) then
                if (DEBUG) then log(GDCAI()) end
                if (entity.action[1]) then
                    if (DEBUG) then log(GDCAI()) end
                    for _, _action in ipairs(entity.action) do
                        if (DEBUG) then log(GDCAI()) end
                        collate_trigger_effects({ effects = _action, })
                    end
                    if (DEBUG) then log(GDCAI()) end
                else
                    if (DEBUG) then log(GDCAI()) end
                    collate_trigger_effects({ effects = entity.action, })
                end
                if (DEBUG) then log(GDCAI()) end
            elseif (entity.ammo_type) then
                if (DEBUG) then log(GDCAI()) end
                if (entity.ammo_type[1]) then
                    if (DEBUG) then log(GDCAI()) end
                    for _, ammo_type in ipairs(entity.ammo_type) do
                        if (DEBUG) then log(GDCAI()) end
                        if (ammo_type.action) then
                            if (DEBUG) then log(GDCAI()) end
                            if (ammo_type.action[1]) then
                                if (DEBUG) then log(GDCAI()) end
                                for _, _action in ipairs(ammo_type.action) do
                                    if (DEBUG) then log(GDCAI()) end
                                    collate_trigger_effects({ effects = _action, })
                                end
                                if (DEBUG) then log(GDCAI()) end
                            else
                                if (DEBUG) then log(GDCAI()) end
                                collate_trigger_effects({ effects = ammo_type.action, })
                            end
                        end
                    end
                else
                    if (DEBUG) then log(GDCAI()) end
                    if (entity.ammo_type.action) then
                        if (DEBUG) then log(GDCAI()) end
                        if (entity.ammo_type.action[1]) then
                            if (DEBUG) then log(GDCAI()) end
                            for _, _action in ipairs(entity.ammo_type.action) do
                                if (DEBUG) then log(GDCAI()) end
                                collate_trigger_effects({ effects = _action, })
                            end
                            if (DEBUG) then log(GDCAI()) end
                        else
                            if (DEBUG) then log(GDCAI()) end
                            collate_trigger_effects({ effects = entity.ammo_type.action, })
                        end
                    end
                end
            end
        end
        if (DEBUG) then log(GDCAI()) end

        local params_action = Util.table.deepcopy(
                params.source.ammo.ammo_type
            and params.source.ammo.ammo_type[1]
            and (function (ammo_types)
                if (ammo_types) then
                    local ret = {}
                    for k, v in pairs(ammo_types) do
                        if (v.action) then
                            table.insert(ret, v.action)
                        end
                    end
                    return ret
                end
            end)(params.source.ammo.ammo_type)
            or
                params.source.ammo.ammo_type
            and params.source.ammo.ammo_type.action
            or
                { params.source.ammo.action, }
        )

        local function recurse(_data, trigger_effect_type, limit)
            if (type(_data) ~= "table") then return end
            local found = {}
            local depth = 0
            local effects_depth = 0
            limit = type(limit) == "number" and limit or 2 ^ 8

            local key = trigger_effect_type
            local keys = {}
            keys["target_effects"] = key
            keys["source_effects"] = key

            local function _recurse(t, __k, __t)
                -- if (depth > limit) then return end
                if (type(t) ~= "table") then return end
                depth = depth + 1

                local found_effect = false
                for k, v in pairs(t) do
                    if (type(v) == "table") then
                        if (keys[k] and k ~= key and t[k]) then
                            found_effect = true
                            t[key] = t[k]
                            -- if (effects_depth < limit) then
                            t[k] = nil
                            -- end
                            effects_depth = effects_depth + 1
                        end

                        _recurse(v, __k, t)
                    end
                end

                depth = depth - 1
                if (found_effect) then effects_depth = effects_depth - 1 end
            end

            _recurse({ _data, })
        end

        if (
                params.source.ammo.type == "land-mine"
        ) then
            recurse(params_action, "target_effects")
        end

        projectile_placeholder.action = __Data_Utils.table.unbox(params_action, 1)
        action =__Data_Utils.table.unbox(action, 1)
        if (not next(action.action_delivery.target_effects)) then action.action_delivery.target_effects = nil end
        if (not next(action.action_delivery.source_effects)) then action.action_delivery.source_effects = nil end
        if (action.action_delivery.target_effects or action.action_delivery.source_effects) then
            -- table.insert(projectile_placeholder.action, __Data_Utils.table.unbox(action, 1))
            table.insert(projectile_placeholder.action, 1, action)
        end


        --[[
            >>
        ]]

        projectile_placeholder.final_action = entity and type(entity.final_action) == "table" and entity.final_action or nil

        dummy_projectile.get().action = Util.table.deepcopy(projectile_placeholder.action)
        dummy_projectile.get().final_action = Util.table.deepcopy(action)

        projectile_placeholder.final_action = projectile_placeholder.final_action or action

        if (PROJECTILE_PLACEHOLDER_COLLISION == "none") then
            dummy_projectile.get().collision_box = nil
            dummy_projectile.get().collision_mask = nil
        end

        --[[
            <<
        ]]

        --[[
            -> Add/enable whatever is minimumly needed for basic payload function, irrespective of selected settings
        ]]
        -- -> nothing presently?
    end

    if (DEBUG) then log(GDCAI()) end
    if (params.magazine_size) then
        local x = params.magazine_size or 1
        if (x < 1) then x = 1 end
        if (x > 200) then x = 200 end

        if (not __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE) then
            local max_stack_size = 0
            for _, _raw in pairs({data.raw.ammmo, data.raw["land-mine"]}) do
                for k, v in pairs(_raw) do
                    if (v.stack_size and v.stack_size > max_stack_size) then max_stack_size = v.stack_size end
                end
            end
            __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE = max_stack_size
        end
        __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE = __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE > 0 and __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE or 200

        if (__CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE > 2 ^ 32 - 1) then __CN_MAX_POSSIBLE_PAYLOAD_STACK_SIZE = 2 ^ 32 - 1 end

        local q = QUALITY_BASE_MULTIPLIER
        local q_max = Startup_Settings_Constants.settings.QUALITY_BASE_MULTIPLIER.maximum_value
        local max_stack_size = 200
        local magazine_size_modifier = 1 + (((1 + (((q + q_max)/((q + q_max) ^ 0.54321 ))) * ((q_max - 1) - (q_max - 1.3)) + ((((max_stack_size - x) ^ (2)) / max_stack_size) / max_stack_size))) /  (3)) ^ (q_max - (q_max - 1) * (q / q_max))

        local modified_magazine_size = params.magazine_size * magazine_size_modifier
        if (modified_magazine_size < x) then modified_magazine_size = x end
        --[[ Highest stack size (nominally 200) * legendary quality bonus (2.5) ]]
        if (modified_magazine_size > 200 * 2.5) then modified_magazine_size = 200 * 2.5 end

        if (DEBUG) then log(GDCAI()) end
        if (projectile_placeholder.action[1]) then
            for _, _action in ipairs(projectile_placeholder.action) do
                if (type(_action) == "table") then
                    local repeat_count = math.floor(math.log(modified_magazine_size, modified_magazine_size / #(projectile_placeholder.action)))
                    _action.repeat_count = repeat_count > 1 and math.floor(repeat_count) or 1
                end
            end
        else
            projectile_placeholder.action.repeat_count = math.floor(modified_magazine_size)
        end
    end

    -- log(serpent.block(projectile_placeholder))
    -- log(serpent.block(dummy_projectile.get()))

    return projectile_placeholder, dummy_projectile.get()
end