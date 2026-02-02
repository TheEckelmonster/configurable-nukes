local payloader_recipe = data.raw.recipe["payloader"]
if (not payloader_recipe) then return end

local fluids = {}
local fluid_count = 0
local fluid_concrete = nil
local refined_conrete = nil

local function check_fluids()
    fluid_concrete = nil
    fluid_count = 0
    fluids = {}

    for k, v in pairs(payloader_recipe.ingredients) do

        if (v.name:find("concrete")) then
            if (v.name == "refined-concrete") then
                if (not refined_conrete) then
                    refined_conrete = v
                end
            end

            if (v.type == "fluid" and not fluid_concrete) then
                fluid_concrete = {
                    index = k,
                    name = v.name,
                    ingredient = v,
                }
            end
        end

        if (v.type == "fluid") then
            fluid_count = fluid_count + 1
            fluids[v.name] = {
                index = k,
                name = v.name,
                ingredient = v,
            }
        end
    end
end

check_fluids()

local loops = 0
while fluid_count > 1 do
    if (loops > 2 ^ 6) then return end
    loops = loops + 1

    if (fluid_concrete) then
        if (not refined_conrete) then
            payloader_recipe.ingredients[fluid_concrete.index].name = "refined-concrete"
            payloader_recipe.ingredients[fluid_concrete.index].type = "item"
            payloader_recipe.ingredients[fluid_concrete.index].amount = payloader_recipe.ingredients[fluid_concrete.index].amount / 10
        else
            table.remove(payloader_recipe.ingredients, fluid_concrete.index)
        end
    else
        if (fluids["lubricant"]) then
            table.remove(payloader_recipe.ingredients, fluids["lubricant"].index)
        else
            local _, fluid = next(fluids)
            if (fluid and fluid.ingredient and fluid.ingredient.type == "fluid") then
                table.remove(payloader_recipe.ingredients, fluid.index)
            end
        end
    end

    check_fluids()
end