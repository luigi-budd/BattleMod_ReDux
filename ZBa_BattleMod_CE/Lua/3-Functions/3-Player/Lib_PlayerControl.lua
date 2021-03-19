local B = CBW_Battle
local CV = B.Console
local S = B.SkinVars

B.InitPlayer = function(player)
	B.DebugPrint("Initializing "..player.name.."'s player variables",DF_PLAYER)

	//Battle related skin stats
	B.GetSkinVars(player)
	
	//Battle related variables
	player.actionsuper = false
	player.actionrings = 0
	player.action2rings = 0
	player.actiondebt = 0
	player.actiontime = 0
	player.actionstate = 0
	player.actioncooldown = TICRATE
	player.actionallowed = true
	player.actiontext = nil
	player.actiontextflags = 0
	player.action2text = nil
	player.action2textflags = 0
	player.charmed = false
	player.charmedtime = 0
	player.backdraft = 0
	player.spendrings = 0
	player.disableringslinger = false
	player.iseggrobo = false
	player.eggrobo_transforming = false
	player.capturing = false
	player.captureamount = 0
	player.gotflagdebuff = false
	player.pushed_creditplr = nil
	player.pushed_credittime = 0
	player.shieldstock = {}
	player.shieldmax = 2
	player.exhaustmeter = FRACUNIT
	player.gotcrystal = false
	player.gotcrystal_time = 0
	player.lifeshards = 0
	player.shieldswap_cooldown = 0
	player.airdodge = 0
	player.melee_state = 0
	player.thinkmoveangle = 0
	player.intangible = false
	player.lockaim = false
	player.lockmove = false
	player.rank = 0
	player.canguard = true
	player.guard = 0
	player.guardtics = 0
	player.carried_time = 0
	if player.respawnpenalty == nil then
		player.respawnpenalty = 0
	end
	if player.spectatortime == nil then
		player.spectatortime = 0
	end
	
	//Player Config
	if player.battleconfig_guard == nil then
		player.battleconfig_guard = BT_FIRENORMAL
	end
	if player.battleconfig_special == nil then
		player.battleconfig_special = BT_ATTACK
	end
	if player.battleconfig_aimsight == nil then
		player.battleconfig_aimsight = true
	end
	if player.battleconfig_autospectator == nil then
		player.battleconfig_autospectator = true
	end
	
	if player.revenge == nil then
		player.revenge = false
	end
	player.isjettysyn = false
	if player.mo then
		player.charflags = skins[player.mo.skin].flags
	end
	if not (player.lastcolor) then
		player.lastcolor = 0
	end
end

B.ResetPlayerProperties = function(player,jumped,thokked)
	local mo = player.mo
	if not(mo) then return end
	//Reset pflags
	local pflags = player.pflags&~(PF_GLIDING|PF_BOUNCING)
	if jumped == true then
		pflags = $|PF_JUMPED&~PF_STARTJUMP
		if player.charflags&SF_NOJUMPDAMAGE
			pflags = $|PF_NOJUMPDAMAGE
		end
		if not(player.charflags&SF_NOJUMPSPIN)
			mo.state = S_PLAY_ROLL
		else
			mo.state = S_PLAY_SPRING
		end
	elseif jumped == false then
		pflags = $&~(PF_JUMPED|PF_SPINNING)
		if not(P_IsObjectOnGround(mo)) and not(P_PlayerInPain(player)) then
			mo.state = S_PLAY_FALL
		end
	end
	if thokked == true then
		pflags = ($|PF_THOKKED)&~PF_SHIELDABILITY
	elseif thokked == false then
		pflags = $&~(PF_THOKKED|PF_SHIELDABILITY)
	end
	player.pflags = pflags
	//Reset other variables
	local skin = skins[mo.skin]
	mo.flags = $&~(MF_NOCLIPTHING)
	mo.flags2 = $&~(MF2_DONTDRAW)
	player.charability = skin.ability
	player.charability2 = skin.ability2
	player.normalspeed = skin.normalspeed
	player.thrustfactor = skin.thrustfactor
	player.climbing = 0
	player.secondjump = 0
	if not(player.actionsuper) then
		player.actionstate = 0
		player.actiontime = 0
	end
	player.exhaustmeter = FRACUNIT
	player.otherscore = nil
