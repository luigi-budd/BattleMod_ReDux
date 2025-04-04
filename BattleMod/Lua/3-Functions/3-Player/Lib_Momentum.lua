local B = CBW_Battle
local S = B.SkinVars

B.DiminishingMomentum = function(player)
	if player.gotflagdebuff or not (player.skinvars and S[player.skinvars]) then return end -- Nuh uh
	local diminish_time = (S[player.skinvars].momentum or S[-1].momentum)
	if not diminish_time then return end -- Opted out
	
	local mo = player.mo
	if not(mo and mo.valid) then return end -- Doesn't exist
	if mo.skin == "adventuresonic" then return end -- Already has momentum

	local cmd = player.cmd
	local default_friction = 29*FRACUNIT/32

	if not (cmd.buttons or cmd.forwardmove or cmd.sidemove) then
		mo.friction = default_friction
	elseif FixedHypot(mo.momx, mo.momy) > skins[mo.skin].normalspeed then
		if (mo.eflags & MFE_JUSTHITFLOOR) then
			mo.lasthitfloor = leveltime
		elseif not mo.lasthitfloor then
			return
		end
		local diminish = (FRACUNIT - default_friction) / diminish_time
		local diminish_stacks = leveltime - mo.lasthitfloor
		mo.friction = max(FRACUNIT - (diminish * diminish_stacks), default_friction)
	end
end