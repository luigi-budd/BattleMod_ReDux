local B = CBW_Battle
local CV = B.Console

--Repurposed and edited this function from Lianvee's MinHUD
local function GetTimer(player)
	local tics
	local timelimit = CV_FindVar("timelimit").value
	local hidetime = CV_FindVar("hidetime").value
	if timelimit then
		timelimit = $ * 60 * TICRATE
		if gametyperules&GTR_FIXGAMESET then
			timelimit = $-(60*TICRATE)
		end
	end
	if hidetime then
		hidetime = $ * TICRATE
	end
	
	if (gametyperules & GTR_STARTCOUNTDOWN) 
		and (player.realtime <= hidetime)
	then
		tics = hidetime - player.realtime + TICRATE
		
	else
		if (gametyperules & GTR_TIMELIMIT) and timelimit then
			if timelimit > player.realtime then
				tics = timelimit - player.realtime
			else
				tics = 0	
			end
		elseif (gametyperules & GTR_STARTCOUNTDOWN) and (gametyperules & GTR_TIMELIMIT) then
			tics = timelimit - player.realtime
		elseif (gametyperules & GTR_STARTCOUNTDOWN) then
			tics = player.realtime - hidetime
		else
			tics = player.realtime
		end
	end
	
	return tics
end

B.TimerHUD = function(v, player, cam)
	if 	not (player.battleconfig_newhud)
		or not hud.enabled("time")
	then
		return
	end
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local x = 148
	local y = 18
	v.draw(160,y+5,v.cachePatch("HUD_FADBAR"),V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER|V_REVERSESUBTRACT)
	local p = displayplayer
	local tics = GetTimer(player)
	local mins = G_TicsToMinutes(tics)
	local secs = G_TicsToSeconds(tics)
	local cs = G_TicsToCentiseconds(tics)
	if (mins >= 10) then
		x = $ + 4
	end
	if (cs < 10) then
		cs = "0"..$
	end
	if (mins > 99) then
		mins = 99
		secs = 59
		cs = 99
	end
	v.drawNum(x, y, mins, flags)
	v.draw(x - 2, y, v.cachePatch("STTCOLON"), flags)
	x = $ + 20
	if (secs < 10) then
		v.drawNum(x - 8, y, 0, flags)
	end
	v.drawNum(x, y, secs, flags)
	v.drawString(x, y + 4, "."..cs, flags, "thin")
end