end

B.GetSkinVars = function(player)
	local mo = player.mo
	local exists = (mo and mo.valid)
	
	//Get player skin
	if not(exists) or not(S[player.mo.skin]) or player.isjettysyn or player.iseggrobo
		player.skinvars = -1
	else
		player.skinvars = player.mo.skin
	end
	return player.skinvars
end

B.GetSkinVarsFlags = function(player,value)
	if value != nil
	and (player.skinvars == nil or player.skinvars == -1 or S[player.skinvars] == nil)
		return S[-1].flags
	end
	local flags = S[player.skinvars].flags 
	if flags == nil then
		flags = S[-1].flags
	end
	if value == nil then
		return flags
	else
		return flags&value
	end
end

B.DrawSVSprite = function(player,value)
	local s = player.skinvars
	if not(player.mo)
	or s == -1 
	or S[s].sprites == nil 
	or S[s].sprites[value] == nil
		return false
	end
	P_SetMobjStateNF(player.mo,S[s].sprites[value])
	return true
end

B.GetSVSprite = function(player,value)
	local s = player.skinvars
	//Return nil have skinvars undefined
	if not(player.mo)
	or s == -1 
	or S[s].sprites == nil 
		return nil
	end
	//Get value-defined skinvar state
	if not(value == nil)
		if S[s].sprites[value] == nil
			return nil
		else
			return S[s].sprites[value]
		end
	else //Get player's current skinvar state
		for n = 1, #S[s].sprites
			if player.mo.state == S[s].sprites[n]
				return S[s].sprites[n]
			end
		end
	end
end

B.PlayerButtonPressed = function(player,button,held,check_stasis)
	if not(player.cmd.buttons&button) then return false end
	if held == true and not(player.buttonhistory&button) then return false end
	if held == false and player.buttonhistory&button then return false end
	if(check_stasis) and player.powers[pw_nocontrol] then return false end
	return true
end

B.GetInputAngle = function(player)
	//2d check
	if (player.mo and player.mo.valid)
	and (player.mo.flags2&MF2_TWOD or twodlevel) then
		return player.mo.angle
	end
	
	//3d
	local fw = player.cmd.forwardmove
	local sw = player.cmd.sidemove
	local pang = player.cmd.angleturn << 16
	
	if fw == 0 and sw == 0 then
		return nil
	end
	
	local c0, s0 = cos(pang), sin(pang)
	
	local rx, ry = fw*c0 + sw*s0, fw*s0 - sw*c0
	local retangle = R_PointToAngle2(0, 0, rx, ry)
	return retangle
end

B.MyTeam = function(player,myplayer) //Also accepts player.mo
	//Check yourself before you wreck yourself
	if myplayer == player then return true end
	if (player == nil) or (myplayer == nil) //One of these is invalid!
		B.Warning("Attempted to use a nil argument in function MyTeam()!")
	return end
	//Are we using mo's instead of players? Let's fix that.
	if player.player then player = player.player end
	if myplayer.player then myplayer = myplayer.player end
	//FriendlyFire
	if CV_FindVar("friendlyfire").value then
		return false
	end
	//CTF checks
	if G_GametypeHasTeams() then
		if player.ctfteam == myplayer.ctfteam then return true
		else return false
		end
	end
	//Tag checks
	if B.TagGametype() then
		if player.pflags&PF_TAGIT == myplayer.pflags&PF_TAGIT then return true
		else return false
		end
	end
	//Battle check
	if (B.BattleGametype() or G_RingSlingerGametype()) and not(G_GametypeHasTeams()) then
		return false
	end
	//default
	return true
end

B.RestoreColors = function(player)
	if G_GametypeHasTeams() then
		if player.skincolor
		and player.lastcolor == 0
			player.lastcolor = player.skincolor
		end
	else
		if player.skincolor
		and player.lastcolor != 0
			player.skincolor = player.lastcolor
			player.lastcolor = 0
		end
	end	
