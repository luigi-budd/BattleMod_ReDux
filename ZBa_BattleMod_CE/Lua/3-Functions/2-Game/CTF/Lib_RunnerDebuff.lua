local B = CBW_Battle

B.GotFlagStats = function(player)
	local skin = skins[player.mo.skin]
	//Register debuff
	if (player.gotflag or player.gotcrystal) and player.gotflagdebuff == false then
		player.gotflagdebuff = true
		player.secondjump = 0
		player.powers[pw_tailsfly] = 0
		if player.pflags&PF_GLIDING
			player.mo.state = S_PLAY_FALL
		end
		player.pflags = $&~(PF_BOUNCING|PF_GLIDING|PF_THOKKED)
		player.climbing = 0
		if player.actionstate and not(player.actionsuper) then
			player.actionstate = 0
			local zlimit = player.jumpfactor*10
			player.mo.momz = max(min($,zlimit),-zlimit)
		end
	end
	//Unregister debuff and apply normal stats
	if not(player.gotflag or player.gotcrystal) and player.gotflagdebuff == true then
		player.gotflagdebuff = false
		player.normalspeed = skin.normalspeed
		player.acceleration = skin.acceleration
		player.runspeed = skin.runspeed
		player.charflags = skins[player.mo.skin].flags
	end
	//Apply debuff
	if player.gotflagdebuff
		player.normalspeed = skin.normalspeed*4/5
		player.acceleration = skin.acceleration*4/5
		player.runspeed = skin.runspeed*4/5
		player.dashmode = 0
		player.charflags = skins[player.mo.skin].flags & ~SF_RUNONWATER
	end
end
