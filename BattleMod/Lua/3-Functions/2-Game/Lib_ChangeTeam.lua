local B = CBW_Battle
local A = B.Arena
local CV = B.Console

local notice = "\x83".."NOTICE: \x80"
B.JoinCheck = function(player,team,fromspectators,autobalance,scramble)
	if player.spectatortime == nil then
		player.spectatortime = 0
	end
	if team == 0 then //Penalty for abandoning the team
		if player.mo and player.mo.valid then
			local vfx = P_SpawnMobj(player.mo.x,player.mo.y,player.mo.z,MT_THOK)
			if vfx and vfx.valid then
				vfx.state = S_XPLD1
				S_StartSound(vfx,sfx_pop)
				S_StartSound(nil,sfx_jshard)
			end
		end
		player.spectator = true
		player.spectatortime = -10*TICRATE
		return true
	end
	if not(player.spectatortime >= 0) and team != 0 then //Player join time cannot preceed assigned respawn delay
		CONS_Printf(player,"Please wait "..-player.spectatortime/TICRATE.."s to rejoin")
		return false
	end
	
	-- Team balance
	local addplayers = 0
	if fromspectators
		addplayers = 1
	end
	if gametyperules&GTR_TEAMS and not(autobalance or scramble or splitscreen) and #A.Fighters > 1-addplayers
		local red = #A.RedFighters
		local blue = #A.BlueFighters
		if team == 1 then
			blue = $-1+addplayers
			if red > blue
				CONS_Printf(player,notice.."There are too many players on red team!")
				return false
			end
		end
		if team == 2 then
			red = $-1+addplayers
			if blue > red
				CONS_Printf(player,notice.."There are too many players on blue team!")
				return false
			end
		end
	end
	
	if not(gametyperules&GTR_LIVES) or not(B.BattleGametype()) then return end //Competitive lives only
	if (autobalance or scramble) then
		if player.playerstate == PST_LIVE then
			player.lives = $+1 //Negating the death caused by team balancing
		end
	return end
	if (fromspectators) then //Validity check for joining a game in progress
		if A.SpawnLives then
			player.lives = A.SpawnLives //Spawn with the amount of lives the game thinks is fair
			return true
		elseif CV.Revenge.value then //Player was eliminated but can still be a jettysyn
			player.lives = 1
			player.revenge = 1
			return true
		else -- Game over, can't join
			return false
		end
	return end
end

--// rev: Balanced autobalance
--[[ A player will NOT be autobalanced depending on the following factors in order:
	1. If game mode has a cap type, then if they got lots, they are exempt
	2. Depending on points. If they got lots, they are exempt
	3. Depending on time.   If they got lots of time, they are exempt.

	If everything up to this point has been equal ..
		(e.g. let's say 3 players with equal caps, points, time)
	.. then it will be RNG.	
]]

--// team: Red/blue
--// amount: The amount required to balance teams
--// NOTE: Caps reset when map changes, in-game time resets when map changes/player spectates (see MapChange hook)
local function autobalance_team(team, amount)
	local sorted = team

	table.sort(sorted, function(p1, p2)
		if not (p1 or p2) then return end

		--// 1. Flag caps
		if 	(gametype == GT_CTF or gametype == GT_BATTLECTF) and p1.flagscore == p2.flagscore then

			--// 2. Score
	    	if 	p1.score == p2.score then 

	    		--// 3. Time since the player has NOT been a spectator
	   			if 	p1.ingametime == p2.ingametime then 

	    			--// Let's assume this is RNG (it's actually not, gonna come abck to this later)
 	 				return #p1 > #p2

	   			else
	   				return p1.ingametime > p2.ingametime
	   			end

	    	else
	    		return p1.score > p2.score 
	    	end

	    else
			return p1.caps > p2.caps
		end
	end)

	local count = 0
	for i = #sorted, 1, -1 do
		local p = sorted[i]

		--// If amount reached, don't iterate over players anymore.
		if count >= amount then break end

		--// small hack, since this runs every frame, up the count if it's already players with autobalance
		--// and continue the loop
		if not (p and p.mo) or p.autobalancing then 
			count = $+1
			continue 
		end
		p.autobalancing = 1
		count = $+1
	end
end

B.Autobalance = function()
	if not G_GametypeHasTeams() then return end
	if CV.Autobalance.value and CV_FindVar("autobalance").value then
		CV_Set(CV.Autobalance, "0")
		-- TODO: this is printed twice, idk why
		print("`autobalance` must be off in order for `battle_autobalance` to work!")
		return
	elseif not CV.Autobalance.value then return end

	local redteam = {}
	local bluteam = {}
	for p in players.iterate do

		--// Count players on red/blue. Ignores spectators and flag holders.
		if not p.spectator and not p.gotflag then
			if 		p.ctfteam == 1 then     -- RED
				table.insert(redteam, p)
			elseif 	p.ctfteam == 2 then -- BLUE
				table.insert(bluteam, p)
			end
		end
	end

	--// If teams are unequal, let's do something about it
	--// Also won't cause autobalance if the other team is equal - 1
	local rlen = #redteam
	local blen = #bluteam
	local blimit = (blen + 1) == rlen
	local rlimit = (rlen + 1) == blen
	local amount = abs(rlen-blen)-1
	if amount < 0 then amount = 0 end
	
	if rlen ~= blen and not (blimit or rlimit) then

		--// Check which team has most players, and autobalance from there.
		if rlen > blen then
			autobalance_team(redteam, amount)
		else
			autobalance_team(bluteam, amount)
		end

	--// If teams somehow got equalized, let's cancel the autobalance process.
	elseif rlen == blen or (blimit or rlimit) then
		for p in players.iterate do
			p.autobalancing = nil
		end
	end
end
