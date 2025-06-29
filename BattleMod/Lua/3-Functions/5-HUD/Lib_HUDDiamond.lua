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
	if not (B.HUDMain and B.DiamondGametype()) then return end
	if D.SpawnGrace then --whatever...
		local xoff = 320/2
		local yoff = 24
		if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then yoff = $+12 end
		v.drawString(xoff,yoff,D.SpawnGrace/TICRATE,V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER,"center")
	end
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
	
	if not (CV.FindVarString("battleconfig_hud", {"New", "Minimal"})) then
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

	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then
		yoffset = $+12
	end

	--Get timers
	if id.idle then --Going to respawn in X seconds
		text = id.idle/TICRATE
	end
	
	--Draw timer
	if time > 0 then --Point is going to be unlocked in X seconds
		text = (time/TICRATE)+1
		if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then
			v.draw(xoffset,yoffset+16, v.cachePatch("RAD_LOCK1"),flags,colormap)
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
			return
		else
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
		end
	end

	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then
		if not (D.Diamond and D.Diamond.target) then
			v.draw(xoffset+center,yoffset+8+bottom, v.cachePatch("RAD_TOPAZ1"),flags,colormap)
			v.drawString(xoffset+center,yoffset+bottom,text,flags,centeralign)
		end
		return
	end

	--Get item holder
	if id.target and id.target.valid and id.target.player then
		if not(G_GametypeHasTeams())
			v.drawScaled(
				(xoffset+right+(center*2))*FU,
				(yoffset+bottom)*FU,
				skins[id.target.player.skin].highresscale,
				v.getSprite2Patch(id.target.skin, SPR2_LIFE),
				flags|V_FLIP, v.getColormap(id.target.skin, id.target.player.skincolor)
			)
		else
			v.drawScaled(
				(xoffset+right*4+(center*2))*FU,
				(yoffset+bottom/2)*FU,
				skins[id.target.player.skin].highresscale,
				v.getSprite2Patch(id.target.skin, SPR2_LIFE),
				flags|V_FLIP, v.getColormap(id.target.skin, id.target.player.skincolor)
			)
		end
		if id.target.player.gotcrystal and id.target.player.gotcrystal_time
			local percent_amt = id.target.player.gotcrystal_time * 100 / captime
			local percent_text = percent_amt.."%"
			v.drawString(xoffset+center,yoffset+bottom,percent_text,flags,centeralign)
		end
	end		
end

local ecks = CV_RegisterVar({
    name = "ecks",
    defaultvalue = 1,
    flags = CV_NETVAR|CV_FLOAT,
    PossibleValue = CV_Unsigned
})

local why = CV_RegisterVar({
    name = "why",
    defaultvalue = 1,
    flags = CV_NETVAR|CV_FLOAT,
    PossibleValue = CV_Unsigned
})

local BASEVIDWIDTH = 320
local BASEVIDHEIGHT = 200
-- Draws flag next to players' icons, shows the flag power-up icon, etc.
D.DiamondRankHUD = function(v)
	-- Ensure that the gametype is custom ctf!
	if not(B.DiamondGametype()) then return end

	if G_GametypeHasTeams() then
		local redplayers = 0
		local blueplayers = 0
		local x, y = 0--40, 32

		local players_sorted = {}
		for p in players.iterate do
			table.insert(players_sorted, p)
		end

		-- Properly sort players
		-- TODO: This probably still won't work.. what to do?
		-- Maybe recode the entirety of rankings i guess? :shrug:
		table.sort(players_sorted, function(a, b)
			if a.score == b.score then
			return #a > #b
			else
			return (a.score > b.score)
			end
		end)

		for i=1, #players_sorted do
			local p = players_sorted[i]
			if p.spectator then continue end
			--if p.ctfteam == 0 then continue end

			local cond = (not CV_FindVar("compactscoreboard").value) and (redplayers <= 9 or blueplayers <= 9)
			if p.ctfteam == 1 then
				redplayers = $+1
				--if (redplayers > 8) then continue end
				if cond then 
					x = 32 + (BASEVIDWIDTH/2)
					y = (redplayers * 16) + 16
				else
					x = 14 + (BASEVIDWIDTH/2)
					y = (redplayers * 9) + 20
				end
			elseif p.ctfteam == 2 then
				blueplayers = $+1
				--if (blueplayers > 8) then continue end
				if cond then
					x = 32
					y = (blueplayers * 16) + 16
				else
					x = 14
					y = (blueplayers * 9) + 20
				end
			else 
				continue
			end

			local iconscale = cond and FRACUNIT/2 or FRACUNIT/4
			local fx = cond and x-12 or x-5
			local fy = cond and y+12 or y+8

			if D.Diamond and D.Diamond.valid and p.gotcrystal then
				local intpatch = {v.getSpritePatch(D.Diamond.sprite, D.Diamond.frame)}

				local ring = intpatch[1]
				local flip = (intpatch[2] and V_FLIP) or 0
				v.drawScaled(fx*FRACUNIT, fy*FRACUNIT, iconscale, ring, 0|flip, v.getColormap(0, D.Diamond.color))
			end
		end
	end
end
