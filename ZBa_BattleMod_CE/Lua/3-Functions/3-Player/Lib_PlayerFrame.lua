local B = CBW_Battle
local A = B.Arena

B.PlayerPreThinkFrame = function(player)
	//Initiate support mobj
	B.SpawnTargetDummy(player)
	//History
	if player.versusvars == nil then
		player.buttonhistory = player.cmd.buttons
		B.InitPlayer(player)
		player.versusvars = true
	end

	//Spectator functions
	B.PreAutoSpectator(player)
	B.SpectatorControl(player)

	//Arena death functions
	A.ForceRespawn(player)
	A.GameOverControl(player)
	
	//Dead control unlock
	if player.playerstate != PST_LIVE then
		player.lockaim = false
		player.lockmove = false
	end
	
	//Spawning
	if player.playerstate == PST_LIVE then
		//Battle spawn animation
		local spawning = B.PlayerBattleSpawning(player) 
		//Pre Round Setup
		if not(spawning) and B.PreRoundWait()
			B.PlayerSetupPhase(player)
		end
	end
	//Control inputs
	B.PreGunslinging(player)
	if player.lockaim and player.mo then //Aim is being locked in place
		player.cmd.aiming = player.aiming>>16
		player.cmd.angleturn = player.mo.angle>>16
	end
	if player.pflags&PF_STASIS then
		//Failsafe for simple controls
		player.cmd.sidemove = 0
		player.cmd.forwardmove = 0
	end
	if player.lockmove
		player.cmd.sidemove = 0
		player.cmd.forwardmove = 0
		player.cmd.buttons = 0
	end
end

local function buttoncheck(player,button)
	if player.cmd.buttons&button then
		if player.buttonhistory&button then
			return 2
		else
			return 1
		end
	end
	return 0
end

B.PlayerThinkFrame = function(player)
	local pmo = player.mo
	
	//Sanity checks
	if player.versusvars == nil then return end
	if not(pmo and pmo.valid) or player.playerstate != PST_LIVE then return end
	if maptol&(TOL_NIGHTS|TOL_XMAS) then return end
	
	//Shield Stock usage
	B.ShieldStock(player)
	B.ShieldMax(player) //Regulate shield capacity
	
	//Lock-aim
	if player.lockaim then
		player.lockaim = false
		player.drawangle = player.mo.angle
	end
	if player.lockmove then
		player.lockmove = false
	end
	
	//Skinvars
	B.GetSkinVars(player)
	
	//Ability control
	B.GuardControl(player)//Guard behavior
	B.CharAbilityControl(player)//Exhaust and ability behavior
	B.ShieldSwapControl(player)//Shield swap
	
	//Update timers/stats
	B.GotFlagStats(player)
	player.charmedtime = max(0,$-1)
	player.actioncooldown = max(0,$-1)
	B.DoBackdraft(player)
	
	//Special thinkers
	A.JettySynThinker(player)
	B.AutoSpectator(player)
	A.RingSpill(player)
	B.PlayerMovementControl(player)
	
	//Perform Actions
	local doaction = buttoncheck(player,player.battleconfig_special)
	B.MasterActionScript(player,doaction)
	
	//Guard, Stun Break
	local doguard = buttoncheck(player,player.battleconfig_guard)
	B.Guard(player,doguard)	
	B.StunBreak(player,doguard)
	
	//Abilities
	B.CustomGunslinger(player)
	B.ShieldActives(player)
	
	//PvP Collision
	B.DoPriority(player)
	B.DoPlayerInteract(pmo,pmo.pushed)
	B.UpdateRecoilState(pmo)
	B.UpdateCollisionHistory(pmo)
end

B.PlayerPostThinkFrame = function(player)
	player.buttonhistory = player.cmd.buttons
end