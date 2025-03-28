local B = CBW_Battle
local flash = TICRATE/2
local x = 320/2
local y = 184+5 --5px offset cause' hudrings lol

B.DrawMatchPoint = function(v)
    if B.MatchPoint == true and (leveltime/flash & 1) then
        v.drawString(x, y, "MATCH POINT!", V_SNAPTOBOTTOM, "center")
    end
end
