/*Note: See Exec_System.lua for player functions in hooks:
	PreThinkFrame
	ThinkFrame
	PostThinkFrame
*/

local B = CBW_Battle
local A = B.Arena
local CV = B.Console
//Handle player spawning
addHook("PlayerSpawn",function(player) 
	//Init vars
	B.InitPlayer(player) 
	B.InitPriority(player)
	//Do music
	if not(B.OvertimeMusic(player)) then
		B.PinchMusic(player)
	end
	//Conditional spawn settings
	B.SpawnWithShield(player)
	A.StartRings(player)
	B.RestoreColors(player)
	B.ResetPlayerProperties(player)
	B.PlayerBattleSpawnStart(player)
end)

//Handle player vs player collision
addHook("TouchSpecial", B.PlayerTouch,MT_PLAYER)

//Control ability usage
addHook("AbilitySpecial",function(player)
	if not(B.MidAirAbilityAllowed(player)) then return true end
	//Fix metal sonic shield stuff
	if player.charability == CA_FLOAT
		and ((player.mo and player.mo.valid and (player.mo.state == S_PLAY_ROLL)) or player.secondjump == UINT8_MAX)
		return true
	end
end)

addHook("ShieldSpecial", do	return true end)

addHook("JumpSpecial",function(player)
	if (player.powers[pw_carry]) return end
	if not(player.buttonhistory&BT_JUMP)
		if B.TwinSpin(player) return true end
	end
end)

addHook("SpinSpecial",function(player)
	if (player.powers[pw_carry]) return end
	if not(player.buttonhistory&BT_USE)
		if B.TwinSpin(player) return true end
	end
end)

//Player against Player damage
addHook("ShouldDamage", function(target,inflictor,source,damage,other)
	if not(inflictor and inflictor.valid and inflictor.player and inflictor != target)
	return end
	if not(target.player and not(B.MyTeam(target.player,source.player)))
	return end
	if not(B.PlayerCanBeDamaged(target.player) or inflictor.flags2&MF2_SUPERFIRE)
	return end
	return true
end,MT_PLAYER)

//Remove targetdummy false positives
addHook("ShouldDamage", function(target,inflictor)
	if inflictor and inflictor.valid and inflictor.type == MT_TARGETDUMMY then return false end
end,MT_PLAYER)

//Armaggeddon blast
addHook("ShouldDamage", function(target,inflictor,source,damage,other)
	B.DamageTargetDummy(target,inflictor,source,damage,other)
	return false
end,MT_TARGETDUMMY)

//Damage triggered
addHook("MobjDamage",function(target,inflictor,source, damage,damagetype)
	if not(target.player) then return end
	//Do guarding
	if B.GuardTrigger(target, inflictor, source, damage, damagetype) then return true end
	//Handle damage dealt/received by revenge jettysyns
	A.RevengeDamage(target,inflictor,source)
	//Establish enemy player as the last pusher (for hazard kills)
	B.PlayerCreditPusher(target.player,inflictor)
	B.PlayerCreditPusher(target.player,source)
	
	local player = target.player
	if player and player.valid and (player.powers[pw_shield] & SH_NOSTACK) == SH_ARMAGEDDON//no more arma revenge boom
		player.powers[pw_shield] = SH_PITY
	end
end,MT_PLAYER)

//Player death
addHook("MobjDeath",function(target,inflictor,source,damagetype)
	local killer
	local player = target.player
	
	//Standard kill
	if inflictor and inflictor.player
		killer = inflictor.player
	elseif source and source.player
		killer = source.player
	end
	
	//Player was pushed into a death hazard
	if player and (damagetype == DMG_DEATHPIT or damagetype == DMG_CRUSHED)
		and player.pushed_creditplr and player.pushed_creditplr.valid and not(B.MyTeam(player,player.pushed_creditplr))
		then
		killer = player.pushed_creditplr
		P_AddPlayerScore(player.pushed_creditplr,50)
		B.DebugPrint(player.pushed_creditplr.name.." received 50 points for sending "..player.name.." to their demise")
	end
	//Player ran out of lives in Survival mode
	if player.lives == 1 and B.BattleGametype() and G_GametypeUsesLives()
		B.PrintGameFeed(player," ran out of lives!")
		A.GameOvers = $+1
	end
	//Death time penalty
	if B.BattleGametype() 
		if not(B.PreRoundWait())
			if not(G_GametypeUsesLives())
				player.deadtimer = -(1+min(CV.RespawnTime.value-3,player.respawnpenalty*2))*TICRATE
				player.respawnpenalty = $+1
			elseif player.lives == 1 and CV.Revenge.value
				player.deadtimer = (2-10-(player.respawnpenalty)*2)*TICRATE
				player.respawnpenalty = $+1
			end
		elseif B.PreRoundWait()
			player.deadtimer = TICRATE*3
		end
	end
	A.KillReward(killer)
	
	player.spectatortime = player.deadtimer -TICRATE*3
end, MT_PLAYER)

//Disallow revenge jettysyns and spawning players from collecting items
addHook("TouchSpecial",function(special,pmo)
	if not(pmo.player) then return end //player check
	if B.PreRoundWait() then return true end //in preround phase
	if pmo.player.battlespawning then return true end //player is spawning
	if special.player then return end //player collisions are excluded here
	if (pmo.player.revenge or pmo.player.isjettysyn) then return true end //player is jettysyn
end,MT_NULL)