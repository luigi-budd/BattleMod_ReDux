local redFlag, blueFlag

addHook('NetVars', function(net)
	redFlag = net($)
	blueFlag = net($)
end)

local addPoints = function(team, points)
	if team == 1
		redscore = $ + points
	else
		bluescore = $ + points
	end
end

local bankTime = function(player)
	return max(1, 6 - ( FixedSqrt(player.rings * FRACUNIT / 2)>>FRACBITS ) )
end

local robTime = function(player)
	return min(15, FixedSqrt(player.rings * FRACUNIT)>>FRACBITS)
end

local bankTouch = function(mo, pmo)
	return gametype == GT_BANK or nil
end

local baseSparkle = function(player, team)
	local spark
	if team == 1 and redFlag and redFlag.valid
		spark = P_SpawnMobjFromMobj(redFlag, 0, 0, 0, MT_SPARK)
	elseif team == 2 and blueFlag and blueFlag.valid
		spark = P_SpawnMobjFromMobj(blueFlag, 0, 0, 0, MT_SPARK)
	end
	if spark and spark.valid
		spark.momx = P_RandomRange(-2, 2) * spark.scale
		spark.momy = P_RandomRange(-2, 2) * spark.scale
		spark.momz = P_RandomRange(1, 3) * spark.scale
		spark.color = player.ctfteam == 1 and SKINCOLOR_RED or SKINCOLOR_BLUE
		spark.colorized = true
		spark.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT
	end
end

local baseTransaction = function(player, team)
	if player.tossdelay
		return true
	end
	-- Get current team score
	local score
	if team == 1
		score = redscore
	else
		score = bluescore
	end
	if player.ctfteam == team
		-- Deposit rings
		if player.rings > 0
			S_StartSound(player.mo, sfx_itemup)
			P_GivePlayerRings(player, -1)
			P_AddPlayerScore(player, 1)
			addPoints(team, 1)
			player.tossdelay = bankTime(player)
			local spark = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_SPARK)
			if spark and spark.valid
				spark.colorized = true
				spark.color = SKINCOLOR_CARBON
			end
			baseSparkle(player, team)
		end
	else
		-- Steal rings
		if score > 0
			S_StartSound(player.mo, sfx_itemup)
			P_AddPlayerScore(player, 1)
			P_GivePlayerRings(player, 1)
			addPoints(team, -1)
			player.tossdelay = robTime(player)
			P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_SPARK)
			baseSparkle(player, team)
		end
	end
	return true
end

addHook('TouchSpecial', function(mo, pmo)
	return bankTouch(mo, pmo)
end, MT_REDFLAG)

addHook('TouchSpecial', function(mo, pmo)
	return bankTouch(mo, pmo)
end, MT_BLUEFLAG)

local spawnFunc = function(mo, team)
	if gametype != GT_BANK
		return
	end
	if team == 1
		redFlag = mo
	else
		blueFlag = mo
	end
	mo.state = S_TEAMRING
	mo.scale = $<<1
	mo.flags = $|MF_NOGRAVITY
	mo.renderflags = $|RF_SEMIBRIGHT
end

addHook('MobjSpawn', function(mo)
	spawnFunc(mo, 1)
end, MT_REDFLAG)

addHook('MobjSpawn', function(mo)
	spawnFunc(mo, 2)
end, MT_BLUEFLAG)

local flashColor = function(colormin,colormax, rate)
	local N = rate or 32 //Rate of oscillation
-- 	local size = colormax-colormin+1 //Color spectrum
	local scale = 2 //Factor-amount to reduce the oscillation intensity
	local offset = 0 //Offset the origin of oscillation
	local oscillate = abs((leveltime&(N*2-1))-N)/scale //Oscillation cycle
	local c = colormin+oscillate+offset //offset
	c = max(colormin,min(colormax,$)) //Enforce min/max
	return c
end

local getBase = function(player)
	if not P_IsObjectOnGround(player.mo) then return 0 end

	--// rev: credits to JAB, he figured this one out. This will work for both UDMF / Binary maps
	if P_MobjTouchingSectorSpecialFlag(player.mo, SSF_REDTEAMBASE) then
		return 1
	elseif P_MobjTouchingSectorSpecialFlag(player.mo, SSF_BLUETEAMBASE) then
		return 2
	else
		return 0
	end
end

local highValueSparkle = function(player)
	if leveltime % 2
		local w = player.mo.radius>>FRACBITS
		local h = player.mo.height>>FRACBITS
		local x = P_RandomRange(-w, w) * FRACUNIT
		local y = P_RandomRange(-w, w) * FRACUNIT
		local z = P_RandomRange(0, h) * FRACUNIT
