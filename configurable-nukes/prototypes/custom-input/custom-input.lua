local custom_input =
{
    SCRUB_NEWEST_LAUNCH = {
        type = "custom-input",
        name = "configurable-nukes-scrub-newest-launch",
        key_sequence = "CONTROL + SHIFT + Z",
        consuming = "none",
        localised_name = { "custom-input.scrub-newest-launch", },
        action = "lua",
    },
    SCRUB_OLDEST_LAUNCH = {
        type = "custom-input",
        name = "configurable-nukes-scrub-oldest-launch",
        key_sequence = "CONTROL + ALT + Z",
        consuming = "none",
        localised_name = { "custom-input.scrub-oldest-launch", },
        action = "lua",
    },
    SCRUB_ALL_LAUNCHES = {
        type = "custom-input",
        name = "configurable-nukes-scrub-all-launches",
        key_sequence = "CONTROL + SHIFT + ALT + Z",
        consuming = "none",
        localised_name = { "custom-input.scrub-all-launches", },
        action = "lua",
    },
    TOGGLE_DASHBOARD = {
        type = "custom-input",
        name = "configurable-nukes-toggle-dashboard",
        key_sequence = "CONTROL + SHIFT + D",
        consuming = "none",
        localised_name = { "custom-input.toggle-dashboard", },
        action = "lua",
    },
    CREATE_ICBM_REMOTE = {
        type = "custom-input",
        name = "configurable-nukes-create-icbm-remote",
        key_sequence = "SHIFT + ALT + T",
        consuming = "none",
        localised_name = { "custom-input.create-icbm-remote", },
        action = "spawn-item",
        item_to_spawn = "ICBM-remote",
    },
    TARGET_COMBINATOR_SELECT_TARGET = {
        type = "custom-input",
        name = "configurable-nukes-target-combinator-select-target",
        key_sequence = "CONTROL + SHIFT + mouse-button-2",
        consuming = "none",
        include_selected_prototype = true,
        localised_name = { "custom-input.target-combinator-select-target", },
        action = "lua",
    },
    TOGGLE_MAP = {
        type = "custom-input",
        name = "configurable-nukes-toggle-map",
        key_sequence = "",
        linked_game_control = "toggle-map",
        consuming = "none",
        include_selected_prototype = true,
        -- localised_name = { "custom-input.target-combinator-select-target", },
        action = "lua",
    },
    CONFIRM_GUI = {
        type = "custom-input",
        name = "configurable-nukes-confirm-gui",
        key_sequence = "",
        linked_game_control = "confirm-gui",
        consuming = "none",
        include_selected_prototype = true,
        -- localised_name = { "custom-input.target-combinator-select-target", },
        action = "lua",
    },
}

if (mods and not script) then
    data:extend({
        custom_input.SCRUB_NEWEST_LAUNCH,
        custom_input.SCRUB_OLDEST_LAUNCH,
        custom_input.SCRUB_ALL_LAUNCHES,
        custom_input.TOGGLE_DASHBOARD,
        custom_input.CREATE_ICBM_REMOTE,
        custom_input.TARGET_COMBINATOR_SELECT_TARGET,
        custom_input.TOGGLE_MAP,
        custom_input.CONFIRM_GUI,
    })
end

custom_input.name = "custom_input"

return custom_input