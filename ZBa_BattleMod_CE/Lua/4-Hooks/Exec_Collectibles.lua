local B = CBW_Battle
local F = B.CTF
addHook("MobjThinker",F.FlagIntangible, MT_REDFLAG)
addHook("MobjThinker",F.FlagIntangible, MT_BLUEFLAG)
addHook("MobjThinker",F.TrackRed, MT_REDFLAG)
addHook("MobjThinker",F.TrackBlue, MT_BLUEFLAG)
addHook("MobjThinker",B.Arena.RingLoss, MT_FLINGRING)