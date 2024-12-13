local B = CBW_Battle
local F = B.CTF
local R = B.Ruby

--[[ 
/* 	=== NOTE: ALL CUSTOM CTF FLAG HOOKS ARE CURRENTLY UNUSED! ===

	Real flags indicate flags that will be used in-game, and fake flags are
	the flags that will be replaced with the real flags.

	For this instance, REALFLAG_R (MT_REDFLAG) will replace FAKEFLAG_R (MT_CREDFLAG).

*/]]--
local REALFLAG_R = MT_REDFLAG
local REALFLAG_B = MT_BLUEFLAG
local FAKEFLAG_R = MT_CREDFLAG
local FAKEFLAG_B = MT_CBLUEFLAG


addHook("MobjThinker",F.FlagIntangible, REALFLAG_R)
addHook("MobjThinker",F.FlagIntangible, REALFLAG_B)
addHook("MobjThinker",F.TrackRed, REALFLAG_R)
addHook("MobjThinker",F.TrackBlue, REALFLAG_B)
addHook("ThinkFrame",F.TrackPlayers)
addHook("MobjThinker",B.Arena.RingLoss, MT_FLINGRING)
--addHook("TouchSpecial",function(...) return F.TouchFlag(...) end, REALFLAG_R)
--addHook("TouchSpecial",function(...) return F.TouchFlag(...) end, REALFLAG_B)

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
--addHook("MobjSpawn", removeflags, FAKEFLAG_R)
--addHook("MobjSpawn", removeflags, FAKEFLAG_B)
-- Run thinkers for flags
--addHook("MobjThinker", F.FlagMobjThinker, REALFLAG_R)
--addHook("MobjThinker", F.FlagMobjThinker, REALFLAG_B)
-- For checking if flags were interacted with
--addHook("TouchSpecial", F.FlagTouchSpecial, REALFLAG_R)
--addHook("TouchSpecial", F.FlagTouchSpecial, REALFLAG_B)
-- To assign some properties to flags when they spawn
--addHook("MobjSpawn", F.FlagSpawn, REALFLAG_R)
--addHook("MobjSpawn", F.FlagSpawn, REALFLAG_B)
-- If fuse runs out
--addHook("MobjFuse", F.RespawnFlag, REALFLAG_R)
--addHook("MobjFuse", F.RespawnFlag, REALFLAG_B)
-- If object gets removed
--addHook("MobjRemoved", F.FlagRemoved, REALFLAG_R)
--addHook("MobjRemoved", F.FlagRemoved, REALFLAG_B)

-- Player: prevent shield specials and ability specials.
--addHook("AbilitySpecial", F.GotFlagCheck)
--addHook("ShieldSpecial", F.GotFlagCheck)

-- Draw GOT FLAG! indicator on player.
addHook("PostThinkFrame", F.DrawIndicator)

-- Check if flag was tossed or capped, etc.
addHook("PreThinkFrame", F.FlagPreThinker) 

-- Toss ruby
addHook("PreThinkFrame", R.PreThinker) 
