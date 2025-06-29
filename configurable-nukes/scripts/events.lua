local Log = require("libs.log.log")

-- POLLUTION
local get_pollution = function ()
  local setting = 0

  if (settings and settings.global and settings.global["configurable-nukes-pollution"]) then
    setting = settings.global["configurable-nukes-pollution"].value
  end

  return setting
end

script.on_event(defines.events.on_script_trigger_effect, function (event)
  Log.debug("script.on_event(defines.events.on_script_trigger_effect,...)")
  Log.info(event)
  if (  event
    and event.effect_id
    and
      (not event.effect_id == "atomic-bomb-pollution")) then return end
  if (not game or not event.surface_index or game.surfaces[event.surface_index] == nil) then return end

  local position = event.source_position or event.target_position
  local surface = game.surfaces[event.surface_index]

  if (position and event.effect_id == "atomic-bomb-pollution") then
    Log.debug("detonation; polluting")
    -- surface.pollute(position, 10, "atomic-rocket")
    surface.pollute(position, get_pollution(), "atomic-rocket")
  end
end)