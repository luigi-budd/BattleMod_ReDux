local B = CBW_Battle
local C = B.Bank
local CV = CBW_Battle.Console
C.RedBank = nil
C.BlueBank = nil
C.ChaosRing = {}
C.BANK_RINGLIMIT = 50
C.ScoreDelay = {}
local CR = C.ChaosRing

--Constants
local BANK_RINGLIMIT = C.BANK_RINGLIMIT

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

CR.Checkpoints = {}
local neardamagefloor = B.MobjNearDamageFloor
CR.UpdateCheckpoint = function(chaosring)
	if not (chaosring and chaosring.valid and chaosring.chaosring_num) then return end
		
	local ringNum = chaosring.chaosring_num
		
	-- If the target (player) exists and is valid
	if chaosring.target and chaosring.target.valid and chaosring.target.player then
		local t = chaosring.target
		local floored = P_IsObjectOnGround(t) or ((t.eflags & MFE_JUSTHITFLOOR) and (t.player.pflags & PF_STARTJUMP))
		local safe = not neardamagefloor(t)
		local failsafe = t.state != S_PLAY_PAIN and not P_PlayerInPain(t.player)
		local checkpoints = CR.Checkpoints
		
		-- Create checkpoint if it doesn't exist
		if not checkpoints[ringNum] then
			checkpoints[ringNum] = {
				x = t.x,
				y = t.y,
				z = t.z,
				obj = P_SpawnMobjFromMobj(chaosring, 0, 0, 0, MT_THOK)
			}
			checkpoints[ringNum].obj.tics = -1
			checkpoints[ringNum].obj.state = S_SHRD1
			checkpoints[ringNum].obj.colorized = true
			checkpoints[ringNum].obj.color = chaosring.color
			checkpoints[ringNum].obj.flags2 = $|MF2_DONTDRAW
		-- Update checkpoint position if player is on solid ground and safe
		elseif floored and safe and failsafe then
			checkpoints[ringNum].x = t.x
			checkpoints[ringNum].y = t.y
			checkpoints[ringNum].z = t.z
			
			if checkpoints[ringNum].obj and checkpoints[ringNum].obj.valid then
				P_MoveOrigin(checkpoints[ringNum].obj, t.x, t.y, t.z)
			end
		end
		
		-- Debug visualization
		local debug = CV.Debug.value
		if checkpoints[ringNum].obj and checkpoints[ringNum].obj.valid then
			if debug&DF_GAMETYPE then
				checkpoints[ringNum].obj.flags2 = $&~MF2_DONTDRAW
			else
				checkpoints[ringNum].obj.flags2 = $|MF2_DONTDRAW
			end
		end
	end
end
CR.ResetCheckpoints = function()
	for num, checkpoint in pairs(CR.Checkpoints) do
		if checkpoint.obj and checkpoint.obj.valid then
			P_RemoveMobj(checkpoint.obj)
		end
	end
	CR.Checkpoints = {}
end

local CHAOSRING_TEXT = function(num, donum)
	if donum then
		return CR.Data[num].textmap.."Chaos Ring "..num.."\x80"
	else
		return CR.Data[num].textmap.."Chaos Ring".."\x80"
	end
end

local applyflip = function(mo1, mo2)
	if mo1.eflags & MFE_VERTICALFLIP then
		mo2.eflags = $|MFE_VERTICALFLIP
	else
		mo2.eflags = $ & ~MFE_VERTICALFLIP
	end
	
	if mo1.flags2 & MF2_OBJECTFLIP then
		mo2.flags2 = $|MF2_OBJECTFLIP
	else
		mo2.flags2 = $ & ~MF2_OBJECTFLIP
	end
end

local chprint = function(string)
	if not(CV.ChaosRing_Debug.value) then return end
	print("\x82".."chprint:".."\x80".." "..string)
end

CR.VarsExist = function()
	return server and (server.SpawnCountDown~=nil and 
	server.GlobalAngle~=nil and 
	server.InitSpawnWait~=nil and
	server.SpawnTable~=nil and
	server.WinCountdown~=nil and
	server.AvailableChaosRings~=nil and
	server.OrderedChaosRings~=nil)
