local B = CBW_Battle
B.FlashColor = function(colormin,colormax)
	local N = 32 //Rate of oscillation
-- 	local size = colormax-colormin+1 //Color spectrum
	local scale = 2 //Factor-amount to reduce the oscillation intensity
	local offset = 0 //Offset the origin of oscillation
	local oscillate = abs((leveltime&(N*2-1))-N)/scale //Oscillation cycle
	local c = colormin+oscillate+offset //offset
	c = max(colormin,min(colormax,$)) //Enforce min/max
	return c
end

B.FlashRainbow = function(mo)
	local t = (leveltime&15)>>2
	if t == 0 then return B.FlashColor(SKINCOLOR_SUPERGOLD1,SKINCOLOR_SUPERGOLD5) end
	if t == 1 then return B.FlashColor(SKINCOLOR_SUPERSKY1,SKINCOLOR_SUPERSKY5) end
	if t == 2 then return B.FlashColor(SKINCOLOR_SUPERTAN1,SKINCOLOR_SUPERTAN5) end
	if t == 3 then return B.FlashColor(SKINCOLOR_SUPERSILVER1,SKINCOLOR_SUPERSILVER5) end
end

function B.StartFlash(mo)

	local fmo

	if mo.player then
		fmo = mo.player.followmobj
	end

	mo.alert_flash = {
		mo.colorized,
		mo.blendmode
	}

	--Toggle Colorized
	if mo.colorized then
		mo.colorized = false
	else
		mo.colorized = true
	end

	if mo.blendmode == AST_ADD then
		mo.blendmode = AST_COPY
	else
		mo.blendmode = AST_ADD
	end

	if fmo and fmo.valid then

		fmo.alert_flash = {
			fmo.colorized,
			fmo.blendmode
		}

		if fmo.colorized then
			fmo.colorized = false
		else
			fmo.colorized = true
		end
		

		--Toggle additive blending
		if fmo.blendmode == AST_ADD then
			fmo.blendmode = AST_COPY
		else
			fmo.blendmode = AST_ADD
		end
	end

	local circle = P_SpawnMobjFromMobj(mo, 0, 0, mo.scale * 5, MT_THOK)
	circle.sprite = SPR_STAB
	circle.frame =  _G["A"]
	--circle.angle = mo.angle + ANGLE_90
	circle.fuse = 7
	circle.scale = mo.scale / 3
	circle.destscale = 10*mo.scale
	circle.colorized = true
	circle.blendmode = AST_OVERLAY
	circle.color = mo.color
	circle.momx = -mo.momx / 2
	circle.momy = -mo.momy / 2
end 

function B.IsFlashOn(mo)
	return ((mo.player and mo.player.followmobj and mo.player.followmobj.alert_flash) or mo.alert_flash)
end

function B.StopFlash(mo)

	local fmo

	if mo.player then
		fmo = mo.player.followmobj
	end

	if mo.alert_flash then
		mo.colorized = mo.alert_flash[1]
		mo.blendmode = mo.alert_flash[2]
		mo.alert_flash = nil
	end

	if fmo and fmo.valid and fmo.alert_flash then
		fmo.colorized = fmo.alert_flash[1]
		fmo.blendmode = fmo.alert_flash[2]
		fmo.alert_flash = nil
	end
end

function B.chargeFlash(mo, chargevar, chargedval, flashdiff, param) --chargevar has to be a number that increases, charged val is the num that counts as charged
	param = $ or true
	if param and (chargevar >= chargedval-(flashdiff or FRACUNIT)) then --flashdiff is what needs to be subtracted from chargedval to "catch" the charge
		if chargevar == chargedval then
			B.StartFlash(mo)
		else
			B.StopFlash(mo)
		end
	elseif B.IsFlashOn(mo) then
		B.StopFlash(mo)
	end

	if mo.alert_flash then
		return true
	end
end

B.TextFlash = function(text, reset, player)
	local colors = {"\x81","\x88"}

	local originaltext = text

	local bin = 0

	if leveltime % 4 then
		bin = 1
	end

	if player then
		player.textflash_flashing = true
	end

	local newtext = colors[bin+1]..originaltext.."\x80"

	if (reset) then
		player.textflash_flashing = false
		return text:sub(2)
	else
		return (newtext)
	end
end