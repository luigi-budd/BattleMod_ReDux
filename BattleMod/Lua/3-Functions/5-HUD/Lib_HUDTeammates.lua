local B = CBW_Battle
local CV = B.Console

B.TeammateHUD = function(v, player)
	if not G_GametypeHasTeams()
	or not player.battleconfig_newhud
	then
		return
	end
	
	local flags = V_PERPLAYER|V_SNAPTOTOP
	local sep = 9*FRACUNIT
	local basesep = 48*FRACUNIT
	local x = 160*FRACUNIT
	local y = 26*FRACUNIT
	local rednum = 0
	local bluenum = 0
	
	for p in players.iterate() do
		local xmult = 1
		local doflip = 0
		local num
		local teamcol
		if (p.ctfteam ~= 1 and p.ctfteam ~= 2) or not p.mo or p.isjettysyn then
			continue
		end
		if p.ctfteam == 1 then
			rednum = $ + 1
			num = rednum
			teamcol = SKINCOLOR_RED
		else
			xmult = -1
			doflip = V_FLIP
			bluenum = $ + 1
			num = bluenum
			teamcol = SKINCOLOR_BLUE
		end
		local offset = (basesep + num * sep) * xmult
		local yoffset = 0
		local scale = FRACUNIT/2
		local black = v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK)
		local playercol = v.getColormap(TC_BLINK, teamcol)
		local color = black
		local trans = V_HUDTRANSHALF
		if p.playerstate == PST_LIVE then
			yoffset = -scale*2
			trans = V_HUDTRANS
			v.drawScaled(x + offset, y, scale, v.getSprite2Patch(p.mo.skin, SPR2_LIFE), flags | trans | doflip, color)
			color = playercol
		end
		
		v.drawScaled(x + offset, y + yoffset, scale, v.getSprite2Patch(p.mo.skin, SPR2_LIFE), flags | trans | doflip, color)
		if p.playerstate == PST_DEAD then
			v.drawScaled(x + offset, y, scale, v.cachePatch("HUD_X"), flags | V_HUDTRANS, v.getColormap(TC_RAINBOW, teamcol))
		end
		if G_GametypeUsesLives() and not p.revenge then
			local stock_sep = 2*FRACUNIT
			local stock_yoff = 3*FRACUNIT + FRACUNIT/2
			local maxstocks = max(p.lives, CV.SurvivalStock.value)
			for i = 0, p.lives-1 do
				local offset2 = -((maxstocks - 1) * stock_sep / 2) + (i * stock_sep)
				local scale2 = FRACUNIT/3
				v.drawScaled(x + offset + offset2, y + stock_yoff + scale2*2, scale2, v.cachePatch("HUD_STOK"), flags | trans, black)
				v.drawScaled(x + offset + offset2, y + stock_yoff, scale2, v.cachePatch("HUD_STOK"), flags | trans, playercol)
			end
		end
	end
end
