-- If already defined, return
if _string_utils and _string_utils.configurable_nukes then
    return _string_utils
end

local Log = require("libs.log.log")

local space_exploration = script and script.active_mods and script.active_mods["space-exploration"]
local locals = {}

local string_utils = {}

function string_utils.find_invalid_substrings(string)
    Log.debug("string_utils.find_invalid_substrings")
    Log.info(string)

    if (space_exploration and  string:find("spaceship-", 1, true)) then
        Log.error(string)
    end

    return (not locals.is_string_valid(string)
        or string:find("EE_", 1, true)
        or string:find("TEST", 1, true)
        or string:find("test", 1, true)
        )
        or (space_exploration
            and (string:find("starmap-", 1, true)))
end

locals.is_string_valid = function(string)
    Log.debug("string_utils, is_string_valid")
    Log.info(string)

    return string and type(string) == "string" and #string > 0
end

string_utils.configurable_nukes = true

local _string_utils = string_utils

return string_utils