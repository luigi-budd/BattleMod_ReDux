local B = CBW_Battle
local D = B.Diamond
D.HUD = function(v, player, cam)
	local id = D.ID
	if not(id and id.valid) then return end
	if not(player.realmo) then return end
-- 	if B.PreRoundWait() then return end
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local xoffset = 152
	local yoffset = 4
	local angle
	local compass
	local color
	if player.realmo and player.realmo.valid then
		if id.target == player.mo then
			compass = v.cachePatch("DIAMOND")
		else
			if twodlevel then
				angle = R_PointToAngle2(player.realmo.x, player.realmo.z, id.x, id.z) - ANGLE_90
			else
				angle = R_PointToAngle2(player.realmo.x,player.realmo.y,id.x,id.y) - player.cmd.angleturn<<16 //R_PointToAngle(player.realmo.x,player.realmo.y)
			end
			local cmpangle = ((-angle)/ANG1)/(360/9)+5
			compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))
		end
		local pcol = id.color
		color = v.getColormap(TC_DEFAULT,pcol)
		local cflags = flags
		if id.target == player.realmo then
			cflags = V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER
		end
		//Draw
		v.draw(xoffset,yoffset,compass,cflags,color)
	end
	local text = ""
	local center = 8
	local left = -2
	local right = 8
	local blue = center-1
	local red = center+1
	local bottom = 20
	local centeralign = "center"
	local leftalign = "thin-right"
	local rightalign = "thin"
	//Get timer
	if id.idle then
		local text = id.idle/TICRATE
		v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign) //Draw timer
	end
	//Get item holder
	if id.target and id.target.valid and id.target.player then
		if not(G_GametypeHasTeams())
		v.draw(xoffset+right+(center*2), yoffset+bottom, v.getSprite2Patch(id.target.skin, SPR2_LIFE),
			flags|V_FLIP, v.getColormap(nil, id.target.player.skincolor))
		else
		v.draw(xoffset+right*4+(center*2), yoffset+bottom/2, v.getSprite2Patch(id.target.skin, SPR2_LIFE),
			flags|V_FLIP, v.getColormap(nil, id.target.player.skincolor))
-- 		v.draw(xoffset+center, yoffset+bottom+8, v.getSprite2Patch(id.target.skin, SPR2_LIFE),
-- 			flags|V_FLIP, v.getColormap(nil, id.target.player.skincolor))
		end
	end		
end