local B = CBW_Battle
local time = 0 -- substitute for leveltime (since we're not in a level)

B.Lmao = function(v, player)
	-- vars for easily editing the thing
	local LEFT = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER
	local bgscale = FRACUNIT
	local tilescalex = bgscale*256
	local tilescaley = bgscale*128
	local tile = v.cachePatch("CHECKER8")
	local color = SKINCOLOR_SLATE

	-- the thing!
	time = $+1
	for column = 0, 3 do
		local y = column*tilescaley
		local orientation = (column % 2 == 0) and 1 or -1 -- alternate move from left to right
		for row = 0, 2 do
			local x = B.Wrap(time*FRACUNIT*orientation, (row-1)*tilescalex, row*tilescalex)
			v.drawScaled(x, y, bgscale, tile, LEFT, v.getColormap(nil, color))
		end
	end
end
hud.add(B.Lmao, "intermission")