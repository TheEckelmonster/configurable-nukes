
-- Globals
Log = require("__TheEckelmonster-core-library__.libs.log.log")
Event_Handler = require("__TheEckelmonster-core-library__.scripts.event-handler")

---
--[[
    -> Storage
]]

local function get_storage(key, keys)
    storage.storage_attributes = storage.storage_attributes or setmetatable({}, { __mode = "k", })
    if (key) then
        storage[key] = storage[key] or {}
    end
end

function Storage(...)
    -- local key = ... and tostring(...) or nil
    local key = ... and #{...} == 1 and tostring(...) or (function (...)
        local ret, args = "", {...}

        for i = 1, #args, 1 do
            ret = ret .. tostring(args[i])
        end

        return ret
    end)(...) or nil
    get_storage(key)
    return key and storage[key] or storage
end
function Storage_Attributes(...)
    -- local key = ... and tostring(...) or nil
    local key = ... and #{...} == 1 and tostring(...) or (function (...)
        local ret, args = "", {...}

        for i = 1, #args, 1 do
            ret = ret .. tostring(args[i])
        end

        return ret
    end)(...) or nil
    get_storage(key)
    return key and storage[key] or storage.storage_attributes
end

---
--[[
    -> Cache
]]

local function get_caches(key)
    storage.cache = storage.cache or {}
    storage.cache_attributes = storage.cache_attributes or setmetatable({}, { __mode = "k", })
    if (key) then
        storage.cache[key] = storage.cache[key] or {}
        storage.cache_attributes[key] = storage.cache_attributes[key] or setmetatable({}, { __mode = "k", })
    end
end

function Cache(...)
    -- local key = ... and tostring(...) or nil
    local key = ... and #{...} == 1 and tostring(...) or (function (...)
        local ret, args = "", {...}

        for i = 1, #args, 1 do
            ret = ret .. tostring(args[i])
        end

        return ret
    end)(...) or nil
    get_caches(key)
    return key and storage.cache[key] or storage.cache
end
function Cache_Attributes(...)
    -- local key = ... and tostring(...) or nil
    local key = ... and #{...} == 1 and tostring(...) or (function (...)
        local ret, args = "", {...}

        for i = 1, #args, 1 do
            ret = ret .. tostring(args[i])
        end

        return ret
    end)(...) or nil
    get_caches(key)
    return key and storage.cache_attributes[key] or storage.cache_attributes
end

---

--[[ Data types and metatables ]]

-- circuit-network
local Circuit_Network_Rocket_Silo_Data = require("scripts.data.circuit-network.rocket-silo-data")

script.register_metatable("Circuit_Network_Rocket_Silo_Data", Circuit_Network_Rocket_Silo_Data)

-- space
--   -> celestial-objects
local Anomaly_Data = require("scripts.data.space.celestial-objects.anomaly-data")
local Asteroid_Belt_Data = require("scripts.data.space.celestial-objects.asteroid-belt-data")
local Asteroid_Field_Data = require("scripts.data.space.celestial-objects.asteroid-field-data")
local Moon_Data = require("scripts.data.space.celestial-objects.moon-data")
local Orbit_Data = require("scripts.data.space.celestial-objects.orbit-data")
local Planet_Data = require("scripts.data.space.celestial-objects.planet-data")
local Star_Data = require("scripts.data.space.celestial-objects.star-data")

script.register_metatable("Anomaly_Data", Anomaly_Data)
script.register_metatable("Asteroid_Belt_Data", Asteroid_Belt_Data)
script.register_metatable("Asteroid_Field_Data", Asteroid_Field_Data)
script.register_metatable("Moon_Data", Moon_Data)
script.register_metatable("Orbit_Data", Orbit_Data)
script.register_metatable("Planet_Data", Planet_Data)
script.register_metatable("Star_Data", Star_Data)

-- space
local Space_Connection_Data = require("scripts.data.space.space-connection-data")
local Space_Location_Data = require("scripts.data.space.space-location-data")
local Spaceship_Data = require("scripts.data.space.spaceship-data")

script.register_metatable("Space_Connection_Data", Space_Connection_Data)
script.register_metatable("Space_Location_Data", Space_Location_Data)
script.register_metatable("Spaceship_Data", Spaceship_Data)

-- structures
local Queue_Data = require("__TheEckelmonster-core-library__.libs.data.structures.queue-data")

script.register_metatable("Queue_Data", Queue_Data)

-- versions
local Bug_Fix_Data = require("__TheEckelmonster-core-library__.libs.data.versions.bug-fix-data")
local Major_Data = require("__TheEckelmonster-core-library__.libs.data.versions.major-data")
local Minor_Data = require("__TheEckelmonster-core-library__.libs.data.versions.minor-data")

script.register_metatable("Bug_Fix_Data", Bug_Fix_Data)
script.register_metatable("Major_Data", Major_Data)
script.register_metatable("Minor_Data", Minor_Data)

-- unsorted
local Cache_Attributes_Data = require("scripts.data.cache.cache-attribute-data")
local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Data = require("__TheEckelmonster-core-library__.libs.data.data")
local Force_Launch_Data = require("scripts.data.force-launch-data")
local Hash_Key_Data = require("scripts.data.hash-key-data")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Meta_Data = require("scripts.data.ICBM-meta-data")
local Rhythm = require("scripts.rhythm")
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Meta_Data = require("scripts.data.rocket-silo-meta-data")
local Version_Data = require("scripts.data.version-data")

