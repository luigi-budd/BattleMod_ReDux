local B = CBW_Battle
local CV = B.Console

B.TeamFireTrail = function(mo)
	if not(G_GametypeHasTeams() and mo.target and mo.target.valid and mo.target.player) then return end
	if not(mo.ctfteam) then
		local player = mo.target.player
		mo.ctfteam = player.ctfteam
		mo.color = player.skincolor
		mo.state = S_TEAMFIRE1
	end
end

B.PlayerHeartCollision = function(mo,heart,owner)
	//Relegate this hook to interactions with players and heart projectiles
	if not(mo and mo.valid) then return end
	if not(mo.player) then return end
	if not(heart and heart.valid and heart.type == MT_LHRT) then return end
	if not(heart.flags&MF_MISSILE) then return end //heart is dead
	if not(owner and owner.type == MT_PLAYER) then return end
	//Player vs tagged
	if mo.player.pflags&PF_TAGIT and not(owner.player.pflags&PF_TAGIT) then return false end
	//Players
	if B.PlayerCanBeDamaged(mo.player) and not(B.MyTeam(owner.player,mo.player))
		then
		if G_TagGametype()
			return true
		elseif mo.player.battle_def
			P_InstaThrust(mo,R_PointToAngle2(0,0,heart.momx,heart.momy),heart.scale*10)
			S_StartSound(mo,sfx_s3k7b)
			B.PlayerCreditPusher(mo.player,owner)
			return false
		else
			return true
		end
	end
	if B.MyTeam(mo.player,owner.player)
		then//Do pink shield
		B.AddPinkShield(mo.player,owner.player)
		return 
	end
	return nil
end

B.PlayerCorkDamage = function(pmo,mo,source)
	if not(mo and mo.valid and mo.type == MT_CORK and mo.flags&MF_MISSILE) then return end
	if pmo.player and source and source.valid and source.player and not(B.MyTeam(source.player,pmo.player))
		local vulnerable = B.PlayerCanBeDamaged(pmo.player)
-- 		B.DoSPriority(pmo.player,mo)
		B.PlayerCreditPusher(pmo.player,source)
		if vulnerable and pmo.player.battle_def != 0 then
			B.ResetPlayerProperties(pmo.player,false,false)
			local thrust
			if P_IsObjectOnGround(pmo) then
				thrust = 12
				P_InstaThrust(pmo,mo.angle,mo.scale*thrust)		
				pmo.state = S_PLAY_SKID
			else
				pmo.momz = $/2
				P_SetObjectMomZ(pmo,FRACUNIT*10/B.WaterFactor(pmo),1)
				thrust = 5
				P_InstaThrust(pmo,mo.angle,mo.scale*thrust)
				pmo.state = S_PLAY_FALL
			end
			S_StartSound(pmo,sfx_s3k7b)
			//Do uncurling, skidding
			local time = thrust
			local angle = R_PointToAngle2(0,0,pmo.momx,pmo.momy)
			local recoilthrust = FixedHypot(pmo.momx,pmo.momy)
			B.DoPlayerFlinch(pmo.player, thrust, angle, recoilthrust)
			P_RemoveMobj(mo)
			return false
		elseif not(vulnerable) then
			P_Thrust(pmo,mo.angle,mo.scale*12)
			S_StartSound(mo,sfx_s3k7b)		
			return false
		else
			return true
		end
	end
end

B.PlayerRoboMissileCollision = function(pmo,missile,source)
	//Missiles only
	if not(missile and missile.valid and missile.robomissile_init and missile.flags&MF_MISSILE) then return end
	//Enemy player collisions only
	if not(pmo.player and source and source.valid and source.player and not(B.MyTeam(source.player,pmo.player))) then return false end
	//The game already handles standard missile damage.
	//We just need to make an exception case
	if pmo.player.battle_def != 0
		local spd = FixedDiv(
			FixedHypot(missile.momx,missile.momy)/2,
			pmo.weight
		)
-- 		local angle = R_PointToAngle2(missile.x,missile.y,pmo.x,pmo.y)
-- 		P_Thrust(pmo,angle,spd)
		if not(P_IsObjectOnGround(pmo)) then
			P_SetObjectMomZ(pmo,FRACUNIT*8,0)
		end
		//Do uncurling, skidding
		B.DoPlayerFlinch(pmo.player, spd*2/FRACUNIT, R_PointToAngle2(0,0,missile.momx,missile.momy),spd,true)
		P_KillMobj(missile)
	return false end
end