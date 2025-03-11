local B = CBW_Battle
local CV = B.Console
local F = B.CTF
local C = B.Bank
local CR = C.ChaosRing

local lerpamt = FRACUNIT

local CHAOSRING1 = 1<<0
local CHAOSRING2 = 1<<1
local CHAOSRING3 = 1<<2
local CHAOSRING4 = 1<<3
local CHAOSRING5 = 1<<4
local CHAOSRING6 = 1<<5

CR.ChaosRingCapHUD = function(v)
	if (not(B.BankGametype())) then
		return
	end
	
	--An attempt to look exactly like the hardcode cecho
	if not(F.GameState.CaptureHUDTimer) then --... Except for the text easing in.
		lerpamt = FRACUNIT
	else
        if F.GameState.CaptureHUDName > 0 then
            local trans = 0
            if (F.GameState.CaptureHUDTimer <= 20) then
                trans = V_10TRANS * ((20 - F.GameState.CaptureHUDTimer) / 2)
            end
            local chaosringnum = F.GameState.CaptureHUDName --It's fine I swear
            local x = 160
            local y = B.Exiting and 160 or 66
            lerpamt = B.FixedLerp(0,FRACUNIT,$*90/100)
            local subtract = B.FixedLerp(0,180,lerpamt)
            v.drawString(x+subtract, y, "A "..CR.Data[chaosringnum].textmap.."Chaos Ring".."\x80".." has appeared!", trans, "center")
            F.GameState.CaptureHUDTimer = $ - 1
        end
	end

    if not(#server.AvailableChaosRings or B.PreRoundWait()) then
        local tics = server.InitSpawnWait-(leveltime-(CV_FindVar("hidetime").value*TICRATE))
        local x = 320/2 * FRACUNIT
        local y = 45 * FRACUNIT
        local f = V_PERPLAYER|V_SNAPTOTOP|(tics > TICRATE*10 and V_HUDTRANSHALF or V_HUDTRANS)
        local baseradius = 12 * FRACUNIT
        local radius = baseradius + sin(tics*ANG1)*4
        local referencepatch = v.cachePatch("CHRING1")
        local scalediv = 2
        local xoff = (referencepatch.width/(scalediv*2)) + (baseradius/2)
        --local yoff = (referencepatch.height/(scalediv*2)) + (baseradius/2)
        if tics > TICRATE or tics%2!=0 then
            for i = 1, 6 do
                local angle = ((i-1) * ANG60) + (tics * ANG1)
                local px = x + FixedMul(cos(angle), radius) +  - xoff
                local py = y + FixedMul(sin(angle), radius) --+ yoff
                local patch = v.cachePatch("CHRING"..i)
                v.drawScaled(px, py, FRACUNIT/scalediv, patch, f)
            end
        end
		if tics > TICRATE*3 or tics%2==0 then
            v.drawString((x/FU)-2, y/FU, tics/TICRATE, f, "thin-center")
        end
    elseif not (B.Exiting) then
        local team = nil
        for i = 1, 2 do
            local bank = (i==1 and C.RedBank) or C.BlueBank
            if bank and bank.valid and bank.chaosrings == (CHAOSRING1|CHAOSRING2|CHAOSRING3|CHAOSRING4|CHAOSRING5|CHAOSRING6)
                team = (i==1 and "\x85".."Red Team".."\x80") or "\x84".."Blue Team".."\x80"
            end
        end

        --Hi Cyan

        local c = CR.Data

        local action = "\x82".."win".."\x80"


        if team then
            local trans = B.Timeout and V_HUDTRANSHALF or V_HUDTRANS
            v.drawString(320/2, 60, "The "..team.." will "..action.." in".."\n"..(server.WinCountdown/TICRATE), V_PERPLAYER|V_SNAPTOTOP|trans, "thin-center")
        end
    end
end

CR.ChaosRingHUD = function(v, player)
    --Froot Loops (Chaos Rings)
    if not B.BankGametype() then
        return
    end
    local flags = V_PERPLAYER|V_SNAPTOTOP
    local x = 160*FRACUNIT
    local y = (CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) and 26*FRACUNIT) or 26*FRACUNIT
    local rednum = 0
    local bluenum = 0
    for t = 1, 2 do
        local val = 1
        local flip = (t==1 and val) or -val
        for i = 1, 6 do
            local num = i
            local chaosring = CR.GetChaosRing(num)
            if not(chaosring and chaosring.valid) then continue end
            if not((chaosring.captured and (chaosring.captureteam == t)) or ((chaosring.target and chaosring.target.valid and chaosring.target.player and (chaosring.target.player.ctfteam == t) and chaosring.target.player.gotcrystal_time and not(chaosring.chaosring_bankkey)) and (leveltime%2)==1)) then continue end
            local patch = v.cachePatch("CHRING"..num)
            local trans = (chaosring.fuse or chaosring.beingstolen) and (leveltime/6)%2==1 and V_HUDTRANSHALF or V_HUDTRANS
            if chaosring.beingstolen then
                local shake = 1
                x = $ + v.RandomRange(-shake,shake)
			    y = $ + v.RandomRange(-shake,shake)
            end
            v.drawScaled((x-(FRACUNIT*3)+(flip*((FRACUNIT/3)*(28)))*(i+2)), (y+(FRACUNIT*10)), FRACUNIT/2, patch, flags|trans)
        end
    end
