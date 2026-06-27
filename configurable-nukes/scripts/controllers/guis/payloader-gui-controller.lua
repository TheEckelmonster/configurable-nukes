local storage
local cache
local icbms_researched
local ordered_rocket_silos
local ready_rocket_silos
local recently_launched_rkt_silos
local rocket_silos
local rocket_silo_status_timeout
local surfaces
local payloader

local game
local get_player

local function set_game(event, __game, __storage)
    storage = __storage or _ENV.storage

    storage.cache = storage.cache
    cache = storage.cache

    storage.icbms_researched = storage.icbms_researched or {}
    icbms_researched = storage.icbms_researched

    storage.ordered_rocket_silos = storage.ordered_rocket_silos
    ordered_rocket_silos = storage.ordered_rocket_silos

    storage.ready_rocket_silos = storage.ready_rocket_silos or {}
    ready_rocket_silos = storage.ready_rocket_silos

    storage.recently_launched_rkt_silos = storage.recently_launched_rkt_silos or {}
    recently_launched_rkt_silos = storage.recently_launched_rkt_silos

    storage.rocket_silos = storage.rocket_silos or {}
    rocket_silos = storage.rocket_silos

    storage.rocket_silo_status_timeout = storage.rocket_silo_status_timeout or {}
    rocket_silo_status_timeout = storage.rocket_silo_status_timeout

    storage.payloader = storage.payloader
    payloader = storage.payloader

    surfaces = storage.surfaces or {}
    surfaces = storage.surfaces

    --[[ game ]]
    game = __game or _ENV.game

    get_player = game.get_player

    return game
end

local next = next
local string = string
local tonumber = tonumber
local type = type

local defines = defines
local script = script

local gui_type_entity = defines.gui_type.entity

local Event_Handler = Event_Handler
local Log = Log
local Payloader_Data = Circuit_Network_Payloader_Data

-- local Payloader_Data = require("scripts.data.circuit-network.payloader-data")
local Payloader_Gui_Service = require("scripts.services.guis.payloader-gui-service")
local create_payloader_gui = Payloader_Gui_Service.create_payloader_gui

local buttons = {
    ["cn_payloader_button_signal_select_launch"] = "launch",
    ["cn_payloader_button_signal_select_x"] = "x",
    ["cn_payloader_button_signal_select_y"] = "y",
    ["cn_payloader_button_signal_select_z"] = "space_location_index",
}

local payloader_gui_controller = {}
payloader_gui_controller.name = "payloader_gui_controller"
payloader_gui_controller.set_game = set_game

local MIRVS = "cn-mirvs"
local PAYLOADER = "payloader"
function payloader_gui_controller.on_gui_opened(event)
    -- Log.debug("payloader_gui_controller.on_gui_opened")
    -- Log.info(event)

    if (not event) then return end
    if (not event.gui_type or event.gui_type ~= gui_type_entity) then return end
    local entity = event.entity
    if (not entity or not entity.valid or entity.name ~= PAYLOADER) then return end

    local surface = entity.surface
    if (not surface or not surface.valid) then return end

    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = (game and get_player or set_game()) and get_player(event.player_index)
    if (not player or not player.valid) then return end

    local force = player.force and player.force.valid and player.force or nil
    if (not force or not force.valid) then return end

    local technologies = force and force.technologies or nil
    if (not technologies or not technologies.valid) then return end
    if (not technologies[MIRVS] or not technologies[MIRVS].valid or not technologies[MIRVS].researched) then return end

    if (not player.gui.relative.cn_frame_outer_circuit_launchable) then
        create_payloader_gui({
            unit_number = entity.unit_number,
            surface_index = surface.index,
            surface_name = surface.name,
            player = player,
        })
    end
end
Event_Handler:register_event({
    event_name = "on_gui_opened",
    source_name = "payloader_gui_controller.on_gui_opened",
    func_name = "payloader_gui_controller.on_gui_opened",
    func = payloader_gui_controller.on_gui_opened,
})

function payloader_gui_controller.on_gui_closed(event)
    -- Log.debug("payloader_gui_controller.on_gui_closed")
    -- Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.gui_type or event.gui_type ~= gui_type_entity) then return end
    local entity = event.entity
    if (not entity or not entity.valid or entity.name ~= "payloader") then return end

    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = (game and get_player or set_game()) and get_player(event.player_index)
    if (player and player.valid) then
        local gui = player.gui.relative.cn_payloader_frame_outer
        if (gui) then gui.destroy() end
    end
end
Event_Handler:register_event({
    event_name = "on_gui_closed",
    source_name = "payloader_gui_controller.on_gui_closed",
    func_name = "payloader_gui_controller.on_gui_closed",
    func = payloader_gui_controller.on_gui_closed,
})

