freeslot('mt_ruby','s_phantomruby','spr_phrb','mt_rubyspawn','sfx_ruby0','sfx_ruby1','sfx_ruby2','sfx_ruby3','sfx_ruby4','sfx_ruby5')

sfxinfo[sfx_ruby0].caption = "Phantom Ruby"
sfxinfo[sfx_ruby1].caption = "Got ruby!"
sfxinfo[sfx_ruby2].caption = "Ruby respawned"
sfxinfo[sfx_ruby3].caption = "/"
sfxinfo[sfx_ruby4].caption = "Ruby warp"
sfxinfo[sfx_ruby5].caption = "Ruby presence"

// Ruby object
mobjinfo[MT_RUBY] = {
	doomednum = -1,
	spawnstate = S_PHANTOMRUBY,
	height = 32*FRACUNIT,
	radius = 16*FRACUNIT,
	flags = MF_SPECIAL
}

states[S_PHANTOMRUBY] = {
	sprite = SPR_PHRB,
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 3,
	var2 = 8,
	tics = -1
}

// Ruby spawnpoint object
mobjinfo[MT_RUBYSPAWN] = {
	//$Name "Ruby Spawn Point"
	//$Sprite PHRBA0
	//$Category "BattleMod Phantom Ruby"
	doomednum = 3630,
	spawnstate = 1,
	height = 32*FRACUNIT,
	radius = 24*FRACUNIT,
	flags = MF_NOTHINK|MF_NOSECTOR
}
