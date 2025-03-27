local B = CBW_Battle
local CV = B.Console
local flash = TICRATE/2
local x = 320/2
local y = 184+5 --5px offset cause' hudrings lol
local shake = 1

B.DrawMatchPoint = function(v)
    if B.MatchPoint and (leveltime/flash & 1) then
        local txt = "MATCH POINT!"
        local flags = V_SNAPTOBOTTOM
        local xshake = 0
        local yshake = 0
        if B.MatchPoint == 2 then
            txt = "FINAL SHOWDOWN!!"
            --flags = $ | V_INVERTMAP
            xshake = v.RandomRange(-shake,shake)
		    yshake = v.RandomRange(-shake,shake)
        end
        v.drawString(x+xshake, y+yshake, txt, flags, "center")
    end
end

--Using this for now because we don't have default songs
B.DrawMatchPointDebug = function(v)
    local debug = CV.Debug.value
    if debug&DF_GAMETYPE then
        B.DrawMatchPoint(v)
    end
end