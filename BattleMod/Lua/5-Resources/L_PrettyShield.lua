--
-- ==== Ringler, a Ringslinger Overhaul ====
-- == By Kart Krew ==
--
-- r_pity.lua: Less distracting pity shield
--

freeslot("S_PITY_BACK");

states[S_PITY1] = {SPR_PITY, FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY2};
states[S_PITY2] = {SPR_PITY, 1|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY3};
states[S_PITY3] = {SPR_PITY, 2|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY4};
states[S_PITY4] = {SPR_PITY, 3|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY5};
states[S_PITY5] = {SPR_PITY, 4|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY6};
states[S_PITY6] = {SPR_PITY, 5|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY7};
states[S_PITY7] = {SPR_PITY, 6|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY8};
states[S_PITY8] = {SPR_PITY, 7|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY9};
states[S_PITY9] = {SPR_PITY, 8|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY10};
states[S_PITY10] = {SPR_PITY, 9|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY11};
states[S_PITY11] = {SPR_PITY, 10|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY12};
states[S_PITY12] = {SPR_PITY, 11|FF_FULLBRIGHT|FF_TRANS50, 2, nil, 0, 0, S_PITY1};

states[S_PITY_BACK] = {SPR_PITY, 12|FF_FULLBRIGHT|FF_TRANS70, -1, nil, 1, 0, S_PITY_BACK};

mobjinfo[MT_PITY_ORB].seestate = S_PITY_BACK;

addHook("MobjThinker", function(mo)
	mo.blendmode = AST_ADD;

	local bg = mo.tracer;
	if not (bg and bg.valid)
		return;
	end

	local owner = mo.target;
	if not (owner and owner.valid)
		return;
	end

	local player = owner.player;
	if not (player and player.valid)
		return;
	end

	if ((player.powers[pw_shield] & SH_NOSTACK) == SH_PINK)
		mo.color = SKINCOLOR_RASPBERRY;
		bg.color = SKINCOLOR_RASPBERRY;
		bg.colorized = true;
		bg.blendmode = AST_ADD;
	end
end, MT_PITY_ORB);

states[S_ARMA1] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT, 2, nil, 1, 0, S_ARMA2};
states[S_ARMA2] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|1, 2, nil, 1, 0, S_ARMA3};
states[S_ARMA3] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|2, 2, nil, 1, 0, S_ARMA4};
states[S_ARMA4] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|3, 2, nil, 1, 0, S_ARMA5};
states[S_ARMA5] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|4, 2, nil, 1, 0, S_ARMA6};
states[S_ARMA6] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|5, 2, nil, 1, 0, S_ARMA7};
states[S_ARMA7] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|6, 2, nil, 1, 0, S_ARMA8};
states[S_ARMA8] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|7, 2, nil, 1, 0, S_ARMA9};
states[S_ARMA9] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|8, 2, nil, 1, 0, S_ARMA10};
states[S_ARMA10] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|9, 2, nil, 1, 0, S_ARMA11};
states[S_ARMA11] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|10, 2, nil, 1, 0, S_ARMA12};
states[S_ARMA12] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|11, 2, nil, 1, 0, S_ARMA13};
states[S_ARMA13] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|12, 2, nil, 1, 0, S_ARMA14};
states[S_ARMA14] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|13, 2, nil, 1, 0, S_ARMA15};
states[S_ARMA15] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|14, 2, nil, 1, 0, S_ARMA16};
states[S_ARMA16] = {SPR_ARMA, FF_ADD|FF_FULLBRIGHT|15, 2, nil, 1, 0, S_ARMA1};

mobjinfo[MT_ARMAGEDDON_ORB].spawnstate = S_ARMF1;
mobjinfo[MT_ARMAGEDDON_ORB].seestate = S_ARMA1;

