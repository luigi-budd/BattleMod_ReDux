local B = CBW_Battle

--Player v player projectile
addHook("ShouldDamage", function(target,inflictor,source,something,idk)
	if gamestate ~= GS_LEVEL then return end -- won't work outside a level
	if not(target.player and inflictor and inflictor.valid and source and source.valid and source.player)
	return end
	
	if inflictor.type == MT_SPINFIRE
	and not(target.player.powers[pw_shield]&SH_PROTECTFIRE)
	and not(target.player.powers[pw_flashing] or target.player.powers[pw_super] or target.player.powers[pw_invulnerability])
	and not(B.MyTeam(target.player,source.player))
		return true
	end
end,MT_PLAYER)

--Player v player projectile
for n = 1, #mobjinfo-1 do
	
	local mt = n-1
	local info = mobjinfo[mt]
	
	if info.flags & MF_MISSILE == 0
		continue
	end
	
	addHook("MobjMoveCollide", function(tmthing,thing)
		if not(tmthing and tmthing.valid and tmthing.flags&MF_MISSILE
			and tmthing.target and tmthing.target.valid
			and tmthing.target.player and tmthing.target.player.valid
			and thing and thing.valid and thing.player and thing.player.valid)
			
			return
		end
		--Fix for teammates interacting at all with teammate projectiles
		if B.MyTeam(tmthing.target.player,thing.player)
			and not tmthing.cantouchteam
			return false
		end
		--Projectile intangibility
		if thing.player.intangible
			return false
		end
	end, mt)
	
	addHook("MobjThinker",function(mo) 
		if not(mo and mo.valid and mo.flags & MF_MISSILE) then return end
		--Master underwater/2D check
		B.UnderwaterMissile(mo)
		B.TwoDMissile(mo)
	end, mt)
	
end



--Sonic ground pound
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit00
	mo.block_stun = 4
	mo.block_sound = sfx_s3k49
	mo.block_hthrust = 2
	mo.block_vthrust = 6
end,MT_GROUNDPOUND)


--Tails Projectiles
addHook("MobjThinker",function(mo)
	if not(mo.flags&MF_MISSILE) then return end
	local ghost = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_GHOST)
		ghost.color = mo.color
		ghost.fuse = TICRATE/4
		ghost.state = mo.state
		ghost.sprite = mo.sprite
		ghost.frame =  mo.frame
		ghost.frame = $|TR_TRANS50|FF_FULLBRIGHT 
		ghost.tics = -1

	if mo.radius < (32*FRACUNIT) then
		mo.radius = $+FRACUNIT
	end

	if mo.radius < (32*FRACUNIT) then
		mo.radius = $+FRACUNIT
	end
	
	if not (mo.valid) then return end

	P_Thrust(mo,R_PointToAngle2(0,0,mo.momx,mo.momy) + ANGLE_180,R_PointToDist2(0,0,mo.momx,mo.momy) / 16)
	P_SetObjectMomZ(mo, -mo.momz/32, true)

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
end,MT_SONICBOOM)

addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit02
end,MT_SONICBOOM)


--Knux rocks
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit00
	mo.blockable = 1
	mo.block_stun = 2
	mo.block_sound = sfx_s3k49
	mo.block_hthrust = 3
	mo.block_vthrust = 3
end,MT_ROCKBLAST)


