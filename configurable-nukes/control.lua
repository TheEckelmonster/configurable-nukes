
-- Globals
Log = require("__TheEckelmonster-core-library__.libs.log.log")
Event_Handler = require("__TheEckelmonster-core-library__.scripts.event-handler")

Cache = {}
Cache_Attributes = {}
setmetatable(Cache_Attributes, { __mode = 'k' })

Random = nil

Primes = {
    [1] = {
        1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693, 1697, 1699, 1709, 1721, 1723, 1733, 1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847, 1861, 1867, 1871, 1873, 1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997, 1999,
    },
    [2] = {
        2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129, 2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287, 2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417, 2423, 2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531, 2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593, 2609, 2617, 2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687, 2689, 2693, 2699, 2707, 2711, 2713, 2719, 2729, 2731, 2741, 2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819, 2833, 2837, 2843, 2851, 2857, 2861, 2879, 2887, 2897, 2903, 2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999,
    },
    [3] = {
        3001, 3011, 3019, 3023, 3037, 3041, 3049, 3061, 3067, 3079, 3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181, 3187, 3191, 3203, 3209, 3217, 3221, 3229, 3251, 3253, 3257, 3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331, 3343, 3347, 3359, 3361, 3371, 3373, 3389, 3391, 3407, 3413, 3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511, 3517, 3527, 3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571, 3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643, 3659, 3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727, 3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821, 3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907, 3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967, 3989,
    },
    [4] = {
        4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057, 4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129, 4133, 4139, 4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231, 4241, 4243, 4253, 4259, 4261, 4271, 4273, 4283, 4289, 4297, 4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409, 4421, 4423, 4441, 4447, 4451, 4457, 4463, 4481, 4483, 4493, 4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583, 4591, 4597, 4603, 4621, 4637, 4639, 4643, 4649, 4651, 4657, 4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751, 4759, 4783, 4787, 4789, 4793, 4799, 4801, 4813, 4817, 4831, 4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937, 4943, 4951, 4957, 4967, 4969, 4973, 4987, 4993, 4999,
    },
    [5] = {
        5003, 5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087, 5099, 5101, 5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179, 5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279, 5281, 5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387, 5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443, 5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521, 5527, 5531, 5557, 5563, 5569, 5573, 5581, 5591, 5623, 5639, 5641, 5647, 5651, 5653, 5657, 5659, 5669, 5683, 5689, 5693, 5701, 5711, 5717, 5737, 5741, 5743, 5749, 5779, 5783, 5791, 5801, 5807, 5813, 5821, 5827, 5839, 5843, 5849, 5851, 5857, 5861, 5867, 5869, 5879, 5881, 5897, 5903, 5923, 5927, 5939, 5953, 5981, 5987,
    },
    [6] = {
        6007, 6011, 6029, 6037, 6043, 6047, 6053, 6067, 6073, 6079, 6089, 6091, 6101, 6113, 6121, 6131, 6133, 6143, 6151, 6163, 6173, 6197, 6199, 6203, 6211, 6217, 6221, 6229, 6247, 6257, 6263, 6269, 6271, 6277, 6287, 6299, 6301, 6311, 6317, 6323, 6329, 6337, 6343, 6353, 6359, 6361, 6367, 6373, 6379, 6389, 6397, 6421, 6427, 6449, 6451, 6469, 6473, 6481, 6491, 6521, 6529, 6547, 6551, 6553, 6563, 6569, 6571, 6577, 6581, 6599, 6607, 6619, 6637, 6653, 6659, 6661, 6673, 6679, 6689, 6691, 6701, 6703, 6709, 6719, 6733, 6737, 6761, 6763, 6779, 6781, 6791, 6793, 6803, 6823, 6827, 6829, 6833, 6841, 6857, 6863, 6869, 6871, 6883, 6899, 6907, 6911, 6917, 6947, 6949, 6959, 6961, 6967, 6971, 6977, 6983, 6991, 6997,
    },
    [7] = {
        7001, 7013, 7019, 7027, 7039, 7043, 7057, 7069, 7079, 7103, 7109, 7121, 7127, 7129, 7151, 7159, 7177, 7187, 7193, 7207, 7211, 7213, 7219, 7229, 7237, 7243, 7247, 7253, 7283, 7297, 7307, 7309, 7321, 7331, 7333, 7349, 7351, 7369, 7393, 7411, 7417, 7433, 7451, 7457, 7459, 7477, 7481, 7487, 7489, 7499, 7507, 7517, 7523, 7529, 7537, 7541, 7547, 7549, 7559, 7561, 7573, 7577, 7583, 7589, 7591, 7603, 7607, 7621, 7639, 7643, 7649, 7669, 7673, 7681, 7687, 7691, 7699, 7703, 7717, 7723, 7727, 7741, 7753, 7757, 7759, 7789, 7793, 7817, 7823, 7829, 7841, 7853, 7867, 7873, 7877, 7879, 7883, 7901, 7907, 7919, 7927, 7933, 7937, 7949, 7951, 7963, 7993,
    },
}
Prime_Indices = { outer = 1, inner = 1, }

Rhythms = {}

local _rhythm_pulse =  nil

function Rhythms.increment_count()
    if (_rhythm_pulse and _rhythm_pulse.count) then
        if (_rhythm_pulse.count >= game.tick) then
            _rhythm_pulse.count = math.floor(_rhythm_pulse.count / 2)
        end
        _rhythm_pulse.count = _rhythm_pulse.count + 1
    end
end

function Rhythms.get_count(param)
    if (not _rhythm_pulse or _rhythm_pulse.count == nil) then _rhythm_pulse = storage.rhythm_pulse end

    return
            _rhythm_pulse
        and _rhythm_pulse.count
        and _rhythm_pulse.count
        or  1,
            param
        and Rhythms.increment_count()
        or  nil