script.register_metatable("Cache_Attributes_Data", Cache_Attributes_Data)
script.register_metatable("Configurable_Nukes_Data", Configurable_Nukes_Data)
script.register_metatable("Data", Data)
script.register_metatable("Force_Launch_Data", Force_Launch_Data)
script.register_metatable("Hash_Key_Data", Hash_Key_Data)
script.register_metatable("ICBM_Data", ICBM_Data)
script.register_metatable("ICBM_Meta_Data", ICBM_Meta_Data)
script.register_metatable("Rhythm", Rhythm)
script.register_metatable("Rocket_Silo_Data", Rocket_Silo_Data)
script.register_metatable("Rocket_Silo_Meta_Data", Rocket_Silo_Meta_Data)
script.register_metatable("Version_Data", Version_Data)

---

Hash = {}

function Hash.hashed_tick(...)
    storage.hash_keys = storage.hash_keys or Hash_Key_Data:new({})
    local __hash_keys = storage.hash_keys

    if (__hash_keys.tick < game.tick) then
        __hash_keys.tick = game.tick
        __hash_keys.tick_count = 0
    end
    if (__hash_keys.tick == game.tick) then
        __hash_keys.tick_count = __hash_keys.tick_count + 1
    end
    return __hash_keys.tick_count
end

function Hash.hash(...)
    storage.hash_keys = storage.hash_keys or Hash_Key_Data:new({})
    local __hash_keys = storage.hash_keys
    local argv = {...}
    local opts = argv and argv[#argv] or { new_key = false, }
    opts = type(opts) == "table" and opts or { new_key = false, persist = false, }

    local hash_keys = __hash_keys

    local function do_hash(...)
        local base = ... and {...} or { hashed_tick = game.tick .. "/" .. Hash.hashed_tick(), }
        for k, v in pairs(base) do
            if (type(k) == "table") then
                local hash = Hash.hashed_tick()
                base[hash] = { base[k], hashed_tick = hash, }
                base[k] = nil
            end
        end

        local hashed_key = helpers.encode_string(helpers.table_to_json(base))

        if (hash_keys[hashed_key] and not opts.new_key) then return hashed_key, base end

        if (not hash_keys[hashed_key]) then
            local k, v = next(base)
            if (k and tostring(k) ~= "hashed_tick" and not base["hashed_tick"]) then
                hash_keys[hashed_key] = opts.persist and Hash_Key_Data:new({ k = hashed_key, b = base, no_attr = false, }) or nil
                if (hash_keys[hashed_key]) then
                    Cache("hashed-keys")[hashed_key] = hash_keys[hashed_key]
                    local cas = Cache_Attributes("hashed-keys")
                    cas[hash_keys[hashed_key]] = Cache_Attributes_Data:new({  cas = cas, k = hash_keys[hashed_key], time_to_live = game.tick + 1234 })
                end
            end
            return hashed_key, base
        else
            -- log("hash recurse")
            return do_hash({ hashed_key, hash_keys[hashed_key], ...})
        end
    end

    return do_hash(...)
end
function Hash.new_hash(...)
    return Hash.hash(..., { new_key = true, })
end

function Hash.decode(hash)
    return (function (...)
        -- log(serpent.block(...))
        -- log(serpent.block({...}))
        local args = {...}
        local hash = args[1]
        local ret_tbl = nil
        -- log(serpent.block(hash))
        if (hash) then
            -- log(tostring(helpers.decode_string(hash)))
            -- log(serpent.block(helpers.json_to_table(helpers.decode_string(hash) or "")))
            ret_tbl = helpers.json_to_table(helpers.decode_string(hash) or "")
        end

        return ret_tbl
    end)(tostring(hash))
end

---

Loaded = false
Is_Singleplayer = false
Is_Multiplayer = false

require("scripts.events")
require("scripts.commands")

--[[ This event is so that the current game.tick is always available in storage, even if the game object itself is not available
    -> namely for the "on_load" event, as the game object is not available, but storage is available to read from
]]
-- Event_Handler:register_event({
--     event_name = "on_tick",
--     source_name = "control.on_tick",
--     func_name = "control.on_tick",
--     func = function (event)
--        if (storage and event and event.tick) then storage.tick = event.tick end
--     end,
-- })

-- Event_Handler:set_event_position({
--     event_name = "on_tick",
--     source_name = "control.on_tick",
--     new_position = 1,
-- })
Event_Handler:register_event({
    event_name = "on_nth_tick",
    nth_tick = 10,
    source_name = "control.on_nth_tick",
    func_name = "control.on_nth_tick",
    func = function (event)
       if (storage and event and event.tick) then storage.tick = event.tick end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_nth_tick",
    nth_tick = 10,
    source_name = "control.on_nth_tick",
    new_position = 1,
})

Event_Handler:register_event({
    event_name = "on_configuration_changed",
    source_name = "control.on_configuration_changed",
    func_name = "control.on_configuration_changed",
    func = function (event)
        if (storage and game and game.tick) then storage.tick = game.tick end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_configuration_changed",
    source_name = "control.on_configuration_changed",
    new_position = 1,
})