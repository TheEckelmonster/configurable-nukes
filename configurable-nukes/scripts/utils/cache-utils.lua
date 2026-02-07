local Utils = require("__core__.lualib.util")

local cache_utils = {}
cache_utils.name = "cache_utils"

local defaults = {
    name = "cache_utils",
    cache = {},
    cache_attributes = {},
}
setmetatable(defaults.cache_attributes, { __mode = "k", })

function cache_utils.reqister_cache(params)
    local __params = params
    params = params or defaults

    local self = {
        name = params.name or defaults.name,
        cache = params.cache or defaults.cache,
        cache_attributes = params.cache_attributes or defaults.cache_attributes,
    }
    setmetatable(self.cache_attributes, { __mode = "k", })

    function self.reset_cache(params)
        -- for k, v in pairs(self.cache) do
        --     log(serpent.block(self.name .. " -> " .. k))
        --     log(serpent.block(v))
        -- end
        -- for k, v in pairs(self.cache_attributes) do
        --     log(serpent.block(k))
        --     log(serpent.block(v))
        -- end

        self.cache = {}
        self.cache_attributes = {}
        setmetatable(self.cache_attributes, { __mode = "k", })
    end
    function self.get_cache(params)
        if (params and type(params) == "table" and params.raw) then
            return self.cache
        else
            return Utils.table.deepcopy(self.cache)
        end
    end
    function self.get_cache_attributes(params)
        if (params and type(params) == "table" and params.raw) then
            return self.cache_attributes
        else
            return Utils.table.deepcopy(self.cache_attributes)
        end
    end

    return {
        reset_cache = self.reset_cache,
        get_cache = self.get_cache,
        get_cache_attributes = self.get_cache_attributes,
    }
end

return cache_utils