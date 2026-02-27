local CU = require("scripts.utils.cache-utils")
local Cache_Utils, Reinit_Cache = CU[1], CU[2]
local Custom_Events = require("prototypes.custom-events.custom-events")
local Hash_Key_Data = require("scripts.data.hash-key-data")
-- local Rhythm = require("scripts.rhythm")
local Runtime_Global_Settings_Constants = require("settings.runtime-global.runtime-global-settings-constants")

local cache_controller = {}
cache_controller.name = "cache_controller"

cache_controller.cache_list = {
    ["hashed-keys"] = { name = "hashed-keys", }
}

-- cache_controller.rhythm = { name = cache_controller.name, }
-- local rhythm = Rhythm.new(cache_controller.rhythm, cache_controller.rhythm)
-- local Prime_Random = Rhythm.prime_random

cache_controller.nth_tick_cache_processing = Data_Utils.get_runtime_global_setting({ setting = Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.name }) or 60
cache_controller.settings_handle = {
    ["runtime-global"] = {},
}

local settings_dictionary = {
    ["startup"] = {},
    ["runtime-global"] = {
        [Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.name] = Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.default_value,
    },
}

local cache_handle = Cache_Utils.register_cache({ name = cache_controller.name, })
cache_controller.cache_handle = cache_handle
Event_Handler:register_events({
    {
        event_name = Custom_Events.cn_init_cache.name,
        source_name = cache_controller.name .. ".reinit_cache",
        func_name = cache_controller.name .. ".reinit_cache",
        func = cache_controller.reinit_cache,
    },
})

local hash_keys = nil
local cache, cache_attributes = nil, nil

function cache_controller.reinit_cache()
    cache_handle.__reinit_cache()
    cache, cache_attributes = Reinit_Cache(cache_handle, cache_handle.name)

    storage.hash_keys = storage.hash_keys or Hash_Key_Data:new({})
    Hash.keys = Hash.keys or storage.hash_keys

    storage.hash_keys[cache_handle.name] = storage.hash_keys[cache_handle.name] or Hash_Key_Data:new({ name = cache_handle.name, })
    hash_keys = storage.hash_keys[cache_handle.name]
end
cache_handle.reinit_cache = cache_controller.reinit_cache

-- local function clean_cache(self, opts)
--     opts = opts and type(opts) == "table" and opts or {}
--     local cache, cache_attributes = opts.cache or {}, opts.cache_attributes or {}

--     storage.cache = storage.cache or {}
--     storage.cache_attributes = storage.cache_attributes or {}

--     for k, v in pairs(cache or {}) do
--         if (cache_attributes[v]) then
--             local attr = cache_attributes[v]
--             attr = type(attr) == "table" and attr or {}
--             if (attr.time_to_live < game.tick or not attr.valid) then
--                 attr.valid = false
--                 attr.updated = game.tick
--                 attr.cas[attr.k] = nil
--             else
--                 if (attr.time_to_live ~= math.huge and attr.time_to_live >= 0) then
--                     attr.found_count = (attr.found_count or 0) + 1
--                     local ttl, created = attr.time_to_live, attr.created
--                     local diffed_ttl, found_count = ttl - created, attr.found_count
--                     local proportion = found_count ^ (0.01 * (found_count ^ (0.25 * (1 / found_count))) + 1)

--                     attr.time_to_live = math.floor(diffed_ttl * (found_count ^ 2 + (found_count * (1 - (proportion / (proportion + 1)))) ^ 2) / ((1.5 * found_count) ^ 2) + created)
--                     attr.updated = game.tick
--                 end
--             end
--         else
--             if (type(v) == "table" and not v.no_attr) then
--                 --[[ Can have an attr but none presently exists ]]
--                 cache[k] = nil
--             end
--         end
--     end

--     for k, v in pairs(cache_attributes or {}) do
--         local attr = type(v) == "table" and v or {}
--         if (attr.time_to_live < game.tick or not attr.valid) then
--             attr.valid = false
--             attr.updated = game.tick
--             attr.cas[attr.k] = nil
--         else
--             if (attr.time_to_live ~= math.huge and attr.time_to_live >= 0) then
--                 attr.found_count = (attr.found_count or 0) + 1
--                 local ttl, created = attr.time_to_live, attr.created
--                 local diffed_ttl, found_count = ttl - created, attr.found_count
--                 local proportion = found_count ^ (0.01 * (found_count ^ (0.25 * (1 / found_count))) + 1)

--                 attr.time_to_live = math.floor(diffed_ttl * (found_count ^ 2 + (found_count * (1 - (proportion / (proportion + 1)))) ^ 2) / ((1.5 * found_count) ^ 2) + created)
--                 attr.updated = game.tick
--             end
--         end
--     end
-- end

