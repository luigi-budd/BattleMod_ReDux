local B = CBW_Battle

local applyFlip = function(mo1, mo2)
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

B.MacGuffinPass = function(player) --PreThinkFrame (For Tossflag)
    if not(G_GametypeHasTeams()) then return end
    local btns = player.cmd.buttons

    local zpos = player.mo.z+(player.mo.height+(player.mo.scale*10))

    local frame = _G["A"]
    local mirrored = false

    if P_MobjFlip(player.mo) == -1 then
        zpos = (player.mo.z+player.mo.height)-(player.mo.height+(player.mo.scale*10))
    end

    local doflip = false

    local flipfunc = function(screenplayer, flipcam)
        local flippedpassplayer = P_MobjFlip(player.mo)==-1
        local flippedscreenplayer = P_MobjFlip(screenplayer.mo)==-1
        --local flipcam = CV_FindVar('flipcam').value

        if flipcam then
            if (P_MobjFlip(player.mo)+P_MobjFlip(screenplayer.mo)) == 0 --Mismatched flips, with flipcam?
                doflip = true --Flip it so it's readable
            end
        else
            if flippedpassplayer then 
                doflip = true --Always flip it if the camera is never going to be flipped
            end
        end
    end

    local skipflip = false


    if not(splitscreen) then
        local screenplayer = displayplayer
        if screenplayer and screenplayer.mo and screenplayer.mo.valid then
            flipfunc(screenplayer, CV_FindVar("flipcam").value)
        end
    end
    

    if doflip then
        frame = _G["B"]
        mirrored = true
    end

    if not(player.mo.pass_indicator and player.mo.pass_indicator.valid) then
        player.mo.pass_indicator = P_SpawnMobj(player.mo.x, player.mo.y, zpos, MT_PARTICLE)
        player.mo.pass_indicator.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP|MF_NOCLIP
        player.mo.pass_indicator.flags2 = $|MF2_DONTDRAW
        player.mo.pass_indicator.fuse = -1
        applyFlip(player.mo, player.mo.pass_indicator)
        return
    end
    if (player.mo.pass_indicator and player.mo.pass_indicator.valid) then
        applyFlip(player.mo, player.mo.pass_indicator)
            player.mo.pass_indicator.mirrored = mirrored
        P_MoveOrigin(player.mo.pass_indicator, player.mo.x, player.mo.y, zpos)
        player.mo.pass_indicator.scale = player.mo.scale-(player.mo.scale/4)
        player.mo.pass_indicator.frame = frame|FF_FULLBRIGHT
        player.mo.pass_indicator.sprite = SPR_MACGUFFIN_PASS
        player.mo.pass_indicator.color = ({{SKINCOLOR_PINK,SKINCOLOR_CRIMSON},{SKINCOLOR_AETHER,SKINCOLOR_COBALT}})[player.ctfteam][1+(((leveltime/2)%2))]
        player.mo.pass_indicator.renderflags = $|RF_NOCOLORMAPS
        player.mo.pass_indicator.fuse = max($, 2)
        if displayplayer and B.MyTeam(displayplayer, player) then
            player.mo.pass_indicator.flags2 = $ & ~MF2_DONTDRAW
        else
            player.mo.pass_indicator.flags2 = $|MF2_DONTDRAW
        end
    end
end

B.MacGuffinClaimed = function(mo, customdist, addxy, nofloat)
    mo.flags = ($&~MF_BOUNCE)|MF_NOGRAVITY|MF_SLIDEME
	local t = mo.target
	local ang = mo.angle
	local dist = customdist or mo.target.radius*3
	local x = t.x+P_ReturnThrustX(mo,ang,dist)
	local y = t.y+P_ReturnThrustY(mo,ang,dist)
    if addxy == nil then
        addxy = t.player and t.player.deadtimer
    end
    if addxy then
        x = $ + t.momx
        y = $ + t.momy
    end
	local z = t.z+abs(leveltime&63-31)*FRACUNIT/2 -- Gives us a hovering effect
	if P_MobjFlip(t) == 1 -- Make sure our vertical orientation is correct
		mo.flags2 = $&~MF2_OBJECTFLIP
	else
-- 		z = $+t.height
		mo.flags2 = $|MF2_OBJECTFLIP
	end
	P_MoveOrigin(mo,t.x,t.y,t.z)
	P_InstaThrust(mo,R_PointToAngle2(mo.x,mo.y,x,y),min(FRACUNIT*60,R_PointToDist2(mo.x,mo.y,x,y)))
	if not nofloat then
        mo.z = max(mo.floorz,min(mo.ceilingz+mo.height,z)) -- Do z pos while respecting level geometry
    end
end

B.HomingDeflect = function(player, target)
    if player and player.lasthoming
    and leveltime - player.lasthoming < TICRATE/5
    then
        if not player.powers[pw_flashing] then
            local mo = player.mo
            S_StartSound(mo, sfx_deflct)
            mo.momx = -$*2/3
            mo.momy = -$*2/3
            local s = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_BATTLESHIELD)
		    s.scale = s.scale*3
		    s.colorized = true
		    s.color = SKINCOLOR_BONE
        end
        return true
    end
end