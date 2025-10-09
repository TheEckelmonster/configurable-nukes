local custom_input = {}

custom_input.LAUNCH_IPBM = {
    type = "custom-input",
    name = "configurable-nukes-launch-ipbm",
    key_sequence = "SHIFT + LEFT-CLCK",
    consuming = "none",
    localised_name = "Launch IPBMs",
    action = "lua",
}

if (mods and not script) then
    data:extend({
        custom_input.LAUNCH_IPBM,
    })
end

return custom_input