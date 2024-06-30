assert(not CBW_Battle, "Loaded multiple instances of BattleMod")

rawset(_G,"CBW_Battle",{})
local B = CBW_Battle

-- Sub Tables
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
B.Ruby = {}
B.Diamond = {}
B.CTF = {}
B.CTF.GameState = {}
B.GuardFunc = {}
B.SkinVars = {}
B.MessageText = {}
B.RedScore = 0
B.BlueScore = 0
B.HUDMain = true
B.HUDAlt = true
B.Timeout = 0
B.HUDRoulette = {}

-- Debug flags
rawset(_G,"DF_GAMETYPE",	1<<0)
rawset(_G,"DF_COLLISION",	1<<1)
rawset(_G,"DF_ITEM",		1<<2)
rawset(_G,"DF_PLAYER",		1<<3)

-- Skinvar flags
rawset(_G,"SKINVARS_GUARD",			1<<0)
rawset(_G,"SKINVARS_NOSPINSHIELD",	1<<1)
rawset(_G,"SKINVARS_GUNSLINGER",	1<<2)
rawset(_G,"SKINVARS_ROSY",			1<<3)

-- Define TOLs and gametypes
freeslot('tol_arena','tol_survival','tol_cp','tol_diamond','tol_battlectf','tol_bigarena','tol_battle','tol_eggrobotag')
G_AddGametype({
	name = "Arena",
	identifier = "arena",
	typeoflevel = TOL_ARENA|TOL_MATCH,
	rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_MATCH,
	intermissiontype = int_match,
	defaultpointlimit = 0,
	defaulttimelimit = 4,
	headerleftcolor = 56,
	headerrightcolor = 56,
	description = 'Bash other players with your spin and jump moves to earn points! Collect and use rings to unleash special moves unique to each character!'
})

G_AddGametype({
	name = "Team Arena",
	identifier = "teamarena",
	typeoflevel = TOL_ARENA|TOL_MATCH,
	rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_TEAMMATCH,
	intermissiontype = int_teammatch,
	defaultpointlimit = 0,
	defaulttimelimit = 4,
	headerleftcolor = 150,
	headerrightcolor = 37,
	description = 'Stick together! The team that can support each other and deal the most damage will be victorious!'
})

G_AddGametype({
	name = "Survival",
	identifier = "survival",
	typeoflevel = TOL_SURVIVAL,
	rules = GTR_OVERTIME|GTR_LIVES|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_MATCH,
	intermissiontype = int_match,
	defaultpointlimit = 0,
	defaulttimelimit = 5,
	headerleftcolor = 231,
	headerrightcolor = 231,
	description = "It's survival of the fittest! Manage your shields and rings as you compete to be the last critter standing."
})

G_AddGametype({
	name = "Team Survival",
	identifier = "teamsurvival",
	typeoflevel = TOL_SURVIVAL,
	rules = GTR_OVERTIME|GTR_LIVES|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_TEAMS|GTR_PITYSHIELD|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_TEAMMATCH,
	intermissiontype = int_teammatch,
	defaultpointlimit = 0,
	defaulttimelimit = 5,
	headerleftcolor = 150,
	headerrightcolor = 37,
	description = "Shake'm all down in this team-based survival format. When one team runs out of lives, the other wins!"
})

G_AddGametype({
	name = "Zone Control",
	identifier = "cp",
	typeoflevel = TOL_MATCH|TOL_CP,
	rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_MATCH,
	intermissiontype = int_match,
	defaultpointlimit = 3000,
	defaulttimelimit = 5,
	headerleftcolor = 75,
	headerrightcolor = 75,
	description = "The player who stands inside the score zone for long enough will claim its reward! Knock your foes out before they steal the spotlight!"
})

G_AddGametype({
	name = "Team Zone Control",
	identifier = "teamcp",
	typeoflevel = TOL_MATCH|TOL_CP,
	rules = GTR_OVERTIME|GTR_TEAMFLAGS|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_TEAMMATCH,
	intermissiontype = int_teammatch,
	defaultpointlimit = 3,
	defaulttimelimit = 5,
	headerleftcolor = 37,
	headerrightcolor = 150,
	description = "Players must work together to capture the control point before the opposing team does. The more players inside, the faster the capture!"
})

G_AddGametype({
	name = "Warp Heist",
	identifier = "diamond",
	typeoflevel = TOL_DIAMOND|TOL_MATCH,
	rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES,
	rankingtype = GT_MATCH,
	intermissiontype = int_match,
	defaultpointlimit = 6000,
	defaulttimelimit = 5,
	headerleftcolor = 148,
	headerrightcolor = 148,
	description = 'Find and seize the WArp Topaz on the field, then take it to a Control Point to score! Careful -- other players can steal the warp topaz, even just by touching it or you!!'
})

G_AddGametype({
	name = "Team Warp Heist",
	identifier = "teamdiamond",
	typeoflevel = TOL_DIAMOND|TOL_MATCH,
	rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES|GTR_TEAMFLAGS,
	rankingtype = GT_TEAMMATCH,
	intermissiontype = int_ctf,
	defaultpointlimit = 8,
	defaulttimelimit = 5,
	headerleftcolor = 37,
	headerrightcolor = 150,
	description = 'Two teams compete for a single warp topaz on the field; work together to seize the topaz and send it back whence it came!!'
})

