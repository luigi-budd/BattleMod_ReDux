local B = CBW_Battle

freeslot('MT_MAPRADARPOINT1','MT_MAPRADARPOINT2')

mobjinfo[MT_MAPRADARPOINT1] = {
	//$Name "Map Radar Point (northwest)"
	//$Sprite ZBRADARD
	//$Category "Map Radar"
	doomednum = 98
}
mobjinfo[MT_MAPRADARPOINT2] = {
	//$Name "Map Radar Point (southeast)"
	//$Sprite ZBRADARD
	//$Category "Map Radar"
	doomednum = 99
}

B.MapRadarPoint1 = 0
B.MapRadarPoint2 = 0

addHook("MapLoad",do
	B.MapRadarPoint1 = 0
	B.MapRadarPoint2 = 0
	
	for mapthing in mapthings.iterate
		local mt = mapthing
		local t = mt.type
		if t == 98
			B.MapRadarPoint1 = mt
			--print("found rp1 "..mt.x..", "..mt.y)
		end
		if t == 99
			B.MapRadarPoint2 = mt
			--print("found rp2 "..mt.x..", "..mt.y)
		end
	end
end)
