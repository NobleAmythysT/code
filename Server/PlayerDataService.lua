--[[(examples will have the prefix of "(EX)")
	lets say the player is Dued1, he just joined the server
	he wants his data to be loaded
]]

local Players = game:GetService("Players")
local ProfileService = require(script:WaitForChild("ProfileService"))

local dataTemplate = {
	Money = 0,
	Rebirths = 0,
	Tycoon = {
		Unlocked = {},
	}
}

--so you get the database, this profile store is called the PlayerProfile
--equivalent of :GetDataStore() of the roblox's DataStoreService
local ProfileStore = ProfileService.GetProfileStore("PlayerProfile", dataTemplate)

local Profiles = {}

local function playerAdded(player: Player)
	--[[get the data, or the profile of the datastore, with the input key
		(EX) retrieves Dued1's profile in the PlayerProfile database, the key will be "Player" concatenated with his UserId
	]]
	local profile = ProfileStore:LoadProfileAsync("Player"..player.UserId)
	
	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)
		
		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			--print(Profiles[player].Data)
		else
			profile:Release()
		end
	else
		player:Kick("Couldn't load data")
	end
end

local DataHandler = {}


--initialize
function DataHandler:Init()
	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end
	
	Players.PlayerAdded:Connect(playerAdded)
	
	Players.PlayerRemoving:Connect(function(player: Player)
		if Profiles[player] then
			Profiles[player]:Release()
		end
	end)
end

--[[just so you want a fancier name
works the same as DataHandler:Init()]]
function DataHandler:Initialize()
	self:Init()
end

--you get the player's profile
local function getProfile(player: Player)
	--if not Profiles[player] then
	--	error("cant find player's data, UserID: "..player.UserId)
	--	return nil
	--end
	--assert(Profiles[player], "cant find player's data, UserID: "..player.UserId)
	while not Profiles[player] do
		task.wait()
	end
	return Profiles[player]	
end

--[[just to get the entire data of the player whatsoever
	so we dont have to get the player's data multiple times when we just want to get
]]
function DataHandler:GetData(player: Player)	
	local profile = getProfile(player)
	return profile.Data
end

--[[the script gets a specific value of a player's profile by inputting the player and the key(name of the value)
	(EX) a certain script wants to get Dued1's money value, so the script will do :Get(player, "Money"), where player is Dued1
]]
function DataHandler:Get(player: Player, key)
	--(EX) Dued1's profile is retrieved, inside there are money, rebirths, and other things
	local profile = getProfile(player)
	
	--(EX) profile.Data[Money], in this case we found the money! and uhh
	if profile.Data[key] == nil then
		warn("the key "..key.." is missing for "..player.Name.."'s data")
		return nil
	end
	
	--(EX) yeah just return back Dued1's money amount
	return profile.Data[key]
end

--[[the script sets a specific value of a player's profile by inputting the player, the key, and the value
	BE WARNED THAT YOU COULD OVERRIDE THE KEY & VALUE PAIR
	(EX) Dued1 just rebirthed, sadly, that means he will lose all his coins!
	a ceratin script will do :Set(player, "Money", 0), where player is Dued1
]]
function DataHandler:Set(player: Player, key, value)
	--(EX) Dued1's profile is retrieved, inside there are money, rebirths, and other things
	local profile = getProfile(player)

	--(EX) profile.Data[Money], in this case we found the money! and uhh... same as above
	if profile.Data[key] == nil then
		warn("the key "..key.." is missing for "..player.Name.."'s data")
		return nil
	end
	
	--(EX) the money's type has to be number to work! otherwise it will cause bugs and wdym he has Apple amount of money
	if type(profile.Data[key]) ~= type(value) then
		warn("the value type for "..key.." is wrong! (it needs to be "..type(profile.Data[key])..")")
		return nil
	end

	--(EX) sets Dued1's money to 0 QQ
	profile.Data[key] = value
end

--[[the script changes a specific value of a player's profile by inputting the player, the key, and the callback
	callback is a function that will uh do stuff
	(EX) Dued1 just collected a COIN!!! he now has 1 more monies! now just 999999 more to go.
	a ceratin script will do :Update(player, "Money", function(v) return v + 1 end), where player is Dued1
]]
function DataHandler:Update(player: Player, key, callback)
	--(EX) Dued1's profile is retrieved, inside there are money, rebirths, and other things
	local profile = getProfile(player)
	
	--(EX) this will get Dued1's current money value and now it needs to plus 1
	local lastData = self:Get(player, key)
	
	--[[since different keys will have their different ways of functioning, it cant be just self value plus 1
		it could be changing a string, flipping a boolean, collecting an item, modify a CFrame value... and so on
		and since this is very versatile, the third input will be a function (i believe thats the explanation)
		(EX) Dued1's new money value will be his current money value +1, and how to do that? by this:
		function(money)
			return money + 1
		end
	]]
	local newData = callback(lastData)
	
	--the update function is essentially just the set method but utilizing the last value
	--(EX) congrats to Dued1 now has has 1 extra money!
	self:Set(player, key, newData)
end

return DataHandler
