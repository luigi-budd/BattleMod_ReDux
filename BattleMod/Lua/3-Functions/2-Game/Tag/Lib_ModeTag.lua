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

B.IsValidPlayer = function(player)
	return player != nil and player.valid and player.mo != nil and
			player.mo.valid and not player.spectator
end

B.TagConverter = function(player)
	if not B.IsValidPlayer(player) or player.battletagIT
		return
	end
	
	player.battletagIT = true
	local IT = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BATTLETAG_IT)
	IT.tracerplayer = player
	player.BTblindfade = 0
	P_ResetScore(player)
	player.score = 0
	print(player.name .. " is now IT!")
end

local function PlayerCounter()
	local tplayers = 0
	for player in players.iterate do
		if B.IsValidPlayer(player)
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
			if B.IsValidPlayer(luckyplayer) and not luckyplayer.battletagIT
				B.TagConverter(luckyplayer)
				i = $ + 1
			end
		end
		B.TagPreRound = 1
		B.TagPreTimer = 10 * TICRATE
	//run through the second pre-round, where taggers are frozen and blindfolded
	elseif B.TagPreRound == 1
		B.TagPlayers = PlayerCounter()
		for player in players.iterate do
			if B.IsValidPlayer(player)
				if player.battletagIT
					player.pflags = $ | PF_FULLSTASIS
					if player.BTblindfade < 10
						player.BTblindfade = $ + 1
					end
				//ensure the first player that joins is a tagger, if there's none
				elseif B.TagPlayers == 1
					B.TagConverter(player)
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
			if B.IsValidPlayer(player)
				//have spectators joining in become taggers, also as failsafe
				//exception for if there's only 2 active players in a game
				if player.battlespawning != nil and player.battlespawning > 0 
						and not player.battletagIT and B.TagPlayers != 2
					B.TagConverter(player)
				end
				if player.battletagIT
					totaltaggers = $ + 1
					if player.BTblindfade > 0
						player.BTblindfade = $ - 1
					end
				end
				//have runners earn points every second they're alive and well
				if not player.battletagIT and player.realtime % TICRATE == 0
						and player.playerstate == PST_LIVE and not
						player.powers[pw_flashing]
					P_AddPlayerScore(player, 5)
				end
			end
		end
		if B.TagPlayers > 1 and B.TagPlayers == totaltaggers
			print("All players have been tagged!")
			G_ExitLevel()
		end
	end
	//double runners score for surviving the whole round
	if B.Exiting and B.TagPreRound == 2
		for player in players.iterate do
			if not player.battletagIT
				P_AddPlayerScore(player, player.score)
			end
		end
		print("All runners have their score doubled for surviving the round.")
		B.TagPreRound = 3
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

//have runners who are damaged by taggers or die switch teams
B.TagTeamSwitch = function(target, inflictor, source)
	if gametype != GT_BATTLETAG or not MoValidPlayer(target)
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
		//have tagger steal the runner's score
		P_AddPlayerScore(tagger, runner.score)
		B.TagConverter(runner)
	elseif runner.playerstate != PST_LIVE and not runner.battletagIT
		B.TagConverter(runner)
	end
end