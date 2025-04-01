--[[/*
rev: intangible cam, credit goes to:
- a chunk of P_MoveChaseCam 
- clairebun's intangible cam code

toggle:
nosolidcam on/off | default: off
*/]]

local path = "client/nosolidcam.dat"
local nosolidcam = false
local file = io.openlocal(path, "r")
if file then
	for line in file:lines() do COM_BufInsertText(consoleplayer, line) end
    file:close()
end

local red   = '\x85'
local green = '\x83'
COM_AddCommand("nosolidcam", function(p, arg)
	local str = (arg and type(arg) == "string") and string.lower(arg) or nil
	if not p or not (str == "on" or str == "off")  then 
		CONS_Printf(p, "nosolidcam <on/off>: Turns intangible camera on or off.")
		return 
	end

	nosolidcam = str == "on" and true or false
	local color = nosolidcam and green or red 
	CONS_Printf(p,color+"nosolidcam was turned "+str+".")

	local file = io.openlocal(path, "w")
	file:write("nosolidcam "+str)
	file:close()
end, COM_LOCAL)

local t_cam_dist = -42
local t_cam_height = -42
local t_cam_rotate = -42
local t_cam2_dist = -42
local t_cam2_height = -42
local t_cam2_rotate = -42
local objectplacing = false

-- oops these are unused lmao
local function calc_chase_post_img(p, ccam)

end

local function reset_camera(p, ccam)

end

local function camera_thinker(p, ccam, resetcalled)

end

local function cam_get_floorz(ccam, sector, midx, midy, unk)

end

local function cam_get_ceilingz(ccam, sector, midx, midy, unk)

end

local function control_style(p)

end

local function clip_aim_pitch(ang)

end

