local B = CBW_Battle
local A = B.Arena
local CV = B.Console

local yo = 152

//Enable/disable spectator controls hud
B.SpectatorControlHUD = function(v,player,cam)
	if not (B.HUDAlt) then return end
	if player.spectatortime != nil
	and (player.spectatortime < TICRATE*9 or (player.spectatortime < TICRATE*10 and player.spectatortime&1))
		hud.enable("textspectator")
	else
		hud.disable("textspectator")
	end
end

//Waiting to join
A.WaitJoinHUD = function(v, player, cam)
	if not (B.HUDAlt) then return end
	if not (gametyperules&GTR_LIVES) or (gametyperules&GTR_FRIENDLY) then return end //Competitive lives only
	local dead = (player.spectator and not(A.SpawnLives))
		or (player.playerstate == PST_DEAD and player.revenge)
	if not (dead) then return end
	if not(CV.Revenge.value) or B.SuddenDeath then
-- 		local t = "\x85".."You've been ELIMINATED!"
-- 		v.drawString(160,160,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
		local t = "\x85".."Wait until next round to join"
		v.drawString(160,yo,t,V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER,"center")
	elseif CV.Revenge.value then
		local t = "\x85".."You've been ELIMINATED!"
		v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		if B.SuddenDeath
-- 			local t = "\n\x85".."Wait until next round to join"
-- 			v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		else
			t = "\n\x80".."But you can still respawn as a \x86".."jetty-syn"
			v.drawString(160,yo,t,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
-- 		end
	end	
end

//Game set!
local lerpamt = FRACUNIT
A.GameSetHUD = function(v,player,cam)
	if not (B.BattleGametype()) or not (B.Exiting) or not (B.HUDAlt) then
		lerpamt = FRACUNIT
	return end
	local a = v.cachePatch("LTFNT065")
	local e = v.cachePatch("LTFNT069")
	local g = v.cachePatch("LTFNT071")
	local m = v.cachePatch("LTFNT077")
	local s = v.cachePatch("LTFNT083")
	local t = v.cachePatch("LTFNT084")
	local exclaim = v.cachePatch("LTFNT033")
	local text1 = {g,a,m,e}
	local x1 = 80
	local y1 = 80
	
	lerpamt = B.FixedLerp(0,FRACUNIT,$*90/100)
	local subtract = B.FixedLerp(0,180,lerpamt)
	local text2 = {s,e,t,exclaim}
	local x2 = 140
	local y2 = 100
	local spacing = 20
	for n = 1,#text1
		v.drawScaled(FRACUNIT*(x1+spacing*n-subtract),y1*FRACUNIT,FRACUNIT,text1[n],
			V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
		if text1[n] == m then
			x1 = $+8
		end
	end
	for n = 1,#text2
		v.drawScaled(FRACUNIT*(x2+spacing*n+subtract),y2*FRACUNIT,FRACUNIT,text2[n],
			V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
	end
end

//Revenge JettySyn
local revengehud = false
A.RevengeHUD = function(v,player,cam)
	if not (B.HUDAlt) then -- Gateway.
		revengehud = false
		return
	end
	if player.revenge and not(revengehud) then
		hud.disable("lives")
		hud.disable("rings")
		revengehud = true
	end
	if not(player.revenge) and revengehud then
		hud.enable("lives")
		hud.enable("rings")
		revengehud = false
	end
end