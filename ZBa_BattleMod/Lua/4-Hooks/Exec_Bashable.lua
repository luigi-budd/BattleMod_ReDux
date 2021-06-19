local B = CBW_Battle
local CV = B.Console
//Tails Doll sparring partner
addHook("MobjSpawn",B.TailsDollCreate,MT_SPARRINGDUMMY)

addHook("MobjThinker",B.TailsDollThinker,MT_SPARRINGDUMMY)

addHook("MobjFuse", function(mo)
	B.TailsDollFuse(mo,mo.target)
	return true
end,MT_SPARRINGDUMMY)

//Chess Pieces
local ChessSpawn = function(mo,scale,friction,smooth)
	B.CreateBashable(mo,scale,friction,smooth)
	if P_RandomRange(0,1) then
		mo.color = SKINCOLOR_SILVER
	else
		mo.color = SKINCOLOR_JET
	end
end

addHook("MobjSpawn",function(mo) ChessSpawn(mo,80,2,false) end,MT_CHESSKNIGHT)
addHook("MobjSpawn",function(mo) ChessSpawn(mo,100,5,false) end,MT_CHESSKING)
addHook("MobjSpawn",function(mo) ChessSpawn(mo,100,1,false) end,MT_CHESSQUEEN)
addHook("MobjSpawn",function(mo) ChessSpawn(mo,60,3,false) end,MT_CHESSPAWN)

// B.CreateBashable(mo,weight,friction,smooth,sentient)
	//Args
	//mo: object to modify
	//weight: Resistance to knockback (in "percent"). 100 is standard. Must be positive.
	//friction: Factor to slow object when sliding from knockback, overrides normal friction. 0 is none, 3-4 is approx normal friction.
	//smooth: Object rolls downhill. "Friction" factor always takes effect.
	//sentient: Intended for use with objects that are designed to act more like enemies

//Snowmen
addHook("MobjSpawn",function (mo) B.CreateBashable(mo,nil,nil,true) end,MT_SNOWMAN)
addHook("MobjSpawn",function(mo) B.CreateBashable(mo,nil,nil,true) end,MT_SNOWMANHAT)
//Rollout Rock
addHook("MobjSpawn",function(mo) B.CreateBashable(mo,nil,1,true) end,MT_ROLLOUTROCK)

//Bash boulder
addHook("MobjSpawn",function(mo) 
	B.CreateBashable(mo,70,1,true)
	mo.flags2 = $|MF2_AMBUSH
end,MT_BASHBOULDER)
 
addHook("MapThingSpawn",function(mo,thing)
	if thing.options&MTF_AMBUSH
		mo.scale = $*3/2
	end
end, MT_BASHBOULDER)

addHook("MobjThinker",function(mo)
	if not(mo and mo.valid) or mo.flags&MF_NOTHINK then return end
	mo.fuse = 999
end,MT_BASHBOULDER)

//Game logic hooks

addHook("MobjThinker",B.BashableThinker,MT_BASHBOULDER)
addHook("MobjThinker",B.BashableThinker,MT_SPARRINGDUMMY)
addHook("MobjThinker",B.BashableThinker,MT_SNOWMAN)
addHook("MobjThinker",B.BashableThinker,MT_SNOWMANHAT)
addHook("MobjThinker",B.BashableThinker,MT_CHESSKNIGHT)
addHook("MobjThinker",B.BashableThinker,MT_CHESSKING)
addHook("MobjThinker",B.BashableThinker,MT_CHESSQUEEN)
addHook("MobjThinker",B.BashableThinker,MT_CHESSPAWN)
addHook("MobjThinker",B.BashableThinker,MT_ROLLOUTROCK)


addHook("MobjLineCollide",function(mo,line)
	if mo.battleobject and line.flags&ML_BLOCKMONSTERS return true end
end,MT_NULL)


addHook("MobjCollide",B.BashableCollision,MT_NULL)

addHook("MobjMoveCollide",function(mo,other)
	if not(mo and mo.valid) or mo.flags&MF_NOTHINK then return end
	return B.BashableCollision(mo,other)
end,MT_NULL)

addHook("TouchSpecial",function(mo,other)
	if not(mo and mo.valid and mo.battleobject) then return end
	B.BashableCollision(mo,other)
	return true
end,MT_NULL)

addHook("ShouldDamage",B.BashableShouldDamage,MT_NULL)