local B = CBW_Battle
local CV = B.Console

COM_AddCommand("battleversioninfo",function(player)
	CONS_Printf(player,
		"\x82".."BattleMod ("..B.VersionNumber.."."..B.VersionSub..
		") \x80 written by CobaltBW. Last updated "..CBW_Battle.VersionDate.."\n"..
		"Maps created by CobaltBW, FlareBlade93, and Krabs.\n"..
		"Please visit the mb.SRB2.org topic or review this pk3's Credits.txt and PatchNotes.txt for full credits & changelog."
	)
end,0)

COM_AddCommand("suicide",function(player)
	if player.spectator
	or not(player.mo)
	or player.playerstate != PST_LIVE
	or P_PlayerInPain(player)
	or not(P_IsObjectOnGround(player.mo))
		CONS_Printf(player,"You can't use this command right now!")
	else
		P_PlayerWeaponPanelOrAmmoBurst(player)
		P_PlayerEmeraldBurst(player)
		P_PlayerFlagBurst(player)
		P_KillMobj(player.mo)
	end
end,0)
/*
COM_AddCommand("skin",function(player,name,[...])
	//Gate
	if (
		P_PlayerInPain(player)
		or not(P_IsObjectOnGround(player.mo)
		or (
	)
	and not(B.PreRoundWait() 
		or ((gametyperules & GTR_RACE) && leveltime < 4*TICRATE) and (leveltime < CV_FindVar("hidetime").value * TICRATE)
		CONS_Printf(player,"You can't use this command right now! (Use -suicide to override)")
	elseif name == nil //No arguments
		CONS_Printf(player,"skin <name> <-suicide> <-defcolor>")
	elseif skins[name]
		if not(R_SkinUsable(player,name))
			CONS_Printf(player,"You haven't earned this yet!")
		else
			CONS_Printf(player,"<placeholder>")
		end
	else
		CONS_Printf(player,'Skin "'..name..'" not found')
	end
end,0)*/

CV.CoyoteTime = CV_RegisterVar{
	name = "battle_coyotetime",
	defaultvalue = 3,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 1, MAX = 99}
}
CV.CoyoteFactor = CV_RegisterVar{
	name = "battle_coyotefactor",
	defaultvalue = 15,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 15}
}
CV.RecoveryJump = CV_RegisterVar{
	name = "battle_recoveryjump",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}