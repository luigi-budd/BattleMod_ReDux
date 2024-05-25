local B = CBW_Battle
local D = B.Diamond
addHook("TouchSpecial",function(mo,toucher)
	D.Collect(mo,toucher)
	return true
end,MT_DIAMOND)


addHook("MobjThinker",D.Thinker,MT_DIAMOND)
addHook("MobjThinker", D.CapturePointThinker, MT_CONTROLPOINT)

addHook("MobjFuse",function(mo)
	mo.flags = $|MF_SPECIAL
	return true
end,MT_DIAMOND)
addHook("ThinkFrame", D.GameControl)

addHook("MapChange", D.Reset)
addHook("MapLoad", D.GenerateSpawns)
--addHook("PlayerThink", D.SpawnDiamondIndicator)
addHook("PostThinkFrame", D.DiamondIndicatorThinker)
