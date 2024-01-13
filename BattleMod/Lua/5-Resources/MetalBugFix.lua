addHook("PlayerThink",function(p)
	if p.mo and p.mo.valid then
		if p.mo.skin == "metalknuckles" or p.mo.skin == "maimy" or p.mo.skin == "metalsonic" then
			if p.actionstate then
				p.powers[pw_strong] = $&~STR_METAL
			end
		end
	end
end,MT_PLAYER) --a more general check would be useful in case we get dashmodes that aren't these 3 
			   --but i'll worry about it later