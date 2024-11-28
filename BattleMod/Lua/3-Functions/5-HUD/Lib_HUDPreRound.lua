local B = CBW_Battle

local white = "\x80"
local gray = "\x86"
local yellow = "\x82"

B.PreRoundHUD = function(v,player,cam)
	local roulette_x = player.roulette_x
	if (roulette_x == nil) then return end
	
	local lockedin = (leveltime + 17 >= CV_FindVar("hidetime").value*TICRATE)
	if lockedin then roulette_x = 0 end
	
	local forceskinned = false
	if (CV_FindVar("forceskin").value == -1) then forceskinned = false else forceskinned = true end
	if (B.HUDAlt) and B.PreRoundWait() and player.roulette and not (B.Timeout or player.spectator) then
		local x, y = 160, 72
		local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER|V_ALLOWLOWERCASE
		local rtext = forceskinned and "Forceskin in effect!" or "Select a character!" 
		-- Display pre-round hint: We can change characters during this period.
		v.drawString(x, y + 8, yellow..rtext, flags, "center")
		
		if (leveltime <= 60) then return end
		
		-- Display pre-round character roulette. Show previous and next characters we're gonna change into.
		for n = -5, 5 do
			local blink = (leveltime % 2 and leveltime + 35 >= CV_FindVar("hidetime").value*TICRATE)
			if (n ~= 0 and (lockedin or blink or forceskinned))
				continue
			end
			
			local cflags = V_SNAPTOTOP|V_PERPLAYER
			local trans = V_10TRANS * max(0, abs(n*2) - 1)
			local scale = (n==0) and FRACUNIT*3/2 or FRACUNIT
			local xoffs = (x-8)*FRACUNIT + roulette_x + ((40*FRACUNIT)*n)
			local yoffs = (y+36)*FRACUNIT
			
			local character = (player.skin) and #skins[player.skin] or 0
			local tocharacter = 0
			repeat
				if (n > 0) then
					character = $+1
					tocharacter = $+1
					if character >= #skins then character = 0 end
				elseif (n < 0) then
					character = $-1
					tocharacter = $-1
					if character < 0 then character = #skins-1 end
				elseif (n == 0) then
					break
				end
			until tocharacter == n
			
			if lockedin then
				scale = $ + max(0, ((CV_FindVar("hidetime").value*TICRATE) - leveltime - 12)*FRACUNIT/8)
			end
			
			yoffs = $ + scale*3

			local clr
			if bannedskins[character+1] then
				clr = SKINCOLOR_JET
				cflags = $ | V_REVERSESUBTRACT
			else
				clr = skins[character].prefcolor
			end
			
			v.drawScaled(
				xoffs+(8*FRACUNIT), yoffs, scale, v.getSprite2Patch(character, SPR2_LIFE), cflags|trans,
				v.getColormap(character, clr)
			)
		end
		if not (B.Console.FindVarString("battleconfig_hud", {"New", "Minimal"})) then
			v.drawString(160, 192, yellow.."TOSSFLAG: "..white.."Close roulette", V_HUDTRANSHALF|V_SNAPTOBOTTOM|V_PERPLAYER, "center")
		end
		v.draw(160-16, 100-9, v.cachePatch("M_FSEL"), V_HUDTRANSHALF|V_SNAPTOTOP|V_PERPLAYER)
	end
end
