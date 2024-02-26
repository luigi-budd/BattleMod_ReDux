local B = CBW_Battle
local state_swipe = 1
local state_thrust = 2
local cooldown_swipe = TICRATE*5/2
local cooldown_dash = TICRATE*3/2
local cooldown_throw = cooldown_dash
local sideangle = ANG30 + ANG10
local throw_strength = 30
local throw_lift = 10
local thrustpower = 16

B.Action.TailSwipe_Priority = function(player)
	local mo = player.mo
	if not (mo and mo.valid) return end
	
	if player.actionstate == state_swipe
		B.SetPriority(player,1,1,nil,1,1,"tail swipe")
	elseif player.actionstate == state_thrust
		B.SetPriority(player,0,2,nil,0,2,"flight dash")
	end
end

B.Tails_PreCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if plr[n1] and plr[n1].valid and plr[n1].actionstate and plr[n1].playerstate == PST_LIVE
	and (B.MyTeam(mo[n1], mo[n2]) or not (atk[n2] or def[n2]))
		plr[n1].tailsmarker = true
	end
end

B.Tails_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if not (plr[n1] and plr[n1].tailsmarker)
		return false
	end
	if ((hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2))
	and plr[n2]
		if plr[n1].actionstate == state_thrust
			plr[n1].actionstate = 0
			plr[n1].powers[pw_tailsfly] = TICRATE*5
			mo[n1].state = S_PLAY_FLY
			plr[n1].pflags = $ &~ (PF_JUMPED|PF_NOJUMPDAMAGE|PF_SPINNING|PF_STARTDASH)
			plr[n1].pflags = $|PF_CANCARRY
			P_TeleportMove(mo[n1],mo[n1].x,mo[n1].y,mo[n2].z+mo[n2].height)
			B.CarryState(plr[n1],plr[n2])
			P_SetObjectMomZ(mo[n1],FRACUNIT*7*P_MobjFlip(mo[n1]))
			S_StartSound(mo[n1], sfx_s3ka0)
			if not B.MyTeam(plr[n1], plr[n2])
				plr[n2].powers[pw_nocontrol] = max($,20)
			end
			plr[n2].airdodge = -1
			return true
		elseif plr[n1].actionstate == state_swipe
			B.DoPlayerTumble(plr[n2], 24, angle[n1], mo[n1].scale*3, true)
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
		m.fuse = 24
		m.momx = $ + pmo.momx/2
		m.momy = $ + pmo.momy/2
		S_StartSoundAtVolume(m,sfx_s3kb8,190)
	end
end

local function domissile(mo,thrustfactor)
	//Projectile
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle+sideangle,0)
	sbvars(m,mo)
	//Do Side Projectiles
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle-sideangle,0)
	sbvars(m,mo)
	local m = P_SPMAngle(mo,MT_SONICBOOM,mo.angle,0)
	sbvars(m,mo)
	//Thrust
	if not(P_IsObjectOnGround(mo))
		P_Thrust(mo,mo.angle+ANGLE_180,thrustfactor*5)
	else
		P_Thrust(mo,mo.angle+ANGLE_180,thrustfactor*8)
	end
end

local function dodust(mo)
	if P_IsObjectOnGround(mo)
		local player = mo.player
		local dust = P_SpawnMobjFromMobj(mo,0,0,0,MT_DUST)
		P_InstaThrust(dust,player.drawangle,mo.scale*12)
	end
end

