local B = CBW_Battle
local CP = B.ControlPoint

CP.HUD = function(v, player, cam)
	if not (player.realmo and CP.Mode and server) then return end
	if not (B.HUDMain) then return end
	if B.PreRoundWait() then return end
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER
	local xoffset = 152
	local yoffset = 4
	local time = CP.Timer
	local angle
	local cmpangle
	local compass
	local color
	local pid = CP.ID[CP.Num]
	
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
	
	if (CP.Active or (time <= 10*TICRATE and time&1)) and not player.battleconfig_newhud
		and pid and pid.valid then
				-- Use the angle based off x and z rather than x and y
		if twodlevel then
			angle = R_PointToAngle2(xx, zz, pid.x, pid.z) - ANGLE_90 + ANGLE_22h
		else
			angle = R_PointToAngle2(xx, yy, pid.x, pid.y) - lookang + ANGLE_22h
		end
		
		local cmpangle = 8
		if (angle >= 0) and (angle < ANGLE_45)
			cmpangle = 1
		elseif (angle >= ANGLE_45) and (angle < ANGLE_90)
			cmpangle = 2
		elseif (angle >= ANGLE_90) and (angle < ANGLE_135)
			cmpangle = 3
		elseif (angle >= ANGLE_135)// and (angle < ANGLE_180)
			cmpangle = 4
		elseif (angle >= ANGLE_180) and (angle < ANGLE_225)
			cmpangle = 5
		elseif (angle >= ANGLE_225) and (angle < ANGLE_270)
			cmpangle = 6
		elseif (angle >= ANGLE_270) and (angle < ANGLE_315)
			cmpangle = 7
		end
		
		compass = v.getSpritePatch("CMPS",A,max(min(cmpangle,8),1))
		local pcol = pid.color
		if (G_GametypeHasTeams() and not(CP.Capturing or CP.Blocked)) or pcol == SKINCOLOR_JET then
			pcol = SKINCOLOR_SILVER
		end
		color = v.getColormap(TC_DEFAULT,pcol)
		//Draw
		v.draw(xoffset,yoffset,compass,flags,color)
	end
	local text = ""
	local center = 8
	local left = -2
	local right = 20
	local blue = center-1
	local red = center+1
	local bottom = 12
	local centeralign = "center"
	local leftalign = "thin-right"
	local rightalign = "thin"
	local dist = 0
	if player.battleconfig_newhud then
		yoffset = $+16
		dist = $+16
	end

	--Waiting for CP to open
	if time then
		if player.battleconfig_newhud then
			v.draw(xoffset,yoffset+8,v.cachePatch("RAD_LOCK1"),flags)
		end
		text = time/TICRATE
		v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign) --Draw timer
	elseif CP.Active then --CP is active
		if not(G_GametypeHasTeams()) then --Free-for-all
			--Get lead capper
			if CP.LeadCapPlr and CP.LeadCapPlr.valid and CP.LeadCapPlr.mo and CP.LeadCapPlr.mo.valid
			and CP.LeadCapPlr.captureamount == CP.LeadCapAmt and CP.LeadCapPlr.playerstate == PST_LIVE
			then
				local leadlifepatch = v.getSprite2Patch(CP.LeadCapPlr.mo.skin, SPR2_LIFE)
				local leadcolormap = v.getColormap(CP.LeadCapPlr.mo.skin, CP.LeadCapPlr.mo.color)
				v.draw(xoffset+right+(center*2)+dist, yoffset+bottom, leadlifepatch, flags|V_FLIP, leadcolormap)
			end
			text = "\x82"..CP.LeadCapAmt*100/CP.Meter.."%" --Suppose it doesn't hurt to draw this either way...
			v.drawString(xoffset+right+dist,yoffset+4,text,flags,rightalign)
			--Get our player
			if player.mo and CP.Active and not player.battleconfig_newhud
				local lifepatch = v.getSprite2Patch(player.mo.skin, SPR2_LIFE)
				local colormap = v.getColormap(player.mo.skin, player.mo.color)
				v.draw(xoffset+left-(center*2)-dist, yoffset+bottom, lifepatch, flags, colormap)
				text = player.captureamount*100/CP.Meter.."%"
				v.drawString(xoffset+left-dist,yoffset+4,text,flags,leftalign)
			end
		else --Team CP
			text = CP.TeamCapAmt[2]*100/CP.Meter.."%"
			v.drawString(xoffset+blue-dist,yoffset+4+bottom,text,flags,leftalign)
			text = CP.TeamCapAmt[1]*100/CP.Meter.."%"
			v.drawString(xoffset+red+dist,yoffset+4+bottom,text,flags,rightalign)
		end		
	end
end