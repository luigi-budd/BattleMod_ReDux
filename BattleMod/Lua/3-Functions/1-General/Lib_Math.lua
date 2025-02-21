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

B.TIMETRANS = function(time, speed, prefix, suffix, minimum, cap, debug)
    speed = speed or 1
	prefix = $ or "V_"
	suffix = $ or "TRANS"
    local level = (time / speed / 10) * 10
    level = max(10, min(100, level))
    
	if minimum then level = max($, minimum / 10 * 10) end
	if cap then level = min($, cap / 10 * 10) end

    if level == 100 then
		if debug then print(level) end
        return 0
    else
		if debug then print(level) end
        return _G[prefix .. (100 - level) .. suffix]
    end
end

B.Wrap = function(value, minValue, maxValue)
	local range = maxValue - minValue + 1
	return ((value - minValue) % range + range) % range + minValue
end

--- Fixes infamous "wallswipe" bugs - projectiles getting stuck into walls and such.
--- Keep in mind a player's radius is 16FU, but the recommended oldRadius is 8FU or lower
B.SafeRadiusIncrease = function(mo, newRadius, oldRadius, repeatable)
    if (mo.flags2 & MF2_FRET) then
		return
	end

	local z1 = (mo.flags2 & MF2_OBJECTFLIP) and mo.ceilingz or mo.floorz
	mo.radius = newRadius
	local z2 = (mo.flags2 & MF2_OBJECTFLIP) and mo.ceilingz or mo.floorz

	if P_CheckPosition(mo, mo.x, mo.y) and abs(z1 - z2) < mo.height then
		if not repeatable then mo.flags2 = $ | MF2_FRET end
	else
		mo.radius = oldRadius or mobjinfo[mo.type].radius
	end
	--print(mo.radius/FU)
end

B.NearGround = function(mo, fracunits)
	if P_MobjFlip(mo) == 1 then
		return (mo.z-mo.floorz < mo.scale*fracunits)
	else
		return (mo.ceilingz+mo.height-mo.z < mo.scale*fracunits)
	end
end

B.NearPlayer = function(mo, fracunits)
	local nearest = B.GetNearestPlayer(mo)
	if nearest and nearest.mo then
		nearest = nearest.mo
		local dx = mo.x - nearest.x
		local dy = mo.y - nearest.y
		local dz = mo.z - nearest.z
		return FixedHypot(FixedHypot(dx, dy), dz) < mo.scale*fracunits
	end
end