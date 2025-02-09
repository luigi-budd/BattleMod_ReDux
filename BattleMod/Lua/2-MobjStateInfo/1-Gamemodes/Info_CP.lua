freeslot(
	'mt_controlpoint',
	'mt_cpbonus',
	's_cpbonus',
	'spr_cpbs',
	'spr_dthz'
)

// Control point object
mobjinfo[MT_CONTROLPOINT] = {
	//$Name "Control Point"
	//$Sprite EMBMA0
	//$Category "BattleMod Control Point"
	--$arg0 [1-15]Set amount of time to capture point
	--$arg1 [0-384]Set the size of the CP Radius
	--$arg2 [1]Height is decreased by 50%.
	--$arg3 [1]Height is increased by 100% 
	--$arg4 [1]Base and height are equal to the floor and ceiling height of the sector.
	doomednum = 3640,
	spawnstate = S_EMBLEM1,
	height = 32*FRACUNIT,
	radius = 24*FRACUNIT,
	flags = MF_NOGRAVITY|MF_SCENERY
}

// Control point object's bonus sphere graphic
mobjinfo[MT_CPBONUS] = {
	spawnstate = S_CPBONUS,
	flags = MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT
}

states[S_CPBONUS] = {
	sprite = SPR_CPBS,
	frame = A|FF_FULLBRIGHT|FF_TRANS10,
	tics = 0,
	nextstate = S_CPBONUS
}