end

CR.GetChaosRing = function(num)
	if server.OrderedChaosRings and server.OrderedChaosRings[num] then
		local chring = server.OrderedChaosRings[num]
		if chring.valid then
			return chring
		end
	end
end
CR.GetChaosRingKey = function(num)
	if server.OrderedChaosRings and server.OrderedChaosRings[num] then
		local chring = server.OrderedChaosRings[num]
		if chring.valid then
			return chring.available_key
		end
	end
end

local resetVars = function()
	server.SpawnTable = {} --Clear the table
	server.WinCountdown = CV.ChaosRing_WinTime.value*TICRATE
	server.SpawnCountDown = 0
	server.AvailableChaosRings = {}
	server.OrderedChaosRings = {}
	server.GlobalAngle = ANG20
	server.InitSpawnWait = CV.ChaosRing_StartSpawnBuffer.value*TICRATE
	CR.ResetCheckpoints()
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
	if num == nil then -- Attempt to fetch it with a filter
		local unnocupied_spawns = {}
		for i, spawn in ipairs(server.SpawnTable) do
			if not (spawn.obj and spawn.obj.valid) then
				table.insert(unnocupied_spawns, i)
			end
		end
		if #unnocupied_spawns then
			num = unnocupied_spawns[P_RandomRange(1, #unnocupied_spawns)]
		else
			num = P_RandomRange(1, #server.SpawnTable)
		end
	end

	local thing = server.SpawnTable[num]
	if not thing then
		B.DebugPrint("Nonexistant spawnpoint!", DF_GAMETYPE)
		return
	end

	local x, y, z
	local useCheckpoint = false

	-- Check if we have a checkpoint for this Chaos Ring
	if CR.Checkpoints[chaosringnum] and CR.Checkpoints[chaosringnum].obj and CR.Checkpoints[chaosringnum].obj.valid then
		x = CR.Checkpoints[chaosringnum].x
		y = CR.Checkpoints[chaosringnum].y
		z = CR.Checkpoints[chaosringnum].z
		useCheckpoint = true
		
		P_RemoveMobj(CR.Checkpoints[chaosringnum].obj)
		CR.Checkpoints[chaosringnum] = nil
	else
		if thing.mo and thing.mo.valid then
			B.DebugPrint("Already has an object!", DF_GAMETYPE)
			return
		end
		
		-- Use the spawn point coordinates
		x = thing.x
		y = thing.y
		z = thing.z
	end

	local sector = (R_PointInSubsector(x, y)).sector

	local flip = ((thing.options&MTF_OBJECTFLIP) and -1) or 1
	local float = ((thing.options&MTF_AMBUSH) and 1) or 0
	--local z = ((thing.options & MTF_AMBUSH) and (thing.z+(24*FRACUNIT))) or thing.z
	--local z = 

	if useCheckpoint then
		thing.mo = P_SpawnMobj(x, y, z, CHAOSRING_TYPE)
	else
		thing.mo = P_SpawnMobj(thing.x, thing.y, (((flip==-1) and sector.ceilingheight-(thing.z)) or sector.floorheight+(thing.z+(24*FRACUNIT*float))), CHAOSRING_TYPE)
	end
	if flip == -1 then
		thing.mo.flags2 = $|MF2_OBJECTFLIP
	end

	--local floor = P_FloorzAtPos(thing.x, thing.y, , mobjinfo[CHAOSRING_TYPE].height)
	local data = CR.Data[chaosringnum]

	thing.mo.scale = FixedMul(thing.scale, CHAOSRING_SCALE) --Chaos Rings are large
	thing.mo.color = data.color --Color according to number
	thing.mo.chaosring_num = chaosringnum --Store number
	thing.mo.idealz = thing.mo.z --Store original Z position
	thing.mo.idealscale = FixedMul(thing.scale, CHAOSRING_SCALE) --Store ideal scale
	thing.num = num --Store spawnpoint number
	thing.mo.chaosring_thingspawn = thing --Store the MapThing table
	thing.mo.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS --Shiny
	--table.remove(server.SpawnTable, num) --Don't try to spawn here again
	if not useCheckpoint then
		print("A "..CHAOSRING_TEXT(chaosringnum).." has "..((re and "re") or "").."spawned!")
		if re then
			S_StartSound(nil, sfx_cdfm44)
		end
	end
	thing.mo.radius = 16*FRACUNIT
	return thing.mo
end

local function free(mo)
	if not (mo and mo.valid) then return end
	mo.fuse = (mo.captured and CV.ChaosRing_InvulnTime.value*TICRATE) or freetics
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
	local previousTarget = (mo.target and mo.target.valid and mo.target) --Old Target

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

	if (toucherIsFlashing or B.HomingDeflect(toucher.player, mo.target)) and not(mo.captured) then
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
			server.WinCountdown = CV.ChaosRing_WinTime.value*TICRATE --Reset the Win Countdown
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
	mo.scale = mo.target.scale
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
		if previousTarget then
			if previousTarget.player then
				if B.MyTeam(previousTarget.player, toucher.player) then
					B.PrintGameFeed(previousTarget.player," passed their "..CHAOSRING_TEXT(mo.chaosring_num).." to ",toucher.player,"!")
				else
					B.PrintGameFeed(toucher.player," stole a "..CHAOSRING_TEXT(mo.chaosring_num).." from ",previousTarget.player,"!")
				end
			elseif (previousTarget == C.RedBank) or (previousTarget == C.BlueBank) then
				B.PrintGameFeed(toucher.player," stole a "..CHAOSRING_TEXT(mo.chaosring_num).." from the "..(((previousTarget == C.RedBank) and "\x85".."Red") or "\x84".."Blue").." Team.".."\x80")
			end
		else
			B.PrintGameFeed(toucher.player," picked up a "..CHAOSRING_TEXT(mo.chaosring_num).."!")
		end
	end

	return true
end


local function captureChaosRing(mo, bank) --Capture a Chaos Ring into a Bank
	mo.flags = $ & ~MF_SPECIAL --Can't be touched
	bank.chaosrings = $|(CHAOSRING_ENUM[mo.chaosring_num]) --Add to Bank count
	mo.bank = bank --Set its Bank to the new Bank
	addPoints(mo.target.player.ctfteam, CV.ChaosRing_CaptureScore.value) --Reward points to the team
	mo.target.player.preservescore = $ + CV.ChaosRing_CaptureScore.value --P_AddPlayerScore
	mo.fuse = CV.ChaosRing_InvulnTime.value*TICRATE --Set the steal cooldown
	mo.scale = (mo.idealscale - (mo.idealscale/3)) --Shrink it
	mo.captureteam = mo.target.player.ctfteam --Set the team it's captured in
	B.PrintGameFeed(mo.target.player," captured a "..CHAOSRING_TEXT(mo.chaosring_num).."!")
	touchChaosRing(mo, bank, true)
	mo.scale = CHAOSRING_SCALE
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

	if mo.player.gotcrystal_time~=nil and (mo.player.gotcrystal_time >= CV.ChaosRing_StealTime.value*TICRATE) then --If we've been standing long enough
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

local chaosringspark = function(mo)
	local r
	if not(leveltime%8) then
		if mo.beingstolen then
			local g = P_SpawnGhostMobj(mo)
			g.blendmode = AST_ADD
			g.tics = 7
			g.frame = ($ & ~FF_TRANSMASK) | FF_TRANS50
			g.scale = $ * 8/7
			g.destscale = mo.scale * 3/2
			g.scalespeed = FRACUNIT/2
			r = g
		else
			local spark = P_SpawnMobjFromMobj(mo,0,0,0,MT_SUPERSPARK)
			spark.scale = mo.scale
			spark.colorized = true
			spark.color = mo.color
			spark.spriteyoffset = $-(FRACUNIT*6)
			r = spark
		end
	end
	return r
end

local blink = B.Blink
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
	
	blink(mo)

	--Set internal angle
	mo.angle = $+rotatespd
	
	-- Owner has been pushed by another player
	if mo.flags&MF_SPECIAL and mo.target and mo.target.valid 
	and mo.target.pushed_last and mo.target.pushed_last.valid
		touchChaosRing(mo,mo.target.pushed_last, B.MyTeam(mo.target, mo.target.pushed_last) == false)
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
		chaosringspark(mo)

		local t = mo.target
		local player = t.player
		local customdist = t.radius*3
		if t.chaosring_capturing then
			local offset = player and (player.gotcrystal_time*mo.scale) or 1 
			customdist = $-(offset/2)
		end
		B.MacGuffinClaimed(mo, customdist)
		CR.UpdateCheckpoint(mo)
	else --Loose?
		mo.flags = ($|MF_BOUNCE)&~MF_SLIDEME
		if mo.flags & MF_GRENADEBOUNCE == 0
			mo.flags = $|MF_NOGRAVITY
			local zz = mo.idealz + (sin(leveltime * ANG10) * 128)
			B.ZLaunch(mo, (zz - mo.z) / 120, false)
			
		else
			chaosringspark(mo)
			mo.flags = $&~MF_NOGRAVITY
			if P_IsObjectOnGround(mo)
				-- Bounce behavior
				B.ZLaunch(mo, FRACUNIT*bounceheight/2, true)
				S_StartSoundAtVolume(mo, sfx_tink, 100)
			end
		end
	end

end

local function deleteChaosRing(chaosring) --Special Behavior upon Removal
	if chaosring and chaosring.valid and chaosring.chaosring_num and CR.GetChaosRingKey(chaosring.chaosring_num) then
		local spark = P_SpawnMobjFromMobj(chaosring, 0,0,0,MT_SPARK)
		spark.colorized = true
		spark.color = chaosring.color

		--Re-Insert Spawnpoint
		server.SpawnTable[chaosring.chaosring_thingspawn.num] = chaosring.chaosring_thingspawn

		--Set to Respawning in LiveTable
		local checkPoint = CR.Checkpoints[chaosring.chaosring_num]
		server.AvailableChaosRings[CR.GetChaosRingKey(chaosring.chaosring_num)] = {
			chaosring_num = chaosring.chaosring_num,
			valid = false,
			respawntimer= checkPoint and 1 or CV.ChaosRing_SpawnBuffer.value*TICRATE,
			checkpoint = checkPoint
		}
		server.OrderedChaosRings[chaosring.chaosring_num] = nil

		if not checkPoint then
			print("A "..CHAOSRING_TEXT(chaosring.chaosring_num).." was lost!")
		end
		S_StartSound(nil, sfx_kc5d)
	end
end

local GS = B.CTF.GameState
local handleremovalsectors = B.HandleRemovalSectors
CR.ThinkFrame = function() --Main Thinker
	if not(CR.VarsExist()) then return end

	server.GlobalAngle = (($+rotatespd == ANG1*360) and 0) or $+rotatespd --Constantly rotating

	local roundTime = leveltime-(CV_FindVar("hidetime").value*TICRATE)
	local startupChaosRings = roundTime >= CV.ChaosRing_StartSpawnBuffer.value*TICRATE

	local allChaosRings = (#server.AvailableChaosRings >= 6)

	if startupChaosRings and not(allChaosRings)  then --2 Minutes in?

		if server.SpawnCountDown <= 0 then --Counted down?
			S_StartSound(nil, sfx_kc33)
			local num = server.AvailableChaosRings and #server.AvailableChaosRings+1 or 1
			GS.CaptureHUDName = num

			local newring = spawnChaosRing(nil, num)
			if newring and newring.valid then
				GS.CaptureHUDTimer = 5*TICRATE
			    table.insert(server.AvailableChaosRings, newring)
			else
				B.DebugPrint("Failed to spawn a "..CHAOSRING_TEXT(num).."!", DF_GAMETYPE)
			end
			--Set our countdown
			server.SpawnCountDown = CV.ChaosRing_SpawnBuffer.value*TICRATE
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
				server.AvailableChaosRings[i] = spawnChaosRing(nil, i, true)
			end
			continue
		end

		if remove then
			continue
		end

		local delete = handleremovalsectors(chaosring, CHAOSRING_TEXT(chaosring.chaosring_num), true)

		-- Idle timer
		if chaosring.idle != nil and not(chaosring.captured) and not(chaosring.target and chaosring.target.valid and chaosring.target.player) then 
			chaosring.idle = $-1
			if chaosring.idle < waittics then
				blink(chaosring)
			end
			if chaosring.idle == 0
				if chaosring.captureteam then
					-- Remove team protection
					chaosring.idle = nil
					chaosring.captureteam = 0
					chaosring.beingstolen = nil
				else
					local num = chaosring.chaosring_num
					if CR.Checkpoints[num] and CR.Checkpoints[num].obj and CR.Checkpoints[num].obj.valid then
						P_RemoveMobj(CR.Checkpoints[num].obj)
						CR.Checkpoints[num] = nil
					end
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
			applyflip(mo, mo.chaosring_corona)
			mo.chaosring_corona.fuse = max($, 2)
			mo.chaosring_corona.scale = mo.scale
			P_MoveOrigin(mo.chaosring_corona, mo.x, mo.y, ((P_MobjFlip(mo)==-1) and (mo.z+mo.height-(mo.height/2))) or mo.z+(mo.height/2))
		end
		if not(mo.chaosring_corona and mo.chaosring_corona.valid) then
			mo.chaosring_corona = P_SpawnMobjFromMobj(mo, 0,0,((P_MobjFlip(mo)==-1) and (mo.height-(mo.height/2))) or mo.z+(mo.height/2), MT_INVINCIBLE_LIGHT)
			applyflip(mo, mo.chaosring_corona)
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
			player.preservescore = $+1 --P_AddPlayerScore(player, 1)
			if not (player.powers[pw_nocontrol] and player.nodamage) then
				addPoints(team, player.rings)
				C.ScoreDelay[player.ctfteam] = player.rings
			end
			P_GivePlayerRings(player, -1)
			player.tossdelay = bankTime(player)
			--[[local spark = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BOXSPARKLE)
			if spark and spark.valid
				spark.colorized = true
				spark.color = SKINCOLOR_CARBON
			end]]
			baseSparkle(player, team)
		end
	else
		-- Steal rings
		if score > 0 and not player.actionstate
			S_StartSound(player.mo, sfx_itemup)
			player.preservescore = $+1 --P_AddPlayerScore(player, 1)
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

	return B.MobjTouchingFlagBase(player.mo)
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
	local captime = CV.ChaosRing_CaptureTime.value*TICRATE
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
	else
		
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

		--Chaos Ring Radar
		if not(player.gotcrystal) then
			local p = player
			local beeps = {}
			local proxBeep = { 50, 50, 40, 20, 10, 5 }
			//Emblem radar. Also hidden when the menu is present.
			for i=1,#server.AvailableChaosRings do
				local chaosring = server.AvailableChaosRings[i]
				local invalid = (not(chaosring and chaosring.valid) or chaosring.target or not(chaosring.valid))
				if invalid then
					continue 
				end
				local proximity = B.GetProximity(p.mo, chaosring)
				if proximity > 1 then
					table.insert(beeps, {proximity=proximity, color=chaosring.color})
				end
			end

			if #beeps then
				table.sort(beeps, function(a, b) return a.proximity > b.proximity end)
				if not(leveltime % proxBeep[beeps[1].proximity]) then
					S_StartSoundAtVolume(nil, sfx_crng2, 100, p)
				end
				player.chaosring_radarbeeps = beeps
				--v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, outline, flags_hudtrans, v.getColormap(TC_BLINK, radarColor[beeps[1].proximity]))
			else
				player.chaosring_radarbeeps = nil
			end
		end

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
					local spawnstate = (B.SkinVars[player.mo.skin] and B.SkinVars[player.mo.skin].spawnanim_state) or S_PLAY_ROLL
					if player.mo.state != spawnstate then
						player.mo.state = spawnstate
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
	--Make it look like the scores are smoothly increasing
	for i, v in pairs(C.ScoreDelay) do
		if leveltime%3==0 and v then C.ScoreDelay[i] = v - 1 end
	end
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