end

local BASEVIDWIDTH = 320
local BASEVIDHEIGHT = 200

local ringframe_counter = 1

-- Draws flag next to players' icons, shows the flag power-up icon, etc.
CR.RankingHUD = function(v)
	-- Ensure that the gametype is custom ctf!
	if not(B.BankGametype()) then return end

    ringframe_counter = (($+1)<(states[S_TEAMRING].var1+1) and $+1) or 1

	local intpatch = {v.getSpritePatch(SPR_TRNG, ringframe_counter)}

    local ring = intpatch[1]
    local flip = (intpatch[2] and V_FLIP) or 0

	local redplayers = 0
	local blueplayers = 0
	local x, y = 0--40, 32

	local players_sorted = {}
	for p in players.iterate do
		table.insert(players_sorted, p)
	end

	-- Properly sort players
	-- TODO: This probably still won't work.. what to do?
	-- Maybe recode the entirety of rankings i guess? :shrug:
	table.sort(players_sorted, function(a, b)
		if a.score == b.score then
		return #a > #b
		else
		return (a.score > b.score)
		end
	end)

	for i=1, #players_sorted do
		local p = players_sorted[i]
		if p.spectator then continue end
		--if p.ctfteam == 0 then continue end

		local cond = (not CV_FindVar("compactscoreboard").value) and (redplayers <= 9 or blueplayers <= 9)
		if p.ctfteam == 1 then
			redplayers = $+1
			--if (redplayers > 8) then continue end
			if cond then 
				x = 32 + (BASEVIDWIDTH/2)
				y = (redplayers * 16) + 16
			else
				x = 14 + (BASEVIDWIDTH/2)
				y = (redplayers * 9) + 20
			end
		elseif p.ctfteam == 2 then
			blueplayers = $+1
			--if (blueplayers > 8) then continue end
			if cond then
				x = 32
				y = (blueplayers * 16) + 16
			else
				x = 14
				y = (blueplayers * 9) + 20
			end
		else 
			continue
		end

		local iconscale = cond and FRACUNIT/2 or FRACUNIT/4
		local fx = cond and x-12 or x-5
		local fy = cond and y+12 or y+8

        if p.gotcrystal and p.mo and p.mo.valid and p.mo.chaosring and p.mo.chaosring.valid then
            v.drawScaled(fx*FRACUNIT, fy*FRACUNIT, iconscale, ring, 0|flip, v.getColormap(0, CR.Data[p.mo.chaosring.chaosring_num].color))
        end
	end
end

