local B = CBW_Battle
local CV = B.Console

B.TeammateHUD = function(v, player)
	if not G_GametypeHasTeams()
	or not CV.FindVarString("battleconfig_hud", {"New", "Minimal"})
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
	
	local player_self = nil
	local autobalancing = nil
	for p in players.iterate() do
		if p.autobalancing then 
			if p == player then player_self = true end
			autobalancing = true
		end

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

		--Froot Loops (Chaos Rings)
		if gametype == GT_BANK then
			
			for t = 1, 2 do
				local val = 1
				local flip = (t==1 and val) or -val
				for i = 1, 6 do
					local num = i
					local chaosring = B.ChaosRing.LiveTable[num]
					if not(chaosring and chaosring.valid) then continue end
					if not((chaosring.captured and ((chaosring.ctfteam == t) and (((chaosring.fuse) and ((leveltime/6)%2)==1) or not(chaosring.fuse)))) or ((chaosring.target and chaosring.target.valid and chaosring.target.player and (chaosring.target.player.ctfteam == t) and chaosring.target.player.gotcrystal_time) and (leveltime%2)==1)) then continue end
					local patch = v.cachePatch("CHRING"..num)
					v.drawScaled((x-(FRACUNIT*3)+(flip*((FRACUNIT/3)*(28)))*(i+2)), (y+(FRACUNIT*10)), FRACUNIT/2, patch, flags|V_HUDTRANS)
				end
			end
		end

	end

	--// rev: If autobalance is happening, let's tell everyone about it
	local ax = 120
	local ay = 18
	local aflags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER

	--// You are the player being autobalanced
	if player_self and autobalancing then
		local team = player.ctfteam == 1 and "\x85" or "\x84"
		local time = 3 - (player.autobalancing/TICRATE)
		v.drawString(ax-30, ay - 14, team+"You will be autobalanced in: "+time, aflags, "thin")

	--// Someone else is being autobalanced
	elseif not player_self and autobalancing then
		v.drawString(ax, ay - 14, "Rebalancing teams...", aflags, "thin")
	end
end
