local B = CBW_Battle
local G = B.GuardFunc
local CV = B.Console

local guardtics = 20
local guard_cooldown = TICRATE/2
local guard_iframe_time = TICRATE
local projectile_ignore_time = TICRATE

local nearground = function(mo,flip)
	if flip == 1
		return (mo.z-mo.floorz < mo.scale*8)
	else
		return (mo.ceilingz+mo.height-mo.z < mo.scale*8)
	end
end

B.GuardControl = function(player)
	if CV.Guard.value == 0 
	or G_TagGametype()
	or player.iseggrobo
	or player.isjettysyn
	or (player.powers[pw_flashing] and P_IsObjectOnGround(player.mo))
		player.canguard = false
	return end

	if B.GetSkinVarsFlags(player,SKINVARS_GUARD) then
		player.canguard = true
	else
		player.canguard = false
	end
end

B.Guard = function(player,buttonpressed)
	if not CV.parrytoggle.value return end
	local mo = player.mo
	local flip = P_MobjFlip(mo)
	local grounded = P_IsObjectOnGround(mo) or (player.guard and nearground(mo,flip))
	local latency = 0; -- Default to 0 for EXEs without cmd.latency. Thanks Lumyni.
	pcall(function()
		latency = player.cmd.latency;
	end);
	local latency2 = latency
	if mo and mo.valid and mo.guardflash then
		mo.colorized = false
		mo.color = player.skincolor
		mo.guardflash = false
	end
	if not(player.playerstate == PST_LIVE) or (player.spectator) then return end
	if P_PlayerInPain(player)
	or not grounded
	or not(player.canguard)
	or player.tumble
	or player.actionstate then
		if player.guard != 0 then
			if not(P_PlayerInPain(player)) and not(player.pflags&(PF_JUMPED|PF_SPINNING)) then
				mo.state = S_PLAY_FALL
				if player.shieldmobj ~= nil and player.shieldmobj.valid then
					P_RemoveMobj(player.shieldmobj)
				end
			end
			player.guard = 0
		end
		return
	end

	if player.guardcooldown == nil then
		player.guardcooldown = 0
	end

	if player.projectileignoretime == nil then
		player.projectileignoretime = 0
	end

	--Neutral
	if (player.guard == 0) then
		player.guardcooldown = max(0, $ - 1)
		player.projectileignoretime = max(0, $ - 1)
		if buttonpressed == 1 and player.guardcooldown == 0 then
			player.guard = 1
			-- play shield sound
			S_StartSoundAtVolume(mo,sfx_guard1, 100)
			player.guardtics = guardtics
			player.powers[pw_flashing] = 0
			if not(player.actionsuper) then
				player.actionstate = 0
			end
			local i = P_SpawnMobj(mo.x,mo.y,mo.z-FRACUNIT,MT_INSTASHIELD)
			i.fuse = guardtics - 1
			i.scale = 5*mo.scale/4
			i.colorized = true
			i.color = player.skincolor
			if i and i.valid then
				i.target = mo
			end
			player.shieldmobj = i	
		end
	end
	player.guardtics = $-1
	if player.guard != 0 and (player.followmobj) then
		P_SetMobjStateNF(player.followmobj,S_NULL)
	end
	local guardframe
	if B.SkinVars[player.skinvars].guard_frame != nil then
		guardframe = B.SkinVars[player.skinvars].guard_frame
	else
		guardframe = B.SkinVars[-1].guard_frame
	end
	
	if player.guard != 0 then
		if flip == 1 then
			mo.z = mo.floorz
		else
			mo.z = mo.ceilingz-mo.height
		end
	end
	
	if player.guard == 1 then
		mo.state = S_PLAY_STND
		mo.sprite2 = SPR2_TRNS
		mo.frame = guardframe
		player.powers[pw_nocontrol] = 2
		if player.guardtics < 1 then
			if latency < 10 then
				player.guardtics = 25 - (latency2*2)
			else
				player.guardtics = 25
			end
			player.guard = -1
		else
			mo.guardflash = player.guardtics&2
			if mo.guardflash then
				mo.colorized = true
				mo.color = SKINCOLOR_WHITE
			end
		end
	end

	if player.guard <= -1 then
		mo.frame = 0
		mo.state = S_PLAY_STND
		--mo.sprite2 = SPR2_TRNS
		--mo.frame = guardframe
		--player.powers[pw_nocontrol] = 2		
		mo.sprite2 = SPR2_STND

		--if player.guardtics < 1 then
		player.guard = 0
		player.guardcooldown = guard_cooldown
		--end
	end

	if player.guard == 2 then
-- 		mo.state = S_PLAY_STND
		player.powers[pw_nocontrol] = 0
		mo.sprite2 = SPR2_TRNS
		mo.frame = min(6,$+1)
		player.powers[pw_flashing] = TICRATE*3/4
		mo.flags2 = $&~MF2_DONTDRAW
		player.lockmove = true
-- 		if player.cmd.forwardmove or player.cmd.sidemove then
-- 			mo.sprite2 = SPR2_STAND
-- 			mo.frame = 0
-- 		end
		if player.guardtics < 1 then
			player.guard = 0
			mo.frame = 0
			mo.state = S_PLAY_STND
			mo.sprite2 = SPR2_STND
		end
	end
end

