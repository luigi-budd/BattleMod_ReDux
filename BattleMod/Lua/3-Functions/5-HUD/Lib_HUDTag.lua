//separate hud in case someone wants to polish it up
local B = CBW_Battle

B.TagHUD = function(v, player, cam)
	if not B.TagGametype()
		return
	end
	
	if B.TagPreTimer > 0
		if player.pflags & PF_TAGIT
			local wid = v.width() / v.dupx()
			local hight = v.height / v.dupy()
			v.drawFill(0, 0, wid, hight)
		end
		local x = v.width() / v.dupx() / 2
		local y = v.height() / v.dupy() / 5
		local flags = V_SNAPTOTOP | V_PERPLAYER | V_ALLOWLOWERCASE
		local text = "\x80" .. tostring(B.TagPreTimer / TICRATE + 1) .. 
				" seconds until the Taggers are released!"
		v.drawString(x, y, text, flags, "center")
	end
end