function cache_controller.on_nth_tick(event)

    storage.cache_controller = storage.cache_controller or {}
    local __S = storage.cache_controller
    __S.index = __S.index or 0

    __S.k, __S.v = next(cache_controller.cache_list, __S.k)
    __S.index = __S.index + 1
    if (not __S.k or not __S.v) then
        __S.k, __S.v = next(cache_controller.cache_list)
        __S.index = 1
    end
    if (not __S.k or not __S.v) then
        __S.index = 0
        return
    end

    local pseudo_self = { name = __S.k, }
    cache, cache_attributes = Cache(pseudo_self and pseudo_self.name or nil), Cache_Attributes(pseudo_self and pseudo_self.name or nil)

    __S.max_clean_count = __S.max_clean_count or 1
    __S.i = 0
    __S.cache_indices = __S.cache_indices or {}
    __S.cache_indices[cache] = __S.cache_indices[cache] or {}
    __S.cache_indices[cache_attributes] = __S.cache_indices[cache_attributes] or {}

    __S.statrted = game.tick
    local do_break = 0

    while __S.i < __S.max_clean_count and do_break < 2 do
        do_break = 0

        do
            local k, v = __S.cache_indices[cache].c_k, __S.cache_indices[cache].c_v
            if (not cache[k]) then k = nil end
            k, v = next(cache, k)
            __S.cache_indices[cache].c_k, __S.cache_indices[cache].c_v = k, v

            if(k and v) then
                if (cache_attributes[v]) then
                    local attr = cache_attributes[v]
                    if (attr.time_to_live) then
                        attr = type(attr) == "table" and attr or {}
                        if (attr.time_to_live < game.tick or not attr.valid) then
                            attr.valid = false
                            attr.updated = game.tick
                            attr.cas[attr.k] = nil
                        else
                            if (attr.time_to_live ~= math.huge and attr.time_to_live >= 0) then
                                attr.found_count = (attr.found_count or 0) + 1
                                local ttl, created = attr.time_to_live, attr.created
                                local diffed_ttl, found_count = ttl - created, attr.found_count
                                local proportion = found_count ^ (0.01 * (found_count ^ (0.25 * (1 / found_count))) + 1)

                                attr.time_to_live = math.floor(diffed_ttl * (found_count ^ 2 + (found_count * (1 - (proportion / (proportion + 1)))) ^ 2) / ((1.5 * found_count) ^ 2) + created)
                                attr.updated = game.tick
                            end
                        end
                    else

                    end
                else
                    if (type(v) == "table" and not v.no_attr) then
                        --[[ Can have an attr but none presently exists ]]
                        cache[k] = nil
                    end
                end
            else
                do_break = do_break + 1
            end
        end

        do
            local k, v = __S.cache_indices[cache_attributes].cas_k, __S.cache_indices[cache_attributes].cas_v
            if (not cache_attributes[k]) then k = nil end
            k, v = next(cache_attributes, k)
            __S.cache_indices[cache_attributes].cas_k, __S.cache_indices[cache_attributes].cas_v = k, v

            if(k and v) then
                local attr = type(v) == "table" and v or {}
                if (attr.time_to_live) then
                    if (attr.time_to_live < game.tick or not attr.valid) then
                        attr.valid = false
                        attr.updated = game.tick
                        attr.cas[attr.k] = nil
                    else
                        if (attr.time_to_live ~= math.huge and attr.time_to_live >= 0) then
                            attr.found_count = (attr.found_count or 0) + 1
                            local ttl, created = attr.time_to_live, attr.created
                            local diffed_ttl, found_count = ttl - created, attr.found_count
                            local proportion = found_count ^ (0.01 * (found_count ^ (0.25 * (1 / found_count))) + 1)

                            attr.time_to_live = math.floor(diffed_ttl * (found_count ^ 2 + (found_count * (1 - (proportion / (proportion + 1)))) ^ 2) / ((1.5 * found_count) ^ 2) + created)
                            attr.updated = game.tick
                        end
                    end
                else

                end
            else
                do_break = do_break + 1
            end
        end

        __S.i = __S.i + 1
    end

    __S.updated = game.tick

    if (do_break < 2) then
        __S.max_clean_count = __S.max_clean_count + 1
    else
        __S.max_clean_count = math.ceil(__S.max_clean_count / 2)
    end
end
--[[ Registerd in events.lua ]]

function cache_controller.on_runtime_mod_setting_changed(event)
    Log.debug("cache_controller.on_runtime_mod_setting_changed")
    Log.info(event)

    if (not event.setting or type(event.setting) ~= "string") then return end
    if (not event.setting_type or type(event.setting_type) ~= "string") then return end

    if (not (event.setting:find("configurable-nukes-", 1, true) == 1)) then return end

    if (event.setting == Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.name) then
        cache_controller.settings_handle["runtime-global"][event.setting] = Settings_Service.get_runtime_global_setting({ setting = event.setting, reindex = true })
        local new_nth_tick = cache_controller.settings_handle["runtime-global"][event.setting]
        if (    new_nth_tick ~= nil
            and type(new_nth_tick) == "number"
            and new_nth_tick >= Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.minimum_value
            and new_nth_tick <= Runtime_Global_Settings_Constants.settings.CACHE_BACKGROUND_CLEANING_RATE.maximum_value
        ) then
            new_nth_tick = new_nth_tick - new_nth_tick % 1 -- Shouldn't be necessary, but just to be sure

            local prev_nth_tick = cache_controller.nth_tick_cache_processing
            if (prev_nth_tick > 0) then
                Event_Handler:unregister_event({
                    event_name = "on_nth_tick",
                    nth_tick = prev_nth_tick,
                    source_name = "cache_controller.on_nth_tick",
                })
            end

            if (new_nth_tick > 0) then
                Event_Handler:register_event({
                    event_name = "on_nth_tick",
                    nth_tick = new_nth_tick,
                    source_name = "cache_controller.on_nth_tick",
                    func_name = "cache_controller.on_nth_tick",
                    func = cache_controller.on_nth_tick,
                })
            end
            cache_controller.nth_tick_cache_processing = new_nth_tick
        end
    elseif (settings_dictionary["runtime-global"][event.setting]) then
        cache_controller.settings_handle["runtime-global"][event.setting] = Settings_Service.get_runtime_global_setting({ setting = event.setting, reindex = true })
    end
end
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "cache_controller.on_runtime_mod_setting_changed",
    func_name = "cache_controller.on_runtime_mod_setting_changed",
    func = cache_controller.on_runtime_mod_setting_changed,
})

return cache_controller