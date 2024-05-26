local B = CBW_Battle
local state_sweep = 1
local state_dash = 2
local state_charging = 3
local state_didthrow = 4
local cooldown_swipe = TICRATE*7/5 --1.4s
local cooldown_dash = TICRATE*2
local cooldown_throw = cooldown_dash
local cooldown_cancel = TICRATE
local sideangle = ANG30 + ANG10
local throw_strength = 30
local throw_lift = 10
local thrustpower = 16
local threshold1 = TICRATE/3 --0.3s
local threshold2 = threshold1+(TICRATE*3/2) --minimum charging time + 1.5s
--local swipe_thrust = 15

B.Action.TailSwipe_Priority = function(player)
	local mo = player.mo
	if not (mo and mo.valid) return end
	
	if player.actionstate == state_charging
		B.SetPriority(player,0,0,nil,0,0,"tail sweep chargeup")
	elseif player.actionstate == state_sweep
		B.SetPriority(player,0,0,nil,0,0,"tail sweep")
	elseif player.actionstate == state_dash or player.actionstate == state_didthrow
		B.SetPriority(player,0,1,nil,0,1,"flight dash")
	end
end

B.cutterattract = function(mo, dimension)
	local followmo = mo.followmo
	local speed = mo.cutterspeed or followmo.scale
	if followmo[dimension] > mo[dimension] then
		if mo["mom" .. dimension] > followmo["mom" .. dimension] then
		   mo["mom" .. dimension] = $ + speed/2
		else
		   mo["mom" .. dimension] = $ + speed*2
		end
	elseif followmo[dimension] < mo[dimension] then
		if mo["mom" .. dimension] < followmo["mom" .. dimension] then
		   mo["mom" .. dimension] = $ - speed/2
		else
		   mo["mom" .. dimension] = $ - speed*2
		end
	end
end

B.Tails_PreCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if plr[n1] and plr[n1].valid and plr[n1].actionstate and plr[n1].playerstate == PST_LIVE
	and (B.MyTeam(mo[n1], mo[n2]) or not (atk[n2] > 2 or def[n2] > 2)) 
		plr[n1].tailsmarker = true
	end
end

B.Tails_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if not (plr[n1] and plr[n1].tailsmarker)
		return false
	end
	if plr[n2]
		if plr[n1].actionstate == state_dash
			plr[n1].actionstate = 0
			plr[n1].powers[pw_tailsfly] = TICRATE*5
			mo[n1].state = S_PLAY_FLY
			plr[n1].pflags = $ &~ (PF_JUMPED|PF_NOJUMPDAMAGE|PF_SPINNING|PF_STARTDASH)
			plr[n1].pflags = $|PF_CANCARRY
			P_SetOrigin(mo[n1],mo[n1].x,mo[n1].y,mo[n2].z+mo[n2].height)
			B.CarryState(plr[n1],plr[n2])
			P_SetObjectMomZ(mo[n1],FRACUNIT*7*P_MobjFlip(mo[n1]))
			S_StartSound(mo[n1], sfx_s3ka0)
			if not B.MyTeam(plr[n1], plr[n2])
				plr[n2].customstunbreaktics = TICRATE
				plr[n2].customstunbreakcost = 35
			end
			plr[n2].powers[pw_nocontrol] = max($,TICRATE/7)
			plr[n2].airdodge = -1
			return true
		elseif plr[n1].actionstate == state_sweep
			P_InstaThrust(mo[n2], angle[n2], mo[n1].scale*3)
			P_InstaThrust(mo[n1], angle[n1], mo[n1].scale*3)
		end
	end
end

B.Tails_PostCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if plr[n1] and plr[n1].tailsmarker
		plr[n1].tailsmarker = nil
		if (plr[n1].pflags & PF_CANCARRY)
			return true
		end
	end
end

