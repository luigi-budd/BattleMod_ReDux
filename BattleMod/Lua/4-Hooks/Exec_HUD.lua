local B = CBW_Battle
local CV = B.Console
local CP = B.ControlPoint
local A = B.Arena
local D = B.Diamond
local R = B.Ruby
local F = B.CTF
local C = B.Bank
local CR = C.ChaosRing

--Make a wrapper function so these can be modified
--externally by any modder
local history = {}
local samplecount = 150
hud.add(function(v,p,c)
	local function Wrap(func, name)
		if name:len() < 21
			for i = 1, 21 - name:len()
				name = $ .. " "
			end
		end

		if history[name] == nil
			history[name] = {samples = {}}
		end

		local micros = getTimeMicros()
		func(v,p,c)
		local len = getTimeMicros() - micros

		table.insert(history[name].samples, len)
		if #history[name].samples > samplecount
			table.remove(history[name].samples, 1)
		end

		len = 0
		local counted = 0
		for k,val in ipairs(history[name].samples)
			len = $ + val
			counted = $ + 1
		end
		len = $ / counted

		print(string.format("\x82%s\x80:\t %dus\t \x86(%d samples)", name, len, counted))
	end

	print("leveltime "..leveltime.." start")
	--Radar
	Wrap(B.RadarHUD, "B.RadarHUD")
	Wrap(B.MinimapHUD, "B.MinimapHUD")

	--Player info
	Wrap(B.ChangeHUD, "B.ChangeHUD")
	Wrap(B.RingsHUD, "B.RingsHUD")
	Wrap(B.ActionHUD, "B.ActionHUD")
	Wrap(B.ShieldHUD, "B.ShieldHUD")
	Wrap(B.TeammateHUD, "B.TeammateHUD")
	Wrap(B.TimerHUD,"B.TimerHUD")
	Wrap(B.StartRingsHUD,"B.StartRingsHUD")

	--Gamemode info
	Wrap(CP.HUD,"CP.HUD")
	Wrap(D.HUD,"D.HUD")
	Wrap(R.HUD,"R.HUD")
	Wrap(R.FadeFunc,"R.FadeFunc")
	Wrap(A.AllFightersHUD,"A.AllFightersHUD")
	Wrap(A.MyStocksHUD,"A.MyStocksHUD")
	Wrap(A.BountyHUD,"A.BountyHUD")
	Wrap(A.PlacementHUD,"A.PlacementHUD")
	Wrap(F.CompassHUD,"F.CompassHUD")
	Wrap(F.TeamScoreHUD,"F.TeamScoreHUD")
	Wrap(F.DelayCapNotice,"F.DelayCapNotice")
	Wrap(CR.ChaosRingHUD,"CR.ChaosRingHUD")
	Wrap(CR.ChaosRingCapHUD,"R.ChaosRingCapHUD")

	--Game state info
	Wrap(B.PreRoundHUD,"B.PreRoundHUD")
	Wrap(B.PinchHUD,"B.PinchHUD")
	Wrap(A.RevengeHUD,"A.RevengeHUD")
	Wrap(A.WaitJoinHUD,"A.WaitJoinHUD")
	Wrap(B.SpectatorControlHUD,"B.SpectatorControlHUD")
	Wrap(F.CapHUD,"F.CapHUD")
	Wrap(F.DelayCapBar,"F.DelayCapBar")
	Wrap(A.GameSetHUD,"A.GameSetHUD")

	--Misc.
	Wrap(B.HitCounterHUD,"B.HitCounterHUD")
	Wrap(B.DebugHUD,"B.DebugHUD")
	Wrap(B.TagGenHUD,"B.TagGenHUD")
	Wrap(B.DrawMatchPoint,"B.DrawMatchPoint")
end, "game")

hud.add(function(v,p,c) --Ditto
	B.ScoresTimerHUD(v,p,c)
	
	R.FadeFunc(v,p,c)
	
	--Score screen
	B.StatsHUD(v,p,c)
	F.RankingHUD(v,p,c)
	B.TagRankHUD(v,p,c)
	CR.BankRankHUD(v,p,c)
	R.RubyRankHUD(v,p,c)
	D.DiamondRankHUD(v,p,c)
end,"scores")

--Title HUD
hud.add(B.TitleHUD, "title")