local fx = function(mo)
	for n = 0, 16
		local dust = P_SpawnMobj(mo.x,mo.y,mo.z,MT_DUST)
		if dust and dust.valid then
			P_InstaThrust(dust,mo.angle+ANGLE_22h*n,mo.scale*36)
		end
	end
end


--Successful guard action
B.GuardTrigger = function(target, inflictor, source, damage, damagetype)
	if not(target.valid and target.player) then return false end
	if target.player.guard > 0
		if B.SkinVars[target.player.skinvars].func_guard_trigger then
			B.SkinVars[target.player.skinvars].func_guard_trigger(target,inflictor,source,damage,damagetype)
		elseif B.SkinVars[-1].func_guard_trigger then
			B.SkinVars[-1].func_guard_trigger(target,inflictor,source,damage,damagetype)
		end
	return true end
end

--Standard parry trigger action
G.Parry = function(target, inflictor, source, damage, damagetype)
	if target.player.guard == 1 and inflictor and inflictor.valid then

		S_StartSound(target,sfx_rflct)
		S_StartSound(target,sfx_s259)
		target.player.guard = 2
		target.player.guardtics = 9
		target.player.powers[pw_flashing] = guard_iframe_time
		--B.ControlThrust(target,FRACUNIT/2)
		--Do graphical effects
		local sh = P_SpawnMobjFromMobj(target,0,0,0,MT_BATTLESHIELD)
		sh.target = target
		fx(target)

		target.player.guard = 0
		target.player.guardcooldown = guard_cooldown/2
		target.player.projectileignoretime = projectile_ignore_time

		--P_SpawnMobjFromMobj(inflictor,0,0,0,MT_EXPLODE)
		--Affect source
		if source and source.valid and source.health and source.player and source.player.powers[pw_flashing] then
			source.player.powers[pw_flashing] = 0
			local nega = P_SpawnMobjFromMobj(source,0,0,0,MT_NEGASHIELD)
			nega.target = source
		end

		--Affect attacker
		if inflictor.player then
			if inflictor.player.powers[pw_invulnerability] then
				inflictor.player.powers[pw_invulnerability] = 0
				P_RestoreMusic(inflictor.player)
			end
			local angle = R_PointToAngle2(target.x-target.momx,target.y-target.momy,inflictor.x-inflictor.momx,inflictor.y-inflictor.momy)
			local thrust = max(inflictor.player.speed/2, 17*inflictor.scale)
			if not P_IsObjectOnGround(inflictor) then
				inflictor.player.pflags = $|PF_THOKKED
			end
			--local zthrust = inflictor.momz/3
			----local thrust = FRACUNIT*10
			--if twodlevel then thrust = B.TwoDFactor($) end

			--P_Thrust(inflictor, angle, thrust)

			--P_SetObjectMomZ(inflictor,zthrust)

			--local speedpriority = B.GetSpeedPriority(inflictor.player)
			--if (inflictor.player.battle_atk > 2) or (inflictor.player.battle_satk > 2) then
			--if (inflictor.player.battle_atk > 2 and speedpriority == 2) or (inflictor.player.battle_satk > 2 and speedpriority == 2) then
				--B.DoPlayerTumble(inflictor.player, 40, angle, inflictor.scale*3, true, true)	-- prevent stun break
			--else
				B.DoPlayerInteract(inflictor, target)
				--if CV.GuardStun.value == 1 then
					--B.DoPlayerFlinch(inflictor.player, 5, thrust)
					--B.DoPlayerFlinch(inflictor.player, ((inflictor.player.speed*2)/(inflictor.scale*4)),thrust)
				--end
				P_Thrust(inflictor, angle, thrust)
			--end
		else
			P_DamageMobj(inflictor,target,target)
		end
	end
end


--flip instashield stuff if the player is flipped

B.InstaFlip = function(inst)
	if inst.target
		inst.eflags = ((inst.target.eflags & MFE_VERTICALFLIP) and ($1|MFE_VERTICALFLIP) or ($1 & ~MFE_VERTICALFLIP))
	end
end

B.BattleShieldThinker = function(mobj)
	if not mobj.target return end
	mobj.scale = FixedMul(skins[mobj.target.skin].shieldscale, mobj.target.scale*3/2)*2
	P_TeleportMove(mobj, mobj.target.x, mobj.target.y, mobj.target.z+(mobj.target.height/2))
	
	mobj.colorized = true
	mobj.color = SKINCOLOR_WHITE
	
	--After-effects
	local ghost = P_SpawnGhostMobj(mobj)
	if ghost and ghost.valid then
		--Rainbow flash
		ghost.colorized = true
		ghost.color = B.Choose(SKINCOLOR_WHITE,SKINCOLOR_YELLOW,SKINCOLOR_ROSY,SKINCOLOR_GREEN,SKINCOLOR_ORANGE,SKINCOLOR_BLUE,SKINCOLOR_PURPLE)
	end
end

B.NegaShieldThinker = function(mobj)
	if not mobj.target return end
	mobj.scale = FixedMul(skins[mobj.target.skin].shieldscale, mobj.target.scale*3/2)*2
	P_TeleportMove(mobj, mobj.target.x, mobj.target.y, mobj.target.z+(mobj.target.height/2))
	mobj.colorized = true
	mobj.color = SKINCOLOR_BLACK
	mobj.flags2 = $^^MF2_DONTDRAW
end
