local B = CBW_Battle
local CV = B.Console
local A = B.Arena
A.Fighters = {}
A.RedFighters = {}
A.BlueFighters = {}
A.Survivors = {}
A.RedSurvivors = {}
A.BlueSurvivors = {}
A.Placements = {}
A.SpawnLives = 3
A.GameOvers = 0

A.GameOverControl = function(player)
	if not(B.BattleGametype()) then return end
	if player.playerstate == PST_DEAD and player.lives == 0 then
		if B.Exiting == false
			if player.deadtimer == gameovertics and not(B.Pinch or B.SuddenDeath)
				P_RestoreMusic(player)
			end
		else
			player.deadtimer = 2
		end
	end
end

A.StartRings = function(player)
	if not(B.BattleGametype()) then return end
	player.xtralife = 9 //Prevent players from gaining extra lives in the format
	if B.SuddenDeath then return end
	if not(A.CheckRevenge(player)) then
		player.rings = CV.ArenaStartRings.value
	else
		player.rings = 0
	end
end

A.RingSpill = function(player)
	//Rings spill far in Arena gametypes
	if B.ArenaGametype() then player.losstime = 30*TICRATE end
end

A.RingLoss = function(mo)
	//Rings disappear quickly in Arena gametypes
	if B.ArenaGametype() then mo.fuse = min($,35) end
end

A.UpdateSpawnLives = function()
	if not(B.BattleGametype()) then return end
	local cv_stock = CV.SurvivalStock.value
	if B.PreRoundWait() 
		A.SpawnLives = cv_stock
		for player in players.iterate
			player.lives = cv_stock
		end
	return end
	for player in players.iterate
		A.SpawnLives = min($,player.lives)
		if player.spectator then player.lives = cv_stock end
	end
end

A.ResetLives = function()
	for player in players.iterate
		player.revenge = false
		player.respawnpenalty = 0
	end
	if not(gametyperules&GTR_LIVES) or not(B.BattleGametype()) then return end
	local L = CV.SurvivalStock.value
	for player in players.iterate
		player.lives = L
		player.revenge = false
		player.isjettysyn = false
	end
	A.SpawnLives = L
	A.GameOvers = 0
end

A.ResetScore = function()
	if not(gametyperules&GTR_LIVES and B.ArenaGametype()) then return end
	for player in players.iterate()
		if not(player.spectator) and player.lives and not(player.revenge) then
			player.preservescore = A.GameOvers+player.lives
		elseif player.preservescore == nil
			player.preservescore = 0
		end
		player.score = 0
	end
	bluescore = 0
	redscore = 0
end

A.UpdateScore = function()
	//Score function for Survival
	if not(gametyperules&GTR_LIVES and B.ArenaGametype()) then return end
	for player in players.iterate
		//Player is contending
		if player.preservescore != nil then
			player.score = player.preservescore
		end
	end
	
	//Team Survival
	if G_GametypeHasTeams() then
		redscore = 0
		bluescore = 0
		for player in players.iterate
			if player.ctfteam == 1 and not(player.revenge)
				redscore = $+player.lives
			end
			if player.ctfteam == 2 and not(player.revenge)
				bluescore = $+player.lives
			end
		end
	end
end

A.ForceRespawn = function(player)
	if B.ArenaGametype() and G_GametypeUsesLives()
	and not(player.playerstate == PST_LIVE) and player.lives > 0 and not(player.revenge)
	and leveltime&1
		then
		player.cmd.buttons = $|BT_JUMP
	end
end

A.GetRanks = function()
	local p = A.Fighters
	A.Placements = {}
	//Rank players
	for n = 1, #p
		local player = p[n]
		if not(player and player.valid) then continue end
		player.rank = 1
		//Compare with other player's scores
		for m = 1, #p
			local otherplayer = p[m]
			if not(p[m].valid) then continue end //sigh
			if player.score < otherplayer.score then
				player.rank = $+1
			end
		end
		//Sort players on the "placement" list
		for n = player.rank,#p
			if A.Placements[n] == nil
				A.Placements[n] = player
				break
			end
		end
	end
end

local function forcewin()
	local doexit = false
	for player in players.iterate
		if player.exiting then continue end
		doexit = true 
		P_DoPlayerExit(player)
		S_StopMusic(player)
	end
	if doexit == true then
		B.DebugPrint("Game set conditions triggered.")
		S_StartSound(nil,sfx_lvpass)
		S_StartSound(nil,sfx_nxbump)
		B.Exiting = true
		for player in players.iterate
			COM_BufInsertText(player,"cecho  ") //Override ctf messages
		end
	end
end

local tiebreaker_t = function()
	print("\x82".."Tiebreaker!")
