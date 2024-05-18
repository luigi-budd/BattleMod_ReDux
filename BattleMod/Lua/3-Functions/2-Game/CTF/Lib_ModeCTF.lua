local B = CBW_Battle
local CV = B.Console
local F = B.CTF
local grace1 = CV.CTFdropgrace
local grace2 = CV.CTFrespawngrace
local FLG_SCORE = 250 -- The score a player gets for capping flag
local RET_SCORE = 200 -- The score a player gets for returning flag
F.RedScore = 0
F.BlueScore = 0
F.RedFlag = nil
F.BlueFlag = nil
F.RedFlagPos = {x=0,y=0,z=0}
F.BlueFlagPos = {x=0,y=0,z=0}

F.TrackRed = function(mo)
	F.RedFlag = mo
end
F.TrackBlue = function(mo)
	F.BlueFlag = mo
end
F.TrackPlayers = function()
	for p in players.iterate
		if p.valid and p.mo and p.mo.valid and p.gotflag
			if p.ctfteam == 1
				F.BlueFlag = p.mo
			elseif p.ctfteam == 2
				F.RedFlag = p.mo
			end
		end
	end
end

F.TouchFlag = function(mo, pmo)
	local player = pmo.player
	if not mo.fuse
		return
	end
	if player.guard
	or player.airdodge > 0
	or player.forcestopping
		if P_IsObjectOnGround(mo) and not mo.jostletimer
			mo.jostletimer = 16
			S_StartSound(mo, sfx_s3k6d)
			B.ZLaunch(mo, FRACUNIT*10)
			P_InstaThrust(mo, R_PointToAngle2(pmo.x - pmo.momx, pmo.y - pmo.momy, mo.x, mo.y), mo.scale*4)
		end
		return true -- Disallow grabbing the flag while in one of these states
	end
	
	if player.powers[pw_flashing]
		player.powers[pw_flashing] = max($,2)
	end
end

F.FlagIntangible = function(mo)
	if B.CPGametype() then
		mo.flags2 = $&~MF2_DONTDRAW
		mo.flags = $&~MF_SPECIAL
	return end
	//Get spawntime
	local spawntype = 1 //flag is at base
	if mo.fuse then spawntype = 2 end //flag has been dropped

	//Flag has been dropped manually
	local lasttouched = mo.tracer or mo.target
	if lasttouched
	and lasttouched.player
	and lasttouched.player.gotflagdebuff
	and lasttouched.player.cmd.buttons & BT_TOSSFLAG
		spawntype = 3
		mo.intangibletime = 0
		S_StartSound(mo, sfx_toss)
	end

	//Initiate mo.intangibletime
	if mo.intangibletime == nil then
		if spawntype == 2 then
			mo.intangibletime = TICRATE*grace1.value
		else
			mo.intangibletime = TICRATE*grace2.value
		end
	end
	
	//Countdown
	mo.intangibletime = max(0,$-1)
	
	//Determine blink frame
	local blink = 0
	if spawntype == 2 or (spawntype == 1 and mo.intangibletime > TICRATE*2) then
		blink = mo.intangibletime&1
	else
		blink = mo.intangibletime&4
	end
	
	if blink then
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $&~MF2_DONTDRAW
	end

	//Determine toss blink
	local tossblink = 0
	if lasttouched and lasttouched.player then
		tossblink = lasttouched.player.tossdelay
	end

	if tossblink then
		local g = P_SpawnGhostMobj(mo)
		g.tics = 4
	end
	if tossblink&4 then
		mo.shadowscale = 1
	else
		mo.shadowscale = mo.scale
	end
	
	//Determine tangibility
	if mo.intangibletime then
		mo.flags = $&~MF_SPECIAL
	else
		mo.flags = $|MF_SPECIAL
	end
end

local function resetFlagvars()
	-- If anyone is holding the flag, get rid of it
	for p in players.iterate do
		if p.gotflag then p.gotflag = 0 end
	end
end

