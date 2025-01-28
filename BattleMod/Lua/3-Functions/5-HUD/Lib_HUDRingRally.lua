local B = CBW_Battle
local CV = B.Console
B.ChaosRingHUD = function(v, player)
    --Froot Loops (Chaos Rings)
    if gametype == GT_BANK then
        local flags = V_PERPLAYER|V_SNAPTOTOP|V_HUDTRANS
        local x = 160*FRACUNIT
        local y = (CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) and 26*FRACUNIT) or 26*FRACUNIT
        local rednum = 0
        local bluenum = 0
        for t = 1, 2 do
            local val = 1
            local flip = (t==1 and val) or -val
            for i = 1, 6 do
                local num = i
                local chaosring = B.ChaosRing.LiveTable[num]
                if not(chaosring and chaosring.valid) then continue end
                if not((chaosring.captured and ((chaosring.ctfteam == t) and (((chaosring.fuse) and ((leveltime/6)%2)==1) or not(chaosring.fuse)))) or ((chaosring.target and chaosring.target.valid and chaosring.target.player and (chaosring.target.player.ctfteam == t) and chaosring.target.player.gotcrystal_time) and (leveltime%2)==1)) then continue end
                local patch = v.cachePatch("CHRING"..num)
                v.drawScaled((x-(FRACUNIT*3)+(flip*((FRACUNIT/3)*(28)))*(i+2)), (y+(FRACUNIT*10)), FRACUNIT/2, patch, flags|V_HUDTRANS)
            end
        end
    end
end