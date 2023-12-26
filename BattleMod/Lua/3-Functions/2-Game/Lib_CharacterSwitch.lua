local B = CBW_Battle
local CV = B.Console
local S = B.SkinVars

local function ButtonCheck2(player,button)
	if player.cmd.buttons&button then
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
			player.deadtimer = $-10*TICRATE -- add more time before respawning so player can choose
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
		if player.selectchar then
			local deadzone = 20
			local right = player.cmd.sidemove >= deadzone
			local left = player.cmd.sidemove <= -deadzone
			local scrollright = player.roulette_prev_right > 18 and player.roulette_prev_right % 4 == 0
			local scrollleft = player.roulette_prev_left > 18 and player.roulette_prev_left % 4 == 0
				if right and (scrollright or not player.roulette_prev_right) then
					repeat 
						skinnum = $+1
						if skinnum >= #skins then skinnum = 0 end
						newskin()
					until skinchanged == true
					change = 1
				end
				if left and (scrollleft or not player.roulette_prev_left)
					skinnum = $-1
					if skinnum < 0 then skinnum = #skins-1 end
					newskin()
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
			if (ButtonCheck2(player,BT_SPIN) == 1) then -- confirn skin choice, cant use jump because its alreay being set 
				player.deadtimer = $+10*TICRATE -- subtract timer so we will spawn sooner
				player.selectchar = false
			end
		end
	else
		player.selectchar = false
	end
end)