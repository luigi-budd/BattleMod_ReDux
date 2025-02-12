local B = CBW_Battle
local CV = B.Console
local frameA = A --cry
local A = B.Arena

local pinchtime = 31
local pinchmusic = "_PINCH"
local overtimemusic = "_OVRTM"

B.PreRoundWait = function()
	if gametype and CV.PreRound.value-- and not(B.TagGametype())
		and gametyperules&GTR_STARTCOUNTDOWN and leveltime < CV_FindVar("hidetime").value*TICRATE
		then return true
	else return false end
end

B.GetPinch = function()
	B.PinchTics = max(0,$-1)
	if B.Exiting then 
		B.SuddenDeath 	= false
		B.Pinch 		= false
		B.Overtime	 	= false
		B.MatchPoint	= false
	return end
	--Get vars
	local t 			= CV_FindVar("timelimit")
	local ot 			= CV_FindVar("overtime")
	local pointlimit 	= CV_FindVar("pointlimit").value
	local pre_pinch 	= (t.value*60-pinchtime)
	local timeleft 		= pre_pinch-leveltime/TICRATE
	if t.value and gametyperules&GTR_FIXGAMESET then
		timeleft = $-60
	end
	local pinch 		= timeleft < 0
	local overtime 		= ((ot.value) and (gametyperules & GTR_OVERTIME) and t.value*60-leveltime/TICRATE <= 0)
	local suddendeath 	= (B.Gametypes.SuddenDeath[gametype] and overtime and CV.SuddenDeath.value == 1)
	local matchpoint    = G_GametypeHasTeams() and ((redscore+1 == pointlimit) or (bluescore+1 == pointlimit)) and not(pinch) and not(overtime)

	--Match point music
	if matchpoint then
		--print(true)
		if B.MatchPoint == false then
			B.DebugPrint("Match Point triggered", DF_GAMETYPE)
			B.MatchPoint = true
			B.MatchPointMusic(consoleplayer)
		end
	end

	--Check game mode conditions
	if not(B.PreRoundWait())
	and gametyperules&GTR_TIMELIMIT and t.value and pinch
		--Pinch state
		if not(overtime)
			B.SuddenDeath 	= false
			B.Overtime 		= false
			B.MatchPoint	= false
			--Do pinch indicators
			if B.Pinch == false then
				B.Pinch = true
				B.DebugPrint("Pinch mode triggered",DF_GAMETYPE)
				S_StartSound(nil,sfx_s3k63)
				B.PinchMusic(consoleplayer)
				B.PinchTics = TICRATE*2
			end
		end
		--Overtime state
		if overtime then
			B.Pinch = false
			--Enable sudden death
			if suddendeath and not(B.SuddenDeath)
				B.DebugPrint("Sudden death triggered",DF_GAMETYPE)
				B.SuddenDeath = true
				B.PinchTics = TICRATE*2
	 			S_StartSound(nil,sfx_s253)
			end
			--Do overtime indicators
			if B.Overtime == false then
				B.DebugPrint("Overtime triggered",DF_GAMETYPE)
				B.Overtime = true
				B.OvertimeMusic(consoleplayer)
			end
		end
	else
		if not(B.Exiting) and (B.Pinch or B.SuddenDeath or B.Overtime) then
			B.DebugPrint("Pinch mode / sudden death / overtime deactivated",DF_GAMETYPE)
			B.Pinch = false
			B.SuddenDeath = false
			B.Overtime = false
			for player in players.iterate
	-- 			P_RestoreMusic(player)
				COM_BufInsertText(player,"tunes -default")
			end
		end
	end
end

B.InvalidPlayer = function(player)
	if player.spectator then return true end
	if player.playerstate != PST_LIVE then return true end
	if player.exiting then return true end
	if not(player.mo) then return true end
	if player.revenge then return true end
	return false
end

