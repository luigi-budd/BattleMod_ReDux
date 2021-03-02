local B = CBW_Battle
local CV = B.Console
local CP = B.ControlPoint
local A = B.Arena
local D = B.Diamond
local F = B.CTF

hud.add(B.ActionHUD, player)
hud.add(B.StunBreakHUD, player)
hud.add(B.ShieldStockHUD, player)
hud.add(CP.HUD, player)
hud.add(D.HUD, player)
hud.add(F.HUD, player)
hud.add(B.PreRoundHUD, player)
hud.add(B.DebugHUD, player)
hud.add(A.WaitJoinHUD,player)
hud.add(A.HUD,player)
hud.add(B.PinchHUD,player)
hud.add(A.RevengeHUD,player)
hud.add(A.GameSetHUD,player)
hud.add(B.HitCounterHUD,player)
hud.add(B.SpectatorControlHUD,player)