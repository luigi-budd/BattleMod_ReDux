local B = CBW_Battle

B.PinchHUD = function(v, player, cam)
	if not(B.PinchTics) then return end
	
	if not(B.SuddenDeath) then
		if leveltime&6 then
			v.drawString(160,80,timelimit*60-leveltime/TICRATE.." seconds left!",V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,"center")
		end
	else
		local color = {"\x80","\x82","\x81","\x80"}
	 	local c = color[leveltime&3+1]
		if leveltime&3 then
	 	v.drawString(160,80,c.."Sudden Death!!",V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,"center")
		end
	end
end