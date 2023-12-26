local B = CBW_Battle
local CV = B.Console
local A = B.Arena
local D = B.Diamond
local CP = B.ControlPoint
local I = B.Item
local S = B.SkinVars

B.DebugHUD = function(v, player, cam)
	local debug = CV.Debug.value
	
	if ((not B.VersionPublic) or debug) then
		local flags = V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP
		local flags2 = V_ALLOWLOWERCASE|V_HUDTRANSHALF|V_SNAPTORIGHT|V_SNAPTOTOP
		local xx = v.width()/v.dupx()
		local align = "small-right"
		v.drawString(320,0,"v"..B.VersionNumber.."."..B.VersionSub.." [\x82"..B.VersionCommit.."\x80]\n",flags,align)
		v.drawString(317,4,B.VersionBranch,flags2,align)
		v.drawString(317,8,B.VersionDate.." ["..B.VersionTime.."]",flags2,align)
	end
	
	if not(debug) then return end
	local xoffset = 320
	local yoffset = 14
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_SNAPTORIGHT|V_PERPLAYER
	local align = "small-right"
	local nextline = 4
	--Double the scale for smaller screens (illegible otherwise)
	if v.height() < 400 then 
		align = "right"
		nextline = 8
	end
	local addspace = function()
		yoffset = $+nextline
	end
	local addline = function(string,string2)
		string = "\x86"+tostring($)+": \x80"+tostring(string2)
		v.drawString(xoffset,yoffset,string,flags,align)
		yoffset = $+nextline
	end
	local addheader = function(string)
		yoffset = $+nextline
		string = "\x82"+string
		v.drawString(xoffset,yoffset,string,flags,align)
		yoffset = $+nextline
	end
	local subheader = function(string)
		string = "\x88"+string
		v.drawString(xoffset,yoffset,string,flags,align)
		yoffset = $+nextline
	end
	--****
	--Execute drawing
	--****
	if B.ArenaGametype() then
		--Making room for Arena's HUD
		addspace()
		addspace()
	end
	--Gametypes
	if debug&DF_GAMETYPE then
			addheader("Gametype")
			addline("RedScore",B.RedScore)
			addline("BlueScore",B.BlueScore)
			addline("Pinch",B.Pinch)
			addline("Overtime",B.Overtime)
			addline("SuddenDeath",B.SuddenDeath)
			addline("PinchTics",B.PinchTics)
			addline("Exiting",B.Exiting)
			addline("Timeout",B.Timeout)
			
		if B.ArenaGametype() then
			subheader("Arena")
			addline("Fighters",#A.Fighters)
			addline("RedFighters",#A.RedFighters)
			addline("BlueFighters",#A.BlueFighters)
			addline("Survivors",#A.Survivors)
			addline("RedSurvivors",#A.RedSurvivors)
			addline("BlueSurvivors",#A.BlueSurvivors)
			addline("SpawnLives",A.SpawnLives)
			addline("GameOvers",A.GameOvers)
			addline("Bounty",""+A.Bounty+"("+A.Bounty.name+")")
		end
		
		if B.CPGametype() then
			subheader("Control Point")
			addline("IDs",#CP.ID)
			addline("Num",CP.Num)
			addline("Meter",CP.Meter)
			addline("RedCapAmt",CP.TeamCapAmt[1])
			addline("TeamCapAmt",CP.TeamCapAmt[2])
			addline("LeadCapAmt",CP.LeadCapAmt)
		end
		
		if B.DiamondGametype() then
			subheader("Ruby")
			addline("Spawned",(D.ID ~= nil and D.ID.valid))
			if(D.ID and D.ID.valid and D.ID.target and D.ID.target.player) then
				addline("Holder",(D.ID.target.player.name))
			end
			if(D.ID and D.ID.valid) then
				addline("Idle",(D.ID.idle))
			end
		end
	end
	
	--Items
	
	if debug&DF_ITEM then
		addheader("Items")
		addline("Global Spawns",#I.Spawns)
		addline("Global Timer",I.SpawnTimer/TICRATE.."/"..(4-CV.ItemRate.value)*I.GlobalRate/2)
		addline("GlobalChance Entries",#I.GlobalChance)
		addline("Global Item Rate",I.GlobalRate)
		addline("Local Item Rate",I.LocalRate)
		addline("Item Type",CV.ItemType.value)
	end
	
	--Player
	if debug&DF_PLAYER then
		if player and player.valid then
			addheader("Player")
			addline("SkinVars",player.skinvars)
			addline("SkinVars.flags",B.GetSkinVarsFlags(player))
			addline("Rank",player.rank)
			addline("PreserveScore",player.preservescore)
			addline("Exhaust",player.exhaustmeter*100/FRACUNIT.."%")
			addline("Revenge",player.revenge)
			addline("LifeShards",player.lifeshards)
			addline("IsEggRobo",player.iseggrobo)
			addline("IsJettySyn",player.isjettysyn)
-- 			addline("Carry_ID",player.carry_id)
-- 			addline("Carried_Time",player.carried_time)
			addline("BattleSpawning",player.battlespawning)
			addline("SpectatorTime",player.spectatortime)
			addline("DeadTimer",player.deadtimer)
			addline("Intangible",player.intangible)
			addline("AirGun",player.airgun)
			addline("Tumble",player.tumble)
			subheader("Action")
			addline("Allowed",player.actionallowed)
			addline("super",player.actionsuper)
			addline("state",player.actionstate)
			addline("time",player.actiontime)
			addline("rings",player.actionrings)
			--addline("debt",player.actiondebt)
			addline("cooldown",player.actioncooldown)
			subheader("Battle")
			addline("sfunc",player.battle_sfunc)
			addline("atk",player.battle_atk)
			addline("def",player.battle_def)
			addline("satk",player.battle_satk)
			addline("sdef",player.battle_sdef)
			addline("text",player.battle_hurttxt)
			subheader("Guard")
			addline("CanGuard",player.canguard)
			addline("guard",player.guard)
			addline("guardtics",player.guardtics)
		end
		if player and player.valid and player.mo and player.mo.valid then
			subheader("General")
			addline("ID",player.mo)
			addline("target",player.mo.target)
			addline("tracer",player.mo.tracer)
			addline("Carry",player.powers[pw_carry])
			addline("Flashing",player.powers[pw_flashing])
			addline("NoControl",player.powers[pw_nocontrol])
			addline("JumpFactor",player.jumpfactor)
			addline("ThrustFactor",player.thrustfactor)
			addline("Lock Aim",player.lockaim)
			addline("Lock Move",player.lockmove)
			addline("Pushed Credit",player.pushed_creditplr)
		end
	end
	--Collision
	if debug&DF_COLLISION then
		addheader("Collision")
		if player and player.valid and player.mo and player.mo.valid then
			subheader("player.mo")
			addline("pushed_last",player.mo.pushed_last)
			addline("pushtics",player.mo.pushtics)
			addline("weight",player.mo.weight*100/FRACUNIT.."%")
		end
		local T = B.TrainingDummy
		if T and T.valid then
			subheader("Training Dummy")
			addline("Hits",B.HitCounter)
			addline("Fuse",T.fuse)
			addline("Pain",T.pain)
			addline("AI",T.ai)
			addline("Attacking",T.attacking)
			addline("Phase",T.phase)
			addline("Invisibility",(T.flags&MF_NOCLIPTHING))
		end
	end
end
