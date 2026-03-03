local payloader_rocket = data.raw["projectile"]["payloader-rocket"]
if (payloader_rocket.collision_box) then payloader_rocket.collision_box = nil end
if (payloader_rocket.hit_collision_mask) then payloader_rocket.hit_collision_mask = nil end