-- Removed GTR_TEAMFLAGS; Battle CTF uses its own flag system
G_AddGametype({
	name = "Battle CTF",
	identifier = "battlectf",
	typeoflevel = TOL_CTF|TOL_BATTLECTF,
	rules = GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_OVERTIME|GTR_HURTMESSAGES,
	rankingtype = GT_CTF,
	intermissiontype = int_ctf,
	defaultpointlimit = 3,
	defaulttimelimit = 8,
	headerleftcolor = 37,
	headerrightcolor = 150,
	description = "Combine melee and special moves to capture the enemy flag while protecting your own. Master the slipstream to catch up to enemy flagrunners!"
})

freeslot('tol_bank')
G_AddGametype({
    name = "Bank",
    identifier = "bank",
    typeoflevel = TOL_BANK|TOL_CTF|TOL_BATTLECTF,
    rules = GTR_STARTCOUNTDOWN|GTR_OVERTIME|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|
	GTR_HURTMESSAGES|GTR_TEAMFLAGS,
    rankingtype = GT_CTF,
	intermissiontype = int_ctf,
	defaultpointlimit = 0,
	defaulttimelimit = 5,
    headerleftcolor = 37,
    headerrightcolor = 150,
    description = "Add rings to your base, and steal ring's from the enemy base!"
})

freeslot('tol_rubyrun')
G_AddGametype({
    name = "Ruby Run",
    identifier = "rubyrun",
    typeoflevel = TOL_RUBYRUN|TOL_CTF|TOL_BATTLECTF,
    rules = GTR_OVERTIME|GTR_STARTCOUNTDOWN|GTR_RESPAWNDELAY|GTR_PITYSHIELD|GTR_TEAMS|GTR_SPECTATORS|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_SPAWNINVUL|GTR_DEATHPENALTY|GTR_DEATHMATCHSTARTS|GTR_HURTMESSAGES|GTR_TEAMFLAGS,
    rankingtype = GT_CTF,
	intermissiontype = int_ctf,
	defaultpointlimit = 0,
	defaulttimelimit = 5,
    headerleftcolor = 37,
    headerrightcolor = 150,
    description = 'Reach the goalpost with the ruby crystal in hand!'
})

local B = CBW_Battle
local G = B.Gametypes

-- Vanilla gametypes aren't supported, so set them all to 0 values. (Vanilla gametypes start from 1 up to 8)
G.TeamScoreType = {0,0,0,0,0,0,0,0}
G.SuddenDeath 	= {false,false,false,false,false,false,false,false}
G.Battle 		= {false,false,false,false,false,false,false,false}
G.CP 			= {false,false,false,false,false,false,false,false}
G.Arena 		= {false,false,false,false,false,false,false,false}
G.Diamond 		= {false,false,false,false,false,false,false,false}
G.Ruby 			= {false,false,false,false,false,false,false,false}

-- Format: { [GAMETYPE], {[ GAMETYPE_VALUES ]}}
local GAMETYPE_INDICES = {
	{GT_ARENA			,{0, false, true, false, true, false, false}}, 
	{GT_TEAMARENA		,{0, false, true, false, true, false, false}}, 
	{GT_SURVIVAL		,{0, true,  true, false, true, false, false}}, 
	{GT_TEAMSURVIVAL	,{0, true,  true, false, true, false, false}}, 
	{GT_BATTLECTF		,{0, false, true, false, false,false, false}}, 
	{GT_CP				,{0, false, true, true,  false,false, false}},
	{GT_TEAMCP			,{0, false, true, true,  false,false, false}},
	{GT_DIAMOND			,{0, false, true, false, false,true,  false}},
	{GT_TEAMDIAMOND		,{0, false, true, false, false,true,  false}},
	{GT_BANK			,{0, false, true, false, false,false, false}},
	{GT_RUBYRUN 		,{0, false, false,false, false,false,  true}}
}
for i =1,#GAMETYPE_INDICES do
	local GAME_TYPE_INDEX 	= GAMETYPE_INDICES[i]
	local GAME_TYPE_VALUES 	= GAME_TYPE_INDEX[2]

	G.TeamScoreType[GAME_TYPE_INDEX[1]] = GAME_TYPE_VALUES[1] -- Team Scoretype (1 = add player score to team score. 0 = do nothing)
	G.SuddenDeath[GAME_TYPE_INDEX[1]] 	= GAME_TYPE_VALUES[2] -- Does this gametype support sudden death?
	G.Battle[GAME_TYPE_INDEX[1]] 		= GAME_TYPE_VALUES[3] -- Does this gametype use the Battle format?
	G.CP[GAME_TYPE_INDEX[1]] 			= GAME_TYPE_VALUES[4] -- Does this gametype use the Control Point format?
	G.Arena[GAME_TYPE_INDEX[1]] 		= GAME_TYPE_VALUES[5] -- Does this gametype use the Arena format?
	G.Diamond[GAME_TYPE_INDEX[1]] 		= GAME_TYPE_VALUES[6] -- Does this gametype use the Diamond format?
	G.Ruby[GAME_TYPE_INDEX[1]] 			= GAME_TYPE_VALUES[7] -- Does this gametype use the Ruby format?
end