freeslot(
	"SPR_MAGF",
	"S_MAGF1",
	"S_MAGF2",
	"S_MAGF3",
	"S_MAGF4",
	"S_MAGF5",
	"S_MAGF6",
	"S_MAGF7",
	"S_MAGF8",
	"S_MAGF9",
	"S_MAGF10",
	"S_MAGF11",
	"S_MAGF12"
);

states[S_MAGN1] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10, 2, nil, 1, 0, S_MAGN2};
states[S_MAGN2] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|1, 2, nil, 1, 0, S_MAGN3};
states[S_MAGN3] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|2, 2, nil, 1, 0, S_MAGN4};
states[S_MAGN4] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|3, 2, nil, 1, 0, S_MAGN5};
states[S_MAGN5] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|4, 2, nil, 1, 0, S_MAGN6};
states[S_MAGN6] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|5, 2, nil, 1, 0, S_MAGN7};
states[S_MAGN7] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|6, 2, nil, 1, 0, S_MAGN8};
states[S_MAGN8] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|7, 2, nil, 1, 0, S_MAGN9};
states[S_MAGN9] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|8, 2, nil, 1, 0, S_MAGN10};
states[S_MAGN10] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|9, 2, nil, 1, 0, S_MAGN11};
states[S_MAGN11] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|10, 2, nil, 1, 0, S_MAGN12};
states[S_MAGN12] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|FF_TRANS10|11, 2, nil, 1, 0, S_MAGN1};

states[S_MAGN13] = {SPR_MAGN, FF_ADD|FF_FULLBRIGHT|12, 2, nil, 0, 0, S_MAGF1};

states[S_MAGF1] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT, 2, nil, 0, 0, S_MAGF2};
states[S_MAGF2] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|1, 2, nil, 0, 0, S_MAGF3};
states[S_MAGF3] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|2, 2, nil, 0, 0, S_MAGF4};
states[S_MAGF4] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|3, 2, nil, 0, 0, S_MAGF5};
states[S_MAGF5] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|4, 2, nil, 0, 0, S_MAGF6};
states[S_MAGF6] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|5, 2, nil, 0, 0, S_MAGF7};
states[S_MAGF7] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|6, 2, nil, 0, 0, S_MAGF8};
states[S_MAGF8] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|7, 2, nil, 0, 0, S_MAGF9};
states[S_MAGF9] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|8, 2, nil, 0, 0, S_MAGF10};
states[S_MAGF10] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|9, 2, nil, 0, 0, S_MAGF11};
states[S_MAGF11] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|10, 2, nil, 0, 0, S_MAGF12};
states[S_MAGF12] = {SPR_MAGF, FF_ADD|FF_FULLBRIGHT|11, 2, nil, 0, 0, S_MAGF1};

mobjinfo[MT_ATTRACT_ORB].spawnstate = S_MAGF1;
mobjinfo[MT_ATTRACT_ORB].seestate = S_MAGN1;

freeslot(
	"SPR_FORG",
	"SPR_FORH",
	"S_FORCE_GRID1",
	"S_FORCE_GRID2",
	"S_FORCE_GRID3",
	"S_FORCE_GRID4",
	"S_FORCE_GRID5",
	"S_FORCE_GRID6",
	"S_FORCE_GRID_WEAK",
	"S_FORCE_HEX_F1",
	"S_FORCE_HEX_F2",
	"S_FORCE_HEX_F3",
	"S_FORCE_HEX_F4",
	"S_FORCE_HEX_F5",
	"S_FORCE_HEX_F6",
	"S_FORCE_HEX_FWAIT",
	"S_FORCE_HEX_B1",
	"S_FORCE_HEX_B2",
	"S_FORCE_HEX_B3",
	"S_FORCE_HEX_B4",
	"S_FORCE_HEX_B5",
	"S_FORCE_HEX_B6",
	"S_FORCE_HEX_BWAIT1",
	"S_FORCE_HEX_BWAIT2"
);

