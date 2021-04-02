local B = CBW_Battle
local cooldown = TICRATE*2
local xythrust = 24
local zthrust = 8
local dropspeed = 20

B.Action.CombatRoll = function(mo,doaction)
	local player = mo.player

	//Conditions
	local bouncing = player.pflags&PF_BOUNCING
	local activate = player.actiontime == 0 and doaction == 1
	local thrust_trigger = activate and not(bouncing)
	local springdrop_trigger = activate and bouncing
	local drop_state = player.actionstate == 1 and bouncing
		and P_MobjFlip(mo)*mo.momz < 0
	local thrust_state = player.actiontime and mo.state == S_PLAY_ROLL
		and not(P_IsObjectOnGround(mo)) and player.actiontime < 20
	
	//Properties
	player.actiontext = "Combat Roll"
	player.actionrings = 10
	if player.pflags&PF_BOUNCING
		player.actiontext = "Spring Drop"
	end
	
	//Perform Thrust
	if thrust_trigger
		//Apply cost, cooldown, state
		B.PayRings(player)
		player.actionstate = 2
		player.actiontime = 1
		B.ApplyCooldown(player,cooldown)
		player.drawangle = mo.angle
		//Apply momentum
		B.ZLaunch(mo,zthrust*FRACUNIT,false)
		P_InstaThrust(mo,mo.angle,xythrust*mo.scale)
		//Apply midair state
		player.pflags = ($|PF_JUMPED) &~ (PF_NOJUMPDAMAGE|PF_THOKKED)
		mo.state = S_PLAY_ROLL
		player.airgun = false
		//Do effects
		S_StartSound(mo,sfx_zoom)
		for n = 0,3
			local dust = P_SpawnMobjFromMobj(mo,0,0,0,MT_SPINDUST)
			local angle = (180+P_RandomRange(-60,60))*ANG1+mo.angle
			local speed = mo.scale*P_RandomRange(5,10)
			P_InstaThrust(dust,angle,speed)
		end
		return
	end
	
 	//Perform spring drop
	if springdrop_trigger
		//Apply cost, cooldown, state
		B.PayRings(player)
		B.ApplyCooldown(player,cooldown)
		player.actionstate = 1
		player.actiontime = 1
		//Apply momentum
		mo.momx = $/2
		mo.momy = $/2
		B.ZLaunch(mo,-dropspeed*FRACUNIT,false)
		//Effects
		S_StartSound(mo,sfx_zoom)
		P_SpawnParaloop(mo.x,mo.y,mo.z,mo.scale*128,16,MT_DUST,ANGLE_90,nil,true)
		return
	end

	//Reset state
	if not(drop_state or thrust_state)
		player.actiontime = 0
		player.actionstate = 0
	else //Afterimage
		player.actiontime = $+1
		if player.actiontime%8
			P_SpawnGhostMobj(mo)
		end
	end
end

B.Action.CombatRoll_Priority = function(player)
	local mo = player.mo
	if not (mo and mo.valid) return end
	
	local bouncing = player.pflags&PF_BOUNCING
	local drop_state = player.actionstate == 1 and bouncing
		and P_MobjFlip(mo)*mo.momz < 0
	local thrust_state = player.actiontime and mo.state == S_PLAY_ROLL
		and not(P_IsObjectOnGround(mo)) and player.actiontime < 20
	
	if player.actionstate == 1
		B.SetPriority(player,0,1,"fang_springdrop",2,3,"spring drop")
	elseif player.actionstate == 2
		B.SetPriority(player,1,1,nil,1,1,"combat roll")
	end
end