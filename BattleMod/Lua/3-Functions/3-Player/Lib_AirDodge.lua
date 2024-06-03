local B = CBW_Battle
local CV = B.Console

local intangible_time = TICRATE*4/5
local dodge_endlag = TICRATE
local dodge_momz = 5
local dodge_thrust = 15

B.AirDodge = function(player)
	if not (CV.airtoggle.value and player and player.valid and player.mo and player.mo.valid)
		return
	end
	local mo = player.mo
	
	local intangible_time_real = intangible_time
	if not player.safedodge then
		intangible_time_real = intangible_time/2
	end
	
	if B.ButtonCheck(player, player.battleconfig_guard) == 1
		and (CV.Guard.value)
		and player.canguard
		and player.mo.state != S_PLAY_PAIN
		and player.mo.state != S_PLAY_STUN
		and player.airdodge == 0
		and player.playerstate == PST_LIVE
		and not player.exiting
		and not player.actionstate
		and not player.climbing
		and not player.armachargeup
		and not player.isjettysyn
		and not player.revenge
		and not player.powers[pw_nocontrol]
		and not player.powers[pw_carry]
		and not P_IsObjectOnGround(mo)
		
		local angle = B.GetInputAngle(player)
		
		if player.battleconfig_dodgecamera or (R_PointToDist2(0, 0, player.cmd.forwardmove, player.cmd.sidemove) <= 10)
			angle = mo.angle
		end
		
		player.airdodge = 1
		player.airdodge_spin = ANGLE_90 + ANG10
		if not(player.dodgecooldown)
			player.safedodge = true
		else
			player.safedodge = false
		end
		player.dodgecooldown = CV.dodgetime.value*TICRATE
		
		//State and flags
		B.ResetPlayerProperties(player,false,false)
		mo.state = S_PLAY_FALL
		player.airgun = false
		
		if (player.powers[pw_shield] & SH_NOSTACK) == SH_WHIRLWIND
			player.pflags = $ | PF_SHIELDABILITY
		end
		
		//Release carried player
		for otherplayer in players.iterate
			local partner = otherplayer.mo
			if not(
				partner and partner.valid
				and partner.tracer == mo
				and otherplayer.powers[pw_carry] == CR_PLAYER
			)
				continue
			end
			partner.tracer = nil
			otherplayer.powers[pw_carry] = 0
			B.ResetPlayerProperties(otherplayer, true, false)
		end
		
		//Launch
		local dodge_momz_real = dodge_momz*mo.scale/B.WaterFactor(mo)
		local dodge_thrust_real = mo.scale*dodge_thrust
		if player.gotflagdebuff
			dodge_thrust_real = $ * 3/4
			dodge_momz_real = $ / 2
		end
		
		local diff = dodge_momz_real - (mo.momz*P_MobjFlip(mo))
		if (diff > 0)
			mo.momz = dodge_momz_real*P_MobjFlip(mo)
		else
			mo.momz = (dodge_momz_real - diff/2)*P_MobjFlip(mo)
		end
		
		mo.momx = $ / 7
		mo.momy = $ / 7
		//if not neutral
			P_Thrust(mo,angle,dodge_thrust_real)
		//end
		player.drawangle = mo.angle
		
		//SFX
		S_StartSound(mo, sfx_s3k47)
		S_StartSoundAtVolume(mo, sfx_nbmper, 125)
		
		//Sparkle
		local sparkle = P_SpawnMobj(mo.x,mo.y,mo.z,MT_SUPERSPARK)
		sparkle.scale = mo.scale
		sparkle.destscale = 0
		if AST_ADD
			sparkle.blendmode = AST_ADD
		end
		sparkle.momx = mo.momx / 2
		sparkle.momy = mo.momy / 2
		sparkle.momz = mo.momz * 2/3
	end
	
	//Airdodge is in progress
	if player.airdodge != 0
		B.analogkill(player, 2)
		if player.isjettysyn
			or player.powers[pw_carry]
			or P_PlayerInPain(player)
			or P_IsObjectOnGround(mo)
			
			player.airdodge = 0
			player.pflags = $ & ~PF_FULLSTASIS

		elseif player.airdodge > 0
			player.airdodge = $ + 1
			if not player.safedodge then
				player.pflags = $ | PF_FULLSTASIS
			end
			if player.airdodge <= intangible_time_real
				if (player.airdodge % 4) == 3
					mo.colorized = true
					mo.color = SKINCOLOR_WHITE
					mo.airdodgecolor = true
					if player.safedodge then
						local g = P_SpawnGhostMobj(mo)
						if AST_ADD
							g.blendmode = AST_ADD
						end
					end
				elseif (player.airdodge % 4) != 1
					mo.colorized = true
					mo.color = SKINCOLOR_SILVER
					if player.followmobj then player.followmobj.color = mo.color end
					mo.airdodgecolor = true
				else
					mo.colorized = false
					mo.color = player.skincolor
					if player.followmobj then player.followmobj.color = mo.color end
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
	
	local skin = skins[player.mo.skin]
	if (player.airdodge > 0 and player.airdodge <= intangible_time_real)
		player.intangible = true
		player.thrustfactor = skin.thrustfactor+5
		player.normalspeed = skin.normalspeed/2
	else
		player.intangible = false
		player.thrustfactor = skin.thrustfactor
		player.normalspeed = skin.normalspeed
	end
end