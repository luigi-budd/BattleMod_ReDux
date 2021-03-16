local B = CBW_Battle
local CV = B.Console

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


B.AirDodge = function(player)
	if not B return end
	if not (player and player.valid and player.mo and player.mo.valid) or P_PlayerInPain(player) or player.mo.state == S_PLAY_PAIN
		return
	end
	local mo = player.mo
	
	if buttoncheck(player, player.battleconfig_guard) == 1
		and player.airdodge == 0
		and player.playerstate == PST_LIVE
		and not player.exiting
		and not player.actionstate
		and not player.climbing
		and not player.armachargeup
		and not player.powers[pw_nocontrol]
		and not P_IsObjectOnGround(mo)
		
		local angle = R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
		angle = $ + (player.cmd.angleturn << FRACBITS)
		
		local neutral = (R_PointToDist2(0, 0, player.cmd.forwardmove, player.cmd.sidemove) <= 10)
		
		player.airdodge = 1
		player.airdodge_spin = ANGLE_180
		
		//State and flags
		B.ResetPlayerProperties(player,false,false)
		mo.state = S_PLAY_FALL
		player.airgun = false
		
		//Launch
		local momz = 7*FRACUNIT/B.WaterFactor(mo)
		P_SetObjectMomZ(mo, momz, false)
		if neutral
			mo.momx = $ / 2
			mo.momy = $ / 2
		else
			P_InstaThrust(mo,angle,mo.scale*15)
		end
		player.drawangle = mo.angle
		
		//SFX
		S_StartSound(mo, sfx_s3k47)
		S_StartSoundAtVolume(mo, sfx_nbmper, 120)
	end
	
	if player.airdodge != 0
		if player.isjettysyn
			or player.powers[pw_carry]
			or P_PlayerInPain(player)
			or P_IsObjectOnGround(mo)
			
			player.airdodge = 0
			player.lockmove = false
			
		elseif player.airdodge > 0
			player.lockmove = true
			player.airdodge = $ + 1
			if player.airdodge < 15
				player.powers[pw_flashing] = max($, 1)
				if not (player.airdodge % 3)
					mo.colorized = true
					mo.color = SKINCOLOR_WHITE
					mo.airdodgecolor = true
				else
					mo.colorized = false
					mo.color = player.skincolor
					mo.airdodgecolor = false
				end
				if (player.airdodge % 4)
					P_SpawnGhostMobj(mo)
				end
			end
			if player.airdodge > TICRATE
				player.airdodge = -1
				player.lockmove = false
			end
			
			player.airdodge_spin = $ + ANGLE_90 - (ANG1*3 * player.airdodge)
			player.drawangle = mo.angle + player.airdodge_spin
		end
	elseif mo.airdodgecolor
		mo.colorized = false
		mo.color = player.skincolor
		mo.airdodgecolor = false
	end
end