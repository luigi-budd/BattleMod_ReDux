local B = CBW_Battle
local CV = B.Console
local S = B.SkinVars
local grace = 3*TICRATE

local function ButtonCheck2(player,button)
	if player.realbuttons&button then
		if player.buttonhistory&button then
			return 2
		else
			return 1
		end
	end
	return 0
end
-- I copied and edited some code from battle mod
addHook("PlayerThink", function(player) -- death timer test
	if player.deadtimer then
		if (ButtonCheck2(player,BT_TOSSFLAG) == 1) and not player.selectchar then
			player.selectchar = true -- new var we are useing to control this
			if B.ArenaGametype() then 
				player.extradeadtimer = grace -- add more time before respawning so player can choose
			end
			player.buttonhistory = $ | BT_TOSSFLAG --so we don't close the roulette instantly lol
		end
		
		local skinnum = #skins[player.skin]
		--If we're changing skins, this is the set of instructions we'll use
		local skinchanged = false
		local function newskin()
		if not(R_SkinUsable(player, skinnum)) then return end		
			R_SetPlayerSkin(player,skinnum)
			S_StartSound(nil,sfx_menu1,player)
			S_StartSound(nil,sfx_kc50,player)
			B.GetSkinVars(player)
			B.SpawnWithShield(player)
			skinchanged = true
		end
		
		local change = 0
		local f = #skins[skinnum] + 2
		local b = #skins[skinnum]
		if player.selectchar then
			local deadzone = 20
			local right = player.realsidemove >= deadzone
			local left = player.realsidemove <= -deadzone
			local scrollright = player.roulette_prev_right > 18 and player.roulette_prev_right % 4 == 0
			local scrollleft = player.roulette_prev_left > 18 and player.roulette_prev_left % 4 == 0
				if right and (scrollright or not player.roulette_prev_right) then
					repeat 
						skinnum = $+1
						if bannedskins[f] then skinnum = $+1 end
						if skinnum >= #skins then skinnum = 0 end
						if bannedskins[skinnum+1] then skinnum = $+1 end
						local i = skinnum
						while bannedskins[i] 
							i = $+1
							skinnum = i - 1
						end
						newskin()
					until skinchanged == true
					change = 1
				end
				if left and (scrollleft or not player.roulette_prev_left)
					repeat
						skinnum = $-1
						if bannedskins[b] then skinnum = $-1 end
						local i = skinnum
						while bannedskins[i+1] 
							i = $-1
							skinnum = i
						end
						if skinnum < 0	then skinnum = #skins-1
							local y = skinnum
							while bannedskins[y+1] 
								y = $-1
								skinnum = y
							end
						end
						newskin()
					until skinchanged == true
					change = -1
				end
				player.roulette_prev_right = (right and $+1) or 0
				player.roulette_prev_left = (left and $+1) or 0
				-- Roulette scrolling (to be used by the HUD later)
				if change == 0 then
					player.roulette_x = $*6/10
					if abs(player.roulette_x) < FRACUNIT then
						player.roulette_x = 0
					end
				else
					player.roulette_x = (40*FRACUNIT*change)
				end
			if (ButtonCheck2(player,BT_SPIN) == 1
			or ButtonCheck2(player,BT_JUMP) == 1
			or ButtonCheck2(player,BT_TOSSFLAG) == 1)
			then -- confirm skin choice
				player.extradeadtimer = $ and $-grace or 0 -- subtract timer so we will spawn sooner
				player.selectchar = false
			end
		end
	else
		player.selectchar = false
	end
end)