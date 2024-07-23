//separate hud in case someone wants to polish it up
local B = CBW_Battle

B.TagGenHUD = function(v, player, cam)
	if not B.TagGametype()
		return
	end
	
	if player.battletagIT
		//blindfold taggers
		if player.BTblindfade > 0 and camera2 == nil
			v.fadeScreen(31, player.BTblindfade)
		end
	end
	local flags = V_SNAPTOTOP | V_PERPLAYER | V_ALLOWLOWERCASE
	local x = v.width() / v.dupx() / 2
	if B.TagPreTimer > 0
		local y = v.height() / v.dupy() / 5
		local text = "\x80" .. tostring(B.TagPreTimer / TICRATE + 1) .. 
				" seconds until the Taggers are released!"
		v.drawString(x, y, text, flags, "center")
	end
	//radar function
	if B.TagPreRound > 1
		local px = player.mo.x
		local py = player.mo.y
		local pz = player.mo.z
		local temp
		local radar = INT32_MAX
		for otherplayer in players.iterate do
			if not B.IsValidPlayer(otherplayer) or otherplayer == player or
					B.MyTeam(player, otherplayer)
				continue
			end
			local mo = otherplayer.mo
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
			radar = $ / FRACUNIT
			if radar <= 1000
				flags = $ | V_REDMAP
			elseif radar <= 3000
				flags = $ | V_YELLOWMAP
			elseif radar <= 7500
				flags = $ | V_GREENMAP
			else
				flags = $ | V_GRAYMAP
			end
			v.drawString(x, y, tostring(radar) .. "fu", flags, "center")
		end
	end
end

B.TagRankHUD = function(v)
	if gametype != GT_BATTLETAG
		return
	end
	
	for player in players.iterate do
		if player.battletagIT
			//v.drawString(14, 5, "placeholder", V_PERPLAYER, "center")
			if displayplayer == player and player.BTblindfade > 0 and 
					camera2 == nil
				v.fadeScreen(31, player.BTblindfade)
			end
		end
	end
end