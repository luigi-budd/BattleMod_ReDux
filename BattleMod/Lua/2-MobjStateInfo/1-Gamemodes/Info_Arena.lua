freeslot("sfx_s243a")
sfxinfo[freeslot("sfx_svshar")].caption = "\x89".."Extra Life".."\x80"
sfxinfo[sfx_cdfm63].caption = "Tripwire!"
sfxinfo[freeslot("sfx_premon")].caption = "\x85".."Premonition".."\x80"

freeslot("S_PLAY_LOSS")
states[S_PLAY_LOSS] = {SPR_PLAY, SPR2_CNT1, 7, nil, 0, 0, S_PLAY_LOSS}