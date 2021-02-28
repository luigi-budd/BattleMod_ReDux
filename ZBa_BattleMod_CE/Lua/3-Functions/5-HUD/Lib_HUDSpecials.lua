local B = CBW_Battle
local CV = B.Console

B.ActionHUD=function(v, player, cam)
	if player.playerstate != PST_LIVE then return end
	if not(CV.Actions.value) then return end
	if player.actionallowed != true and not player.gotflag then return end
	if G_TagGametype() and leveltime < CV_FindVar("hidetime").value*TICRATE then return end
	local TF_GRAY = 1
	local TF_YELLOW = 2
	local TF_RED = 3
	local blink = false
	local xoffset = 16
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER
	local align = "thin"
	//Action 1 text
	local yoffset = 56
	local text = player.actiontext
	local textflags = player.actiontextflags
	local gotflag = player.gotflag
	local gotcrystal = player.gotcrystal
	//Item text
	if gotflag or gotcrystal then
		if gotflag then
			text = "Got flag!"
		elseif gotcrystal then
			text = "Got crystal!"
		end
		if leveltime&4 then
			text = "\x82"+$
		end
		local patch = v.cachePatch("TOSSFLAG")
		v.draw(xoffset,yoffset,patch,flags)
		v.drawString(xoffset+12,yoffset,text,flags,align)
	return end //Don't draw anything more if we're holding an item
	if text and not(player.actioncooldown and leveltime&1) then 
		if player.actioncooldown then
			textflags = TF_GRAY
			text = "Cooldown "..G_TicsToSeconds(player.actioncooldown).."."..G_TicsToCentiseconds(player.actioncooldown)
		elseif textflags == nil then
			textflags = 0
			if (player.actionstate == 0 and player.actionrings > player.rings) then
				textflags = $|TF_GRAY
			end		
			if player.actionstate then
				textflags = $|TF_YELLOW
			end
		end
		if textflags == TF_GRAY then
			text = "\x86"+$
		elseif textflags == TF_YELLOW then
			text = "\x82"+$
		elseif textflags == TF_RED then
			text = "\x85"+$
		else
			text = "\x80"+$
		end
		if player.actionrings and not(player.actioncooldown) then 
			text = "\x82"+player.actionrings+"\x80 "+$
		end
		//Draw
		local patch = v.cachePatch("THRWRING")
		v.draw(xoffset,yoffset,patch,flags)
		v.drawString(xoffset+12,yoffset,text,flags,align)
	end
	//Action 2 text
	yoffset = $+10
	text = player.action2text
	textflags = player.action2textflags
	if not(player.gotflag) and text and not(player.actioncooldown) then 
		if textflags == nil then
			textflags = 0
			if (player.actionstate == 0 and player.action2rings > player.rings) then
				textflags = $|TF_GRAY
			end		
			if player.actionstate then
				textflags = $|TF_YELLOW
			end
		end
		if textflags == TF_GRAY then
			text = "\x86"+$
		elseif textflags == TF_YELLOW then
			text = "\x82"+$
		elseif textflags == TF_RED then
			text = "\x85"+$
		else
			text = "\x80"+$
		end
		if player.action2rings then 
			text = "\x82"+player.action2rings+"\x80 "+$
		end
		//Draw
		local patch = v.cachePatch("TOSSFLAG")
		v.draw(xoffset,yoffset,patch,flags)
		v.drawString(xoffset+12,yoffset,text,flags,align)
	end
end