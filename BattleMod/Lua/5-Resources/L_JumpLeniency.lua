local function PreThinkJump(player)
	P_DoJump(player, true);

	-- Prevent using abilities immediately, by removing jump inputs.
	player.cmd.buttons = $1 | BT_JUMP;
	player.pflags = $1 | PF_JUMPDOWN;
end

local function RestoreAbility(player)
	player.secondjump = 0;
	player.pflags = $1 & ~PF_THOKKED;
end

local function RemoveAbility(player)
	player.secondjump = UINT8_MAX;
	player.pflags = $1 | PF_THOKKED;
end

local function JumpLeniencyThink(player)
	if not (player.mo and player.mo.valid) then
		return;
	end
	local mo = player.mo;

	local latency = 0; -- Default to 0 for EXEs without cmd.latency.
	--[[
	pcall(function()
		latency = player.cmd.latency;
	end);
	]]
	-- Commented out to prevent unfair advantages via EXE modifications (?) Citation needed ~Lu

	-- Init variables
	if (mo.coyoteTime == nil) then
		mo.coyoteTime = 0;
	end

	if (mo.recoveryWait == nil) then
		mo.recoveryWait = 0;
	end

	if (player.exiting) then
		-- Can't control anyway, don't need to do this.
		return;
	end

	local pressedJump = false;
	if (player.cmd.buttons & BT_JUMP) and not (player.pflags & PF_JUMPDOWN) then
		pressedJump = true;
	end

	if (P_PlayerInPain(player) == true) then
		mo.coyoteTime = 0; -- Reset coyote time
		mo.recoveryWait = $1 + 1; -- Increment recovery wait time.

		-- The recovery jump from SA2, where you can jump out of your pain state.
		if (pressedJump == true) and CV_FindVar("battle_recoveryjump").value then
			local baseRecoveryWait = (2*TICRATE)/3; -- 0.667 seconds of waiting, - your latency.

			if (mo.recoveryWait > baseRecoveryWait - latency) then
				PreThinkJump(player);

				--[[
				RemoveAbility(player);

				-- Reset momentum so you can move a bit.
				player.mo.momx = 0;
				player.mo.momy = 0;
				--]]

				RestoreAbility(player);
			end
		end

		-- Don't do any of the coyote time thinking.
		return;
	end

	-- Reset recovery wait time outside of pain state.
	mo.recoveryWait = 0;

	-- "Coyote time" is how much time you have after leaving the ground where you can jump off.
	-- Many modern platformers do this, especially 3D.
	-- Prevents lots of "the jump didn't jump".
	local baseCoyoteTime = CV_FindVar("battle_coyotetime").value; -- 0.25 seconds, + your latency.

	-- Check if you're in a state where you would normally be allowed to jump.
	local canJump = false;
	if ((P_IsObjectOnGround(mo) == true) or (P_InQuicksand(mo) == true))
		and (player.powers[pw_carry] == CR_NONE)
	then
		canJump = true;
	end

	if (player.skidtime and player.powers[pw_nocontrol]) then
		mo.coyoteTime = -1;
	end

	if (mo.coyoteTime < 0) then
		-- (For mods) Don't go any further if something is preventing it
		mo.coyoteTime = $+1;
	elseif (player.pflags & PF_JUMPED)
		or (player.playerstate ~= PST_LIVE)
		or (mo.eflags & MFE_SPRUNG)
	then
		-- We jumped. We should not have coyote time.
		mo.coyoteTime = 0;
	elseif (canJump == true) then
		-- Set the coyote time while in a state where you can jump.
		mo.coyoteTime = baseCoyoteTime + latency;
	else
		if (pressedJump == true) and (mo.coyoteTime > 0) then
			-- Pressed jump in a state where you can't jump,
			-- but you have coyote time. So we'll give you a jump anyway!
			PreThinkJump(player);
			RestoreAbility(player);
			mo.coyoteTime = 0;
			if CV_FindVar("battle_coyotefactor").value<15 then
				mo.momz = $-($/CV_FindVar("battle_coyotefactor").value);
			end
		end

		if (mo.coyoteTime > 0) then
			-- Reduce coyote timer while in a state where you can't jump.
			mo.coyoteTime = $1 - 1;
		end
	end
end

addHook("PreThinkFrame", function()
	for player in players.iterate do
		JumpLeniencyThink(player);
	end
end);
