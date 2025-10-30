local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not _Log) then _Log = Log_Stub end

local Version_Data = require("scripts.data.version-data")
local Version_Repository = require("scripts.repositories.version-repository")

local version_service = {}

function version_service.validate_version(optionals)
    Log.debug("version_service.validate_version")
    Log.info(optionals)

    local return_val = {
        valid = false,
        major = {
            valid = false,
            value = 0
        },
        minor = {
            valid = false,
            value = 0
        },
        bug_fix = {
            valid = false,
            value = 0
        }
    }

    local version_data = Version_Repository.get_version_data()
    if (not version_data.valid) then return return_val end

    -- Check the version numbers; initialize if necessary
    if (not version_data.major) then
        version_data.major = { valid = false, value = 0 }
    else
        return_val.major.value = version_data.major.value
    end
    if (not version_data.minor) then
        version_data.minor = { valid = false, value = 0 }
    else
        return_val.minor.value = version_data.minor.value
    end
    if (not version_data.bug_fix) then
        version_data.bug_fix = { valid = false, value = 0 }
    else
        return_val.bug_fix.value = version_data.bug_fix.value
    end

    local current_version = Version_Data:new()

    -- Compare the version numbers
    if (current_version.major.value <= version_data.major.value) then return_val.major.valid = true end
    if (current_version.minor.value <= version_data.minor.value) then return_val.minor.valid = true end
    if (current_version.bug_fix.value <= version_data.bug_fix.value) then return_val.bug_fix.valid = true end

    -- Check if they're all valid
    if (return_val.major.valid and return_val.minor.valid and return_val.bug_fix.valid) then
        return_val.valid = true
    end

    return return_val
end

return version_service