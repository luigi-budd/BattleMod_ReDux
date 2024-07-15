--Spike Breaking (Because battlemod nulls out STR_SPIKE)

local state_ringspark = 4
local state_dashslicer = 6

addHook("MobjCollide", function(spike, pmo)
	if not (pmo and pmo.valid and pmo.player and pmo.player) then return end
	if pmo.z+pmo.height < spike.z or spike.z+spike.height < pmo.z then return end
	
	if pmo.player.actionstate == state_ringspark or pmo.player.actionstate == state_dashslicer then
		P_KillMobj(spike, pmo, pmo)
	end
end, MT_SPIKE)

addHook("MobjCollide", function(spike, pmo)
    if not (pmo and pmo.valid and pmo.player and pmo.player.valid) then return end
    if (pmo.z > spike.z+spike.height*4) or (spike.z > pmo.z+pmo.height*2) then return end
	
	if pmo.player.actionstate == state_ringspark or pmo.player.actionstate == state_dashslicer then
		P_KillMobj(spike, pmo, pmo)
	end
end, MT_WALLSPIKE)