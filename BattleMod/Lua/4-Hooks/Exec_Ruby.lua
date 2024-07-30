local B = CBW_Battle
local R = B.Ruby
addHook("TouchSpecial",function(mo,toucher)
	R.Collect(mo,toucher)
	return true
end,MT_RUBY)


addHook("MobjThinker",R.Thinker,MT_RUBY)

addHook("MobjFuse",function(mo)
	mo.flags = $|MF_SPECIAL
	return true
end,MT_RUBY)

addHook("MobjRemoved", function(mo)
	if mo.light and mo.light.valid then
		P_RemoveMobj(mo.light)
		return nil
	end
end, MT_RUBY)
