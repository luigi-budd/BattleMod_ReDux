local B = CBW_Battle

addHook("MobjThinker", B.BattleShieldThinker, MT_BATTLESHIELD)
addHook("MobjThinker", B.NegaShieldThinker, MT_NEGASHIELD)
addHook("MobjThinker", B.InstaFlip, MT_INSTASHIELD)
addHook("MobjThinker", B.StunBreakVFXThinker, MT_STUNBREAK)

addHook("MobjThinker",function(mo) B.EnergyGather(mo,mo.target,mo.extravalue1,mo.extravalue2) end,MT_ENERGYGATHER)
addHook("MobjThinker", B.TargetDummyThinker, MT_TARGETDUMMY)
addHook("MobjThinker",function(mo) B.MetalAura(mo,mo.target) end, MT_ENERGYAURA)
local TeamOrb = function(mo)
	if G_GametypeHasTeams() then
		B.ShieldColor(mo,mo.target)
	end
	B.OverlayHide(mo,mo.target) 
end
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target)  end,MT_ELEMENTAL_ORB)
addHook("MobjThinker", TeamOrb,MT_FORCE_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target)  end,MT_ATTRACT_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target)  end,MT_ARMAGEDDON_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target)  end,MT_WHIRLWIND_ORB)
addHook("MobjThinker",function(mo) 
	if gametyperules&GTR_PITYSHIELD or G_GametypeHasTeams() then
		B.ShieldColor(mo,mo.target)
	end
	B.OverlayHide(mo,mo.target) 
end,MT_PITY_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target) end,MT_FLAMEAURA_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target) end,MT_BUBBLEWRAP_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target) end,MT_THUNDERCOIN_ORB)
addHook("MobjThinker",function(mo) B.OverlayHide(mo,mo.target) end,MT_OVERLAY)