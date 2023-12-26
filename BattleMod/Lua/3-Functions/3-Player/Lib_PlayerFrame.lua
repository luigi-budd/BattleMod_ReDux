local B = CBW_Battle
local A = B.Arena

B.PlayerPreThinkFrame = function(player)
	--Initiate support mobj
	B.SpawnTargetDummy(player)
	
	--History
	if player.versusvars == nil then
		player.buttonhistory = player.cmd.buttons
		B.InitPlayer(player)
		player.versusvars = true
	end
	
	--Spectator functions
	B.PreAutoSpectator(player)
	B.SpectatorControl(player)

	--Arena death functions
	A.ForceRespawn(player)
	A.GameOverControl(player)
	
	--Dead control unlock
	if player.playerstate != PST_LIVE then
		player.lockaim = false
		player.lockmove = false
	end
	
	--Spawning, end of round
	if player.playerstate == PST_LIVE then
		--Battle spawn animation
		local spawning = B.PlayerBattleSpawning(player) 
		--Pre Round Setup
		if not(spawning) and B.PreRoundWait()
			B.PlayerSetupPhase(player)
		end
		--Post round invuln
		if B.Exiting
			player.powers[pw_flashing] = TICRATE
		end
	end
	
	--Control inputs
	B.PreGunslinging(player)
	B.InputControl(player)
end

B.PlayerThinkFrame = function(player)
	local pmo = player.mo
	
	if (pmo and pmo.valid) and ((not player.squashstretch) or player.playerstate != PST_LIVE)
		pmo.spritexscale = FRACUNIT
		pmo.spriteyscale = FRACUNIT
		player.squashstretch = nil
	end
	
	--Sanity checks
	if player.versusvars == nil then return end
	if not(pmo and pmo.valid) or player.playerstate != PST_LIVE then return end
	if maptol&(TOL_NIGHTS|TOL_XMAS) then return end
	
	--Shield Stock usage
	B.ShieldStock(player)
	B.ShieldMax(player) --Regulate shield capacity
	
	--Lock-aim
	if player.lockaim then
		player.lockaim = false
		player.drawangle = player.mo.angle
	end
	if player.lockmove then
		player.lockmove = false
	end
	
	--Skinvars
	B.GetSkinVars(player)
	
	--Tumble state
	B.Tumble(player)
	
	--Ability control
	B.GuardControl(player)--Check if guard is allowed
	B.CharAbilityControl(player)--Exhaust and ability behavior
	
	--Update timers/stats
	B.GotFlagStats(player)
	player.charmedtime = max(0,$-1)
	if player.actioncooldown > 0 then
		if player.lastcooldown == nil or player.lastcooldown < player.actioncooldown then
			player.lastcooldown = player.actioncooldown
		end
		player.actioncooldown = max(0,$-1)
		if player.actioncooldown == 0 then
			player.lastcooldown = nil
			S_StartSound(nil, sfx_cddone, player)
		end
	end
	--player.actioncooldown = max(0,$-1)
	B.DoBackdraft(player)
	

	--Special thinkers
	A.JettySynThinker(player)
	A.RingSpill(player)
	B.PlayerMovementControl(player)
	
	--Perform Actions
	local doaction = B.ButtonCheck(player,player.battleconfig_special)
	B.MasterActionScript(player,doaction)
	
	--Air dodge, Stun Break, Guard
	local doguard = B.ButtonCheck(player,player.battleconfig_guard)
	B.StunBreak(player,doguard)
	B.AirDodge(player,doguard)
	B.Guard(player,doguard)
	
	--Abilities
	B.HammerControl(player)
	B.CustomGunslinger(player)
	B.ShieldTossFlagButton(player)
	
	--PvP Collision
	B.DoPriority(player)
	B.DoPlayerInteract(pmo,pmo.pushed)
	B.UpdateRecoilState(pmo)
	B.UpdateCollisionHistory(pmo)
end

B.PlayerPostThinkFrame = function(player)
	player.buttonhistory = player.cmd.buttons
	
	--Lock jump timer
	if player.lockjumpframe then
		player.lockjumpframe = $ - 1
	end

	-- Manage ringhudflash
	if (player.prevrings < player.rings) then
		player.ringhudflash = 3
	elseif (player.prevrings > player.rings) then
		player.ringhudflash = -3
	else
		if (player.ringhudflash > 0) then
			player.ringhudflash = max(0, $ - 1)
		elseif (player.ringhudflash < 0) then
			player.ringhudflash = min(0, $ + 1)
		end
	end
	player.prevrings = player.rings
end