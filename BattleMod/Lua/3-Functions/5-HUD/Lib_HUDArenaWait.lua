local B = CBW_Battle
local A = B.Arena
local CV = B.Console

local yo = 152

//Enable/disable spectator controls hud
B.SpectatorControlHUD = function(v,player,cam)
	if not (B.HUDAlt) then return end
	if (not (B.Exiting or B.Timeout or CV.FindVarString("battleconfig_hud", "Minimal"))) and (player.spectatortime != nil
	and (player.spectatortime < TICRATE*9 or (player.spectatortime < TICRATE*10 and player.spectatortime&1)))
		hud.enable("textspectator")
	else
		hud.disable("textspectator")
	end
end

local function roundToMultipleOf5(num)
    local remainder = num % 5
    if remainder >= 3 then
        return num + (5 - remainder)
    else
        return num - remainder
    end
end

A.DangerHUD = function(v, player, cam)
	if B.SuddenDeath and player.BT_antiAFK < 200 then
		local centiseconds = roundToMultipleOf5(G_TicsToCentiseconds(player.BT_antiAFK))
        local formattedCentiseconds = string.format("%02d", centiseconds)
        local t = "DANGER! "..G_TicsToSeconds(player.BT_antiAFK).."."..formattedCentiseconds.."s"
		local f = V_SNAPTOTOP|V_PERPLAYER|V_ALLOWLOWERCASE
		local V_MENACINGFLASH = leveltime%11 < 5 and V_REDMAP or V_INVERTMAP
		v.drawString(160,yo,t,V_MENACINGFLASH|V_HUDTRANS|f,"center")
		if B.ZoneObject and B.ZoneObject.valid and (B.ZoneObject.flags2 & MF2_DONTDRAW) then
			local shake = 1
			local x = 160
			local y = yo
			if not (paused) then
				x = $ + v.RandomRange(-shake,shake)
				y = $ + v.RandomRange(-shake,shake)
			end
			v.drawString(x,y,"\nFight for your life!",V_HUDTRANS|f,"center")
		else
			v.drawString(160,yo,"\nReturn to combat zone!",V_HUDTRANSHALF|f,"center")
		end
	end
end

//Waiting to join
A.WaitJoinHUD = function(v, player, cam)
	if CV.FindVarString("battleconfig_hud", "Minimal") or not (B.HUDAlt) then return end
	if not (gametyperules&GTR_LIVES) or (gametyperules&GTR_FRIENDLY) then return end //Competitive lives only
	if B.Exiting or B.Timeout then return end
	local dead = (player.spectator and not(A.SpawnLives)) or (player.playerstate == PST_DEAD and player.revenge)

	if not (dead) then return A.DangerHUD(v, player, cam) end
	local t = "\x85".."You've been ELIMINATED!"
	local f = V_SNAPTOTOP|V_PERPLAYER|V_ALLOWLOWERCASE
	v.drawString(160,yo,t,V_HUDTRANSHALF|f,"center")
	if CV.Revenge.value == 0 or B.SuddenDeath then
		t = "\n\x80".."You will respawn in the next round"
	else
		t = "\n\x80".."But you can still respawn as a \x86".."jetty-syn"
	end	
	v.drawString(160,yo,t,V_HUDTRANSHALF|f,"center")
end

B.DrawSpriteString = function(v, x, y, scale, font, text, gap, flags, colormap, center, yfloat, yfloatspd, shadow)
	gap = $ or 8*scale
	local x_offset = 0
	local spacebars = 0
	if center and string.len(text) then
		local len = 1+string.len(text)/2
		x_offset = $ - (gap*len)
		if (1+string.len(text)) % 2 == 0 then
			x_offset = $ - gap/2
		end
	end
	for i = 1, string.len(text) do
		local letter = text:sub(i, i)
		x_offset = $ + gap
		if letter == " " then
			spacebars = $+1
			continue --skip remaider of code
		end
		local sprite = v.cachePatch(font..letter)
		local y_offset = 0
		if yfloat then
			yfloatspd = $ or ANG10
			y_offset = sin((leveltime*yfloatspd) + i*yfloatspd) * yfloat
		end
		if shadow then
			v.drawScaled(x + x_offset + (2*FU), y + y_offset + (2*FU), scale, sprite, flags, v.getColormap(TC_DEFAULT, SKINCOLOR_PITCHBLACK))
		end
		local actualcolormap
		if type(colormap) == "table" then
			actualcolormap = v.getColormap(TC_RAINBOW, colormap[i-spacebars])
		else
			actualcolormap = v.getColormap(TC_DEFAULT, colormap)
		end
		v.drawScaled(x + x_offset, y + y_offset, scale, sprite, flags, actualcolormap)
	end
end

