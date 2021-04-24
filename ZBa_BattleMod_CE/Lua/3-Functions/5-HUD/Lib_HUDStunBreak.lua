local B = CBW_Battle
local CV = B.Console
B.StunBreakHUD = function(v, player, cam)
	if not (player and player.valid and player.mo and player.mo.valid)
		or not P_PlayerInPain(player)
		or not player.mo.state == S_PLAY_PAIN
		or player.isjettysyn
		or not (CV.Guard.value)
		return
	end
	
	local xoffset = 16
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER
	local align = "thin"
	local yoffset = 56
	local text = "Stun Break"
	local textcolor = "\x86"
	local patch = v.cachePatch("PARRYBT")
	if player.rings >= 20
		if leveltime % 3 == 0
			textcolor = ""
		elseif leveltime % 3 == 1
			textcolor = "\x83"
		else
			textcolor = "\x87"
		end
	end
	text = "\x82" .. 20 .. textcolor .. " " .. $
	v.draw(xoffset,yoffset,patch,flags)
	v.drawString(xoffset+12,yoffset,text,flags,align)
end