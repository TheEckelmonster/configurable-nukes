local sounds = require("__base__.prototypes.entity.sounds")

local Util = require("__core__.lualib.util")

local galvanic_cluster_grenade = data.raw.capsule["cn-galvanic-cluster-grenade"]

if (not galvanic_cluster_grenade) then
    galvanic_cluster_grenade = data.raw.capsule["cluster-grenade"]
    if (not galvanic_cluster_grenade) then return end

    galvanic_cluster_grenade = Util.table.deepcopy(galvanic_cluster_grenade)

    galvanic_cluster_grenade.name = "cn-galvanic-cluster-grenade"
end

-- galvanic_cluster_grenade.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile = "cn-galvanic-cluster-projectile"
galvanic_cluster_grenade.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile = "cn-galvanic-cluster-grenade"

local galvanic_cluster_projectile = Util.table.deepcopy(data.raw.projectile["cluster-grenade"])
-- galvanic_cluster_projectile.name = "cn-galvanic-cluster-projectile"
-- galvanic_cluster_projectile.action[2].action_delivery.projectile = "cn-galvanic-grenade-projectile"
galvanic_cluster_projectile.name = "cn-galvanic-cluster-grenade"
galvanic_cluster_projectile.action[2].action_delivery.projectile = "cn-galvanic-grenade"

galvanic_cluster_grenade.capsule_action.attack_parameters.ammo_category = "tesla-munition"
galvanic_cluster_grenade.capsule_action.attack_parameters.range = galvanic_cluster_grenade.capsule_action.attack_parameters.range * (7/5)

galvanic_cluster_grenade.enabled = true
data:extend({ galvanic_cluster_grenade, galvanic_cluster_projectile, })
