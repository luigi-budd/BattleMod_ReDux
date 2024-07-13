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

//all the stuff for battle tag
B.TagPreRound = 0
B.TagPreTimer = 0
B.TagPlayers = 0

local function IsValidPlayer(player)
	return player != nil and player.valid and player.mo != nil and
			player.mo.valid and not player.spectator
end

local function PlayerCounter()
	local tplayers = 0
	for player in players.iterate do
		if IsValidPlayer(player)
			tplayers = $ + 1
		end
	end
	return tplayers
end

B.TagControl = function()
	if gametype != GT_BATTLETAG
		return
	end
	
	//failsafe to ensure a time limit is active
	if (timelimit == nil or timelimit <= 0) and (server)
		COM_BufInsertText(server, "timelimit 5")
	end
	
	if B.PreRoundWait()
		B.TagPlayers = PlayerCounter()
		return
	end
	//assign some taggers as soon as pre-round ends
	if B.TagPreRound == 0
		local i = 0
		B.TagPlayers = PlayerCounter()
		local maxtaggers = 0
		if B.TagPlayers > 4
			maxtaggers = min(max($ / 4, 1), 5)
		elseif B.TagPlayers > 0
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
	//run through the second pre-round, where taggers are frozen
	elseif B.TagPreRound == 1
		B.TagPlayers = PlayerCounter()
		for player in players.iterate do
			if IsValidPlayer(player)
				if player.battletagIT
					player.pflags = $ | PF_FULLSTASIS
				//ensure the first player that joins is a tagger, if there's none
				elseif B.TagPlayers == 1
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
		local totaltaggers = 0
		B.TagPlayers = PlayerCounter()
		for player in players.iterate do
			if IsValidPlayer(player)
				//have spectators joining in become taggers, also as failsafe
				//exception for if there's only 2 active players in a game
				if player.battlespawning != nil and player.battlespawning > 0 
						and not player.battletagIT and B.TagPlayers != 2
					player.battletagIT = true
					local IT = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, 
							MT_BATTLETAG_IT)
					IT.tracerplayer = player
				end
				if player.battletagIT
					totaltaggers = $ + 1
				end
				//attempts to have the runner earn points every second they're alive
				if not player.battletagIT and leveltime % TICRATE == 0
					P_AddPlayerScore(player, 5)
				end
			end
		end
		if B.TagPlayers > 1 and B.TagPlayers == totaltaggers
			G_ExitLevel()
		end
	end
end

local function MoValidPlayer(mo)
	return mo != nil and mo.valid and mo.player != nil and mo.player.valid
end

//ensure taggers that are tumbled or in pain can't deal damage to runners
B.TagDamageControl = function(target, inflictor, source)
	if gametype != GT_BATTLETAG or not MoValidPlayer(target) or (not 
			MoValidPlayer(inflictor) and not MoValidPlayer(source))
		return
	end
	
	if B.MyTeam(target, inflictor) or B.MyTeam(target, source)
		return false
	else
		return true
	end
end

//have runners who are damaged or killed by taggers switch teams
B.TagTeamSwitch = function(target, inflictor, source)
	if gametype != GT_BATTLETAG or not MoValidPlayer(target) or (not
			MoValidPlayer(inflictor) and not MoValidPlayer(source))
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