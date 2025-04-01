--[[
	NOTE: I tried to just do something like this on a 'MusicChange' hook:
	'return p.nojingles and (newname == "_shoes" or newname == "_inv" or newname == "_super")'
	However, instead of denying the music override, the music just stopped playing entirely.
	I have no clue why, maybe it's how srb2 handles jingles. Oh well. Here's this hack instead.

	~Lumyni
]]

local B = CBW_Battle
local CV = B.Console
local DBG_GAMELOGIC = true

B.NoJingles = function()
	return B.Pinch or B.Overtime or B.MatchPoint
end

local CONS_Debug = function(debug, message)
	for player in players.iterate do
		if debug and devparm then CONS_Printf(player, message) end
	end
end

function A_SuperSneakers(actor, var1, var2)
	if not (actor.target and actor.target.player) then
		CONS_Debug(DBG_GAMELOGIC, "Powerup has no target.\n")
		return
	end
    local player = actor.target.player
    if CV.FindVarString("battleconfig_nojingles", "On") or B.NoJingles() then
	    player.powers[pw_sneakers] = sneakertics + 1
    else
        super(actor, var1, var2) --same as source
    end
end

function A_Invincibility(actor, var1, var2)
	if not (actor.target and actor.target.player) then
		CONS_Debug(DBG_GAMELOGIC, "Powerup has no target.\n")
		return
	end

	local player = actor.target.player
    if CV.FindVarString("battleconfig_nojingles", "On") or B.NoJingles() then
	    player.powers[pw_invulnerability] = invulntics + 1
    else
        super(actor, var1, var2) --same as source
    end
end