local function sbvars(m,pmo)
	if m and m.valid then
		local chargepercentage = min(100,pmo.player.actiontime*100/threshold2)
		--local chargefactor = max(1,(10-chargepercentage/10))
		local thrustX = P_ReturnThrustX(m,pmo.angle,pmo.player.speed*3/2)
		local thrustY = P_ReturnThrustY(m,pmo.angle,pmo.player.speed*3/2)
		m.fuse = (threshold1/2)+(pmo.player.actiontime/5)
		m.cutterspeed = pmo.scale*(chargepercentage/2)
		--m.momx = ($/4) + ($/chargefactor)
		--m.momy = ($/4) + ($/chargefactor)
		S_StartSoundAtVolume(m,sfx_s3kb8,190)
	end
end

local function domissile(mo,thrustfactor)
	//Projectile
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle,0)
	sbvars(m,mo)
	//Do Side Projectiles
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle-sideangle,0)
	sbvars(m,mo)
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle+sideangle,0)
	sbvars(m,mo)
	//Do Extra Projectiles
	if mo.player.actiontime > threshold2
		local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle-sideangle/2,0)
		sbvars(m,mo)
		local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle+sideangle/2,0)
		sbvars(m,mo)
	end
	//Thrust
	if not(P_IsObjectOnGround(mo))
		P_InstaThrust(mo,mo.angle+ANGLE_180,thrustfactor*5)
	else
		P_Thrust(mo,mo.angle+ANGLE_180,thrustfactor*10)
	end
end

local function dodust(mo)
	if P_IsObjectOnGround(mo)
		local player = mo.player
		local dust = P_SpawnMobjFromMobj(mo,0,0,0,MT_DUST)
		P_InstaThrust(dust,player.drawangle,mo.scale*12)
	end
end

local function doaircutter(mo,thrustfactor)
	--Projectile
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle,0)
	sbvars(m,mo)
	mo.player.aircutter = m
	--Thrust
	--if not(P_IsObjectOnGround(mo)) then
		--P_InstaThrust(mo,mo.angle+ANGLE_180,thrustfactor)
	--else
		--P_Thrust(mo,mo.angle+ANGLE_180,thrustfactor)
	--end
end

local function uncolorize(mo)
	local player = mo.player
	mo.colorized = false
	mo.color = player.skincolor	
	if player.followmobj
		player.followmobj.colorized = false
		player.followmobj.color = player.skincolor
	end
end

addHook("PlayerThink", function(player)
	local mo = player.mo
	if not mo or not mo.valid then return end
	if mo.skin ~= "tails" then return end

	if player.gotflag or player.gotcrystal then
		player.actionstate = 0
		player.charability2 = CA2_SPINDASH
	end
end)

