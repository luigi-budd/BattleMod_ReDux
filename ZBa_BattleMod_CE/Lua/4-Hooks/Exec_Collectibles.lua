local B = CBW_Battle
addHook("MobjThinker",B.FlagIntangible, MT_REDFLAG)
addHook("MobjThinker",B.FlagIntangible, MT_BLUEFLAG)
addHook("MobjThinker",B.Arena.RingLoss, MT_FLINGRING)