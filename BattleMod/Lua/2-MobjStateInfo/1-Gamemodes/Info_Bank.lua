freeslot('mt_battle_chaosring', 'mt_battle_chaosringspawner')

mobjinfo[MT_BATTLE_CHAOSRING] = {
	doomednum = -1,
	spawnstate = S_TEAMRING,
	height = 32*FRACUNIT,
	radius = 16*FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY
}

mobjinfo[MT_BATTLE_CHAOSRINGSPAWNER] = {
	--$Name "Chaos Ring Spawnpoint"
	--$Sprite ZBCHRING
	--$Category "BattleMod Mcguffins"
	doomednum = 3707,
	spawnstate = S_NULL,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOSECTOR
}
