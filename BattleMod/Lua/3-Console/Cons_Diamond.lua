local CV = CBW_Battle.Console

CV.DiamondCaptureTime = CV_RegisterVar{
	name = "diamond_capture_time",
	defaultvalue = 30,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 10, MAX = 60}
}

CV.DiamondCaptureBonus = CV_RegisterVar{
	name = "diamond_capture_bonus",
	defaultvalue = 500,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 100000}
}

CV.DiamondTeamCaptureBonus = CV_RegisterVar{
	name = "diamond_team_capture_bonus",
	defaultvalue = 300,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 100000}
}

CV.DiamondPointRadius = CV_RegisterVar{
	name = "diamond_point_radius",
	defaultvalue = 50,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 100000}
}

CV.DiamondPointUnlockTime = CV_RegisterVar{
	name = "diamond_point_unlock_time",
	defaultvalue = 500,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 100000}
}

CV.DiamondCapsBeforeReset = CV_RegisterVar{
	name = "diamond_caps_before_reset",
	defaultvalue = 1,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 20}
}

CV.DiamondTeamCapsBeforeReset = CV_RegisterVar{
	name = "diamond_team_caps_before_reset",
	defaultvalue = 1,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 20}
}

CV.DiamondDisableStealing = CV_RegisterVar{
	name = "diamond_disable_stealing",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = {Off = 0, On = 1}
}

CV.DiamondIndicator = CV_RegisterVar{
	name = "diamond_indicator",
	defaultvalue = 1,
	flags = CV_NETVAR,
	PossibleValue = {Off = 0, On = 1}
}

CV.DiamondTumbleAfterCap = CV_RegisterVar{
	name = "diamond_tumble_after_cap",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = {Off = 0, On = 1}
}
