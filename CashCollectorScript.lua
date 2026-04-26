local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local configurePlayer = require(game.ReplicatedStorage.configurePlayer)
--local OwnerUserID

function setupCashCollector(model: Model)
	local Tycoon = model.Parent.Parent
	if not Tycoon then return end

	--OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
	--if not OwnerUserID then return end

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
	
	CashCollectPart.Touched:Connect(function(hit: BasePart)
		local player = configurePlayer(hit)
		if not player then return end
		
		--if not OwnerUserID then
		--	OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		--end
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		if not OwnerUserID or player.UserId ~= OwnerUserID then return end
		
		player:FindFirstChild("leaderstats"):FindFirstChild("Money").Value += CashMonitor:GetAttribute("AccumulatedCash")
		CashMonitor:SetAttribute("AccumulatedCash", 0)
		--print(TotalCash)
	end)
end

function removeCashCollector(model: Model)
	if model then
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