states[S_FORCE_GRID1] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30, 2, nil, 1, 0, S_FORCE_GRID2};
states[S_FORCE_GRID2] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30|1, 2, nil, 1, 0, S_FORCE_GRID3};
states[S_FORCE_GRID3] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30|2, 2, nil, 1, 0, S_FORCE_GRID4};
states[S_FORCE_GRID4] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30|3, 2, nil, 1, 0, S_FORCE_GRID5};
states[S_FORCE_GRID5] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30|4, 2, nil, 1, 0, S_FORCE_GRID6};
states[S_FORCE_GRID6] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|FF_TRANS30|5, 2, nil, 1, 0, S_FORCE_GRID1};

states[S_FORCE_GRID_WEAK] = {SPR_FORG, FF_ADD|FF_FULLBRIGHT|6, -1, nil, 1, 0, S_NULL};

states[S_FORCE_HEX_F1] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT, 2, nil, 0, 0, S_FORCE_HEX_F2};
states[S_FORCE_HEX_F2] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|1, 2, nil, 0, 0, S_FORCE_HEX_F3};
states[S_FORCE_HEX_F3] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|2, 2, nil, 0, 0, S_FORCE_HEX_F4};
states[S_FORCE_HEX_F4] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|3, 2, nil, 0, 0, S_FORCE_HEX_F5};
states[S_FORCE_HEX_F5] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|4, 2, nil, 0, 0, S_FORCE_HEX_F6};
states[S_FORCE_HEX_F6] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|5, 2, nil, 0, 0, S_FORCE_HEX_FWAIT};

states[S_FORCE_HEX_FWAIT] = {SPR_NULL, 0, 24, nil, 0, 0, S_FORCE_HEX_F1};

states[S_FORCE_HEX_B1] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|6, 2, nil, 1, 0, S_FORCE_HEX_B2};
states[S_FORCE_HEX_B2] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|7, 2, nil, 1, 0, S_FORCE_HEX_B3};
states[S_FORCE_HEX_B3] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|8, 2, nil, 1, 0, S_FORCE_HEX_B4};
states[S_FORCE_HEX_B4] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|9, 2, nil, 1, 0, S_FORCE_HEX_B5};
states[S_FORCE_HEX_B5] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|10, 2, nil, 1, 0, S_FORCE_HEX_B6};
states[S_FORCE_HEX_B6] = {SPR_FORH, FF_ADD|FF_FULLBRIGHT|11, 2, nil, 1, 0, S_FORCE_HEX_BWAIT1};

states[S_FORCE_HEX_BWAIT1] = {SPR_NULL, 0, 6, nil, 1, 0, S_FORCE_HEX_BWAIT2};
states[S_FORCE_HEX_BWAIT2] = {SPR_NULL, 0, 18, nil, 1, 0, S_FORCE_HEX_B1};

states[S_FORC21] = {SPR_FORC, FF_ADD|FF_FULLBRIGHT|20, -1, nil, 0, 0, S_NULL};

mobjinfo[MT_FORCE_ORB].spawnstate = S_FORCE_HEX_F1;
mobjinfo[MT_FORCE_ORB].painstate = S_INVISIBLE;
mobjinfo[MT_FORCE_ORB].seestate = S_FORCE_GRID1;
mobjinfo[MT_FORCE_ORB].meleestate = S_FORCE_HEX_BWAIT2;

addHook("MobjThinker", function(mo)
	local bg = mo.tracer;
	if not (bg and bg.valid)
		return;
	end

	local owner = mo.target;
	if not (owner and owner.valid)
		return;
	end

	local player = owner.player;
	if not (player and player.valid)
		return;
	end

	if (mo.movecount < 1)
		if (bg.state >= S_FORCE_GRID1)
		and (bg.state <= S_FORCE_GRID2)
			bg.state = S_FORCE_GRID_WEAK;
		end

		bg.flags2 = $1 ^^ MF2_DONTDRAW;
	else
		if (bg.state == S_FORCE_GRID_WEAK)
			bg.state = S_FORCE_GRID1;
		end

		bg.flags2 = $1 & ~MF2_DONTDRAW;
	end
end, MT_FORCE_ORB);

