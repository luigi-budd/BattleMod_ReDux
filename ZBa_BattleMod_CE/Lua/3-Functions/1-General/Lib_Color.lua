local B = CBW_Battle
B.FlashColor = function(colormin,colormax)
	local N = 32 //Rate of oscillation
-- 	local size = colormax-colormin+1 //Color spectrum
	local scale = 2 //Factor-amount to reduce the oscillation intensity
	local offset = 0 //Offset the origin of oscillation
	local oscillate = abs((leveltime&(N*2-1))-N)/scale //Oscillation cycle
	local c = colormin+oscillate+offset //offset
	c = max(colormin,min(colormax,$)) //Enforce min/max
	return c
end

B.FlashRainbow = function(mo)
	local t = (leveltime&15)>>2
	if t == 0 then return B.FlashColor(SKINCOLOR_SUPERGOLD1,SKINCOLOR_SUPERGOLD5) end
	if t == 1 then return B.FlashColor(SKINCOLOR_SUPERSKY1,SKINCOLOR_SUPERSKY5) end
	if t == 2 then return B.FlashColor(SKINCOLOR_SUPERTAN1,SKINCOLOR_SUPERTAN5) end
	if t == 3 then return B.FlashColor(SKINCOLOR_SUPERSILVER1,SKINCOLOR_SUPERSILVER5) end
end