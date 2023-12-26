local B = CBW_Battle

B.FixedLerp = function(val1,val2,amt)
	local p = FixedMul(FRACUNIT-amt,val1) + FixedMul(amt,val2)
	return p
end

B.ZCollide = function(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end

B.GetZAngle = function(x1,y1,z1,x2,y2,z2)
	local xydist = R_PointToDist2(x1,y1,x2,y2)
	local zdist = z2-z1
	return R_PointToAngle2(0,0,xydist,zdist)
end

--Lach
local transLevelToQuarterTransFlag = {
    [0] = V_70TRANS,
    [1] = V_70TRANS,
    [2] = V_70TRANS,
    [3] = V_80TRANS,
    [4] = V_80TRANS,
    [5] = V_80TRANS,
    [6] = V_90TRANS,
    [7] = V_90TRANS,
    [8] = V_90TRANS,
    [9] = V_90TRANS,
    [10] = V_HUDTRANS
}
B.GetHudQuarterTrans = function(v)
    return transLevelToQuarterTransFlag[v.localTransFlag() >> V_ALPHASHIFT]
end

local baseChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@"

--[[/*
B.BaseConv = function(number, base, chars)
	if not chars then
		chars = baseChars
	end

	local outstring = ""

	if (number == 0) then
		return "0";
	end

	local i = 0

	while (number > 0) do
		local index = number % base
		outstring[i] = chars[index]
		number = $ / base

		i = i + 1
	end

	string.reverse(outstring)

	return outstring
end
*/]]