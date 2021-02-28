local B = CBW_Battle

addHook("HurtMsg",function(player,inflictor,source)
	if not(inflictor and inflictor.player) then return end
	local attacktext = inflictor.player.battle_hurttxt
	if attacktext then print(B.CustomHurtMessage(player,inflictor,attacktext)) return true end
end,MT_PLAYER)

addHook("HurtMsg",function(player,inflictor,source) 
	if not(inflictor and inflictor.valid and inflictor.info.name) then return end
	if inflictor.type == MT_PLAYER then return end
	print(B.CustomHurtMessage(player,source,inflictor.info.name))
	return true
 end,NULL)