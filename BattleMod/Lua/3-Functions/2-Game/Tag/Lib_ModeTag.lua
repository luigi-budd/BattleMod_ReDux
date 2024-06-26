local B = CBW_Battle

B.HideTime = function()
	if (server) then
		if G_TagGametype() //and gametype != GT_BATTLETAG then
			COM_BufInsertText(server,"hidetime 30")
		else
			COM_BufInsertText(server,"hidetime 15")
		end
	end
end

B.TagCam = function(player, runner)
	if gamestate ~= GS_LEVEL then return end
	if (runner and runner.valid)
		if G_TagGametype()
		and not (runner.pflags&PF_TAGIT)
			return false
		end
	end
end

local function IsValidPlayer(player)
	return player != nil and player.valid and player.mo != nil and
			player.mo.valid and not player.spectating
end

B.TagControl = function()
	if gametype != GT_BATTLETAG or B.PreRoundWait()
		return
	end
	
	local totalplayers = 0
	if B.TagPreRound == 0
		local i = 0
		totalplayers = 0
		for player in players.iterate do
			if IsValidPlayer(player)
				totalplayers = $ + 1
			end
		end
		local maxtaggers = 0
		if totalplayers > 4
			maxtaggers = min(max($ / 4, 1), 5)
		elseif totalplayers > 0
			maxtaggers = 1
		end
		while i < maxtaggers
			local luckyplayer = players[P_RandomKey(32)]
			if IsValidPlayer(luckyplayer) and not luckyplayer.battletagIT
				luckyplayer.battletagIT = true
				local IT = P_SpawnMobjFromMobj(luckyplayer.mo, 0, 0, 0, 
						MT_BATTLETAG_IT)
				IT.tracerplayer = luckyplayer
				i = $ + 1
			end
		end
		B.TagPreRound = 1
		B.TagPreTimer = 10 * TICRATE
	elseif B.TagPreRound == 1
		totalplayers = 0
		for player in players.iterate do
			if IsValidPlayer(player)
				if player.battletagIT
					player.pflags = $ | PF_FULLSTASIS
				end
				totalplayers = $ + 1
			end
		end
		if totalplayers == 1
			for player in players.iterate do
				if IsValidPlayer(player) and not player.battletagIT
					player.battletagIT = true
					local IT = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, 
							MT_BATTLETAG_IT)
					IT.tracerplayer = player
				end
			end
		end
		if B.TagPreTimer > 0
			B.TagPreTimer = $ - 1
		else
			B.TagPreRound = 2
		end
	else
		//constantly keep track of how many active players and taggers there are
		//to end the game if everyone is tagged
		local totaltaggers = 0
		totalplayers = 0
		for player in players.iterate do
			if IsValidPlayer(player)
				//have spectators joining in become taggers, also as failsafe
				if player.battlespawning != nil and player.battlespawning > 0 
						and not player.battletagIT
					player.battletagIT = true
					local IT = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, 
							MT_BATTLETAG_IT)
					IT.tracerplayer = player
				end
				totalplayers = $ + 1
				if player.battletagIT
					totaltaggers = $ + 1
				end
			end
		end
		if totalplayers > 1 and totalplayers == totaltaggers
			G_ExitLevel()
		end
	end
end

//ensure taggers that are tumbled or in pain can't deal damage to runners
local function MoValidPlayer(mo)
	return mo != nil and mo.valid and mo.player != nil and mo.player.valid
end

B.TagDamageControl = function(target, inflictor, source)
	if gametype != GT_BATTLETAG or not MoValidPlayer(target) or (not 
			MoValidPlayer(inflictor) and not MoValidPlayer(source))
		return
	end
	
	if B.MyTeam(target, inflictor)
		return false
	end
end

//have runners who are damaged or killed by taggers switch teams
B.TagTeamSwitch = function(target, inflictor, source)
	if gametype != GT_BATTLETAG or not MoValidPlayer(target) or (not
			MoValidPlayer(inflictor) and MoValidPlayer(source))
		return
	end
	
	local runner = target.player
	local tagger
	if MoValidPlayer(inflictor)
		tagger = inflictor.player
	elseif MoValidPlayer(source)
		tagger = source.player
	end
	if tagger != nil and tagger.battletagIT and not runner.battletagIT
		runner.battletagIT = true
		local IT = P_SpawnMobjFromMobj(runner.mo, 0, 0, 0, MT_BATTLETAG_IT)
		IT.tracerplayer = runner
	end
end