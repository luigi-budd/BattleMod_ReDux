local B = CBW_Battle
local CP = B.ControlPoint

addHook("MapChange",CP.Reset)
addHook("MobjSpawn",CP.Spawn,MT_CONTROLPOINT)
addHook("MapThingSpawn",CP.MapThingSpawn,MT_CONTROLPOINT)
addHook("MapLoad",CP.Generate)
addHook("MobjThinker",CP.PointThinker, MT_CONTROLPOINT)
addHook("MobjThinker",CP.SphereThinker, MT_CPBONUS)
addHook("MobjRemoved",function(mo)
	if mo.target then P_SpawnMobj(mo.x,mo.y,mo.z,MT_SPARK) end
end, MT_CPBONUS)
addHook("ThinkFrame",CP.ThinkFrame)
