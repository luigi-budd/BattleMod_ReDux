local B = CBW_Battle
local CV = B.Console

local intangible_time = 14
local dodge_endlag = TICRATE
local dodge_momz = 7
local dodge_thrust = 15

B.AirDodge = function(player)
	if not B return end
	if not (player and player.valid and player.mo and player.mo.valid)
		return
	end
	local mo = player.mo
	
	if B.ButtonCheck(player, player.battleconfig_guard) == 1 
		if not P_PlayerInPain(player)
			and player.mo.state != S_PLAY_PAIN
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
			player.airdodge_spin = ANGLE_90 + ANG10
			
			//State and flags
			B.ResetPlayerProperties(player,false,false)
			mo.state = S_PLAY_FALL
			player.airgun = false
			
			//Launch
			local momz = dodge_momz*FRACUNIT/B.WaterFactor(mo)
			P_SetObjectMomZ(mo, momz, false)
			if neutral
				mo.momx = $ / 2
				mo.momy = $ / 2
			else
				P_InstaThrust(mo,angle,mo.scale*dodge_thrust)
			end
			player.drawangle = mo.angle
			
			//SFX
			S_StartSound(mo, sfx_s3k47)
			S_StartSoundAtVolume(mo, sfx_nbmper, 120)
			
			//Sparkle
			local sparkle = P_SpawnMobj(mo.x,mo.y,mo.z,MT_SUPERSPARK)
			sparkle.scale = mo.scale * 5/4
			sparkle.destscale = 0
			sparkle.momx = mo.momx / 2
			sparkle.momy = mo.momy / 2
			sparkle.momz = mo.momz * 2/3
		else
			S_StartSound(nil, sfx_s3k8c, player)
		end
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
			if player.airdodge <= intangible_time
				if (player.airdodge % 4) == 3
					mo.colorized = true
					mo.color = SKINCOLOR_WHITE
					mo.airdodgecolor = true
					P_SpawnGhostMobj(mo)
				elseif (player.airdodge % 4) != 1
					mo.colorized = true
					mo.color = SKINCOLOR_SILVER
					mo.airdodgecolor = true
				else
					mo.colorized = false
					mo.color = player.skincolor
					mo.airdodgecolor = false
				end
			else
				mo.colorized = false
				mo.color = player.skincolor
				mo.airdodgecolor = false
			end
			if player.airdodge > dodge_endlag
				player.airdodge = -1
				player.lockmove = false
				player.drawangle = mo.angle
			else
				player.airdodge_spin = $ + ANGLE_90 + ANG15 - (ANG1*3 * player.airdodge)
				player.drawangle = mo.angle + player.airdodge_spin
			end
		end
	elseif mo.airdodgecolor
		mo.colorized = false
		mo.color = player.skincolor
		mo.airdodgecolor = false
	end
	
	if (player.airdodge > 0 and player.airdodge <= intangible_time)
		player.intangible = true
	else
		player.intangible = false
	end
end