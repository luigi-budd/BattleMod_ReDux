freeslot("MT_DASHMODE_OVERLAY",
         "sfx_dashe",
		 "sfx_dasht"
)

mobjinfo[MT_DASHMODE_OVERLAY] = {
	doomednum = -1,
	spawnstate = S_THOK,
	radius = FRACUNIT,
	height = FRACUNIT,
	dispoffset = mobjinfo[MT_PLAYER].dispoffset-1, --Behind player
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_SCENERY --Intangible
}


sfxinfo[sfx_dashe].caption = "\x82".."DASHMODE".."\x80"
sfxinfo[sfx_dasht].caption = "Dashmode"