B.SuddenDeathBomb = function()
	if leveltime&7 then return end
	if B.PinchTics then return end
	local unlucky = {} --Raffle of players to choose to bomb
	for player in players.iterate() do
		if B.InvalidPlayer(player) then continue end
		unlucky[#unlucky+1] = player.mo --Can be bombed
	end
	if not(#unlucky) then return end --No one to bomb
	
	local mo = unlucky[P_RandomRange(1,#unlucky)] --And our unlucky winner is...
	
	local z 
	local z2 = P_MobjFlip(mo) == 1 and mo.ceilingz or mo.floorz
	z = B.FixedLerp(mo.z,z2,P_RandomRange(FRACUNIT/2,FRACUNIT))

	local b = P_SpawnMobj(mo.x,mo.y,z,MT_FBOMB)

	if P_MobjFlip(mo) == -1 then
		b.flags2 = MF2_OBJECTFLIP
	end
	local dist = P_RandomRange(0,512)*FRACUNIT
	local ang = P_RandomRange(0,359)*ANG1
	local x = b.x+P_ReturnThrustX(b,ang,dist)
	local y = b.y
	if not(twodlevel) then
		y = $+P_ReturnThrustY(b,ang,dist)
	end
	P_TryMove(b,x,y,false)
end

B.SuddenDeathGrow = function(player)
	for player in players.iterate() do
		if B.InvalidPlayer(player) then continue end
		player.mo.scale = $+FRACUNIT/400
	end
end

B.SuddenDeathZone = function(remove)
	if remove then
		if B.ZoneObject and B.ZoneObject.valid and not (B.ZoneObject.flags2 & MF2_DONTDRAW) then
			local vfx = P_SpawnMobjFromMobj(B.ZoneObject, 0, 0, 0, MT_THOK)
			if vfx and vfx.valid then
				vfx.state = S_XPLD1
				S_StartSound(vfx, sfx_pop)
			end
			for p in players.iterate do
				if p.mo then
					if S_SoundPlaying(p.mo, sfx_premon) then
						S_StopSoundByID(p.mo, sfx_premon)
					end
					if p.mo.btagpointer and p.mo.btagpointer.valid then
						P_RemoveMobj(p.mo.btagpointer)
					end
				end
			end
			B.ZoneObject.flags2 = $ | MF2_DONTDRAW
			B.ControlPoint.ResetFX(B.ZoneObject)
			P_RemoveMobj(B.ZoneObject)
		end
		return
	end

	-- Initialize zone if it doesn't exist
	if not (B.ZoneObject and B.ZoneObject.valid) then
		local validSpawns = {}
		for player in players.iterate() do
			if B.InvalidPlayer(player) then continue end
			
			-- Prioritize players not over pits by checking if they're on ground
			-- TODO: Remove port priority
			if P_IsObjectOnGround(player.mo) or player.powers[pw_flashing] then
				table.insert(validSpawns, 1, player.mo)
			else
				table.insert(validSpawns, player.mo)
			end
		end
		
		if #validSpawns == 0 then return end
		
		local chosen = validSpawns[1]
		local zoneobject = P_SpawnMobj(chosen.x, chosen.y, chosen.z, MT_CONTROLPOINT)
		zoneobject.sprite = SPR_DTHZ
		zoneobject.cp_radius = 2048*FRACUNIT
		zoneobject.cp_height = 320*FRACUNIT
		zoneobject.cp_meter = 400
		if chosen.eflags & MFE_VERTICALFLIP then
			zoneobject.eflags = $|MFE_VERTICALFLIP
		end
		zoneobject.isdeathzone = true
		B.ZoneObject = zoneobject
		B.ControlPoint.ActivateFX(zoneobject)
	else -- Update zone
		B.ZoneObject.cp_radius = max(0, $ - FRACUNIT)
		if B.ZoneObject.cp_radius <= 0 and not (B.ZoneObject.flags2 & MF2_DONTDRAW) then
			local vfx = P_SpawnMobjFromMobj(B.ZoneObject, 0, 0, 0, MT_THOK)
			if vfx and vfx.valid then
				vfx.state = S_XPLD1
				S_StartSound(vfx,sfx_pop)
			end
			B.ZoneObject.flags2 = $ | MF2_DONTDRAW
			B.ControlPoint.ResetFX(B.ZoneObject)
		end
	end
		
	-- Check all players against zone
	for player in players.iterate() do
		if B.InvalidPlayer(player) then continue end
		local pmo = player.mo
  
		if R_PointToDist2(pmo.x, pmo.y, B.ZoneObject.x, B.ZoneObject.y) > B.ZoneObject.cp_radius then
			local targ = P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_THOK)
			targ.sprite = SPR_TARG
			targ.trans = B.TIMETRANS(100-(player.BT_antiAFK/2), 1, "TR_TRANS", "", 10, 90)
			targ.tics = 2
			targ.frame = B.Wrap(leveltime/2, frameA, G)
			targ.momx, targ.momy, targ.momz = pmo.momx, pmo.momy, pmo.momz
			if player.BT_antiAFK == 200 then
				S_StartSound(pmo, sfx_premon)
				S_StartSound(nil, sfx_cdfm63, player)
			end
			if not (player.mo.btagpointer and player.mo.btagpointer.valid) then
				player.mo.btagpointer = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BTAG_POINTER)
				if player.mo.btagpointer and player.mo.btagpointer.valid then
					player.mo.btagpointer.tracer = player.mo
					player.mo.btagpointer.target = B.ZoneObject
				end
			else
				player.mo.btagpointer.colorized = leveltime%11 < 5
				player.mo.btagpointer.blendmode = leveltime%11 < 5 and AST_ADD or AST_TRANSLUCENT
			end
			player.BT_antiAFK = $ - 1
			if player.BT_antiAFK <= 0 then
				P_DamageMobj(pmo, nil, nil, 1, DMG_INSTAKILL)
				local b = P_SpawnMobj(pmo.x,pmo.y,pmo.z,MT_FBOMB)
				P_ExplodeMissile(b)
			end
		else
			if S_SoundPlaying(pmo, sfx_premon) then
				S_StopSoundByID(pmo, sfx_premon)
			end
			if player.mo.btagpointer and player.mo.btagpointer.valid then
				P_RemoveMobj(player.mo.btagpointer)
			end
			player.BT_antiAFK = 200
		end
	end

	-- Lol lmao
	local mo = B.ZoneObject
	local flip = P_MobjFlip(mo)
	local floor
	local ceil
	if flip == 1 then
		floor = mo.floorz
		ceil = mo.ceilingz
	else
		floor = mo.ceilingz
		ceil = mo.floorz
	end

	B.ControlPoint.ActiveThinker(B.ZoneObject,floor,flip,ceil,mo.cp_radius,mo.cp_height,mo.cp_meter)
	B.ControlPoint.UpdateFX(B.ZoneObject, mo.cp_radius)
end

B.PinchMusic = function(player)
	if B.Exiting then return end
	if player == nil then return end
	if B.Pinch and player == consoleplayer then

		local pinch = pinchmusic
	
		B.DebugPrint("Starting pinch music",DF_GAMETYPE)
		mapmusname = pinch
		S_ChangeMusic(pinch)
		--COM_BufInsertText(player,"tunes "..pinch)
	return true end
	return false
end

B.OvertimeMusic = function(player)
	if B.Exiting then return end
	if player == nil then return end
	if B.Overtime and player == consoleplayer then

		local over = overtimemusic

		B.DebugPrint("Starting overtime music",DF_GAMETYPE)
		mapmusname = over
		S_ChangeMusic(over)
		--COM_BufInsertText(player,"tunes "..over)
	return true end
	return false
end

B.MatchPointMusic = function(player)
	if B.Exiting then return end
	if player == nil then return end
	----
	return false
end

B.SuddenDeathShockwaves = function()
	for mo in mobjs.iterate() do
		if mo.trans != nil then
			mo.frame = ($ & ~FF_TRANSMASK) | mo.trans
			mo.trans = nil
		end
	end
end

B.PinchControl = function()
	B.GetPinch()
	if B.SuddenDeath then
		--B.SuddenDeathBomb()
		--B.SuddenDeathGrow()
		B.SuddenDeathZone(false)
	else
		B.SuddenDeathZone(true)
	end
end

B.PostPinchControl = function()
	if B.SuddenDeath then
		B.SuddenDeathShockwaves()
	end
end