--Amy love hearts
addHook("MobjSpawn",function(mo)
	if mo.valid
		mo.hit_sound = sfx_hit03
		mo.cantouchteam = true
		mo.blockable = 1
		mo.block_stun = 3
		--mo.block_sound = sfx_s3kb5
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
		--mo.block_sound = sfx_s3kb5
		mo.block_hthrust = 7
		mo.block_vthrust = 5
		mo.spawnfire = true
	end
end,MT_PIKOWAVEHEART)
addHook("MobjMoveCollide", function(mover,collide) if collide and (collide.battleobject or not(collide.flags&MF_SOLID)) then return end end, MT_PIKOWAVE)
addHook("MobjMoveBlocked", function(mo)
	--mo.fuse = max(1, $ - 9)
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


--Piko tornado
addHook("TouchSpecial",B.DustDevilTouch,MT_DUSTDEVIL)
addHook("MobjMoveCollide",function(mover,collide)
	if not(collide.battleobject) then return end
	B.DustDevilTouch(mover,collide)
end,MT_DUSTDEVIL)
addHook("MobjThinker",B.DustDevilThinker, MT_DUSTDEVIL_BASE)
addHook("MobjSpawn",B.SwirlSpawn,MT_SWIRL)
addHook("MobjThinker",B.SwirlThinker, MT_SWIRL)
addHook("MobjSpawn",B.DustDevilSpawn,MT_DUSTDEVIL_BASE)


--Fang
addHook("MobjSpawn",function(mo)
	if mo.valid
		mo.hit_sound = sfx_hit04
		mo.blockable = 1
		mo.block_stun = 5
		--mo.block_sound = sfx_s3kb5
		mo.block_hthrust = 12
		mo.block_vthrust = 10
		mo.spawnfire = true
	end
	return true --Overwrite default behavior so that corks won't damage invulnerable players
end,MT_CORK)
addHook("MobjThinker",function(mo)
	if mo.flags&MF_MISSILE and mo.target and mo.target.player then
		local ghost = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_GHOST)
		ghost.fuse = TICRATE/4
		ghost.state = mo.state
		ghost.sprite = mo.sprite
		ghost.frame =  mo.frame
		ghost.frame = $|TR_TRANS50 
		ghost.tics = -1
		ghost.destscale = ghost.scale*4
		if not(gametyperules&GTR_FRIENDLY)
			ghost.colorized = true
			ghost.color = mo.target.player.skincolor
		end
	end
end,MT_CORK)


--Metal Sonic
addHook("MobjThinker",function(mo)
	mo.flags2 = $^^MF2_DONTDRAW
end,MT_SLASH)
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit02
	mo.blendmode = AST_ADD
end,MT_SLASH)
addHook("MobjSpawn",function(mo)
	mo.hit_sound = sfx_hit01
end,MT_ENERGYBLAST)

addHook("MobjSpawn",function(mo)
	mo.flags2 = MF2_INVERTAIMABLE
end,MT_BOMBSPHERE)

--addHook("MobjCollide",B.BombSphereMissileCollide,MT_BOMBSPHERE)
--addHook("TouchSpecial",B.BombSphereTouch,MT_BOMBSPHERE)
addHook("MobjFuse",B.FBombDetonate,MT_FBOMB)
addHook("MobjMoveCollide",B.BombCollide,MT_FBOMB)
addHook("MobjSpawn",B.FBombSpawn,MT_FBOMB)
addHook("MobjThinker",B.FBombThink,MT_FBOMB)

--Other
addHook("MobjThinker",B.RockBlastObject,MT_ROCKBLAST)
addHook("MobjThinker",function(mo) if P_IsObjectOnGround(mo) then P_RemoveMobj(mo) return true end end,MT_ROCKCRUMBLE2)
addHook("ShouldDamage", B.PlayerCorkDamage, MT_PLAYER)
addHook("ShouldDamage", B.PlayerHeartCollision, MT_PLAYER)
addHook("ShouldDamage", B.PlayerBombDamage,MT_PLAYER)
addHook("ShouldDamage", B.PlayerRoboMissileCollision,MT_PLAYER)
addHook("MobjThinker", function(mo) mo.fuse = min($, TICRATE * 4) end,MT_SPINFIRE)
--Other
addHook("MobjThinker",B.RockBlastObject,MT_ROCKBLAST)
addHook("MobjThinker",function(mo) if P_IsObjectOnGround(mo) then P_RemoveMobj(mo) return true end end,MT_ROCKCRUMBLE2)
addHook("ShouldDamage", B.PlayerCorkDamage, MT_PLAYER)
addHook("ShouldDamage", B.PlayerHeartCollision, MT_PLAYER)
addHook("ShouldDamage", B.PlayerBombDamage,MT_PLAYER)
addHook("ShouldDamage", B.PlayerRoboMissileCollision,MT_PLAYER)
addHook("MobjThinker", B.TeamFireTrail,MT_SPINFIRE)
