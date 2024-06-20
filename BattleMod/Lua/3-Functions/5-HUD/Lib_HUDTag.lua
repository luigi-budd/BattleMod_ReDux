//separate hud in case someone wants to polish it up
local B = CBW_Battle

B.TagHUD = function(v, player, cam)
	if not B.TagGametype()
		return
	end
	
	if B.TagPreTimer > 0
		/*if player.pflags & PF_TAGIT
			v.drawFill(0, 0, v.width() / v.dupx() + 1, v.height / v.dupy() + 1)
		end*/
		local x = v.width() / v.dupx() / 2
		local y = v.height() / v.dupy() / 5
		local flags = V_SNAPTOTOP | V_PERPLAYER | V_ALLOWLOWERCASE
		local text = "\x80" .. tostring(B.TagPreTimer / TICRATE + 1)
		local text2
		/*if player.pflags & PF_TAGIT
			text2 = "\x86Get ready for the hunt..."
		else
			text2 = "\x86Run before you get clapped!"
		end*/
		v.drawString(x, y, text, flags, "center")
		//v.drawString(x, y + 2, text2, flags, "center")
	end
end