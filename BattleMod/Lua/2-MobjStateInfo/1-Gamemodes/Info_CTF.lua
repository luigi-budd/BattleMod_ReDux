sfxinfo[freeslot('sfx_toss')].caption = "\x82".."Flag Tossed".."\x80"
sfxinfo[freeslot('sfx_flgwht')].caption = "\x82".."ENEMY FLAG LOST".."\x80"

freeslot('MT_CREDFLAG', 'MT_CBLUEFLAG')
freeslot('S_CREDFLAG', 'S_CBLUEFLAG')

--State definitions
states[S_CREDFLAG] = {SPR_RFLG, FF_FULLBRIGHT|A, -1, nil, 0, 0, nil}
states[S_CBLUEFLAG] = {SPR_BFLG, FF_FULLBRIGHT|A, -1, nil, 0, 0, nil}

--Object definitions
mobjinfo[MT_CREDFLAG] = { 
        doomednum = -1, -- IDK..
        spawnstate = S_CREDFLAG,
        spawnhealth = 1000,
        seestate = S_NULL,
        seesound = sfx_None,
        reactiontime = 8,
        attacksound = sfx_None,
        painstate = S_NULL,
        painchance = 0,
        painsound = sfx_None,
        meleestate = S_NULL,
        missilestate = S_NULL,
        deathstate = S_NULL,
        xdeathstate = S_NULL,
        deathsound = sfx_lvpass,
        speed = 8,
        radius = 24*FRACUNIT,
        height = 64*FRACUNIT,
        dispoffset = 0, -- tearing?
        mass = 16,
        damage = 0,
        activesound = sfx_None,
        flags = MF_SPECIAL,
        raisestate = S_NULL
}
mobjinfo[MT_CBLUEFLAG] = {
        doomednum = -1, -- IDK..
        spawnstate = S_CBLUEFLAG,
        spawnhealth = 1000,
        seestate = S_NULL,
        seesound = sfx_None,
        reactiontime = 8,
        attacksound = sfx_None,
        painstate = S_NULL,
        painchance = 0,
        painsound = sfx_None,
        meleestate = S_NULL,
        missilestate = S_NULL,
        deathstate = S_NULL,
        xdeathstate = S_NULL,
        deathsound = sfx_lvpass,
        speed = 8,
        radius = 24*FRACUNIT,
        height = 64*FRACUNIT,
        dispoffset = 0, -- tearing?
        mass = 16,
        damage = 0,
        activesound = sfx_None,
        flags = MF_SPECIAL,
        raisestate = S_NULL
}

--CTF Flags
mobjinfo[MT_CREDFLAG].flags = 0
mobjinfo[MT_CBLUEFLAG].flags = 0
