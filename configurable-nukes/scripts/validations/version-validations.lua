-- If already defined, return
if (_version_validations and _version_validations.configurable_nukes) then
    return _version_validations
end

local Constants = require("scripts.constants.constants")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")
local Version_Data = require("scripts.data.version-data")
local Version_Service = require("scripts.services.version-service")
local Version_Repository = require("scripts.repositories.version-repository")

local version_validations = {}

function version_validations.validate_version()
    local return_val = true

    local version = Version_Service.validate_version()
    local validate_fun = function()
        Log.warn(Constants.mod_name .. ": Invalid version detected relative to version " .. Version_Data.string_val .. "; reinitializing naively")
        Initialization.reinit()
        local return_val = true
        if (not Version_Service.validate_version().valid) then
            local version_data = Version_Repository.get_version_data()
            return_val = false
            Log.error(Constants.mod_name .. ": invalid version detected relative to version " .. Version_Data.string_val .. "; naive reinitialization failed")
            if (version_data.string_val) then
                game.print({ "version-validations.invalid-version-message-1a", Constants.mod_name, Version_Data.string_val, version_data.string_val })
            else
                game.print({ "version-validations.invalid-version-message-1b", Constants.mod_name, Version_Data.string_val })
            end
            game.print({ "version-validations.invalid-version-message-2", Constants.mod_name })
        end
        return return_val
    end -- local validate_fun = function ()

    if (not version.valid) then
        return_val = validate_fun()
    end

    return return_val
end

version_validations.configurable_nukes = true

local _version_validations = version_validations
return version_validations
