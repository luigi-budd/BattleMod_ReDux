local B = CBW_Battle
local R = B.Ruby
addHook("TouchSpecial",function(mo,toucher)
	R.Collect(mo,toucher)
	return true
end,MT_RUBY)


addHook("MobjThinker",R.Thinker,MT_RUBY)

/*addHook("MobjFuse",function(mo)
	mo.flags = $|MF_SPECIAL
	return true
end,MT_RUBY)*/
