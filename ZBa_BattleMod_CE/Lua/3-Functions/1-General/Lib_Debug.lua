local B = CBW_Battle
local CV = B.Console
local CP = B.ControlPoint
local I = B.Item
local A = B.Arena
local D = B.Diamond

B.DebugPrint = function(string,flags)
	local debug = CV.Debug.value
	//Gates
	if not(debug) then return end
	if flags and not(debug&flags) then return end
	//Colors
	local c = "\x8C"
	if flags then
		c = "\x8A"
		if flags == 1 c = "\x8E" end
		if flags == 2 c = "\x8B" end
		if flags == 4 c = "\x8D" end
		if flags == 8 c = "\x87" end
	end
	//Print
	print(c..tostring(string))
end

B.Warning = function(string)
	print("\x82".."WARNING:"..tostring(string))
end
