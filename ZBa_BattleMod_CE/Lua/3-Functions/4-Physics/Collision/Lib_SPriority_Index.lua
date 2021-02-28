local B = CBW_Battle

local xyangle = B.GetCollideRelativeAngle
local zangle = B.GetZCollideAngle

B.SPriority_Fly = function(mo,other)
	if zangle(mo,other) > -ANGLE_45 then return false
	else return true end
end

B.SPriority_Glide = function(mo,other)
	if abs(zangle(mo,other)) > ANGLE_45 or abs(xyangle(mo,other,true)) > ANGLE_45 then return false
	else return true end
end

B.SPriority_TwinSpin = function(mo,other)
	if mo.player then mo.player.pflags = $&~PF_THOKKED end
	if xyangle(mo,other,true) > ANGLE_45 then return false
	else return true end
end

B.SPriority_Melee = function(mo,other)
	if abs(xyangle(mo,other,true)) > ANGLE_45 then return false
	else return true end
end

B.SPriority_TailBounce = function(mo,other)
	if (B.GetZCollideAngle(mo,other) < ANGLE_45) then return false
	else return true end
end

/*
B.SPriority_StompDamage = function(mo,other)
	local bottomheight = mo.z
	local topheight = mo.z + mo.height

	if (mo.eflags & MFE_VERTICALFLIP)
		local swap = bottomheight
		bottomheight = topheight
		topheight = swap
	end

	if not ((P_MobjFlip(mo)*(bottomheight - (other.z + other.height/2)) > 0)
	and (P_MobjFlip(mo)*(mo.momz - other.momz) < 0)) then return false
	else return true end
end
*/
B.SPriority_CanDamage = function(mo,other)
	if not (mo.player and P_PlayerCanDamage(mo.player,other)) then return false
	else return true end
end