B.Action.TailSwipe = function(mo,doaction)
	local player = mo.player

	if (mo.eflags & MFE_SPRUNG)
	and player.actionstate
		uncolorize(mo)
		B.ResetPlayerProperties(player,true,false)
		return
	end

	if not(B.CanDoAction(player)) 
		if mo.state == B.GetSVSprite(player,1)
		or P_PlayerInPain(player)
			B.ResetPlayerProperties(player,false,true)
			uncolorize(mo)
		end
	return end
	
	local flying = player.panim == PA_ABILITY
	local carrying = false
	--[[
		!! IMPORTANT NOTE ABOUT OPTIMIZATION:
		basically, the for block below makes every tails run through every single player
		in every single frame JUST to check which player is being grabbed by him.
		sounds pretty bad, right? but then consider the fact that we're also doing several
		IF statements in each one of them.
		with this in mind, this can be optimized in a number of ways. have this checklist:
		- [x] only run the search function at all that if he's flying (can't be carrying otherwise)
		- [x] change the order of the if statements by how rare they are, so it checks less on average
		- [ ] use a searchblockmap function instead of iterating through all players
		thank you for your attention
		~lumyni
		]]
	if flying
		--carrying = tailspartnerdetect(mo) --maybe we can move the block below to a separate function?
		for otherplayer in players.iterate
			if otherplayer.powers[pw_carry] == CR_PLAYER
			and otherplayer.mo and otherplayer.mo.valid
			and otherplayer.mo.tracer == mo
				carrying = true
				player.actioncooldown = min($,cooldown_cancel)
				//If not friendly
				if not B.MyTeam(otherplayer.mo,mo)
					//gameplay
					otherplayer.airdodge = -1
					otherplayer.jumpstasistimer = 2 --because giving PF_JUMPSTASIS doesnt work apparently
					otherplayer.landlag = otherplayer.powers[pw_nocontrol]
					if (otherplayer.realbuttons & BT_JUMP)
					and not (otherplayer.powers[pw_nocontrol] or (player.buttonhistory & BT_JUMP))
					then
						S_StartSound(otherplayer.mo, sfx_s3kd7s)
						otherplayer.customstunbreakcost = max(0,$-5)
						otherplayer.powers[pw_nocontrol] = max($,TICRATE/2)
						otherplayer.canstunbreak = 0
					else
						otherplayer.canstunbreak = max($,2)
					end
					//pain animation
					if otherplayer.followmobj
						if otherplayer.mo.skin == "tails"
							otherplayer.followmobj.state = S_TAILSOVERLAY_PAIN
						elseif otherplayer.mo.skin == "tailsdoll"
							P_SetMobjStateNF(otherplayer.followmobj,S_NULL)
						end
					end
					otherplayer.mo.state = S_PLAY_PAIN
				end
				break
			end
		end
	end
	
	local chargepercentage = min(100,player.actiontime*100/threshold2)
	if player.actionstate == state_charging
		player.action2text = "Preparing attack "..chargepercentage.."%"
	end
	
	//Action triggers
	local attackready = (player.actiontime >= threshold1 and player.actionstate == state_charging)
	--local charging = ((not(attackready)) and player.actionstate == state_charging)
	local swipetrigger = attackready and (player.actiontime > threshold2*2 or B.ButtonCheck(player,player.battleconfig_special) == 0)
	local chargehold = (attackready and B.PlayerButtonPressed(player,player.battleconfig_special,true))
	local canceltrigger =
		not swipetrigger
		and player.actionstate == state_charging
		and doaction == 2
		and B.PlayerButtonPressed(player,player.battleconfig_guard,false)
	--local swipetrigger = (player.actionstate == 0 and doaction == 1 and not(flying or carrying))
	local thrusttrigger = (player.actionstate == 0 and doaction == 1 and flying and not(carrying))
	local throwtrigger = (player.actionstate == 0 and doaction == 1 and carrying)
	local chargetrigger = (player.actionstate == 0 and doaction == 1 and not (flying or carrying))
	local buffer = (player.cmd.buttons&player.battleconfig_special)

	//Get thrust speed multiplier
	local thrustfactor = mo.scale
	if mo.eflags&MFE_UNDERWATER
		thrustfactor = $>>1
	end
	if mo.flags2&MF2_TWOD or twodlevel
		thrustfactor = $>>1
	end
	
	player.actionrings = 10
	if not(flying or player.actionstate == state_dash) then
		player.actiontext = "Tail Sweep"
	elseif not(carrying)
		player.actiontext = "Flight Dash"
	else
		player.actionrings = 0
		player.actiontext = "Power Throw"
	end
	
	if player.actionstate != 0 then
		player.actiontime = $+1
		--player.exhaustmeter = FRACUNIT
		player.actionbuffer = true
	elseif player.actionbuffer
		player.actiontime = 0
		player.actionbuffer = false
		uncolorize(mo)
		if P_IsObjectOnGround(mo) then
			player.pflags = $ &~ PF_JUMPED
		end
		if player.powers[pw_shield] == SH_WHIRLWIND
		and not player.powers[pw_tailsfly]
			player.pflags = $|PF_SHIELDABILITY
		end
	end
	
	//Intercepted while charging
	if (player.actionstate == state_charging or player.actionstate == state_sweep) and player.powers[pw_nocontrol] then
		player.actionstate = 0
		B.ApplyCooldown(player,cooldown_cancel)
		uncolorize(mo)
		return
	end
	
	//Start charging attack
	if chargetrigger
		B.PayRings(player,player.actionrings)
		player.actionstate = state_charging
		player.actiontime = 0
		--player.exhaustmeter = FRACUNIT
		player.pflags = $&~(PF_SPINNING|PF_SHIELDABILITY)
		player.canguard = false
	--	S_StartSound(mo,sfx_charge)
		if not(P_IsObjectOnGround(mo))
			P_SetObjectMomZ(mo,mo.momz-(mo.momz/3),false)
		end
		local spark = P_SpawnMobj(mo.x,mo.y,mo.z+mo.height/2,MT_SUPERSPARK)
	end
	
	//Charging attack
	if charging or chargehold then
		local ang = (1+chargepercentage*ANG1)/3
		local spdrange = (1+player.speed)/(3*mo.scale)
		local chargerange = (1+chargepercentage)/16
		local range = spdrange + chargerange
		//Do aim sights
		player.canguard = false
		player.pflags = $&~(PF_SPINNING)
		--player.exhaustmeter = max(0,$-(FRACUNIT/TICRATE/2))

		//Speed Cap
		local speed = FixedHypot(mo.momx,mo.momy)
		if speed > mo.scale and player.actiontime >= threshold1 then
			local dir = R_PointToAngle2(0,0,mo.momx,mo.momy)
			P_InstaThrust(mo,dir,FixedMul(speed,mo.friction))
			if P_IsObjectOnGround(mo) and player.actiontime > threshold2 then
				mo.momx = $/2
				mo.momy = $/2
			end
		end
		
		//Do "skidding" effects
		if P_IsObjectOnGround(mo) and leveltime%3 == 1 and player.speed > 3*mo.scale then
			S_StartSound(mo,sfx_s3k7e)
			local r = mo.radius/FRACUNIT
			local dust = P_SpawnMobj(
				P_RandomRange(-r,r)*FRACUNIT+mo.x,
				P_RandomRange(-r,r)*FRACUNIT+mo.y,
				mo.z,
				MT_DUST
			)
			if dust and dust.valid then dust.scale = mo.scale end
		end
		
		//Powerup
		if chargehold then	
			if (player.actiontime%6 < 2) then
				mo.colorized = true
				if player.actiontime%4 == 1
					mo.color = SKINCOLOR_SUPERGOLD3
				else
					mo.color = SKINCOLOR_SUPERGOLD5
				end
				if player.followmobj
					player.followmobj.colorized = true
					player.followmobj.color = SKINCOLOR_SUPERGOLD5
				end
			else
				uncolorize(mo)
			end
			if player.actiontime == threshold2 then
				S_StartSound(mo,sfx_s1c3)
				for l = 0,8
					P_SpawnParaloop(mo.x,mo.y,mo.z+mo.height/2,256*mo.scale,16,MT_NIGHTSPARKLE,mo.angle+45*l*ANG1,nil,1)
				end
			end
		end
		player.actionsuper = true
	end
	
	//Unable to charge
	if canceltrigger then
		B.ResetPlayerProperties(player,false,false)
		player.actiontime = -1
		S_StartSound(mo,sfx_s3k7d)
		B.ApplyCooldown(player,cooldown_cancel)
		uncolorize(mo)
		player.guardbuffer = -1
	end
	
	//Charging frame
	if player.actionstate == state_charging then
		mo.state = S_PLAY_EDGE
		player.pflags = $|PF_SPINDOWN|PF_THOKKED&~PF_NOJUMPDAMAGE
		player.actionsuper = true
		if not (P_IsObjectOnGround(mo) or B.WaterFactor(mo) > 1) then
			P_SetObjectMomZ(mo,gravity/2,true) //Low grav
		end
		//post vfx
		local g = P_SpawnGhostMobj(player.mo)
		g.colorized = true
		g.color = SKINCOLOR_SUPERGOLD5
		g.tics = 1
		g.frame = ($ & ~FF_TRANSMASK) | FF_TRANS70
		g.scale = $ * 8/7
		if g.tracer then
			g.tracer.colorized = true
			g.tracer.color = SKINCOLOR_SUPERGOLD5
			g.tracer.tics = 1
			g.tracer.frame = ($ & ~FF_TRANSMASK) | FF_TRANS70
			g.tracer.scale = $ * 8/7
		end
	elseif (player.actiontime == -1) then
		player.actiontime = 0
	end
	
	//Activate swipe
	if swipetrigger then
		--Set state
		player.actionstate = state_sweep
		--player.pflags = $&~(PF_THOKKED)
		--player.pflags = $&~(PF_SPINNING)
		--Missile attack
		--domissile(mo,thrustfactor)
		doaircutter(mo, 0)
		player.actiontime = 0
		if player.aircutter and player.aircutter.valid then
			--player.aircutter.momx = 0
			--player.aircutter.momy = 0
			player.aircutter_distance = 0
			player.aircutter.scale = 5*mo.scale/4
			--local aircutter_speed = 50*mo.scale
			--P_Thrust(player.aircutter, mo.angle, aircutter_speed)
		end
		
		--Physics
		--if not(P_IsObjectOnGround(mo))
			--P_SetObjectMomZ(mo,FRACUNIT*5,false)
		--end
		--Effects
		uncolorize(mo)
		P_SpawnParaloop(mo.x,mo.y,mo.z,mo.scale*64,12,MT_DUST,ANGLE_90,nil,true)
		--if P_IsObjectOnGround(mo) then
			--P_Thrust(mo, mo.angle, swipe_thrust*mo.scale)
		--elseif player.speed < player.normalspeed then
			--P_Thrust(mo, mo.angle, 10*mo.scale)
		--end
		S_StartSound(mo,sfx_spdpad)
		--S_StartSoundAtVolume(mo,sfx_swing, 120)
		B.ApplyCooldown(player,cooldown_swipe)
	end

	//Activate thrust
	if thrusttrigger
		B.PayRings(player)
		--B.ApplyCooldown(player,cooldown_dash)
		//Set state
		player.powers[pw_tailsfly] = 0
		player.pflags = ($|PF_JUMPED|PF_THOKKED)
		player.actionstate = state_dash
		player.actiontime = 0
		mo.state = S_PLAY_ROLL
		//Physics
		P_Thrust(mo,mo.angle,thrustfactor*thrustpower)
		P_SetObjectMomZ(mo,FRACUNIT*3,false)
		//Effects
		local radius = mo.radius/FRACUNIT
		local height = mo.height/FRACUNIT
		local r1 = do
			return P_RandomRange(-radius,radius)*FRACUNIT
		end
		local r2 = do
			return P_RandomRange(0,height)*FRACUNIT
		end
		for n = 1,16
			P_SpawnMobjFromMobj(mo,r1(),r1(),r2(),MT_DUST)
		end
		S_StartSound(mo,sfx_zoom)
	end
	
	//Activate throw
	if throwtrigger 
		B.PayRings(player)
		B.ApplyCooldown(player,cooldown_throw)
		//Set state
		player.powers[pw_tailsfly] = 0
		player.pflags = ($|PF_JUMPED|PF_THOKKED)
		player.actionstate = state_didthrow
		player.actiontime = 0
		mo.state = S_PLAY_ROLL
	
		//Throw Partner
		for otherplayer in players.iterate
			if not(
				otherplayer.mo and otherplayer.mo.valid
				and otherplayer.mo.tracer == mo
				and otherplayer.powers[pw_carry] == CR_PLAYER
			)
				continue
			end
			otherplayer.pushed_creditplr = player
			otherplayer.tailsthrown = player
			otherplayer.powers[pw_carry] = 0
			otherplayer.pflags = $|PF_SPINNING|PF_THOKKED
			local partner = otherplayer.mo
			partner.tracer = nil
			partner.state = S_PLAY_ROLL
			local spd = max(throw_strength,1+player.speed/FRACUNIT)
			P_InstaThrust(partner,mo.angle,thrustfactor*spd)
			partner.momx = $ + mo.momx/2
			partner.momy = $ + mo.momy/2
			partner.momz = throw_lift*mo.scale*P_MobjFlip(mo) + mo.momz/2
			if B.MyTeam(player, otherplayer) == false
				otherplayer.airdodge = -1
				otherplayer.actioncooldown = max($,2*TICRATE)
				B.PlayerCreditPusher(otherplayer,player)
				otherplayer.customstunbreakcost = $ and min($+15,35) or 35
			end
			otherplayer.powers[pw_nocontrol] = 0
			otherplayer.landlag = 0
		end
