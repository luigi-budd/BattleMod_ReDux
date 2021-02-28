local B = CBW_Battle
local PFunc = B.PriorityFunction

B.AddPriorityFunction = function(name,func)
	if not(name) then //Invalid name
		B.Warning("Invalid argument #1 provided for CBW_Battle.AddPriorityFunction()")
	return nil end
	if not(type(name) == "string") then //Name isn't a string
		B.Warning("Argument #1 for CBW_Battle.AddPriorityFunction() must be a string!")
	return nil end
	if PFunc[name] != nil then //Name already exists
		B.Warning("CBW_Battle.PriorityFunction['"..name.."'] is already defined!")
	return nil end
	if not(func) then //Invalid function argument
		B.Warning("Invalid argument #2 provided for CBW_Battle.AddPriorityFunction()")
	return nil end
	if not(type(func) == "function") then //argument type is not a function
		B.Warning("Argument #2 for CBW_Battle.AddPriorityFunction() must be a function!")
	return nil end
	PFunc[name] = func
	return name
end

local Add = B.AddPriorityFunction

Add("tails_fly",B.SPriority_Fly)
Add("knuckles_glide",B.SPriority_Glide)
Add("amy_twinspin",B.SPriority_TwinSpin)
Add("amy_melee",B.SPriority_Melee)
Add("fang_tailbounce",B.SPriority_TailBounce)
Add("stomp_damage",B.SPriority_StompDamage)
Add("can_damage",B.SPriority_CanDamage)