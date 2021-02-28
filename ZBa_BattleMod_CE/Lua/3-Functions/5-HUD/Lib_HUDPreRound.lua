local B = CBW_Battle
B.PreRoundHUD = function(v,player,cam)
	if B.PreRoundWait() and not(player.spectator) then
		if not(splitscreen)
			v.drawString(160,80,"Waiting for other players to join",V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,"center")
		end
		v.drawString(160,88,"Press spin/jump to change skin",V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,"center")
	end
end