-- 		//Free carry ID
-- 		player.carry_id = nil
		
		//Physics
		if not(P_IsObjectOnGround(mo))
			P_SetObjectMomZ(mo,FRACUNIT*5,false)
		end
		//Effects
		P_SpawnParaloop(mo.x,mo.y,mo.z,mo.scale*64,12,MT_DUST,ANGLE_90,nil,true)
		S_StartSound(mo,sfx_spdpad)
	end
	
	//Swipe state
	if player.actionstate == state_sweep then
		B.analogkill(player, 2)
		player.laststate = state_sweep
		--if P_IsObjectOnGround(mo)
			--player.lockaim = true
		--end
		--player.lockmove = true
		player.pflags = $|PF_THOKKED|PF_SPINDOWN
		player.pflags = $&~(PF_SPINNING)
		player.charability2 = CA2_NONE
		--S_StopSoundByID(mo, sfx_spin)

		-- aircutter circling thingy
		if player.aircutter and player.aircutter.valid then
			player.pflags = $ | PF_STASIS
			local distancescaling = player.aircutter.cutterspeed/2
			local boomerangtime = max(6,distancescaling*2/3/FRACUNIT)
			--this is taking into account that swipe actiontime lasts like 22 frames
			if player.actiontime > boomerangtime then
				player.aircutter_distance = max(1,$-distancescaling)
			else
				player.aircutter_distance = $+distancescaling
			end
			local angle = ANGLE_45 * player.actiontime
			local cut_x = FixedMul(player.aircutter_distance, cos(angle))
			local cut_y = FixedMul(player.aircutter_distance, sin(angle))
			local refmobj = P_SpawnMobj(0,0,0,MT_THOK)
			refmobj.flags2 = $ | MF2_DONTDRAW
			P_SetOrigin(refmobj, mo.x + cut_x, mo.y + cut_y, mo.z + (mo.height/2))
			player.aircutter.followmo = refmobj
			B.cutterattract(player.aircutter, "x")
			B.cutterattract(player.aircutter, "y")
			player.aircutter.momz = 0
			P_MoveOrigin(player.aircutter, player.aircutter.x, player.aircutter.y, mo.z + (mo.height/2))
		end

