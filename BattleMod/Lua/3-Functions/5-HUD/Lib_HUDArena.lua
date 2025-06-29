local B = CBW_Battle
local frameA = A --cry
local A = B.Arena
local CV = B.Console

local testhud = 0

--Screen, team properties
local screenwidth,team_width,team_centergap

--Placement suffixes
local post = {"st","nd","rd","th","th","th","th","th","th","th"}

--Shield patches
local shpatch = function(n)
	if n==SH_WHIRLWIND then return "ARSHWIND" end
	if n==SH_ARMAGEDDON then return "ARSHARMG" end
	if n==SH_ELEMENTAL then return "ARSHELMT" end
	if n==SH_ATTRACT then return "ARSHATRC" end
	if n==SH_PINK then return "ARSHLOVE" end
	if n==SH_FLAMEAURA then return "ARSHFLAM" end
	if n==SH_BUBBLEWRAP then return "ARSHBUBL" end
	if n==SH_THUNDERCOIN then return "ARSHLITN" end
	if n&SH_FORCE then return "ARSHFORC" end
	if n ~= 0 then return "ARSHPITY" end --Default
end

local ringpatch = function(player)
	if 	(player.actionstate and player.rings)
		or (not(player.rings) and leveltime&4)
	then
		return "ARRINGRD"
	end
	if not(player.actioncooldown) then
		return "ARRINGYL"
	end
	return "ARRINGGR"
end


local f = FRACUNIT
local m = 1 --HUD size multiplier
--Set offsets
local xoffset = 0
local condensed = 0
local condense_threshold = 9 --We can only go up to this many players before the HUD becomes illegible with extra info
local condense_threshold2 = 13
local team_condense_threshold = 4
local team_condense_threshold2 = 6
local xshift1 = 10
local xshift2 = 10
local xshift3 = -4
local yoffset = 0
local xstart = 0
-- local xstart = 0
local left = 0
local right = 10
local bottom = 12
local color
local leftalign = "thin-right"
local rightalign = "thin"
local text = ""

local headw,headx,heady,heads,flags,
	livesx,livesy,livess,livesn,livesa,livesx2,livesy2,livesf,
	ringx,ringx2,ringy,rings,ringa,
	shieldw,shieldx,shieldy,shields,shieldf,shielda,
	stockx,stocky,stockn,stocks,stocka,
	scorex,scorey,scorea

local function setoffsets(player,m)
	flags = V_HUDTRANS|V_SNAPTOTOP--|V_PERPLAYER
	if not(player.mo and player.mo.health) then
		flags = V_SNAPTOTOP|V_HUDTRANSHALF--|V_PERPLAYER
	end
	--Head
	headw = 8*m
	headx = -headw/2
	heady = 6*m
	heads = f/2*m
	--Lives
	livess = f/3
	livesx = -headw/2-3
	livesy = 8*m+4
	livesy2 = 7*m
	if not(condensed) then
		livesy2 = $+3
	end
	livesx2 = -headw/2+1
	livesn = 6
	livesa = "small"
	livesf = V_HUDTRANS|V_SNAPTOTOP|V_FLIP--|V_PERPLAYER
	--Ring
	if not(condensed) then
		ringx = 1*m
		ringx2 = ringx + 6
	else
		ringx = 1
		ringx2 = ringx + 5
	end
	ringy = 2
	rings = f/2
	ringa = "small"
	--Shield
	shieldw = 4*m
-- 	shieldx = -2*m
	if not(condensed) then
		shieldy = headw/2-1
		shieldx = 1*m
	else
		shieldy = 6
		shieldx = 2
	end
	shields = f/2*m
	-- shieldf = V_SNAPTOTOP|V_PERPLAYER|V_HUDTRANSHALF
	shieldf = flags
	shielda = "left"
	--Shield Stock
	stockx = shieldw+shieldx+1
	stocky = shieldy
	stockn = 2
	stocks = f/2
	stocka = "left"
	--Score
	scorex = livesx-4
	scorey = livesy2
	scorea = "small"
