local B = CBW_Battle
local C = B.Bank
C.RedBank = nil
C.BlueBank = nil
C.ChaosRing = {}
local CR = C.ChaosRing

--Constants
local CHAOSRING_STARTSPAWNBUFFER = TICRATE*25 --Time it takes for Chaos Rings to start spawning
local CHAOSRING_SPAWNBUFFER = TICRATE*10 --Chaos rings spawn every X seconds
local CHAOSRING_SCALE = FRACUNIT+(FRACUNIT/2) --Scale of Chaos Rings
local CHAOSRING_TYPE = MT_BATTLE_CHAOSRING --Object Type
local CHAOSRING_WINTIME = TICRATE*12 --Countdown to a team win if they have all 6
local CHAOSRING_CAPTIME = TICRATE*5 --Time it takes to capture a Chaos Ring
local CHAOSRING_STEALTIME = TICRATE*5 --Time it takes to steal a Chaos Ring
local CHAOSRING_INVULNTIME = TICRATE*15 --How long a Chaos Ring is intangible after capture
local CHAOSRING_SCOREAWARD = 50 --50 points per chaos ring
local CHAOSRING_WINPOINTS = 9999
CR.SpawnCountdown = 0
CR.GlobalAngle = ANG20
CR.InitSpawnWait = CHAOSRING_STARTSPAWNBUFFER

local CHAOSRING1 = 1<<0
local CHAOSRING2 = 1<<1
local CHAOSRING3 = 1<<2
local CHAOSRING4 = 1<<3
local CHAOSRING5 = 1<<4
local CHAOSRING6 = 1<<5

local CHAOSRING_ENUM = {CHAOSRING1, CHAOSRING2, CHAOSRING3, CHAOSRING4, CHAOSRING5, CHAOSRING6}
local CHAOSRING_GETENUM = {
	[CHAOSRING1] = 1,
	[CHAOSRING2] = 2,
	[CHAOSRING3] = 3,
	[CHAOSRING4] = 4,
	[CHAOSRING5] = 5,
	[CHAOSRING6] = 6
}
local idletics = TICRATE*16
local waittics = TICRATE*4
local freetics = TICRATE
local bounceheight = 10
local rotatespd = ANG1*8

local SLOWCAPPINGALLY_SFX  = sfx_kc5a
local SLOWCAPPINGENEMY_SFX = sfx_kc59

CR.SpawnTable = {}
CR.WinCountdown = CHAOSRING_WINTIME
CR.LiveTable = {nil, nil, nil, nil, nil, nil} --Table where you can get each Chaos ring's Object

CR.Data = {
	[1] = { --Gold
		color = SKINCOLOR_GOLDENROD,
		textmap = "\x82"
	},

	[2] = { --Light Blue
		color = SKINCOLOR_SKY,
		textmap = "\x88"
	},

	[3] = { --Green
		color = SKINCOLOR_MASTER,
		textmap = "\x83"
	},

	[4] = { --Pink
		color = SKINCOLOR_FANCY,
		textmap = "\x81"
	},

	[5] = { --Purple
		color = SKINCOLOR_PURPLE,
		textmap = "\x89"
	},

	[6] = { --Blue
		color = SKINCOLOR_SAPPHIRE,
		textmap = "\x84"
	}
}

local resetVars = function()
	CR.SpawnTable = {} --Clear the table
	CR.WinCountdown = CHAOSRING_WINTIME
	CR.LiveTable = {nil, nil, nil, nil, nil, nil} --Table where you can get each Chaos ring's Object
	CR.SpawnCountdown = 0
	CR.GlobalAngle = ANG20
	CR.InitSpawnWait = CHAOSRING_STARTSPAWNBUFFER
end

local addPoints = function(team, points)
	if team == 1
		redscore = $ + points
	else
		bluescore = $ + points
	end
end

local insertSpawnPoint = function(mt)
	table.insert(CR.SpawnTable, { --Data for the spawn
		x = mt.x*FRACUNIT,
		y = mt.y*FRACUNIT,
		z = mt.z*FRACUNIT,
		options = mt.options,
		scale = mt.scale,
		mo = nil --Will use this field later
	})
end

local CHAOSRING_DATA = CR.Data
local CHAOSRING_TEXT = function(num)
	return CHAOSRING_DATA[num].textmap.."Chaos Ring".."\x80"
end

