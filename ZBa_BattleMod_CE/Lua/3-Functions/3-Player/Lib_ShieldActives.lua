local B = CBW_Battle

B.ArmaCharge = function(player)
	if not player.valid or not player.mo or not player.mo.valid or not player.armachargeup
		player.armachargeup = nil
		return
	end
	
	local mo = player.mo
	
	if (player.actionstate
		or player.playerstate != PST_LIVE
		or P_PlayerInPain(player)
		or (player.powers[pw_shield] & SH_NOSTACK) != SH_ARMAGEDDON)
		
		player.armachargeup = nil
		player.pflags = $ & ~PF_FULLSTASIS
		return
	end
	
	mo.state = S_PLAY_ROLL
	player.pflags = $ | PF_THOKKED | PF_SHIELDABILITY | PF_FULLSTASIS | PF_JUMPED & ~PF_NOJUMPDAMAGE
	
	player.armachargeup = $ + 1
	//Speed Cap
	local speed = FixedHypot(mo.momx,mo.momy)
	if speed > mo.scale then
		local dir = R_PointToAngle2(0,0,mo.momx,mo.momy)
		P_InstaThrust(mo,dir,FixedMul(speed,mo.friction))
	end
	P_SetObjectMomZ(mo,0,false)
	
	if player.armachargeup == 14
		S_StartSoundAtVolume(mo, sfx_s3kc4s, 200)
		S_StartSoundAtVolume(nil, sfx_s3kc4s, 80)
	end
	
	if player.armachargeup >= 27
		player.armachargeup = nil
		player.pflags = $ & ~PF_FULLSTASIS
		player.pflags = $ & ~PF_JUMPED
		
		mo.state = S_PLAY_FALL
		local shake = 14
		local shaketics = 5
		P_StartQuake(shake * FRACUNIT, shaketics)
		S_StartSoundAtVolume(nil, sfx_s3kb4, 170)
		P_BlackOw(player)
	end
end

local ElementalStomp = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	player.mo.state = S_PLAY_ROLL
	P_InstaThrust(player.mo, 0, 0*FRACUNIT)
	P_SetObjectMomZ(player.mo, -25*FRACUNIT)
	S_StartSound(player.mo,sfx_s3k43)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
end
local ArmageddonExplosion = function(player)
	player.armachargeup = 1
	player.dashmode = 0
	player.pflags = $ | PF_SHIELDABILITY | PF_FULLSTASIS | PF_JUMPED & ~PF_NOJUMPDAMAGE
	player.mo.state = S_PLAY_ROLL

	S_StartSoundAtVolume(player.mo, sfx_s3kc4s, 200)
	S_StartSoundAtVolume(nil, sfx_s3kc4s, 100)
end
local WhirlwindJump = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	P_DoJumpShield(player)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
end
local FlameDash = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	player.mo.state = S_PLAY_ROLL
	P_Thrust(player.mo, player.mo.angle, 30*player.mo.scale)
	S_StartSound(player.mo,sfx_s3k43)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY) & ~PF_NOJUMPDAMAGE
end
local BubbleBounce = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	P_DoBubbleBounce(player)
	player.mo.state = S_PLAY_ROLL
	P_SetObjectMomZ(player.mo, -25*FRACUNIT)
	S_StartSound(player.mo,sfx_s3k44)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
end
local ThunderJump = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	player.mo.state = S_PLAY_ROLL
	P_DoJumpShield(player)
	S_StartSound(player.mo,sfx_s3k45)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY) & ~PF_NOJUMPDAMAGE
end
local ForceStop = function(player)
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED)
	P_InstaThrust(player.mo, 0, 0*FRACUNIT)
	
	player.weapondelay = 25
	P_SetObjectMomZ(player.mo, 0*FRACUNIT)
	S_StartSound(player.mo,sfx_ngskid)
	player.pflags = $|PF_THOKKED|PF_SHIELDABILITY
end
local AttractionShot = function(player)
	local lockonshield = P_LookForEnemies(player, false, false)
	player.mo.tracer = lockonshield
	player.mo.target = lockonshield
	if lockonshield and lockonshield.valid
		player.pflags = ($|PF_THOKKED|PF_JUMPED|PF_SHIELDABILITY) & ~(PF_NOJUMPDAMAGE)
		player.mo.state = S_PLAY_ROLL
		player.mo.angle = R_PointToAngle2(player.mo.x, player.mo.y, lockonshield.x, lockonshield.y)
		S_StartSound(player.mo, sfx_s3k40)
		player.homing = 1*TICRATE/2
	else
		player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
		S_StartSound(player.mo, sfx_s3ka6)
		player.homing = 2
	end
end

B.CanShieldActive = function(player)
	if not player.gotcrystal
		and not player.gotflag
		and not player.isjettysyn
		and not player.exiting
		and not player.actionstate
		and not player.powers[pw_nocontrol]
		and not (player.pflags&PF_SHIELDABILITY)
		return true
	end
	return false
end

B.DoShieldActive = function(player)
	// The SRB2 shields.
	-- Elemental Stomp.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
		ElementalStomp(player)
		return
	end

	-- Armageddon Explosion.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_ARMAGEDDON
		ArmageddonExplosion(player)
		return
	end

	-- Whirlwind Jump.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_WHIRLWIND
		WhirlwindJump(player)
		return
	end

	-- Force Stop.
	if (player.powers[pw_shield] & ~(SH_FORCEHP|SH_STACK)) == SH_FORCE
		ForceStop(player)
		return
	end

	-- Attraction Shot.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_ATTRACT
		AttractionShot(player)
		return
	end

	// The S3K shields.
	-- Flame Dash.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_FLAMEAURA
		FlameDash(player)
		return
	end

	-- Bubble Bounce.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP
		BubbleBounce(player)
		return
	end
	
	-- Thunder Jump.
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_THUNDERCOIN
		ThunderJump(player)
		return
	end
end

B.ShieldTossFlagButton = function(player)
	if player and player.valid and player.mo and player.mo.valid
		player.shieldswap_cooldown = max(0, $ - 1)
		
		if B.CanShieldActive(player)
			and (B.ButtonCheck(player,BT_TOSSFLAG) == 1)
			and not (player.tossdelay == 2*TICRATE - 1)
			
			if (player.pflags&PF_JUMPED)
				and not player.powers[pw_carry]
				and not (player.pflags&PF_THOKKED and not (player.secondjump == UINT8_MAX and (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP))
				B.DoShieldActive(player)
			else
				--Shield swap
				local power = player.shieldstock[1]
				
				if B.ButtonCheck(player,BT_TOSSFLAG) == 1
				and not player.shieldswap_cooldown
				and power
					
					local temp = player.powers[pw_shield]&SH_NOSTACK
					if temp != power
					
						player.shieldswap_cooldown = 15
						
						player.powers[pw_shield] = 0
						P_RemoveShield(player)
						
						B.UpdateShieldStock(player,-1)
						P_SwitchShield(player, power)
						
						player.shieldstock[#player.shieldstock+1] = temp
					
						S_StartSound(player.mo, sfx_shswap)
					end
				end
			end
		end
	end
end