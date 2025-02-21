local B = CBW_Battle

B.Shuffle = function(tbl) -- Fisher-Yates algorithm
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

-- pairtype hint: ipairs preserves order while pairs prevents duplicate keys
B.Merge = function(tbl1, tbl2, pairtype)
	local tbl3 = {}
	for k, v in pairtype(tbl1) do tbl3[k] = v end
	for k, v in pairtype(tbl2) do tbl3[k] = v end
	return tbl3
end

B.FirstValidTable = function(...)
	for _, tbl in ipairs({...}) do
		if next(tbl) then
			return tbl
		end
	end
	return {}
end

B.LastValidTable = function(...)
	local tables = {...}
	for i = #tables, 1, -1 do
		if tables[i] and #tables[i] > 0 then
			return tables[i]
		end
	end
	return {}
end