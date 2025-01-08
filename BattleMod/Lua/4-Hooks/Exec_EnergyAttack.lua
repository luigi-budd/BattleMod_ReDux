--Spike Breaking (Because battlemod nulls out STR_SPIKE)

local state_ringspark = 4
local state_dashslicer = 6
local B = CBW_Battle

B.EnergyAttackCheck = function(player)
	return player and player.realmo and player.realmo.valid and rawget(B.SkinVars, player.realmo.skin) and (B.SkinVars[player.realmo.skin].special == B.Action.EnergyAttack)
end

B.RingSparkCheck = function(player)
	return B.EnergyAttackCheck(player) and ((player.actionstate == state_ringsparkprep) or (player.actionstate == state_ringspark))
end

addHook("MobjCollide", function(spike, pmo)
	if not (pmo and pmo.valid and pmo.player and B.EnergyAttackCheck(pmo.player)) then return end
	if pmo.z+pmo.height < spike.z or spike.z+spike.height < pmo.z then return end
	
	if pmo.player.actionstate == state_ringspark or pmo.player.actionstate == state_dashslicer then
		P_KillMobj(spike, pmo, pmo)
	end
end, MT_SPIKE)

addHook("MobjCollide", function(spike, pmo)
    if not (pmo and pmo.valid and pmo.player and B.EnergyAttackCheck(pmo.player)) then return end
    if (pmo.z > spike.z+spike.height*4) or (spike.z > pmo.z+pmo.height*2) then return end
	
	if pmo.player.actionstate == state_ringspark or pmo.player.actionstate == state_dashslicer then
		P_KillMobj(spike, pmo, pmo)
	end
end, MT_WALLSPIKE)


addHook("PlayerCanDamage", function(player, mo)
	if not(B.EnergyAttackCheck(player)) then return end
	if (player.actionstate == state_ringspark) or (player.actionstate == state_dashslicer) and not(mo.player) then
		return true
	end
end)