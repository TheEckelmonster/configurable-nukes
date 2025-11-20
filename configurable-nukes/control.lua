
-- Globals
Log = require("__TheEckelmonster-core-library__.libs.log.log")
Event_Handler = require("__TheEckelmonster-core-library__.scripts.event-handler")

Cache = {}
Cache_Attributes = {}
setmetatable(Cache_Attributes, { __mode = 'k' })

Random = nil

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