addHook('MapLoad', do

	if not(B.BankGametype()) then return end

	resetVars()

	for mt in mapthings.iterate do
		if mt and mt.valid and (mt.type == (mobjinfo[MT_BATTLE_CHAOSRINGSPAWNER].doomednum)) then --Match Chaos Emerald Spawn
			insertSpawnPoint(mt)
		end
	end

	if not(#CR.SpawnTable) or (#CR.SpawnTable < 6) then
		for mt in mapthings.iterate do
			if mt and (mt.type == (321)) and mt.valid then --Match Chaos Emerald Spawn
				insertSpawnPoint(mt)
			end
		end
	end
end)

local freetics = TICRATE
local idletics = TICRATE*16

local function free(mo)
	if not (mo and mo.valid) then return end
	mo.fuse = freetics
	mo.flags = ($|MF_GRENADEBOUNCE) & ~(MF_SPECIAL)
	mo.idle = idletics
end


local function touchChaosRing(mo, toucher) --Going to copy Ruby/Topaz code here
	if mo.target == toucher or not(toucher.player) -- This toucher has already collected the item, or is not a player
	or P_PlayerInPain(toucher.player) or toucher.player.powers[pw_flashing] -- Can't touch if we've recently taken damage
	or toucher.player.tossdelay -- Can't collect if tossflag is on cooldown
		return true
	end
	local previoustarget = mo.target
	if (G_GametypeHasTeams() and previoustarget and previoustarget.player and (previoustarget.player.ctfteam == toucher.player.ctfteam))
		return true
	end
	if toucher.player.ctfteam == mo.ctfteam then
		return true
	end
	if toucher.player.gotcrystal then
		return true
	end
	if previoustarget and previoustarget.valid then
		if previoustarget.player then
			previoustarget.player.gotcrystal = false
		end
		mo.lasttouched = previoustarget
	else
		mo.lasttouched = toucher
	end
	if mo.captured and (toucher.player) then
		mo.captured = nil
		--mo.angle = 0
		mo.bank.chaosrings = $ & ~CHAOSRING_ENUM[mo.chaosring_num]
		mo.bank = nil
	end
	if mo.target and mo.target.valid then
		
		if not(mo.target.player) then --Bank?
			CR.WinCountdown = CHAOSRING_WINTIME
		end

		mo.target.chaosring = nil
	end
	toucher.chaosring = mo
	toucher.player.gotcrystal = true
	mo.target = toucher
	free(mo)
	mo.idle = nil
	mo.scale = mo.idealscale
	mo.ctfteam = 0
	P_SetObjectMomZ(toucher, toucher.momz/2)
	S_StartSound(mo,sfx_lvpass)
	if (splitscreen or (displayplayer and toucher.player == displayplayer)) or (displayplayer and previoustarget and previoustarget.player and previoustarget.player == displayplayer)
		S_StartSound(nil, sfx_kc5e)
	end
	toucher.spritexscale = toucher.scale
	toucher.spriteyscale = toucher.scale
	if not(previoustarget) then
		B.PrintGameFeed(toucher.player," picked up a "..CHAOSRING_TEXT(mo.chaosring_num).."!")
	elseif previoustarget.player
		B.PrintGameFeed(toucher.player," stole a "..CHAOSRING_TEXT(mo.chaosring_num).." from ",previoustarget.player,"!")
	end
	return true
end


local function captureChaosRing(mo, bank)
	mo.flags = $ & ~MF_SPECIAL
	bank.chaosrings = $|(CHAOSRING_ENUM[mo.chaosring_num])
	mo.bank = bank
	mo.captured = true
	addPoints(mo.target.player.ctfteam, CHAOSRING_SCOREAWARD)
	mo.fuse = CHAOSRING_INVULNTIME
	mo.scale = mo.idealscale - (mo.idealscale/3)
	mo.ctfteam = mo.target.player.ctfteam
end

local function playerSteal(mo, bank)
	if mo.player.gotcrystal then return end
	if #bank.chaosrings_table then
		if not(mo.chaosring_tosteal) then
			local available_rings = {}
			for k, ringnum in ipairs(bank.chaosrings_table) do
				local v = CR.LiveTable[ringnum]
				if not (v and v.valid and v.captured and not(v.fuse) and not(v.beingstolen)) then
					continue
				end
				table.insert(available_rings, ringnum)
			end
			if not(#available_rings) then return end
			local pickme = CR.LiveTable[available_rings[P_RandomRange(1, #available_rings)]]
			pickme.beingstolen = mo
			mo.chaosring_tosteal = pickme
		else
			mo.stealing = true
			mo.player.gotcrystal_time = ($~=nil and $+1) or 1
			local sfx = sfx_kc59
			if mo.player.gotcrystal_time % 35 == 11 then
				S_StartSoundAtVolume(mo, sfx, 160)
			elseif mo.player.gotcrystal_time % 35 == 22 then
				S_StartSoundAtVolume(mo, sfx, 90)
			elseif mo.player.gotcrystal_time % 35 == 33 then
				S_StartSoundAtVolume(mo, sfx, 20)
			end
		end
	end

	if mo.player.gotcrystal_time >= CHAOSRING_STEALTIME then
		if mo.chaosring_tosteal and mo.chaosring_tosteal.valid then
			mo.player.gotcrystal_time = nil
			mo.chaosring_tosteal.target = nil
			mo.chaosring_tosteal.captured = nil
			table.remove(bank.chaosrings_table, mo.chaosring_tosteal.bankkey)
			mo.chaosring_tosteal.bankkey = nil
			touchChaosRing(mo.chaosring_tosteal, mo)
			mo.chaosring_tosteal.beingstolen = nil
			mo.chaosring_tosteal = nil
			mo.player.gotcrystal_time = nil
			return true
		end
	end
end

addHook("TouchSpecial", touchChaosRing, CHAOSRING_TYPE)

addHook("MobjFuse",function(mo)
	if not(mo.captured) then
		mo.flags = $|MF_SPECIAL
		return true
	else
		return true
	end
end,CHAOSRING_TYPE)


local function spawnChaosRing(num, chaosringnum, re)
	if not(CR.SpawnTable[num]) then
		return
	end

	if CR.SpawnTable[num].mo and CR.SpawnTable[num].mo.valid then
		return
	end
	local thing = CR.SpawnTable[num]
	local data = CHAOSRING_DATA[chaosringnum]

	local flip = ((thing.options&MTF_OBJECTFLIP) and -1) or 1
	local float = ((thing.options&MTF_OBJECTFLIP) and 1) or 0
	--local z = ((thing.options & MTF_AMBUSH) and (thing.z+(24*FRACUNIT))) or thing.z
	local z = thing.z+(70*FRACUNIT)

	thing.mo = P_SpawnMobj(thing.x, thing.y, z, CHAOSRING_TYPE)
	if flip == -1 then
		thing.mo.flags2 = $|MF2_OBJECTFLIP
	end
	thing.mo.scale = FixedMul(thing.scale, CHAOSRING_SCALE)
	thing.mo.state = S_TEAMRING
	thing.mo.color = data.color
	thing.mo.chaosring_num = chaosringnum
	thing.mo.idealz = thing.mo.z
	thing.mo.idealscale = FixedMul(thing.scale, CHAOSRING_SCALE)
	thing.mo.spawnthing = thing
	thing.num = num
	thing.mo.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
	CR.LiveTable[chaosringnum] = thing.mo
	table.remove(CR.SpawnTable, num)
	print("A "..CHAOSRING_TEXT(chaosringnum).." has "..((re and "re") or "").."spawned!")
	if re then
		S_StartSound(nil, sfx_cdfm44)
	end
end

local CHAOSRING_AMBIENCE = sfx_nullba--freeslot("sfx_crng1")
local CHAOSRING_RADAR = freeslot("sfx_crng2")

sfxinfo[CHAOSRING_RADAR].caption = "/"

local chaosRingFunc = function(mo)
	mo.shadowscale = FRACUNIT>>1
	
	-- Blink
	if mo.fuse&1
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $&~MF2_DONTDRAW
	end
	
	mo.angle = $+rotatespd
	
	-- Owner has been pushed by another player
	if mo.flags&MF_SPECIAL and mo.target and mo.target.valid 
	and mo.target.pushed_last and mo.target.pushed_last.valid
		touchChaosRing(mo,mo.target.pushed_last)
	end
	
	-- Owner has taken damage or has gone missing
	if mo.target and mo.target.player
		if not(mo.target.valid)
		or P_PlayerInPain(mo.target.player)
		or mo.target.player.playerstate != PST_LIVE
			if mo.target and mo.target.valid and mo.target.player then
				B.PrintGameFeed(mo.target.player," dropped the "..CHAOSRING_TEXT(mo.chaosring_num)..".")
			end
			mo.target.player.gotcrystal = false
			mo.target.player.gotcrystal_time = 0
			mo.target = nil
			B.ZLaunch(mo,FRACUNIT*bounceheight/2,true)
			--B.XYLaunch(mo,mo.angle,FRACUNIT*5)	
			P_InstaThrust(mo,mo.angle,FRACUNIT*5)
			free(mo)
			S_StartSound(mo, sfx_cdfm67)
		end
	end
	
	-- Unclaimed behavior
	if not(mo.target and mo.target.valid) then
		mo.flags = ($|MF_BOUNCE)&~MF_SLIDEME
		if mo.flags & MF_GRENADEBOUNCE == 0
			mo.flags = $|MF_NOGRAVITY
			local zz = mo.idealz + (sin(leveltime * ANG10) * 128)
			B.ZLaunch(mo, (zz - mo.z) / 120, false)
			
		else
			if not(leveltime%8) then
				local spark = P_SpawnMobjFromMobj(mo,0,0,0,MT_SUPERSPARK)
				spark.scale = mo.scale
				spark.colorized = true
				spark.color = mo.color
				spark.spriteyoffset = $-(FRACUNIT*6)
			end
			mo.flags = $&~MF_NOGRAVITY
			if P_IsObjectOnGround(mo)
				-- Bounce behavior
				B.ZLaunch(mo, FRACUNIT*bounceheight/2, true)
				S_StartSoundAtVolume(mo, sfx_tink, 100)
			end
		end
		-- Presence ambience
		if not S_SoundPlaying(mo, CHAOSRING_AMBIENCE)
			S_StartSound(mo, CHAOSRING_AMBIENCE)
		end
	else
		if S_SoundPlaying(mo, CHAOSRING_AMBIENCE)
			S_StopSoundByID(mo, CHAOSRING_AMBIENCE)
		end

		if not(leveltime%8) then
			local spark = P_SpawnMobjFromMobj(mo,0,0,0,MT_SUPERSPARK)
			spark.scale = mo.scale
			spark.colorized = true
			spark.color = mo.color
			spark.spriteyoffset = $-(FRACUNIT*6)
		end

		mo.flags = ($&~MF_BOUNCE)|MF_NOGRAVITY|MF_SLIDEME
		local t = mo.target
		--print(t.player)
		local ang = (mo.captured and (ANG1*60*mo.chaosring_num)+CR.GlobalAngle) or mo.angle
		local dist = mo.target.radius*3
		local x = t.x+P_ReturnThrustX(mo,ang,dist)
		local y = t.y+P_ReturnThrustY(mo,ang,dist)
		local z = t.z+abs(leveltime&63-31)*FRACUNIT/2 -- Gives us a hovering effect
		if P_MobjFlip(t) == 1 -- Make sure our vertical orientation is correct
			mo.flags2 = $&~MF2_OBJECTFLIP
		else
	-- 		z = $+t.height
			mo.flags2 = $|MF2_OBJECTFLIP
		end
		P_MoveOrigin(mo,t.x,t.y,t.z)
		P_InstaThrust(mo,R_PointToAngle2(mo.x,mo.y,x,y),min(FRACUNIT*60,R_PointToDist2(mo.x,mo.y,x,y)))
		mo.z = max(mo.floorz,min(mo.ceilingz+mo.height,z)) -- Do z pos while respecting level geometry
	end

	local cvar_pointlimit = CV_FindVar("pointlimit").value
	local cvar_overtime = CV_FindVar("overtime").value
	local cvar_timelimit = CV_FindVar("timelimit").value
	local overtime = ((cvar_overtime) and cvar_timelimit*60-leveltime/TICRATE <= 0)

	

	//Determine toss blink
	local tossblink = 0
	if mo.lasttouched and mo.lasttouched.valid and mo.lasttouched.player and not(mo.target) then
		tossblink = mo.lasttouched.player.tossdelay
	end

	if tossblink then
		
		local floorz = ((mo.flags2 & MF2_OBJECTFLIP) and mo.ceilingz-(FRACUNIT/2)) or mo.floorz+(FRACUNIT/2)

		if not(mo.floorvfx and (type(mo.floorvfx) == "table")) then
			mo.floorvfx = {}
		end

		local color = ((tossblink > (TICRATE/4)) and ({[1]=skincolor_redteam,[2]=skincolor_blueteam})[mo.lasttouched.player.ctfteam]) or SKINCOLOR_GOLD
		local blendmode = ((tossblink > (TICRATE/4)) and AST_TRANSLUCENT) or AST_ADD

		if #mo.floorvfx < 6 then
			table.insert(mo.floorvfx, P_SpawnMobj(mo.x, mo.y, floorz, MT_GHOST_VFX))
			local vfx = mo.floorvfx[#mo.floorvfx]
			if (mo.flags2 & MF2_OBJECTFLIP) then
				vfx.flags2 = $|MF2_OBJECTFLIP
			end
			vfx.fuse = mobjinfo[MT_GHOST].damage/2
			vfx.renderflags = $|RF_FULLBRIGHT|RF_FLOORSPRITE|RF_ABSOLUTEOFFSETS|RF_NOCOLORMAPS
			vfx.spritexoffset = 45*FRACUNIT
			vfx.spriteyoffset = 45*FRACUNIT
			vfx.blendmode = blendmode
			vfx.sprite = SPR_STAB
			vfx.destscale = mo.scale*2
			vfx.frame = 0|FF_TRANS50
			vfx.colorized = true
			vfx.color = color
			vfx.flags2 = $|MF2_SPLAT
		end
		for k, vfx in ipairs(mo.floorvfx) do
			if not(vfx and vfx.valid) then
				table.remove(mo.floorvfx, k)
			else
				vfx.color = color
			end
		end
	else
		if mo.floorvfx and (type(mo.floorvfx) == "table") then
			--print("exists")
			for k, vfx in ipairs(mo.floorvfx) do
				if vfx and vfx.valid then
					--print("deleted")
					P_RemoveMobj(vfx)
				end
				table.remove(mo.floorvfx, k)
				--print("removed")
			end
			mo.floorvfx = nil
		end
	end
end

local chaosRingPreFunc = function(mo)
	-- Press tossflag to toss ruby
	if not(mo.target and mo.target.valid and mo.target.player) then return end
	local player = mo.target.player
	local btns = player.cmd.buttons
	if (btns&BT_TOSSFLAG and not(player.powers[pw_carry] & CR_PLAYER) and not(player.powers[pw_super]) and not(player.tossdelay) and G_GametypeHasTeams())
		if player.gotcrystal then
			S_StartSound(mo, sfx_toss)
			B.PrintGameFeed(player," tossed a "..CHAOSRING_TEXT(mo.chaosring_num)..".")
			player.actioncooldown = TICRATE
			player.gotcrystal = false
			player.gotcrystal_time = 0
			player.tossdelay = TICRATE*2
			free(mo)
			if not (mo and mo.valid) then return end
			mo.target = nil
			mo.captured = nil
			P_MoveOrigin(mo,player.mo.x,player.mo.y,player.mo.z)
			B.ZLaunch(mo,player.mo.scale*6)
			P_InstaThrust(mo,player.mo.angle,player.mo.scale*15)
		end
	end
end

addHook("MobjThinker", chaosRingFunc, MT_BATTLE_CHAOSRING)

CR.PreThinkFrame = function()
	for i = 1, 7 do
		if CR.LiveTable[i] and CR.LiveTable[i].valid then
			chaosRingPreFunc(CR.LiveTable[i])
			continue
		end
	end
end

local function do_delete(mo)
	-- Remove object
	local chaosring = mo
	P_SpawnMobj(chaosring.x,chaosring.y,chaosring.z,MT_SPARK)
	CR.SpawnTable[chaosring.spawnthing.num] = chaosring.spawnthing
	CR.LiveTable[mo.chaosring_num] = {valid=false, respawntimer=CHAOSRING_SPAWNBUFFER}
	print("A "..CHAOSRING_TEXT(mo.chaosring_num).." was lost!")
	S_StartSound(nil, sfx_kc5d)
end

addHook("MobjRemoved", function(mo)
	if mo and mo.valid then
		do_delete(mo)
	end
end, CHAOSRING_TYPE)

CR.ThinkFrame = function()
	CR.GlobalAngle = (($+rotatespd == ANG1*360) and 0) or $+rotatespd
	if (leveltime-(CV_FindVar("hidetime").value*TICRATE) >= CHAOSRING_STARTSPAWNBUFFER) and #CR.LiveTable < 6 then --2 Minutes in?
		if CR.SpawnCountdown <= 0 then 
			B.CTF.GameState.CaptureHUDTimer = 5*TICRATE
			S_StartSound(nil, sfx_kc33)
			if #CR.LiveTable then
				B.CTF.GameState.CaptureHUDName = #CR.LiveTable+1
				spawnChaosRing(P_RandomRange(1, #CR.SpawnTable), #CR.LiveTable+1)
			else
				B.CTF.GameState.CaptureHUDName = 1
				spawnChaosRing(P_RandomRange(1, #CR.SpawnTable), 1)
			end
			CR.SpawnCountdown = CHAOSRING_SPAWNBUFFER
		else
			CR.SpawnCountdown = $-1
		end
	end
	if CR.WinCountdown == 0 then
		B.Arena.ForceWin()
		CR.WinCountdown = -1
	elseif CR.WinCountdown > 0
		for i = 1, 2 do
			local bank = (i==1 and C.RedBank) or C.BlueBank
			if bank and bank.valid and bank.chaosrings == (CHAOSRING1|CHAOSRING2|CHAOSRING3|CHAOSRING4|CHAOSRING5|CHAOSRING6)
				CR.WinCountdown = $-1
				if CR.WinCountdown == 0 then
					addPoints(i, CHAOSRING_WINPOINTS)
				end
			end
		end
	end

	for i = 1, 6 do
		local chaosring = CR.LiveTable[i]

		local remove = false

		if not(chaosring and chaosring.valid) then
			remove = true
		end

		if chaosring and not(chaosring.valid) and type(chaosring) == "table" and (chaosring.respawntimer) then
			remove = false
			chaosring.respawntimer = $-1
			if chaosring.respawntimer <= 0 then
				spawnChaosRing(P_RandomRange(1, #CR.SpawnTable), i, true)
			end
			continue
		end

		if remove then
			continue
		end


		local mo = chaosring
		if mo.chaosring_corona and mo.chaosring_corona.valid then
			mo.chaosring_corona.fuse = max($, 2)
			mo.chaosring_corona.scale = mo.scale
			P_MoveOrigin(mo.chaosring_corona, mo.x, mo.y, mo.z+(P_MobjFlip(mo)*(mo.height/2)))
		else
			mo.chaosring_corona = P_SpawnMobjFromMobj(mo, 0,0,0, MT_INVINCIBLE_LIGHT)
			mo.chaosring_corona.frame = ($ & ~FF_TRANSMASK) | FF_TRANS80
			mo.chaosring_corona.blendmode = AST_ADD
			mo.chaosring_corona.target = mo
			mo.chaosring_corona.scale = mo.scale
			mo.chaosring_corona.spritexscale = FRACUNIT/2
			mo.chaosring_corona.spriteyscale = FRACUNIT/2
			mo.chaosring_corona.spriteyoffset = $+(FRACUNIT*5)
			mo.chaosring_corona.colorized = true
			mo.chaosring_corona.color = mo.color
			mo.chaosring_corona.fuse = 2
		end

		local delete = false

		-- rev: remove ruby if on a "remove ctf flag" sector type
		local sector = mo.subsector.sector
		local ruby_in_goop = mo.eflags&MFE_GOOWATER
		local on_return_sector = P_MobjTouchingSectorSpecialFlag(mo, SSF_RETURNFLAG) -- rev: i don't know if this even works..
		local plr_has_ruby = mo.target and mo.target.valid

		if not plr_has_ruby and (ruby_in_goop or (on_return_sector)) then
			--print("fell into removal sector")
			if (mo.target and mo.target.valid) then
				--B.PrintGameFeed(player, " dropped a "+CHAOSRING_TEXT(chaosring.chaosring_num)+".")
			end
			delete = true
		end

			-- Idle timer
		if chaosring.idle != nil and not(chaosring.captured) then 
			chaosring.idle = $-1
			if chaosring.idle == 0
				if chaosring.ctfteam then
					-- Remove team protection
					chaosring.idle = nil
					chaosring.ctfteam = 0
				else
					delete = true
				end
			end
		end

		if delete then
			P_RemoveMobj(chaosring)
			continue
		end
	end
end

local bankTime = function(player)
	return max(1, 6 - ( FixedSqrt(player.rings * FRACUNIT / 2)>>FRACBITS ) )
end

local robTime = function(player)
	return min(15, FixedSqrt(player.rings * FRACUNIT)>>FRACBITS)
end

local bankTouch = function(mo, pmo)
	return gametype == GT_BANK or nil
end

local baseSparkle = function(player, team)
	local spark
	if team == 1 and C.RedBank and C.RedBank.valid
		spark = P_SpawnMobjFromMobj(C.RedBank, 0, 0, 0, MT_SPARK)
	elseif team == 2 and C.BlueBank and C.BlueBank.valid
		spark = P_SpawnMobjFromMobj(C.BlueBank, 0, 0, 0, MT_SPARK)
	end
	if spark and spark.valid
		spark.momx = P_RandomRange(-2, 2) * spark.scale
		spark.momy = P_RandomRange(-2, 2) * spark.scale
		spark.momz = P_RandomRange(1, 3) * spark.scale
		spark.color = player.ctfteam == 1 and SKINCOLOR_RED or SKINCOLOR_BLUE
		spark.colorized = true
		spark.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT
	end
end

local baseTransaction = function(player, team)
	if player.tossdelay or B.Exiting then
		return true
	end
	-- Get current team score
	local score
	if team == 1
		score = redscore
	else
		score = bluescore
	end
	if player.ctfteam == team
		-- Deposit rings
		if player.rings > 0 and P_IsObjectOnGround(player.mo) and not player.actionstate
			S_StartSound(player.mo, sfx_itemup)
			P_GivePlayerRings(player, -1)
			P_AddPlayerScore(player, 1)
			addPoints(team, 1)
			player.tossdelay = bankTime(player)
			local spark = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BOXSPARKLE)
			if spark and spark.valid
				spark.colorized = true
				spark.color = SKINCOLOR_CARBON
			end
			baseSparkle(player, team)
		end
	else
		-- Steal rings
		if score > 0 and P_IsObjectOnGround(player.mo) and not player.actionstate
			S_StartSound(player.mo, sfx_itemup)
			P_AddPlayerScore(player, 1)
			P_GivePlayerRings(player, 1)
			addPoints(team, -1)
			player.tossdelay = robTime(player)
			P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_SPARK)
			baseSparkle(player, team)
		end
	end
	return true
end

addHook('TouchSpecial', function(mo, pmo)
	return bankTouch(mo, pmo)
end, MT_REDFLAG)

addHook('TouchSpecial', function(mo, pmo)
	return bankTouch(mo, pmo)
end, MT_BLUEFLAG)

local spawnFunc = function(mo, team)
	if not(B.BankGametype()) then
		return
	end
	if team == 1
		C.RedBank = mo
		C.RedBank.chaosrings = 0
		C.RedBank.chaosrings_table = {}
	else
		C.BlueBank = mo
		C.BlueBank.chaosrings = 0
		C.BlueBank.chaosrings_table = {}
	end
	mo.state = S_TEAMRING
	mo.scale = $<<1
	mo.flags = $|MF_NOGRAVITY
	mo.renderflags = $|RF_SEMIBRIGHT
end

addHook('MobjSpawn', function(mo)
	spawnFunc(mo, 1)
end, MT_REDFLAG)

addHook('MobjSpawn', function(mo)
	spawnFunc(mo, 2)
end, MT_BLUEFLAG)

local flashColor = function(colormin,colormax, rate)
	local N = rate or 32 //Rate of oscillation
-- 	local size = colormax-colormin+1 //Color spectrum
	local scale = 2 //Factor-amount to reduce the oscillation intensity
	local offset = 0 //Offset the origin of oscillation
	local oscillate = abs((leveltime&(N*2-1))-N)/scale //Oscillation cycle
	local c = colormin+oscillate+offset //offset
	c = max(colormin,min(colormax,$)) //Enforce min/max
	return c
end

local getBase = function(player)
	if not P_IsObjectOnGround(player.mo) then return end

	--// rev: credits to JAB, he figured this one out. This will work for both UDMF / Binary maps
	if P_MobjTouchingSectorSpecialFlag(player.mo, SSF_REDTEAMBASE) then
		return 1
	elseif P_MobjTouchingSectorSpecialFlag(player.mo, SSF_BLUETEAMBASE) then
		return 2
	else
		return 0
	end
end

local highValueSparkle = function(player)
	if leveltime % 2
		local w = player.mo.radius>>FRACBITS
		local h = player.mo.height>>FRACBITS
		local x = P_RandomRange(-w, w) * FRACUNIT
		local y = P_RandomRange(-w, w) * FRACUNIT
		local z = P_RandomRange(0, h) * FRACUNIT
-- 		local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_BOXSPARKLE)
		local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_BOXSPARKLE)
		if fx and fx.valid
			fx.scale = $>>1
			fx.fuse = P_RandomRange(10, 65)
			local spd = FixedMul(fx.scale, P_RandomRange(0, FRACUNIT-1))
			local angle = FixedAngle(P_RandomRange(0, 259)*FRACUNIT)
			P_Thrust(fx, angle, spd)
			P_SetObjectMomZ(fx, P_RandomRange(0, FRACUNIT-1), true)
-- 			if P_RandomChance(FRACUNIT>>2)
				fx.colorized = true
				fx.color = SKINCOLOR_GOLD
-- 			end
			if player == displayplayer
				fx.flags2 = $|MF2_SHADOW|FF_ADD
			end
		end
	end
end

local addHudSparkle = function(team, direction)
	local w = 22
	local h = 14
	local x, y = 130 + P_RandomRange(0,w), 6
	local momy = 1
	if team == 1
		x = $ + 40
	end
	if direction == 1
		momy = -$
		y = $+h
	end
	table.insert(hudobjs, {
		drawtype = "sprite",
		string = "NSPK",
		frame = 1,
		flags = V_SNAPTOTOP|V_PERPLAYER,
		x = FRACUNIT * x,
		y = FRACUNIT * y,
		momy = momy * FRACUNIT,
		friction = FRACUNIT * 15 / 16,
		scale = FRACUNIT >> 2,
		fuse = 28
	})
end

local capture = function(mo, team, bank)
	local captime = CHAOSRING_CAPTIME
	local friendly = (splitscreen or (consoleplayer and consoleplayer.ctfteam == team))
	local sfx = friendly and SLOWCAPPINGALLY_SFX or SLOWCAPPINGENEMY_SFX
	mo.player.gotcrystal_time = ($~=nil and $+1) or 1
	mo.chaosring.chaosring_capturing = true
	if mo.player.gotcrystal_time % 35 == 11 then
		S_StartSoundAtVolume(nil, sfx, 160)
	elseif mo.player.gotcrystal_time % 35 == 22 then
		S_StartSoundAtVolume(nil, sfx, 90)
	elseif mo.player.gotcrystal_time % 35 == 33 then
		S_StartSoundAtVolume(nil, sfx, 20)
	end
	if mo.player.gotcrystal_time > captime then
		S_StartSound(nil, (friendly and sfx_kc5c) or sfx_kc46)
		mo.player.gotcrystal = false
		mo.player.gotcrystal_time = 0
		captureChaosRing(mo.chaosring, bank)
		table.insert(bank.chaosrings_table, mo.chaosring.chaosring_num)
		mo.chaosring.chaosring_bankkey = #bank.chaosrings_table
		mo.chaosring.target = bank
		return true
	end
end


C.ThinkFrame = function()

	if not(B.BankGametype()) then return end
	local rs = redscore
	local bs = bluescore
	local blueInBlue = 0
	local blueInRed = 0
	local redInBlue = 0
	local redInRed = 0
	
	-- Get player-to-base statuses
	for player in players.iterate do
		if player.mo and player.rings >= 100
			highValueSparkle(player)
		end
		if player.mo and player.mo.health and not player.powers[pw_flashing]
			local base = getBase(player)
			if base == 1 -- Red base
				if player.ctfteam == 1
					redInRed = $+1
				else
					blueInRed = $+1
				end
			elseif base == 2 -- Blue base
				if player.ctfteam == 1
					redInBlue = $+1
				else
					blueInBlue = $+1
				end
			end
		end
	end

	-- Do player in base transactions
	for player in players.iterate do
		if player.mo and player.mo.health and not player.powers[pw_flashing]
			local base = getBase(player)
			if base == 1 -- Red base
				if player.gotcrystal and player.ctfteam == base then
					capture(player.mo, player.ctfteam, C.RedBank)
					continue
				end
				if blueInRed
					if blueInRed > redInBlue then
						if player.ctfteam == 2 then
							playerSteal(player.mo, C.RedBank)
						end
					end
					continue
				end
			elseif base == 2 -- Blue base
				if player.gotcrystal and player.ctfteam == base then
					capture(player.mo, player.ctfteam, C.BlueBank)
					continue
				end
				if redInBlue
					if redInBlue > blueInRed
						if player.ctfteam == 1
							playerSteal(player.mo, C.BlueBank)
						end
					end
					continue
				end
			end
			if base != 0
				baseTransaction(player, base)
			end
			if not(base) then
				if player.mo.stealing then
					player.mo.stealing = nil
					player.gotcrystal_time = 0
				end
				if player.mo.chaosring and player.mo.chaosring.valid and player.mo.chaosring.capturing then
					player.mo.chaosring.capturing = nil
					player.gotcrystal_time = 0
				end
			end
		end
		if C.RedBank and C.RedBank.valid
			-- Color
			if redInRed and blueInRed
				C.RedBank.color = flashColor(SKINCOLOR_TANGERINE, SKINCOLOR_TOPAZ, 8)
			elseif redInRed
				C.RedBank.color = flashColor(SKINCOLOR_SUPERRED1, SKINCOLOR_SUPERRED5, 16)
			elseif blueInRed
				C.RedBank.color = flashColor(SKINCOLOR_SUNSET, SKINCOLOR_FOUNDATION, 16)
			else
				C.RedBank.color = SKINCOLOR_CRIMSON
			end
			-- Transparency
			C.RedBank.frame = $ | FF_TRANS30
			-- Motion
			C.RedBank.z = C.RedBank.floorz + C.RedBank.scale * 16 + FixedMul(sin(leveltime * ANG10), C.RedBank.scale * 8)
			-- HUD sparkle
			if rs < redscore
				addHudSparkle(1, 1)
			elseif rs > redscore
				addHudSparkle(1, 0)
			end
		end
		if C.BlueBank and C.BlueBank.valid
			-- Color
			if redInBlue and blueInBlue
				C.BlueBank.color = flashColor(SKINCOLOR_NOBLE, SKINCOLOR_PASTEL, 8)
			elseif redInBlue
				C.BlueBank.color = flashColor(SKINCOLOR_MIDNIGHT, SKINCOLOR_VIOLET, 16)
			elseif blueInBlue
				C.BlueBank.color = flashColor(SKINCOLOR_ICY, SKINCOLOR_ARCTIC, 16)
			else
				C.BlueBank.color = SKINCOLOR_COBALT
			end
			-- Transparency
			C.BlueBank.frame = $ | FF_TRANS30
			-- Motion
			C.BlueBank.z = C.BlueBank.floorz + C.BlueBank.scale * 16 + FixedMul(sin(leveltime * ANG10), C.BlueBank.scale * 8)
			-- HUD sparkle
			if bs < bluescore
				addHudSparkle(0, 1)
			elseif bs > bluescore
				addHudSparkle(0, 0)
			end
		end
	end	
	CR.ThinkFrame() --Chaos Rings
end