B.Action.TailSwipe = function(mo,doaction)
	local player = mo.player
	if not(B.CanDoAction(player)) 
		if mo.state == B.GetSVSprite(player,1)
			B.ResetPlayerProperties(player,false,true)
		end
	return end
	
	local flying = player.panim == PA_ABILITY
	local carrying = false
	for otherplayer in players.iterate
		if otherplayer.mo and otherplayer.mo.valid
		and otherplayer.mo.tracer == mo
		and otherplayer.powers[pw_carry] == CR_PLAYER
			carrying = true
			player.actioncooldown = min($,5)
			//If not friendly
			if not B.MyTeam(otherplayer.mo,mo)
				//gameplay
				otherplayer.airdodge = -1
				otherplayer.landlag = otherplayer.powers[pw_nocontrol]
				if not (otherplayer.actioncooldown)
					otherplayer.airdodge = 0
				end
				if otherplayer.powers[pw_nocontrol]
				and (otherplayer.cmd.buttons & BT_JUMP)
				and not (otherplayer.buttonhistory & BT_JUMP)
				then
					S_StartSound(otherplayer.mo, sfx_s3kd7s)
				end
				//pain animation
				otherplayer.mo.state = S_PLAY_PAIN
				if otherplayer.followmobj
					if otherplayer.mo.skin == "tails"
						otherplayer.followmobj.state = S_TAILSOVERLAY_PAIN
					elseif otherplayer.mo.skin == "tailsdoll"
						P_SetMobjStateNF(otherplayer.followmobj,S_NULL)
					end
				end
			end
			break
		end
	end
	
	local swipetrigger = (player.actionstate == 0 and doaction == 1 and not(flying or carrying))
	local thrusttrigger = (player.actionstate == 0 and doaction == 1 and flying and not(carrying))
	local throwtrigger = (player.actionstate == 0 and doaction == 1 and carrying)
	//Get thrust speed multiplier
	local thrustfactor = mo.scale
	if mo.eflags&MFE_UNDERWATER
		thrustfactor = $>>1
	end
	if mo.flags2&MF2_TWOD or twodlevel
		thrustfactor = $>>1
	end
	
	player.actionrings = 10
	if not(flying) then
		player.actiontext = "Tail Swipe"
	elseif not(carrying)
		player.actiontext = "Flight Dash"
	else
		player.actiontext = "Throw Partner"
	end
	
	if player.actionstate != 0 then
		player.exhaustmeter = FRACUNIT
	end
	
	//Activate swipe
	if swipetrigger 
		B.PayRings(player)
		B.ApplyCooldown(player,cooldown_swipe)
		//Set state
		player.actionstate = state_swipe
		player.actiontime = 0
		player.pflags = $&~(PF_SPINNING|PF_JUMPED)
		//Missile attack
		domissile(mo,thrustfactor)
		
		//Physics
		if not(P_IsObjectOnGround(mo))
			P_SetObjectMomZ(mo,FRACUNIT*5,false)
		end
		//Effects
		P_SpawnParaloop(mo.x,mo.y,mo.z,mo.scale*64,12,MT_DUST,ANGLE_90,nil,true)
		S_StartSound(mo,sfx_spdpad)
	end

	//Activate thrust
	if thrusttrigger 
		B.PayRings(player)
		//Tails can get as much as 4x cooldown for using flight dash after flying for a while
		if mo.state == S_PLAY_FLY_TIRED
			B.ApplyCooldown(player, cooldown_dash * 3)
		else
			B.ApplyCooldown(player, min(cooldown_dash * 3, max(cooldown_dash, (cooldown_dash * 5) - (player.exhaustmeter * 300/FRACUNIT))))
		end
		//Set state
		player.powers[pw_tailsfly] = 0
		player.pflags = ($|PF_JUMPED|PF_THOKKED)
		player.actionstate = state_thrust
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
		player.actionstate = state_thrust
		player.actiontime = 0
		mo.state = S_PLAY_ROLL
	
		//Throw Partner
		for otherplayer in players.iterate
-- 			print(otherplayer.mo.tracer)
-- 			print(otherplayer.powers[pw_carry])
			if not(
				otherplayer.mo and otherplayer.mo.valid
				and otherplayer.mo.tracer == mo
				and otherplayer.powers[pw_carry] == CR_PLAYER
			)
				continue
			end
			local partner = otherplayer.mo
			partner.tracer = nil
			otherplayer.powers[pw_carry] = 0
			partner.state = S_PLAY_ROLL
			otherplayer.pflags = $|PF_SPINNING|PF_THOKKED
			P_InstaThrust(partner,mo.angle,thrustfactor*throw_strength)
			partner.momx = $ + mo.momx/2
			partner.momy = $ + mo.momy/2
			partner.momz = throw_lift*mo.scale*P_MobjFlip(mo) + mo.momz/2
			otherplayer.pushed_creditplr = player
			if B.MyTeam(player, otherplayer)
				otherplayer.tailsthrown = -1
			else
				otherplayer.tailsthrown = -2
				otherplayer.airdodge = -1
				otherplayer.actioncooldown = max($,2*TICRATE)
				B.PlayerCreditPusher(otherplayer,player)
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
	if player.actionstate == state_swipe
		player.actiontime = $+1
		if P_IsObjectOnGround(mo)
			player.lockaim = true
		end
		player.lockmove = true
-- 		player.powers[pw_nocontrol] = $|2
		//Anim states
		if player.actiontime < 4
			//Fast Spin anim
			player.drawangle = mo.angle-ANGLE_90*(player.actiontime-4)
			B.DrawSVSprite(player,1)
			P_SetMobjStateNF(player.followmobj,S_NULL)
			dodust(mo)
		elseif player.actiontime < 12
			//Medium Spin anim
			player.drawangle = mo.angle-ANGLE_45*(player.actiontime-4)
			B.DrawSVSprite(player,1)
			P_SetMobjStateNF(player.followmobj,S_NULL)
			dodust(mo)
		else
			//Teeter anim
			player.drawangle = mo.angle-ANGLE_45/2*(player.actiontime-4)
			mo.state = S_PLAY_EDGE
			mo.frame = 0
			mo.tics = 0
		end
		//Reset to neutral
		if player.actiontime >= 22
			player.actionstate = 0
			player.drawangle = mo.angle
			mo.state = S_PLAY_WALK
			mo.frame = 0
		end
	end
	//Thrust state
	if player.actionstate == state_thrust
		if not player.actioncooldown then
			player.mo.cantouchteam = 1
		end
		P_SetMobjStateNF(player.followmobj,S_NULL)
		B.DrawSVSprite(player,1)
		player.actiontime = $+1
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
		//Reset to neutral
		if P_IsObjectOnGround(mo) then
			player.actionstate = 0
			player.drawangle = mo.angle
			mo.state = S_PLAY_WALK
			mo.frame = 0
		end
	end
end