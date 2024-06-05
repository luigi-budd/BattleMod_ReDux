local CV = CBW_Battle.Console
CV.ConfigPath = "client/battleconfig.cfg"
CV.BattleConfigs = {}

-- holy moly.. maybe we should use pcall() to prevent ppl from causing warnings? ~lu
CV.SaveConfig = function(player, configname, value, oldonly)
	if not(consoleplayer and consoleplayer == player) then
		return
	end

	local lines = {}
	local found = false
	if type(value) == "boolean" then
		value = $ and "1" or "0"
	end
	local newline = configname.." "..value
	local firstline = not oldonly
	local file = io.openlocal(CV.ConfigPath, "r")

	-- Read the current version from the file if it exists, and cancel operation when appropriate
	if oldonly and file and CBW_Battle.VersionNumber then
		for line in file:lines() do
        	local fileversion = 0
			local versionnumber, versionsub = line:match("(%d+)%s+($d+)")
			if versionnumber and versionsub then
				fileversion = tonumber(versionnumber) * 100 + tonumber(versionsub)
			end
			file:close()
			break --only read first line
    	end
		if (not CBW_Battle.VersionNumber)
		or ((CBW_Battle.VersionNumber * 100 + CBW_Battle.VersionSub) <= fileversion)
		then
			return
		end
	end

	-- Read the file and store the lines in a table
	local file = io.openlocal(CV.ConfigPath, "r")
	if file then
   	 	for line in file:lines() do
        	if firstline then
           	 	firstline = false
        	else
            	if line:sub(1, #configname) == configname then
                	table.insert(lines, newline)
                	found = true
            	else
                	table.insert(lines, line)
            	end
        	end
    	end
    	file:close()
	end

	-- If the config didn't exist in the config file, add is at as a new line
	if not found then
		if oldonly then
			return
		end
		table.insert(lines, newline)
	end

	-- Write the modified content back to the file
	local file = io.openlocal(CV.ConfigPath, "w")
	if file then
		if not oldonly then
			if CBW_Battle.VersionNumber then
				file:write(CBW_Battle.VersionNumber.." "..CBW_Battle.VersionSub.." "..CBW_Battle.VersionCommit.."\n")
			else
				file:write("PIRATE".."\n")
			end
		end
		for i, line in ipairs(lines) do
			file:write(line .. "\n")
		end
		file:close()
	else
		CONS_Printf(player, "Failed to save "..CV.ConfigPath)
	end
end

local function tostring2(value)
	if value == nil then
		return "nil"
	elseif type(value) == "boolean" then
		return value and "true" or "false"
	else
		return tostring(value)
	end
end

CV.AddBattleConfig = function(configname, func, defaultvalue)
	if not(configname and func and defaultvalue) then
		assert(false, "AHH!! AAAHHHHHHH!!\n".."One of these values is nil! "..tostring2(configname).." "..tostring2(func).." "..tostring2(defaultvalue)) --panic
	end
	COM_AddCommand(configname, func, 0)
	table.insert(CV.BattleConfigs, {configname, defaultvalue})
end

CV.ConfigFunc = function(player, arg, silent)
	local color = "\135"
    arg = $ and $:lower() or nil
    local CONS_Printl = function(text)
        if not silent then CONS_Printf(player, text) end
    end
    if (silent and silent != "silent") or not (arg == "load" or arg == "reset" or arg == "truereset") then
        CONS_Printl(color.."battleconfig <load/reset/truereset>: Load from or wipe BattleMod's configuration file, or wipe and return to the default values.")
    elseif (arg == "load") then
        local file = io.openlocal(CV.ConfigPath, "r")
        if file then
            local firstline = true
            for line in file:lines() do
                if firstline then
                    firstline = false
                else
                    COM_BufInsertText(player, line)
                end
            end
            file:close()
            CONS_Printl(color.."Configuration has been loaded!")
        else
            CONS_Printl(color.."Failed to access (luafiles/"..CV.ConfigPath.."). Perhaps it is missing?")
        end
    elseif (arg == "save") then
        CONS_Printl(color.."Nuh uh! Saving already happens automatically whenever you modify a battleconfig.")
    elseif (arg == "reset" or arg == "truereset") then
		if (arg == "truereset") then
        	for _, battleconfig in ipairs(CV.BattleConfigs) do 
				local config = battleconfig[1]
				local defaultvalue = battleconfig[2]
				CONS_Printl(color.."Executing: "..config.." "..defaultvalue)
				COM_BufInsertText(player, config.." "..defaultvalue)
			end
		end
		local file = io.openlocal(CV.ConfigPath, "w")
        if file then
            file:close()
            CONS_Printl(color.."Configuration has been reset!")
        else
            CONS_Printl(color.."Failed to find (luafiles/"..CV.ConfigPath.."). Success, I guess?")
        end
    end
end
CV.Config = COM_AddCommand("battleconfig", CV.ConfigFunc, COM_LOCAL)

local str2btn = {}
str2btn["jump"] = BT_JUMP
str2btn["spin"] = BT_SPIN
str2btn["fire"] = BT_ATTACK
str2btn["firenormal"] = BT_FIRENORMAL
str2btn["tossflag"] = BT_TOSSFLAG
str2btn["camleft"] = BT_CAMLEFT
str2btn["camright"] = BT_CAMRIGHT
str2btn["custom1"] = BT_CUSTOM1
str2btn["custom2"] = BT_CUSTOM2
str2btn["custom3"] = BT_CUSTOM3
str2btn["nextweapon"] = BT_WEAPONNEXT
str2btn["prevweapon"] = BT_WEAPONPREV
str2btn["weapon1"] = 1
str2btn["weapon2"] = 2
str2btn["weapon3"] = 3
str2btn["weapon4"] = 4
str2btn["weapon5"] = 5
str2btn["weapon6"] = 6
str2btn["weapon7"] = 7

local capitalize = function(word) --i know y'all hate capitalism but
	--also sorry, this could be optimized but i just feel like making a silly little hack for multiple words
	if word == "firenormal" then return "FireNormal"
	elseif word == "camleft" then return "CamLeft"
	elseif word == "camright" then return "CamRight"
	elseif word == "nextweapon" then return "NextWeapon"
	elseif word == "prevweapon" then return "PrevWeapon"
	else return (word:sub(1,1):upper() .. word:sub(2))
	end
end

local btn2str = {}
for str, btn in pairs(str2btn) do
	btn2str[btn] = capitalize(str)
end

//User Config

//Convert strings to flags
local getflags = function(args)
	local flags = 0

	for n = 1, #args
		local a = args[n]
		local numtype = tonumber(a) 
		local strtype = str2btn[tostring(a)]
		if
		numtype and numtype < BT_CUSTOM3<<1  and numtype > 0 then
			flags = $|numtype
-- 			print("Set number argument "..numtype)
		elseif
		strtype != nil then
			flags = $|strtype
-- 			print('Converted string "'..tostring(a)..'" to number argument argument '..strtype)
		else
-- 			print('Error: argument "'..tostring(a)..'" could not be read')
		end
	end
	return flags
end

local print_help = function(player)
	local buttons = ""
	for btn, str in pairs(btn2str) do
		buttons = $..str..", "
	end
	buttons = string.gsub($, ", $", ".")
	CONS_Printf(player,"\x86".."Valid arguments: "..buttons)
end

local validplayer = function(player, silent)
	if not(player and player.valid) then
		if not silent then
			CONS_Printf(player,"Please wait until inside a game to use this command.")
		end
		return false
	end
	return true
end

CV.SetYesNo = function(player, arg, config, defaultvalue, silent)
	if validplayer(player, silent) == false then
		return
	end
	arg = $ and $:lower() or nil
	local options = {
		["true"] = true, ["1"] = true, ["on"] = true, ["yes"] = true,
		["false"] = false, ["0"] = false, ["off"] = false, ["no"] = false,
	}
	local yesno = options[arg]
	if yesno == nil and not silent then
		CONS_Printf(player,config.." <On/Off>: Currently \135"..tostring2(player[config]).."\x80 - Default is \135"..defaultvalue)
	else
		player[config] = yesno
		CV.SaveConfig(player, config, yesno)
	end
end

CV.SetButton = function(player, args, config, defaultvalue, silent)
	if validplayer(player, silent) == false then
		return
	end
	for _,arg in ipairs(args) do
		arg = $:lower()
	end
	
	local flags = 0
	flags = args and getflags(args) or 0
	
	if flags == 0 or not #args then
		CONS_Printf(player,config.." <Button>: Currently \135"..btn2str[player[config]].."\x80 - Default is \135"..btn2str[defaultvalue])
		print_help(player)
	else
		player[config] = flags
		CV.SaveConfig(player, config, flags)
	end
end

--time to start adding battleconfigs! as of v10, default values are handled automatically, so don't worry about other scripts! ~lu
--TODO: maybe merge CV.SetYesNo and CV.SetButton by using the default value to determine what to do, would make implementation easier but maybe less performant?
local cfg, default = {}, {} --by the way, this is only necessary because we are adding them in bulk (so it doesnt print different commands later)

cfg[1], default[1] = "battleconfig_dodgecamera", "On"
CV.AddBattleConfig(cfg[1], function(player, arg) CV.SetYesNo(player, arg, cfg[1], default[1]) end, default[1])

cfg[2], default[2] = "battleconfig_autospectator", "On"
CV.AddBattleConfig(cfg[2], function(player, arg) CV.SetYesNo(player, arg, cfg[2], default[2]) end, default[2])

cfg[3], default[3] = "battleconfig_special", BT_ATTACK
CV.AddBattleConfig(cfg[3], function(player, ...) CV.SetButton(player, {...}, cfg[3], default[3]) end, default[3])

cfg[4], default[4] = "battleconfig_guard", BT_FIRENORMAL
CV.AddBattleConfig(cfg[4], function(player, ...) CV.SetButton(player, {...}, cfg[4], default[4]) end, default[4])

cfg[5], default[5] = "battleconfig_aimsight", "On"
CV.AddBattleConfig(cfg[5], function(player, arg) CV.SetYesNo(player, arg, cfg[5], default[5]) end, default[5])

cfg[6], default[6] = "battleconfig_charselect", "On"
CV.AddBattleConfig(cfg[6], function(player, arg) CV.SetYesNo(player, arg, cfg[6], default[6]) end, default[6])

cfg[7], default[7] = "battleconfig_nospinshield", "Off"
CV.AddBattleConfig(cfg[7], function(player, arg) CV.SetYesNo(player, arg, cfg[7], default[7]) end, default[7])

cfg[8], default[8] = "battleconfig_newhud", "On"
CV.AddBattleConfig(cfg[8], function(player, arg) CV.SetYesNo(player, arg, cfg[8], default[8]) end, default[8])

cfg[9], default[9] = "battleconfig_minimap", "On"
CV.AddBattleConfig(cfg[9], function(player, arg) CV.SetYesNo(player, arg, cfg[9], default[9]) end, default[9])

cfg[10], default[10] = "battleconfig_glidestrafe", "On"
CV.AddBattleConfig(cfg[10], function(player, arg) CV.SetYesNo(player, arg, cfg[10], default[10]) end, default[10])

cfg[11], default[11] = "battleconfig_hammerstrafe", "Off"
CV.AddBattleConfig(cfg[11], function(player, arg) CV.SetYesNo(player, arg, cfg[11], default[11]) end, default[11])

cfg[12], default[12] = "battleconfig_slipstreambutton", BT_WEAPONNEXT
CV.AddBattleConfig(cfg[12], function(player, ...) CV.SetButton(player, {...}, cfg[12], default[12]) end, default[12])

cfg[13], default[13] = "battleconfig_useslipstreambutton", "Off"
CV.AddBattleConfig(cfg[13], function(player, arg) CV.SetYesNo(player, arg, cfg[13], default[13]) end, default[13])