--// rev: Taken straight from source code.
local function move_chase_cam_analog(p, ccam, resetcalled)
	--// We probably shouldn't move the camera if there is no player or player mobj somehow
	if not (p or p.mo) then return true end
	local is_p1 = p == consoleplayer
	local is_p2 = p == secondarydisplayplayer
	local localangle = 0
	local localangle2 = 0
	local localaiming = consoleplayer.aiming
	local localaiming2 = secondarydisplayplayer and secondarydisplayplayer.aiming or 0
	ccam.aiming = p.aiming
	p.awayviewaiming = ccam.aiming

	if consoleplayer 		  then localangle = consoleplayer.cmd.angleturn << 16 end --mo.angle
	if secondarydisplayplayer then localangle2 = secondarydisplayplayer.cmd.angleturn << 16 end --mo.angle

	local angle, focusangle, focusaiming = 0, 0, 0
	local x, y, z, dist, distxy, distz = 0, 0, 0, 0, 0, 0
	local viewpointx, viewpointy, pviewheight, slopez = 0, 0, 0, 0
	local camrotate, camorbit, camstill, camspeed, camdist, camheight = 0, 0, 0, 0, 0, 0
	local f1, f2 = 0, 0

	local camsideshift = {0, 0}
	local shiftx, shifty = 0, 0

	local mo = p.mo
	local angle = 0
	local newsubsec = 0
	local sign = nil

	local cv_exitmove = nil --cv_exitmove.value
	if p.exiting then
		if 	mo.target and mo.target.type == MT_SIGN and mo.target.spawnpoint and
			not ((gametyperules&GTR_FRIENDLY) and (netgame or multiplayer) and cv_exitmove) and
			not (twodlevel or (mo.flags2&MF2_TWOD))
		then
			sign = mo.target
		elseif ((p.powers[pw_carry] == CR_NIGHTSMODE) and
				not (p.mo.state >= states[S_PLAY_NIGHTS_TRANS1]
					and p.mo.state <= states[S_PLAY_NIGHTS_TRANS6])
				)
		then
			calc_chase_post_img(p, ccam)
			return true
		end
	end

	--cameranoclip = (sign || player->powers[pw_carry] == CR_NIGHTSMODE || player->pflags & PF_NOCLIP) || (mo->flags & (MF_NOCLIP|MF_NOCLIPHEIGHT)); // Noclipping player camera noclips too!!
	local cv_chasecam 			= CV_FindVar("chasecam").value
	local cv_cam_rotate 		= CV_FindVar("cam_rotate").value 
	local cv_cam_rotspeed 		= CV_FindVar("cam_rotspeed").value
	local cv_cam_shiftfacing 	= CV_FindVar("cam_shiftfacingchar")
	local cv_cam_dist 			= CV_FindVar("cam_dist").value
	local cv_cam_height 		= CV_FindVar("cam_height").value
	local cv_cam_orbit 			= CV_FindVar("cam_orbit").value
	local cv_cam_speed 			= CV_FindVar("cam_speed").value
	local cv_analog 			= CV_FindVar("sessionanalog").value

	--//p2
	local cv_chasecam2 			= CV_FindVar("chasecam2").value

	if not p.climbing or (p.powers[pw_carry] == CR_NIGHTSMODE) or p.playerstate == PST_DEAD or tutorialmode then
		if p.spectator then return true end
		if not cv_chasecam --[[and ccam == camera]] then return true end
		if not cv_chasecam2 --[[and ccam == camera2]] then return true end
	end

	if not ccam.chase and not resetcalled then
		if 		is_p1 			then focusangle = localangle
		elseif 	is_p2		 	then focusangle = localangle2
		else 						 focusangle = mo.angle
		end

		if is_p1 then
			camrotate = cv_cam_rotate
		elseif is_p2 then
			camrotate = cv_cam2_rotate
		else
			camrotate = 0
		end

		ccam.angle = focusangle + FixedAngle(camrotate*FRACUNIT)
		reset_camera(p, ccam)
		return true
	end

	ccam.radius = FixedMul(20*FRACUNIT, mo.scale)
	ccam.height = FixedMul(16*FRACUNIT, mo.scale)

	--// Don't run while respawning from a starpost
	--// Inu 4/8/13 Why not?!
	--if leveltime > 0 and timeinmap <= 0 then return true end

	if p.powers[pw_carry] == CR_NIGHTSMODE then
		focusangle = mo.angle
		focusaiming = 0
	elseif sign then
		focusangle = FixedAngle(sign.spawnpoint.angle) + ANGLE_180
		focusaiming = 0
	elseif is_p1 then
		focusangle = localangle
		focusaiming = localaiming
	elseif is_p2 then
		focusangle = localangle2
		focusaiming = localaiming2
	else
		focusangle = p.cmd.angleturn << 16
		focusaiming = p.aiming
	end

	if camera_thinker(p, ccam, resetcalled) then return true end
	
	if p == secondarydisplayplayer then
		--// Camera 2
		camspeed = cv_cam2_speed
		camstill = cv_cam2_still
		camorbit = cv_cam2_orbit
		camrotate = cv_cam2_rotate
		camdist = FixedMul(cv_cam2_dist, mo.scale)
		camheight = FixedMul(cv_cam2_height, mo.scale)
	else --// default cam
		camspeed = cv_cam_speed
		camstill = cv_cam_still
		camorbit = cv_cam_orbit
		camrotate = cv_cam_rotate
		camdist = FixedMul(cv_cam_dist, mo.scale)
		camheight = FixedMul(cv_cam_height, mo.scale)
	end

	if (not twodlevel or (mo.flags2&MF2_TWOD)) and not (p.powers[pw_carry] == CR_NIGHTSMODE) then
		camheight = FixedMul(camheight, p.camerascale)
	end

	--// ifdef REDSANALOG
	if (control_style(p) == CS_LMAOGALOG and (p.cmd.buttons&(BT_CAMLEFT|BT_CAMRIGHT)) == (BT_CAMLEFT|BT_CAMRIGHT)) then
		camstill = true
		if (camspeed < 4*FRACUNIT/5) then camspeed = 4*FRACUNIT/5 end
	end
	--// endif

	if mo.eflags&MFE_VERTICALFLIP then camheight = $+ccam.height end
	if twodlevel or (mo.flags2&MF2_TWOD) then
		angle = ANGLE_90
	elseif camstill or resetcalled or p.playerstate == PST_DEAD then
		angle = ccam.angle
	--elseif p.powers[pw_carry] == CR_NIGHTSMODE then --// Nights level 
	--[[
	{
		if ((player->pflags & PF_TRANSFERTOCLOSEST) && player->axis1 && player->axis2)
		{
			angle = R_PointToAngle2(player->axis1->x, player->axis1->y, player->axis2->x, player->axis2->y);
			angle += ANGLE_90;
		}
		else if (mo->target)
		{
			if (mo->target->flags2 & MF2_AMBUSH)
				angle = R_PointToAngle2(mo->target->x, mo->target->y, mo->x, mo->y);
			else
				angle = R_PointToAngle2(mo->x, mo->y, mo->target->x, mo->target->y);
		}
	}
	]]
	elseif control_style(p) == CS_LMAOGALOG and not sign then --// Analog
		angle = R_PointToAngle2(ccam.x, ccam.y, mo.x, mo.y)

	elseif demoplayback then
		angle = focusangle
		focusangle = R_PointToAngle2(ccam.x, ccam.y, mo.x, mo.y)
		if is_p1 then
			if (focusangle >= localangle) then
				force_local_angle(p, localangle + (abs(focusangle - localangle)>>5))
			else
				force_local_angle(p, localangle - (abs(focusangle - localangle)>>5))
			end
		end
	else
		angle = focusangle + FixedAngle(camrotate*FRACUNIT)
	end

	if 	not resetcalled and (cv_analog ~= 0 or demoplayback) and (
			(is_p1 and t_cam_rotate  ~= 42) or 
			(is_p2 and t_cam2_rotate ~= 42)
		)
	then
		angle = FixedAngle(camrotate*FRACUNIT)
	end


	if 	((is_p1) and cv_analog ~= 0) or 
		((is_p1) and cv_analog ~= 0) or
		demoplayback and not sign and not objectplacing and not (twodlevel or (mo.flags2&MF2_TWOD)) and
		(p.powers[pw_carry] ~= CR_NIGHTSMODE) and displayplayer == consoleplayer
	then
		--// ifdef REDSANALOG
		--if p.cmd.buttons&(BT_CAMLEFT|BT_CAMRIGHT) == (BT_CAMLEFT|BT_CAMRIGHT) then else end
		--//endif
		if p.cmd.buttons&BT_CAMRIGHT then
			if is_p1 then
				angle = $-FixedAngle(cv_cam_rotspeed*FRACUNIT)
			else
				angle = $-FixedAngle(cv_cam2_rotspeed*FRACUNIT)
			end
		elseif p.cmd.buttons&BT_CAMLEFT then
			if is_p1 then
				angle = $+FixedAngle(cv_cam_rotspeed*FRACUNIT)
			else
				angle = $+FixedAngle(cv_cam2_rotspeed*FRACUNIT)
			end
		end
	end

	local cstyle = control_style(is_p1) and 1 or 2
	if cstyle == CS_SIMPLE and not sign then
		--// Shift the camera slightly to the sides depending on the player facing direction
		local forplayer = (is_p1) and 1 or 2
		local shift = FixedMul(sin(mo.angle - angle), cv_cam_shiftfacing.value)--cv_cam_shiftfacing[forplayer].value)

		--[[
		if (player->powers[pw_carry] == CR_NIGHTSMODE)
		{
			fixed_t cos = FINECOSINE((angle_t) (player->flyangle * ANG1)>>ANGLETOFINESHIFT);
			shift = FixedMul(shift, min(FRACUNIT, player->speed*abs(cos)/6000));
			shift += FixedMul(camsideshift[forplayer] - shift, FRACUNIT-(camspeed>>2));
		}
		else if (ticcmd_centerviewdown[(thiscam == &camera) ? 0 : 1])
			shift = FixedMul(camsideshift[forplayer], FRACUNIT-camspeed);
		--]]
		shift = $+FixedMul(camsideshift[forplayer] - $, FRACUNIT-(camspeed>>3))

		shiftx = -FixedMul(sin(angle), shift)
		shifty =  FixedMul(cos(angle), shift)
	end


	--// sets ideal cam pos
	if twodlevel or (mo.flags2&MF2_TWOD) then
		dist = 480<<FRACBITS
	--[[else if (player->powers[pw_carry] == CR_NIGHTSMODE
		|| ((maptol & TOL_NIGHTS) && player->capsule && player->capsule->reactiontime > 0 && player == &players[player->capsule->reactiontime-1]))
		dist = 320<<FRACBITS;]]
	else
		dist = camdist
		if sign then --// signpost camera has specific placement
			camheight = mo.scale << 7
			camspeed = FRACUNIT/12
		elseif control_style(p) == CS_LMAOGALOG then --// x1.2 dist for analog
			dist = FixedMul(dist, 6*FRACUNIT/5)
			camheight = FixedMul(camheight, 6*FRACUNIT/5)
		end

		if 	p.climbing or p.exiting or p.playerstate == PST_DEAD or p.powers[pw_carry] == CR_ROPEHANG or
			p.powers[pw_carry] == CR_GENERIC or p.powers[pw_carry] == CR_MACESPIN
		then
			dist = $ << 1
		end
	end

	if not sign and not (twodlevel or (mo.flags2&MF2_TWOD)) and not (p.powers[pw_carry] == CR_NIGHTSMODE) then
		dist = FixedMul(dist, p.camerascale)
	end

	local checkdist = dist
	if checkdist < 128*FRACUNIT then checkdist = 128*FRACUNIT end

	if not (twodlevel or (mo.flags2&MF2_TWOD)) and not (p.powers[pw_carry] == CR_NIGHTSMODE) then --// This block here is like 90% Lach's work, thanks bud
		if not resetcalled and (is_p1 and cv_cam_adjust) or (is_p2 and cv_cam2_adjust) then
			if 	not (mo.eflags&MFE_JUSTHITFLOOR) and P_IsObjectOnGround(mo) --// Check that player is grounded
				and ccam.ceilingz - ccam.floorz >= P_GetPlayerHeight(p)     --// Check that camera's sector is large enough for the player to fit into, at least
			then
				if mo.eflags&MFE_VERTICALFLIP then --// if player is upside-down
					--//z = min(z, thiscam->ceilingz); // solution 1: change new z coordinate to be at LEAST its ground height
					slopez = $+min(ccam.ceilingz - mo.z, 0) --// solution 2: change new z coordinate by the difference between camera's ground and top of player
				else  --// player is not upside-down
					--//z = max(z, thiscam->floorz); // solution 1: change new z coordinate to be at LEAST its ground height
					slopez = $+max(ccam.floorz - mo.z - mo.height, 0) --// solution 2: change new z coordinate by the difference between camera's ground and top of player
				end
			end
		end
	end

	if camorbit then --//Sev here, I'm guessing this is where orbital cam lives

	--[[//ifdef HWRENDER
		if rendermode == render_opengl and not cl_glshearing then
			distxy = FixedMul(dist, cos(focusaiming))
		else
	--//endif]]
		distxy = dist
		distz  = -FixedMul(dist, sin(focusaiming))--+slopez
	else
		distxy = dist
		distz = slopez
	end

	if sign then
		x = sign.x - FixedMul(cos(angle),distxy)
		y = sign.y - FixedMul(sin(angle),distxy)
	else
		x = mo.x - FixedMul(cos(angle),distxy)
		y = mo.y - FixedMul(sin(angle),distxy)
	end

	pviewheight = FixedMul(41*p.height/48, mo.scale)

	--[[
	if sign then
		if sign.eflags&MFE_VERTICALFLIP then
			z = sign.ceilingz - pviewheight - camheight
		else
			z = sign.floorz + pviewheight + camheight
		end
	else
		if mo.eflags&MFE_VERTICALFLIP then
			z = mo.z + mo.height - pviewheight - camheight + distz
		else
			z = mo.z + pviewheight + camheight + distz
		end
	end
	--]] 	-- no thanks, we won't stick to ceilings/floors
	
	if sign then
		if sign.eflags&MFE_VERTICALFLIP then
			z = pviewheight - camheight
		else
			z = pviewheight + camheight
		end
	else
		if mo.eflags&MFE_VERTICALFLIP then
			z = mo.z + mo.height - pviewheight - camheight + distz
		else
			z = mo.z + pviewheight + camheight + distz
		end
	end


	--[[// move camera down to move under lower ceilings
	newsubsec = R_PointInSubsectorOrNull(((mo->x>>FRACBITS) + (thiscam->x>>FRACBITS))<<(FRACBITS-1), ((mo->y>>FRACBITS) + (thiscam->y>>FRACBITS))<<(FRACBITS-1));

	if (!newsubsec)
		newsubsec = thiscam->subsector;

	if (newsubsec)
	{
		fixed_t myfloorz, myceilingz;
		fixed_t midz = thiscam->z + (thiscam->z - mo->z)/2;
		fixed_t midx = ((mo->x>>FRACBITS) + (thiscam->x>>FRACBITS))<<(FRACBITS-1);
		fixed_t midy = ((mo->y>>FRACBITS) + (thiscam->y>>FRACBITS))<<(FRACBITS-1);

		// Cameras use the heightsec's heights rather then the actual sector heights.
		// If you can see through it, why not move the camera through it too?
		if (newsubsec->sector->camsec >= 0)
		{
			myfloorz = sectors[newsubsec->sector->camsec].floorheight;
			myceilingz = sectors[newsubsec->sector->camsec].ceilingheight;
		}
		else if (newsubsec->sector->heightsec >= 0)
		{
			myfloorz = sectors[newsubsec->sector->heightsec].floorheight;
			myceilingz = sectors[newsubsec->sector->heightsec].ceilingheight;
		}
		else
		{
			myfloorz = P_CameraGetFloorZ(thiscam, newsubsec->sector, midx, midy, NULL);
			myceilingz = P_CameraGetCeilingZ(thiscam, newsubsec->sector, midx, midy, NULL);
		}

		// Check list of fake floors and see if floorz/ceilingz need to be altered.
		if (newsubsec->sector->ffloors)
		{
			ffloor_t *rover;
			fixed_t delta1, delta2;
			INT32 thingtop = midz + thiscam->height;

			for (rover = newsubsec->sector->ffloors; rover; rover = rover->next)
			{
				fixed_t topheight, bottomheight;
				if (!(rover->fofflags & FOF_BLOCKOTHERS) || !(rover->fofflags & FOF_EXISTS) || !(rover->fofflags & FOF_RENDERALL) || (rover->master->frontsector->flags & MSF_NOCLIPCAMERA))
					continue;

				topheight = P_CameraGetFOFTopZ(thiscam, newsubsec->sector, rover, midx, midy, NULL);
				bottomheight = P_CameraGetFOFBottomZ(thiscam, newsubsec->sector, rover, midx, midy, NULL);

				delta1 = midz - (bottomheight
					+ ((topheight - bottomheight)/2));
				delta2 = thingtop - (bottomheight
					+ ((topheight - bottomheight)/2));
				if (topheight > myfloorz && abs(delta1) < abs(delta2))
					myfloorz = topheight;
				if (bottomheight < myceilingz && abs(delta1) >= abs(delta2))
					myceilingz = bottomheight;
			}
		}

	// Check polyobjects and see if floorz/ceilingz need to be altered
	{
		INT32 xl, xh, yl, yh, bx, by;
		validcount++;

		xl = (unsigned)(tmbbox[BOXLEFT] - bmaporgx)>>MAPBLOCKSHIFT;
		xh = (unsigned)(tmbbox[BOXRIGHT] - bmaporgx)>>MAPBLOCKSHIFT;
		yl = (unsigned)(tmbbox[BOXBOTTOM] - bmaporgy)>>MAPBLOCKSHIFT;
		yh = (unsigned)(tmbbox[BOXTOP] - bmaporgy)>>MAPBLOCKSHIFT;

		BMBOUNDFIX(xl, xh, yl, yh);

		for (by = yl; by <= yh; by++)
			for (bx = xl; bx <= xh; bx++)
			{
				INT32 offset;
				polymaplink_t *plink; // haleyjd 02/22/06

				if (bx < 0 || by < 0 || bx >= bmapwidth || by >= bmapheight)
					continue;

				offset = by*bmapwidth + bx;

				// haleyjd 02/22/06: consider polyobject lines
				plink = polyblocklinks[offset];

				while (plink)
				{
					polyobj_t *po = plink->po;

					if (po->validcount != validcount) // if polyobj hasn't been checked
					{
						sector_t *polysec;
						fixed_t delta1, delta2, thingtop;
						fixed_t polytop, polybottom;

						po->validcount = validcount;

						if (!P_PointInsidePolyobj(po, x, y) || !(po->flags & POF_SOLID))
						{
							plink = (polymaplink_t *)(plink->link.next);
							continue;
						}

						// We're inside it! Yess...
						polysec = po->lines[0]->backsector;

						if (polysec->flags & MSF_NOCLIPCAMERA)
						{ // Camera noclip polyobj.
							plink = (polymaplink_t *)(plink->link.next);
							continue;
						}

						if (po->flags & POF_CLIPPLANES)
						{
							polytop = polysec->ceilingheight;
							polybottom = polysec->floorheight;
						}
						else
						{
							polytop = INT32_MAX;
							polybottom = INT32_MIN;
						}

						thingtop = midz + thiscam->height;
						delta1 = midz - (polybottom + ((polytop - polybottom)/2));
						delta2 = thingtop - (polybottom + ((polytop - polybottom)/2));

						if (polytop > myfloorz && abs(delta1) < abs(delta2))
							myfloorz = polytop;

						if (polybottom < myceilingz && abs(delta1) >= abs(delta2))
							myceilingz = polybottom;
					}
					plink = (polymaplink_t *)(plink->link.next);
				}
			}
	}

		// crushed camera
		if (myceilingz <= myfloorz + thiscam->height && !resetcalled && !cameranoclip)
		{
			P_ResetCamera(player, thiscam);
			return true;
		}

		// camera fit?
		if (myceilingz != myfloorz
			&& myceilingz - thiscam->height < z)
		{
/*			// no fit
			if (!resetcalled && !cameranoclip)
			{
				P_ResetCamera(player, thiscam);
				return true;
			}
*/
			z = myceilingz - thiscam->height-FixedMul(11*FRACUNIT, mo->scale);
			// is the camera fit is there own sector
		}

		// Make the camera a tad smarter with 3d floors
		if (newsubsec->sector->ffloors && !cameranoclip)
		{
			ffloor_t *rover;

			for (rover = newsubsec->sector->ffloors; rover; rover = rover->next)
			{
				fixed_t topheight, bottomheight;
				if ((rover->fofflags & FOF_BLOCKOTHERS) && (rover->fofflags & FOF_RENDERALL) && (rover->fofflags & FOF_EXISTS) && !(rover->master->frontsector->flags & MSF_NOCLIPCAMERA))
				{
					topheight = P_CameraGetFOFTopZ(thiscam, newsubsec->sector, rover, midx, midy, NULL);
					bottomheight = P_CameraGetFOFBottomZ(thiscam, newsubsec->sector, rover, midx, midy, NULL);

					if (bottomheight - thiscam->height < z
						&& midz < bottomheight)
						z = bottomheight - thiscam->height-FixedMul(11*FRACUNIT, mo->scale);

					else if (topheight + thiscam->height > z
						&& midz > topheight)
						z = topheight;

					if ((mo->z >= topheight && midz < bottomheight)
						|| ((mo->z < bottomheight && mo->z+mo->height < topheight) && midz >= topheight))
					{
						// Can't see
						if (!resetcalled)
							P_ResetCamera(player, thiscam);
						return true;
					}
				}
			}
		}
	}
	--]]

	if mo.type == MT_EGGTRAP then
		z = mo.z + 128*FRACUNIT + pviewheight + camheight
	end

	--[[
	if ccam.z < ccam.floorz and not cameranoclip then 
		ccam.z = ccam.floorz
	end]]

	--// point viewed by the camera
	--// this point is just 64 unit forward the player
	dist = FixedMul(64 << FRACBITS, mo.scale)
	if sign then
		viewpointx = sign.x + FixedMul(cos(angle), dist)
		viewpointy = sign.y + FixedMul(sin(angle), dist)
	else
		viewpointx = mo.x + shiftx + FixedMul(cos(angle), dist)
		viewpointy = mo.y + shifty + FixedMul(sin(angle), dist)
	end

	if not camstill and not resetcalled and not paused then
		ccam.angle = R_PointToAngle2(ccam.x, ccam.y, viewpointx, viewpointy)
	end

	--[[
		if twodlevel or (mo.flags2&MF2_TWOD) then
			ccam.angle = angle
		end
	]]

	--// follow the player
	--[[
		/*if (player->playerstate != PST_DEAD && (camspeed) != 0)
		{
			if (P_AproxDistance(mo->x - thiscam->x, mo->y - thiscam->y) > (checkdist + P_AproxDistance(mo->momx, mo->momy)) * 4
				|| abs(mo->z - thiscam->z) > checkdist * 3)
			{
				if (!resetcalled)
					P_ResetCamera(player, thiscam);
				return true;
			}
		}*/
	]]

	--// rev: if 2d, just stop using custom cam and let vanilla do everytihng.
	--if twodlevel or (mo.flags2&MF2_TWOD) then return end -- probably dont want to return

	ccam.momx = FixedMul(x - ccam.x, camspeed)
	ccam.momy = FixedMul(y - ccam.y, camspeed)


	if 	ccam.subsector.sector.damagetype == SD_DEATHPITTILT
		and ccam.z < ccam.subsector.sector.floorheight + 256*FRACUNIT
		and FixedMul(z - ccam.z, camspeed) < 0
	then
		ccam.momz = 0 --// Don't go down a death pit
	else
		ccam.momz = FixedMul(z - ccam.z, camspeed)
	end

	ccam.momx = $+FixedMul(shiftx, camspeed)
	ccam.momy = $+FixedMul(shifty, camspeed)

	--// compute aiming to look the viewed point
	f1 = viewpointx - ccam.x 
	f2 = viewpointy - ccam.y
	dist = FixedMul(f1, f2)

	if (mo.eflags&MFE_VERTICALFLIP) then
		local sgn = (sign and sign.ceilingz or mo.z+mo.height) - P_GetPlayerHeight(p)
		angle = R_PointToAngle2(0, ccam.z+ccam.height, dist, sgn, sgn)
	else
		local sgn = (sign and sign.floorz or mo.z) + P_GetPlayerHeight(p)
		angle = R_PointToAngle2(0, ccam.z, dist, sgn)
	end

	if p.playerstate ~= PST_DEAD then
		local aim = focusaiming < ANGLE_180 and focusaiming/2 or InvAngle(InvAngle(focusaiming)/2) --// overcomplicated version of '((signed)focusaiming)/2;'
		angle = $+(aim)
	end

	--[[
	if twodlevel or (mo.flags2&MF2_TWOD) or not camstill then --// Keep the view still...
		clip_aim_pitch(angle)
		dist = ccam.aiming - angle
		ccam.aiming = $-(dist>>3)
	end
	--]]

	--// Make player translucent if camera is too close (only in single player).
	--// rev: find a way to make it work in netplay? also walls transparent if cam is too close. Let's see if this works out.
	if not (multiplayer or netgame) and not splitscreen then
		local vx = ccam.x
		local vy = ccam.y
		local vz = ccam.z + ccam.height / 2

		--[[
		if (player->awayviewtics && player->awayviewmobj != NULL && !P_MobjWasRemoved(player->awayviewmobj))		// Camera must obviously exist
		{
			vx = player->awayviewmobj->x;
			vy = player->awayviewmobj->y;
			vz = player->awayviewmobj->z + player->awayviewmobj->height / 2;
		}
		]]

		--// /* check z distance too for orbital camera */
		if P_AproxDistance(P_AproxDistance(vx - mo.x, vy - mo.y),
				vz - (mo.z + mo.height / 2)) < FixedMul(48*FRACUNIT, mo.scale)
		then
			mo.flags2 = $|MF2_SHADOW
		else
			mo.flags2 = $&~MF2_SHADOW
		end
	else
		mo.flags2 = $&~MF2_SHADOW

		--[[
		/*	if (!resetcalled && (player->powers[pw_carry] == CR_NIGHTSMODE && player->exiting))
			{
				// Don't let the camera match your movement.
				thiscam->momz = 0;

				// Only let the camera go a little bit upwards.
				if (mo->eflags & MFE_VERTICALFLIP && thiscam->aiming < ANGLE_315 && thiscam->aiming > ANGLE_180)
					thiscam->aiming = ANGLE_315;
				else if (!(mo->eflags & MFE_VERTICALFLIP) && thiscam->aiming > ANGLE_45 && thiscam->aiming < ANGLE_180)
					thiscam->aiming = ANGLE_45;
			}
			else */
		]]
		if not resetcalled and (p.playerstate == PST_DEAD or p.playerstate == PST_REBORN) then
			--// Don't let the camera match your movement.
			ccam.momz = 0

			--// Only let the camera go a little bit downwards.
			if not (mo.eflags&MFE_VERTICALFLIP) and ccam.aiming < ANGLE_337h and cacm.aiming > ANGLE_180 then
				ccam.aiming = ANGLE_337h
			elseif (mo.eflags&MFE_VERTICALFLIP) and ccam.aiming > ANGLE_22h and ccam.aiming < ANGLE_180 then
				ccam.aiming = ANGLE_22h
			end
		end
	end

	--// rev: Let's set everything up before returning
	-- we use x, y, z and constantly TP the cam around instead of moving it with momentum.
	local calcx = FixedMul(cos(p.cmd.angleturn << 16),-100*FRACUNIT)
	local calcy = FixedMul(sin(p.cmd.angleturn << 16),-100*FRACUNIT)
	local mx = calcx+x
	local my = calcy+y
	local mz = z+mo.height+(15*FRACUNIT)

	P_MoveOrigin(ccam, mx, my, mz)
	p.awayviewmobj = ccam
	return (x == ccam.x and y == ccam.y and z == ccam.z and angle == ccam.aiming)
end

--//
--// Performs analog type chase cam movement. Cam follows the player around in some fasshion.
--//
local function move_chase_cam_analog2(p)

end

--//
--// Performs orbital type chase cam movement.
--//
-- TODO: allow clipping thru ground with a command?
local function move_chase_cam_orbital(p)
	local mo = p.mo
	local scale = mo.scale
	local aiming = p.aiming

	local cam = p.cam
	local cam2 = p.cam2
	local cv_cam_height 	= CV_FindVar("cam_height").value
	local cv_cam_dist   	= CV_FindVar("cam_dist").value
	local cv_cam_rotspeed 	= CV_FindVar("cam_rotspeed").value

	local flip = P_MobjFlip(mo)
	local heightfactor = FixedMul(sin(aiming),cv_cam_dist*2)
	local dist =
		FixedMul(
			FixedMul(
				FixedMul(
					cos(aiming),
					cv_cam_dist
				),
				p.camerascale
			),
			scale
		)

	local height = flip == 1 
			and (cv_cam_height - min(-FRACUNIT,heightfactor))
			or  (cv_cam_height - max(FRACUNIT,heightfactor))

	--// Cam Angle
	local ang = R_PointToAngle2(cam2.x,cam2.y,mo.x,mo.y)
	local ang = cam2.angle
	local camturn = cv_cam_rotspeed
	local camdiff = ang - mo.angle


	if camdiff then ang = $ - FixedMul(
			camdiff,
			min(FRACUNIT, FRACUNIT*camturn/15)
		)
	end

	--// Moves cam
	local movx = mo.x - FixedMul(cos(ang), dist)
	local movy = mo.y - FixedMul(sin(ang), dist)
	local movz = mo.z + height 
	P_MoveOrigin(cam, movx, movy, movz)

	p.camdist = $/10*9 + dist/10
	cam2.newz = mo.z+height

	local dist = p.camdist
	local movx2 = mo.x - FixedMul(cos(ang), dist)
	local movy2 = mo.y - FixedMul(sin(ang), dist)
	local movz2 = cam2.newz
	P_MoveOrigin(cam2, movx2, movy2, movz2)

	cam2.angle = ang --// R_PointToAngle(cam2.x, cam2.y, mo.x, mo.y)
	p.awayviewaiming = flip*aiming > 0 and 0 or aiming
	p.awayviewmobj = cam2
end

addHook("ThinkFrame", function()
	for p in players.iterate do
		local rmo = p.realmo
		local mo = p.mo
		local var
		var = CV_FindVar("chasecam")
		local cv_chasecam 	= var and var.value or 0
		var = CV_FindVar("sessionanalog")
		local cv_analog 	= var and var.value or 0
		var = CV_FindVar("cam_orbit")
		local cv_orbit  	= var and var.value or 0

		--// Disable cam under these conditions and return
		if 	not (mo and mo.valid)
			or ((mo.flags2&MF2_TWOD) or twodlevel)
			or p.spectator
			or maptol&(TOL_NIGHTS|TOL_XMAS)
			or not cv_chasecam
			or not nosolidcam --p.nosolidcam
		then
			if p.awayviewtics then p.awayviewtics = 0 end
			continue
		end

		--// Otherwise, create cam .. if it doesn't exist
		if not p.cam or not (p.cam.valid) then
			p.cam  = P_SpawnMobj(rmo.x, rmo.y, rmo.z, MT_ALTVIEWMAN)
			p.cam2 = P_SpawnMobj(rmo.x, rmo.y, rmo.z, MT_ALTVIEWMAN)
			p.cam.newz  = rmo.z
			p.cam2.newz = rmo.z
			p.camdist = rmo.scale*320

			-- flags
			p.cam.flags = MF_NOBLOCKMAP|MF_SCENERY
			p.cam2.flags = MF_NOBLOCKMAP|MF_SCENERY
		end
		p.awayviewtics = 2 --// set this every tic

		--// Commit nosolidcam ... 
		if cv_analog then --// analog
			move_chase_cam_analog(p, p.cam2) -- rev: my goofy aahh analog cam
		elseif cv_orbit then --// orbital cam
			move_chase_cam_orbital(p) -- rev: this is mostly from clairebun's code
		else --// 
			--print("lol") -- rev: eh, just the normal default cam i guess
		end

		--// TODO: Let's simulate other cam aspects
		--p.cam.pitch     = mo.pitch
		--p.cam.rollangle = mo.rollangle
	end
end)


/*
addHook("ThinkFrame", function()
	for p in players.iterate do
		if not (p and p.mo) then continue end
		local mo = p.mo

		--// Validity check: Does custom cam exist?
		if --(p.custom_cam and not p.custom_cam.valid) or not p.custom_cam then
			(p.awayviewmobj and not p.awayviewmobj.valid) or not p.awayviewmobj then
			local cam = P_SpawnMobjFromMobj(mo,150*FRACUNIT,150*FRACUNIT,0,MT_THOK)
			cam.flags = MF_SCENERY|MF_NOBLOCKMAP
			cam.fuse = -1
			cam.tics = -1
			cam.scale = 0
			cam.chase = true
			p.awayviewmobj = cam
		end

		move_chase_cam(p, p.awayviewmobj, false)

		--// Camera specific stuff
		--[[
		local ccam = p.custom_cam
		if ccam then
			P_MoveOrigin(ccam, (cos(mo.angle)*-250)+mo.x, (sin(mo.angle)*-250)+mo.y, mo.z+mo.height+(15*FRACUNIT))
			ccam.angle = mo.angle
			ccam.pitch = mo.pitch
			p.awayviewaiming = p.aiming
		end

		--p.awayviewmobj = p.custom_cam
		--]]
		p.awayviewtics = TICRATE
	end
end)
*/