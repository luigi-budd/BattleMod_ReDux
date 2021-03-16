local B = CBW_Battle
local CV = B.Console

B.StunBreakVFXThinker = function(mo)
	if not B return end
	mo.color = B.Choose(SKINCOLOR_WHITE,SKINCOLOR_YELLOW,SKINCOLOR_ROSY,SKINCOLOR_GREEN,SKINCOLOR_ORANGE,SKINCOLOR_BLUE,SKINCOLOR_PURPLE)
end

B.StunBreak = function(player, doguard)
	if not B return end
	if not (player and player.valid and player.mo and player.mo.valid) or not P_PlayerInPain(player) or not player.mo.state == S_PLAY_PAIN
		return
	end
	local mo = player.mo
	
	//Input buffer
	if mo.tics == 349//First frame of S_PLAY_PAIN
		player.tech_bfr = false
	end
	if doguard == 1
		player.tech_bfr = true
	end
	if player.tech_bfr and not doguard
		player.tech_bfr = nil
	end
	
	//Do the stun break
	if mo.tics <= 327 and player.tech_bfr and player.rings >= 30
		player.tech_bfr = nil
		
		//State and flags
		B.ResetPlayerProperties(player,false,false)
		mo.state = S_PLAY_SPRING
		player.airdodge = -1
		
		//Launch
		local techmomz = 9*FRACUNIT/B.WaterFactor(mo)
		P_SetObjectMomZ(mo, techmomz, false)
		P_InstaThrust(mo,mo.angle,FRACUNIT*12)
		player.drawangle = mo.angle
		
		//SFX
		S_StartSound(mo,sfx_cdfm66,player)
		S_StartSound(mo, sfx_nbmper)
		S_StartSoundAtVolume(mo, sfx_kc31, 200)
		
		//Pay rings, cooldown
		player.actioncooldown = max($, TICRATE)
		player.rings = $ - 30
		
		//Visual effects
		local sb = P_SpawnMobjFromMobj(mo,0,0,0,MT_STUNBREAK)
		sb.scale = mo.scale * 4/3
		sb.destscale = mo.scale * 3
		sb.momz = mo.momz * 3/4
		local sh = P_SpawnMobjFromMobj(mo,0,0,0,MT_BATTLESHIELD)
		sh.target = mo
		player.powers[pw_flashing] = 19
		
		//Screenshake
		if player == consoleplayer
			P_StartQuake(12 * FRACUNIT, 4)
		end
	end
end