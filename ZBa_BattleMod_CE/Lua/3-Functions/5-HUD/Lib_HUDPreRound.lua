local B = CBW_Battle

local white = "\x80"
local gray = "\x86"
local yellow = "\x82"
local roulette

local CharacterRoulette0 = {
	["x"] = 0,
	["y"] = 0,
	["JUMP"] = false,
	["SPIN"] = false,
}
local CharacterRoulette1 = {
	["x"] = 0,
	["y"] = 0,
	["JUMP"] = false,
	["SPIN"] = false,
}
local function ModifyRouletteVars(whichtable, replacementtable)
-- Allows modification of table variables on the fly.
	if (whichtable == 0) then
		CharacterRoulette0 = replacementtable
	elseif (whichtable == 1) then
		CharacterRoulette1 = replacementtable
	end
end

local function DoRouletteLogic(B, player, xdist, ydist)
-- Manage the variables for the character roulette. BattleMod is required to be loaded.
	local input, roulette
	if (player == displayplayer) then -- Player 1 (or whoever we're viewing).
		input = player.cmd.buttons
		roulette = CharacterRoulette0
	else -- Player 2 (splitscreen).
		input = secondarydisplayplayer.cmd.buttons
		roulette = CharacterRoulette1
	end
	
	roulette["x"] = B.FixedLerp(0, FU, roulette["x"]*65/100)
	roulette["y"] = B.FixedLerp(0, FU, roulette["y"]*65/100)
	
	if (B) and B.PreRoundWait() and not (player.spectator) then -- Is this the start of a match?
		if (input & BT_JUMP) and not roulette["JUMP"] then -- JUMP input. Set everything up for the roulette then lock it.
			roulette["JUMP"] = true
			roulette["x"] = $+(xdist*FU)
			roulette["y"] = $+(ydist*FU)
			//S_StartSound(nil, sfx_menu1, nil)
		elseif not (input & BT_JUMP) and roulette["JUMP"] then -- We're not, disengage the lock.
			roulette["JUMP"] = false
		end
		if (input & BT_SPIN) and not roulette["SPIN"] then -- SPIN input. As above.
			roulette["SPIN"] = true
			roulette["x"] = $-(xdist*FU)
			roulette["y"] = $-(ydist*FU)
			//S_StartSound(nil, sfx_menu1, nil)
		elseif not (input & BT_SPIN) and roulette["SPIN"] then
			roulette["SPIN"] = false
		end
	end
	
	if (player == displayplayer) then
		ModifyRouletteVars(0, roulette) -- Update table 0 (main player).
	else
		ModifyRouletteVars(1, roulette) -- Update table 1 (splitscreen player).
	end
	
	return roulette
end

B.PreRoundHUD = function(v,player,cam)
	if (B) then roulette = DoRouletteLogic(B, player, 40, 0) end
	
	if (B.HUDAlt) and B.PreRoundWait() and not (player.spectator) and (leveltime > 60) then
		local x, y = 160, 72
		local flags = V_HUDTRANS|V_SNAPTOTOP|V_PERPLAYER|V_ALLOWLOWERCASE
		-- Display pre-round hint: We can change characters during this period.
		if not (splitscreen) then v.drawString(x, y, white.."Waiting for other players to join", flags, "center") end
		v.drawString(x, y + 8, gray.."Press "..yellow.."SPIN"..white.."/"..yellow.."JUMP"..gray.." to change characters", flags, "center")
		
		-- Display pre-round character roulette. Show previous and next characters we're gonna change into.
		for n = -5, 5 do
			local cflags = V_SNAPTOTOP|V_PERPLAYER
			local trans = V_10TRANS * max(0, abs(n*2) - 1)
			local scale = (n==0) and FU*3/2 or FU
			local xoffs = (x-8)*FU + roulette["x"] + ((40*FU)*n)
			local yoffs = (y+40)*FU + roulette["y"]
			
			local character = (player.skin) and #skins[player.skin] or 0
			local tocharacter = 0
			repeat
				if (n > 0)
					character = $+1
					tocharacter = $+1
					if character >= #skins then character = 0 end
				elseif (n < 0)
					character = $-1
					tocharacter = $-1
					if character < 0 then character = #skins-1 end
				elseif (n == 0)
					break
				end
			until tocharacter == n
			
			v.drawScaled(
				xoffs+(8*FU), yoffs, scale, v.getSprite2Patch(character, SPR2_LIFE), cflags|trans,
				v.getColormap(character, skins[character].prefcolor)
			)
		end
		v.draw(160-16, 100-10, v.cachePatch("M_FSEL"), V_SNAPTOTOP|V_PERPLAYER)
	end
end