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

-- fracunits, flip and momz are all optional
B.GetGroundDistance = function(mo, flip, momz)
	flip = $ or P_MobjFlip(mo)
	local groundz = mo.floorz
	local moz = mo.z
	if flip == -1 then
		groundz = mo.ceilingz
		moz = $ + mo.height
	end
	if momz then
		moz = $ + momz
	end
	return (moz - groundz) * flip
end

B.NearGround = function(mo, fracunits, flip, momz)
	return P_IsObjectOnGround(mo)
	or B.GetGroundDistance(mo, flip, momz) <= mo.scale * (fracunits or 0)
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

//3D distance used by B.GetProximity
B.Dist3D = function(mo1,mo2)
	local x = mo2.x - mo1.x
	local y = mo2.y - mo1.y
	local z = mo2.z - mo1.z
	return FixedHypot(FixedHypot(x,y),z)
end
//Proximity checker for the emblem radar
B.GetProximity = function(mo, target)
	if not (mo and mo.valid) or not (target and target.valid) return 1 end
	local dist = B.Dist3D(mo,target)/FRACUNIT
	if target.inactive return 1 end
	//Data taken from source code
	local i = 1
	if dist < 128
		i = 6
	elseif dist < 512
		i = 5
	elseif dist < 1024
		i = 4
	elseif dist < 2048
		i = 3
	elseif dist < 3072
		i = 2
	end
	return i
end