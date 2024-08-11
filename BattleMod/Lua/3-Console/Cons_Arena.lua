local CV = CBW_Battle.Console

CV.SurvivalStock = CV_RegisterVar{
	name = "survival_lives",
	defaultvalue = 3,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 1, MAX = 99}
}
CV.Revenge = CV_RegisterVar{
	name = "survival_revenge",
	defaultvalue = 2,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 2}
}
CV.SuddenDeath = CV_RegisterVar{
	name = "survival_suddendeath",
	defaultvalue = 1,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}
CV.Bounty = CV_RegisterVar{
	name = "battle_bounty",
	defaultvalue = 1,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}