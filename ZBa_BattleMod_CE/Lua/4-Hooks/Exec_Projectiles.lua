local B = CBW_Battle

//Player v player projectile
addHook("ShouldDamage", function(target,inflictor,source,something,idk)
	if not(target.player and inflictor and inflictor.valid and source and source.valid and source.player)
	return end
	//Fix for erroneous ring adding
	if inflictor.flags&MF_MISSILE
		and source and source.valid and source.player and B.MyTeam(target.player,source.player)
		then target.player.rings = $-1
	return end
	//Fire trail fix
-- 	print(inflictor.type,target.player.powers[pw_shield]&SH_PROTECTFIRE,B.MyTeam(target.player,source.player))
	if inflictor.type == MT_SPINFIRE
	and not(target.player.powers[pw_shield]&SH_PROTECTFIRE)
	and not(target.player.powers[pw_flashing] or target.player.powers[pw_super])
	and not(B.MyTeam(target.player,source.player))
	return true end
end,MT_PLAYER)

//Master underwater/2D check
addHook("MobjThinker",function(mo) 
	if not(mo and mo.valid) then return end
	if mo.flags&MF_MISSILE then
		B.UnderwaterMissile(mo)
		B.TwoDMissile(mo)
	end
end,MT_NULL)


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
end,MT_SONICBOOM)

//Amy Projectiles
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

//Other
addHook("MobjThinker",B.RockBlastObject,MT_ROCKBLAST)
addHook("MobjThinker",function(mo) if P_IsObjectOnGround(mo) then P_RemoveMobj(mo) return true end end,MT_ROCKCRUMBLE2)
addHook("ShouldDamage", B.PlayerCorkDamage, MT_PLAYER)
addHook("ShouldDamage", B.PlayerHeartCollision, MT_PLAYER)
addHook("ShouldDamage",B.PlayerBombDamage,MT_PLAYER)
addHook("ShouldDamage",B.PlayerRoboMissileCollision,MT_PLAYER)
addHook("MobjThinker",B.TeamFireTrail,MT_SPINFIRE)