local CV = CBW_Battle.Console

CV.CTFdropgrace = CV_RegisterVar{
	name = "ctf_flagdrop_graceperiod",
	defaultvalue = 2,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 3}
}

CV.CTFrespawngrace = CV_RegisterVar{
	name = "ctf_flagrespawn_graceperiod",
	defaultvalue = 6,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 15}
}

--[[/*
-- NOTE: This is an unused consvar!
CV.CTFdelaycap = CV_RegisterVar {
	name = "ctf_delay_cap",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}
COM_AddCommand("killflags", function(player)
    for mo in mobjs.iterate() do
        if mo.type == MT_CREDFLAG or mo.type == MT_CBLUEFLAG then
        	mo.wasgrabbed = true
            P_KillMobj(mo)
            
        end
    end

    -- Give everyone flags
    for p in players.iterate do
    	if p.mo and p.mo.valid then
			p.gotflag = p.ctfteam == 2 and GF_REDFLAG or GF_BLUEFLAG
		end
    end
    local F = CBW_Battle.CTF
	F.DelayCap = 1
end)
*/--]]
