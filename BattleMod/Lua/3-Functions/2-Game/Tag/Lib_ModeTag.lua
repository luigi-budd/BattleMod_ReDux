local B = CBW_Battle

B.HideTime = function()
	if (server) then
		if G_TagGametype() and gametype != GT_BATTLETAG then
			COM_BufInsertText(server,"hidetime 30")
		else
			COM_BufInsertText(server,"hidetime 15")
		end
	end
end

B.TagCam = function(player, runner)
	if gamestate ~= GS_LEVEL then return end
	if (runner and runner.valid)
		if G_TagGametype()
		and not (runner.pflags&PF_TAGIT)
			return false
		end
	end
end

//attempt to override vanilla tag pre-round to allow taggers to select-
//characters (and also assign taggers based on lobby size)
B.TagPreRound = 0
B.TagPreTimer = 0

B.TagStart = function(player)
	if not B.TagGametype()
		return
	end
	
	if B.PreRoundWait()
		for player in players.iterate do
			if player.mo != nil and player.mo.valid
				player.pflags = $ & ~PF_TAGIT
			end
		end
		B.TagPreRound = 0
	elseif B.TagPreRound == 0
		local i = 0
		local maxtaggers = 1//figure out how to calculate how many players there are in the game
		while i < maxtaggers
			local luckyplayer = players[P_RandomKey(32)]
			if luckyplayer != nil and luckyplayer.valid and luckyplayer.mo != 
					nil and luckyplayer.mo.valid and not (luckyplayer.pflags &
					PF_TAGIT)
				luckyplayer.pflags = $ | PF_TAGIT
				i = $ + 1
			end
		end
		B.TagPreRound = 1
		B.TagPreTimer = 10 * TICRATE
	elseif B.TagPreRound == 1
		for player in players.iterate do
			if player.pflags & PF_TAGIT
				player.pflags = $ | PF_FULLSTASIS
			end
		end
		if B.TagPreTimer > 0
			B.TagPreTimer = $ - 1
		else
			B.TagPreRound = 2
		end
	end
end

//ensure taggers that are tumbled or in pain can't deal damage to runners
local function ValidPlayer(mo, isit)
	local isvalid = mo != nil and mo.valid and mo.player != nil and 
			mo.player.valid
	if isit
		isvalid = $ and mo.player.pflags & PF_TAGIT
	end
	return isvalid
end

B.TagDamageControl = function(target, inflictor)
	if not B.TagGametype()
		return
	end
	
	local runner
	local tagger
	if ValidPlayer(target)
		runner = target.player
	end
	if inflictor != nil and inflictor.valid and inflictor.player != nil
			and inflictor.player.valid and inflictor.player.pflags & PF_TAGIT
		tagger = inflictor.player
	elseif source != nil and source.valid and source.player != nil and
			source.player.valid and source.player.pflags & PF_TAGIT
		tagger = source.player
	end
	if tagger != nil and (P_PlayerInPain(tagger) or tagger.tumble)
		return false
	end
	return true
end