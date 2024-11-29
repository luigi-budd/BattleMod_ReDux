local B = CBW_Battle
local huds = {
	{id = HUD_LIVES,		x = 16,	y = 176},
	{id = HUD_RINGS,		x = 16,	y = 42},
	{id = HUD_RINGSNUM,		x = 96,	y = 42},
	{id = HUD_RINGSNUMTICS,	x = 120,y = 42},
	{id = HUD_SCORE,		x = 16,	y = 10},
	{id = HUD_SCORENUM,		x = 120,y = 10},
	{id = HUD_TIME,			x = 16,	y = 26},
	{id = HUD_MINUTES,		x = 72,	y = 26},
	{id = HUD_TIMECOLON,	x = 72,	y = 26},
	{id = HUD_SECONDS,		x = 96,	y = 26},
	{id = HUD_TIMETICCOLON,	x = 96,	y = 26},
	{id = HUD_TICS,			x = 120,y = 26}
}
local newhuds = {"New", "Minimal"}
local hide_x, hide_y = 320*32, 200*32
local toggle = false
B.ChangeHUD = function(v, player)
	local newhud = B.Console.FindVarString("battleconfig_hud", newhuds)
	if (newhud == toggle) then
		return
	end
	toggle = newhud
	if toggle then
		for i = 1, #huds do
			local hud = huds[i]
			hudinfo[hud.id].x = hide_x
			hudinfo[hud.id].y = hide_y
		end
	else
		for i = 1, #huds do
			local hud = huds[i]
			hudinfo[hud.id].x = hud.x
			hudinfo[hud.id].y = hud.y
		end
	end
end