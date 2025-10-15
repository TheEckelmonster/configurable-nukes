local k2so_active = mods and mods["Krastorio2-spaced-out"] and true
if (not k2so_active) then return end

local Util = require("__core__.lualib.util")

local Startup_Settings_Constants = require("settings.startup.startup-settings-constants")

local recipes =
{
    {
        name = Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE.recipe_name,
        ingredients = Util.table.deepcopy(Startup_Settings_Constants.settings.BALLISTIC_ROCKET_PART_RECIPE.ingredients),
    },
    {
        name = Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.recipe_name,
        ingredients = Util.table.deepcopy(Startup_Settings_Constants.settings.INTERMEDIATE_BALLISTIC_ROCKET_PART_RECIPE.ingredients),
    },
    {
        name = Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.recipe_name,
        ingredients = Util.table.deepcopy(Startup_Settings_Constants.settings.ADVANCED_BALLISTIC_ROCKET_PART_RECIPE.ingredients),
    },
    {
        name = Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.recipe_name,
        ingredients = Util.table.deepcopy(Startup_Settings_Constants.settings.BEYOND_BALLISTIC_ROCKET_PART_RECIPE.ingredients),
    },
    {
        name = Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.recipe_name,
        ingredients = Util.table.deepcopy(Startup_Settings_Constants.settings.BEYOND_2_BALLISTIC_ROCKET_PART_RECIPE.ingredients),
    },
}

for k, v in pairs(recipes) do
    local default_ingredients_dictionary = {}
    for i, j in pairs(v.ingredients) do
        default_ingredients_dictionary[j.name] = i
    end

    local recipe = data.raw["recipe"][v.name]

    if (recipe) then
        local ingredients_dictionary = {}
        for i, j in pairs(recipe.ingredients) do
            if (ingredients_dictionary[j.name]) then
                if (i ~= default_ingredients_dictionary[j.name]) then
                    table.remove(recipe.ingredients, i)
                else
                    ingredients_dictionary[j.name] = i
                end
            else
                ingredients_dictionary[j.name] = i
            end
        end
    end
end
