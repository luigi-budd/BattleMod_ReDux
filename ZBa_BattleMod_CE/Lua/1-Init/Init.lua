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

//Flags
rawset(_G,"DF_GAMETYPE",1)
rawset(_G,"DF_COLLISION",2)
rawset(_G,"DF_ITEM",4)
rawset(_G,"DF_PLAYER",8)

rawset(_G,"SKINVARS_GUARD",1)
rawset(_G,"SKINVARS_GUNSLINGER",2)
rawset(_G,"SKINVARS_NOSPINSHIELD",4)


//Version Info
B.VersionNumber = "8"
B.VersionSub = 6
B.VersionDate = "11/15/2020"