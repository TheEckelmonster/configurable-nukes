if (mods and mods["space-age"]) then
    -- local Procession_Graphic_Catalogue_Types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")
    local Util = require("__core__.lualib.util")

    local cargo_pod = data.raw["cargo-pod"]["cargo-pod"]
    local procession_default_a = Util.table.deepcopy(data.raw["procession"]["default-a"])
    procession_default_a.type = "pod-catalogue"
    log(serpent.block(procession_default_a))
    local procession_default_b = Util.table.deepcopy(data.raw["procession"]["default-b"])
    procession_default_b.type = "pod-catalogue"
    log(serpent.block(procession_default_b))

    local interplanetary_cargo_pod = Util.table.deepcopy(cargo_pod)
    interplanetary_cargo_pod.name = "ipbm-cargo-pod"

    log(serpent.block(interplanetary_cargo_pod))
    log(serpent.block(interplanetary_cargo_pod.default_graphic))
    log(serpent.block(interplanetary_cargo_pod.procession_graphic_catalogue))

    -- interplanetary_cargo_pod.default_graphic = { type = "none" }
    interplanetary_cargo_pod.default_graphic =
    -- {
        {
            -- index = 0,
            -- type = "sprite",
            -- sprite = {
            --     filename = "__base__/graphics/empty.png",
            --     height = 32,
            --     line_length = 1,
            --     priority = "medium",
            --     scale = 0.5,
            --     shift = {
            --         0.03125,
            --         0.09375
            --     },
            --     width = 32
            -- },
            type = "pod-catalogue",
            catalogue_id = 2 ^ 32 - 1,
        }
    -- }

    log(serpent.block(interplanetary_cargo_pod.default_graphic))

    -- interplanetary_cargo_pod.default_graphic = nil
    -- interplanetary_cargo_pod.default_shadow_graphic = nil
    -- interplanetary_cargo_pod.default_graphic = { type = "pod-catalogue", catalogue_id = Procession_Graphic_Catalogue_Types.impostor_opening_base }
    -- interplanetary_cargo_pod.default_graphic = { type = "pod-catalogue", catalogue_id = 2 ^ 32 - 1 }
    -- interplanetary_cargo_pod.default_shadow_graphic = { type = "pod-catalogue", catalogue_id = Procession_Graphic_Catalogue_Types.pod_shadow }
    -- interplanetary_cargo_pod.shadow_slave_entity = nil
    -- interplanetary_cargo_pod.procession_graphic_catalogue = nil
    -- interplanetary_cargo_pod.procession_audio_catalogue = nil
    -- interplanetary_cargo_pod.default_graphic = nil
    -- interplanetary_cargo_pod.default_shadow_graphic = nil
    -- interplanetary_cargo_pod.shadow_slave_entity = nil
    -- interplanetary_cargo_pod.default_graphic = { type = "pod-catalogue", catalogue_id = Procession_Graphic_Catalogue_Types.impostor_opening_base }
    -- interplanetary_cargo_pod.default_graphic = { type = "pod-catalogue", catalogue_id = 2 ^ 32 - 1 }
    -- interplanetary_cargo_pod.default_shadow_graphic = { type = "pod-catalogue", catalogue_id = Procession_Graphic_Catalogue_Types.pod_shadow }
    -- interplanetary_cargo_pod.procession_graphic_catalogue = { procession_default_a, procession_default_b,}
    interplanetary_cargo_pod.procession_graphic_catalogue =
    {
        -- {
        --     index = Procession_Graphic_Catalogue_Types.planet_hatch_emission_in_1,
        --     sprite = ""
        -- },
        -- {
        --     index = Procession_Graphic_Catalogue_Types.planet_hatch_emission_in_2,
        --     sprite = ""
        -- },
        -- {
        --     index = Procession_Graphic_Catalogue_Types.planet_hatch_emission_in_3,
        --     sprite = ""
        -- }
        -- {
        --     index = 2 ^ 32 - 1,
        --     sprite = Util.sprite_load("__core__/graphics/empty",
        --     {
        --         priority = "medium",
        --         draw_as_glow = true,
        --         blend_mode = "additive",
        --         scale = 0.5,
        --         shift = Util.by_pixel(-64, 96) --32 x ({2, -3.5} + {0, 0.5})
        --     })
        -- }
        {
            -- index = 0,
            index = 2 ^ 32 - 1,
            sprite = {
                filename = "__core__/graphics/empty.png",
                height = 32,
                line_length = 1,
                priority = "medium",
                scale = 0.5,
                shift = {
                    0.03125,
                    0.09375
                },
                width = 32
            },
        },
    }
    -- interplanetary_cargo_pod.procession_audio_catalogue = nil

    log(serpent.block(interplanetary_cargo_pod))

    data:extend({interplanetary_cargo_pod})

    for location_id, space_location in pairs(data.raw["space-location"]) do
        if (location_id == "space-location-unknown") then
            log(serpent.block(space_location.procession_graphic_catalogue))
            space_location.procession_graphic_catalogue ={
                {
                    -- index = 0,
                    index = 2 ^ 32 - 1,
                    sprite = {
                        filename = "__core__/graphics/empty.png",
                        height = 32,
                        line_length = 1,
                        priority = "medium",
                        scale = 0.5,
                        shift = {
                            0.03125,
                            0.09375
                        },
                        width = 32
                    },
                }
            }
            data:extend({space_location})
        end
    end

    for connection_id, space_connection in pairs(data.raw["space-connection"]) do
        log(serpent.block(space_connection.procession_graphic_catalogue))
        space_connection.procession_graphic_catalogue = {
            {
                -- index = 0,
                index = 2 ^ 32 - 1,
                sprite = {
                    filename = "__core__/graphics/empty.png",
                    height = 32,
                    line_length = 1,
                    priority = "medium",
                    scale = 0.5,
                    shift = {
                        0.03125,
                        0.09375
                    },
                    width = 32
                },
            }
        }
        data:extend({space_connection})
    end
end