local CTFlagReturnNerf = function(mo, toucher)
	local flagcolor = 0
	if mo.type == MT_REDFLAG then
		flagcolor = 1
	elseif mo.type == MT_BLUEFLAG  then
		flagcolor = 2
	end
	if toucher.player.ctfteam == flagcolor and not toucher.player.powers[pw_flashing] then
		// dont return if same team color
		mo.nograb = TICRATE/5 // also prevent enemy team from grabbing the flag that your on top of!
		return true
	 elseif mo.nograb then
		return true
	end

end

local CTFlagNoGrabCooldown = function(mo) 
	local spawnpoint = mo.spawnpoint
	local flagreturn = CV_FindVar("flagtime").value
	local flagcolor = 0
	// we use the roll of the mapthing to keep track of how much time the flag should stay before returning
	
	if mo.fuse then // fuse is used as the timer for when to return on drop and when it scores to return
		// we dont want to set the fuse if the flag is being caped so we check if it has any horazontal momentome
		if mo.flags&MF_SPECIAL or (mo.momx != 0 and mo.momy !=0) then  
			if spawnpoint.roll and  spawnpoint.roll < mo.fuse then
				mo.fuse = spawnpoint.roll
			else
				spawnpoint.roll = mo.fuse
			end
		end
	end
	if (P_MobjTouchingSectorSpecial(mo, 4, 3) and mo.type == MT_REDFLAG) or
		(P_MobjTouchingSectorSpecial(mo, 4, 4) and mo.type == MT_BLUEFLAG) then // check if ctf flag is in its base
			spawnpoint.roll = flagreturn*TICRATE // set flag retun time back to normal
			if mo.fuse
				mo.fuse = 1 // return instantly if droped in its base
			end
	end
	if mo.nograb then
		mo.nograb = max(0,$-1)
	end
end

addHook("MobjThinker", CTFlagNoGrabCooldown, MT_REDFLAG)
addHook("MobjThinker", CTFlagNoGrabCooldown, MT_BLUEFLAG)

addHook("TouchSpecial", CTFlagReturnNerf, MT_REDFLAG)
addHook("TouchSpecial", CTFlagReturnNerf, MT_BLUEFLAG)

addHook("PlayerThink", function(player) // if at your base with the enemy flag reduce your flags return time
	if player.mo and player.mo.valid and player.gotflag then
		if (P_PlayerTouchingSectorSpecial(player, 4, 3) and player.ctfteam == 1) or
			(P_PlayerTouchingSectorSpecial(player, 4, 4) and player.ctfteam == 2) then
			local flagcolor = 0
			if player.ctfteam == 1 then
				flagcolor = 310 //MT_REDFLAG, we need the thing's type number not the object's type number
			elseif player.ctfteam == 2 then
			flagcolor = 311 //MT_BLUEFLAG
			end
			for mthing in mapthings.iterate do
				if flagcolor and mthing.type == flagcolor then 
					mthing.roll = max(1,$-3) // reduceing the roll reduces the flags return time
				end
			end
		end
	end
end)