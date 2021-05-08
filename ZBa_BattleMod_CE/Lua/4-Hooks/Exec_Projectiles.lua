local B = CBW_Battle

//Player v player projectile
addHook("ShouldDamage", function(target,inflictor,source,something,idk)
	if not(target.player and inflictor and inflictor.valid and source and source.valid and source.player)
	return end
	
	if inflictor.type == MT_SPINFIRE
	and not(target.player.powers[pw_shield]&SH_PROTECTFIRE)
	and not(target.player.powers[pw_flashing] or target.player.powers[pw_super] or target.player.powers[pw_invulnerability])
	and not(B.MyTeam(target.player,source.player))
		return true
	end
end,MT_PLAYER)

//Player v player projectile
addHook("MobjMoveCollide", function(tmthing,thing)
	if not(tmthing and tmthing.valid and tmthing.flags&MF_MISSILE
		and tmthing.target and tmthing.target.valid
		and tmthing.target.player and tmthing.target.player.valid
		and thing and thing.valid and thing.player and thing.player.valid)
		
		return
	end
	//Fix for teammates interacting at all with teammate projectiles
	if tmthing.flags&MF_MISSILE
		and B.MyTeam(tmthing.target.player,thing.player)
		and not tmthing.cantouchteam
		return false
	end
end)

//Master underwater/2D check
addHook("MobjThinker",function(mo) 
	if not(mo and mo.valid) then return end
	if mo.flags&MF_MISSILE then
		B.UnderwaterMissile(mo)
		B.TwoDMissile(mo)
	end
end,MT_NULL)


//Sonic ground pound
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit00
	mo.blockable = 1
	mo.block_stun = 4
	mo.block_sound = sfx_s3k49
	mo.block_hthrust = 2
	mo.block_vthrust = 6
end,MT_GROUNDPOUND)


//Tails Projectiles
addHook("MobjThinker",function(mo)
	if not(mo.flags&MF_MISSILE) then return end
	P_SpawnGhostMobj(mo)
	local radius = mo.radius/FRACUNIT
	local r = do
		return P_RandomRange(-radius,radius)*FRACUNIT
	end
	local s = P_SpawnMobjFromMobj(mo,r(),r(),0,MT_SPARK)
	s.scale = $*3/4
	if P_RandomRange(0,1) then
		s.colorized = true
		s.color = SKINCOLOR_SKY
	end
	P_Thrust(mo,R_PointToAngle2(0,0,mo.momx,mo.momy) + ANGLE_180,R_PointToDist2(0,0,mo.momx,mo.momy) / 16)
end,MT_SONICBOOM)

addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit02
end,MT_SONICBOOM)


//Knux rocks
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit00
	mo.blockable = 1
	mo.block_stun = 2
	mo.block_sound = sfx_s3k49
	mo.block_hthrust = 3
	mo.block_vthrust = 3
end,MT_ROCKBLAST)


//Amy love hearts
addHook("MobjSpawn",function(mo)
	if mo.valid
		mo.hit_sound = sfx_hit03
		mo.cantouchteam = true
		mo.blockable = 1
		mo.block_stun = 3
		//mo.block_sound = sfx_s3kb5
		mo.block_hthrust = 6
		mo.block_vthrust = 2
		mo.spawnfire = true
	end
end,MT_LHRT)
addHook("MobjSpawn",function(mo)
	if mo.valid
		mo.hit_sound = sfx_hit03
		mo.cantouchteam = true
		mo.blockable = 1
		mo.block_stun = 6
		//mo.block_sound = sfx_s3kb5
		mo.block_hthrust = 7
		mo.block_vthrust = 5
		mo.spawnfire = true
	end
end,MT_PIKOWAVEHEART)
addHook("MobjMoveCollide", function(mover,collide) if collide and (collide.battleobject or not(collide.flags&MF_SOLID)) then return end end, MT_PIKOWAVE)
addHook("MobjMoveBlocked", function(mo)
	//mo.fuse = max(1, $ - 9)
	S_StartSound(mo,sfx_nbmper)
end, MT_PIKOWAVE)
addHook("MobjThinker", function(mo)
	if mo.grow
		mo.scale = $ + FRACUNIT/45
	end
	mo.momx = $ * mo.friction / 100
	mo.momy = $ * mo.friction / 100
	mo.momz = $ - (P_MobjFlip(mo) * mo.scale)
end, MT_PIKOWAVEHEART)
addHook("MobjThinker", B.PikoWaveThinker, MT_PIKOWAVE)


//Piko tornado
addHook("TouchSpecial",B.DustDevilTouch,MT_DUSTDEVIL)
addHook("MobjMoveCollide",function(mover,collide)
	if not(collide.battleobject) then return end
	B.DustDevilTouch(mover,collide)
end,MT_DUSTDEVIL)
addHook("MobjThinker",B.DustDevilThinker, MT_DUSTDEVIL_BASE)
addHook("MobjSpawn",B.SwirlSpawn,MT_SWIRL)
addHook("MobjThinker",B.SwirlThinker, MT_SWIRL)
addHook("MobjSpawn",B.DustDevilSpawn,MT_DUSTDEVIL_BASE)


//Fang
addHook("MobjSpawn",function(mo)
	if mo.valid
		mo.hit_sound = sfx_hit04
		mo.blockable = 1
		mo.block_stun = 5
		//mo.block_sound = sfx_s3kb5
		mo.block_hthrust = 12
		mo.block_vthrust = 10
		mo.spawnfire = true
	end
	return true //Overwrite default behavior so that corks won't damage invulnerable players
end,MT_CORK)
addHook("MobjThinker",function(mo)
	if mo.flags&MF_MISSILE and mo.target and mo.target.player then
		local ghost = P_SpawnGhostMobj(mo)
		ghost.destscale = ghost.scale*4
		if not(gametyperules&GTR_FRIENDLY)
			ghost.colorized = true
			ghost.color = mo.target.player.skincolor
		end
	end
end,MT_CORK)


//Metal Sonic
addHook("MobjSpawn",B.DashSlicerSpawn,MT_DASHSLICER)
addHook("MobjThinker",B.DashSlicerThinker,MT_DASHSLICER)
addHook("MobjThinker",function(mo)
	mo.flags2 = $^^MF2_DONTDRAW
end,MT_SLASH)
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit02
end,MT_SLASH)
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit01
end,MT_ENERGYBLAST)

//Other
addHook("MobjThinker",B.RockBlastObject,MT_ROCKBLAST)
addHook("MobjThinker",function(mo) if P_IsObjectOnGround(mo) then P_RemoveMobj(mo) return true end end,MT_ROCKCRUMBLE2)
addHook("ShouldDamage", B.PlayerCorkDamage, MT_PLAYER)
addHook("ShouldDamage", B.PlayerHeartCollision, MT_PLAYER)
addHook("ShouldDamage", B.PlayerBombDamage,MT_PLAYER)
addHook("ShouldDamage", B.PlayerRoboMissileCollision,MT_PLAYER)
addHook("MobjThinker", B.TeamFireTrail,MT_SPINFIRE)