-- 		player.powers[pw_nocontrol] = $|2
		--Anim states


		-- aim assist
		--if player.actiontime < 6 then
			--mo.target = P_LookForEnemies(player, true)

			--if mo.target and mo.target.valid then
				--local dir = R_PointToAngle2(mo.x, mo.y, mo.target.x, mo.target.y)
				--local dist = R_PointToDist2(mo.x, mo.y, mo.target.x, mo.target.y)
				--if dir and dist <= 100*mo.scale then
					--P_Thrust(mo, dir, 5*mo.scale)
				--end

			--end
		--end
		if player.actiontime < 6 then


			--Fast Spin anim
			player.drawangle = mo.angle-ANGLE_90*(player.actiontime-4)
			B.DrawSVSprite(player,1)
			P_SetMobjStateNF(player.followmobj,S_NULL)
			dodust(mo)
		elseif player.actiontime < 12 then
			--Medium Spin anim
			player.drawangle = mo.angle-ANGLE_45*(player.actiontime-4)
			B.DrawSVSprite(player,1)
			P_SetMobjStateNF(player.followmobj,S_NULL)
			dodust(mo)
		else
			--Teeter anim
			player.drawangle = mo.angle-ANGLE_45/2*(player.actiontime-4)
			mo.state = S_PLAY_EDGE
			mo.frame = 0
			mo.tics = 0
			--player.pflags = $&~(PF_SPINNING)
		end
		
		-- if we were interrupted mid swipe, we can actually reset our values
		-- they otherwise would be stuck, because we no longer were in the swipe state, 
		-- the code resetting the player's flags doesn't get called
		if player.laststate == state_sweep and player.actionstate ~= state_sweep then
			player.laststate = 0
			player.pflags = $ & ~(PF_THOKKED)
			--player.pflags = $ & ~(PF_FULLSTASIS)
			--player.pflags = $&~(PF_SPINNING)
			if P_IsObjectOnGround(mo) then
				player.pflags = $&~(PF_JUMPED)
			end

			player.pflags = $&~(PF_SPINNING)
			player.drawangle = mo.angle
			--mo.state = S_PLAY_WALK
			mo.frame = 0
			mo.radius = radius
			if P_IsObjectOnGround(mo) then
				player.actionstate = 0
				player.drawangle = mo.angle
				mo.state = S_PLAY_WALK
				mo.frame = 0
			end
			player.actionstate = 0
		end
		
		--Reset to neutral
		if player.actiontime >= 22 then
			player.pflags = $&~(PF_THOKKED|PF_SPINNING)
			--player.pflags = $&~PF_FULLSTASIS
			player.drawangle = mo.angle
			mo.frame = 0
			if P_IsObjectOnGround(mo) then
				player.actionstate = 0
				player.drawangle = mo.angle
				mo.state = S_PLAY_WALK
				mo.frame = 0
				player.pflags = $&~PF_JUMPED
			else
				mo.state = S_PLAY_SPRING
				player.pflags = $|PF_JUMPED
			end
			player.actionstate = 0
			player.laststate = 0
		end
		--if player.pflags & PF_SPINNING then
			--print("spinning for some reason lol")
		--end
		--print(player.actiontime)
	else
		player.charability2 = CA2_SPINDASH
	end
	//Thrust state
	if player.actionstate == state_dash or player.actionstate == state_didthrow
		B.analogkill(player, 2)
		if player.actionstate == state_dash
			player.mo.cantouchteam = 1
		end
		if player.followmobj then P_SetMobjStateNF(player.followmobj,S_NULL) end
		if not B.DrawSVSprite(player,1) then mo.state = S_PLAY_EDGE end
