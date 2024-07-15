local B = CBW_Battle
local D = B.Diamond
local CV = B.Console

local captime = CV.DiamondCaptureTime.value * TICRATE*3/2

local function get_angle_to_pos(x, y, z, xx, yy, zz, lookang)
	local angle
	if twodlevel then
		angle = R_PointToAngle2(xx, zz, x, z) - ANGLE_90 + ANGLE_22h
	else
		angle = R_PointToAngle2(xx, yy, x, y) - lookang + ANGLE_22h
	end
	
	local cmpangle = 8
	if (angle >= 0) and (angle < ANGLE_45)
		cmpangle = 1
	elseif (angle >= ANGLE_45) and (angle < ANGLE_90)
		cmpangle = 2
	elseif (angle >= ANGLE_90) and (angle < ANGLE_135)
		cmpangle = 3
	elseif (angle >= ANGLE_135)-- and (angle < ANGLE_180)
		cmpangle = 4
	elseif (angle >= ANGLE_180) and (angle < ANGLE_225)
		cmpangle = 5
	elseif (angle >= ANGLE_225) and (angle < ANGLE_270)
		cmpangle = 6
	elseif (angle >= ANGLE_270) and (angle < ANGLE_315)
		cmpangle = 7
	end
	return cmpangle
end

D.HUD = function(v, player, cam)
	local id = D.Diamond
	if not (B.HUDMain) then return end
	if not (id and id.valid) then return end
	if not (player.realmo) then return end
-- 	if B.PreRoundWait() then return end
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local xoffset = 152
	local yoffset = 4
	--local angle
	local compass
	local compass_2
	local color
	local time = D.PointUnlockTime
	
	local xx = cam.x
	local yy = cam.y
	local zz = cam.z
	local lookang = cam.angle
	if (player.spectator or not cam.chase) and (player.realmo and player.realmo.valid)--Use the realmo coordinates when not using chasecam
		xx = player.realmo.x
		yy = player.realmo.y
		zz = player.realmo.z
		lookang = player.cmd.angleturn<<16
	end
	
	if not (player.battleconfig_newhud) then
		local active_point = D.ActivePoint
		if not active_point then return end
		if id.target == player.realmo and active_point then
			local cmpangle = get_angle_to_pos(active_point.x, active_point.y, active_point.z, xx, yy, zz, lookang)	
			compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))
		else
			local cmpangle = get_angle_to_pos(id.x, id.y, id.z, xx, yy, zz, lookang)	
			compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))
			cmpangle = get_angle_to_pos(active_point.x, active_point.y, active_point.z, xx, yy, zz, lookang)	
			compass_2 = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))
		end
		local pcol = id.color
		color = v.getColormap(TC_DEFAULT,pcol)
		local cflags = flags
		if G_GametypeHasTeams() then
			yoffset = $ + 20
		end
		if id.target == player.realmo and active_point then
			if time > 0 then
				cflags = V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER
			end
			v.draw(xoffset,yoffset,compass,cflags,color)
		else
			v.draw(xoffset-25,yoffset,compass,cflags,color)
		end
		--Draw
		if compass_2 ~= nil then
			color = v.getColormap(TC_DEFAULT,SKINCOLOR_YELLOW)
			if time > 0 then
				cflags = V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER
			end
			v.draw(xoffset,yoffset,compass_2,cflags,color)
		end
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

	if player.battleconfig_newhud then
		yoffset = $+12
	end

	--Get timers
	if id.idle then --Going to respawn in X seconds
		text = id.idle/TICRATE
	end
	
	--Draw timer
	if time > 0 then --Point is going to be unlocked in X seconds
		text = (time/TICRATE)+1
		if player.battleconfig_newhud then
			v.draw(xoffset,yoffset+16, v.cachePatch("RAD_LOCK1"),flags,colormap)
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
			return
		else
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
		end
	end

	if player.battleconfig_newhud then
		if not (D.Diamond and D.Diamond.target) then
			v.draw(xoffset+center,yoffset+8+bottom, v.cachePatch("RAD_TOPAZ1"),flags,colormap)
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
		end
		return
	end

	--Get item holder
	if id.target and id.target.valid and id.target.player then
		if not(G_GametypeHasTeams())
			v.draw(xoffset+right+(center*2), yoffset+bottom, v.getSprite2Patch(id.target.skin, SPR2_LIFE),
				flags|V_FLIP, v.getColormap(id.target.skin, id.target.player.skincolor))
		else
			v.draw(xoffset+right*4+(center*2), yoffset+bottom/2, v.getSprite2Patch(id.target.skin, SPR2_LIFE),
				flags|V_FLIP, v.getColormap(id.target.skin, id.target.player.skincolor))
		end
		if id.target.player.gotcrystal and id.target.player.gotcrystal_time
			local percent_amt = id.target.player.gotcrystal_time * 100 / captime
			local percent_text = percent_amt.."%"
			v.drawString(xoffset+center,yoffset+bottom,percent_text,flags,centeralign)
		end
	end		
end
