local B = CBW_Battle
addHook("MobjSpawn",function(mo)
	if twodlevel and mo.flags&MF_SPRING then
		mo.scale = B.TwoDFactor($)
	end
end)