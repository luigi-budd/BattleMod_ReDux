local B = CBW_Battle
local CV = B.Console
local CP = B.ControlPoint
local A = B.Arena
local D = B.Diamond
local R = B.Ruby
local F = B.CTF
local C = B.Bank
local CR = C.ChaosRing

--Radar
hud.add(B.RadarHUD)
hud.add(B.MinimapHUD)

--Player info
hud.add(B.ChangeHUD)
hud.add(B.RingsHUD)
hud.add(B.ActionHUD)
hud.add(B.ShieldHUD)
hud.add(B.TeammateHUD)
hud.add(B.TimerHUD)
hud.add(B.ScoresTimerHUD, "scores")
hud.add(B.StartRingsHUD)

--Gamemode info
hud.add(CP.HUD)
hud.add(D.HUD)
hud.add(R.HUD)
hud.add(R.FadeFunc, "game")
hud.add(R.FadeFunc, "scores")
hud.add(A.AllFightersHUD,player)
hud.add(A.MyStocksHUD,player)
hud.add(A.BountyHUD,player)
hud.add(A.PlacementHUD)
hud.add(F.CompassHUD)
hud.add(F.TeamScoreHUD)
hud.add(F.DelayCapNotice)
hud.add(CR.ChaosRingHUD)
hud.add(CR.ChaosRingCapHUD)

--Game state info
hud.add(B.PreRoundHUD)
hud.add(B.PinchHUD,player)
hud.add(A.RevengeHUD,player)
hud.add(A.WaitJoinHUD,player)
hud.add(B.SpectatorControlHUD,player)
hud.add(F.CapHUD)
hud.add(F.DelayCapBar)
hud.add(A.GameSetHUD,player)

--Misc.
hud.add(B.HitCounterHUD,player)
hud.add(B.DebugHUD)
hud.add(B.TagGenHUD)
hud.add(B.DrawMatchPoint)

--Score screen
hud.add(B.StatsHUD, "scores")
hud.add(F.RankingHUD, "scores")
hud.add(B.TagRankHUD, "scores")
hud.add(CR.BankRankHUD, "scores")
hud.add(R.RubyRankHUD, "scores")
hud.add(D.DiamondRankHUD, "scores")

--Title HUD
hud.add(B.TitleHUD, "title")