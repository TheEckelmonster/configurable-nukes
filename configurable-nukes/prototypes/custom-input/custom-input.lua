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
}

if (mods and not script) then
    data:extend({
        custom_input.SCRUB_NEWEST_LAUNCH,
        custom_input.SCRUB_OLDEST_LAUNCH,
        custom_input.SCRUB_ALL_LAUNCHES,
    })
end

custom_input.name = "custom_input"

return custom_input