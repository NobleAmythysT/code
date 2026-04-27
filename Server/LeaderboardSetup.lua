local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

PlayerDataService:Init()

local function leaderboardSetup(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Parent = leaderstats
	
	task.spawn(function()
		local data
		repeat
			data = PlayerDataService:GetData(player)
			task.wait()
		until data
		
		money.Value = data.Money

		while player.Parent do
			money.Value = data.Money
			task.wait(0.5)
		end
	end)
end

Players.PlayerAdded:Connect(leaderboardSetup)