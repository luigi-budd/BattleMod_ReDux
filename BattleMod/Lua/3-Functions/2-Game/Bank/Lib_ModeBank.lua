local B = CBW_Battle
local C = B.Bank
C.RedBank = nil
C.BlueBank = nil
C.ChaosRing = {}
C.BANK_RINGLIMIT = 50
local CR = C.ChaosRing

--Constants
local BANK_RINGLIMIT = C.BANK_RINGLIMIT

local cv_startspawnbuffer = CV_RegisterVar({
    name = "chaosring_startspawnbuffer",
    defaultvalue = 25,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
        print("Chaos Rings will start spawning in Ring Rally after "..cv.value.." seconds.")
    end
})

local cv_spawnbuffer = CV_RegisterVar({
    name = "chaosring_spawnbuffer",
    defaultvalue = 10,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
        print("Chaos Rings will spawn in Ring Rally every "..cv.value.." seconds.")
    end
})

local cv_wintime = CV_RegisterVar({
    name = "chaosring_wintime",
    defaultvalue = 3,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Collecting all 6 Chaos Rings will result in victory after "..cv.value.." seconds.")
		end
    end
})

local cv_capturetime = CV_RegisterVar({
    name = "chaosring_capturetime",
    defaultvalue = 2,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will now take "..cv.value.." seconds to capture.")
		end
    end
})

local cv_stealtime = CV_RegisterVar({
    name = "chaosring_stealtime",
    defaultvalue = 3,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will now take "..cv.value.." seconds to steal.")
		end
    end
})

local cv_invulntime = CV_RegisterVar({
    name = "chaosring_invulntime",
    defaultvalue = 15,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will be protected from theft for "..cv.value.." seconds after capture.")
		end
    end
})

local cv_capturescore = CV_RegisterVar({
    name = "chaosring_capturescore",
    defaultvalue = 50,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Capturing a Chaos Ring will award your team "..cv.value.." points.")
		end
    end
})

local CHAOSRING_WINPOINTS = 9999

local CHAOSRING_SCALE = FRACUNIT+(FRACUNIT/2) --Scale of Chaos Rings
local CHAOSRING_TYPE = MT_BATTLE_CHAOSRING --Object Type

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
local bounceheight = 10
local rotatespd = ANG1*8

local SLOWCAPPINGALLY_SFX  = sfx_kc5a
local SLOWCAPPINGENEMY_SFX = sfx_kc59

local CHAOSRING_RADAR = freeslot("sfx_crng2")
sfxinfo[CHAOSRING_RADAR].caption = "/"

local freetics = TICRATE*2


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
		textmap = "\x8E"
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

local CHAOSRING_TEXT = function(num, donum)
	if donum then
		return CR.Data[num].textmap.."Chaos Ring "..num.."\x80"
	else
		return CR.Data[num].textmap.."Chaos Ring".."\x80"
	end
end

local chaosring_debug = CV_RegisterVar({
    name = "chaosring_debug",
    defaultvalue = "Off",
    value = 0,
    flags = CV_NETVAR,
    PossibleValue = CV_OnOff
})

local chprint = function(string)
	if not(chaosring_debug.value) then return end
	print("\x82".."chprint:".."\x80".." "..string)
end

CR.VarsExist = function()
	return server and (server.SpawnCountDown~=nil and 
	server.GlobalAngle~=nil and 
	server.InitSpawnWait~=nil and
	server.SpawnTable~=nil and
	server.WinCountdown~=nil and
	server.AvailableChaosRings~=nil)
end

CR.GetChaosRing = function(num)
	for k, v in ipairs(server.AvailableChaosRings) do
		if not(v) then continue end
		if v.chaosring_num == num then
			return v
		end
	end
end
CR.GetChaosRingKey = function(num)
	for k, v in ipairs(server.AvailableChaosRings) do
		if not(v) then continue end
		if not(v.valid) and type(v)!="table" then continue end
		if v.chaosring_num == num then
			return k
		end
	end
end

local resetVars = function()
	server.SpawnTable = {} --Clear the table
	server.WinCountdown = cv_wintime.value*TICRATE
	server.SpawnCountDown = 0
	server.AvailableChaosRings = {}
	server.GlobalAngle = ANG20
	server.InitSpawnWait = cv_startspawnbuffer.value*TICRATE
end

local addPoints = function(team, points)
	if team == 1
		redscore = $ + points
	else
		bluescore = $ + points
	end
end

local insertSpawnPoint = function(mt)
	table.insert(server.SpawnTable, { --Data for the spawn
		x = mt.x*FRACUNIT,
		y = mt.y*FRACUNIT,
		z = mt.z*FRACUNIT,
		options = mt.options,
		scale = mt.scale,
		mo = nil --Will use this field later
	})
end

