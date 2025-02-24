local B = CBW_Battle

local applyFlip = function(mo1, mo2)
	if mo1.eflags & MFE_VERTICALFLIP then
		mo2.eflags = $|MFE_VERTICALFLIP
	else
		mo2.eflags = $ & ~MFE_VERTICALFLIP
	end
	
	if mo1.flags2 & MF2_OBJECTFLIP then
		mo2.flags2 = $|MF2_OBJECTFLIP
	else
		mo2.flags2 = $ & ~MF2_OBJECTFLIP
	end
end

B.MacGuffinPass = function(mo) --PreThinkFrame (For Tossflag)
	if mo and mo.valid and G_GametypeHasTeams() then
		if mo.target and mo.target.valid and mo.target.player then
            if mo.target.player.gotcrystal then
                local btns = mo.target.player.cmd.buttons

                local zpos = mo.target.z+(mo.target.height+(mo.target.scale*10))

                if P_MobjFlip(mo.target) == -1 then
                    zpos = (mo.target.z+mo.target.height)-(mo.target.height+(mo.target.scale*10))
                end

                if (btns&BT_TOSSFLAG) then
                    if not(mo.target.pass_indicator and mo.target.pass_indicator.valid) then
                        mo.target.pass_indicator = P_SpawnMobj(mo.target.x, mo.target.y, zpos, MT_PARTICLE)
                        mo.target.pass_indicator.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP|MF_NOCLIP
                        mo.target.pass_indicator.flags2 = $|MF2_DONTDRAW
                        mo.target.pass_indicator.fuse = -1
                        applyFlip(mo.target, mo.target.pass_indicator)
                        return
                    end
                    if (mo.target.pass_indicator and mo.target.pass_indicator.valid) then
                        applyFlip(mo.target, mo.target.pass_indicator)
                        P_MoveOrigin(mo.target.pass_indicator, mo.target.x, mo.target.y, zpos)
                        mo.target.pass_indicator.scale = mo.target.scale-(mo.target.scale/4)
                        mo.target.pass_indicator.frame = _G["A"]|FF_FULLBRIGHT
                        mo.target.pass_indicator.sprite = SPR_MACGUFFIN_PASS
                        mo.target.pass_indicator.color = ({{SKINCOLOR_PINK,SKINCOLOR_CRIMSON},{SKINCOLOR_AETHER,SKINCOLOR_COBALT}})[mo.target.player.ctfteam][1+(((leveltime/2)%2))]
                        mo.target.pass_indicator.renderflags = $|RF_NOCOLORMAPS
                        mo.target.pass_indicator.fuse = max($, 2)
                        if displayplayer and (mo.target.player.ctfteam == displayplayer.ctfteam) then
                            mo.target.pass_indicator.flags2 = $ & ~MF2_DONTDRAW
                        end
                    end
                else
                    if (mo.target.pass_indicator and mo.target.pass_indicator.valid) then
                        P_RemoveMobj(mo.target.pass_indicator)
                    end
                    mo.target.pass_indicator = nil
                end
            else
                if (mo.target.pass_indicator and mo.target.pass_indicator.valid) then
                    P_RemoveMobj(mo.target.pass_indicator)
                end
                mo.target.pass_indicator = nil
            end
		end
	end
end