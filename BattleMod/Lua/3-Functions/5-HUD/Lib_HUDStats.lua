local B = CBW_Battle
local CV = B.Console

B.GetStartRings = function(player, previous)
    if previous then
        return (CV.StartRings.value - (player.ringpenalty-player.lastpenalty or 0)) or 0
    else
        return (CV.StartRings.value - (player.ringpenalty or 0)) or 0
    end
end

B.StatsHUD = function(v)
    local player
    for p in players.iterate do
        if p == displayplayer then
            player = p
            break
        end
    end
    if not player then
        return
    end
    -- Starting rings
    local patch = v.cachePatch("NRNG1")
    local x = 4
    local y = 4
    local flags = V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT
    v.draw(x, y, patch, flags|V_HUDTRANSHALF)
    v.drawString(x+8, y+3, B.GetStartRings(player), flags|V_HUDTRANS, "center")
end

B.StartRingsHUD = function(v, player)
    if not (
        player.deadtimer
        or (player.ringpenalty and player.ringpenalty >= CV.StartRings.value)
    ) then
        return
    end
    local x = 320/2 - 6
    local y = 240/2
    local flags = V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT
    local rflags = 0
    local color = nil
    if player.deadtimer > TICRATE*4 then -- hide completely
        return
    elseif player.deadtimer > TICRATE*2 then -- fade out
        flags = $ | ( B.TIMETRANS(TICRATE*8 - player.deadtimer*2) or 0 )
    elseif player.deadtimer > TICRATE then -- flash red and bounce
        v.drawString(x+8, y+16, "-"..player.lastpenalty, flags|V_YELLOWMAP, "center")
        flags = $ | V_REDMAP
        rflags = V_50TRANS
        color = SKINCOLOR_RED
        local y2 = y - (TICRATE*5/2) + player.deadtimer*2
        x = $ + v.RandomRange(-1, 1)
        y = min($, y2)
    elseif player.deadtimer == TICRATE then -- sfx
        S_StartSound(nil, sfx_antiri, player)
    else -- fade in
        flags = $ | ( B.TIMETRANS(player.deadtimer*3) or 0 )
    end
    local patch = v.cachePatch("NRNG1")
    v.draw(x, y, patch, flags | rflags, v.getColormap(TC_RAINBOW, color))
    v.drawString(x+8, y+3, B.GetStartRings(player, player.deadtimer < TICRATE), flags, "center")
end