local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local se_active = script and script.active_mods and script.active_mods["space-exploration"]
local locals = {}

local string_utils = {}

function string_utils.find_invalid_substrings(string_data)
    Log.debug("string_utils.find_invalid_substrings")
    Log.info(string_data)

    return
        (not locals.is_string_valid(string_data))
        or
        (      string_data:find("EE_", 1, true)
            or string_data:find("TEST", 1, true)
            or string_data:find("test", 1, true)
            or string_data:find("aai-signals", 1, true)
        )
        or
        (       se_active
            and (string_data:find("starmap-", 1, true))
        )
end

function string_utils.format_surface_name(data)
    -- Log.debug("string_utils.format_surface_name")
    -- Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.string_data or type(data.string_data) ~= "string") then return end

    local pattern = "([_%.%g%-]+%s*)(.*)"
    local _, _, token, remaining_string = data.string_data:find(pattern)

    local formatted_string = ""
    local num_loops = 0
    while token do
        if (num_loops > 2 ^ 5) then Log.error("string_utils.format_surface_name looped too many times: num_loops = " .. num_loops); break end

        local initial_character, remainder = token:sub(1, 1), token:sub(2)
        if (initial_character == initial_character:lower()) then
            formatted_string = formatted_string .. initial_character:upper() .. remainder
        else
            formatted_string = formatted_string .. initial_character .. remainder
        end

        if (remaining_string) then
            _, _, token, remaining_string = remaining_string:find(pattern)
        else
            token = nil
        end
        num_loops = num_loops + 1
    end

    if (formatted_string:gsub("%s+", "") == "") then
        formatted_string = data.string_data
    end

    return formatted_string, data.string_data
end

locals.is_string_valid = function(string_data)
    Log.debug("string_utils, is_string_valid")
    Log.info(string_data)

    return string_data and type(string_data) == "string" and string_data:gsub("%s+", "") ~= ""
end

return string_utils