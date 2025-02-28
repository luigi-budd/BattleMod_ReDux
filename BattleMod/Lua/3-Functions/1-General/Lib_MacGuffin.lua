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
        player.mo.pass_indicator.color = ({{SKINCOLOR_PINK,SKINCOLOR_CRIMSON},{SKINCOLOR_AETHER,SKINCOLOR_COBALT}})[player.mo.player.ctfteam][1+(((leveltime/2)%2))]
        player.mo.pass_indicator.renderflags = $|RF_NOCOLORMAPS
        player.mo.pass_indicator.fuse = max($, 2)
        if displayplayer and B.MyTeam(displayplayer, player) then
            player.mo.pass_indicator.flags2 = $ & ~MF2_DONTDRAW
        else
            player.mo.pass_indicator.flags2 = $|MF2_DONTDRAW
        end
    end
end