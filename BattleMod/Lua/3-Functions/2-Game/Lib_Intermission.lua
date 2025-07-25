local B = CBW_Battle

B.Intermission = function()
	//Get results from training with Tails Doll
	B.TrainingResults()
	//Reset round stats
	B.PinchTics = 0
	B.Pinch = false
	B.MatchPoint = false
	B.Overtime = false
	B.SuddenDeath = false
	B.Exiting = false
	B.Arena.SpawnLives = 3
	for player in players.iterate
		player.win = nil
		player.loss = nil
		if player.revenge then
			player.revenge = false
			player.lives = 3
		end
	end
end