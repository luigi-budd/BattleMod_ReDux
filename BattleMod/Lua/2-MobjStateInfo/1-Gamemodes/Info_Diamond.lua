freeslot('mt_diamond',
	'mt_diamondspawn',
	"spr_mshd", -- the diamond indicator (the one that displays over people's head)
	"spr_topz", -- topaz
	"spr_shrd", -- old diamond sprite
	"s_topaz",
	"mt_gotdiamond", -- the diamond indicator (the one that displays over people's head)
	"s_gotdiamond",
	"sfx_dmstl1",
	"sfx_dmstl2",
	"sfx_dmstl3",
	"sfx_stle",
	"sfx_stlt",
	"sfx_shimr",
	"sfx_tpzspn",
	"sfx_tpzdrp"
	)

-- Topaz sprite
states[S_TOPAZ] = {SPR_TOPZ, 0, -1, nil, 0, 0, S_NULL, 0}

-- Diamond object
mobjinfo[MT_DIAMOND] = {
	doomednum = -1,
	spawnstate = S_TOPAZ,
	height = 32*FRACUNIT,
	radius = 12*FRACUNIT,
	flags = MF_SPECIAL
}

-- Control point object
mobjinfo[MT_DIAMONDSPAWN] = {
	--$Name "Topaz Spawnpoint"
	--$Sprite TOPZA0
	--$Category "BattleMod Mcguffins"
	doomednum = 3631,
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