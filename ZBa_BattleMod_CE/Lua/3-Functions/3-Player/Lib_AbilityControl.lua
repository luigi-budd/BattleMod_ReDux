local B = CBW_Battle
local S = B.SkinVars

B.TailsCatchPlayer = function(player1,player2)
	if P_MobjFlip(player1.mo) != P_MobjFlip(player2.mo) then return end
	local flip = P_MobjFlip(player1.mo)
	//Determine who's who
	local tails,passenger
	if player1.mo.z*flip < player2.mo.z*flip
		tails = player2
		passenger = player1
	else
		tails = player1
		passenger = player2
	end
	
	//Get Z distance
	local zdist
	if flip == 1 then
		zdist = abs(tails.mo.z-(passenger.mo.z+passenger.mo.height))
	else
		zdist = abs(passenger.mo.z-(tails.mo.z+tails.mo.height))
	end
	
	//Apply gates
	if tails.panim != PA_ABILITY
	or not(tails.pflags&PF_CANCARRY)
	or zdist > FixedDiv(passenger.mo.height,passenger.mo.scale)/2
-- 	or passenger.carried_time < 15
	or passenger.powers[pw_carry]
	or passenger.mo.momz*flip > 0
		return
	end
	//Assign carry states
	B.DebugPrint("Latching "..passenger.name.." onto "..tails.name,DF_PLAYER)
	B.ResetPlayerProperties(passenger,false,false)
	passenger.mo.tracer = tails.mo
	passenger.powers[pw_carry] = CR_PLAYER
	passenger.carried_time = 0
-- 	tails.carry_id = passenger.mo
	S_StartSound(passenger.mo,sfx_s3k4a)
end

B.TwinSpin = function(player)
	if not(player.pflags&PF_JUMPED)
	or not(player.gotflagdebuff or player.powers[pw_shield]&SH_NOSTACK == SH_PITY)
		return false
	end
	
	if player.charability == CA_TWINSPIN and player.charability2 == CA2_MELEE
	and not(player.pflags&PF_THOKKED) and player.pflags&PF_JUMPED
		player.panim = PA_ABILITY
		player.mo.state = S_PLAY_TWINSPIN
		player.frame = 0
		player.pflags = $|PF_THOKKED
		S_StartSound(player.mo,sfx_s3k42)
	return true end
end

local homingthok = function(p)
-- 	if not (p and p.valid and p.charability == CA_HOMINGTHOK) then return end
-- 	if not (p.pflags&PF_SHIELDABILITY)
		p.homing = min($,10)
-- 	end
end

local popgun = function(player)
	if P_PlayerInPain(player) and player.charability2 == CA2_GUNSLINGER then
		player.weapondelay = TICRATE/3
	end
end

local weight = function(player)
	if not(player.mo) then return end
	
	local w
	if S[player.skinvars].weight then
		w = S[player.skinvars].weight
	else
		w = S[-1].weight
	end
	
	player.mo.weight = FRACUNIT*w/100
end

local exhaust = function(player)
	if player.eggrobo_transforming then return end
	local mo = player.mo
	if mo.exhaustcolor == nil then
		mo.exhaustcolor = false
	end
	if (P_IsObjectOnGround(mo) or P_PlayerInPain(player))
	and not(player.actionstate)
	and player.exhaustmeter != FRACUNIT 
	and not(S[player.skinvars].special == B.Action.Dig and player.mo.flags&MF_NOCLIPTHING)
		//Refill meter
		player.exhaustmeter = FRACUNIT
		if mo.exhaustcolor == true then
			mo.colorized = false
			mo.color = player.skincolor
			mo.exhaustcolor = false
		end
	return end
	local use = false
	local maxtime = TICRATE*6
	local warningtic = FRACUNIT/3
	if (player.powers[pw_carry] == CR_MACESPIN and player.mo.tracer) //Swinging from chain
		maxtime = TICRATE*6
		use = true
	elseif player.charability == CA_FLY then //Tails ability
		maxtime = TICRATE*11/2
	elseif player.charability == CA_GLIDEANDCLIMB and not(player.mo.flags&MF_NOCLIPTHING) then //Knuckles ability
		maxtime = $+TICRATE*2
	end
	//Get usage
	if 
		player.powers[pw_tailsfly]
		or
		player.climbing
		or (player.charability==CA_FLOAT and (
			player.secondjump or player.pflags&(PF_THOKKED|PF_JUMPED)==PF_THOKKED|PF_JUMPED)
		)
		use = true
	end
	//Use meter
	if(use) and (player.exhaustmeter) then
		if player.climbing == 5 then
			if player.exhaustmeter > warningtic then
				player.exhaustmeter = max(warningtic,$-FRACUNIT/4)
			else
				player.exhaustmeter = max(0,$-FRACUNIT/4)
			end
		end
		player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
	end
	//Exhaust warning
	local colorflip = false
	if player.exhaustmeter < warningtic and not(player.exhaustmeter == 0) then
		if not(leveltime&7)
-- 			S_StartSound(mo,sfx_s3kb5,player)
			S_StartSound(mo,sfx_s3kbb,player)
		end
		if (leveltime&4)
			colorflip = true
		end
	end
	
	//Exhaust color
	if colorflip == true
		mo.exhaustcolor = true
		mo.colorized = true
		mo.color = SKINCOLOR_BRONZE
	elseif mo.exhaustcolor == true
		mo.exhaustcolor = false
		mo.colorized = false
		mo.color = player.skincolor		
	end
	
	//Fully exhausted
	if use and not(player.exhaustmeter) then
		//Tails
		if player.powers[pw_tailsfly] then
			player.powers[pw_tailsfly] = 0
		end
		//Knuckles
		if player.climbing then
			player.climbing = 0
			player.pflags = $|PF_JUMPED|PF_THOKKED
			mo.state = S_PLAY_ROLL
		end
		//Metal Sonic
		if (player.charability==CA_FLOAT and player.secondjump) then
			local spd = FixedHypot(player.rmomx,player.rmomy)
			local ang = R_PointToAngle2(0,0,player.rmomx,player.rmomy)
			local limit = FixedMul(player.normalspeed/6,mo.scale)
			if spd > limit then
				P_InstaThrust(mo,ang,limit)
				if P_RandomChance(FRACUNIT/6) then
					local x = mo.x-P_ReturnThrustX(mo,mo.angle,mo.radius)
					local y = mo.y-P_ReturnThrustY(mo,mo.angle,mo.radius)
					local z = mo.z+mo.height/2
					P_SpawnMobj(x,y,z,MT_SMOKE)
				end
				if not(S_SoundPlaying(mo,sfx_s3kc2s)) then
					S_StartSound(mo,sfx_s3kc2s)
				end
			end
		end
		//Swinging from chain
		if (player.powers[pw_carry] == CR_MACESPIN and player.mo.tracer)
			player.powers[pw_carry] = CR_NONE
			player.mo.tracer = nil
			player.powers[pw_flashing] = TICRATE/4
		end
	end
end

B.CharAbilityControl = function(player)
	homingthok(player)
	popgun(player)
	weight(player)
	exhaust(player)
	B.ShieldAbility(player)
end

B.ShieldActiveAllowed = function(player)
	if B.GetSkinVarsFlags(player,SKINVARS_GUNSLINGER)
		return false
	else
		return true
	end
end

B.MidAirAbilityAllowed = function(player)
	if player.gotcrystal or player.gotflag then 
		return false
	else
		return true
	end
end

