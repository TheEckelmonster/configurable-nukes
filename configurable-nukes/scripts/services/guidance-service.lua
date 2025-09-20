-- If already defined, return
if _guidance_service and _guidance_service.configurable_nukes then
    return _guidance_service
end

local Log = require("libs.log.log")
local Research_Meta_Repository = require("scripts.repositories.research-meta-repository")

local guidance_service = {}

function guidance_service.research_finished(data)
    Log.debug("guidance_service.research_finished")
    Log.info(data)

    if (data == nil or type(data) ~= "table") then return end
    if (not data.research or not data.research.valid or not type(data.research) == "userdata") then return end

    local force = data.research.force
    if (force == nil or type(force) ~= "userdata" or not force.valid) then return end

    Research_Meta_Repository.update_research_meta_data({
        force = force,
        force_index = force.index,
        force_name = force.name,
        research_level = force.level,
    })

end

guidance_service.configurable_nukes = true

local _guidance_service = guidance_service

return guidance_service
