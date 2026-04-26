--search for character and humanoid and player and wala
--IT MUST BE HITPART THO for example your limbs
return function(hit: BasePart): Player?
	local character = hit.Parent :: Model
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
	if not humanoid then return end

	local player = game.Players:GetPlayerFromCharacter(character) :: Player
	if not player then return end

	return player
end