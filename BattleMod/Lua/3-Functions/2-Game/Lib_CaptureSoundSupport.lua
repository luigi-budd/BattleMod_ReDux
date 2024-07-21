local B = CBW_Battle

B.LongSound = function(player, fallback)
	if consoleplayer and not(consoleplayer.cos_blockcapturesounds) and Cosmetics and Cosmetics.Capturesounds_long and 
	(player.cos_capturesoundlong and player.cos_capturesoundlong and 
	player.cos_capturesoundlong > 0 and player.cos_capturesoundlong <= #Cosmetics.Capturesounds_long) then
		return Cosmetics.Capturesounds_long[player.cos_capturesoundlong].sound
	else
		return fallback
	end
end

B.ShortSound = function(player, fallback)
	if consoleplayer and not(consoleplayer.cos_blockcapturesounds) and Cosmetics and Cosmetics.Capturesounds_short and 
	(player.cos_capturesoundshort and player.cos_capturesoundshort and 
	player.cos_capturesoundshort > 0 and player.cos_capturesoundshort <= #Cosmetics.Capturesounds_short) then
		return Cosmetics.Capturesounds_short[player.cos_capturesoundshort].sound
	else
		return fallback
	end
end