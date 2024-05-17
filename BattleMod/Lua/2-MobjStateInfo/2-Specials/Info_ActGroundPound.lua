freeslot(
'mt_groundpound',
"MT_SUPERSPINWAVE",
"S_SUPPERSPIN_WAVE1","S_SUPPERSPIN_WAVE2","S_SUPPERSPIN_WAVE3",
"S_SUPPERSPIN_WALL1","S_SUPPERSPIN_WALL2","S_SUPPERSPIN_WALL3",
"S_SUPPERSPIN_WAVE_ACTIVE","S_SUPPERSPIN_WAVE_END",
"SPR_SPNV", "SPR_SPNW", "SPR_SPNX",
"SPR_SPDV", "SPR_SPDW", "SPR_SPDX"
)

//Sonic Ground Pound Projectile
mobjinfo[MT_GROUNDPOUND] = {
	spawnstate = S_ROCKCRUMBLEC,
	speed = 20*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 16*FRACUNIT,
	mass = 0,
	damage = 0,
	flags = MF_MISSILE|MF_BOUNCE|MF_GRENADEBOUNCE
}

//Sonic Spin Wave Projectile
mobjinfo[MT_SUPERSPINWAVE] = {
	name = "spin wave",
	doomednum = -1,
	spawnhealth = 100,
	spawnstate = S_SUPPERSPIN_WAVE_ACTIVE,
	deathstate = S_SUPPERSPIN_WAVE_END,
	radius = 32*FRACUNIT,
	height = 96*FRACUNIT,
	damage = 1,
	flags = MF_NOBLOCKMAP|MF_SCENERY // |MF_MISSILE is added later in the code
}

states[S_SUPPERSPIN_WAVE1] = { // front/back effects
	sprite = SPR_SPNV,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 4,
	action = none,
	var1 = 2,
	var2 = 2,
	nextstate = S_SUPPERSPIN_WAVE2
}

states[S_SUPPERSPIN_WAVE2] = { 
	sprite = SPR_SPNW,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 6,
	action = none,
	var1 = 6,
	var2 = 1,
	nextstate = S_SUPPERSPIN_WAVE2
}


states[S_SUPPERSPIN_WAVE3] = { 
	sprite = SPR_SPNX,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 6,
	action = none,
	var1 = 6,
	var2 = 1,
	nextstate = S_NULL
}

states[S_SUPPERSPIN_WALL1] = { // side  effects
	sprite = SPR_SPDV,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 4,
	action = none,
	var1 = 2,
	var2 = 2,
	nextstate = S_SUPPERSPIN_WALL2
}

states[S_SUPPERSPIN_WALL2] = { // test
	sprite = SPR_SPDW,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 6,
	action = none,
	var1 = 6,
	var2 = 1,
	nextstate = S_SUPPERSPIN_WALL2
}

states[S_SUPPERSPIN_WALL3] = { // paper sprite 
	sprite = SPR_SPDX,
	frame = FF_ANIMATE|FF_PAPERSPRITE|FF_FULLBRIGHT|A,
	tics = 6,
	action = none,
	var1 = 6,
	var2 = 1,
	nextstate = S_NULL
}

states[S_SUPPERSPIN_WAVE_ACTIVE] = { // projectile states
	sprite = SPR_NULL,
	frame = MF2_DONTDRAW|A,
	tics = 700,
	action = none,
	var1 = 0,
	var2 = 0,
	nextstate = S_NULL
}

states[S_SUPPERSPIN_WAVE_END] = {  
	sprite = SPR_NULL,
	frame = MF2_DONTDRAW|A,
	tics = 7,
	action = none,
	var1 = 0,
	var2 = 0,
	nextstate = S_NULL
}
