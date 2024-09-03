local B = CBW_Battle

addHook("MobjThinker", B.BattleShieldThinker, MT_BATTLESHIELD)
addHook("MobjThinker", B.NegaShieldThinker, MT_NEGASHIELD)
addHook("MobjThinker", B.InstaFlip, MT_INSTASHIELD)
addHook("MobjThinker", B.StunBreakVFXThinker, MT_STUNBREAK)

addHook("MobjThinker",function(mo) B.EnergyGather(mo,mo.target,mo.extravalue1,mo.extravalue2) end,MT_ENERGYGATHER)
addHook("MobjThinker", B.TargetDummyThinker, MT_TARGETDUMMY)
addHook("MobjThinker",function(mo) B.MetalAura(mo,mo.target) end, MT_ENERGYAURA)
addHook("MobjThinker", function(mo) 
	if mo and mo.valid and mo.target and mo.target.valid then
		B.SparkAura(mo, mo.target) 
	end
end, MT_RINGSPARKAURA)

//Shields (yeah, this is pretty messy...)
local colorsh = function(mo, redcol, bluecol)
	B.OverlayHide(mo,mo.target)
	
	if mo.colorized return end
	local target = mo.target
	if target and target.valid and not target.player and target.target and target.target.player
		target = target.target
	end
	
	if not (G_GametypeHasTeams() and target and target.valid and target.player and target.player.valid and target.player.ctfteam)
		return
	end
	
	if (target.player.ctfteam == 1) and redcol
		mo.color = redcol
		mo.colorized = true
		return
		
	elseif (target.player.ctfteam == 2) and bluecol
		mo.color = bluecol
		mo.colorized = true
		return
	end
end

local colorsh2 = function(mo)
	if mo.state >= S_ARMA1 and mo.state <= S_ARMB32
		colorsh(mo,nil,SKINCOLOR_PURPLE)
		return
	end
	if mo.state >= S_ZAPS1 and mo.state <= S_ZAPSB11
		colorsh(mo,SKINCOLOR_SUPERRED3,SKINCOLOR_SUPERSKY2)
		return
	end
	if mo.state >= S_FIRS1 and mo.state <= S_FIRSB10
		colorsh(mo,nil,SKINCOLOR_CYAN)
		return
	end
	if mo.state >= S_BUBS1 and mo.state <= S_BUBSB6
		colorsh(mo,SKINCOLOR_SUPERGOLD1,nil)
		return
	end
	B.OverlayHide(mo,mo.target)
end

B.RestoreTailsFollowMobj = function(p, mobj) -- cry
	if not (p and p.mo and p.mo.skin == "tails") then return end
	if (mobj == nil) then mobj = p.followmobj end
	if not (mobj) then return end

	if p.mo.state == S_PLAY_LEDGE_GRAB 
	or p.mo.state == S_PLAY_LEDGE_RELEASE
        mobj.state = S_TAILSOVERLAY_PLUS60DEGREES
		P_MoveOrigin(mobj,
		p.mo.x-P_ReturnThrustX(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustX(mobj, mobj.angle, mobj.scale),
		p.mo.y-P_ReturnThrustY(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustY(mobj, mobj.angle, mobj.scale),
		p.mo.z+FixedMul(4*p.mo.scale, mobj.scale)
		)
		mobj.angle = p.drawangle
		return true
    end

	if mobj.state == S_INVISIBLE
		mobj.state = S_TAILSOVERLAY_PLUS30DEGREES
	end

	if (p.skidtime or mobj.restorebuffer)
	and P_IsValidSprite2(mobj, SPR2_WALK)
		mobj.state = S_TAILSOVERLAY_PLUS30DEGREES
		mobj.frame = 512 + min(7,1+p.speed/(p.mo.scale*2))
		P_MoveOrigin(mobj,
		p.mo.x-P_ReturnThrustX(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustX(mobj, mobj.angle, mobj.scale),
		p.mo.y-P_ReturnThrustY(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustY(mobj, mobj.angle, mobj.scale),
		p.mo.z+FixedMul(2*p.mo.scale, mobj.scale)
		)
		mobj.angle = p.drawangle
		mobj.restorebuffer = p.skidtime --+1 frame
		if leveltime%3 == 1
			S_StartSound(mobj,sfx_s3k7e)
		end
		return true
	end
end
addHook("FollowMobj", B.RestoreTailsFollowMobj, MT_TAILSOVERLAY)

addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_CRIMSON,nil) end,MT_ELEMENTAL_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_ORANGE,SKINCOLOR_VAPOR) end,MT_ATTRACT_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_FLAME,SKINCOLOR_SKY) end,MT_WHIRLWIND_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,nil) end,MT_FORCE_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,nil,SKINCOLOR_BLUE) end,MT_ARMAGEDDON_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,nil,SKINCOLOR_DUSK) end,MT_FLAMEAURA_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,nil) end,MT_BUBBLEWRAP_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,SKINCOLOR_SAPPHIRE) end,MT_THUNDERCOIN_ORB)
addHook("MobjThinker", colorsh2,MT_OVERLAY)

