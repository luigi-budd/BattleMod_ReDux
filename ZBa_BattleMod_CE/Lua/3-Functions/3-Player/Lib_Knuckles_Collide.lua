local B = CBW_Battle
B.Knuckles_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if plr[n1] and mo[n1].health and not(pain[n1])
		and (plr[n1].pflags&PF_GLIDING or plr[n1].climbing 
			or (plr[n1].charability == CA_GLIDEANDCLIMB) and collisiontype > 1 and P_IsObjectOnGround(mo[n1]) and not(plr[n1].pflags&PF_SPINNING)
		) then
		plr[n1].pflags = $&~(PF_GLIDING|PF_JUMPED)
		if not(P_IsObjectOnGround(mo[n1])) and not(plr[n1].climbing) then
			plr[n1].panim = PA_FALL
			mo[n1].state = S_PLAY_FALL
			plr[n1].climbing = 0
			plr[n1].lastsidehit = -1
			plr[n1].lastlinehit = -1
			
			P_Thrust(mo[n1],mo[n1].angle + ANGLE_180, 6*FRACUNIT)
			P_SetObjectMomZ(mo[n1], 2*FRACUNIT/B.WaterFactor(mo[n1]), true)
		elseif (atk[n2])
			mo[n1].state = S_PLAY_GLIDE_LANDING
		end
	end
	return false
end