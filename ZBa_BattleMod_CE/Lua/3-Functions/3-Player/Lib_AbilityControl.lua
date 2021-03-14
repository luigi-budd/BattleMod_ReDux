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

local fly = function(player)
	if not (player and player.mo and player.mo.valid and player.mo.state == S_PLAY_FLY_TIRED)
		return
	end
	player.cmd.forwardmove = $ / 2
	player.cmd.sidemove = $ / 2
end

local glide = function(player)
	if not (player and player.mo and player.mo.valid)
		return
	end
	local mo = player.mo
	if (mo.state == S_PLAY_GLIDE or mo.state == S_PLAY_SWIM) and player.glidetime and not P_IsObjectOnGround(mo)
		if not (player.pflags & PF_DIRECTIONCHAR)//Begin directionchar gliding
			player.waslegacy = true
			player.pflags = $ | PF_DIRECTIONCHAR
		end
		
		if player.glidetime > 16 //Downward force when gliding very slowly
			if (player.speed < 12 * FRACUNIT)
				P_SetObjectMomZ(mo, FRACUNIT * -1, true)
			elseif (player.speed < 24 * FRACUNIT)
				P_SetObjectMomZ(mo, FRACUNIT * -2/3, true)
			end
		end
		
	elseif player.waslegacy//End directionchar gliding
		player.waslegacy = nil
		player.pflags = $ & ~PF_DIRECTIONCHAR
	end
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
	if not (player and player.mo and player.mo.valid)
		return
	end
	local mo = player.mo
	
	//Do func_exhaust
	local defaultfunc = S[-1].func_exhaust
	local func = S[player.skinvars].func_exhaust
	local override = nil
	if not func
		func = defaultfunc
	end
	if func
		override = func(player)
	end
	
	//Common exhaust states
	if player.powers[pw_carry] == CR_MACESPIN and player.mo.tracer
		local maxtime = 4*TICRATE
		player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
		if player.exhaustmeter <= 0
			player.exhaustmeter = FRACUNIT
			player.powers[pw_carry] = CR_NONE
			player.mo.tracer = nil
			player.powers[pw_flashing] = TICRATE/4
		end
	end
	if player.charability == CA_FLY and player.powers[pw_tailsfly]
		local maxtime = 4*TICRATE
		player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
		if player.exhaustmeter <= 0
			player.exhaustmeter = FRACUNIT
			player.powers[pw_tailsfly] = 0
		end
	end
	if player.charability == CA_GLIDEANDCLIMB
		if (mo.state == S_PLAY_GLIDE or mo.state == S_PLAY_SWIM) and not P_IsObjectOnGround(mo)
			local maxtime = 5*TICRATE
			player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
			if player.exhaustmeter <= 0
				player.exhaustmeter = FRACUNIT
				mo.state = S_PLAY_FALL
				player.pflags = $ & ~PF_GLIDING & ~PF_JUMPED | PF_THOKKED
				player.glidetime = 0
			end
		elseif player.climbing
			if player.climbing == 5 then
				if player.exhaustmeter and (player.exhaustmeter > warningtic) then
					player.exhaustmeter = max(warningtic,$-FRACUNIT/4)
				else
					player.exhaustmeter = max(0,$-FRACUNIT/4)
				end
			else
				local maxtime = 8*TICRATE
				player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
			end
			if player.exhaustmeter <= 0
				player.exhaustmeter = FRACUNIT
				player.climbing = 0
				player.pflags = $|PF_JUMPED|PF_THOKKED
				mo.state = S_PLAY_ROLL
			end
		end
	end
	if player.charability == CA_FLOAT and player.secondjump and (player.pflags & PF_THOKKED) and not (player.pflags & PF_JUMPED) and not (player.pflags & PF_SPINNING)
		local maxtime = 6*TICRATE
		player.exhaustmeter = max(0,$-FRACUNIT/maxtime)
		if player.exhaustmeter <= 0
			player.exhaustmeter = FRACUNIT
			player.secondjump = 0
			mo.state = S_PLAY_FALL
			player.pflags = $ & ~PF_JUMPED | PF_THOKKED
		end
	end
	
	//Refill meter
	if (P_IsObjectOnGround(mo) or P_PlayerInPain(player)) and not player.actionstate and not override
		player.exhaustmeter = FRACUNIT
	end
	
	//Exhaust warning / color
	if mo.exhaustcolor == nil then
		mo.exhaustcolor = false
	end
	if mo.exhaustcolor == true and player.exhaustmeter == FRACUNIT
		mo.colorized = false
		mo.color = player.skincolor
		mo.exhaustcolor = false
	end
	local colorflip = false
	local warningtic = FRACUNIT/3
	if player.exhaustmeter < warningtic and not(player.exhaustmeter == 0) then
		if not(leveltime&7)
			S_StartSound(mo,sfx_s3kbb,player)
		end
		if (leveltime&4)
			colorflip = true
		end
	end
	if colorflip == true
		mo.exhaustcolor = true
		mo.colorized = true
		mo.color = SKINCOLOR_BRONZE
	elseif mo.exhaustcolor == true
		mo.exhaustcolor = false
		mo.colorized = false
		mo.color = player.skincolor		
	end
end

B.ExhaustCommon = function(player)
	local warningtic = FRACUNIT/3
	local mo = player.mo
end

B.CharAbilityControl = function(player)
	B.ArmaCharge(player)
	fly(player)
	glide(player)
	homingthok(player)
	popgun(player)
	weight(player)
	exhaust(player)
end

B.MidAirAbilityAllowed = function(player)
	if player.gotcrystal or player.gotflag then 
		return false
	else
		return true
	end
end