end

B.DrawPlayerInfo = function(v, player, x, y, flags, textalign, isNameCapped)
	local scale = FRACUNIT*3/4
	local flip = (flags & V_SNAPTORIGHT) and -1 or 1
	
	--RINGS
	local patch = ringpatch(player)
	local text
	if patch == "ARRINGYL" then
		text = "\x80"
	elseif patch == "ARRINGRD" then
		if player.rings then
			text = "\x82"
		else
			text = "\x85"
		end
	else
		text = "\x86"
	end

	--NAME
	local name = G_GametypeHasTeams() and B.GetPlayerText(player) or player.name
	local capped_max_letters = 12
	if isNameCapped and string.len(name) > capped_max_letters then
		name = string.sub(name, 1, capped_max_letters-3) .. "..."
	end

	--Draw
	v.drawString(x, y-8, name, flags|V_HUDTRANS, textalign)
	local wtf = 0
	if flip < 0 then wtf = -8 end -- probably patch.width
	v.drawString(x+(8*flip), y, text..player.rings, flags|V_HUDTRANS, textalign)
	x = $*FU
	y = $*FU
	v.drawScaled(x+(wtf*FU), y, scale, v.cachePatch(patch), flags|V_HUDTRANS)

	--Life heads
	local headflags = flags
	local ouchy = 0
	local blink = 0
	
	if P_PlayerInPain(player) then --Add shake if the player is taking damage
		local choose = {-1,1}
		ouchy = ((leveltime&1) and 1 or -1) * FRACUNIT
		headflags = V_HUDTRANSHALF
	elseif not(P_PlayerInPain(player)) and player.powers[pw_flashing] and not(B.PreRoundWait()) then
		blink = leveltime&1 -- Blink if flashing
	elseif player.playerstate ~= PST_LIVE then --Transparency for dead/respawning players
		headflags = V_HUDTRANSHALF
	else
		headflags = V_HUDTRANS
	end
	if not(blink) then
		if (flip > 0) then headflags = $ | V_FLIP end
		local mo = player.mo
		if mo then
			local colormap = v.getColormap(mo.skin, mo.color)
			local sprite = v.getSprite2Patch(mo.skin, SPR2_LIFE)
			local scale = scale
			if skins[mo.skin].highresscale ~= FRACUNIT
				scale = FixedMul($, skins[mo.skin].highresscale)
			end
			v.drawScaled(x-(10*FRACUNIT*flip), y+ouchy, scale, sprite, flags|headflags, colormap)
		end
	end
	v.drawString((x/FU)-(16*flip), y/FU, player.lives, flags|V_HUDTRANS, textalign)
	
	x = $+(30*FU*flip)
	x = $+(wtf*FU)

	--Shields
	if player.powers[pw_shield] & SH_NOSTACK then
		local shieldpatch = shpatch(player.powers[pw_shield&SH_NOSTACK])
		v.drawScaled(x, y, scale, v.cachePatch(shieldpatch), flags|V_HUDTRANS)
	end
	if CV.ShieldStock.value then
		local n = #player.shieldstock
		while n >= 1 do
			local xoffset = 8*n*FU*flip
			local shieldpatch = v.cachePatch(shpatch(player.shieldstock[n]))
			v.drawScaled(x+xoffset,y,scale*3/4,shieldpatch,flags|V_HUDTRANS)
			n = $-1
		end
	end
end

