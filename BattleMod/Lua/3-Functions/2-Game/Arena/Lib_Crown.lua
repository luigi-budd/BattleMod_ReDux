freeslot("SPR_CRWN","S_CROWN")
states[S_CROWN] = {
	sprite = SPR_CRWN,
	tics = -1
}
local B = CBW_Battle
local A = B.Arena
local CV = B.Console


addHook("ThinkFrame",function()
if not B.ArenaGametype() return end
if G_GametypeUsesLives() return end
	for player in players.iterate
		if not player.heart and player.wanted == true
			player.heart = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z + player.mo.height + 24*player.mo.scale, MT_GHOST)
			player.heart.state = S_CROWN
			player.heart.scale = 2*player.mo.scale/3
			player.heart.fuse = -1
			player.heart.target = player.mo
		end
		if (player.rwanted == true and player.ctfteam == 1) and not player.heart and G_GametypeHasTeams()
			player.heart = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z + player.mo.height + 24*player.mo.scale, MT_GHOST)
			player.heart.state = S_CROWN
			player.heart.scale = 2*player.mo.scale/3
			player.heart.fuse = -1
			player.heart.target = player.mo
		end
		if (player.bwanted == true and player.ctfteam == 2) and not player.heart and G_GametypeHasTeams()
			player.heart = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z + player.mo.height + 24*player.mo.scale, MT_GHOST)
			player.heart.state = S_CROWN
			player.heart.scale = 2*player.mo.scale/3
			player.heart.fuse = -1
			player.heart.target = player.mo
		end
	end
end)

addHook("MobjThinker", function(mo)
if G_GametypeHasTeams() return end
if not B.ArenaGametype() return end
if mo.state != S_CROWN return end
	if mo.target
		if mo.target.player.wanted == false
			mo.target.player.heart = nil
			P_RemoveMobj(mo)
		else
			mo.scale = 2*mo.target.scale/3
			local z = mo.target.z + mo.target.height + 16*FRACUNIT
			P_MoveOrigin(mo, mo.target.x, mo.target.y, z)
			return true
		end
	elseif not mo.target 
		P_RemoveMobj(mo)
	end
end, MT_GHOST)

addHook("MobjThinker", function(mo)
if not G_GametypeHasTeams() return end
if not B.ArenaGametype() return end
if not (mo and mo.valid) then return end
if not (mo.target and mo.target.valid) then return end
if mo.state != S_CROWN return end
	if mo.target and mo.target.valid
		if (mo.target.player.rwanted == false and mo.target.player.ctfteam == 1)
			mo.target.player.heart = nil
			P_RemoveMobj(mo)
			return
		else
			mo.scale = 2*mo.target.scale/3
			local z = mo.target.z + mo.target.height + FixedMul((16 + abs((leveltime % TICRATE) - TICRATE/2))*FRACUNIT, mo.target.scale)
			P_MoveOrigin(mo, mo.target.x, mo.target.y, z)
			return true
		end
	elseif not mo.target 
		P_RemoveMobj(mo)
	end
end, MT_GHOST)

addHook("MobjThinker", function(mo)
if not G_GametypeHasTeams() return end
if not B.ArenaGametype() return end
if not (mo and mo.valid) then return end
if not (mo.target and mo.target.valid) then return end
if mo.state != S_CROWN return end
	if mo.target and mo.target.valid
		if (mo.target.player.bwanted == false and mo.target.player.ctfteam == 2)
			mo.target.player.heart = nil
			P_RemoveMobj(mo)
			return 
		else
			mo.scale = 2*mo.target.scale/3
			local z = mo.target.z + mo.target.height + FixedMul((16 + abs((leveltime % TICRATE) - TICRATE/2))*FRACUNIT, mo.target.scale)
			P_MoveOrigin(mo, mo.target.x, mo.target.y, z)
			return true
		end
	elseif not mo.target 
		P_RemoveMobj(mo)
		return
	end
end, MT_GHOST)