//separate hud in case someone wants to polish it up
local B = CBW_Battle

B.TagPreHUD = function(v, player, cam)
	if not B.TagGametype()
		return
	end
	
	if B.TagPreTimer > 0
		local x = v.width() / v.dupx() / 2
		local y = v.height() / v.dupy() / 5
		local flags = V_SNAPTOTOP | V_PERPLAYER | V_ALLOWLOWERCASE
		local text = "\x80" .. tostring(B.TagPreTimer / TICRATE + 1) .. 
				" seconds until the Taggers are released!"
		v.drawString(x, y, text, flags, "center")
	end
end

B.TagRankHUD = function(v)
	if gametype != GT_BATTLETAG
		return
	end
	
	for player in players.iterate do
		if player.battletagIT
			v.drawString(14, 5, "placeholder", V_PERPLAYER, "center")
		end
	end
end