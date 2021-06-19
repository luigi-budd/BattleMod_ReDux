freeslot(
	'spr_flob',
	's_fangchar_lob1',
	's_fangchar_lob2',
	's_fangchar_lob3',
	'spr_cbom',
	's_colorbomb1',
	's_colorbomb2'
)

//Fang lob animation
states[S_FANGCHAR_LOB1] = {
	sprite = SPR_FLOB,
	frame = A
}

states[S_FANGCHAR_LOB2] = {
	sprite = SPR_FLOB,
	frame = B
}

states[S_FANGCHAR_LOB3] = {
	sprite = SPR_FLOB,
	frame = C
}


//Fang's team-colored bomb

states[S_COLORBOMB1] = {
	sprite = SPR_CBOM,
	frame = A,
	action = A_GhostMe,
	tics = 1,
	nextstate = S_COLORBOMB2
}

states[S_COLORBOMB2] = {
	sprite = SPR_CBOM,
	frame = B,
	action = A_GhostMe,
	tics = 1,
	nextstate = S_COLORBOMB1
}

states[S_FBOMB_EXPL2] = {
    sprite = SPR_BARX,
    frame = 1|FF_FULLBRIGHT,
    tics = 2,
    nextstate = S_FBOMB_EXPL3
}