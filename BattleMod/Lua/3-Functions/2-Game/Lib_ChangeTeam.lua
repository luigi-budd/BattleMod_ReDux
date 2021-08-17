local B = CBW_Battle
local A = B.Arena
local CV = B.Console

local notice = "\x83".."NOTICE: \x80"
B.JoinCheck = function(player,team,fromspectators,autobalance,scramble)
	if player.spectatortime == nil then
		player.spectatortime = 0
	end
	if not(player.spectatortime >= 0) and team != 0 then //Player join time cannot preceed assigned respawn delay
		CONS_Printf(player,"Please wait "..-player.spectatortime/TICRATE.."s to rejoin")
		return false
	end
	
	//Team balance
	local addplayers = 0
	if fromspectators
		addplayers = 1
	end
	if gametyperules&GTR_TEAMS and not(autobalance or scramble or splitscreen) and #A.Fighters > 1-addplayers
		local red = #A.RedFighters
		local blue = #A.BlueFighters
		if team == 1
			blue = $-1+addplayers
			if red > blue
				CONS_Printf(player,notice.."There are too many players on red team!")
				return false
			end
		end
		if team == 2
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
		else //Game over, can't join
			return false
		end
	return end
end