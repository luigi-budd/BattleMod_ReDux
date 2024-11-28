local B = CBW_Battle
local CV = B.Console

local POWERUPS_X = 274
local POWERUPS_Y = 180
local POWERUPS_X_OLD = 288
local POWERUPS_Y_OLD = 176

--// rev: broke it down into a table
local shields = {
	[SH_THUNDERCOIN] = "TVZPICON",
	[SH_BUBBLEWRAP] = "TVBBICON",
	[SH_FLAMEAURA] = "TVFLICON",
	[SH_ARMAGEDDON] = "TVARICON",
	[SH_ELEMENTAL] = "TVELICON",
	[SH_ATTRACT] = "TVATICON",
	[SH_WHIRLWIND] = "TVWWICON",
	[SH_PINK] = "TVPPICON"
}
local function getshield(n)
	local icon = shields[n]
	return icon 
		and icon 
		or ((n&SH_FORCE) and "TVFOICON" or "TVPIICON")
end

local function drawshield(v, player, x, y, shield, scale)
	local patch = "MPTYICON"
	local flags = V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTORIGHT|V_PERPLAYER
	local twoforce = (shield == SH_FORCE|1)
	local blink = not (not(P_PlayerInPain(player) or player.charmed) or leveltime&1)
	if shield and not blink then
		patch = getshield(shield)
	end
	local patch = v.cachePatch(patch)
	if twoforce and not blink then
		v.drawScaled(x*FRACUNIT-4*scale,y*FRACUNIT-4*scale,scale,patch,flags)
	end
	v.drawScaled(x*FRACUNIT,y*FRACUNIT,scale,patch,flags)
end

B.ShieldHUD = function(v, player, cam)
	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) then
		hudinfo[HUD_POWERUPS].x = POWERUPS_X
		hudinfo[HUD_POWERUPS].y = POWERUPS_Y
	else
		hudinfo[HUD_POWERUPS].x = POWERUPS_X_OLD
		hudinfo[HUD_POWERUPS].y = POWERUPS_Y_OLD
	end
	if not (B.HUDMain) then return end
	if player.playerstate ~= PST_LIVE then return end
	if player.spectator then return end
	if not(CV.ShieldStock.value) then return end
	if not(gametyperules&GTR_PITYSHIELD) then return end
	if not(player.shieldmax) then return end
	
	local xoffset = hudinfo[HUD_POWERUPS].x
	local yoffset = hudinfo[HUD_POWERUPS].y
	
	if CV.FindVarString("battleconfig_hud", {"New", "Minimal"}) and not(player.powers[pw_shield] or player.powers[pw_sneakers]
	or player.gotflag or player.powers[pw_flashing] or player.powers[pw_invulnerability])
	then
		drawshield(v, player, xoffset, yoffset, player.powers[pw_shield], FRACUNIT>>1)
	end
	
	--Draw shield reserves
	local n = player.shieldmax
	xoffset = $ + 8
	yoffset = $ - (10*n)
	while n > 0 do
		drawshield(v, player, xoffset, yoffset, player.shieldstock[n], FRACUNIT>>2)
		yoffset = $+10
		n = $-1
	end
end
