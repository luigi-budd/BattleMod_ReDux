local B = CBW_Battle
local CV = B.Console
local F = B.CTF
local D = B.Diamond
local CP = B.ControlPoint
local MINIMAP_XPOS = 305
local MINIMAP_YPOS = 130
local MINIMAP_YPOS_SPEC = 160
local BIGMAP_XPOS = 160
local BIGMAP_YPOS = 100

freeslot("spr_radd", "spr_rcam")

--IntToExtMapNum(n)
--Returns the extended map number as a string
--Returns nil if n is an invalid map number
local function IntToExtMapNum(n)
	if n < 0 or n > 1035 then
		return nil
	end
	if n < 10 then
		return "MAP0" + n
	end
	if n < 100 then
		return "MAP" + n
	end
	local x = n-100
	local p = x/36
	local q = x - (36*p)
	local a = string.char(65 + p)
	local b
	if q < 10 then
		b = q
	else
		b = string.char(55 + q)
	end
	return "MAP" + a + b
end

--Draw an icon on the map
local function drawplayer(v, xoff, yoff, x, y, angle, scale, patch, flags, snapflags, colormap)
	y = $ + scale*8
	x = $ + scale*2/3
	if angle then
		v.drawScaled(xoff+x, yoff+y, scale, v.getSpritePatch(SPR_RCAM, 1, 0, angle), V_HUDTRANSHALF|V_ADD|snapflags|V_PERPLAYER)
	end
	v.drawScaled(xoff+x, yoff+y, scale, patch, flags, colormap)
end
local function drawicon(v, xoff, yoff, x, y, scale, patch, flags, colormap)
	v.drawScaled(xoff+x, yoff+y, scale, patch, flags, colormap)
end

