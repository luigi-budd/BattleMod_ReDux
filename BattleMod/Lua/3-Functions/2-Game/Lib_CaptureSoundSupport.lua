local B = CBW_Battle
local F = B.CTF

B.LongSound = function(player, fallback, lose, nowin, gettable)
	if consoleplayer and not(consoleplayer.cos_blockcapturesounds) and Cosmetics and Cosmetics.Capturesounds_long and 
	(player.cos_capturesoundlong and player.cos_capturesoundlong and 
	player.cos_capturesoundlong > 0 and player.cos_capturesoundlong <= #Cosmetics.Capturesounds_long) then
		local choice = Cosmetics.Capturesounds_long[player.cos_capturesoundlong]
		if gettable then
			return choice
		end
		if lose then
			return (choice.losesound or fallback)
		else
			return (nowin and fallback) or (choice.sound or fallback)
		end
	else
		if gettable then
			return {volume=255}
		else
			return fallback
		end
	end
end

B.ShortSound = function(player, fallback, lose, nowin, gettable)
	if consoleplayer and not(consoleplayer.cos_blockcapturesounds) and Cosmetics and Cosmetics.Capturesounds_short and 
	(player.cos_capturesoundshort and player.cos_capturesoundshort and 
	player.cos_capturesoundshort > 0 and player.cos_capturesoundshort <= #Cosmetics.Capturesounds_short) then
		local choice = Cosmetics.Capturesounds_short[player.cos_capturesoundshort]
		if gettable then
			return choice
		end
		if lose then
			return (choice.losesound or fallback)
		else
			return (nowin and fallback) or (choice.sound or fallback)
		end
	else
		if gettable then
			return {volume=255}
		else
			return fallback
		end
	end
end