--		player.actiontime = $+1
		player.drawangle = mo.angle-ANG60*player.actiontime
-- 		P_SpawnGhostMobj(mo)
		local radius = mo.radius/FRACUNIT
		local height = mo.height/FRACUNIT
		local r1 = do
			return P_RandomRange(-radius,radius)*FRACUNIT
		end
		local r2 = do
			return P_RandomRange(0,height)*FRACUNIT
		end
		local s = P_SpawnMobjFromMobj(mo,r1(),r1(),r2(),MT_SPARK)
		s.colorized = true
		s.color = SKINCOLOR_WHITE
		s.scale = $/3
		s.momx = mo.momx/2
		s.momy = mo.momy/2
		s.momz = mo.momz/2
		s.flags2 = $|MF2_SHADOW
		player.canguard = 2
		player.guardtext = "Cancel"
		//Reset to neutral
		if P_IsObjectOnGround(mo)
		or B.PlayerButtonPressed(player,player.battleconfig_guard,false)
		then
			player.actionstate = 0
			player.drawangle = mo.angle
			player.pflags = $|PF_JUMPSTASIS
			mo.state = S_PLAY_WALK
			mo.frame = 0
			if not P_IsObjectOnGround(mo) then
				S_StartSound(mo,sfx_s251)
				B.ResetPlayerProperties(player,false,false)
				player.airdodgebuffer = true
				P_SpawnGhostMobj(mo)
			else
				B.ApplyCooldown(player,cooldown_dash)
			end
		end
	end
end