--Draw map at position & scale
local function drawmap(v, xpos, ypos, map_zoom, icon_scale, snapflags, border)
	local V_HUDTRANSQUARTER = B.GetHudQuarterTrans(v)
	local patchname = IntToExtMapNum(gamemap).."R"
	if not (v.patchExists(patchname)) then return end
	local point1_x, point1_y, point2_x, point2_y
	if B.MapRadarPoint1 and B.MapRadarPoint2 and B.MapRadarPoint1.x and B.MapRadarPoint1.y and B.MapRadarPoint2.x and B.MapRadarPoint2.y then
		point1_x = B.MapRadarPoint1.x * FRACUNIT
		point1_y = B.MapRadarPoint1.y * FRACUNIT
		point2_x = B.MapRadarPoint2.x * FRACUNIT
		point2_y = B.MapRadarPoint2.y * FRACUNIT
	else
		for v in vertexes.iterate do
			if point1_x == nil then
				point1_x = v.x
				point1_y = v.y
				point2_x = v.x
				point2_y = v.y
			else
				point1_x = min($, v.x)
				point1_y = max($, v.y)
				point2_x = max($, v.x)
				point2_y = min($, v.y)
			end
		end
	end
	
	local map_patch = v.cachePatch(patchname)
	local graphic_width = map_patch.width - 2
	local graphic_height = map_patch.height - 2
	
	local map_screenwidth = FixedMul(graphic_width*FRACUNIT, map_zoom)
	local map_screenheight = FixedMul(graphic_height*FRACUNIT, map_zoom)
	local radarpoints_width = point2_x - point1_x
	local radarpoints_height = point2_y - point1_y
	local radarpoints_centerx = (point1_x + point2_x) / 2
	local radarpoints_centery = (point1_y + point2_y) / 2
	local xoff
	if border then
		xoff = (xpos-border)*FRACUNIT-(map_screenwidth/2)
	else
		xoff = xpos*FRACUNIT
	end
	local yoff = ypos*FRACUNIT
	
	--Draw the map
	v.drawScaled(xoff - (map_screenwidth / 2), yoff - (map_screenheight / 2), map_zoom, map_patch, snapflags|V_HUDTRANSHALF|V_PERPLAYER)
	
	--Draw capture points
	for i = 1, #CP.ID do
		local mo = CP.ID[i]
		local trans = V_HUDTRANSHALF
		local scale = FRACUNIT/10
		local col = v.getColormap(TC_ALLWHITE)
		if CP.Active and CP.Num == i then
			trans = V_HUDTRANS
			if CP.Capturing then
				col = v.getColormap(nil, leveltime % 5 + SKINCOLOR_SUPERGOLD1)
				scale = FRACUNIT/5
			else
				scale = FRACUNIT/5
				col = v.getColormap(nil, SKINCOLOR_SILVER)
			end
		end
		local xpos = mo.x - radarpoints_centerx
		local ypos = mo.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_CP"), trans|snapflags|V_PERPLAYER, col)
	end
	
	--Draw goal zones
	if D.RedGoal and D.RedGoal.valid then
		local scale = FRACUNIT/4
		local xpos = D.RedGoal.x - radarpoints_centerx
		local ypos = D.RedGoal.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_GOALM"), trans|snapflags|V_PERPLAYER)
	end
	if D.BlueGoal and D.BlueGoal.valid then
		local scale = FRACUNIT/4
		local xpos = D.BlueGoal.x - radarpoints_centerx
		local ypos = D.BlueGoal.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_GOALM"), V_HUDTRANS|snapflags|V_PERPLAYER)
	end
	
	--Draw flag (not held by player)
	if F.RedFlag and F.RedFlag.valid and not (F.RedFlag.player or F.RedFlag.fuse) and not (F.RedFlag.flags2 & MF2_DONTDRAW) then
		local scale = FRACUNIT/2
		local xpos = F.RedFlag.x - radarpoints_centerx
		local ypos = F.RedFlag.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		local color = v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_FLAG"), V_HUDTRANS|snapflags|V_PERPLAYER, color)
	end
	if F.BlueFlag and F.BlueFlag.valid and not (F.BlueFlag.player or F.BlueFlag.fuse) and not (F.BlueFlag.flags2 & MF2_DONTDRAW) then
		local scale = FRACUNIT/2
		local xpos = F.BlueFlag.x - radarpoints_centerx
		local ypos = F.BlueFlag.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		local color = v.getColormap(TC_RAINBOW, SKINCOLOR_BLUE)
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_FLAG"), V_HUDTRANS|snapflags|V_PERPLAYER, color)
	end
	if D.ID and D.ID.valid and not (D.ID.target and D.ID.target.valid) then
		local scale = FRACUNIT/4
		local xpos = D.ID.x - radarpoints_centerx
		local ypos = D.ID.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		local color = D.ID.color
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_RUBY"), V_HUDTRANS|snapflags|V_PERPLAYER, v.getColormap(TC_RAINBOW, color))
	end
	
	--Draw Players
	for player in players.iterate do
		local mo = player.realmo
		if not mo or ((mo.flags2 & MF2_DONTDRAW) and not player.spectator) then
			continue
		end
		
		if (gametyperules & GTR_TEAMS) and consoleplayer and not B.MyTeam(consoleplayer, player) and not consoleplayer.spectator then
			continue
		end
		
		local angle, trans, scale
		local color = v.getColormap(player.skin, player.skincolor)
		local xpos = mo.x - radarpoints_centerx
		local ypos = mo.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		if player.spectator then
			v.drawScaled(xoff+x, yoff+y, icon_scale/4, v.getSpritePatch(SPR_RCAM, 0, 0, mo.angle), V_HUDTRANS|snapflags|V_PERPLAYER)
			v.drawScaled(xoff+x, yoff+y, icon_scale/4, v.getSpritePatch(SPR_RCAM, 1, 0, mo.angle), V_HUDTRANSHALF|V_ADD|snapflags|V_PERPLAYER)
			continue
		elseif (player ~= displayplayer) and (player ~= secondarydisplayplayer) then
			trans = V_HUDTRANS
			scale = FRACUNIT/4
		else
			trans = V_HUDTRANS
			angle = mo.angle
			scale = FRACUNIT/3
		end
		if P_PlayerInPain(player) or player.playerstate == PST_DEAD then
			trans = V_HUDTRANSHALF
			if P_PlayerInPain(player) then
				y = $ + ((leveltime%2) * FRACUNIT) - FRACUNIT/2
			end
		end
		drawplayer(v, xoff, yoff, x, y, angle, FixedMul(scale, icon_scale), v.getSprite2Patch(player.skin, SPR2_LIFE), trans|snapflags|V_PERPLAYER, snapflags, color)
		
		if player.powers[pw_invulnerability] then
			local frame = max(0, leveltime % 32)
			local frame2 = max(0, (leveltime - 6) % 32)
			drawicon(v, xoff, yoff + 16*scale, x, y + 6*scale, FixedMul(scale/2, icon_scale), v.getSpritePatch(SPR_IVSP, frame), V_HUDTRANS|snapflags|V_PERPLAYER, color)
			drawicon(v, xoff, yoff + 16*scale, x, y + 6*scale, FixedMul(scale/2, icon_scale), v.getSpritePatch(SPR_IVSP, frame2), V_HUDTRANSQUARTER|snapflags|V_PERPLAYER, color)
		end
		if player.powers[pw_sneakers] > TICRATE/2 then
			local xrot = FixedMul(10*map_zoom, sin(leveltime * ANG20))
			local yrot = FixedMul(10*map_zoom, cos(leveltime * ANG20))
			local xrot2 = FixedMul(10*map_zoom, sin((leveltime - 3) * ANG20))
			local yrot2 = FixedMul(10*map_zoom, cos((leveltime - 3) * ANG20))
			drawicon(v, xoff, yoff, x + xrot, y + yrot, FixedMul(scale, icon_scale) * 2/3, v.cachePatch("RAD_SHOE"), V_HUDTRANS|snapflags|V_PERPLAYER, color)
			drawicon(v, xoff, yoff, x + xrot2, y + yrot2, FixedMul(scale, icon_scale) * 2/3, v.cachePatch("RAD_SHOE"), V_HUDTRANSQUARTER|snapflags|V_PERPLAYER, color)
		end
	end
	
	if D.ID and D.ID.valid and (D.ID.target and D.ID.target.valid) then
		local scale = FRACUNIT/6
		local xpos = D.ID.x - radarpoints_centerx
		local ypos = D.ID.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		local color = D.ID.color
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_RUBY"), V_HUDTRANS|snapflags|V_PERPLAYER, v.getColormap(TC_RAINBOW, color))
	end
	
	--Draw flag (held by player)
	if (F.RedFlag and (F.RedFlag.player or F.RedFlag.fuse) and not (F.RedFlag.flags2 & MF2_DONTDRAW)) then
		local scale = FRACUNIT * 2/7
		local color = v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
		if (leveltime / 4) % 3 == 0 and not F.RedFlag.fuse then
			color = v.getColormap(TC_ALLWHITE)
		end
		local xpos = F.RedFlag.x - radarpoints_centerx
		local ypos = F.RedFlag.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_FLAG"), V_HUDTRANS|snapflags|V_PERPLAYER, color)
	end
	if (F.BlueFlag and (F.BlueFlag.player or F.BlueFlag.fuse) and not (F.BlueFlag.flags2 & MF2_DONTDRAW)) then
		local scale = FRACUNIT * 2/7
		local color = v.getColormap(TC_RAINBOW, SKINCOLOR_BLUE)
		if (leveltime / 4) % 3 == 0 and not F.BlueFlag.fuse then
			color = v.getColormap(TC_ALLWHITE)
		end
		local xpos = F.BlueFlag.x - radarpoints_centerx
		local ypos = F.BlueFlag.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		drawicon(v, xoff, yoff, x, y, FixedMul(scale, icon_scale), v.cachePatch("RAD_FLAG"), V_HUDTRANS|snapflags|V_PERPLAYER, color)
	end
	
	--Draw help ping icon
	for player in players.iterate do
		local mo = player.mo
		if (gametyperules & GTR_TEAMS) and consoleplayer and not B.MyTeam(consoleplayer, player) and not consoleplayer.spectator then
			continue
		end
		if not (mo and mo.help_ping) then
			continue
		end
		local xpos = mo.x - radarpoints_centerx
		local ypos = mo.y - radarpoints_centery
		local x = FixedMul(map_screenwidth, FixedDiv(xpos,radarpoints_width))
		local y = FixedMul(map_screenheight, FixedDiv(ypos,radarpoints_height))
		
		local alart = v.cachePatch("WHATC0")
		if (leveltime / 2) % 2 then
			alart = v.cachePatch("WHATD0")
		end
		drawicon(v, xoff, yoff, x, y, icon_scale / 8, alart, V_HUDTRANSHALF|snapflags|V_PERPLAYER, nil)
	end
end

--Draw minimap in the bottom right corner
B.MinimapHUD = function(v, player, cam)
	if not player.battleconfig_minimap
	or (CBW_Chaos_Library and CBW_Chaos_Library.Gametypes[gametype])
	then
		return
	end
	local k = input.gameControlToKeyNum(GC_CUSTOM2)
	if gamekeydown[k] then
		drawmap(v, BIGMAP_XPOS, BIGMAP_YPOS, FRACUNIT*2/3, FRACUNIT*3/2, 0, nil)
	else
		local y = MINIMAP_YPOS
		if player.spectator then
			y = MINIMAP_YPOS_SPEC
		end
		drawmap(v, MINIMAP_XPOS, y, FRACUNIT/4, FRACUNIT, V_SNAPTOBOTTOM|V_SNAPTORIGHT, 10)
	end
end
