
-- Globals
Log = require("__TheEckelmonster-core-library__.libs.log.log")
Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")
Event_Handler = require("__TheEckelmonster-core-library__.scripts.event-handler")

---

CN_PREFIX = "configurable-nukes-"
CN_PREFIX_ESCAPED = "configurable%-nukes%-"

FUNCTION = "function"
NUMBER = "number"
STRING = "string"
TABLE = "table"

local FUNCTION = FUNCTION
local STRING = STRING

local settings_registry = { registry = {}, }
Settings_Registry = settings_registry
function Settings_Registry:register_setting(params)
    if (not params) then return end
    if (type(params.func_name) ~= STRING) then return end
    if (type(params.func) ~= FUNCTION) then return end

    if (not self or not Settings_Registry) then
        self = self or {}
        Settings_Registry = self
    end
    self.registry = self.registry or {}
    self.registry[#self.registry+1] = { func_name = params.func_name, func = params.func, }
end

---

local script = script
local register_metatable = script.register_metatable

--[[ Data types and metatables ]]

-- circuit-network
Circuit_Network_Payloader_Data = require("scripts.data.circuit-network.payloader-data")
Circuit_Network_Rocket_Silo_Data = require("scripts.data.circuit-network.rocket-silo-data")

register_metatable("Circuit_Network_Payloader_Data", Circuit_Network_Payloader_Data)
register_metatable("Circuit_Network_Rocket_Silo_Data", Circuit_Network_Rocket_Silo_Data)

-- space
--   -> celestial-objects
Anomaly_Data = require("scripts.data.space.celestial-objects.anomaly-data")
Asteroid_Belt_Data = require("scripts.data.space.celestial-objects.asteroid-belt-data")
Asteroid_Field_Data = require("scripts.data.space.celestial-objects.asteroid-field-data")
Moon_Data = require("scripts.data.space.celestial-objects.moon-data")
Orbit_Data = require("scripts.data.space.celestial-objects.orbit-data")
Planet_Data = require("scripts.data.space.celestial-objects.planet-data")
Star_Data = require("scripts.data.space.celestial-objects.star-data")

register_metatable("Anomaly_Data", Anomaly_Data)
register_metatable("Asteroid_Belt_Data", Asteroid_Belt_Data)
register_metatable("Asteroid_Field_Data", Asteroid_Field_Data)
register_metatable("Moon_Data", Moon_Data)
register_metatable("Orbit_Data", Orbit_Data)
register_metatable("Planet_Data", Planet_Data)
register_metatable("Star_Data", Star_Data)

-- space
Space_Connection_Data = require("scripts.data.space.space-connection-data")
Space_Location_Data = require("scripts.data.space.space-location-data")
Spaceship_Data = require("scripts.data.space.spaceship-data")

register_metatable("Space_Connection_Data", Space_Connection_Data)
register_metatable("Space_Location_Data", Space_Location_Data)
register_metatable("Spaceship_Data", Spaceship_Data)

-- structures
Queue_Data = require("__TheEckelmonster-core-library__.libs.data.structures.queue-data")

script.register_metatable("Queue_Data", Queue_Data)

-- versions
Bug_Fix_Data = require("__TheEckelmonster-core-library__.libs.data.versions.bug-fix-data")
Major_Data = require("__TheEckelmonster-core-library__.libs.data.versions.major-data")
Minor_Data = require("__TheEckelmonster-core-library__.libs.data.versions.minor-data")

register_metatable("Bug_Fix_Data", Bug_Fix_Data)
register_metatable("Major_Data", Major_Data)
register_metatable("Minor_Data", Minor_Data)

-- unsorted
Configurable_Nukes_Data = require("scripts.data.configurable-nukes-data")
Data = require("__TheEckelmonster-core-library__.libs.data.data")
Force_Launch_Data = require("scripts.data.force-launch-data")
ICBM_Data = require("scripts.data.ICBM-data")
ICBM_Meta_Data = require("scripts.data.ICBM-meta-data")
-- local Rhythm = require("scripts.rhythm")
Rocket_Silo_Data = require("scripts.data.rocket-silo-data")
Rocket_Silo_Meta_Data = require("scripts.data.rocket-silo-meta-data")
Version_Data = require("scripts.data.version-data")

register_metatable("Configurable_Nukes_Data", Configurable_Nukes_Data)
register_metatable("Data", Data)
register_metatable("Force_Launch_Data", Force_Launch_Data)
register_metatable("ICBM_Data", ICBM_Data)
register_metatable("ICBM_Meta_Data", ICBM_Meta_Data)
-- script.register_metatable("Rhythm", Rhythm)
register_metatable("Rocket_Silo_Data", Rocket_Silo_Data)
register_metatable("Rocket_Silo_Meta_Data", Rocket_Silo_Meta_Data)
register_metatable("Version_Data", Version_Data)

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
    event_name = "on_nth_tick",
    nth_tick = 20,
    source_name = "control.on_nth_tick",
    func_name = "control.on_nth_tick",
    func = function (event)
       if (storage and event and event.tick) then
        storage.tick = event.tick
        if (event.tick % 500 == 0) then storage.cache = nil end
       end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_nth_tick",
    nth_tick = 20,
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


local get_runtime_global_setting = Data_Utils.get_runtime_global_setting
local get_startup_setting = Data_Utils.get_startup_setting

local ipairs = ipairs
local type = type

local string = string
local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local string_upper = string.upper
local CN_PREFIX_ESCAPED = CN_PREFIX_ESCAPED
local DOT_STAR = "(.*)"
local DASH_ESCAPED = "%-"
local UNDERSCORE = "_"
Event_Handler:register_event({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "settings_map.on_runtime_mod_setting_changed",
    func_name = "settings_map.on_runtime_mod_setting_changed",
    func = function (event)
        if (not event or not event.setting or not string_find(event.setting, CN_PREFIX_ESCAPED)) then return end
        local trimmed = string_match(event.setting, CN_PREFIX_ESCAPED .. DOT_STAR)
        local subbed_to_upper = string_upper(string_gsub(trimmed, DASH_ESCAPED, UNDERSCORE))

        storage.settings_map = storage.settings_map or {}
        storage.settings_map.runtime_global = storage.settings_map.runtime_global or {}
        storage.settings_map.startup = storage.settings_map.startup or {}

        local setting_value = nil
        local setting = nil
        local planet = nil
        if (Runtime_Global_Settings_Constants.settings[subbed_to_upper]) then
            planet = Runtime_Global_Settings_Constants.settings[subbed_to_upper].planet
            storage.settings_map.runtime_global[event.setting] = get_runtime_global_setting({ setting = event.setting, reindex = true, })
            setting_value = storage.settings_map.runtime_global[event.setting]
            setting = Runtime_Global_Settings_Constants.settings[subbed_to_upper]
        elseif (Startup_Settings_Constants.settings[subbed_to_upper]) then
            planet = Startup_Settings_Constants.settings[subbed_to_upper].planet
            storage.settings_map.startup[event.setting] = get_startup_setting({ setting = event.setting, reindex = true, })
            setting_value = storage.settings_map.startup[event.setting]
            setting = Startup_Settings_Constants.settings[subbed_to_upper]
        end

        for _, registered in ipairs(Settings_Registry.registry or {}) do
            if (registered.func and type(registered.func) == FUNCTION) then registered.func(event, { setting_constant = setting, setting_value = setting_value, surface_name = planet, }) end
        end
    end,
})

Event_Handler:set_event_position({
    event_name = "on_runtime_mod_setting_changed",
    source_name = "settings_map.on_runtime_mod_setting_changed",
    new_position = 1,
})