--Game set!
local lerpamt = FRACUNIT
local lerpamt2 = FRACUNIT
local exittime = 0
local rainbow = {SKINCOLOR_RED, SKINCOLOR_ORANGE, SKINCOLOR_YELLOW, SKINCOLOR_GREEN, SKINCOLOR_CYAN, SKINCOLOR_BLUE, SKINCOLOR_PURPLE}
local b_rainbow = {SKINCOLOR_BLUE, SKINCOLOR_COBALT, SKINCOLOR_BLUEBELL, SKINCOLOR_ARCTIC, SKINCOLOR_ARCTIC, SKINCOLOR_BLUEBELL, SKINCOLOR_COBALT, SKINCOLOR_BLUE}
local r_rainbow = {SKINCOLOR_CRIMSON, SKINCOLOR_RED, SKINCOLOR_PEPPER, SKINCOLOR_SALMON, SKINCOLOR_PEPPER, SKINCOLOR_RED, SKINCOLOR_CRIMSON}
A.GameSetHUD = function(v,player,cam)
	if not (B.BattleGametype()) or not (B.Exiting) or not (B.HUDAlt) then
		lerpamt = FRACUNIT
		lerpamt2 = FRACUNIT
		exittime = 0
		return
	else
		exittime = $+1
	end
	local a = v.cachePatch("LTFNT065")
	local e = v.cachePatch("LTFNT069")
	local g = v.cachePatch("LTFNT071")
	local m = v.cachePatch("LTFNT077")
	local s = v.cachePatch("LTFNT083")
	local t = v.cachePatch("LTFNT084")
	local exclaim = v.cachePatch("LTFNT033")
	local text1 = {g,a,m,e}
	local x1 = 80
	local y1 = 80
	
	lerpamt = B.FixedLerp(0,FRACUNIT,$*90/100)
	local subtract = B.FixedLerp(0,180,lerpamt)
	local text2 = {s,e,t,exclaim}
	local x2 = 140
	local y2 = 100
	local spacing = 20
	
	local subtract2 = 0
	local delay = TICRATE*3
	if exittime > delay
	and not(player.spectator and not G_GametypeHasTeams()) --spectators only see "GAME SET" in solo gametypes
	then
		lerpamt2 = B.FixedLerp(0,FRACUNIT,$*90/100)
		subtract2 = B.FixedLerp(180,0,lerpamt2)
		local trans = B.TIMETRANS(exittime*2 - delay*2)
		local x3 = 320/2
		if leveltime%2 == 0 and not paused then
			local rainbows = {rainbow, b_rainbow, r_rainbow}
			for _, tbl in ipairs(rainbows) do
				local last = tbl[#tbl]
				for n = #tbl, 2, -1 do
					tbl[n] = tbl[n-1]
				end
				tbl[1] = last
			end
		end
		local finaltext = "COOOOOL"
		local finalcolors = rainbow
		if player.loss then
			finaltext = "TOO BAD"
			finalcolors = SKINCOLOR_CRIMSON
		end
		if G_GametypeHasTeams() and redscore == bluescore then
			finaltext = "TIE GAME"
			finalcolors = SKINCOLOR_WHITE
		end
		if player.spectator and not(finaltext == "TIE GAME") then
			if G_GametypeHasTeams() then
				finaltext = (redscore > bluescore) and "RED" or "BLUE"
				finalcolors = (finaltext == "RED") and r_rainbow or b_rainbow
				finaltext = $.." WINS"
			--[[
			else
				local highestscore = 0
				finaltext = "WHAT"
				for p in players.iterate do
					if p.spectator then
						continue
					end
					if p.score > highestscore then
						highestscore = p.score
						finaltext = p.name.." WINS"
						finalcolors = p.skincolor
					end
					if p.score == highestscore then
						finaltext = "TIE GAME"
						finalcolors = SKINCOLOR_WHITE
					end
				end
			]]
			end
		end
		B.DrawSpriteString(v, x3*FU, y1*FU, FU, "LETTER", finaltext, 22*FU, trans|V_SNAPTOTOP, finalcolors, true, 4, nil, true)
	end

	for n = 1,#text1
		v.drawScaled(FRACUNIT*(x1+spacing*n-subtract),(y1-subtract2)*FRACUNIT,FRACUNIT,text1[n],
			V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
		if text1[n] == m then
			x1 = $+8
		end
	end
	for n = 1,#text2
		v.drawScaled(FRACUNIT*(x2+spacing*n+subtract),(y2-subtract2)*FRACUNIT,FRACUNIT,text2[n],
			V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
	end
end

//Revenge JettySyn
local revengehud = false
A.RevengeHUD = function(v,player,cam)
	if not (B.HUDAlt) then -- Gateway.
		revengehud = false
		return
	end
	if player.revenge and not(revengehud) then
		hud.disable("lives")
		hud.disable("rings")
		revengehud = true
	end
	if not(player.revenge) and revengehud then
		hud.enable("lives")
		hud.enable("rings")
		revengehud = false
	end
end