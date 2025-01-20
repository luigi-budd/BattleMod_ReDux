local B = CBW_Battle

local stored_skincolors = false

addHook("NetVars", function(n)
    stored_skincolors = n($)
end)

addHook("PreThinkFrame", do
    if (G_GametypeHasTeams()) and (B.BattleGametype()) then 
        

        if not(stored_skincolors) then
            for player in players.iterate do
                if (player.ctfteam < 1) then
                    continue
                end

                if player.skincolor ~= color then
                    player.battle_oldskincolor = player.skincolor
                end
            end
            stored_skincolors = true
        end

        for player in players.iterate do
            if (player.ctfteam < 1) then
                continue
            end

            local color = ({skincolor_redteam, skincolor_blueteam})[player.ctfteam]

            player.skincolor = color
        end

    else
        if stored_skincolors then
            for player in players.iterate do
                if player.battle_oldskincolor then
                    player.skincolor = player.battle_oldskincolor
                end
                player.battle_oldskincolor = nil
            end
            stored_skincolors = false
        end
    end
end)