end

function Rhythms.init_rhythm(param)
    local __rhythm = {
        current_tick = nil,
        current_tick_count = nil,
        poly_sign = 1,
        poly_index = 2,
        polyrythms = {},
    }

    storage.rhythm = param and __rhythm or storage.rhythm or __rhythm
    Rhythm = __rhythm

    return __rhythm
end

Rhythm = nil

local max_poly_index = 37

function Prime_Random(param1, param2)
    if (type(param2) ~= "number") then param2 = nil end
    local param1_valid = false
    if (type(param1) ~= "number") then
        param1 = 1
        param2 = nil
    else
        if (not param2) then
            if (param1 < 0) then param1 = -1 * param1 end
            if (param1 < 1) then param1 = 1 end
        end
        param1_valid = true
    end
    if (param2 and param2 > param1) then param2 = param1 end
    if (param2 and param1 < param2) then param1 = param2 end

    Rhythm = Rhythm or Rhythms.init_rhythm()

    if (not Rhythm.current_tick) then
        Rhythm.current_tick, Rhythm.current_tick_count = game.tick, 0
    else
        if (Rhythm.current_tick < game.tick) then
            Rhythm.current_tick, Rhythm.current_tick_count = game.tick, 0
        else
            Rhythm.current_tick_count = Rhythm.current_tick_count + 1
        end
    end

    local indices = storage.prime_indices or Prime_Indices
    indices.outer = indices.outer % #Primes + 1
    if (Primes[indices.outer]) then
        indices.inner = indices.inner % #(Primes[indices.outer]) + 1
    else
        indices.inner = 1
    end

    local return_val = (param1 * (game and (game.tick ^ 0.666) ^ 1.5 or 123456789.987654321) * Primes[indices.outer][#Primes[indices.outer]]) / Primes[indices.outer][indices.inner]
    local sign = return_val < 0 and -1 or 1
    return_val = sign * ((math.abs(return_val)) ^ 0.5)

    if (indices.inner > #Primes[indices.outer]) then
        indices.inner = indices.inner + 1
    else
        indices.inner = 1
        indices.outer = indices.outer + 1
    end

    if (param1_valid) then return_val = return_val - return_val % 1 end

    local count = Rhythms.get_count("increment")
    Rhythm.count = count
    Rhythm.polyrythms = {
        [2]  = Rhythm.count % 2 + 1,
        [3]  = Rhythm.count % 3 + 1,
        [5]  = Rhythm.count % 5 + 1,
        [7]  = Rhythm.count % 7 + 1,
        [11] = Rhythm.count % 11 + 1,
        [13] = Rhythm.count % 13 + 1,
        [17] = Rhythm.count % 17 + 1,
        [19] = Rhythm.count % 19 + 1,
        [23] = Rhythm.count % 23 + 1,
        [29] = Rhythm.count % 29 + 1,
        [31] = Rhythm.count % 31 + 1,
        [37] = Rhythm.count % 37 + 1,
    }

    if (not Rhythm.poly_index) then Rhythm.poly_index = 2 end
    Rhythm.poly_index = game and game.tick and (((game.tick + Rhythm.current_tick_count + count) % max_poly_index)) or 2
    local v = nil
    while Rhythm.poly_index and not Rhythm.polyrythms[Rhythm.poly_index] do
        if (Rhythm.poly_index > max_poly_index) then
            Rhythm.poly_index = 2
        elseif (Rhythm.poly_index < 2) then
            Rhythm.poly_index = 2
        end
        Rhythm.poly_index, v = next(Rhythm.polyrythms, Rhythm.poly_index)
    end
    if (not Rhythm.poly_index) then Rhythm.poly_index = 2 end

    local i = Rhythm.poly_index or 2
    if (not v) then v = 2 end

    Rhythm.poly_sign = ((Rhythm.polyrythms[i] / 1) > 0.5 and 1 or -1) or (-1 * Rhythm.poly_sign)

    return return_val % param1
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
local Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
local Data = require("__TheEckelmonster-core-library__.libs.data.data")
local Force_Launch_Data = require("scripts.data.force-launch-data")
local ICBM_Data = require("scripts.data.ICBM-data")
local ICBM_Meta_Data = require("scripts.data.ICBM-meta-data")
local Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
local Rocket_Silo_Meta_Data = require("scripts.data.rocket-silo-meta-data")
local Version_Data = require("scripts.data.version-data")

script.register_metatable("Configurable_Nukes_Data", Configurable_Nukes_Data)
script.register_metatable("Data", Data)
script.register_metatable("Force_Launch_Data", Force_Launch_Data)
script.register_metatable("ICBM_Data", ICBM_Data)
script.register_metatable("ICBM_Meta_Data", ICBM_Meta_Data)
script.register_metatable("Rocket_Silo_Data", Rocket_Silo_Data)
script.register_metatable("Rocket_Silo_Meta_Data", Rocket_Silo_Meta_Data)
script.register_metatable("Version_Data", Version_Data)

---

Loaded = false
Is_Singleplayer = false
Is_Multiplayer = false

require("scripts.events")
require("scripts.commands")

--[[ This event is so that the current game.tick is always available in storage, even if the game object itself is not available
    -> namely for the "on_load" event, as the game object is not available, but storage is available to read from
]]
Event_Handler:register_event({
    event_name = "on_tick",
    source_name = "control.on_tick",
    func_name = "control.on_tick",
    func = function (event)
       if (storage and event and event.tick) then storage.tick = event.tick end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_tick",
    source_name = "control.on_tick",
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