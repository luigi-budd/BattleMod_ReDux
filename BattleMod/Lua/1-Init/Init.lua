assert(not CBW_Battle, "Loaded multiple instances of BattleMod")

rawset(_G,"CBW_Battle",{})
local B = CBW_Battle

//Sub Tables
B.NetVars = {}
B.ControlPoint = {}
B.Gametypes = {}
B.Console = {}
B.Action = {}
B.PriorityFunction = {}
B.TrainingDummy = nil
B.TrainingDummyName = nil
B.HitCounter = 0
B.Item = {}
B.SuddenDeath = false
B.Pinch = false
B.Overtime = false
B.Exiting = false
B.PinchTics = 0
B.Arena = {}
B.Diamond = {}
B.CTF = {}
B.GuardFunc = {}
B.SkinVars = {}
B.MessageText = {}
B.RedScore = 0
B.BlueScore = 0
B.HUDMain = true
B.HUDAlt = true
B.HUDRoulette = {}

//Flags
rawset(_G,"DF_GAMETYPE",	1<<0)
rawset(_G,"DF_COLLISION",	1<<1)
rawset(_G,"DF_ITEM",		1<<2)
rawset(_G,"DF_PLAYER",		1<<3)

rawset(_G,"SKINVARS_GUARD",			1<<0)
rawset(_G,"SKINVARS_NOSPINSHIELD",	1<<1)
rawset(_G,"SKINVARS_GUNSLINGER",	1<<2)
rawset(_G,"SKINVARS_ROSY",			1<<3)