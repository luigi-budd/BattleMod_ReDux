local B = CBW_Battle
local A = B.Arena
local D = B.Diamond
local F = B.CTF
local CV = B.Console
local CP = B.ControlPoint
local I = B.Item

addHook("NetVars",B.NetVars.Sync)

addHook("MapChange",function(map)
	for player in players.iterate
		player.revenge = false
		player.preservescore = 0
	end
	D.Reset()
	B.RedScore = 0
	B.BlueScore = 0
	B.SuddenDeath = false
	B.Pinch = false
	B.PinchTics = 0
	B.Exiting = false
	A.ResetLives()
	I.GameReset()
	B.ResetSparring()
	F.RedFlag = nil
	F.BlueFlag = nil
end)

addHook("MapLoad",function(map)
	B.HideTime()
	D.GetSpawns()
	I.GetMapHeader(map)
	I.GenerateSpawns()
end)

addHook("TeamSwitch", B.JoinCheck)

addHook("ViewpointSwitch", B.TagCam)

addHook("PreThinkFrame", function()
	B.SparringPartnerControl()
	D.GameControl()
	I.GameControl()
	B.PinchControl()
	//Player control
	for player in players.iterate
		if player.deadtimer < 0 and player.deadtimer >= -TICRATE then player.deadtimer = 0 end
		B.PlayerPreThinkFrame(player)
	end
-- 	B.GetTailsCarry()
end)

addHook("ThinkFrame",function()	
	//Player control
	B.UserConfig()
	for player in players.iterate
		B.PlayerThinkFrame(player)
	end
	B.ResetScore()
	A.ResetScore()
end)

addHook("PostThinkFrame",function()
	if not(B.PreRoundWait())
		for player in players.iterate
			B.PlayerPostThinkFrame(player)
		end
	end
	A.UpdateSpawnLives()
	A.UpdateGame()
	A.GetRanks()
end)

addHook("IntermissionThinker",B.Intermission)