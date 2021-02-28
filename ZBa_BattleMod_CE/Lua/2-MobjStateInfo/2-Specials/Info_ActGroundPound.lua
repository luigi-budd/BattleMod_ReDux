freeslot('mt_groundpound')

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