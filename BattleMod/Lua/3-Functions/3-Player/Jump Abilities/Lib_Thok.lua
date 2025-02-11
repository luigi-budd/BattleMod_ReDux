local B = CBW_Battle

local spawncircle = function(mo)
    local circle = P_SpawnMobjFromMobj(mo, 0, 0, P_MobjFlip(mo)*(mo.scale * 24), MT_THOK)
    circle.sprite = SPR_STAB
    circle.frame = TR_TRANS50|FF_PAPERSPRITE|A
    circle.angle = mo.angle + ANGLE_90
    circle.fuse = 7
    circle.scale = mo.scale / 3
    circle.colorized = true
    circle.color = mo.color
    return circle
end

B.UncappedThok = function(player, mo)
    if player.pflags&PF_THOKKED then return true end
    local xyspd = FixedHypot(mo.momx, mo.momy)
    local actionspd = FixedMul(mo.scale, player.actionspd) / B.WaterFactor(mo)

    if xyspd > actionspd then
        S_StartSound(mo, sfx_thok)
        S_StartSound(mo, sfx_dash)
        if (player == displayplayer) then
            P_StartQuake(9*FRACUNIT, 2)
        end
        local circle1 = spawncircle(mo)
        circle1.fuse = $ + 3
        circle1.destscale = circle1.scale * 2
        circle1.scalespeed = circle1.destscale / circle1.fuse
        local circle2 = spawncircle(mo)
        circle2.blendmode = AST_ADD
    else
        S_StartSound(mo, sfx_thok)
        P_SpawnThokMobj(player)
    end
    P_InstaThrust(mo, mo.angle, max(actionspd, xyspd))
    player.drawangle = mo.angle
    
    player.pflags = $|PF_THOKKED &~ PF_SPINNING
    return true
end