//separate hud in case someone wants to polish it up
local B = CBW_Battle

local BASEVIDWIDTH = 320
B.TagGenHUD = function(v, player, cam)
	if not B.TagGametype()
		return
	end
	
	/*if player.battletagIT
		//blindfold taggers
		if player.BTblindfade > 0 and camera2 == nil
			v.fadeScreen(31, player.BTblindfade)
		end
	end*/
	local flags = V_SNAPTOTOP | V_PERPLAYER | V_ALLOWLOWERCASE
	--local x = v.width() / v.dupx() / 2
	if B.TagPreTimer > 0
		--local y = v.height() / v.dupy() / 5
		local text = "\x80" .. tostring(B.TagPreTimer / TICRATE + 1) .. 
				" seconds until the Taggers are released!"
		v.drawString(BASEVIDWIDTH/2, 32, text, flags, "center")
	end
	--radar function
	if B.TagPreRound > 1 and (timelimit * 60 * TICRATE - player.realtime <= 180 * TICRATE)
		/*local px = player.realmo.x
		local py = player.realmo.y
		local pz = player.realmo.z
		local temp
		local radar = INT32_MAX
		for otherplayer in players.iterate do
			if not B.IsValidPlayer(otherplayer) or otherplayer == player or
					B.MyTeam(player, otherplayer)
				continue
			end
			local mo = otherplayer.realmo
			local h_dist = R_PointToDist2(px, py, mo.x, mo.y)
			temp = R_PointToDist2(0, pz, h_dist, mo.z)
			if temp < radar
				radar = temp
			end
		end
		local y = v.height() / v.dupy()
		y = $ - $ / 5
		if radar == INT32_MAX
			v.drawString(x, y, "No Players Nearby", flags | V_GRAYMAP, "center")
		else
			radar = $ / (FRACUNIT * 60)
			if radar <= 20
				flags = $ | V_REDMAP
			elseif radar <= 60
				flags = $ | V_YELLOWMAP
			elseif radar <= 180
				flags = $ | V_GREENMAP
			else
				flags = $ | V_GRAYMAP
			end
			v.drawString(x, y, tostring(radar) .. "m", flags, "center")
		end*/

		local opponents = (player.battletagIT and B.TagRunners) or B.TagTaggers
		local radar1 = v.cachePatch("TGPLYR1")
		local radar2 = v.cachePatch("TGPLYR2")
		local radar3 = v.cachePatch("TGPLYR3")
		local radar4 = v.cachePatch("TGPLYR4")
		local radar5 = v.cachePatch("TGPLYR5")
		local radar6 = v.cachePatch("TGPLYR6")
		local radarColor = {radar1,radar2,radar3,radar4,radar5,radar6}
		local proxBeep = {50,50,40,20,10,5}
		local beeps = {}
		local graphic = radar1
		local skincolor = SKINCOLOR_GREY
		for i=1,#opponents do
			if not(opponents[i].mo and opponents[i].mo.valid) then continue end
			if opponents[i] == player then continue end
			if opponents[i].playerstate ~= PST_LIVE then continue end
			local hori = (152 - 9*(#opponents-1)) + (18*(i-1))
			local proximity = B.GetProximity(player.mo, opponents[i].mo)
			if proximity > 1 then
				table.insert(beeps, {proximity=proximity, color=radarColor[proximity], skincolor=opponents[i].skincolor})
			end
		end

		if #beeps then
			table.sort(beeps, function(a, b) return a.proximity > b.proximity end)
			graphic = beeps[1].color
			skincolor = beeps[1].skincolor
		end
		v.draw(BASEVIDWIDTH/2, FRACUNIT*50, graphic, V_SNAPTOTOP|V_PERPLAYER, v.getColormap(0, skincolor))

	end
	//anti-AFK warnings
	if player.BT_antiAFK <= TICRATE * 30 and player.BT_antiAFK > 0
		local warning = "Move or be spectator in " ..
				tostring(player.BT_antiAFK / TICRATE) .. " seconds!"
		v.drawString(x, v.height() / v.dupy() / 2, warning, flags | V_REDMAP, 
				"center")
	end
end

B.TagRankHUD = function(v)
	if gametype != GT_BATTLETAG then
		return
	end

	-- Draw "IT" (Modified from F.RankingHUD)
	local plrs = 0
	local x, y = 0 --40, 32

	local players_sorted = {}
	for p in players.iterate do
		table.insert(players_sorted, p)
	end

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

		local cond = (not CV_FindVar("compactscoreboard").value) and (plrs <= 9)
		plrs = $+1
		if cond then
			x = 32
			y = (plrs * 16) + 16
		else
			x = 14
			y = (plrs * 9) + 20
		end

		local iconscale = cond and FRACUNIT/2 or FRACUNIT/4
		local fx = cond and x-28 or x-10
		local fy = cond and y-4 or y

		if p.battletagIT then
			v.drawScaled(fx*FRACUNIT, fy*FRACUNIT, iconscale, v.cachePatch("TAGICO"))
		end
	end

	-- Blindfold
	/*for player in players.iterate do
		if player.battletagIT and displayplayer == player and player.BTblindfade > 0 and camera2 == nil
			v.fadeScreen(31, player.BTblindfade)
		end
	end*/
end