end

B.DrawAimLine = function(player,angle)
	if not(player.mo) then return end
	if not(player.battleconfig_aimsight) then return end
	if not(leveltime&1) then return end
	if angle == nil then angle = player.mo.angle end
	for n = 1,8
		local dist = FRACUNIT*64*n
		local x = player.mo.x+P_ReturnThrustX(nil,angle,dist)
		local y = player.mo.y+P_ReturnThrustY(nil,angle,dist)
		local z = player.mo.z+player.mo.height/4
-- 		if P_MobjFlip(player.mo) == -1 then
-- 			z = $+player.mo.height
-- 		end
		local b = P_SpawnMobj(x,y,z,MT_CPBONUS)
		if b and b.valid then
			b.fuse = 1
			b.color = B.Choose(SKINCOLOR_ORANGE,SKINCOLOR_YELLOW,SKINCOLOR_SILVER,SKINCOLOR_GREEN,SKINCOLOR_GREY,SKINCOLOR_FOREST,SKINCOLOR_PURPLE,SKINCOLOR_COBALT,SKINCOLOR_RED)
			b.color = player.skincolor
			//Only the user is supposed to see this
			if not(player == displayplayer or player == secondarydisplayplayer) then 
				b.flags2 = $|MF2_DONTDRAW 
			end
		end
	end
end

B.DoPlayerFlinch = function(player, time, angle, thrust,force)
	//Uncurl
	if P_IsObjectOnGround(player.mo) then
		player.panim = 0
		player.mo.state = S_PLAY_SKID
		player.pflags = $&~(PF_SPINNING|PF_STARTDASH|PF_SLIDING)
	else
		player.panim = PA_FALL
		player.mo.state = S_PLAY_FALL
		player.pflags = $&~(PF_GLIDING|PF_JUMPED|PF_BOUNCING|PF_SPINNING|PF_THOKKED|PF_SHIELDABILITY)
	end
	//Apply recoil
	player.powers[pw_nocontrol] = max($,min(time,TICRATE))
	player.mo.recoilangle = angle
	player.mo.recoilthrust = thrust
	if not(player.actionsuper) then
		player.actionstate = 0
	end
	if force == true then
		P_InstaThrust(player.mo,angle,thrust)
	end
end

B.PlayerCreditPusher = function(player,source)
	if source and source.valid and source.player
		player.pushed_creditplr = source.player
	end
end

B.PlayerSetupPhase = function(player)
	if (player.spectator or player.playerstate != PST_LIVE) then return end
	local mo = player.mo
	
	local skinnum = #skins[mo.skin]
	//If we're changing skins, this is the set of instructions we'll use
	local skinchanged = false
	local function newskin()
		if not(R_SkinUsable(mo.player, skinnum)) then return end		
-- 		COM_BufInsertText(mo.player, skintext..tostring(skinnum))
		R_SetPlayerSkin(player,skinnum)
		S_StartSound(nil,sfx_menu1,player)
		B.GetSkinVars(player)
		B.SpawnWithShield(player)
		skinchanged = true
	end
	//Roulette
	if player.cmd.buttons&BT_JUMP and not(player.buttonhistory&BT_JUMP) then
		repeat 
			skinnum = $+1
			if skinnum >= #skins then skinnum = 0 end
			newskin()
		until skinchanged == true
	end
	if player.cmd.buttons&BT_USE and not(player.buttonhistory&BT_USE) then
		skinnum = $-1
		if skinnum < 0 then skinnum = #skins-1 end
		newskin()
	end	
	
	//No control
	player.powers[pw_nocontrol] = 2
	//Don't kill me
	player.powers[pw_flashing] = TICRATE
	if player.powers[pw_underwater] then
		player.powers[pw_underwater] = max(30*TICRATE,$)
	end
	
	//State
	if not(P_IsObjectOnGround(mo)) then
		mo.state = S_PLAY_FALL
	end
	
	//Update history
	player.buttonhistory = player.cmd.buttons
end