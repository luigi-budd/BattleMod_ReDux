local B = CBW_Battle
local A = B.Arena
local D = B.Ruby
local F = B.CTF
local CV = B.Console
local CP = B.ControlPoint
local I = B.Item

addHook("NetVars",B.NetVars.Sync)

addHook("MapChange",function(map)
	for player in players.iterate
		player.revenge = false
		player.preservescore = 0
        COM_BufInsertText(plr, "cechoflags 0") -- Reset cecho flags
        --// rev: reset these variables.
        player.ingametime = 0
        player.caps = 0
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
	F.RedScore = 0
    F.BlueScore = 0
	F.RedFlagPos = {x=0,y=0,z=0} -- Reset flag coords!
	F.BlueFlagPos = {x=0,y=0,z=0} -- Reset flag coords!
	F.ResetPlayerFlags() -- remove any gotflag field vars
	B.Timeout = 0
	F.GameState.CaptureHUDTimer = 0
	A.Bounty = nil
end)

addHook("MapLoad",function(map)
	F.LoadVars()
	B.HideTime()
	I.GetMapHeader(map)
	I.GenerateSpawns()
	for player in players.iterate
		if player.mo and player.mo.valid then player.mo.color = player.skincolor end
	end
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
		F.UpdateCaps(player)
	end
	B.ResetScore()
	A.ResetScore()
	B.Autobalance()
	--F.UpdateScore()
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