freeslot('mt_tagginghand')
//Tagging hand object
mobjinfo[MT_TAGGINGHAND] = {
	spawnstate = 1,
	height = 32*FRACUNIT,
	radius = 24*FRACUNIT,
	flags = MF_NOGRAVITY|MF_MISSILE|MF_NOSECTOR
}

//little indicator that hovers over taggers in battle tag
freeslot("S_BATTLETAG_IT", "MT_BATTLETAG_IT")
states[S_BATTLETAG_IT] = {
	sprite = SPR_TTAG,
	frame = FF_FULLBRIGHT | A,
	tics = -1,
	nextstate = S_BATTLETAG_IT
}
mobjinfo[MT_BATTLETAG_IT] = {
	spawnstate = S_BATTLETAG_IT,
	height = 10 * FRACUNIT,
	radius = 5 * FRACUNIT,
	dispoffset = 1,
	flags = MF_NOCLIP | MF_NOCLIPHEIGHT | MF_SCENERY | MF_NOGRAVITY
}

//this is fucking scuffed but i have no other options
/*freeslot("S_BTAG_BLINDFOLD", "MT_BTAG_BLINDFOLD")
states[S_BTAG_BLINDFOLD] = {
	sprite = SPR_THOK,
	frame = FF_FULLDARK | A,
	tics = -1,
	nextstate = S_BTAG_BLINDFOLD
}
mobjinfo[MT_BTAG_BLINDFOLD] = {
	spawnstate = S_BTAG_BLINDFOLD,
	height = 10 * FRACUNIT,
	radius = 5 * FRACUNIT,
	flags = MF_NOCLIP | MF_NOCLIPHEIGHT | MF_SCENERY | MF_NOGRAVITY
}*/