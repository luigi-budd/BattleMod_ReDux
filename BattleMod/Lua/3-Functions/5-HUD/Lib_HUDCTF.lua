local B = CBW_Battle
local F = B.CTF
local BASEVIDWIDTH = 320 --NEVER CHANGE THIS! This is the original
local SEP = 33
local YPOS = 8

local update_pos = function(player)
	if (not player) or player.battleconfig_newhud then
		SEP = 36
		YPOS = 12
	else
		SEP = 22
		YPOS = 0
	end
end

F.CompassHUD = function(v, player, cam)
	if not (B.HUDMain) then return end
	if (player.battleconfig_newhud) then return end
	if gametype ~= GT_BATTLECTF then return end -- Gametype Gateway
	--if not hud.enabled("teamscores") then return end -- Gateway.
	
	local redflag = F.RedFlag
	local blueflag = F.BlueFlag
	
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local xoffsetred = 152 + 20
	local xoffsetblue = 152 - 20
	local yoffset = 25
	local angle
	local cmpangle
	local compass
	local color
	
	local xx = cam.x
	local yy = cam.y
	local zz = cam.z
	local lookang = cam.angle

	--Use the realmo coordinates when not using chasecam
	if (player.spectator or not cam.chase) and (player.realmo and player.realmo.valid) then 
		xx = player.realmo.x
		yy = player.realmo.y
		zz = player.realmo.z
		lookang = player.cmd.angleturn<<16
	end
	
	color = v.getColormap(TC_DEFAULT,SKINCOLOR_RED)
	if redflag and redflag.valid and not (player.mo and player.mo == redflag) then
		if twodlevel then
			angle = R_PointToAngle2(xx, zz, redflag.x, redflag.z) - ANGLE_90 + ANGLE_22h
		else
			angle = R_PointToAngle2(xx, yy, redflag.x, redflag.y) - lookang + ANGLE_22h
		end
		
		local cmpangle = 8
		if (angle >= 0) and (angle < ANGLE_45) then
			cmpangle = 1
		elseif (angle >= ANGLE_45) and (angle < ANGLE_90) then
			cmpangle = 2
		elseif (angle >= ANGLE_90) and (angle < ANGLE_135) then
			cmpangle = 3
		elseif (angle >= ANGLE_135) --[[and (angle < ANGLE_180)]] then
			cmpangle = 4
		elseif (angle >= ANGLE_180) and (angle < ANGLE_225) then
			cmpangle = 5
		elseif (angle >= ANGLE_225) and (angle < ANGLE_270) then
			cmpangle = 6
		elseif (angle >= ANGLE_270) and (angle < ANGLE_315) then
			cmpangle = 7
		end
		
		compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))

		v.draw(xoffsetred,yoffset,compass,flags,color)
		
	elseif player.mo and player.mo == redflag then
		compass = v.cachePatch("FLAGICO")
		v.draw(xoffsetred,yoffset,compass,flags,color)
	end
	
	color = v.getColormap(TC_DEFAULT,SKINCOLOR_BLUE)
	if blueflag and blueflag.valid and not (player.mo and player.mo == blueflag) then
		if twodlevel then
			angle = R_PointToAngle2(xx, zz, blueflag.x, blueflag.z) - ANGLE_90 + ANGLE_22h
		else
			angle = R_PointToAngle2(xx, yy, blueflag.x, blueflag.y) - lookang + ANGLE_22h
		end
		
		local cmpangle = 8
		if (angle >= 0) and (angle < ANGLE_45) then
			cmpangle = 1
		elseif (angle >= ANGLE_45) and (angle < ANGLE_90) then
			cmpangle = 2
		elseif (angle >= ANGLE_90) and (angle < ANGLE_135) then
			cmpangle = 3
		elseif (angle >= ANGLE_135) --[[and (angle < ANGLE_180)]] then
			cmpangle = 4
		elseif (angle >= ANGLE_180) and (angle < ANGLE_225) then
			cmpangle = 5
		elseif (angle >= ANGLE_225) and (angle < ANGLE_270) then
			cmpangle = 6
		elseif (angle >= ANGLE_270) and (angle < ANGLE_315) then
			cmpangle = 7
		end
		
		compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))

		v.draw(xoffsetblue,yoffset,compass,flags,color)

	elseif player.mo and player.mo == blueflag then
		compass = v.cachePatch("FLAGICO")
		v.draw(xoffsetblue,yoffset,compass,flags,color)
	end
end

local function getdigits(num)
	if num then
		local digits = 0
		while(num >= 10) do
			digits = $ + 1
			num = $ / 10
		end
		return digits
	end
	return 0
end

