freeslot(
	"SPR_SHAK",
	"S_SHAKE"
)

states[S_SHAKE] = {
	sprite = SPR_SHAK,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 5,
	var2 = 2,
	tics = 10,
	nexstate = S_NULL
}

freeslot(
	"SPR_SWET",
	"S_SWEAT"
)

states[S_SWEAT] = {
	sprite = SPR_SWET,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 2,
	var2 = 2,
	tics = 4,
	nexstate = S_NULL
}