A.MyStocksHUD = function(v, player)
	if 	player.spectator
		or not G_GametypeUsesLives()
		or not B.ArenaGametype()
		or not CV.FindVarString("battleconfig_hud", {"New", "Minimal"})
		or not B.HUDMain
		or not player.mo
	then
		return
	end
	
	local flags = V_PERPLAYER|V_SNAPTOTOP
	local stocks = player.lives
	if player.revenge then
		stocks = 0
	end
	local stock_sep = 14*FRACUNIT
	local x = 160*FRACUNIT
	local y = 40*FRACUNIT
	local maxstocks = max(stocks, CV.SurvivalStock.value)
	for i = 0, maxstocks-1 do
		local offset = -((maxstocks - 1) * stock_sep / 2) + (i * stock_sep)
		local black = v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK)
		local patch = v.getSprite2Patch(player.mo.skin, SPR2_LIFE)
		local scale = FRACUNIT*3/4
		if skins[player.mo.skin].highresscale ~= FRACUNIT
			scale = FixedMul($, skins[player.mo.skin].highresscale)
		end
		v.drawScaled(x + offset + scale, y + scale, scale, patch, flags | V_HUDTRANS | V_FLIP, black)
		if stocks > i then
			v.drawScaled(x + offset - scale, y - scale, scale, patch, flags | V_HUDTRANS | V_FLIP, v.getColormap(player.mo.skin, player.skincolor))
		end
	end
	local maxshards = 3
	local shard_sep = stock_sep*2/3
	y = $ + (4*FRACUNIT)
	for i = 0, maxshards-1 do
		local offset = -((maxshards - 1) * shard_sep / 2) + (i * shard_sep)
		local black = v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK)
		local patch = v.getSpritePatch("SHRD", frameA, 0, ANGLE_45)
		local scale = FRACUNIT/2
		v.drawScaled(x + offset + scale, y + scale, scale, patch, flags | V_HUDTRANSHALF | V_FLIP, black)
		if (player.lifeshards or 0) > i then
			v.drawScaled(x + offset - scale, y - scale, scale, patch, flags | V_HUDTRANS | V_FLIP, v.getColormap(TC_RAINBOW, SKINCOLOR_PURPLE))
		end
	end

	--Now draw all of the other player's info
	--[[
	if splitscreen then
		return
	end
	local playercount = {left = 0, right = 0}  
	local basepanning = 20
	local starty = 30
	local players_per_row = v.height() > 240 and 16 or 8
	local solo_two_rows = false

	-- First pass: count players
	for p in players.iterate do
		if player == p or p.spectator then continue end
		
		local isLeft
		if G_GametypeHasTeams() then
			isLeft = (p.ctfteam == 1)
		else
			isLeft = ((playercount.left + playercount.right) % 2 == 0)
		end
		
		playercount[isLeft and "left" or "right"] = $ + 1
	end

	if playercount.left + playercount.right <= players_per_row and not G_GametypeHasTeams() then
		playercount.right = $ + playercount.left
		playercount.left = 0
	end

	-- Second pass: draw players with correct spacing
	local drawcount = {left = 0, right = 0}
	for p in players.iterate do
		if player == p or p.spectator then continue end
		
		local isLeft
		if G_GametypeHasTeams() then
			isLeft = (p.ctfteam == 1)
		elseif playercount.left then
			isLeft = ((drawcount.left + drawcount.right) % 2 == 0)
		end
		
		local side = isLeft and "left" or "right"
		local rownum = drawcount[side] / players_per_row
		local panning = basepanning + (64 * rownum)
		local spacing_increments = v.height() > 240 and 4 or 2
		local spacing = max(16, 32 - (max(0, playercount[side] - 4) * spacing_increments))
		local realspacing = (spacing * drawcount[side]) - (spacing * rownum * players_per_row)
		local isNameCapped = playercount[side] > 8
		local enoughSpace = (v.height() > 240 or drawcount[side] < players_per_row) 
		
		if isLeft and enoughSpace then
			B.DrawPlayerInfo(v, p, panning, starty+realspacing, flags, "thin", isNameCapped)
		elseif enoughSpace then
			B.DrawPlayerInfo(v, p, 320-panning, starty+realspacing, flags|V_SNAPTORIGHT, "thin-right", isNameCapped)
		end
		drawcount[side] = $ + 1
	end
	]]
end

