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

B.PikoWaveThinker = function(mo)
	if not(mo.target and mo.target.valid)
		P_RemoveMobj(mo)
		return
	end
	if mo.state != S_PIKOWAVE1
		mo.momx = 0
		mo.momy = 0
		mo.momz = 0
		return
	end
	
	if mo.time == nil
		mo.time = 1
	end
	mo.time = $+1
	
	//Spawn projectiles
	if not(mo.time%2)
		local range = 3
		local x = mo.x + P_RandomRange(-range,range)*mo.scale
		local y = mo.y + P_RandomRange(-range,range)*mo.scale
		local z = mo.z
		if P_MobjFlip(mo) == -1
			z = $ + mo.height
		end
		
		local momz = P_RandomRange(10,12)*FRACUNIT
		local hfriction = P_RandomRange(80,90)
		
		local hrt = P_SpawnXYZMissile(mo.target, mo, MT_PIKOWAVEHEART, x,y,z)
		if hrt and hrt.valid
			S_StartSound(hrt,sfx_hoop2)
			hrt.friction = hfriction //Horz friction
			hrt.momz = momz * P_MobjFlip(mo)
			local thrust = hrt.scale*11/5
			local thrust2 = hrt.scale*2
			local angle = FixedAngle(P_RandomRange(0,359)<<FRACBITS)
			P_InstaThrust(hrt,angle,thrust)
			P_Thrust(hrt,mo.angle,thrust2)
			hrt.scale = mo.scale / 9
			hrt.fuse = 50
			
			if (mo.time%4) and mo.color
				hrt.state = S_PIKOWAVE3
				hrt.color = mo.teamcolor
			end
		end
	end
	
	//Speeds up over time
	local friction = 101
	mo.momx = $*friction/100
	mo.momy = $*friction/100
	
	mo.angle = $ + ANG10
end

B.PlayerHeartCollision = function(mo,heart,owner)
	//Relegate this hook to interactions with players and heart projectiles
	if not(mo and mo.valid) then return end
	if not(mo.player) then return end
	if not(heart and heart.valid and (heart.type == MT_LHRT or heart.type == MT_PIKOWAVEHEART)) then return end
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