local function spawnChaosRing(num, chaosringnum, re) --Spawn a Chaos Ring
	if not(server.SpawnTable[num]) then --If we're trying to access a non-existant spawnpoint, don't
		return
	end

	if server.SpawnTable[num].mo and server.SpawnTable[num].mo.valid then --Only if it doesn't already have an object
		return
	end
	local thing = server.SpawnTable[num]
	local data = CR.Data[chaosringnum]

	local flip = ((thing.options&MTF_OBJECTFLIP) and -1) or 1
	local float = ((thing.options&MTF_OBJECTFLIP) and 1) or 0
	--local z = ((thing.options & MTF_AMBUSH) and (thing.z+(24*FRACUNIT))) or thing.z
	local z = thing.z+(24*FRACUNIT)

	thing.mo = P_SpawnMobj(thing.x, thing.y, z, CHAOSRING_TYPE)
	if flip == -1 then
		thing.mo.flags2 = $|MF2_OBJECTFLIP
	end

	thing.mo.scale = FixedMul(thing.scale, CHAOSRING_SCALE) --Chaos Rings are large
	thing.mo.color = data.color --Color according to number
	thing.mo.chaosring_num = chaosringnum --Store number
	thing.mo.idealz = thing.mo.z --Store original Z position
	thing.mo.idealscale = FixedMul(thing.scale, CHAOSRING_SCALE) --Store ideal scale
	thing.num = num --Store spawnpoint number
	thing.mo.chaosring_thingspawn = thing --Store the MapThing table
	thing.mo.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS --Shiny
	table.remove(server.SpawnTable, num) --Don't try to spawn here again
	print("A "..CHAOSRING_TEXT(chaosringnum).." has "..((re and "re") or "").."spawned!")
	if re then
		S_StartSound(nil, sfx_cdfm44)
	end
	thing.mo.radius = 16*FRACUNIT
	return thing.mo
end

local function free(mo)
	if not (mo and mo.valid) then return end
	mo.fuse = (mo.captured and cv_invulntime.value*TICRATE) or freetics
	mo.flags = ($|MF_GRENADEBOUNCE) & ~(MF_SPECIAL)
	mo.idle = idletics
end

local function touchChaosRing(mo, toucher, playercansteal) --Going to copy Ruby/Topaz code here


	if not(mo and mo.valid and toucher and toucher.valid) then
		return
	end

	local teamGT = G_GametypeHasTeams()

	--Chaos Ring
	local capturedChaosRing = (mo.captured)

	--Toucher
	local toucherIsTarget = (mo.target == toucher)

	--Toucher Player
	local toucherIsPlayer = (toucher.player)

	local toucherIsPlayerInPain = (toucherIsPlayer and P_PlayerInPain(toucher.player))
	local toucherIsFlashing 	= (toucherIsPlayer and toucher.player.powers[pw_flashing])
	local toucherTossdelay 		= (toucherIsPlayer and toucher.player.tossdelay)
	local toucherCTFTeam 		= (toucherIsPlayer and toucher.player.ctfteam)
	local toucherHasCrystal 	= (toucherIsPlayer and toucher.player.gotcrystal)
	local toucherIsParrying     = (toucherIsPlayer and toucher.player.guard)
	local toucherIsAirDodging   = (toucherIsPlayer and toucher.player.airdodge > 0)

	--Previous Target
	local previousTarget = (mo.target and mo.target.valid) --Old Target

	local previousTargetIsPlayer = (previousTarget and mo.target and mo.target.player)
	local previousTargetCTFTeam = (previousTargetIsPlayer and mo.target.player.ctfteam)
	

	--Combinations
	local sameTeam = ((toucherCTFTeam == previousTargetCTFTeam) or (toucherCTFTeam == mo.captureteam)) and mo.target.player.cmd.buttons & BT_TOSSFLAG

	if (toucher ~= C.RedBank) and (toucher ~= C.BlueBank) and not(toucher.player) then
		return true
	end

	if previousTarget and not(playercansteal or sameTeam) then
		return true
	end

	if toucherIsPlayer and 
	(toucherIsTarget 
	or toucherIsPlayerInPain
	--or (toucherIsAirDodging and not(mo.captured))
	--or (toucherIsParrying   and not(mo.captured))
	or toucherTossdelay 
	or toucherHasCrystal) then
		return true
	end

	if toucherIsFlashing and not(mo.captured) then
		toucher.player.powers[pw_flashing] = max($,2)
		return true
	end


	if previousTarget then
		if previousTargetIsPlayer then --Last target was a Chaos Ring holder?
			if mo.target.btagpointer and mo.target.btagpointer.valid then
				if not(mo.target.player.gotmaxrings) then
					P_RemoveMobj(mo.target.btagpointer)
				end
			end
			mo.target.player.gotcrystal = false --Not Anymore
			mo.target.chaosring = nil --Disconnect Chaos Ring from player object
		else
			server.WinCountdown = cv_wintime.value*TICRATE --Reset the Win Countdown
		end
		mo.lasttouched = mo.target --Set lasttouched to them
	else
		mo.lasttouched = toucher --Set lasttouched to us
	end

	if capturedChaosRing then --Already at a base?
		mo.captured = nil --Not anymore
		mo.bank.chaosrings = $ & ~CHAOSRING_ENUM[mo.chaosring_num] --Remove it from the bank
		mo.bank = nil --Disconnect from bank
		mo.captureteam = 0 --The object's team is only applied upon capture
	end

	mo.beingstolen = nil
	toucher.chaosring = mo --Set the player object's Chaos Ring to this object
	mo.target = toucher --Set the Chaos Ring's target to us
	free(mo) --Set collection cooldown
	mo.scale = mo.idealscale --Store player's scale in object

	P_SetObjectMomZ(toucher, toucher.momz/2)

	local shouldHearSFX = (splitscreen or (displayplayer and toucher.player == displayplayer)) or (displayplayer and previoustarget and previoustarget.player and previoustarget.player == displayplayer)
	if toucherIsPlayer then
		toucher.player.gotcrystal = true --We have a McGuffin
		S_StartSound(mo,sfx_lvpass)
		if displayplayer and shouldHearSFX then 
			S_StartSound(nil, sfx_kc5e)
		end
		toucher.spritexscale = toucher.scale 
		toucher.spriteyscale = toucher.scale
		if not(toucher.btagpointer and toucher.btagpointer.valid) then
			toucher.btagpointer = P_SpawnMobjFromMobj(toucher, 0, 0, 0, MT_BTAG_POINTER)
		end
		if toucher.btagpointer and toucher.btagpointer.valid
			toucher.btagpointer.tracer = toucher
			toucher.btagpointer.target = ({C.RedBank, C.BlueBank})[toucher.player.ctfteam]
		end
	end

	if toucher.player then
		if not(previoustarget) then
			B.PrintGameFeed(toucher.player," picked up a "..CHAOSRING_TEXT(mo.chaosring_num).."!")
		elseif previoustarget.player
			B.PrintGameFeed(toucher.player," stole a "..CHAOSRING_TEXT(mo.chaosring_num).." from ",previousTarget.player,"!")
		end
	end

	return true
