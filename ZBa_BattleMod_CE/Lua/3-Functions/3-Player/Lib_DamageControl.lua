local B = CBW_Battle

B.PlayerCanBeDamaged = function(player)
	if not(player.playerstate == PST_LIVE)
	or player.powers[pw_invulnerability]
	or player.powers[pw_super]
	or player.powers[pw_flashing]
		return false
	end
	return true
end