local ranking = false
local function drawFlagfromP(v)
	local patch_flags = V_HUDTRANS|V_PERPLAYER|V_SNAPTOTOP

	-- Thanks, "scores" -- I can't fucking use the player from the parameters
	for player in players.iterate do

		-- If blue flag isn't at base
		if (player.gotflag & GF_BLUEFLAG) then
			local bheld = v.cachePatch("NONICON")
			local BNON_X = BASEVIDWIDTH/2 - SEP - (bheld.width / 2)
			local BNON_Y = YPOS
			v.drawScaled(BNON_X*FRACUNIT, BNON_Y*FRACUNIT, FRACUNIT, bheld, patch_flags)
		end
		-- If red flag isn't at base
		if (player.gotflag & GF_REDFLAG) then
			local rheld = v.cachePatch("NONICON2")   
			local RNON_X = BASEVIDWIDTH/2 + SEP - (rheld.width / 2)
			local RNON_Y = YPOS
			v.drawScaled(RNON_X*FRACUNIT, RNON_Y*FRACUNIT, FRACUNIT, rheld, patch_flags)
		end


		local redflag = F.RedFlag
				local blueflag = F.BlueFlag
		-- Display a countdown timer showing how much time left until the flag returns to base. 
		local scr_flags = V_YELLOWMAP|V_HUDTRANS|V_PERPLAYER|V_SNAPTOTOP
		if blueflag and blueflag.valid and blueflag.fuse > 1 then
			local BFS_X = BASEVIDWIDTH/2 - SEP
			local BFS_Y = YPOS + 8
			local bfuse = blueflag.fuse/TICRATE
			v.drawString(BFS_X, BFS_Y, bfuse, scr_flags, "center")
		end
		if redflag and redflag.valid and redflag.fuse > 1 then
			local RFS_X = BASEVIDWIDTH/2 + SEP
			local RFS_Y = YPOS + 8
			local rfuse = redflag.fuse/TICRATE
			v.drawString(RFS_X, RFS_Y, rfuse, scr_flags, "center")
		end
	end

	-- Draw the flag icon in a fucking unorthodox way
	-- Also don't show this if rankings are currently being shown.
	local player = consoleplayer
	if player.gotflag and not camera.chase and not ranking then
		-- Display flag powerup icon
		local offs_x = 288 --hudinfo[HUD_POWERUPS].x -- matches weapon rings HUD
		if player.powers[pw_shield] ~= SH_NONE then offs_x = $-20 end
		if player.powers[pw_flashing] or player.powers[pw_invulnerability] then offs_x = $-20 end
		if player.powers[pw_sneakers] then offs_x = $-20 end
		local offs_y = hudinfo[HUD_POWERUPS].y
		local flg_str = (player.gotflag == GF_REDFLAG) and "GOTRFLAG" or "GOTBFLAG"
		local flag = v.cachePatch(flg_str)
		local V_HUDFLAG = hudinfo[HUD_POWERUPS].f
		v.drawScaled(offs_x*FRACUNIT, offs_y*FRACUNIT, FRACUNIT/2, flag, V_PERPLAYER|V_HUDFLAG|V_HUDTRANS)
	end

	-- Blue flag score (drawn here so it's always shown on top of the flag icons)
	local bscore = bluescore
	local BFLG_SCR_X = BASEVIDWIDTH/2 - SEP - getdigits(bscore)*2
	local BFLG_SCR_Y = YPOS + 15

	-- Red flag score
	local rscore = redscore
	local RFLG_SCR_X = BASEVIDWIDTH/2 + SEP + getdigits(rscore)*2
	local RFLG_SCR_Y = YPOS + 15

	v.drawString(BFLG_SCR_X, BFLG_SCR_Y, bscore, patch_flags, "center")
	v.drawString(RFLG_SCR_X, RFLG_SCR_Y, rscore, patch_flags, "center")
end

local function cctf_hud(v, p, cam)
	update_pos(p)

	local patch_flags = V_HUDTRANS|V_PERPLAYER|V_SNAPTOTOP

	-- Blue flag
	local bflag = v.cachePatch("BFLAGICO")
	local BFLG_POS_X = (BASEVIDWIDTH/2) - SEP - (bflag.width/4)
	local BFLG_POS_Y = YPOS + 4

	-- Red flag
	local rflag = v.cachePatch("RFLAGICO")
	local RFLG_POS_X = (BASEVIDWIDTH/2) + SEP - (bflag.width/4)
	local RFLG_POS_Y = YPOS + 4

	-- Drawing the flags at the top of screen
	v.drawScaled(BFLG_POS_X*FRACUNIT, BFLG_POS_Y*FRACUNIT, FRACUNIT/2, bflag, patch_flags)
	v.drawScaled(RFLG_POS_X*FRACUNIT, RFLG_POS_Y*FRACUNIT, FRACUNIT/2, rflag, patch_flags)

	-- Draw player depended flag icons ,etc
	drawFlagfromP(v)
end

-- Draws flag icons on top of screen, scores, etc.
F.TeamScoreHUD = function(v, p, cam)
	if hud.enabled("teamscores") then
		hud.disable("teamscores")
	end

	if not G_GametypeHasTeams() then return end
	ranking = false
	cctf_hud(v, p, cam)
end

-- Draws flag next to players' icons, shows the flag power-up icon, etc.
F.RankingHUD = function(v)
	-- Ensure that the gametype is custom ctf!
	if gametype ~= GT_BATTLECTF then return end

	ranking = true
	cctf_hud(v)

-- TODO: RE-code all of the ranking that shows up when you press tab

	-- Draws flag icon next to flag holder when showing rankings
	local bflagico = v.cachePatch("BFLAGICO")
	local rflagico = v.cachePatch("RFLAGICO")   

	local redplayers = 0
	local blueplayers = 0
	local x, y = 0--40, 32

	local players_sorted = {}
	for p in players.iterate do
		table.insert(players_sorted, p)
	end

	-- Properly sort players
	-- TODO: This probably still won't work.. what to do?
	-- Maybe recode the entirety of rankings i guess? :shrug:
	table.sort(players_sorted, function(a, b)
		if a.score == b.score then
		return #a > #b
		else
		return (a.score > b.score)
		end
	end)

	for i=1, #players_sorted do
		local p = players_sorted[i]
		if p.spectator then continue end
		--if p.ctfteam == 0 then continue end

		local cond = (redplayers <= 9 or blueplayers <= 9)
		if p.ctfteam == 1 then
			redplayers = $+1
			--if (redplayers > 8) then continue end
			if cond then 
				x = 32 + (BASEVIDWIDTH/2)
				y = (redplayers * 16) + 16
			else
				x = 14 + (BASEVIDWIDTH/2)
				y = (redplayers * 9) + 20
			end
		elseif p.ctfteam == 2 then
			blueplayers = $+1
			--if (blueplayers > 8) then continue end
			if cond then
				x = 32
				y = (blueplayers * 16) + 16
			else
				x = 14
				y = (blueplayers * 9) + 20
			end
		else 
			continue
		end

		local iconscale = cond and FRACUNIT/2 or FRACUNIT/4
		local fx = cond and x-28 or x-10
		local fy = cond and y-4 or y

		if p.gotflag & GF_REDFLAG then -- holds red flag
			v.drawScaled(fx*FRACUNIT, fy*FRACUNIT, iconscale, rflagico)
		elseif p.gotflag & GF_BLUEFLAG then --holds blue flag
			v.drawScaled(fx*FRACUNIT, fy*FRACUNIT, iconscale, bflagico)
		end
	end

	--[[ TODO: 32 players tab ranking draw, when the players too much ( use condition)
	for p in players.iterate do
		if (p.spectator) then continue end
		if p.ctfteam == 1 then	  -- red
			redplayers=$+1
			x = 14 + (BASEVIDWIDTH/2)
			y = (redplayers * 9) + 20
		elseif p.ctfteam == 2 then      -- blue
			blueplayers=$+1
			x = 14
			y = (blueplayers * 9) + 20
		else			    -- black
			continue
		end

		if p.gotflag & GF_REDFLAG then -- holds red flag
			v.drawScaled((x-10)*FRACUNIT, (y)*FRACUNIT, FRACUNIT/2, rflag)
		elseif p.gotflag & GF_BLUEFLAG then --holds blue flag
			v.drawScaled((x-10)*FRACUNIT, (y)*FRACUNIT, FRACUNIT/2, bflag)
		end
	end
	--]]
end

local lerpamt = FRACUNIT
F.CapHUD = function(v)
	if (gametype ~= GT_BATTLECTF) and not(B.DiamondGametype() or B.RubyGametype()) then
		return
	end
	
	--An attempt to look exactly like the hardcode cecho
	if not(F.GameState.CaptureHUDTimer) then --... Except for the text easing in.
		lerpamt = FRACUNIT
	else
		local trans = 0
		if (F.GameState.CaptureHUDTimer <= 20) then
			trans = V_10TRANS * ((20 - F.GameState.CaptureHUDTimer) / 2)
		end
		local name = F.GameState.CaptureHUDName
		local team = F.GameState.CaptureHUDTeam
		local red = "\x85"
		local blue = "\x84"
		local magenta = "\x81"
		local orange = "\x87"
		local flagtext
		local chatcolor = 0
		if G_GametypeHasTeams() then
			if (team == 1) then
				name = red + $
				flagtext = blue+"BLUE FLAG"
			else
				name = blue + $
				flagtext = red+"RED FLAG"
			end
		else
			chatcolor = team --for diamond
		end
		if B.DiamondGametype() then
			flagtext = orange+"WARP TOPAZ"
		elseif B.RubyGametype() then
			flagtext = magenta+"PHANTOM RUBY"
		end
		local x = 160
		local y = B.Exiting and 160 or 66
		lerpamt = B.FixedLerp(0,FRACUNIT,$*90/100)
		local subtract = B.FixedLerp(0,180,lerpamt)
		v.drawString(x-subtract, y, name, trans|V_ALLOWLOWERCASE|chatcolor, "center")
		v.drawString(x+subtract, y + 12, "CAPTURED THE "+flagtext+"\x80.", trans, "center")
		F.GameState.CaptureHUDTimer = $ - 1
	end
end
