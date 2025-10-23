-- If already defined, return
if _gui_utils and _gui_utils.configurable_nukes then
  return _gui_utils
end

local Log = require("libs.log.log")

local gui_utils = {}

function gui_utils.add_dropdown(data)
    Log.debug("gui_utils.add_dropdown")
    Log.info(data)

    if (not data or type(data) ~= "table") then return _, -1 end
    if (not data.gui or not data.gui.valid) then return _, -1 end
    if (not data.name or type(data.name) ~= "string") then return _, -1 end
    if (not data.items or type(data.items) ~= "table") then return _, -1 end

    if (not data.selected_index or type(data.selected_index) ~= "number") then data.selected_index = 1 end
    if (data.selected_index > #data.items) then data.selected_index = data.default_index or 0 end

    return data.gui.add({
        type = "drop-down",
        name = data.name,
        selected_index = data.selected_index,
        items = data.items
    }), 1
end

function gui_utils.get_platform_name_from_surface(data)
    Log.debug("gui_utils.get_platform_name_from_surface")
    Log.info(data)

    if (not data or type(data) ~= "table") then return end
    if (not data.icbm_data or type(data.icbm_data) ~= "table") then return end

    local platform_name = data.icbm_data.surface and data.icbm_data.surface.valid and data.icbm_data.surface.name or data.icbm_data.surface_name or "?"

    if (platform_name and platform_name:find("platform-", 1, true) == 1) then
        local surface = game.get_surface(platform_name)
        if (surface and surface.valid) then
            if (surface.platform and surface.platform.valid) then
                platform_name = surface.platform.name
            end
        end
    end

    return platform_name
end

gui_utils.configurable_nukes = true

local _gui_utils = gui_utils

return gui_utils