local B = CBW_Battle
local CV = B.Console
local TF_GRAY = 1
local TF_YELLOW = 2
local TF_RED = 3

B.RingsHUD = function(v, player, cam)
	if not (B.HUDMain)
	or not (player.battleconfig_newhud)
	or not hud.enabled("rings")
	or player.spectator
	then
		return
	end
	
	local V_HUDTRANSQUARTER = B.GetHudQuarterTrans(v)
	local flags = V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTOLEFT
	local flags_hudtrans = V_PERPLAYER|V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTOLEFT
	local x = 39
	local y = 180
	local shake = 0
	local patch
	if (not player.playerstate) and P_PlayerInPain(player) then --p_playerinpain crashes w/ playerstate :v
		shake = 5
	elseif player.tumble then
		shake = 2
	end
	if shake and not (paused or player.playerstate) then
		x = $ + v.RandomRange(-shake,shake)
		y = $ + v.RandomRange(-shake,shake)
	end
	local num_offsetx = 4
	local num_offsety = -5
	local action_offsetx = 15
	local action_offsety = 2
	local action_offsety_line = -8
	local cooldownbar_offsetx = -6
	local cooldownnum_offsetx = 5
	local shaking = player.shakemobj and player.shakemobj.valid
	if player.rings >= 1000 then
		num_offsetx = $ + 12
	elseif player.rings >= 100 then
		num_offsetx = $ + 8
	elseif player.rings >= 10 then
		num_offsetx = $ + 4
	else
		num_offsetx = $ + 1
	end
	
	--Face
	local facepatch = v.getSprite2Patch(player.skin, SPR2_SIGN)
	local facepos = 0
	if B.SkinVars[skins[player.skin].name] then
		facepos = B.SkinVars[skins[player.skin].name].hud_facepos or 0
	end
	local col = G_GametypeHasTeams() and player.skincolor or SKINCOLOR_PITCHBLACK
	if player.rings == 0 and (leveltime/5 & 1) then
		col = SKINCOLOR_PITCHBLACK
	end
	v.draw(x + 3 + facepos, 200, facepatch, flags | V_HUDTRANSQUARTER, v.getColormap(TC_BLINK, col))
	--v.draw(x + 2 + facepos, 201, facepatch, flags | V_HUDTRANSQUARTER, v.getColormap(TC_BLINK, col))

	if B.PreRoundWait() then
		v.drawString(x + action_offsetx, y + action_offsety, "GET READY...", flags_hudtrans, "thin")
		return
	end
	
	--Rings
	local scale = FRACUNIT + (player.ringhudflash * FRACUNIT/50)
	local ringpatchname = "HUD_RING"
	local actionrings = player.actionrings or player.lastactionrings or 0
	if (player.rings == 0 and (leveltime/5 & 1)) then
		ringpatchname = "HUD_RINGR"
	elseif player.rings < actionrings then
		ringpatchname = "HUD_RINGG"
	end
	local ringpatch = v.cachePatch(ringpatchname)
	v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, ringpatch, flags_hudtrans)

	--Actions
	local function roundToMultipleOf5(num)
		local remainder = num % 5
		if remainder >= 3 then
			return num + (5 - remainder)
		else
			return num - remainder
		end
	end

	if B.StunBreakAllowed(player) then
		local text = "Stun Break"
		local cost = player.stunbreakcosttext
		if cost != nil and player.rings >= cost then
			if leveltime % 3 == 0 then
				text = "\x82" + $
			elseif leveltime % 3 == 1 then
				text = "\x83" + $
			else
				text = "\x87" + $
			end
			if cost == 0 then
				cost = ""
			end
			text = $ + " \x82 "..cost
		else
			if not(cost) then
				cost = ""
			end
			text = "\x86" + $ + " \x85 "..cost
		end
		v.drawString(x + action_offsetx, y + action_offsety, text, flags_hudtrans, "thin")
	elseif player.tumble then
		--nothing
	else
		if (player.actioncooldown) then
			local lastcooldown = player.lastcooldown or 1
			local scale_factor = 1000
			local scaled_ratio = (player.actioncooldown * scale_factor) / lastcooldown
			local spacing = 4 --maybe this makes it more performant?
			local angles = scaled_ratio * (360/spacing) / scale_factor
			for n=1, angles do
				local p = v.getSpritePatch("CDBR", leveltime/4 % 4, 0, n*ANG1*spacing)
				v.draw(x, y-9, p, flags_hudtrans)
			end
			local text = "\x86" + G_TicsToSeconds(player.actioncooldown) + "." + roundToMultipleOf5(G_TicsToCentiseconds(player.actioncooldown))
			v.drawString(x, y + 14, text, flags_hudtrans, "thin-center")
		else
			local text = player.actiontext or player.lastactiontext or 0
			if player.battleconfig_minimalhud then
				text = player.actionstate and "--" or ""
			end
			if shaking and player.jumpstasistimer and player.strugglerings then
				text = "          "..player.strugglerings.." COST"
				text = (leveltime%2==0) and "\131"+text or "\139"+text
			end
			if text and not(player.gotflagdebuff) then
				if player.actionstate then
					text = "\x82" + text
				else
					if not B.CanDoAction(player) then
						if B.TagGametype() and not (player.pflags & PF_TAGIT or player.battletagIT)
							text = player.battleconfig_minimalhud and ("\x86Guard" .. "\x80" .. " 10") or "\x80" .. "10"
						else
							text = "\x86" + text
						end
					end
					if player.actionrings and not(player.actioncooldown) then
						if not B.CanDoAction(player) then
							if (CV.RequireRings.value and player.rings < player.actionrings) then
								text = $ + "  \x85" + player.actionrings
							else
								text = $ + "  " + player.actionrings
							end
						else
							text = $ + "  \x82" + player.actionrings
						end
					end
				end
				if player.battleconfig_minimalhud then
					v.drawString(x, y + 14, text, flags_hudtrans, "thin-center")
				else
					v.drawString(x + action_offsetx, y + action_offsety, text, flags_hudtrans, "thin")
				end
				action_offsety = $ + action_offsety_line
			end
		end
		if (player.action2text and not player.battleconfig_minimalhud) then
			local text = player.action2text
			local textflags = player.action2textflags
			if textflags == TF_GRAY then
				text = "\x86"+$
			elseif textflags == TF_YELLOW then
				text = "\x82"+$
			elseif textflags == TF_RED then
				text = "\x85"+$
			else
				text = "\x80"+$
			end
			v.drawString(x + action_offsetx, y + action_offsety, text, flags_hudtrans, "thin")
			action_offsety = $ + action_offsety_line
		end
		if (player.gotflagdebuff) then
			local color = SKINCOLOR_WHITE
			patch = v.cachePatch("FLAGBT")
			if B.RubyGametype() then
				patch = v.cachePatch("RUBYBT")
				color = nil
			elseif B.DiamondGametype() then
				patch = v.cachePatch("TOPZBT")
				color = nil
			elseif G_GametypeHasTeams() then
				local flagcolors = {SKINCOLOR_BLUE, SKINCOLOR_RED}
				color = flagcolors[player.ctfteam]
			end
			v.draw(x + action_offsetx, y - 1 + action_offsety, patch, flags, color and v.getColormap(TC_DEFAULT, color) or nil)
		end
	end
	
	--Number
	if player.ringhudflash ~= 0 then
		local flashpatch
		if player.ringhudflash > 0 then
			flashpatch = v.cachePatch("HUD_RINGW")
		else
			flashpatch = v.cachePatch("HUD_RINGB")
		end
		local flash_trans = TR_TRANS70
		if abs(player.ringhudflash) == 1 then
			flash_trans = TR_TRANS90
		elseif abs(player.ringhudflash) == 2 then
			flash_trans = TR_TRANS80
		end
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, flashpatch, flags | flash_trans)
	end
	
	v.drawNum(x + num_offsetx, y + num_offsety, player.rings, flags_hudtrans)

	--Sweat
	local warningtic = FRACUNIT/3
	if player.exhaustmeter < warningtic then
		local frame = 0
		local sprite = (player.charflags & SF_MACHINE) and "SPAK" or "SWET"
		local nodraw = false
		if player.exhaustmeter == 0 then
			frame = 1
		elseif not(leveltime % 7) then
			nodraw = true
		end
		if not nodraw then
			v.drawScaled((x+12)*FRACUNIT, (y-14)*FRACUNIT, scale, v.getSpritePatch(sprite, frame), flags_hudtrans)
		end
	end

	--Shake
	if shaking then
		local frame = B.Wrap(leveltime/2, 0, states[S_SHAKE].var1-1)
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, v.getSpritePatch("SHAK", frame), flags_hudtrans)
	end

	--Mash!! (so many checks :sob:)
	if player.powers[pw_carry] and player.mo and player.mo.valid
	and player.mo.tracer and player.mo.tracer.valid and player.mo.tracer.player
	and not B.MyTeam(player, player.mo.tracer.player) then
		local color = v.getColormap(nil, player.mo.tracer.color)
		local frame = (player.realbuttons & BT_JUMP) and "A" or "B"
		v.drawScaled(172*FRACUNIT, 140*FRACUNIT, scale, v.cachePatch("MASH"..frame), flags_hudtrans, color)
		if leveltime % 4 >= 2 then
			v.drawScaled(172*FRACUNIT, 140*FRACUNIT, scale, v.cachePatch("MASHC"), flags_hudtrans, color)
		end
		--Opponent cooldown
		local opponent = player.mo.tracer.player
		if opponent and opponent.actioncooldown then
			local barpatch = v.cachePatch("HUD_CDBAR"+(leveltime/2 % 4))
			local prev = opponent.lastcooldown or opponent.actioncooldown
			local barlength = 80 * opponent.actioncooldown / prev
			if barlength then
				for i = 0, barlength do
					v.draw(172 + i, 170, barpatch, flags_hudtrans)
				end
			end
			local text = "\x86" + G_TicsToSeconds(opponent.actioncooldown) + "." + roundToMultipleOf5(G_TicsToCentiseconds(opponent.actioncooldown))
			v.drawString(172 + cooldownnum_offsetx + barlength, 170, text, flags_hudtrans, "thin")
		end
	end

	--Ring spent effect
	if player.spentrings then
		local scale2 = FRACUNIT*5 - (player.spentrings * (FRACUNIT*4)/(TICRATE/2))
		local transrights = B.TIMETRANS(player.spentrings * 6) or 0
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale2, ringpatch, flags|transrights)
	end

	--GUARD
	local mo = player.mo
	if not(mo and mo.valid) then return end
	if player.tumble then return end
	local guardoverride = tonumber(player.canguard) and tonumber(player.canguard) > 1 and not player.deadtimer

	x = $+20
	y = $+10
	
	local canguard = (player.canguard
		and CV.Guard.value
		and CV.parrytoggle.value
		and P_IsObjectOnGround(mo)
		and not player.actionstate
		and not P_PlayerInPain(player)
		and not player.guard
		and not player.actionstate
		and not (player.skidtime and player.powers[pw_nocontrol])
		and not (mo.eflags & MFE_JUSTHITFLOOR)
		and not (player.weapondelay and mo.state == S_PLAY_FIRE)
		and leveltime > TICRATE*5/4
		--since guard is disabled for runners for now, don't show it in the hud
		and not (B.TagGametype() and not (player.pflags & PF_TAGIT))
	)
	local candodge = (player.canguard
		and CV.airtoggle.value
		and mo.state ~= S_PLAY_PAIN
		and mo.state ~= S_PLAY_STUN
		--and player.airdodge == 0
		and player.playerstate == PST_LIVE
		and not player.exiting
		and not player.actionstate
		and not player.climbing
		and not player.armachargeup
		and not player.isjettysyn
		and not player.revenge
		--and not player.powers[pw_nocontrol]
		--and not player.powers[pw_carry]
		--and not P_IsObjectOnGround(mo)
		and leveltime>TICRATE*5/4
	)
	
	local guardtext = guardoverride and player.guardtext or "\x82Guard"
	/*if B.TagGametype() and not (player.pflags & PF_TAGIT)
		guardtext = $ + "\x85" + " 10"
	end*/
	patch = v.cachePatch("PARRYBT")
	if (canguard or guardoverride) and not (player.battleconfig_minimalhud) then
		v.draw(x-10,y-1,patch,flags)
		v.drawString(x,y,guardtext,flags,"thin")
	end

	--AIR DODGE
	if candodge then
		if player.dodgecooldown then
			local maxcooldown = CV.dodgetime.value*TICRATE or 1
			local scale_factor = 1000
			local scaled_ratio = (player.dodgecooldown * scale_factor) / maxcooldown
			local spacing = 4 --maybe this makes it more performant?
			local angles = scaled_ratio * (360/spacing) / scale_factor
			local tiny = 4 -- 0 for not tiny
			for n=1, angles do
				local p = v.getSpritePatch("CDBR", tiny+(leveltime/4 % 4), 0, n*ANG1*spacing)
				v.draw(x, y-18, p, flags_hudtrans)
			end
			local unsafe_dodge = (player.safedodge and player.safedodge < 0)
			if player.dodgecooldown > maxcooldown and (unsafe_dodge or (leveltime/5 & 1)) then
				local color = "\x85"
				if unsafe_dodge then
					color = (leveltime/5 & 1) and $ or "\x8F"
					x = $ + v.RandomRange(-1,1)
					y = $ + v.RandomRange(-1,1)
				end
				v.drawString(x-1,y-19,color+"!",flags,"thin")
			end
		elseif not (player.battleconfig_minimalhud) then
			patch = v.cachePatch("DODGEBT")
			v.draw(x-5,y-18,patch,flags)
		end
	end

	--hi
end
