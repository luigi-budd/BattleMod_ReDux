local B = CBW_Battle
local A = B.Arena
local CV = B.Console

/*B.HideTime = function()
	if (server) then
		if G_TagGametype() //and gametype != GT_BATTLETAG then
			COM_BufInsertText(server,"hidetime 30")
		else
			COM_BufInsertText(server,"hidetime 15")
		end
	end
end*/

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
B.TagRunners = {}
B.TagTaggers = {}

B.IsValidPlayer = function(player)
	local p = player
	if player != nil and player.valid and player.player
		p = player.player
	elseif player == nil or not player.valid
		return false
	end
	return p != nil and p.valid and p.mo != nil and p.mo.valid and not 
			p.spectator
end

local function IT_Spawner(player)
	if not B.IsValidPlayer(player) or not player.battletagIT
		return
	end
	
	if player.ITindiBT != nil
		player.ITindiBT = nil
	end
	local IT = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BATTLETAG_IT)
	IT.tracerplayer = player
	player.ITindiBT = IT
end

B.TagConverter = function(player)
	if not B.IsValidPlayer(player) or player.battletagIT
		return
	end
	
	player.battletagIT = true
	IT_Spawner(player)
	--player.BTblindfade = 0
	P_ResetScore(player)
	player.score = 0
	for i, p in ipairs(B.TagRunners) do
		if p == player
			table.remove(B.TagRunners, i)
			break
		end
	end
	table.insert(B.TagTaggers, player)
	print(player.name .. " is now IT!")
end

local function PlayerCounter()
	
end

B.TagControl = function()
	if gametype != GT_BATTLETAG
		return
	end
	
	//failsafe to ensure a time limit is active
	/*if (timelimit == nil or timelimit <= 1) and (server)
		COM_BufInsertText(server, "timelimit 6")
	end*/
	
	//iterate through all players to get them sorted into "teams"
	B.TagPlayers = 0
	B.TagRunners = {}
	B.TagTaggers = {}
	for player in players.iterate do
		if player.solchar then player.solchar.hasallemeralds = false end
		if B.IsValidPlayer(player)

			--radar function
			if B.TagPreRound > 1 and (timelimit * 60 * TICRATE - player.realtime <= 180 * TICRATE)
				local opponents = (player.battletagIT and B.TagRunners) or B.TagTaggers
				local proxBeep = {50,50,40,20,10,5}
				local beeps = {}
				for i=1,#opponents do
					if not(opponents[i].mo and opponents[i].mo.valid) then continue end
					if opponents[i] == player then continue end
					if opponents[i].playerstate ~= PST_LIVE then continue end
					local hori = (152 - 9*(#opponents-1)) + (18*(i-1))
					local proximity = B.GetProximity(player.mo, opponents[i].mo)
					if proximity > 1 then
						table.insert(beeps, {proximity=proximity})
					end
				end

				if #beeps then
					table.sort(beeps, function(a, b) return a.proximity > b.proximity end)
					if not(leveltime % proxBeep[beeps[1].proximity]) then
						S_StartSoundAtVolume(nil, sfx_crng2, 100, player)
					end
				end
			end

			//attempt to move players that have quit to spectator
			if player.quittime != nil and player.quittime > TICRATE * 3
				P_KillMobj(player.mo, nil, nil, DMG_SPECTATOR)
				player.spectator = true
				print(player.name .. " left the game!")
				continue
			end
			//anti-afk script, let's go
			local horispeed = FixedHypot(player.mo.momx - player.cmomx, 
					player.mo.momy - player.cmomy)
			local speed = FixedHypot(horispeed, player.mo.momz)
			if player.speed > 5 * player.mo.scale
				if player.BT_antiAFK < TICRATE * 60
					player.BT_antiAFK = TICRATE * 60
				end
			elseif B.TagPreRound > 1
				if player.BT_antiAFK <= 0
					P_KillMobj(player.mo, nil, nil, DMG_SPECTATOR)
					player.spectator = true
					print(player.name .. " is AFK!")
					continue
				elseif player.BT_antiAFK == TICRATE * 30
					S_StartSound(player.mo, sfx_s3kb2, player)
				end
				player.BT_antiAFK = $ - 1
			end
			B.TagPlayers = $ + 1
			if player.battletagIT
				table.insert(B.TagTaggers, player)
			else
				table.insert(B.TagRunners, player)
			end
		end
	end
	
	if B.PreRoundWait()
		return
	end
	//assign some taggers as soon as pre-round ends
	if B.TagPreRound == 0
		local i = 0
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
		//ensure the first player that joins is a tagger, if there's none
		if B.TagPlayers == 1
			for i, player in ipairs(B.TagRunners) do
				B.TagConverter(player)
			end
		end
		for i, player in ipairs(B.TagTaggers) do
			player.pflags = $ | PF_FULLSTASIS
			/*if player.BTblindfade < 10
				player.BTblindfade = $ + 1
			end*/
		end
		if B.TagPreTimer > 0
			B.TagPreTimer = $ - 1
			if not (CV.PreRound.value) then
				B.TagPreTimer = min($, 1)
			end
		else
			S_StartSound(nil, sfx_tgrlsd)
			B.TagPreRound = 2
		end
	else
		//constantly keep track of how many active players and taggers there are
		local totaltaggers = 0
		for i, player in ipairs(B.TagRunners) do
			//have spectators joining in become taggers, also as failsafe
			//exception for if there's only 2 active players in a game
			if player.battlespawning != nil and player.battlespawning > 0 
					and B.TagPlayers != 2
				B.TagConverter(player)
			//have runners earn points every second they're alive and well
			elseif player.realtime % TICRATE == 0 and player.playerstate == 
					PST_LIVE and not player.powers[pw_flashing]
				P_AddPlayerScore(player, 5)
			end
		end
		for i, player in ipairs(B.TagTaggers) do
			totaltaggers = $ + 1
			/*if player.BTblindfade > 0
				player.BTblindfade = $ - 1
			end*/
			if player.ITindiBT == nil or not player.ITindiBT.valid
				IT_Spawner(player)
			end
			//spawn in pointers for taggers during pinch
			if B.Pinch
				if player.btagpointers == nil
					player.btagpointers = {}
					for i, runners in ipairs(B.TagRunners) do
						local pointer = P_SpawnMobjFromMobj(player.mo, 0, 0, 0,
								MT_BTAG_POINTER)
						pointer.tracer = player.mo
						pointer.target = runners.mo
						table.insert(player.btagpointers, pointer)
					end
				end
			end
		end
		if B.TagPlayers > 1 and B.TagPlayers == totaltaggers and not B.Exiting
			print("All players have been tagged!")
			A.ForceWin()
		elseif B.TagPlayers > 1 and totaltaggers <= 0 and not B.Exiting
			print("No taggers active! Ending round...")
			B.Exiting = true
		end
	end
	if B.Exiting and B.TagPreRound == 2
		local runwin = false
		for i, player in ipairs(B.TagRunners) do
			P_AddPlayerScore(player, player.score)
			runwin = true
		end
		//double runners score for surviving the whole round
		if runwin
			print("All runners have their score doubled for surviving the round.")
		end
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
	
	if B.MyTeam(target.player, inflictor.player) or B.MyTeam(target.player, 
			source.player)
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

B.TagViewpoints = function(player, nextviewedplayer, forced)
    if (gametype == GT_BATTLETAG and not player.spectator) then
		return (player.battletagIT == nextviewedplayer.battletagIT)
    end
end