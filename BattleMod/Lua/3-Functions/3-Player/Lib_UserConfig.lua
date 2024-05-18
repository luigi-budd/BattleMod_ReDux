local B = CBW_Battle

-- TODO: (rev:) It's been a while and we can't use `exec` with lua anymore. So this needs to be redone
local configplayer	-- used to know when the config should be reloaded
B.UserConfig = function()
	if consoleplayer and consoleplayer.valid and (not configplayer or not configplayer.valid)
		-- config must be reloaded
		COM_BufInsertText(consoleplayer, "exec battleconfig.cfg -noerror")	-- for some retarded ass reason, you can't use both -silent and -noerror
		configplayer = consoleplayer
	end
end
