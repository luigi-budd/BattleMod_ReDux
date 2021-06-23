local B = CBW_Battle

B.Choose = function(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end
