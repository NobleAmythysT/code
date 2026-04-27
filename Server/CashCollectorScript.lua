local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local configurePlayer = require(game.ReplicatedStorage.configurePlayer)
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local collectMoney = ReplicatedStorage.collectMoney :: RemoteEvent
local debounce = {}

function setupCashCollector(model: Model)
	local Tycoon = model.Parent.Parent
	if not Tycoon then return end

	local CashMonitor = model.Parent:FindFirstChild("CashMonitor") :: Model
	if not CashMonitor then return end
	
	local TotalCash = CashMonitor:GetAttribute("AccumulatedCash")
	if not TotalCash then return end

	local CashCollectPart = model:FindFirstChild("CashCollect") :: BasePart
	if not CashCollectPart then return end

	local CashDisplay = CashMonitor:FindFirstChild("CashDisplay")
	local CashText = CashDisplay:FindFirstChildOfClass("SurfaceGui"):FindFirstChild("CashText") :: TextLabel
	if CashText then
		CashText.Text = "Cash: $"..TotalCash
	end
	
	CashMonitor:GetAttributeChangedSignal("AccumulatedCash"):Connect(function()
		TotalCash = CashMonitor:GetAttribute("AccumulatedCash")
		if CashText then
			CashText.Text = "Cash: $"..TotalCash
		end
	end)
	
	debounce[model] = {}
	CashCollectPart.Touched:Connect(function(hit: BasePart)		
		local player = configurePlayer(hit)
		if not player then return end
		
		if debounce[model][player] then return end
		debounce[model][player] = true
		task.delay(1, function()
			debounce[model][player] = nil
		end)
		
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		if not OwnerUserID then return end 
		
		if player.UserId ~= OwnerUserID then
			collectMoney:FireClient(player, model, false)
			return
		end
		
		PlayerDataService:Update(player, "Money", function(currentMoney)
			return currentMoney + CashMonitor:GetAttribute("AccumulatedCash")
		end)
		collectMoney:FireClient(player, model, true)
		CashMonitor:SetAttribute("AccumulatedCash", 0)
	end)
end

function removeCashCollector(model: Model)
	if model then
		if debounce[model] then
			debounce[model] = nil
		end
		model:Destroy()
		model = nil
	end
	print("cash collector is removed")
end

for _, button in CollectionService:GetTagged("CashCollector") do
	setupCashCollector(button)
end
CollectionService:GetInstanceAddedSignal("CashCollector"):Connect(setupCashCollector)
CollectionService:GetInstanceRemovedSignal("CashCollector"):Connect(removeCashCollector)