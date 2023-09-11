-- (original from XSabe & trb)
-- corpses <on/off>: Determines whether corpses should be turned on or off
-- Some characters use OOF_ for their SHIT frames instead, idk how to check for both
freeslot(
	"SPR2_SHIT",
	"S_PLAY_FACEPLANT",
	"SPR2_OOF_"
)

spr2defaults[SPR2_OOF_] = SPR2_SHIT
spr2defaults[SPR2_SHIT] = SPR2_PAIN

CV_RegisterVar({
    name = "corpses",
    defaultvalue = 1,
    flags = CV_NETVAR,
    PossibleValue = CV_OnOff
})

-- MobjDeath: Used to determine what to do once the player dies
addHook("MobjDeath", function(target, inflictor, source, damagetype)
	if not (target or target.valid or inflictor or inflictor.valid) or CV_FindVar("corpses").value == 0 then return end
	local sign = not(leveltime%2) and 1 or -1
	local rng_ang = FixedAngle(P_RandomRange(-50, 50)*FRACUNIT)
	local direction = target.player.drawangle - ANGLE_90 + rng_ang
	-- No inflictor, use player based values
	if inflictor == nil and source == nil then
		-- TODO: check for damagetypes here? (e.g. if damagetype is electric, fire, crushed, etc)
		target.rng_ang = direction
		target.h_impact = (target.momx/FRACUNIT+target.momy/FRACUNIT)+(P_RandomRange(15,20))
		target.v_impact = (target.momz)+P_RandomRange(15,20)*FRACUNIT
		target.impact_speed = target.player.speed*sign
	else
		local infl_mass = inflictor.info.mass
		local infl_speed = inflictor.momx+inflictor.momy

		-- Determine horizontal and vertical impacts
		-- (vel * mass)? with some randomness thrown in
		target.rng_ang = direction
		-- the mess
		target.h_impact = (target.momx/FRACUNIT+target.momy/FRACUNIT)--+inflictor.momx/FRACUNIT+inflictor.momy/FRACUNIT)
		target.v_impact = (inflictor.momz+target.momz)*infl_mass+(P_RandomRange(11, 17)*FRACUNIT)
		target.impact_speed = (target.player.speed + infl_speed)*sign
	end
	target.deathimpact = 1
end, MT_PLAYER)

-- All the important code happens here, which checks for pla
addHook("PlayerThink", function(p)
	if p and p.valid and p.mo and p.mo.valid then		
		local mo = p.mo

		-- Code that runs always -- check if player is in a death state.
		if mo.deathimpact == 1 then
			-- Setting fuse time to be large, enough until we land somewhere (where we will generate another mobj)
			mo.fuse = FRACUNIT --
			-- TODO: bounce off walls
			--target.flags = $|MF_SOLID|MF_BOUNCE

			-- Initial impact: Horizontally and vertically	
			local v_impact = mo.v_impact
			P_SetObjectMomZ(mo, v_impact, false)
			--P_InstaThrust(mo, rng_ang, h_impact)

			-- Prevent player from clipping through floor
			mo.flags = $ & ~MF_NOCLIPHEIGHT

			-- Launching corpse is done
			mo.deathimpact = 2

		-- Post-launch checks
		elseif mo.deathimpact == 2 then
			if P_IsObjectOnGround(mo) then
				-- If in pit, reset vars and return (no corpse)
				if P_CheckDeathPitCollide(mo) then
					mo.deathimpact = nil
					mo.fuse = 0
					return
				end
				-- Now we put a replica in our place
				local corpse = P_SpawnGhostMobj(mo)--P_SpawnMobjFromMobj(mo, 0,0,0, MT_THOK)
				corpse.from_player = true
				corpse.fuse = 550--P_RandomRange(450, 550) -- hefty fusetime
				corpse.rollangle = 0
				corpse.color = mo.color
				corpse.state = S_PLAY_FACEPLANT
				corpse.shadowscale = mo.shadowscale
				S_StartSound(mo, sfx_s3k5d)
				P_InstaThrust(mo, 0, 0)
				mo.deathimpact = nil -- Set conditions off
				mo.fuse = 0 -- Poof, we are gone
			end
		end

		-- Rotating the corpse
		if (p.playerstate == PST_DEAD) and mo.deathimpact == 2 then
			local direction = mo.rng_ang
			local h_impact = mo.h_impact
			local speed = mo.impact_speed

			mo.momy = -h_impact * cos(direction)  
			mo.momx = h_impact * sin(direction)
			mo.rollangle = $ - FixedAngle(speed)
			--[[
			if P_IsObjectOnGround(mo) then
				if P_CheckDeathPitCollide(mo) then
					P_InstaThrust(mo,mo.angle, 0)
					p.mo.flags = $ & ~MF_NOCLIPHEIGHT
					p.mo.rollangle = InvAngle(0*FRACUNIT) 
				end		
			end
			--]]
		end
	end
end)
