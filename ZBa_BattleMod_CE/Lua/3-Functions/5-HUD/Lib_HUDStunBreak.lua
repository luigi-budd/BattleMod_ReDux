local B = CBW_Battle
B.StunBreakHUD = function(v, player, cam)
	if not B return end
	if player.playerstate != PST_LIVE then return end
	if player.gotflag or player.gotcrystal then return end
	if not P_PlayerInPain(player) return end
	
	local xoffset = 16
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER
	local align = "thin"
	local yoffset = 56
	local text = "Stun Break"
	local textcolor = "\x86"
	local patch = v.cachePatch("PARRYBT")
	if player.rings >= 30
		if leveltime % 3 == 0
			textcolor = ""
		elseif leveltime % 3 == 1
			textcolor = "\x83"
		else
			textcolor = "\x87"
		end
	end
	text = "\x82" .. 30 .. textcolor .. " " .. $
	v.draw(xoffset,yoffset,patch,flags)
	v.drawString(xoffset+12,yoffset,text,flags,align)
	
	return
end