local B = CBW_Battle
local S = B.SkinVars
local Act = B.Action
local G = B.GuardFunc
S[-1] = {
	flags = SKINVARS_GUARD,
	weight = 100,
	shields = 1,
	special = nil,
-- 	guard_enabled = true, //Deprecated
	guard_frame = 2,
	func_guard_trigger = G.Parry,
	func_priority = B.Priority_FullCommon,
	func_priority_ext = nil,
	func_collide = nil,
	func_exhaust = nil,
	sprites = {}
}
S["sonic"] = {
	weight = 90,
	shields = 1, 
	special = Act.SuperSpinJump,
	guard_frame = 2,
	func_priority_ext = Act.SuperSpinJump_Priority,
	sprites = {}
}
S["tails"] = {
	weight = 100,
	shields = 1,
	special = Act.TailSwipe,
	guard_frame = 2,
	func_priority_ext = Act.TailSwipe_Priority,
	sprites = {
		S_TAILS_SWIPE
	}
}
S["knuckles"] = {
	weight = 115,
	shields = 1,
	special = Act.Dig,
	guard_frame = 2,
	func_priority_ext = Act.Dig_Priority,
	func_collide = B.Knuckles_Collide,
	sprites = {
		S_KNUCKLES_DRILLDIVE1,
		S_KNUCKLES_DRILLDIVE2,
		S_KNUCKLES_DRILLDIVE3,
		S_KNUCKLES_DRILLDIVE4,
		S_KNUCKLES_DRILLRISE1,
		S_KNUCKLES_DRILLRISE2,
		S_KNUCKLES_DRILLRISE3,
		S_KNUCKLES_DRILLRISE4
	}
}
S["amy"] = {
	weight = 100,
	shields = 1,
	special = Act.PikoSpin,
	guard_frame = 1,
	func_priority_ext = Act.PikoSpin_Priority,
	sprites = {}
}
S["fang"] = {
	flags = SKINVARS_GUARD|SKINVARS_GUNSLINGER,
	weight = 100,
	shields = 1,
	special = Act.DodgeRoll,
	guard_frame = 1,
	sprites = {
		S_FANGCHAR_AIRFIRE1,
		S_FANGCHAR_AIRFIRE2
	}	
}
S["metalsonic"] = {
	weight = 115,
	shields = 1,
	special = Act.EnergyAttack,
	guard_frame = 2,
	func_priority_ext = Act.EnergyAttack_Priority,
	sprites = {
		S_METALSONIC_GATHER
	}
}
