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
	"SPR_SPAK",
	"S_SWEAT",
	"S_SPARK"
)

states[S_SWEAT] = {
	sprite = SPR_SWET,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 2,
	var2 = 2,
	tics = 4,
	nexstate = S_NULL
}

states[S_SPARK] = {
	sprite = SPR_SPAK,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 2,
	var2 = 2,
	tics = 4,
	nexstate = S_NULL
}

freeslot(
	"SPR_SLAS",
	"S_SLASH"
)

states[S_SLASH] = {
	sprite = SPR_SLAS,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 5,
	var2 = 2,
	tics = 10,
	nexstate = S_NULL
}