end

local function captureChaosRing(mo, bank) --Capture a Chaos Ring into a Bank
	mo.flags = $ & ~MF_SPECIAL --Can't be touched
	bank.chaosrings = $|(CHAOSRING_ENUM[mo.chaosring_num]) --Add to Bank count
	mo.bank = bank --Set its Bank to the new Bank
	addPoints(mo.target.player.ctfteam, cv_capturescore.value) --Reward points to the team
	mo.fuse = cv_invulntime.value*TICRATE --Set the steal cooldown
	mo.scale = (mo.idealscale - (mo.idealscale/3)) --Shrink it
	mo.captureteam = mo.target.player.ctfteam --Set the team it's captured in
	touchChaosRing(mo, bank, true)
	mo.captured = true --Yes it has been captured
	mo.beingstolen = nil
end

local function playerSteal(mo, bank) --Steal a Chaos Ring by staying on their base
	if mo.player.gotcrystal then chprint("Can't steal, has gotcrystal") return end --Chaos Ringholders cannot steal
	if #bank.chaosrings_table then --If the bank has Chaos Ring Objects
		if not(mo.chaosring_tosteal) then --If you aren't already stealing a Chaos Ring
			local available_rings = {}

			for k, v in ipairs(bank.chaosrings_table) do --Gather the stealable rings
				if not (v and v.valid and v.captured and not(v.fuse) and not(v.beingstolen)) then
					chprint("Can't steal "..((v and v.valid and v.chaosring_num and CHAOSRING_TEXT((v and v.valid and v.chaosring_num), true)) or "nil").."\n"..
						  "valid = "..(tostring(v and v.valid) or "nil").."\n"..
						  "captured = "..(tostring(v and v.valid and v.captured) or "nil").."\n"..
						  "fuse = "..(tostring(v and v.valid and v.fuse) or "nil").."\n"..
						  "beingstolen = "..(tostring(v and v.valid and v.beingstolen) or "nil"))
					continue
				end
				table.insert(available_rings, v)
			end

			if not(#available_rings) then chprint("Could not get an available ring to steal.") return end --If there are none, we can't steal

			local pickme = available_rings[P_RandomRange(1, #available_rings)] --Steal a random ring
			pickme.beingstolen = mo --It's being stolen
			mo.chaosring_tosteal = pickme --We're stealing it
		else --Now that we're stealing
			mo.chaosring_stealing = true --Var to mark down that we were stealing
			mo.player.gotcrystal_time = ($~=nil and $+1) or 1 --Add to crystal time
			chprint("Stealing! gotcrystal_time = "..mo.player.gotcrystal_time)
			--Play Staggered SFX
			local sfx = sfx_kc59
			if mo.player.gotcrystal_time % 35 == 11 then
				S_StartSoundAtVolume(mo, sfx, 160)
			elseif mo.player.gotcrystal_time % 35 == 22 then
				S_StartSoundAtVolume(mo, sfx, 90)
			elseif mo.player.gotcrystal_time % 35 == 33 then
				S_StartSoundAtVolume(mo, sfx, 20)
			end
		end
	else
		chprint((((bank == C.RedBank) and "\x85".."Red") or "\x84".."Blue").." Bank".."\x80".." doesn't have enough chaos rings to steal")
	end

	if mo.player.gotcrystal_time~=nil and (mo.player.gotcrystal_time >= cv_stealtime.value*TICRATE) then --If we've been standing long enough
		if mo.chaosring_tosteal and mo.chaosring_tosteal.valid then --And the object exists
			touchChaosRing(mo.chaosring_tosteal, mo, true) --Steal it!
			mo.player.gotcrystal_time = 0 --Not counting anymore
			mo.chaosring_tosteal.chaosring_bankkey = nil --Take away key
			local sorted_rings = {}
			for k, v in ipairs(bank.chaosrings_table) do
				if (v ~= mo.chaosring_tosteal) then
					table.insert(sorted_rings, v)
				end
			end
			for k,v in ipairs(sorted_rings) do
				if v and v.valid then
					v.chaosring_bankkey = k
				end
			end
			bank.chaosrings_table = sorted_rings
			mo.chaosring_tosteal.beingstolen = nil --Chaos ring isn't being stolen
			mo.chaosring_tosteal = nil --We're not stealing the Chaos Ring
			return true
		end
	end
end


local chaosRingFunc = function(mo) --Object Thinker (Mostly taken from Ruby)

	mo.shadowscale = FRACUNIT>>1

	if mo.beingstolen and (
		not(mo.beingstolen.valid) or 
		not(mo.beingstolen.player) or 
		(mo.beingstolen.player.playerstate ~= PST_LIVE) or 
		(mo.captureteam and not(P_MobjTouchingSectorSpecialFlag(mo.beingstolen, (mo.captureteam==1 and SSF_REDTEAMBASE) or SSF_BLUETEAMBASE) and P_IsObjectOnGround(mo.beingstolen)))
	) then
		mo.beingstolen = nil
	end
	
	-- Blink
	if mo.fuse&1
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $&~MF2_DONTDRAW
	end

	--Set internal angle
	mo.angle = $+rotatespd
	
	-- Owner has been pushed by another player
	if mo.flags&MF_SPECIAL and mo.target and mo.target.valid 
	and mo.target.pushed_last and mo.target.pushed_last.valid
		touchChaosRing(mo,mo.target.pushed_last, true)
	end
	
	-- Owner has taken damage or has gone missing
	local targetIsPlayer = (mo.target and mo.target.player)
	local targetIsValid = (mo.target and mo.target.valid)
	local targetIsPlayerInPain = (targetIsPlayer and P_PlayerInPain(mo.target.player))
	local targetIsDeadPlayer = (targetIsPlayer and mo.target.player.playerstate != PST_LIVE)
	if targetIsPlayer and (
		not(targetIsValid)   or
		targetIsPlayerInPain or
		targetIsDeadPlayer
	) then
		if targetIsValid then
			B.PrintGameFeed(mo.target.player," dropped a "..CHAOSRING_TEXT(mo.chaosring_num)..".")
		end

		mo.beingstolen = nil
		mo.captured = nil
		mo.target.chaosring_stealing = nil
		mo.target.chaosring_capturing = nil
		mo.target.chaosring_tosteal = nil

		mo.target.player.gotcrystal = false
		mo.target.player.gotcrystal_time = 0
		mo.target = nil

		B.ZLaunch(mo,FRACUNIT*bounceheight/2,true)
		P_InstaThrust(mo,mo.angle,FRACUNIT*5)
		free(mo)
		S_StartSound(mo.target, sfx_cdfm67)
	end
	
	if mo.target and mo.target.valid then --Claimed?

		if not(leveltime%8) then
			local spark = P_SpawnMobjFromMobj(mo,0,0,0,MT_SUPERSPARK)
			spark.scale = mo.scale
			spark.colorized = true
			spark.color = mo.color
			spark.spriteyoffset = $-(FRACUNIT*6)
		end

		mo.flags = ($&~MF_BOUNCE)|MF_NOGRAVITY|MF_SLIDEME
		local t = mo.target
		local ang = (mo.captured and (ANG1*60*mo.chaosring_num)+server.GlobalAngle) or mo.angle
		local dist = mo.target.radius*3
		local x = t.x+P_ReturnThrustX(mo,ang,dist)
		local y = t.y+P_ReturnThrustY(mo,ang,dist)
		local z = t.z+abs(leveltime&63-31)*FRACUNIT/2 -- Gives us a hovering effect
		local floorz = mo.floorz
		local ceilingz = mo.ceilingz
		if P_MobjFlip(t) == 1 -- Make sure our vertical orientation is correct
			mo.flags2 = $&~MF2_OBJECTFLIP
			mo.eflags = $&~MFE_VERTICALFLIP
		else
			--floorz = mo.ceilingz
			--ceilingz = mo.floorz
			--z = ((t.z-(t.height))+mo.height)+abs(leveltime&63-31)*FRACUNIT/2
			mo.flags2 = $|MF2_OBJECTFLIP
			mo.eflags = $|MFE_VERTICALFLIP
		end
		P_MoveOrigin(mo,t.x,t.y,t.z)
		P_InstaThrust(mo,R_PointToAngle2(mo.x,mo.y,x,y),min(FRACUNIT*60,R_PointToDist2(mo.x,mo.y,x,y)))
		mo.z = max(floorz,min(ceilingz+mo.height,z)) -- Do z pos while respecting level geometry
	else --Loose?
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
	end

	

	--Start Floor VFX
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
			--chprint("exists")
			for k, vfx in ipairs(mo.floorvfx) do
				if vfx and vfx.valid then
					--chprint("deleted")
					P_RemoveMobj(vfx)
				end
				table.remove(mo.floorvfx, k)
				--chprint("removed")
			end
			mo.floorvfx = nil
		end
	end
	--End Floor VFX
end

local function deleteChaosRing(chaosring) --Special Behavior upon Removal
	if chaosring and chaosring.valid and chaosring.chaosring_num and CR.GetChaosRingKey(chaosring.chaosring_num) then
		local spark = P_SpawnMobjFromMobj(chaosring, 0,0,0,MT_SPARK)
		spark.colorized = true
		spark.color = chaosring.color

		--Re-Insert Spawnpoint
		server.SpawnTable[chaosring.chaosring_thingspawn.num] = chaosring.chaosring_thingspawn

		--Set to Respawning in LiveTable
		server.AvailableChaosRings[CR.GetChaosRingKey(chaosring.chaosring_num)] = {chaosring_num=chaosring.chaosring_num, valid=false, respawntimer=cv_spawnbuffer.value*TICRATE}

		print("A "..CHAOSRING_TEXT(chaosring.chaosring_num).." was lost!")
		S_StartSound(nil, sfx_kc5d)
	end
end

CR.ThinkFrame = function() --Main Thinker
	if not(CR.VarsExist()) then return end

	server.GlobalAngle = (($+rotatespd == ANG1*360) and 0) or $+rotatespd --Constantly rotating

	local roundTime = leveltime-(CV_FindVar("hidetime").value*TICRATE)
	local startupChaosRings = roundTime >= cv_startspawnbuffer.value*TICRATE

	local allChaosRings = (#server.AvailableChaosRings >= 6)

	if startupChaosRings and not(allChaosRings)  then --2 Minutes in?

		if server.SpawnCountDown <= 0 then --Counted down?
			B.CTF.GameState.CaptureHUDTimer = 5*TICRATE
			S_StartSound(nil, sfx_kc33)
			if #server.AvailableChaosRings then --Chaos Rings exist?
				--Spawn the next one
				B.CTF.GameState.CaptureHUDName = #server.AvailableChaosRings+1
				table.insert(server.AvailableChaosRings, spawnChaosRing(P_RandomRange(1, #server.SpawnTable), #server.AvailableChaosRings+1))
			else
				--Spawn the first one
				B.CTF.GameState.CaptureHUDName = 1
				table.insert(server.AvailableChaosRings, spawnChaosRing(P_RandomRange(1, #server.SpawnTable), 1))
			end
			--Set our countdown
			server.SpawnCountDown = cv_spawnbuffer.value*TICRATE
		else
			--Start counting down
			server.SpawnCountDown = $-1
		end
	end


	--Win Condition
	if server.WinCountdown == 0 then --Ready to win?
		--Win
		B.Arena.ForceWin()
		server.WinCountdown = -1
	elseif server.WinCountdown > 0
		for i = 1, 2 do
			local bank = (i==1 and C.RedBank) or C.BlueBank
			if bank and bank.valid and bank.chaosrings == (CHAOSRING1|CHAOSRING2|CHAOSRING3|CHAOSRING4|CHAOSRING5|CHAOSRING6)
				server.WinCountdown = $-1
				if server.WinCountdown == 0 then
					addPoints(i, CHAOSRING_WINPOINTS)
				end
			end
		end
	end

	--Main Thinker for ALL Chaos Rings
	for i = 1, #server.AvailableChaosRings do
		local chaosring = server.AvailableChaosRings[i]

		local remove = false

		if not(chaosring and chaosring.valid) then
			remove = true
		end

		if chaosring and not(chaosring.valid) and type(chaosring) == "table" and (chaosring.respawntimer) then
			remove = false
			chaosring.respawntimer = $-1
			if chaosring.respawntimer <= 0 then
				server.AvailableChaosRings[i] = spawnChaosRing(P_RandomRange(1, #server.SpawnTable), i, true)
			end
			continue
		end

		if remove then
			continue
		end

		local delete = false

		local mo = chaosring

		-- rev: remove ruby if on a "remove ctf flag" sector type
		local sector = mo.subsector.sector
		local ruby_in_goop = mo.eflags&MFE_GOOWATER
		local on_return_sector = P_MobjTouchingSectorSpecialFlag(mo, SSF_RETURNFLAG) -- rev: i don't know if this even works..
		local plr_has_ruby = mo.target and mo.target.valid

		if not plr_has_ruby and (ruby_in_goop or (on_return_sector)) then
			--chprint("fell into removal sector")
			if (mo.target and mo.target.valid) then
				--B.PrintGameFeed(player, " dropped a "+CHAOSRING_TEXT(chaosring.chaosring_num)+".")
			end
			delete = true
		end

			-- Idle timer
		if chaosring.idle != nil and not(chaosring.captured) and not(chaosring.target and chaosring.target.valid and chaosring.target.player) then 
			chaosring.idle = $-1
			if chaosring.idle == 0
				if chaosring.captureteam then
					-- Remove team protection
					chaosring.idle = nil
					chaosring.captureteam = 0
					chaosring.beingstolen = nil
				else
					delete = true
				end
			end
		end

		if delete and not(chaosring.target and chaosring.target.valid) then
			P_RemoveMobj(chaosring)
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
			mo.chaosring_corona.renderflags = $|RF_NOCOLORMAPS|RF_FULLBRIGHT
			mo.chaosring_corona.blendmode = AST_ADD
			mo.chaosring_corona.target = mo
			mo.chaosring_corona.scale = mo.scale
			mo.chaosring_corona.spritexscale = FRACUNIT/2
			mo.chaosring_corona.spriteyscale = FRACUNIT/2
			mo.chaosring_corona.spriteyoffset = mo.spriteyoffset
			mo.chaosring_corona.colorized = true
			mo.chaosring_corona.color = mo.color
			mo.chaosring_corona.fuse = 2
		end

		B.MacGuffinPass(mo)
	end
end
--End of most Chaos Ring Stuff

--Bank!
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

local baseTransaction = function(player, team, animation)
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
		if player.rings > 0 and not player.actionstate
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
		if score > 0 and not player.actionstate
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
		mo.chaosrings = 0
		mo.chaosrings_table = {}
		C.RedBank = mo
	else
		mo.chaosrings = 0
		mo.chaosrings_table = {}
		C.BlueBank = mo
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
	if leveltime % 2 then return end

	local w = player.mo.radius>>FRACBITS
	local h = player.mo.height>>FRACBITS
	local x = P_RandomRange(-w, w) * FRACUNIT
	local y = P_RandomRange(-w, w) * FRACUNIT
	local z = P_RandomRange(0, h) * FRACUNIT
-- 	local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_BOXSPARKLE)
	local fx = P_SpawnMobjFromMobj(player.mo, x, y, z, MT_BOXSPARKLE)
	if not (fx and fx.valid) then
		return
	end

	fx.scale = $>>1
	fx.fuse = P_RandomRange(10, 65)
	local spd = FixedMul(fx.scale, P_RandomRange(0, FRACUNIT-1))
	local angle = FixedAngle(P_RandomRange(0, 259)*FRACUNIT)
	P_Thrust(fx, angle, spd)
	P_SetObjectMomZ(fx, P_RandomRange(0, FRACUNIT-1), true)
	fx.colorized = true
	fx.color = SKINCOLOR_GOLD
	if player == displayplayer then
		fx.flags2 = $|MF2_SHADOW|FF_ADD
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
	local captime = cv_capturetime.value*TICRATE
	local friendly = (splitscreen or (consoleplayer and consoleplayer.ctfteam == team))
	local sfx = friendly and SLOWCAPPINGALLY_SFX or SLOWCAPPINGENEMY_SFX
	mo.player.gotcrystal_time = ($~=nil and $+1) or 1
	mo.chaosring_capturing = true
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
		table.insert(bank.chaosrings_table, mo.chaosring)
		mo.chaosring.chaosring_bankkey = #bank.chaosrings_table
		captureChaosRing(mo.chaosring, bank)
		return true
	end
end


C.ThinkFrame = function()

	if not(B.BankGametype()) then return end
	if not(CR.VarsExist()) then return end
	local rs = redscore
	local bs = bluescore
	local blueInBlue = 0
	local blueInRed = 0
	local redInBlue = 0
	local redInRed = 0
	
	-- Get player-to-base statuses
	for player in players.iterate do

		if player.rings >= BANK_RINGLIMIT then
			if not(player.gotmaxrings) then
				player.gotmaxrings = true
			end
		else
			if player.gotmaxrings then
				player.gotmaxrings = false
			end
		end

		player.rings = min($, BANK_RINGLIMIT)

		if player.mo and player.mo.valid then
			if player.gotmaxrings then
				if not(player.mo.btagpointer and player.mo.btagpointer.valid) then
					player.mo.btagpointer = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BTAG_POINTER)
				end
				if player.mo.btagpointer and player.mo.btagpointer.valid then
					player.mo.btagpointer.tracer = player.mo
					player.mo.btagpointer.target = ({C.RedBank, C.BlueBank})[player.ctfteam]
				end
			end

			if player.bank_depositing and player.bank_depositing.valid then
				if player.rings > 0 then
					player.mo.momx = 0
					player.mo.momy = 0
					player.mo.momz = 0
					P_MoveOrigin(player.mo, player.bank_depositing.x, player.bank_depositing.y, player.bank_depositing.z)
					baseTransaction(player, player.ctfteam)
					player.powers[pw_flashing] = ($ and max($, 2)) or 2
					player.powers[pw_nocontrol] = ($ and max($, 2)) or 2
					player.nodamage = ($ and max($, 2)) or 2
					player.intangible = true
					if player.mo.state != S_PLAY_ROLL then
						player.mo.state = S_PLAY_ROLL
					end
				else
					player.bank_depositing.playerDepositing = nil
					player.bank_depositing = nil
					player.intangible = false
				end
			end

			if player.rings >= BANK_RINGLIMIT
				if not S_SoundPlaying(player.mo, sfx_shimr) then
					S_StartSoundAtVolume(player.mo, sfx_shimr, 125)
				end
				highValueSparkle(player)
			elseif S_SoundPlaying(player.mo, sfx_shimr) then
				S_StopSoundByID(player.mo, sfx_shimr)
			end
			if player.mo.health and not player.powers[pw_flashing]
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
	end

	-- Do player in base transactions
	for player in players.iterate do
		if player.mo and player.mo.valid and player.mo.health and not player.powers[pw_flashing]
			local base = getBase(player)
			if base == 1 -- Red base
				if player.gotcrystal and player.mo.chaosring and player.mo.chaosring.valid and player.ctfteam == base then
					capture(player.mo, player.ctfteam, C.RedBank)
					continue
				end
				if blueInRed
					if blueInRed > redInRed then
						if player.ctfteam == 2 then
							playerSteal(player.mo, C.RedBank)
						end
					else
						if player.mo.chaosring_stealing then
							player.mo.chaosring_stealing = nil
							player.gotcrystal_time = 0
							if player.mo.chaosring_tosteal and player.mo.chaosring_tosteal.valid then
								player.mo.chaosring_tosteal.beingstolen = nil
								player.mo.chaosring_tosteal = nil
							end
						end
						if player.mo.chaosring_capturing then
							player.mo.chaosring_capturing = nil
							player.gotcrystal_time = 0
						end
					end
					continue
				end
			elseif base == 2 -- Blue base
				if player.gotcrystal and player.mo.chaosring and player.mo.chaosring.valid and player.ctfteam == base then
					capture(player.mo, player.ctfteam, C.BlueBank)
					continue
				end
				if redInBlue
					if redInBlue > blueInBlue
						if player.ctfteam == 1
							playerSteal(player.mo, C.BlueBank)
						end
					else
						if player.mo.chaosring_stealing then
							player.mo.chaosring_stealing = nil
							player.gotcrystal_time = 0
							if player.mo.chaosring_tosteal and player.mo.chaosring_tosteal.valid then
								player.mo.chaosring_tosteal.beingstolen = nil
								player.mo.chaosring_tosteal = nil
							end
						end
						if player.mo.chaosring_capturing then
							player.mo.chaosring_capturing = nil
							player.gotcrystal_time = 0
						end
					end
					continue
				end
			end
			if base != 0
				local bank = (base==1 and player.ctfteam==1 and C.RedBank) or C.BlueBank
				if base == player.ctfteam and (player.rings >= BANK_RINGLIMIT) and not(player.gotcrystal) and not(bank.playerDepositing) then
					bank.playerDepositing = player
					player.bank_depositing = bank
				end
			end
			if not(base) then
				if player.mo.chaosring_stealing then
					player.mo.chaosring_stealing = nil
					player.gotcrystal_time = 0
					if player.mo.chaosring_tosteal and player.mo.chaosring_tosteal.valid then
						player.mo.chaosring_tosteal.beingstolen = nil
						player.mo.chaosring_tosteal = nil
					end
				end
				if player.mo.chaosring_capturing then
					player.mo.chaosring_capturing = nil
					player.gotcrystal_time = 0
				end
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
	CR.ThinkFrame() --Chaos Rings
end

CR.MapLoad = function()

	if not(B.BankGametype()) then return end

	resetVars()

	local chaosRingSpawn = mobjinfo[MT_BATTLE_CHAOSRINGSPAWNER].doomednum
	local chaosEmeraldSpawn = mobjinfo[MT_EMERALDSPAWN].doomednum

	local infinityRingSpawn = mobjinfo[MT_INFINITYRING].doomednum
	local bouncePanelSpawn = mobjinfo[MT_BOUNCEPICKUP].doomednum
	local railPanelSpawn = mobjinfo[MT_RAILPICKUP].doomednum
	local autoPanelSpawn = mobjinfo[MT_AUTOPICKUP].doomednum
	local bombPanelSpawn = mobjinfo[MT_EXPLODEPICKUP].doomednum
	local scatterPanelSpawn = mobjinfo[MT_SCATTERPICKUP].doomednum
	local grenadePanelSpawn = mobjinfo[MT_GRENADEPICKUP].doomednum

	local bounceRingSpawn = mobjinfo[MT_BOUNCERING].doomednum
	local railRingSpawn = mobjinfo[MT_RAILRING].doomednum
	local autoRingSpawn = mobjinfo[MT_AUTOMATICRING].doomednum
	local bombRingSpawn = mobjinfo[MT_EXPLOSIONRING].doomednum
	local scatterRingSpawn = mobjinfo[MT_SCATTERRING].doomednum
	local grenadeRingSpawn = mobjinfo[MT_GRENADERING].doomednum

	local ringSpawn = mobjinfo[MT_RING].doomednum --Last resort, normal ring spawnpoints
	local coinSpawn = mobjinfo[MT_COIN].doomednum --Mario Mode or something
	

	for mt in mapthings.iterate do
		if mt and mt.valid and (mt.type == (chaosRingSpawn)) then --Battle Chaos Ring Spawn
			insertSpawnPoint(mt)
		end
	end

	if not(#server.SpawnTable) or (#server.SpawnTable < 6) then
		for mt in mapthings.iterate do
			if mt and mt.valid and (mt.type == (chaosEmeraldSpawn)) then --Match Chaos Emerald Spawn
				insertSpawnPoint(mt)
			end
		end
	end

	if not(#server.SpawnTable) or (#server.SpawnTable < 6) then
		for mt in mapthings.iterate do
			if mt and mt.valid and 
			(mt.type == (infinityRingSpawn)) or
			(mt.type == (bouncePanelSpawn)) or
			(mt.type == (railPanelSpawn)) or
			(mt.type == (autoPanelSpawn)) or
			(mt.type == (bombPanelSpawn)) or
			(mt.type == (scatterPanelSpawn)) or
			(mt.type == (grenadePanelSpawn))
			then
				insertSpawnPoint(mt)
			end
		end
	end

	if not(#server.SpawnTable) or (#server.SpawnTable < 6) then
		for mt in mapthings.iterate do
			if mt and mt.valid and 
			(mt.type == (bounceRingSpawn)) or
			(mt.type == (railRingSpawn)) or
			(mt.type == (autoRingSpawn)) or
			(mt.type == (bombRingSpawn)) or
			(mt.type == (scatterRingSpawn)) or
			(mt.type == (grenadeRingSpawn))
			then
				insertSpawnPoint(mt)
			end
		end
	end

	if not(#server.SpawnTable) or (#server.SpawnTable < 6) then
		for mt in mapthings.iterate do
			if mt and mt.valid and 
			(mt.type == (ringSpawn)) or
			(mt.type == (coinSpawn))
			then
				insertSpawnPoint(mt)
			end
		end
	end
end

CR.PreThinkFrame = function()
	if not(CR.VarsExist()) then return end
	for i = 1, #server.AvailableChaosRings do
		if server.AvailableChaosRings[i] and server.AvailableChaosRings[i].valid then
			chaosRingPreFunc(server.AvailableChaosRings[i])
			continue
		end
	end
end

--Experiment, cap rings at 50
local ringTouchSpecial = function(mo, toucher)
	if not(B.BankGametype()) then return end
	if toucher and toucher.valid and toucher.player and toucher.player.rings >= BANK_RINGLIMIT then
		return true
	end
end

local monitorDamage = function(mo, inflictor, source)
	if not(B.BankGametype()) then return end
	if mo and mo.valid and (
	(inflictor and inflictor.valid and inflictor.player and inflictor.player.rings >= BANK_RINGLIMIT) or 
	(source and source.valid and source.player and source.player.rings >= BANK_RINGLIMIT)
	) then
		if inflictor.player then
			inflictor.momx = -($)
			inflictor.momy = -($)
			inflictor.momz = -($)
			S_StartSound(mo, sfx_s3k7b)
		end
		return false
	end
end

local rings = {
	MT_RING,
	MT_FLINGRING,
	MT_REDTEAMRING,
	MT_BLUETEAMRING
}

local ringMonitors = {
	MT_RING_BOX,
	MT_RING_REDBOX,
	MT_RING_BLUEBOX,
	MT_1UP_BOX
}

for _, v in ipairs(rings) do
	--addHook("TouchSpecial", ringTouchSpecial, v)
end

for _, v in ipairs(ringMonitors) do
	--addHook("ShouldDamage", monitorDamage, v)
end


addHook("MapLoad", CR.MapLoad)
addHook("MobjFuse",function(mo)
	if not(mo.captured) then
		mo.flags = $|MF_SPECIAL
		return true
	else
		return true
	end
end,CHAOSRING_TYPE)
addHook("MobjThinker", chaosRingFunc, CHAOSRING_TYPE)
addHook("MobjRemoved", deleteChaosRing, CHAOSRING_TYPE)
addHook("TouchSpecial", touchChaosRing, CHAOSRING_TYPE)