-- fteam: Team for which to respawn flag
-- TODO: sanity check (don't create more than 1 of one flag)
-- 1: Red team
-- 2: Blue team
local function spawnFlag(fteam)
	-- find where the flag's Z coordinate is supposed to be (pain.)
	local x = (fteam == 1) and F.RedFlagPos.x or F.BlueFlagPos.x
	local y = (fteam == 1) and F.RedFlagPos.y or F.BlueFlagPos.y

	local ss = R_PointInSubsector(x, y)
	local s_floorheight = ss.sector.floorheight
	local z = ((fteam == 1) and F.RedFlagPos.z or F.BlueFlagPos.z ) + s_floorheight
	if fteam == 1 then -- spawn a red flag
		local rflag = P_SpawnMobj(x, y, z, MT_CREDFLAG)
		rflag.atbase = true
	elseif fteam == 2 then -- spawn a blue flag
		local bflag = P_SpawnMobj(x, y, z, MT_CBLUEFLAG)
		bflag.atbase = true
	end
end

local function getFlagpos()
	for mo in mapthings.iterate do
		if mo.type == 310 then -- RED FLAG
			F.RedFlagPos.x = FRACUNIT*mo.x
			F.RedFlagPos.y = FRACUNIT*mo.y
			F.RedFlagPos.z = FRACUNIT*mo.z
			spawnFlag(1)
		elseif mo.type == 311 then  -- BLUE FLAG
			F.BlueFlagPos.x = FRACUNIT*mo.x
			F.BlueFlagPos.y = FRACUNIT*mo.y
			F.BlueFlagPos.z = FRACUNIT*mo.z
			spawnFlag(2)
		end
	end
end

F.ResetPlayerFlags = function()
	resetFlagvars()
end

F.LoadVars = function()
	-- Reset all flag variables
	--resetFlagvars()
	if gametype ~= GT_BATTLECTF then return end

	-- Find flag coordinates in the map, and save them; They will be used to spawn the flag
	getFlagpos()
end

-- Makes an injured or dead player lose possession of the flag.
-- if `toss` is nonzero, it indicates tossing the flag.
F.PlayerFlagBurst = function(p, toss)
		if gametype ~= GT_BATTLECTF then return end
		if not p.gotflag then return end -- player MUST have a flag for this to occur!

		if p.mo.flag_indicator then
			P_RemoveMobj(p.mo.flag_indicator)
			p.mo.flag_indicator = nil
		end
		p.gotflag = 0
		local type = p.ctfteam == 1 and MT_CBLUEFLAG or MT_CREDFLAG
		local mo = p.mo
		local flag = P_SpawnMobj(mo.x, mo.y, mo.z, type)
		flag.jostletimer = 8
		if (mo.eflags & MFE_VERTICALFLIP) then
			flag.flags2 = $|MF2_OBJECTFLIP
		end

		if toss then
			P_SetObjectMomZ(flag, P_MobjFlip(mo)*6*FRACUNIT, mo.scale)
			P_InstaThrust(flag, mo.angle, FixedMul(15*FRACUNIT, mo.scale))
		else
			P_SetObjectMomZ(flag, P_MobjFlip(mo)*8*FRACUNIT, mo.scale)
			-- Random range
			local fa = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
			flag.momx = FixedMul(cos(fa), FixedMul(6*FRACUNIT, mo.scale))
			if (not(twodlevel or (mo.flags2 & MF2_TWOD))) then
				flag.momy = FixedMul(sin(fa), FixedMul(6*FRACUNIT, mo.scale))
			end
		end

		local ftime = CV_FindVar("flagtime").value * TICRATE
		flag.fuse = ftime
		flag.target = mo

		-- Flag text
		local plname = p.name
		local pcolor = p.ctfteam == 1 and '\x85' or '\x84'
		local flagtext = 0
		local flagcolor = 0

		if (type == MT_CREDFLAG) then
			flagtext = "Red flag"
			flagcolor = '\x85'
		else
			flagtext = "Blue flag"
			flagcolor = '\x84'
		end
		if (toss) then
			print(pcolor..plname.."\128 tossed the "..flagcolor..flagtext..".")
		else
			print(pcolor..plname.."\128 dropped the "..flagcolor..flagtext..".")
		end

		p.gotflag = 0 -- no flag

		if (toss) then
			p.tossdelay = 2*TICRATE
		end
end

B.DoFirework = function(mo)
	local spark = P_SpawnMobj(mo.x,mo.y,mo.z,MT_SUPERSPARK)
	if spark and spark.valid then
		spark.momz = mo.scale*4
	end
	local fw = P_SpawnMobj(mo.x,mo.y,mo.z+(mo.scale*96),MT_EFIREWORK)
	if fw and fw.valid then
		fw.speed = mo.scale
		fw.state = S_EFIREWORK0
		fw.skin = mo.skin
		fw.color = mo.color
		fw.scale = mo.scale
		fw.destscale = mo.scale*2
	end
end

-- @flag:
-- 1: red
-- 2: blue
local function capFlag(p, flag)
	-- Flag must be at base!!
	if not F.IsFlagAtBase(p.ctfteam) then return end
	p.gotflag = 0

	if flag == 1 then F.RedScore = $+1 elseif flag == 2 then F.BlueScore = $+1 end
	spawnFlag(flag == 1 and 2 or 1) --respawn opposite team flag
	P_AddPlayerScore(p, FLG_SCORE)
	
	--sounds
	local friendly = (splitscreen or (consoleplayer and consoleplayer.ctfteam == p.ctfteam))
	if friendly then S_StartSound(nil, sfx_flgcap) else S_StartSound(nil, sfx_lose) end
	--hud
	F.GameState.CaptureHUDTimer = 5*TICRATE
	F.GameState.CaptureHUDName = p.name
	F.GameState.CaptureHUDTeam = p.ctfteam
	--vfx
	local mo = flag==1 and F.BlueFlag or F.RedFlag
	if mo and mo.valid then
		local vfx = P_SpawnMobj(mo.x,mo.y,mo.z,MT_THOK)
		if vfx and vfx.valid then
			vfx.sprite = flag==1 and SPR_BFLG or SPR_RFLG
			vfx.destscale = vfx.scale*4
			vfx.fuse = $*2
		end
		B.DoFirework(mo)
	end
	
end

F.FlagPreThinker = function()
	if gametype ~= GT_BATTLECTF then return end
	for p in players.iterate do
		if p and p.mo then
			-- Press tossflag to tossflag
			local btns = p.cmd.buttons
			if (btns&BT_TOSSFLAG and not(p.powers[pw_carry] & CR_PLAYER) and not(p.powers[pw_super]) and not(p.tossdelay) and G_GametypeHasTeams() and p.gotflag)
			then
				F.PlayerFlagBurst(p, 1)
			end

			if p.gotflag and P_IsObjectOnGround(p.mo) then
				if p.ctfteam == 1 and P_PlayerTouchingSectorSpecial(p, 4, 3) then -- Red man touching red base
					capFlag(p,1)
				elseif p.ctfteam == 2 and P_PlayerTouchingSectorSpecial(p, 4, 4) then -- Blue man touching Blue base
					capFlag(p,2)
			    end
			end
		end
	end
end

-- Dictates what happens when you touch the flag
F.FlagTouchSpecial = function(special, toucher)
	-- Ensure that the gametype is custom ctf first!
	if gametype ~= GT_BATTLECTF then return end
	if F.TouchFlag(special, toucher) then return true end --don't interact with flag if true!

	if special and toucher and toucher.player then
		local p = toucher.player
		local pteam = p.ctfteam

		if special.type == MT_CREDFLAG or special.type == MT_CBLUEFLAG then
			-- Under these conditions, do NOT interact with the flag.
			if      p.powers[pw_flashing] or
				P_PlayerInPain(p) or
				p.playerstate ~= PST_LIVE or
				p.tossdelay
			then return true end
		end

		local fcolor_r = "\x85"
		local fcolor_b = "\x84"
		local pcolor = p.ctfteam == 1 and fcolor_r or fcolor_b

		-- If object is valid and player doesn't have tossdelay
		if special.valid and not p.tossdelay then
			-- Only interact with if you're on blu
			if special.type == MT_CREDFLAG then 
				if pteam == 2 then -- Opposite team of flag, so grab it
					p.gotflag = GF_REDFLAG
					if splitscreen or (displayplayer and p == displayplayer)
						S_StartSound(nil, sfx_lvpass)
					end
					print(pcolor+p.name+"\128 picked up the "+fcolor_r+"Red flag!")
					special.wasgrabbed = true
				elseif pteam == 1 and special.fuse then -- Same team as flag, so return it (remove the special.fuse part for sfx spam)
					special.wasreturned = true
					P_RemoveMobj(special)
					local sfx_fr = p.ctfteam == 1 and sfx_hoop1 or sfx_hoop3
					S_StartSound(nil, sfx_fr)
					print(pcolor+p.name+"\128 returned the "+fcolor_r+"Red flag\128 to base.")
					P_AddPlayerScore(p, RET_SCORE)
					return
				end
			-- Only interact with if you're on red
			elseif special.type == MT_CBLUEFLAG then
				if pteam == 1 then -- Opposite team of flag, so grab it
					p.gotflag = GF_BLUEFLAG
					if splitscreen or (displayplayer and p == displayplayer)
						S_StartSound(nil, sfx_lvpass)
					end
					print(pcolor+p.name+"\128 picked up the "+fcolor_b+"Blue flag!")
					special.wasgrabbed = true
				elseif pteam == 2 and special.fuse then -- Same team as flag, so return it (remove the special.fuse part for sfx spam)
					special.wasreturned = true
					P_RemoveMobj(special)
					local sfx_fr = p.ctfteam == 2 and sfx_hoop1 or sfx_hoop3
					S_StartSound(nil, sfx_fr)
					print(pcolor+p.name+"\128 returned the "+fcolor_b+"Blue flag\128 to base.")
					P_AddPlayerScore(p, RET_SCORE)
					return
				end
			end
		end

		-- Dumb condition: prevent same team players from grabbing their own flag
		-- TODO: maybe there's a better way, idk..
		if      special.valid and ((special.type == MT_CREDFLAG and pteam == 1) or
			(special.type == MT_CBLUEFLAG and pteam == 2))
		then
			return true 
		end
	end
end

F.FlagSpawn = function(mo)
	if gametype ~= GT_BATTLECTF then return end

	if mo and mo.type == MT_CREDFLAG or mo.type == MT_CBLUEFLAG then
		mo.shadowscale = mo.scale --set flag shadow

		-- The flag was tossed by someone, so give it fuse time
		if mo.target then mo.fuse = CV_FindVar("cv_flagtime") end
	end
end

-- Respawns the flag if it was tossed in a deathpit
F.RespawnFlag = function(mo)
	-- Ensure that the gametype is custom ctf first!
	if gametype ~= GT_BATTLECTF then return end

	-- re-spawn the flags
	if mo.type == MT_CREDFLAG then spawnFlag(1)
	elseif mo.type == MT_CBLUEFLAG then spawnFlag(2)
	end
end
F.FlagRemoved = function(mo)
	if gamestate ~= GS_LEVEL then return end
	if gametype ~= GT_BATTLECTF then return end

	-- If the flag was removed because it wasn't grabbed, then respawn it (it presumably fell in a pit or was returned by a player)
	if mo and (mo.type == MT_CREDFLAG or mo.type == MT_CBLUEFLAG) then
		if not mo.wasgrabbed then

			-- TODO: this is a duplicate, probably bad idea 
			-- Play sound and show messages, assuming the flag somehow got removed (most likely by a pit)
			if not mo.wasreturned and not mo.touched_sector then
				-- Play corresponding sounds
				local p = consoleplayer --idk, this may be bad? :shrug
				local sfx_fr = sfx_hoop3
				if p
					if mo.type == MT_CREDFLAG and not p.spectator then -- red
							sfx_fr = p.ctfteam == 2 and sfx_hoop3 or sfx_hoop1
							CONS_Printf(p, "The \133Red flag\128 has returned to base.")
					elseif mo.type == MT_CBLUEFLAG and not p.spectator then -- blu
							sfx_fr = p.ctfteam == 1 and sfx_hoop3 or sfx_hoop1
							CONS_Printf(p, "The \132Blue flag\128 has returned to base.")
					end
				end
				S_StartSound(nil, sfx_fr)
			end
			F.RespawnFlag(mo) 
		end
	end
end

F.GotFlagCheck = function(p)
	if p.mo and p.gotflag then return true end
end

local function returnFlagcheck(mo)
	if mo.type == MT_CREDFLAG or mo.type == MT_CBLUEFLAG then
		-- Check sector
		local ss = R_PointInSubsector(mo.x, mo.y)
		local special = ss.sector.special
		if (    (GetSecSpecial(special, 1) == 4) or
			(GetSecSpecial(special, 1) == 3) or
			(GetSecSpecial(special, 1) == 2) or
			(GetSecSpecial(special, 1) == 1) or
			(GetSecSpecial(special, 1) == 5) or
			(GetSecSpecial(special, 1) == 8)
			)
		then
			-- TODO: this is also a duplicate..
			if P_IsObjectOnGround(mo) then					
				-- Play corresponding sounds
				local p = consoleplayer --idk, this may be bad? :shrug
				local sfx_fr = sfx_hoop3
				if p
					if mo.type == MT_CREDFLAG and not p.spectator then -- red
							sfx_fr = p.ctfteam == 2 and sfx_hoop3 or sfx_hoop1
							CONS_Printf(p, "The \133Red flag\128 has returned to base.")
					elseif mo.type == MT_CBLUEFLAG and not p.spectator then -- blu
							sfx_fr = p.ctfteam == 1 and sfx_hoop3 or sfx_hoop1
							CONS_Printf(p, "The \132Blue flag\128 has returned to base.")
					end
				end
				S_StartSound(nil, sfx_fr)
				return true
			end
		end

		-- Check FOFs
		for fof in mo.subsector.sector.ffloors() do
			if      ((GetSecSpecial(fof.sector.special, 1) == 4 ) or -- Electric sector
				 (GetSecSpecial(fof.sector.special, 1) == 3 ) or -- Fire sector
				 (GetSecSpecial(fof.sector.special, 1) == 2 ) or -- Water damage sector
				 (GetSecSpecial(fof.sector.special, 1) == 1 ) or -- Damage sector
				 (GetSecSpecial(fof.sector.special, 1) == 5 ) or -- Spikes sector
				 (GetSecSpecial(fof.sector.special, 1) == 8 )  -- Instant kill sector
				 --or (GetSecSpecial(fof.sector.special, 1) == 6 ) or -- Death pit
				 --(GetSecSpecial(fof.sector.special, 1) == 7 )    -- Death pit
				)
				and
				((P_MobjFlip(mo) == 1 and mo.z <= fof.sector.floorheight) -- Must be above FOF if normal gravity
				or
				(P_MobjFlip(mo) == -1 and mo.z >= fof.sector.ceilingheight))
			then
				if P_IsObjectOnGround(mo) then					
					-- Play corresponding sounds
					local p = consoleplayer --idk, this may be bad? :shrug
					if mo.type == MT_CREDFLAG and not p.spectator then -- red
						local sfx_fr = p.ctfteam == 2 and sfx_hoop3 or sfx_hoop1
						S_StartSound(nil, sfx_fr)
						print("The \133Red flag\128 has returned to base.")
					elseif mo.type == MT_CBLUEFLAG and not p.spectator then -- blu
						local sfx_fr = p.ctfteam == 1 and sfx_hoop3 or sfx_hoop1
						S_StartSound(nil, sfx_fr)
						print("The \132Blue flag\128 has returned to base.")
					end
					mo.touched_sector = true
					P_RemoveMobj(mo) 
					return true
				end
			end
		end
	end
	return
end

F.FlagMobjThinker = function(mo)
	if gametype ~= GT_BATTLECTF then return end

	if mo then
		if mo.jostletimer then
			mo.jostletimer = $ - 1
		end
		local ret_check = returnFlagcheck(mo)
		if ret_check then return end
	end
end

F.DrawIndicator = function() --TODO: move this out of Lib_ModeCTF, probably
	for p in players.iterate do
		if not(p.mo and p.mo.valid) then return end
		local pmo = p.mo
		local conditions = {(p.gotflag), (B.Arena.Bounty and B.Arena.Bounty == p)}
		local canhaveicon = false
		for n=1, #conditions do
			if conditions[n] then canhaveicon = true end
		end
		if not(canhaveicon) then -- no conditions were met! so simply delete indicator
			if pmo.flag_indicator then
				P_RemoveMobj(pmo.flag_indicator)
				pmo.flag_indicator = nil
			end
			return
		end

		-- if we're here, at least one of the conditions met, so let's create a generic indicator! (if there isn't any)
		if not(pmo.flag_indicator and pmo.flag_indicator.valid) then
			pmo.flag_indicator = {}
			local icon = P_SpawnMobjFromMobj(pmo,0,0,0,MT_GOTFLAG)
			icon.frame = FF_FULLBRIGHT
			icon.fuse = 0
			icon.tics = -1
			
			-- then, update it based on which condition was met
			if conditions[1] then -- flag
				icon.frame = $|(p.ctfteam == 1 and 2 or 1) 
				-- TODO: mobjinfo stuff for flags so we don't have to keep comparing ctfteam to fixed numbers
			elseif conditions[2] then -- crown
				icon.sprite = SPR_CRWN
				icon.spritexoffset = $+(pmo.scale*6)
				icon.spriteyoffset = $+pmo.height
			else -- what
				icon.sprite = SPR_UNKN
			end
			
			pmo.flag_indicator = icon -- assign the icon to be the player's indicator
		end

		-- finally, update the indicator's position
		local zoffset = pmo.height * P_MobjFlip(pmo)
		if (pmo.eflags&MFE_VERTICALFLIP) then -- not sure why this is necessary, but if it works it works
			zoffset = $+(pmo.height/3)
		end
		pmo.flag_indicator.eflags = (pmo.eflags&MFE_VERTICALFLIP) and $|MFE_VERTICALFLIP or $&~MFE_VERTICALFLIP
		P_TeleportMove(pmo.flag_indicator, pmo.x,pmo.y,pmo.z+zoffset)

		-- players can see their own indicators, so let's make it less visually obstructing for them
		if (displayplayer and p == displayplayer and not splitscreen)
			pmo.flag_indicator.scale = FRACUNIT * 2/3
			pmo.flag_indicator.frame = $ | FF_TRANS30
		end
	end
end

-- 1: Red
-- 2: Blue
F.IsFlagAtBase = function(fteam)
	if fteam == 1 then -- red
		if F.RedFlag and F.RedFlag.atbase then
			return true
		end
		return false
	else -- blu
		if F.BlueFlag and F.BlueFlag.atbase then
			return true
		end
		return false
	end
end

-- Remove stuff from player if they quit
F.RemoveOnQuit = function(p, reason)
	if p and p.mo and p.mo.flag_indicator then
		P_RemoveMobj(p.mo.flag_indicator)
		p.mo.flag_indicator = nil
	end
end

--example
--[[
addHook("PostThinkFrame", function()
  if not G_GametypeHasTeams() then return end
  for p in players.iterate do


  end
end)
--]]

--// rev: Updates player flag captures. e.g. If a player captures a flag, their flag cap goes up by 1.
--// NOTE: Caps reset when the map changes, in-game time resets when map changes/player spectates (see MapChange, Exec_system)
F.UpdateCaps = function(p)
	if gametype ~= GT_BATTLECTF then return end
    if not (p and p.mo) then return end

    --// Keep track of whether player doesn't have flag anymore and if their team's score just went up.
    local new_score = p.ctfteam == 1 and redscore or bluescore
    local old_score = p.oldscore
    local new_flag 	= p.gotflag
    local old_flag  = p.oldflag

    --// If for this singular frame, the new score is larger than before,
    --// and the player doesn't have the flag anymore, add 1 to the player's caps.
    if new_score > old_score and new_flag ~= old_flag then
    	p.caps = $+1
    end

    --// Refresh old team score
    p.oldscore = new_score
    p.oldflag  = new_flag

end

--F.UpdateScore = function(mo)
--	if gametype ~= GT_BATTLECTF then return end
--	redscore = F.RedScore
--	bluescore = F.BlueScore
--end
