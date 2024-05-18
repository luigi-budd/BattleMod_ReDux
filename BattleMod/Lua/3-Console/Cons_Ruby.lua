local CV = CBW_Battle.Console

CV.RubyCaptureTime = CV_RegisterVar{
	name = "ruby_capture_time",
	defaultvalue = 30,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 10, MAX = 60}
}

CV.RubyCaptureBonus = CV_RegisterVar{
	name = "ruby_capture_bonus",
	defaultvalue = 1000,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 100000}
}
