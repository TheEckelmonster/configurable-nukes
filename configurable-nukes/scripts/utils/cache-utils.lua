local Cache_Attributes_Data = require("scripts.data.cache.cache-attribute-data")

local function deepcopy(tbl)
    local lookup_tbl = {}
    local function __copy(tbl)
        if type(tbl) ~= "table" then
            return tbl
        elseif lookup_tbl[tbl] then
            return lookup_tbl[tbl]
        end
        local new_tbl = {}
        lookup_tbl[tbl] = new_tbl
        for k, v in pairs(tbl) do
            new_tbl[__copy(k)] = __copy(v)
        end
        return setmetatable(new_tbl, getmetatable(tbl))
    end
    return __copy(tbl)
end

local function __reinit_cache(self, name)
    -- log("attempting reinit_cache")

    if (self and not name) then
        if (type(self) == "string") then
            name = self
            self = { name = name, }
        elseif (type(self) == "table") then
            name = self.name
        end
    else
        if (not self) then
            self = type(self) == "table" and self or {}
        end
    end

    storage.cache, storage.cache_attributes = storage.cache or {}, storage.cache_attributes or setmetatable({}, { __mode = "k", })
    setmetatable(storage.cache_attributes, { __mode = "k", })

    if (not name) then return storage.cache, storage.cache_attributes end
    if (type(name) ~= "string" or name:gsub("%s+", "") == "") then return storage.cache, storage.cache_attributes end
    -- log(name .. ".reinit_cache")

    storage.cache[name], storage.cache_attributes[name] = storage.cache[name] or {}, storage.cache_attributes[name] or setmetatable({}, { __mode = "k", })

    return storage.cache, storage.cache_attributes
end

local Constants = require("scripts.constants.constants")
local Custom_Events = require("prototypes.custom-events.custom-events")
local Rhythm = require("scripts.rhythm")

local cache_utils = {}
cache_utils.name = "cache_utils"

cache_utils.rhythm = { name = cache_utils.name, }
local rhythm = Rhythm.new(cache_utils.rhythm, cache_utils.rhythm)
local Prime_Random = rhythm.prime_random

if (Event_Handler) then
    Event_Handler:register_events({
        {
            event_name = Custom_Events.cn_on_init_complete.name,
            source_name = cache_utils.name .. ".init_rhythm",
            func_name = rhythm.name .. ".init_rhythm",
            func = rhythm.init_rhythm,
            func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
        },
        {
            event_name = Custom_Events.cn_reset_cache.name,
            source_name = cache_utils.name .. ".init_rhythm",
            func_name = rhythm.name .. ".init_rhythm",
            func = rhythm.init_rhythm,
            func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
        },
        {
            event_name = Custom_Events.cn_on_init_complete.name,
            source_name = cache_utils.name .. ".init_rhythm",
            func_name = cache_utils.name .. ".init_rhythm",
            func = rhythm.init_rhythm,
            func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
        },
        {
            event_name = Custom_Events.cn_reset_cache.name,
            source_name = cache_utils.name .. ".init_rhythm",
            func_name = cache_utils.name .. ".init_rhythm",
            func = rhythm.init_rhythm,
            func_data = { --[[ Passing any non-nil value resets the rhythm (?) ]] }
        },
        {
            event_name = Custom_Events.cn_init_cache.name,
            source_name = cache_utils.name .. ".init_rhythm",
            func_name = cache_utils.name .. ".init_rhythm",
            func = rhythm.init_rhythm,
        },
    })
end

local defaults = {
    name = "cache_utils",
    cache = {},
    cache_attributes = {},
}
setmetatable(defaults.cache_attributes, { __mode = "k", })

