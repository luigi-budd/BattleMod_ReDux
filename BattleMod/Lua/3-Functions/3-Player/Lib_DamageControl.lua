local B = CBW_Battle

B.PlayerCanBeDamaged = function(player)
	if not(player.playerstate == PST_LIVE)
	or player.powers[pw_invulnerability]
	or player.powers[pw_super]
	or player.powers[pw_flashing]
	or player.nodamage
	or (B.TagGametype() and not (player.pflags & PF_TAGIT or player.battletagIT) 
			and player.guard > 0)
		return false
	end
	return true
end