local B = CBW_Battle
local CV = B.Console
local grace1 = CV.CTFdropgrace
local grace2 = CV.CTFrespawngrace

B.FlagIntangible = function(mo)
	if B.CPGametype() then
		mo.flags2 = $&~MF2_DONTDRAW
		mo.flags = $&~MF_SPECIAL
	return end
	//Get spawntime
	local spawntype = 1 //flag is at base
	if mo.fuse then spawntype = 2 end //flag has been dropped

	//Initiate mo.intangibletime
	if mo.intangibletime == nil then
		if spawntype == 2 then
			mo.intangibletime = TICRATE*grace1.value
		else
			mo.intangibletime = TICRATE*grace2.value
		end
	end
	
	
	//Countdown
	mo.intangibletime = max(0,$-1)
	
	//Determine blink frame
	local blink = 0
	if spawntype == 2 or (spawntype == 1 and mo.intangibletime > TICRATE*2) then
		blink = mo.intangibletime&1
	else
		blink = mo.intangibletime&4
	end
	
	if blink then
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $&~MF2_DONTDRAW
	end
	
	//Determine tangibility
	if mo.intangibletime then
		mo.flags = $&~MF_SPECIAL
	else
		mo.flags = $|MF_SPECIAL
	end
	
end