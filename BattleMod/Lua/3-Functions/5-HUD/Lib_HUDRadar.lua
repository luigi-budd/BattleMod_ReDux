--HUD_ScanRadar.lua originally from CBW_Chaos
local B = CBW_Battle
local D = B.Diamond
local F = B.CTF
local A = B.Arena

B.clamp = function(num, minimum, maximum)
	return min(maximum, max(num, minimum))
end

B.screentransform = function(x, y, z, camz, ang, aim, realwidth, realheight)
	z = $ - camz
	aim = B.clamp(aim, -ANGLE_90 + 1, ANGLE_90 - 1)
	
	local width = 160
	local height = 100
	
	--FOV calcs
	local FOV = CV_FindVar("fov").value * FRACUNIT
    local fovang2 = (FOV + (consoleplayer and consoleplayer.fovadd or 90*FRACUNIT))/2
    local fovtan = tan(FixedAngle(fovang2))
    local fg = width*fovtan
	
	--Screen width calculations
	local diffwidth = realwidth-(width*2)
	local clampang = ANGLE_45 + (ANG1*5/64)*diffwidth
	
	--Horizontal
    local h = R_PointToDist(x, y)
	local diffang = ang - R_PointToAngle(x, y)
    local da = B.clamp(diffang, -clampang, clampang)
	local clampedh = 0
	if da > diffang
		clampedh = 1--left side of screen
	elseif da < diffang
		clampedh = 2--right side of screen
	end
	
	--Screen height calculations
	local diffheight = realheight-(height*2)
	local clampvert = FRACUNIT*3/5 + (FRACUNIT*3/50/16)*diffheight
	
	--Vertical
	local diffaim = tan(aim) - FixedDiv(z, 1 + FixedMul(cos(da), h))
	local dv = B.clamp(diffaim, -clampvert, clampvert)
	local clampedv = 0
	if dv > diffaim
		clampedv = 1--top side of screen
	elseif dv < diffaim
		clampedv = 2--bottom side of screen
	end
	
	--Final hud position calcs
    local sx = width<<FRACBITS + FixedMul(tan(da), fg)
    local sy = height<<FRACBITS + FixedMul(dv, fg)
    local scale = FixedDiv(width<<FRACBITS, h+1)
	
    return sx, sy, scale, clampedv, clampedh
end

B.RadarHUD = function(v, player, cam)
	local pmo = player.realmo
	
	if not (pmo)
	or not (pmo.valid)
	or not (player.battleconfig_newhud)
	or splitscreen
		return
	end
	
	for r = 1, 6 do
		local t = {}
		local scale = FRACUNIT/2
		local trans = V_10TRANS
		local fade = 0
		local fade2 = 0
		local patch
		local patch_clamped
		local patch_arrow
		local allow_clamp = true
		local center = false
		local yoff = false
		local float = false
		local color = nil
		local flags = V_PERPLAYER
		
		--Goal
		if r == 1 or r == 2
			if r == 1 and D.RedGoal
				table.insert(t, D.RedGoal)
			end
			if r == 2 and D.BlueGoal
				table.insert(t, D.BlueGoal)
			end
			scale = FRACUNIT/6
			
			if (D.ID and D.ID.valid and D.ID.target and D.ID.target.valid and D.ID.target.player)
				local runner_team = D.ID.target.player.ctfteam
				
				if (r != runner_team)
					if (consoleplayer and consoleplayer.spectator) or (runner_team == displayplayer.ctfteam)
						patch = v.cachePatch("RAD_GOAL2")
					else
						patch = v.cachePatch("RAD_DEFEN")
					end
				else
					continue
					--patch = v.cachePatch("RAD_GOAL1")
					--trans = V_70TRANS
					--scale = FRACUNIT/7
				end
			else
				continue
				--patch = v.cachePatch("RAD_GOAL1")
				--trans = V_40TRANS
			end
			center = true
			float = true
			allow_clamp = false
		end
		--Red Flag
		if r == 3
			if not (F.RedFlag and F.RedFlag.valid) then continue end
			table.insert(t,F.RedFlag)
			fade = V_40TRANS
			fade2 = V_60TRANS
			patch = v.cachePatch("RAD_FLAG")
			color = SKINCOLOR_RED
			center = true
		end
		--Blue Flag
		if r == 4
			if not (F.BlueFlag and F.BlueFlag.valid) then continue end
			table.insert(t,F.BlueFlag)
			fade = V_40TRANS
			fade2 = V_60TRANS
			patch = v.cachePatch("RAD_FLAG")
			color = SKINCOLOR_BLUE
			center = true
			flags = $|V_FLIP
		end
		--Ruby
		if r == 5
			if not (D.ID and D.ID.valid) then continue end
			table.insert(t,D.ID)
			fade = V_40TRANS
			fade2 = V_60TRANS
			patch = v.cachePatch("RAD_RUBY")
			color = D.ID.color
			scale = FRACUNIT / 2
			center = true
		end
		--Bounty
		if r == 6
			if not (A.Bounty and A.Bounty.mo and A.Bounty.mo.valid) then continue end
			table.insert(t,A.Bounty.mo)
			fade = V_40TRANS
			fade2 = V_60TRANS
			patch = v.cachePatch("RAD_CROWN")
			scale = FRACUNIT / 6
			center = true
		end
		
		--Get camera info
		local xx = cam.x
		local yy = cam.y
		local zz = cam.z
		local angle = 0
		local aiming = cam.aiming
		if player.playerstate == PST_LIVE
			angle = cam.angle
			if (player.spectator or not cam.chase)--Use the realmo coordinates when not using chasecam
				xx = pmo.x
				yy = pmo.y
				zz = pmo.z
				angle = player.cmd.angleturn<<FRACBITS
				aiming = player.cmd.aiming<<FRACBITS
			end
		end
		
		for n = 1, #t do
			local mo = t[n]
			if not(mo.valid and mo.health) continue end
			local yoffset = 0
			if center
				yoffset = mo.height / 2
			elseif yoff
				yoffset = yoff
			end
			if float
				yoffset = $ + (64 * FRACUNIT)
			end
			
			--Calculate
			local dx, dy, ds, clampedv, clampedh = B.screentransform(mo.x, mo.y, mo.z + yoffset, zz, angle, aiming, v.width()/v.dupx(), v.height()/v.dupy())
			
			--Check distance
			local final_trans = trans
			local final_patch = patch
			local dist = R_PointToDist(mo.x,mo.y)
			local clampscale = true
			
			if (clampedv or clampedh)
				if not allow_clamp
					continue
				end
				if (patch_clamped)
					final_patch = patch_clamped
				end
			else
				if dist < pmo.scale * 2040
					if fade and not patch_arrow
						continue
					end
					--Don't draw arrows for items that aren't in our view
					if patch_arrow and P_CheckSight(pmo, mo)
						final_trans = 0
						final_patch = patch_arrow
						color = nil
						clampscale = false
					end
				elseif dist < pmo.scale * 2544
					if fade2
						final_trans = fade2
					end
				elseif dist < pmo.scale * 3048
					if fade
						final_trans = fade
					end
				end
			end
			
			--Clamped objects lose scale
			if clampscale
				ds = min(FRACUNIT*2/3, ds)
			end
			
            --Finally draw the damn thing
			if color == 0
				color = nil
			end
			v.drawScaled(dx, dy, max(1, scale + ds), final_patch, final_trans|flags, color and v.getColormap(TC_RAINBOW, color))
		end
	end
end