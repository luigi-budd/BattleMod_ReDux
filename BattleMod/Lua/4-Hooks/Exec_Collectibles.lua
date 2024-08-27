local B = CBW_Battle
local F = B.CTF
local R = B.Ruby
addHook("MobjThinker",F.FlagIntangible, MT_CREDFLAG)
addHook("MobjThinker",F.FlagIntangible, MT_CBLUEFLAG)
addHook("MobjThinker",F.TrackRed, MT_CREDFLAG)
addHook("MobjThinker",F.TrackBlue, MT_CBLUEFLAG)
addHook("ThinkFrame",F.TrackPlayers)
addHook("MobjThinker",B.Arena.RingLoss, MT_FLINGRING)
addHook("TouchSpecial",function(...) return F.TouchFlag(...) end, MT_CREDFLAG)
addHook("TouchSpecial",function(...) return F.TouchFlag(...) end, MT_CBLUEFLAG)

-- Remove the hardcoded flags
local removeflags = function(mo)
	if (gametype == GT_BANK) then return end -- don't do anything if bank TOL

	if (gametype ~= GT_CTF) then
		mo.flags2 = $ | MF2_DONTDRAW
		mo.flags = $ & ~MF_SPECIAL
		if mo.type == MT_REDFLAG then
			R.RedGoal = mo
		else
			R.BlueGoal = mo
		end
	else
		P_RemoveMobj(mo)
	end
end
addHook("MobjSpawn", removeflags, MT_REDFLAG)
addHook("MobjSpawn", removeflags, MT_BLUEFLAG)
-- Run thinkers for flags
addHook("MobjThinker", F.FlagMobjThinker, MT_CREDFLAG)
addHook("MobjThinker", F.FlagMobjThinker, MT_CBLUEFLAG)
-- For checking if flags were interacted with
addHook("TouchSpecial", F.FlagTouchSpecial, MT_CREDFLAG)
addHook("TouchSpecial", F.FlagTouchSpecial, MT_CBLUEFLAG)
-- To assign some properties to flags when they spawn
addHook("MobjSpawn", F.FlagSpawn, MT_CREDFLAG)
addHook("MobjSpawn", F.FlagSpawn, MT_CBLUEFLAG)
-- If fuse runs out
addHook("MobjFuse", F.RespawnFlag, MT_CREDFLAG)
addHook("MobjFuse", F.RespawnFlag, MT_CBLUEFLAG)
-- If object gets removed
addHook("MobjRemoved", F.FlagRemoved, MT_CREDFLAG)
addHook("MobjRemoved", F.FlagRemoved, MT_CBLUEFLAG)
-- Check if flags are supposed to be at their base.. every tic
addHook("ThinkFrame", F.AreFlagsAtBase)

-- Player: prevent shield specials and ability specials.
addHook("AbilitySpecial", F.GotFlagCheck)
addHook("ShieldSpecial", F.GotFlagCheck)

-- Draw GOT FLAG! indicator on player.
addHook("PostThinkFrame", F.DrawIndicator)

-- Check if flag was tossed or capped, etc.
addHook("PreThinkFrame", F.FlagPreThinker) 

-- Toss ruby
addHook("PreThinkFrame", R.PreThinker) 
