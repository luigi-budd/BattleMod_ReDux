local B = CBW_Battle

B.HandleFloat = function(player, mo)
    if player.charability == CA_FLOAT and (mo.state == S_PLAY_ROLL or player.secondjump == UINT8_MAX) then
        return true
    end
end