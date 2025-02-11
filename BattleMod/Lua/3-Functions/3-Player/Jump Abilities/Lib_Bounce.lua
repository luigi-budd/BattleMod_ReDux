local B = CBW_Battle

B.FastBounce = function(player, mo)
    if player.pflags&PF_THOKKED then return true end
    mo.state = S_PLAY_BOUNCE
    player.pflags = $ & ~(PF_JUMPED|PF_NOJUMPDAMAGE)
    player.pflags = $ | (PF_THOKKED|PF_BOUNCING)
    return true
end