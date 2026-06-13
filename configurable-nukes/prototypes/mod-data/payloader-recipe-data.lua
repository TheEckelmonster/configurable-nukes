local Mod_Data = require("__TheEckelmonster-core-library__.libs.mod-data.mod-data")

local Constants = require("scripts.constants.constants")

local Data_Utils = require("__TheEckelmonster-core-library__.libs.utils.data-utils")

local payloader_data = Mod_Data.create({
    name = Constants.mod_name .. "-payloader-recipe-data",
})

local recipe_names = {
    ["payloader-load"] = 1,
    ["payloader-unload"] = 1,
}

for k, v in pairs(data.raw["recipe"]) do
    if (recipe_names[k] and v.category == "payload-change") then
        payloader_data.data.recipes = payloader_data.data.recipes or {}
        payloader_data.data.recipes[k] = v
    end
end

data:extend({
    payloader_data,
})