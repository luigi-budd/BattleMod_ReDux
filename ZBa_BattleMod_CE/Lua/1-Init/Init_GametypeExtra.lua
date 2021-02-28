local B = CBW_Battle
local G = B.Gametypes

//Team Scoretype (1 = add player score to team score. 0 = do nothing)
G.TeamScoreType = {0,0,0,0,0,0,0,0}
G.TeamScoreType[GT_ARENA] = 0
G.TeamScoreType[GT_TEAMARENA] = 0
G.TeamScoreType[GT_SURVIVAL] = 0
G.TeamScoreType[GT_TEAMSURVIVAL] = 0
G.TeamScoreType[GT_BATTLECTF] = 0
G.TeamScoreType[GT_CP] = 0
G.TeamScoreType[GT_TEAMCP] = 0
G.TeamScoreType[GT_DIAMOND] = 0
G.TeamScoreType[GT_TEAMDIAMOND] = 0

//Does this gametype support sudden death?
G.SuddenDeath = {false,false,false,false,false,false,false,false}
G.SuddenDeath[GT_ARENA] = false
G.SuddenDeath[GT_TEAMARENA] = false
G.SuddenDeath[GT_SURVIVAL] = true
G.SuddenDeath[GT_TEAMSURVIVAL] = true
G.SuddenDeath[GT_BATTLECTF] = false
G.SuddenDeath[GT_CP] = false
G.SuddenDeath[GT_TEAMCP] = false
G.SuddenDeath[GT_DIAMOND] = false
G.SuddenDeath[GT_TEAMDIAMOND] = false

//Does this gametype use the Battle format?
G.Battle = {false,false,false,false,false,false,false,false}
G.Battle[GT_ARENA] = true
G.Battle[GT_TEAMARENA] = true
G.Battle[GT_SURVIVAL] = true
G.Battle[GT_TEAMSURVIVAL] = true
G.Battle[GT_BATTLECTF] = true
G.Battle[GT_CP] = true
G.Battle[GT_TEAMCP] = true
G.Battle[GT_DIAMOND] = true
G.Battle[GT_TEAMDIAMOND] = true

//Does this gametype use the Control Point format?
G.CP = {false,false,false,false,false,false,false,false}
G.CP[GT_ARENA] = false
G.CP[GT_TEAMARENA] = false
G.CP[GT_SURVIVAL] = false
G.CP[GT_TEAMSURVIVAL] = false
G.CP[GT_BATTLECTF] = false
G.CP[GT_CP] = true
G.CP[GT_TEAMCP] = true
G.CP[GT_DIAMOND] = false
G.CP[GT_TEAMDIAMOND] = false

//Does this gametype use the Arena format?
G.Arena = {false,false,false,false,false,false,false,false}
G.Arena[GT_ARENA] = true
G.Arena[GT_TEAMARENA] = true
G.Arena[GT_SURVIVAL] = true
G.Arena[GT_TEAMSURVIVAL] = true
G.Arena[GT_BATTLECTF] = false
G.Arena[GT_CP] = false
G.Arena[GT_TEAMCP] = false
G.Arena[GT_DIAMOND] = false
G.Arena[GT_TEAMDIAMOND] = false

//Does this gametype use the Diamond format?
G.Diamond = {false,false,false,false,false,false,false,false}
G.Diamond[GT_ARENA] = false
G.Diamond[GT_TEAMARENA] = false
G.Diamond[GT_SURVIVAL] = false
G.Diamond[GT_TEAMSURVIVAL] = false
G.Diamond[GT_BATTLECTF] = false
G.Diamond[GT_CP] = false
G.Diamond[GT_TEAMCP] = false
G.Diamond[GT_DIAMOND] = true
G.Diamond[GT_TEAMDIAMOND] = true