local sep = 38
local DrawPlacement = function(v, side, p, tie)
	if not (p.rank and p.rank > 0) then return end

	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER

	local xoffset = 160
	local yoffset = 32

	local name_yoffset = 1
	local rank_yoffset = name_yoffset + 4
	local score_yoffset = rank_yoffset + 9

	local doflip = 0
	local xmult = 1
	if side == 0 then
		doflip = V_FLIP
		xmult = -1
	end

	local facepatch = v.getSprite2Patch(p.skin, SPR2_SIGN)
	local facepos = 0
	if B.SkinVars[skins[p.skin].name] then
		facepos = B.SkinVars[skins[p.skin].name].hud_facepos or 0
	end

	local col = p.skincolor
	if p.rings == 0 then
		col = SKINCOLOR_PITCHBLACK
	end

	local name
	local namecol = 0

	if tie > 1 then
		name = tie.."-WAY TIE!"
		if (leveltime/4)%2 then
			namecol = V_YELLOWMAP
		else
			namecol = V_BLUEMAP
		end
	else
		name = p.name
		local maxnamelen = 15
		if (string.len(p.name) > maxnamelen) then
			name = string.sub(p.name, 0, maxnamelen-2).."..."
		end
	end

	local rank = p.rank
	local color = V_GRAYMAP
	if rank == 1 then
		text = "\x82"..rank
		color = V_YELLOWMAP
	elseif rank == 2 then
		text = "\x8c"..rank
		color = 0
	elseif rank == 3 then
		text = "\x87"..rank
		color = V_BROWNMAP
	else
		text = "\x86"..rank
	end
	while rank > 10 do
		rank = $-10
	end
	
	v.draw(xoffset + sep * xmult, yoffset, v.cachePatch("HUD_FADBA2"), V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER|V_REVERSESUBTRACT)
	
	local scale = FRACUNIT/2
	local hires = skins[p.skin].highresscale
	if hires ~= FRACUNIT
		scale = FixedMul($, hires)
	end
	v.drawScaled((xoffset * FRACUNIT) + (facepos * scale * -xmult) + (sep * FRACUNIT * xmult), (yoffset * FRACUNIT) - hires/2, scale, facepatch, flags, v.getColormap(p.skin, p.skincolor))
	v.drawString(xoffset + sep * xmult, yoffset + name_yoffset, name, flags|V_ALLOWLOWERCASE|namecol, "small-center")
	
	text = $..post[rank]
	v.drawString(xoffset + sep * xmult, yoffset + rank_yoffset, text, flags|V_ALLOWLOWERCASE|color, "center")
	v.drawString(xoffset + sep * xmult, yoffset + score_yoffset, p.score.."p", flags|V_ALLOWLOWERCASE, "thin-center")
end

A.PlacementHUD = function(v, player)
	if 	player.spectator
		or G_GametypeUsesLives()
		or G_GametypeHasTeams()
		or not CV.FindVarString("battleconfig_hud", {"New", "Minimal"})
		or (gametype ~= GT_ARENA and gametype ~= GT_RUBYCONTROL)
	then
		return
	end
	
	local bestrank = 64
	local tie = 1
	local leader = nil
	--print("---RANKING CHECK---")
	for p in players.iterate() do
		if p.rank then
			--print(p.name.." (rank "..p.rank..")")
			if p.rank <= bestrank then
				if (p.rank == bestrank) then
					tie = $ + 1
				elseif p ~= player then
					bestrank = p.rank
					tie = 1
					--print("new best rank, resetting ties")
				end
				if p ~= player then
					leader = p
					--print("new leader")
				end
				--print(tie.."-way tie.")
			end
		end
	end
	DrawPlacement(v, 0, player, 1)
	if leader then
		DrawPlacement(v, 1, leader, tie)
	end
end

