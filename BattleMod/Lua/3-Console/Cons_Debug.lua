local B = CBW_Battle
local CV = B.Console

CV.Debug = CV_RegisterVar{
	name = "battledebug",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 15}
}
//See Lib_Debug for debug flag names

CV.DevCamera = CV_RegisterVar{
	name = "devcam",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}


COM_AddCommand("test",function(player, ...)
	if player != server then
		CONS_Printf(player, "Only the server host can execute this command.")
		return
	end
	if B.TestScript then
		local num = ... and tonumber(...) or "0"
		print("Executing test script "..num..": "..(B.TestScript(player, ...) or "Undefined"))
	else
		CONS_Printf(player,"No test script available for loading.")
	end
end,1)