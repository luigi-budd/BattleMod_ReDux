freeslot('mt_diamond',
	'mt_diamondspawn',
	"spr_mshd", -- the diamond indicator (the one that displays over people's head)
	"spr_topz", -- topaz
	"mt_gotdiamond", -- the diamond indicator (the one that displays over people's head)
	"s_gotdiamond",
	"sfx_dmstl1",
	"sfx_dmstl2",
	"sfx_dmstl3",
	"sfx_stle",
	"sfx_stlt",
	"sfx_shimr"
	)

-- Diamond object
mobjinfo[MT_DIAMOND] = {
	doomednum = -1,
	spawnstate = S_SHRD1,
	height = 32*FRACUNIT,
	radius = 12*FRACUNIT,
	flags = MF_SPECIAL
}

-- Control point object
mobjinfo[MT_DIAMONDSPAWN] = {
	--$Name "Diamond Spawn Point"
	--$Sprite SHRDA0
	--$Category "BattleMod Diamond in the Rough"
	doomednum = 3630,
	spawnstate = 1,
	height = 32*FRACUNIT,
	radius = 24*FRACUNIT,
	flags = MF_NOTHINK|MF_NOSECTOR
}

mobjinfo[MT_GOTDIAMOND] = 
{
	doomednum = -1,
	spawnstate = S_GOTDIAMOND,
	spawnhealth = 1000,
	speed = 8,
	radius = 64*FRACUNIT,
	height = 32*FRACUNIT,
	mass = 16,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOGRAVITY|MF_SCENERY
}

states[S_GOTDIAMOND] = 
{
	sprite = SPR_MSHD,
	frame = A|FF_FULLBRIGHT,
	--tics = -1,
}