end

A.UpdateGame = function()
	if not(B.BattleGametype()) then return end
	local survival = G_GametypeUsesLives() and B.ArenaGametype()
	local playercount = 0
	A.Survivors = {}
	A.Fighters = {}
	A.RedSurvivors = {}
	A.BlueSurvivors = {}
	A.BlueFighters = {}
	A.RedFighters = {}
	for player in players.iterate()
		playercount = $+1
		if not(player.spectator)
			A.Fighters[#A.Fighters+1] = player //Player is participating
			if player.ctfteam == 2 then
				A.BlueFighters[#A.BlueFighters+1] = player
			end
			if player.ctfteam == 1 then
				A.RedFighters[#A.RedFighters+1] = player
			end
			if(player.lives) and not(player.revenge) then A.Survivors[#A.Survivors+1] = player //Player is still alive
			else //Handle revenge
				if not(player.lives) and CV.Revenge.value then
					player.lives = 1
					player.revenge = true
				end
			continue end //Gate for team survivors
			if player.ctfteam == 1 then A.RedSurvivors[#A.RedSurvivors+1] = player
			elseif player.ctfteam == 2 then A.BlueSurvivors[#A.BlueSurvivors+1] = player
			end
		end
	end
	
	//Update score
	B.UpdateScore()
	A.UpdateScore()
	
	//****
	//End of round conditions
	local timelimit = 60*TICRATE*CV_FindVar("timelimit").value
	local timeleft = timelimit-leveltime
	local pointlimit = CV_FindVar("pointlimit").value
	//Find out the highest score and how many people/teams are holding it
	local count = 0
	local highscore = 0
	if not(G_GametypeHasTeams()) //FFA scorecheck
		for player in players.iterate
			if player.score > highscore
				highscore = player.score
				count = 1
			elseif player.score == highscore
				count = $+1
			end
		end
	else //Team scorecheck
		highscore = max(redscore,bluescore)
		if redscore == bluescore
			count = 2
		else
			count = 1
		end
	end



	//Score win conditions (non-survival)
	if not(survival)
	and (
		(pointlimit and highscore >= pointlimit) //Score condition met
		or (count == 1 and timelimit and timeleft <= 0) //Time condition met with one person/team in the lead
		)
		forcewin()
	return end //Exit function
	
	//Time out
	if timelimit and timeleft == 0 then
		B.DebugPrint("End of round check!",DF_GAMETYPE)
		//Get FFA victor conditions
		if not(G_GametypeHasTeams())
			//Game must have exactly one player with the highest score in order to force end the game
			if count == 1
				forcewin()
			end
			//Sudden death?
			if count > 1
				if survival
					A.SpawnLives = 0
					for player in players.iterate
						if player.revenge
						or player.spectator
						or player.lives == 0
						then continue end
						
						local extralives = player.lives-1
						player.preservescore = $-extralives
						player.score = player.preservescore
						player.lives = 1
						if player.playerstate == PST_LIVE
							if player.preservescore < highscore-extralives //Remove anyone below the mostlives threshold
								P_KillMobj(player.mo)
							else //Strip resources from remaining players
								player.shieldstock = {}
								P_RemoveShield(player)
								player.powers[pw_shield] = 0
								player.rings = 0
								local nega = P_SpawnMobjFromMobj(player.mo,0,0,0,MT_NEGASHIELD)
								nega.target = player.mo
							end
						end
					end
				end
				tiebreaker_t()
			end
		end
		//Get team victor conditions
		if G_GametypeHasTeams()
			if bluescore != redscore then
				forcewin()
			end
			if bluescore == redscore then
				if survival
					for player in players.iterate
						if player.spectator
						or player.revenge
						or player.lives == 0
						then continue end
						player.lives = 1
						P_RemoveShield(player)
						player.shieldstock = {}
						player.rings = 0
						local nega = P_SpawnMobjFromMobj(player.mo,0,0,0,MT_NEGASHIELD)
						nega.target = player.mo
					end
				end
				tiebreaker_t()
			end
		end
	end
	//Last man standing
	if survival and not(G_GametypeHasTeams()) and not(B.PreRoundWait())then
		if #A.Fighters < 2 then return end //Not enough players to determine winner/loser
		if survival and #A.Survivors < 2 then //Only one survivor left (or none)
			forcewin()
		return end
	end
	//Last team standing
	if survival and G_GametypeHasTeams() and not(B.PreRoundWait())then
		if not(#A.BlueFighters and #A.RedFighters) then return end //Not enough players on each team
		if not(#A.RedSurvivors and #A.BlueSurvivors) then //Only one team standing (or none)
			forcewin()
		return end
	end
end