function cache_utils.register_cache(params)
    params = params or defaults

    local cache_handle = {}

    local self = {
        name = params.name or defaults.name,
        cache = params.cache or defaults.cache,
        cache_attributes = params.cache_attributes or defaults.cache_attributes,
    }
    local __self = self

    setmetatable(self.cache_attributes, { __mode = "k", })

    function self.reinit_cache(params)

        if (storage) then
            storage.cache = storage.cache or {}
            storage.cache[self.name] = storage.cache[self.name] or {}
            self.cache = storage.cache[self.name]

            storage.cache_attributes = storage.cache_attributes or {}
            storage.cache_attributes[self.name] = storage.cache_attributes[self.name] or setmetatable({}, { __mode = "k", })
            self.cache_attributes = storage.cache_attributes[self.name]
        else
            --[[ TODO: implement cache_utils during data stage ]]
        end
    end
    function self.reset_cache(params)

        if (storage) then
            storage.cache = storage.cache or {}
            storage.cache[self.name] = {}
            self.cache = storage.cache[self.name]

            storage.cache_attributes = storage.cache_attributes or {}
            storage.cache_attributes[self.name] = setmetatable({}, { __mode = "k", })
            self.cache_attributes = storage.cache_attributes[self.name]

            if (cache_handle.reinit_cache) then cache_handle.reinit_cache() end
        else
            --[[ TODO: implement cache_utils during data stage ]]
        end
    end
    function self.get_cache(params)
        storage.cache = storage.cache or {}
        storage.cache[self.name] = storage.cache[self.name] or {}
        self.cache = storage.cache[self.name]

        return storage.cache[self.name]
    end
    function self.get_cache_attributes(params)
        storage.cache_attributes = storage.cache_attributes or {}
        storage.cache_attributes[self.name] = storage.cache_attributes[self.name] or {}
        self.cache_attributes = storage.cache_attributes[self.name]
        setmetatable(storage.cache_attributes[self.name], { __mode = "k", })

        return storage.cache_attributes[self.name]
    end
    function self.get_self(tbl)
        if (tbl and type(tbl) ~= "table") then
            tbl = { raw = tbl and true or false, }
        end
        tbl = tbl or {}
        return tbl.raw and self or deepcopy(self)
    end
    function self.set_self(tbl)
        if (type(tbl) ~= "table") then return end
        if (__self == self) then __self = { self, } end
        self = tbl
    end
    function self.get_or_instantiate(params)
        local tbl, key, val, ttl, attrs = params.tbl, params.key, params.val, params.ttl or Constants.BIG_INTEGER, params.attrs
        if (type(val) == "function") then val = val() end
        val = type(val) == "table" and val or nil

        if (params.validate) then
            if (type(tbl) ~= "table" or type(key) ~= "string" or not val) then return {}, {} end
        else
            if (type(key) ~= "string") then key = key or game.tick .. "/" .. rhythm:get_count("increment") end
        end

        local cas = Cache_Attributes(self.name)

        local ret, ret_attr = val, cas[val]

        if (type(val) == "table" and not val.no_attr and (not val.type or val.type ~= "cache-attribute")) then
            if (tbl[key]) then
                if (cas[val] == nil) then
                    if (not val.no_attr and (not val.type or val.type ~= "cache-attribute")) then
                        if (type(val) == "table" and next(val)) then
                            cas[val] = Cache_Attributes_Data:new({ cas = cas, k = val, time_to_live = ttl, }, attrs)
                            ret, ret_attr = val, cas[val]
                        end
                    end
                elseif (cas[val].time_to_live) then
                    local attr = cas[val]
                    if (attr.time_to_live < game.tick or not attr.valid) then
                        attr.valid = false
                        attr.updated = game.tick
                        cas[val] = nil

                        attr.cas[attr.k] = nil

                        ret, ret_attr = val, attr
                    else
                        if (attr.time_to_live ~= math.huge and attr.time_to_live >= 0) then
                            attr.found_count = (attr.found_count or 0) + 1
                            local ttl, created = attr.time_to_live, attr.created
                            local diffed_ttl, found_count = ttl - created, attr.found_count
                            local proportion = found_count ^ (0.01 * (found_count ^ (0.25 * (1 / found_count))) + 1)

                            attr.time_to_live = math.floor(diffed_ttl * (found_count ^ 2 + (found_count * (1 - (proportion / (proportion + 1)))) ^ 2) / ((1.5 * found_count) ^ 2) + created)

                            attr.updated = game.tick

                            ret, ret_attr = val, attr
                        end
                    end
                end
            else
                tbl[key] = val
                cas[val] = Cache_Attributes_Data:new({ cas = cas, k = val, time_to_live = ttl, }, attrs)
                ret_attr = cas[val]
            end
        else
            cas[val or 0] = nil
            val = nil
        end

        return ret, ret_attr
    end

    cache_handle.__reinit_cache = self.reinit_cache
    cache_handle.reset_cache = self.reset_cache
    cache_handle.get_cache = self.get_cache
    cache_handle.get_cache_attributes = self.get_cache_attributes
    cache_handle.get_or_instantiate = self.get_or_instantiate

    cache_handle.name = self.name

    if (Event_Handler) then
        Event_Handler:register_events({
            {
                event_name = Custom_Events.cn_init_cache.name,
                source_name = self.name .. ".reinit_cache",
                func_name = cache_utils.name .. ".reinit_cache",
                func = cache_handle.reinit_cache,
            },
            {
                event_name = Custom_Events.cn_reset_cache.name,
                source_name = self.name .. ".reset_cache",
                func_name = cache_utils.name .. ".reset_cache",
                func = cache_handle.reset_cache,
            },
        })
    end

    return cache_handle
end

return { cache_utils, __reinit_cache, }