states[S_ELEM1] = {SPR_ELEM, FF_ADD, 4, nil, 1, 0, S_ELEM2};
states[S_ELEM2] = {SPR_ELEM, FF_ADD|1, 4, nil, 1, 0, S_ELEM3};
states[S_ELEM3] = {SPR_ELEM, FF_ADD|2, 4, nil, 1, 0, S_ELEM4};
states[S_ELEM4] = {SPR_ELEM, FF_ADD|3, 4, nil, 1, 0, S_ELEM5};
states[S_ELEM5] = {SPR_ELEM, FF_ADD|4, 4, nil, 1, 0, S_ELEM6};
states[S_ELEM6] = {SPR_ELEM, FF_ADD|5, 4, nil, 1, 0, S_ELEM7};
states[S_ELEM7] = {SPR_ELEM, FF_ADD|6, 4, nil, 1, 0, S_ELEM8};
states[S_ELEM8] = {SPR_ELEM, FF_ADD|7, 4, nil, 1, 0, S_ELEM9};
states[S_ELEM9] = {SPR_ELEM, FF_ADD|8, 4, nil, 1, 0, S_ELEM10};
states[S_ELEM10] = {SPR_ELEM, FF_ADD|9, 4, nil, 1, 0, S_ELEM11};
states[S_ELEM11] = {SPR_ELEM, FF_ADD|10, 4, nil, 1, 0, S_ELEM12};
states[S_ELEM12] = {SPR_ELEM, FF_ADD|11, 4, nil, 1, 0, S_ELEM1};

states[S_ELEM14] = {SPR_ELEM, FF_ADD|11, 1, nil, 1, 0, S_ELEM1};

states[S_ELEMF1] = {SPR_ELEM, FF_FULLBRIGHT|12, 3, nil, 0, 0, S_ELEMF2};
states[S_ELEMF2] = {SPR_ELEM, FF_FULLBRIGHT|13, 3, nil, 0, 0, S_ELEMF3};
states[S_ELEMF3] = {SPR_ELEM, FF_FULLBRIGHT|14, 3, nil, 0, 0, S_ELEMF4};
states[S_ELEMF4] = {SPR_ELEM, FF_FULLBRIGHT|15, 3, nil, 0, 0, S_ELEMF5};
states[S_ELEMF5] = {SPR_ELEM, FF_FULLBRIGHT|16, 3, nil, 0, 0, S_ELEMF6};
states[S_ELEMF6] = {SPR_ELEM, FF_FULLBRIGHT|17, 3, nil, 0, 0, S_ELEMF7};
states[S_ELEMF7] = {SPR_ELEM, FF_FULLBRIGHT|18, 3, nil, 0, 0, S_ELEMF8};
states[S_ELEMF8] = {SPR_ELEM, FF_FULLBRIGHT|19, 3, nil, 0, 0, S_ELEMF1};

states[S_ELEMF9] = {SPR_ELEM, FF_FULLBRIGHT|20, 1, nil, 0, 0, S_ELEMF10};

mobjinfo[MT_ELEMENTAL_ORB].spawnstate = S_ELEMF1;
mobjinfo[MT_ELEMENTAL_ORB].seestate = S_ELEM1;
mobjinfo[MT_ELEMENTAL_ORB].painstate = S_ELEMF9;
mobjinfo[MT_ELEMENTAL_ORB].raisestate = S_ELEM13;

addHook("MobjThinker", function(mo)
	local bg = mo.tracer;
	if not (bg and bg.valid)
		return;
	end

	local owner = mo.target;
	if not (owner and owner.valid)
		return;
	end

	local player = owner.player;
	if not (player and player.valid)
		return;
	end

	mo.colorized = true;
	mo.color = player.skincolor;
	bg.colorized = mo.colorized;
	bg.color = mo.color;
end, MT_ELEMENTAL_ORB);