B.PityThinker = function(mo) 
	B.OverlayHide(mo,mo.target)
	if gametyperules&GTR_PITYSHIELD or G_GametypeHasTeams()
		local owner = mo.target
		if not(owner and owner.valid and owner.player and owner.player.valid) then return nil end
		mo.color = owner.player.skincolor
		mo.colorized = true
	else
		mo.color = SKINCOLOR_CERULEAN
	end
end
addHook("MobjThinker", B.PityThinker,MT_PITY_ORB)

B.SpinDustThinker = function(mo)
	if mo.changed then
		return
	end
	if (mo.state == S_SPINDUST_FIRE1)
	and (mo.target and mo.target.valid and mo.target.player)
	then
		mo.color = mo.target.player.skincolor
		mo.state = S_TEAMFIRE1
		mo.frame = $|FF_ANIMATE|FF_TRANSMASK
		mo.fuse = TICRATE/2
		mo.destscale = 0
		mo.scalespeed = $/2
		mo.changed = true
	end
end
addHook("MobjThinker", B.SpinDustThinker, MT_SPINDUST)

//visual indicator for tagger
local function BattleTagITtag(mo)
	if gametype != GT_BATTLETAG or mo.tracerplayer == nil or not 
			mo.tracerplayer.valid or not mo.tracerplayer.battletagIT
		P_RemoveMobj(mo)
		return
	end
	
	local tracer = mo.tracerplayer.mo
	if tracer != nil and tracer.valid
		mo.flags2 = $ & ~MF2_DONTDRAW
		mo.scale = tracer.scale
		mo.eflags = tracer.eflags
		local zheight
		if tracer.eflags & MFE_VERTICALFLIP
			zheight = tracer.height / 2 * -1
		else
			zheight = tracer.height + tracer.height / 3
		end
		P_MoveOrigin(mo, tracer.x, tracer.y, tracer.z + zheight)
	else
		mo.flags2 = $ | MF2_DONTDRAW
	end
end
addHook("MobjThinker", BattleTagITtag, MT_BATTLETAG_IT)

//thinker for pointer
local function BattleTagPointers(mo)
	if not B.IsValidPlayer(mo.tracer) or not B.IsValidPlayer(mo.target) or
			not mo.tracer.player.battletagIT or mo.target.player.battletagIT
		P_RemoveMobj(mo)
		return
	end
	
	//change the appearance based on perspective
	local cam
	if displayplayer == mo.tracer.player
		cam = camera
	elseif secondarydisplayplayer == mo.tracer.player
		cam = camera2
	end
	if cam != nil
		if cam.chase
			mo.frame = $ | FF_PAPERSPRITE & ~FF_FLOORSPRITE
			mo.renderflags = $ & ~RF_NOSPLATBILLBOARD
			mo.spriteroll = ANGLE_270
		else
			mo.frame = $ | FF_FLOORSPRITE & ~FF_PAPERSPRITE
			mo.renderflags = $ | RF_NOSPLATBILLBOARD
			mo.spriteroll = 0
		end
	end
	mo.drawonlyforplayer = mo.tracer.player
	mo.color = mo.target.player.skincolor
	local x = mo.tracer.x
	local y = mo.tracer.y
	local z = mo.tracer.z
	local rx = mo.target.x
	local ry = mo.target.y
	local rz = mo.target.z
	//keep track of how close the targeted runner is
	local h_dist = R_PointToDist2(x, y, rx, ry)
	mo.closedist = R_PointToDist2(0, z, h_dist, rz)
	//point towards the targeted runner
	mo.angle = R_PointToAngle2(x, y, rx, ry)
	local hight = mo.tracer.height / 2
	if mo.tracer.eflags & MFE_VERTICALFLIP
		hight = 0
	end
	P_MoveOrigin(mo, x + P_ReturnThrustX(mo, mo.angle, 75 * mo.tracer.scale), 
			y + P_ReturnThrustY(mo, mo.angle, 75 * mo.tracer.scale), z + hight)
	//change the appearance based on distance of targeted runner
	mo.frame = $ & ~FF_TRANSMASK
	local blink
	if mo.closedist <= 100 * FRACUNIT
		blink = 1
	elseif mo.closedist <= 1000 * FRACUNIT
		mo.scale = mo.tracer.scale
		blink = 3
		mo.frame = $ | FF_TRANS10
	elseif mo.closedist <= 3000 * FRACUNIT
		mo.scale = mo.tracer.scale - (mo.tracer.scale / 4)
		blink = 6
		mo.frame = $ | FF_TRANS30
	elseif mo.closedist <= 7500 * FRACUNIT
		mo.scale = mo.tracer.scale / 2
		blink = 12
		mo.frame = $ | FF_TRANS50
	else
		mo.scale = mo.tracer.scale / 4
		blink = 24
		mo.frame = $ | FF_TRANS70
	end
	if leveltime % blink == 0
		if blink == 1
			mo.flags2 = $ | MF2_DONTDRAW
		else
			mo.flags2 = $ & ~MF2_DONTDRAW
			if mo.frame & FF_ADD
				mo.frame = $ & ~FF_ADD
			else
				mo.frame = $ | FF_ADD
			end
		end
	end
end
addHook("MobjThinker", BattleTagPointers, MT_BTAG_POINTER)