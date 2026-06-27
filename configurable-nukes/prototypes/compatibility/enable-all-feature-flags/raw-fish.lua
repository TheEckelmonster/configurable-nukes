local raw_fish = data.raw["capsule"]["raw-fish"]

if (type(raw_fish) == "table") then
    raw_fish.spoil_ticks = raw_fish.spoil_ticks or 453000
end