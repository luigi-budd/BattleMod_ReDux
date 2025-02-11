local B = CBW_Battle

B.UncappedThok = function(player, mo)
    if player.pflags&PF_THOKKED then return true end
    local actionspd = FixedMul(mo.scale, player.actionspd) / B.WaterFactor(mo)
    
    if (player.speed > player.normalspeed*3) then
        P_InstaThrust(mo, mo.angle, max(actionspd,player.speed-mo.momz))
    else
        P_InstaThrust(mo, mo.angle, max(actionspd,player.speed))
    end
    
    S_StartSound(mo, sfx_thok)
    if player.speed > (actionspd+FRACUNIT) then
        local circle = P_SpawnMobjFromMobj(mo, 0, 0, P_MobjFlip(mo)*(mo.scale * 24), MT_THOK)
        circle.sprite = SPR_STAB
        circle.frame = TR_TRANS50|FF_PAPERSPRITE|_G["A"]
        circle.angle = mo.angle + ANGLE_90
        circle.fuse = 7
        circle.scale = mo.scale / 3
        circle.destscale = 10*mo.scale
        circle.colorized = true
        circle.color = mo.color
        circle.momx = -mo.momx / 2
        circle.momy = -mo.momy / 2
        S_StartSound(mo, sfx_dash)
        if (player == displayplayer) then
            P_StartQuake(9*FRACUNIT, 2)
        end
    else
        P_SpawnThokMobj(player)
    end
    player.drawangle = mo.angle
    
    player.pflags = $|PF_THOKKED &~ PF_SPINNING
    return true
end