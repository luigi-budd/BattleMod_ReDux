local B = CBW_Battle
local A = B.Arena
local CV = B.Console

local yo = 152

//Enable/disable spectator controls hud
B.SpectatorControlHUD = function(v,player,cam)
	if not (B.HUDAlt) then return end
	if player.spectatortime != nil
	and (player.spectatortime < TICRATE*9 or (player.spectatortime < TICRATE*10 and player.spectatortime&1))
		hud.enable("textspectator")
	else
		hud.disable("textspectator")
	end
end

//Waiting to join
A.WaitJoinHUD = function(v, player, cam)
	if not (B.HUDAlt) then return end
	if not (gametyperules&GTR_LIVES) or (gametyperules&GTR_FRIENDLY) then return end //Competitive lives only
	local dead = (player.spectator and not(A.SpawnLives))
		or (player.playerstate == PST_DEAD and player.revenge)
	if not (dead) then return end
	if not(CV.Revenge.value) or B.SuddenDeath then
-- 		local t = "\x85".."You've been ELIMINATED!"
-- 		v.drawString(160,160,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
		local t = "\x85".."Wait until next round to join"
		v.drawString(160,yo,t,V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER,"center")
	elseif CV.Revenge.value then
		local t = "\x85".."You've been ELIMINATED!"
		v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		if B.SuddenDeath
-- 			local t = "\n\x85".."Wait until next round to join"
-- 			v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		else
			t = "\n\x80".."But you can still respawn as a \x86".."jetty-syn"
			v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		end
	end	
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

B.TimeTrans = function(time, speed, minimum, cap, prefix, suffix, debug)
    speed = speed or 1
	prefix = prefix or "V_"
	suffix = suffix or "TRANS"

    local level = (time / speed / 10) * 10
    level = max(10, min(100, level))

    if minimum then level = max($, minimum / 10 * 10) end
	if cap then level = min($, cap / 10 * 10) end
	if debug then print(level) end
    
    if level == 100 then
        return 0
    else
        return _G[prefix .. (100 - level) .. suffix]
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
		local trans = B.TimeTrans(exittime*2 - delay*2)
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