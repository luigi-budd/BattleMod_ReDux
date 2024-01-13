freeslot("MT_EFIREWORK","S_EFIREWORK0","S_EFIREWORK1","S_EFIREWORK2","S_EFIREWORK3")

function A_SetSkinFirework(fw, var1, var2)
	S_StartSound(fw, sfx_s227)
	fw.skin = "sonic"
end

function A_AdvFireworkFrame1(fw, var1, var)
	S_StartSound(fw, sfx_s3kb3)
	-- Without the below, the object is an MT_NULL (and the object errors)
	fw.sprite = SPR_PLAY
    fw.sprite2 = SPR2_XTRA
	fw.frame = D|FF_FULLBRIGHT|FF_TRANS50
	fw.momz = fw.speed*2
end

function A_AdvFireworkFrame2(fw, var1, var)
	fw.sprite = SPR_PLAY
    fw.sprite2 = SPR2_XTRA
	fw.frame = E|FF_FULLBRIGHT|FF_TRANS50
	fw.momz = 1+fw.speed/2
end

function A_AdvFireworkFrame3(fw, var1, var)
	fw.sprite = SPR_PLAY
    fw.sprite2 = SPR2_XTRA
	fw.frame = E|FF_FULLBRIGHT|FF_TRANS50
	fw.momz = fw.speed
	fw.scalespeed = 1+$/4
	fw.destscale = $*2
end

mobjinfo[MT_EFIREWORK].flags = mobjinfo[MT_THOK].flags

states[S_EFIREWORK0] = {
	tics = 21, --Time before the firework actually "explodes"
	action = A_SetSkinFirework,
	flags2 = MF2_DONTDRAW,
	nextstate = S_EFIREWORK1
}

states[S_EFIREWORK1] = {
	tics = 21,
	action = A_AdvFireworkFrame1,
	nextstate = S_EFIREWORK2
}

states[S_EFIREWORK2] = {
	tics = 21,
	action = A_AdvFireworkFrame2,
	nextstate = S_NULL
}

states[S_EFIREWORK2] = {
	tics = 21,
	action = A_AdvFireworkFrame3,
	nextstate = S_NULL
}