A.AllFightersHUD = function(v,player,cam)
	if not (B.HUDMain) then return end
	if not(B.ArenaGametype()) then return end
	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then
		hud.enable("score")
		return
	end
	hud.disable("score")
	if splitscreen then return end
	
	local count = #A.Survivors
	local rcount = #A.RedSurvivors
	local bcount = #A.BlueSurvivors
	if count and testhud then 
		count = CV.SurvivalStock.value
		rcount = CV.SurvivalStock.value
		bcount = CV.SurvivalStock.value
	end
	local lerp_max = count+1
	local red_lerp_max = rcount+1
	local blue_lerp_max = bcount+1
	local r = 0
	local b = 0	
	local teams = G_GametypeHasTeams()
	--Draw all survivors
	for n = 1, count do
		local p = A.Survivors[n]
		if not(G_GametypeUsesLives()) then
			p = A.Placements[n]
		end
		if testhud then
			p = A.Survivors[1]
		end
		if not(p and p.valid and p.mo and p.mo.valid) then continue end
		--Do condensation and boundaries/stretch
		condensed = 0
		screenwidth = 340
		team_centergap = 40
		yoffset = 0

		if 		(teams and p.ctfteam == 1 and rcount >= team_condense_threshold2)
				or (teams and p.ctfteam == 2 and bcount >= team_condense_threshold2)
				or (count >= condense_threshold2)
		then 
			condensed = 2
			screenwidth = 320
			team_centergap = 64
			yoffset = 4

		elseif 	(teams and p.ctfteam == 1 and rcount >= team_condense_threshold)
				or (teams and p.ctfteam == 2 and bcount >= team_condense_threshold)
				or (count >= condense_threshold)
		then 
			condensed = 1
			yoffset = 4
		end	
		team_width = (screenwidth-team_centergap)/2
		local lerp_amt 
		--FFA offsets
		if not(teams) then
			--Figure out how far along we are
			lerp_amt = f*n/lerp_max
			xoffset = screenwidth*lerp_amt/f+xstart			
		end
		--Team offsets
		if teams then
			--Blue Team
			if p.ctfteam == 2 then 
				b = $+1
				lerp_amt = f*b/blue_lerp_max
				xoffset = team_width*lerp_amt/f+xstart
			end
			--Red Team
			if p.ctfteam == 1 then
				r = $+1
				lerp_amt = f*r/red_lerp_max
				xoffset = team_width+team_centergap-xstart
					+team_width*lerp_amt/f
			end
			--This should never happen, but in case it does...
			if p.ctfteam ~= 1 and p.ctfteam ~= 2 then continue end
		end
		if condensed == 0 then
			xoffset = $-xshift1
			setoffsets(p,2)
		elseif condensed == 1 then
			xoffset = $-xshift2
			setoffsets(p,1)
		elseif condensed == 2 then
			xoffset = $-xshift3
			setoffsets(p,1)
		end		
		
		--Get some vars
		local headflags = flags
		local ouchy = 0
		local blink = 0
		local hires = skins[p.skin].highresscale
		--Add shake if the player is taking damage
		if P_PlayerInPain(p) then
			ouchy = ((leveltime&1) and 1 or -1)
			headflags = V_HUDTRANSHALF|V_SNAPTOTOP--|V_PERPLAYER
		end
		--Blink frames for invuln players
		if not(P_PlayerInPain(p)) and p.powers[pw_flashing] and not(B.PreRoundWait()) then
			blink = leveltime&1
		end
		--Transparency for dead/respawning players
		if p.playerstate ~= PST_LIVE then
			headflags = V_HUDTRANSHALF|V_SNAPTOTOP--|V_PERPLAYER
		end
		
		--Draw debug