-- 		local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_BOXSPARKLE)
		local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_SPARK)
		if fx and fx.valid
			fx.scale = $>>1
			fx.fuse = P_RandomRange(10, 65)
			local spd = FixedMul(fx.scale, P_RandomRange(0, FRACUNIT-1))
			local angle = FixedAngle(P_RandomRange(0, 259)*FRACUNIT)
			P_Thrust(fx, angle, spd)
			P_SetObjectMomZ(fx, P_RandomRange(0, FRACUNIT-1), true)
-- 			if P_RandomChance(FRACUNIT>>2)
				fx.colorized = true
				fx.color = player.mo.color
-- 			end
			if player == displayplayer
				fx.flags2 = $|MF2_SHADOW
			end
		end
	end
end

local addHudSparkle = function(team, direction)
	local w = 22
	local h = 14
	local x, y = 130 + P_RandomRange(0,w), 6
	local momy = 1
	if team == 1
		x = $ + 40
	end
	if direction == 1
		momy = -$
		y = $+h
	end
	table.insert(hudobjs, {
		drawtype = "sprite",
		string = "NSPK",
		frame = 1,
		flags = V_SNAPTOTOP|V_PERPLAYER,
		x = FRACUNIT * x,
		y = FRACUNIT * y,
		momy = momy * FRACUNIT,
		friction = FRACUNIT * 15 / 16,
		scale = FRACUNIT >> 2,
		fuse = 28
	})
end

addHook('ThinkFrame', do
	if gametype != GT_BANK
		return
	end
	local rs = redscore
	local bs = bluescore
	local blueInBlue = 0
	local blueInRed = 0
	local redInBlue = 0
	local redInRed = 0
	
	-- Get player-to-base statuses
	for player in players.iterate do
		if player.mo and player.rings >= 100
			highValueSparkle(player)
		end
		if player.mo and player.mo.health and not player.powers[pw_flashing]
			local base = getBase(player)
			if base == 1 -- Red base
				if player.ctfteam == 1
					redInRed = $+1
				else
					blueInRed = $+1
				end
			elseif base == 2 -- Blue base
				if player.ctfteam == 1
					redInBlue = $+1
				else
					blueInBlue = $+1
				end
			end
		end
	end

	-- Do player in base transactions
	for player in players.iterate do
		if player.mo and player.mo.health and not player.powers[pw_flashing]
			local base = getBase(player)
			if base == 1 -- Red base
				if redInRed and blueInRed
					continue
				end
			elseif base == 2 -- Blue base
				if redInBlue and blueInBlue
					continue
				end
			end
			if base != 0
				baseTransaction(player, base)
			end
		end
		if redFlag and redFlag.valid
			-- Color
			if redInRed and blueInRed
				redFlag.color = flashColor(SKINCOLOR_SUPERORANGE1, SKINCOLOR_SUPERORANGE5, 8)
			elseif redInRed
				redFlag.color = flashColor(SKINCOLOR_SUPERRED1, SKINCOLOR_SUPERRED5, 16)
			elseif blueInRed
				redFlag.color = flashColor(SKINCOLOR_SUPERRUST1, SKINCOLOR_SUPERRUST5, 16)
			else
				redFlag.color = SKINCOLOR_CRIMSON
			end
			-- Transparency
			redFlag.frame = $ | FF_TRANS30
			-- Motion
			redFlag.z = redFlag.floorz + redFlag.scale * 16 + FixedMul(sin(leveltime * ANG10), redFlag.scale * 8)
			-- HUD sparkle
			if rs < redscore
				addHudSparkle(1, 1)
			elseif rs > redscore
				addHudSparkle(1, 0)
			end
		end
		if blueFlag and blueFlag.valid
			-- Color
			if redInBlue and blueInBlue
				blueFlag.color = flashColor(SKINCOLOR_SUPERGOLD1, SKINCOLOR_SUPERGOLD5, 8)
			elseif redInBlue
				blueFlag.color = flashColor(SKINCOLOR_SUPERPURPLE1, SKINCOLOR_SUPERPURPLE5, 16)
			elseif blueInBlue
				blueFlag.color = flashColor(SKINCOLOR_SUPERSKY1, SKINCOLOR_SUPERSKY5, 16)
			else
				blueFlag.color = SKINCOLOR_COBALT
			end
			-- Transparency
			blueFlag.frame = $ | FF_TRANS30
			-- Motion
			blueFlag.z = blueFlag.floorz + blueFlag.scale * 16 + FixedMul(sin(leveltime * ANG10), blueFlag.scale * 8)
			-- HUD sparkle
			if bs < bluescore
				addHudSparkle(0, 1)
			elseif bs > bluescore
				addHudSparkle(0, 0)
			end
		end
	end	
end)