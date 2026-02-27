local Data = require("scripts.data.data")

local Primes = {
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

local max_poly_index = 541

local rhythm = {}

rhythm.name = "rhythm"
rhythm.type = "rhythm"

function rhythm.new(self, o)

    local defaults = {
        type = rhythm.type,
        poly_index = 2,
        poly_sign = 1,
        prime_indices = { outer = 1, inner = 1, }
    }

    local prime_indices = nil

    local Rhythm = nil

    local obj = o or defaults

    self.name = obj.name or rhythm.name

    for k, v in pairs(defaults) do if (obj[k] == nil and type(v) ~= "function") then obj[k] = v end end

    obj = Data:new(obj)

    function rhythm.init_rhythm(self, param, ...)
        local __rhythm = {
            name = self.name,
            current_tick = game and game.tick or 1,
            current_tick_count = 0,
            rhythm_pulse = { count = 1, },
            poly_sign = 1,
            poly_index = 2,
            polyrythms = {},
            prime_indices = { outer = 1, inner = {}, }
        }

        storage.rhythm = storage.rhythm or {}
        storage.rhythm[self.name] = param and __rhythm or storage.rhythm[self.name] or __rhythm

        return storage.rhythm[self.name]
    end

    function rhythm.increment_count(self, param)

        Rhythm = Rhythm or rhythm.init_rhythm(self)

        if (Rhythm.rhythm_pulse and Rhythm.rhythm_pulse.count) then
            if (Rhythm.rhythm_pulse.count >= game.tick) then
                Rhythm.rhythm_pulse.count = math.floor(Rhythm.rhythm_pulse.count / 2)
            end
            Rhythm.rhythm_pulse.count = Rhythm.rhythm_pulse.count + 1
        end
    end

    function rhythm.get_count(self, param)

        Rhythm = Rhythm or rhythm.init_rhythm(self)

        if (not Rhythm.rhythm_pulse or Rhythm.rhythm_pulse.count == nil) then Rhythm.rhythm_pulse = storage.rhythm_pulse end

        return
                Rhythm.rhythm_pulse
            and Rhythm.rhythm_pulse.count
            and Rhythm.rhythm_pulse.count
            or  1,
                param
            and rhythm.increment_count(self)
            or  nil
    end

    function rhythm.prime_random(self, param1, param2)

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

        param1 = param1 - (param1 % 1)
        if (param2 ~= nil) then param1 = param1 - (param1 % 1) end

        Rhythm = Rhythm or rhythm.init_rhythm(self)

        if (not Rhythm.current_tick) then
            Rhythm.current_tick, Rhythm.current_tick_count = game.tick, 0
        else
            if (Rhythm.current_tick < game.tick) then
                Rhythm.current_tick, Rhythm.current_tick_count = game.tick, 0
            else
                Rhythm.current_tick_count = Rhythm.current_tick_count + 1
            end
        end

        storage.prime_indices = storage.prime_indices or {}
        storage.prime_indices[self.name] = storage.prime_indices[self.name] or { outer = 1, inner = 1, }
        prime_indices = Rhythm.prime_indices or storage.prime_indices[self.name]

        prime_indices.outer = prime_indices.outer % #Primes + 1
        if (Primes[prime_indices.outer]) then
            prime_indices.inner[prime_indices.outer] = prime_indices.inner[prime_indices.outer] or 1
            prime_indices.inner[prime_indices.outer] = prime_indices.inner[prime_indices.outer] % #(Primes[prime_indices.outer]) + 1
        else
            prime_indices.inner[prime_indices.outer] = 1
        end

        local prime = Primes[prime_indices.outer][prime_indices.inner[prime_indices.outer]]

        local count = rhythm.get_count(self, "increment")
        Rhythm.count = count

        local exponent = ((game.tick + count) ^ 0.5) ^ 1.5
        local return_val = ((game.tick + count + param1) * exponent * Primes[prime_indices.outer][#Primes[prime_indices.outer]]) / prime

        local sign = return_val < 0 and -1 or 1

        return_val = sign * ((math.abs(return_val)) ^ 0.5)

        if (param1_valid) then return_val = return_val - return_val % 1 end

        Rhythm.polyrythms = {
            [2]  = (prime + Rhythm.count) % 2 + 1,
            [3]  = (prime + Rhythm.count) % 3 + 1,
            [5]  = (prime + Rhythm.count) % 5 + 1,
            [7]  = (prime + Rhythm.count) % 7 + 1,
            [11] = (prime + Rhythm.count) % 11 + 1,
            [13] = (prime + Rhythm.count) % 13 + 1,
            [17] = (prime + Rhythm.count) % 17 + 1,
            [19] = (prime + Rhythm.count) % 19 + 1,
            [23] = (prime + Rhythm.count) % 23 + 1,
            [29] = (prime + Rhythm.count) % 29 + 1,
            [31] = (prime + Rhythm.count) % 31 + 1,
            [37] = (prime + Rhythm.count) % 37 + 1,
            [41] = (prime + Rhythm.count) % 41 + 1,
            [43] = (prime + Rhythm.count) % 43 + 1,
            [47] = (prime + Rhythm.count) % 47 + 1,
            [53] = (prime + Rhythm.count) % 53 + 1,
            [59] = (prime + Rhythm.count) % 59 + 1,
            [61] = (prime + Rhythm.count) % 61 + 1,
            [67] = (prime + Rhythm.count) % 67 + 1,
            [71] = (prime + Rhythm.count) % 71 + 1,
            [73] = (prime + Rhythm.count) % 73 + 1,
            [79] = (prime + Rhythm.count) % 79 + 1,
            [83] = (prime + Rhythm.count) % 83 + 1,
            [89] = (prime + Rhythm.count) % 89 + 1,
            [97] = (prime + Rhythm.count) % 97 + 1,
            [101] = (prime + Rhythm.count) % 101 + 1,
            [103] = (prime + Rhythm.count) % 103 + 1,
            [107] = (prime + Rhythm.count) % 107 + 1,
            [109] = (prime + Rhythm.count) % 109 + 1,
            [113] = (prime + Rhythm.count) % 113 + 1,
            [127] = (prime + Rhythm.count) % 127 + 1,
            [131] = (prime + Rhythm.count) % 131 + 1,
            [137] = (prime + Rhythm.count) % 137 + 1,
            [139] = (prime + Rhythm.count) % 139 + 1,
            [149] = (prime + Rhythm.count) % 149 + 1,
            [151] = (prime + Rhythm.count) % 151 + 1,
            [157] = (prime + Rhythm.count) % 157 + 1,
            [163] = (prime + Rhythm.count) % 163 + 1,
            [167] = (prime + Rhythm.count) % 167 + 1,
            [173] = (prime + Rhythm.count) % 173 + 1,
            [179] = (prime + Rhythm.count) % 179 + 1,
            [181] = (prime + Rhythm.count) % 181 + 1,
            [191] = (prime + Rhythm.count) % 191 + 1,
            [193] = (prime + Rhythm.count) % 193 + 1,
            [197] = (prime + Rhythm.count) % 197 + 1,
            [199] = (prime + Rhythm.count) % 199 + 1,
            [211] = (prime + Rhythm.count) % 211 + 1,
            [223] = (prime + Rhythm.count) % 223 + 1,
            [227] = (prime + Rhythm.count) % 227 + 1,
            [229] = (prime + Rhythm.count) % 229 + 1,
            [233] = (prime + Rhythm.count) % 233 + 1,
            [239] = (prime + Rhythm.count) % 239 + 1,
            [241] = (prime + Rhythm.count) % 241 + 1,
            [251] = (prime + Rhythm.count) % 251 + 1,
            [257] = (prime + Rhythm.count) % 257 + 1,
            [263] = (prime + Rhythm.count) % 263 + 1,
            [269] = (prime + Rhythm.count) % 269 + 1,
            [271] = (prime + Rhythm.count) % 271 + 1,
            [277] = (prime + Rhythm.count) % 277 + 1,
            [281] = (prime + Rhythm.count) % 281 + 1,
            [283] = (prime + Rhythm.count) % 283 + 1,
            [293] = (prime + Rhythm.count) % 293 + 1,
            [307] = (prime + Rhythm.count) % 307 + 1,
            [311] = (prime + Rhythm.count) % 311 + 1,
            [313] = (prime + Rhythm.count) % 313 + 1,
            [317] = (prime + Rhythm.count) % 317 + 1,
            [331] = (prime + Rhythm.count) % 331 + 1,
            [337] = (prime + Rhythm.count) % 337 + 1,
            [347] = (prime + Rhythm.count) % 347 + 1,
            [349] = (prime + Rhythm.count) % 349 + 1,
            [353] = (prime + Rhythm.count) % 353 + 1,
            [359] = (prime + Rhythm.count) % 359 + 1,
            [367] = (prime + Rhythm.count) % 367 + 1,
            [373] = (prime + Rhythm.count) % 373 + 1,
            [379] = (prime + Rhythm.count) % 379 + 1,
            [383] = (prime + Rhythm.count) % 383 + 1,
            [389] = (prime + Rhythm.count) % 389 + 1,
            [397] = (prime + Rhythm.count) % 397 + 1,
            [401] = (prime + Rhythm.count) % 401 + 1,
            [409] = (prime + Rhythm.count) % 409 + 1,
            [419] = (prime + Rhythm.count) % 419 + 1,
            [421] = (prime + Rhythm.count) % 421 + 1,
            [431] = (prime + Rhythm.count) % 431 + 1,
            [433] = (prime + Rhythm.count) % 433 + 1,
            [439] = (prime + Rhythm.count) % 439 + 1,
            [443] = (prime + Rhythm.count) % 443 + 1,
            [449] = (prime + Rhythm.count) % 449 + 1,
            [457] = (prime + Rhythm.count) % 457 + 1,
            [461] = (prime + Rhythm.count) % 461 + 1,
            [463] = (prime + Rhythm.count) % 463 + 1,
            [467] = (prime + Rhythm.count) % 467 + 1,
            [479] = (prime + Rhythm.count) % 479 + 1,
            [487] = (prime + Rhythm.count) % 487 + 1,
            [491] = (prime + Rhythm.count) % 491 + 1,
            [499] = (prime + Rhythm.count) % 499 + 1,
            [503] = (prime + Rhythm.count) % 503 + 1,
            [509] = (prime + Rhythm.count) % 509 + 1,
            [521] = (prime + Rhythm.count) % 521 + 1,
            [523] = (prime + Rhythm.count) % 523 + 1,
            [541] = (prime + Rhythm.count) % 541 + 1,
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

        Rhythm.poly_sign = ((Rhythm.polyrythms[i] / i) > 0.5 and 1 or -1) or (-1 * Rhythm.poly_sign)

        return return_val % param1
    end

    obj.__self = Rhythm

    setmetatable(obj, rhythm)
    rhythm.__index = rhythm

    return obj
end

setmetatable(rhythm, Data)
rhythm.__index = rhythm

return rhythm