-- 		v.drawString(xoffset,yoffset,"P"..n,flags,"small")
		--Draw head
		if not(blink) then
			v.drawScaled((xoffset+headx)*f, (yoffset+heady+ouchy)*f, FixedMul(heads, hires), v.getSprite2Patch(p.mo.skin, SPR2_LIFE),
				headflags, v.getColormap(p.mo.skin, p.mo.color)
			)
		end

		--Do shield
		local sh = shpatch(p.powers[pw_shield&SH_NOSTACK])
		if not(condensed == 2) and sh then
			v.drawScaled((xoffset+shieldx)*f,(yoffset+shieldy+ouchy)*f,shields,
				v.cachePatch(sh),shieldf)
		end
		
		
		--Get rings
		if not(condensed == 2) then
			local patch = ringpatch(p)
			v.drawScaled((xoffset+ringx)*f,(yoffset+ringy)*f,rings,
				v.cachePatch(patch),flags)
			--Text color
			if patch == "ARRINGYL" then
				text = "\x80"
			elseif patch == "ARRINGRD" then
				if p.rings then
					text = "\x82"
				else
					text = "\x85"
				end
			else
				text = "\x86"
			end
			--Text symbols
			if condensed and p.rings > 99 then
				text = $.."**"
			else
				text = $..p.rings
			end
			v.drawString(xoffset+ringx2,yoffset+ringy,text,flags,ringa)
		end
		
		--Get shield stock
		if not(condensed == 2) and CV.ShieldStock.value then
			local n = #p.shieldstock
			while n >= 1 do
				v.drawScaled((xoffset+stockx+stockn*(n-1))*f,(yoffset+stocky)*f,stocks,
					v.cachePatch(shpatch(p.shieldstock[n])),flags)
				n = $-1
			end
		end

		--Get lives/score
		if G_GametypeUsesLives() then
			if condensed == 0 then
				if p.lives < 6 then
					for n = 1,p.lives do
						v.drawScaled((xoffset+livesx+livesn*(n-1))*f,(yoffset+livesy)*f, FixedMul(livess, hires),
							v.getSprite2Patch(p.mo.skin, SPR2_LIFE),
							livesf, v.getColormap(p.mo.skin, p.skincolor))
					end
				else
					v.drawScaled((xoffset+livesx)*f,(yoffset+livesy)*f, FixedMul(livess, hires),
						v.getSprite2Patch(p.mo.skin, SPR2_LIFE),
						livesf, v.getColormap(p.mo.skin, p.skincolor))
					text = p.lives
					livesy2 = $
					v.drawString(xoffset+livesx2,yoffset+livesy2,text,livesf,livesa)
				end
			else
				text = p.lives
				livesy2 = $
				v.drawString(xoffset+livesx2,yoffset+livesy2,text,livesf,livesa)
			end
		elseif (not(condensed == 2) or p.rank < 4) and p.rank then
			local t = p.rank

			if t == 1 then
				text = "\x82"..t
			elseif t == 2 then
				text = "\x8c"..t
			elseif t == 3 then
				text = "\x87"..t
			else
				text = "\x86"..t
			end
			while t > 10 do t = $-10 end
			text = $..post[t]
			
			v.drawString(xoffset+scorex,yoffset+scorey,text,flags,scorea)
		end
	end
end

A.BountyHUD = function(v, player, cam)
	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then return end
	if not (player.realmo and B.ArenaGametype() and server) then return end
	if not (B.HUDMain) then return end
	if B.PreRoundWait() then return end
	if not (A.Bounty) then return end
	if player == A.Bounty then return end
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local xoffset = 152
	local yoffset = 48
	local angle
	local cmpangle
	local compass
	local color
	
	local xx = cam.x
	local yy = cam.y
	local zz = cam.z
	local lookang = cam.angle
	if (player.spectator or not cam.chase) and (player.realmo and player.realmo.valid) then --Use the realmo coordinates when not using chasecam
		xx = player.realmo.x
		yy = player.realmo.y
		zz = player.realmo.z
		lookang = player.cmd.angleturn<<16
	end
	
	local bmo = A.Bounty.mo
	if (bmo and bmo.valid) then
		if twodlevel then
			angle = R_PointToAngle2(xx, zz, bmo.x, bmo.z) - ANGLE_90 + ANGLE_22h
		else
			angle = R_PointToAngle2(xx, yy, bmo.x, bmo.y) - lookang + ANGLE_22h
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
		
		compass = v.getSpritePatch("CMPS",frameA,max(min(cmpangle,8),1))
		color = v.getColormap(TC_DEFAULT,SKINCOLOR_GOLD)
		--Draw
		v.draw(xoffset,yoffset,compass,flags,color)
	end
end