local TARGET_COMBINATOR_PROGRAM = "target-combinator-program"
local PAYLOADER_BUTTON_SIGNAL_SELECT = "cn_payloader_button_signal_select"
function payloader_gui_controller.on_gui_elem_changed(event)
    -- Log.debug("payloader_gui_controller.on_gui_elem_changed")
    -- Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not event.player_index or type(event.player_index) ~= "number" or event.player_index < 1) then return end

    local player = (game and get_player or set_game()) and get_player(event.player_index)
    local entity = player.opened
    if (not entity or not entity.valid) then return end
    if (entity.name ~= PAYLOADER) then return end

    local recipe = entity.get_recipe()
    if (not recipe or not recipe.valid) then return end
    if (not recipe.name == TARGET_COMBINATOR_PROGRAM) then return end

    local surface = entity.surface
    if (not surface or not surface.valid) then return end

    if (string.find(event.element.name, PAYLOADER_BUTTON_SIGNAL_SELECT, 1, true)) then
        payloader = (payloaders or set_game() and payloaders) and payloaders[entity.unit_number or ""]
        if (not payloader or not payloader.entity or not payloader.entity.valid) then return end
        local circuit_network_data = payloader.circuit_network_data or Payloader_Data:new({
            unit_number = entity.unit_number,
            surface_index = surface.index,
            surface_name = surface.name,
        })

        if (buttons[event.element.name]) then circuit_network_data.signals[buttons[event.element.name]] = event.element.elem_value end
    end
end
Event_Handler:register_event({
    event_name = "on_gui_elem_changed",
    source_name = "payloader_gui_controller.on_gui_elem_changed",
    func_name = "payloader_gui_controller.on_gui_elem_changed",
    func = payloader_gui_controller.on_gui_elem_changed,
})

function payloader_gui_controller.on_gui_text_changed(event)
    -- Log.debug("payloader_gui_controller.on_gui_text_changed")
    -- Log.info(event)

    if (not event or not type(event) == "table") then return end
    if (not string.find(event.element.name, "cn_payloader_flow_row_text_box_", 1, true)) then return end
    if (event.player_index < 1) then return end

    local player = game.get_player(event.player_index)
    if (not player or not player.valid) then return end

    local entity = player.opened
    if (not entity or not entity.valid) then return end
    if (entity.name ~= "payloader") then return end

    local recipe = entity.get_recipe()
    if (not recipe or not recipe.valid) then return end
    if (not recipe.name == "target-combinator-program") then return end

    local surface = entity.surface
    if (not surface or not surface.valid) then return end

    payloader = (payloaders or set_game() and payloaders) and payloaders[entity.unit_number or ""]
    if (not payloader or not payloader.entity or not payloader.entity.valid) then return end
    local circuit_network_data = payloader.circuit_network_data or Payloader_Data:new({
        unit_number = payloader.entity.unit_number,
        surface_index = surface.index,
        surface_name = surface.name,
    })
    circuit_network_data.manual_entry = circuit_network_data.manual_entry or {
        launch = 0,
        x = 0,
        y = 0,
        space_location_index = surface.index,
    }

    local manual_entry = circuit_network_data.manual_entry
    if (event.element.name:find("x$")) then
        manual_entry.x = tonumber(event.text)
    elseif (event.element.name:find("y$")) then
        manual_entry.y = tonumber(event.text)
    elseif (event.element.name:find("z$")) then
        manual_entry.space_location_index = tonumber(event.text)
    end
end
Event_Handler:register_event({
    event_name = "on_gui_text_changed",
    source_name = "payloader_gui_controller.on_gui_text_changed",
    func_name = "payloader_gui_controller.on_gui_text_changed",
    func = payloader_gui_controller.on_gui_text_changed,
})

function payloader_gui_controller.on_entity_settings_pasted(event)
    Log.debug("payloader_gui_controller.on_entity_settings_pasted")
    Log.info(event)

    if (not event) then return end
    if (not event.player_index or type(event.player_index)  ~= "number" or event.player_index < 1) then return end
    if (not event.source or not event.source.valid) then return end
    if (not event.destination or not event.destination.valid) then return end

    local entity_source = event.source
    local entity_destination = event.destination

    if (entity_source.name ~= "payloader" or entity_destination.name ~= "payloader") then return end

    payloaders = payloaders or set_game() and payloaders
    if (not payloaders[entity_source.unit_number] or not payloaders[entity_destination.unit_number]) then return end
    local payloader_src, payloader_dest = payloaders[entity_source.unit_number], payloaders[entity_destination.unit_number]

    local manual_entry_src = payloader_src.circuit_network_data.manual_entry
    local manual_entry_dest = payloader_dest.circuit_network_data.manual_entry

    manual_entry_dest.launch = manual_entry_src.launch
    manual_entry_dest.x = manual_entry_src.x
    manual_entry_dest.y = manual_entry_src.y
    manual_entry_dest.space_location_index = manual_entry_src.space_location_index
end
Event_Handler:register_event({
    event_name = "on_entity_settings_pasted",
    source_name = "payloader_gui_controller.on_entity_settings_pasted",
    func_name = "payloader_gui_controller.on_entity_settings_pasted",
    func = payloader_gui_controller.on_entity_settings_pasted,
})

function payloader_gui_controller.init(__storage)
    storage = __storage
end

return payloader_gui_controller