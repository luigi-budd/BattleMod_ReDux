local B = CBW_Battle
local function buttoncheck(player,button)
	if player.cmd.buttons&button then
		if player.buttonhistory&button then
			return 2
		else
			return 1
		end
	end
	return 0
end

B.ArmaCharge = function(player)
	if not player.valid or not player.mo or not player.mo.valid or not player.armachargeup return end
	local mo = player.mo
	
	if mo.state != S_PLAY_ROLL
	or player.playerstate != PST_LIVE
	or P_PlayerInPain(player)
	or (player.powers[pw_shield] & SH_NOSTACK) != SH_ARMAGEDDON
		player.armachargeup = nil
		player.pflags = $ & ~PF_FULLSTASIS
		return
	end
	
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
		S_StartSoundAtVolume(nil, sfx_s3kc4s, 100)
	end
	
	if player.armachargeup >= 27
		player.armachargeup = nil
		player.pflags = $ & ~PF_FULLSTASIS
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
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED|PF_NOJUMPDAMAGE)
	player.mo.state = S_PLAY_ROLL
	P_Thrust(player.mo, player.mo.angle, 30*player.mo.scale)
	S_StartSound(player.mo,sfx_s3k43)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
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
	player.pflags = ($|PF_JUMPED) & ~(PF_THOKKED|PF_NOJUMPDAMAGE)
	player.mo.state = S_PLAY_ROLL
	P_DoJumpShield(player)
	S_StartSound(player.mo,sfx_s3k45)
	player.pflags = ($|PF_THOKKED|PF_SHIELDABILITY)
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

B.ShieldActives = function(player)
	B.ArmaCharge(player)
	
	if player and player.valid and player.mo and player.mo.valid
		and (player.pflags&PF_JUMPED)
		and not player.gotcrystal
		and not player.gotflag
		and not player.isjettysyn
		and not player.exiting
		and not player.actionstate
		and not player.powers[pw_nocontrol]
		and not player.powers[pw_carry]
		and ((buttoncheck(player,player.battleconfig_guard) == 1) or ((buttoncheck(player,BT_SPIN) == 1) and not (player.charability2 == CA2_GUNSLINGER)))

		// The SRB2 shields.
		-- Elemental Stomp.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			ElementalStomp(player)
			return
		end

		-- Armageddon Explosion.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_ARMAGEDDON
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			ArmageddonExplosion(player)
			return
		end

		-- Whirlwind Jump.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_WHIRLWIND
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			WhirlwindJump(player)
			return
		end

		-- Force Stop.
		if (player.powers[pw_shield] & ~(SH_FORCEHP|SH_STACK)) == SH_FORCE
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			ForceStop(player)
			return
		end

		-- Attraction Homing Attack.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_ATTRACT
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			AttractionShot(player)
			return
		end
	
		// The S3K shields.
		-- Flame Dash.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_FLAMEAURA
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			FlameDash(player)
			return
		end
	
		-- Bubble Bounce.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP
		and not (player.pflags&PF_SHIELDABILITY)
			BubbleBounce(player)
			return
		end
		
		-- Thunder Jump.
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_THUNDERCOIN
		and not (player.pflags&PF_THOKKED)
		and not (player.pflags&PF_SHIELDABILITY)
			ThunderJump(player)
			return
		end
	end
end