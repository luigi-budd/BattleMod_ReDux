local B = CBW_Battle
local CP = B.ControlPoint

CP.HUD = function(v, player, cam)
	if not(player.realmo and CP.Mode and server) then return end
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
	if (CP.Active or (time <= 10*TICRATE and time&1))
		and player.realmo and player.realmo.valid and pid and pid.valid then
				-- Use the angle based off x and z rather than x and y
		if twodlevel then
			angle = R_PointToAngle2(player.realmo.x, player.realmo.z, pid.x, pid.z) - ANGLE_90
		else
			angle = R_PointToAngle2(player.realmo.x,player.realmo.y,pid.x,pid.y) - player.cmd.angleturn<<16
		end
		cmpangle = ((-angle)/ANG1)/(360/9)+5
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
	//Waiting for CP to open
	if time then
		text = time/TICRATE
		v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign) //Draw timer
	elseif CP.Active then //CP is active
		if not(G_GametypeHasTeams()) then //Free-for-all
			//Get lead capper
			if CP.LeadCapPlr and CP.LeadCapPlr.valid and CP.LeadCapPlr.mo and CP.LeadCapPlr.mo.valid
				and CP.LeadCapPlr.captureamount == CP.LeadCapAmt and CP.LeadCapPlr.playerstate == PST_LIVE
				then
				v.draw(xoffset+right+(center*2), yoffset+bottom, v.getSprite2Patch(CP.LeadCapPlr.mo.skin, SPR2_LIFE),
					flags|V_FLIP, v.getColormap(nil, CP.LeadCapPlr.mo.color))
			end
			text = "\x82"..CP.LeadCapAmt*100/CP.Meter.."%" //Suppose it doesn't hurt to draw this either way...
			v.drawString(xoffset+right,yoffset+4,text,flags,rightalign)
			//Get our player
			if player.mo and CP.Active
				v.draw(xoffset+left-(center*2), yoffset+bottom, v.getSprite2Patch(player.mo.skin, SPR2_LIFE),
					flags, v.getColormap(nil, player.mo.color))
				text = player.captureamount*100/CP.Meter.."%"
				v.drawString(xoffset+left,yoffset+4,text,flags,leftalign)
			end
		else //Team CP
			text = CP.TeamCapAmt[2]*100/CP.Meter.."%"
			v.drawString(xoffset+blue,yoffset+4+bottom,text,flags,leftalign)
			text = CP.TeamCapAmt[1]*100/CP.Meter.."%"
			v.drawString(xoffset+red,yoffset+4+bottom,text,flags,rightalign)
		end		
	end
end