local B = CBW_Battle
local CV = B.Console

B.TagGametype = function()
	if gametype == GT_EGGROBOTAG or G_TagGametype() then return true
	else return false end
end

B.BattleGametype = function()
	if gametype and B.Gametypes.Battle[gametype] then return true
	else return false end
end

B.CPGametype = function()
	if gametype and B.Gametypes.CP[gametype] then return true
	else return false end
end

B.ArenaGametype = function()
	if gametype and B.Gametypes.Arena[gametype] then return true
	else return false end
end

B.DiamondGametype = function()
	if gametype and B.Gametypes.Diamond[gametype] then return true
	else return false end
end

