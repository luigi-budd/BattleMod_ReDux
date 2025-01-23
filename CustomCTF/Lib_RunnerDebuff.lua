local B = CBW_Battle

B.GotFlagStats = function(player)
	local mo = player.mo
	local skin = skins[mo.skin]
	local skinvar = (pcall(do return B.SkinVars[mo.skin].flagstats end) and (type(B.SkinVars[mo.skin].flagstats) == "table") and B.SkinVars[mo.skin].flagstats) or {}
	//Register debuff
	if (player.gotflag or player.gotcrystal) and player.gotflagdebuff == false then
		player.gotflagdebuff = true
		player.secondjump = 0
		player.powers[pw_tailsfly] = 0
		if player.pflags&PF_GLIDING
			mo.state = S_PLAY_FALL
		end
		player.pflags = $&~(PF_BOUNCING|PF_GLIDING|PF_THOKKED)
		player.climbing = 0
		if player.actionstate and not(player.actionsuper) then
			player.actionstate = 0
			player.actiontime = 0
			mo.tics = 0
			mo.spritexscale = FRACUNIT
			mo.spriteyscale = FRACUNIT
			-- Reset state (prevent anything that looks weird)
			if not P_IsObjectOnGround(mo) then
				mo.state = S_PLAY_FALL
			else
				mo.state = S_PLAY_WALK
			end
			player.pflags = $ &~ (PF_JUMPED|PF_SPINNING) -- Disallow spin attack status while in fall/walk anims
		end
		local zlimit = player.jumpfactor*10
		mo.momz = max(min($,zlimit),-zlimit)
		local xylimit = player.normalspeed*5/4
		for i=1, 100 do
			if FixedHypot(mo.momx, mo.momy) <= xylimit then break end
			local speedangle = R_PointToAngle2(0, 0, mo.momx, mo.momy) 
			P_Thrust(mo, speedangle, -mo.scale)
		end
		B.Uncolorize(mo)
	end
	//Unregister debuff and apply normal stats
	if not(player.gotflag or player.gotcrystal) and player.gotflagdebuff == true then
		player.gotflagdebuff = false
		player.normalspeed = skin.normalspeed
		player.acceleration = skin.acceleration
		player.runspeed = skin.runspeed
		player.mindash = skin.mindash
		player.maxdash = skin.maxdash
		player.charflags = skins[mo.skin].flags
		player.jumpfactor = skin.jumpfactor
	end
	//Apply debuff
	if player.gotflagdebuff
		player.normalspeed = skinvar.normalspeed or skin.normalspeed
		player.acceleration = skinvar.acceleration or skin.acceleration
		player.runspeed = skinvar.runspeed or skin.runspeed
		if not(B.GetSkinVarsFlags(player) & SKINVARS_ROSY) then
			player.mindash = skinvar.mindash or (15*3/4*FRACUNIT)
			player.maxdash = skinvar.maxdash or (70*4/5*FRACUNIT)
		end
		player.dashmode = 0
		player.jumpfactor = skinvar.jumpfactor or FRACUNIT
		player.charflags = skins[mo.skin].flags & ~SF_RUNONWATER
		player.powers[pw_strong] = $&~STR_METAL
	end
end
