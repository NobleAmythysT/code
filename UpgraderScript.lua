local CollectionService = game:GetService("CollectionService")
--local CashObject = require(game.ServerScriptService:WaitForChild("Cash"))
local UpgradedCash = {}

function setupUpgrader(upgrader: Model)
	local Tycoon = upgrader.Parent.Parent
	if not Tycoon then return end
	
	local UpgraderPart = upgrader:FindFirstChild("UpgraderPart") :: BasePart
	if not UpgraderPart then return end
	
	UpgraderPart.Touched:Connect(function(hit: BasePart)
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		if not OwnerUserID then return end
		
		if UpgradedCash[hit] then return end
		
		if not hit:HasTag("Cash") then return end

		local CashAmount = hit:GetAttribute("CashAmount")
		local CashOwnerUserID = hit:GetAttribute("OwnerUserID")
		if not CashAmount or not CashOwnerUserID then return end
		
		if CashOwnerUserID ~= OwnerUserID then return end
		
		local Multiplier = UpgraderPart:GetAttribute("Multiplier") or 1.15

		local newAmount = hit:GetAttribute("CashAmount") * Multiplier
		hit:SetAttribute("CashAmount", newAmount)
		
		UpgradedCash[hit] = true
		hit:FindFirstChild("BillboardGui"):FindFirstChild("TextLabel").Text = "$"..math.round(newAmount*100)/100
		task.delay(30, function()
			if UpgradedCash[hit] then
				UpgradedCash[hit] = nil
			end
		end)
	end)
end

function removeUpgrader(upgrader: Model)
	if upgrader then
		upgrader:Destroy()
		upgrader = nil
		UpgradedCash = {}
	end
	print("upgrader is removed")
end

for _, button in CollectionService:GetTagged("Upgrader") do
	setupUpgrader(button)
end
CollectionService:GetInstanceAddedSignal("Upgrader"):Connect(setupUpgrader)
CollectionService:GetInstanceRemovedSignal("Upgrader"):Connect(setupUpgrader)