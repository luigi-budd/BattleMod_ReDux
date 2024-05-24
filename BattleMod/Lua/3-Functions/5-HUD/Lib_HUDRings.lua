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
	local x = 40
	local y = 180
	local num_offsetx = 4
	local num_offsety = -5
	local action_offsetx = 15
	local action_offsety = 2
	local action_offsety_line = -8
	local cooldownbar_offsetx = -6
	local cooldownnum_offsetx = 5
	if player.rings >= 1000 then
		num_offsetx = $ + 12
	elseif player.rings >= 100 then
		num_offsetx = $ + 8
	elseif player.rings >= 10 then
		num_offsetx = $ + 4
	end
	
	--Face
	local facepatch = v.getSprite2Patch(player.skin, SPR2_SIGN)
	local facepos = 0
	if B.SkinVars[skins[player.skin].name] then
		facepos = B.SkinVars[skins[player.skin].name].hud_facepos or 0
	end
	local col = player.skincolor
	if player.rings == 0 then
		col = SKINCOLOR_PITCHBLACK
	end
	v.draw(x + 3 + facepos, 200, facepatch, flags | V_HUDTRANSHALF, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
	v.draw(x + 2 + facepos, 201, facepatch, flags | V_HUDTRANSQUARTER, v.getColormap(TC_BLINK, col))
	
	--Actions
	if B.StunBreakAllowed(player) then
		local text = "Stun Break"
		local cost = player.stunbreakcosttext
		if cost and player.rings >= cost then
			if leveltime % 3 == 0 then
				text = "\x82" + $
			elseif leveltime % 3 == 1 then
				text = "\x83" + $
			else
				text = "\x87" + $
			end
			text = $ + " \x82 "..cost
		else
			text = "\x86" + $ + " \x85 "--..cost
		end
		v.drawString(x + action_offsetx, y + action_offsety, text, flags_hudtrans, "thin")
	else
		if (player.actioncooldown) then
			local barpatch = v.cachePatch("HUD_CDBAR"+(leveltime/2 % 4))
			local prev = player.lastcooldown or player.actioncooldown
			local barlength = 80 * player.actioncooldown / prev
			if barlength then
				for i = 0, barlength do
					v.draw(x + action_offsetx + cooldownbar_offsetx + i, y + action_offsety, barpatch, flags_hudtrans)
				end
			end
			local text = G_TicsToSeconds(player.actioncooldown) + "." + G_TicsToCentiseconds(player.actioncooldown)
			v.drawString(x + action_offsetx + cooldownbar_offsetx + cooldownnum_offsetx + barlength, y + action_offsety, text, flags_hudtrans, "thin")
		else
			if (player.actiontext) then
				local text = player.actiontext
				if player.actionstate then
					text = "\x82" + $
				else
					local requirerings = (CV.RequireRings.value and player.rings < player.actionrings)
					if requirerings or not B.CanDoAction(player) then
						text = "\x86" + $
					end
					if player.actionrings and not(player.actioncooldown) then
						if not B.CanDoAction(player) then
							text = $ + "  " + player.actionrings
						elseif requirerings then
							text = $ + "  \x85" + player.actionrings
						else
							text = $ + "  \x82" + player.actionrings
						end
					end
				end
				v.drawString(x + action_offsetx, y + action_offsety, text, flags_hudtrans, "thin")
				action_offsety = $ + action_offsety_line
			end
			if (player.action2text) then
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
		end
	end
	
	--Rings
	local scale = FRACUNIT + (player.ringhudflash * FRACUNIT/50)
	local ringpatchname = "HUD_RING"
	if (player.rings == 0 and (leveltime/5 & 1)) then
		ringpatchname = "HUD_RINGR"
	elseif player.rings < player.actionrings then
		ringpatchname = "HUD_RINGG"
	end
	local ringpatch = v.cachePatch(ringpatchname)
	v.drawScaled(x*FRACUNIT + FRACUNIT/2, y*FRACUNIT, scale, ringpatch, flags_hudtrans)
	
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
		v.drawScaled(x*FRACUNIT + FRACUNIT/2, y*FRACUNIT, scale, flashpatch, flags | flash_trans)
	end
	
	v.drawNum(x + num_offsetx, y + num_offsety, player.rings, flags_hudtrans)
end
