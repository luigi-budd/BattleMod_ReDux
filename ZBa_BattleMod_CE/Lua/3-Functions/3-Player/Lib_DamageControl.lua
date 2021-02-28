local B = CBW_Battle

B.PlayerCanBeDamaged = function(player)
	if not(player.playerstate == PST_LIVE) then return false end
	if player.powers[pw_invulnerability] then return false end
	if player.powers[pw_super] then return false end
	if player.powers[pw_flashing] then return false end
	return true
end