local CollectionService = game:GetService("CollectionService")
local UpgradedCash = {}

function setupUpgrader(upgrader: Model)
	local Tycoon = upgrader.Parent.Parent
	if not Tycoon then return end
	
	local UpgraderPart = upgrader:FindFirstChild("UpgraderPart") :: BasePart
	if not UpgraderPart then return end
	
	UpgradedCash[upgrader] = {}
	UpgraderPart.Touched:Connect(function(hit: BasePart)
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		if not OwnerUserID then return end
		
		if UpgradedCash[upgrader][hit] then return end
		
		if not hit:HasTag("Cash") then return end

		local CashAmount = hit:GetAttribute("CashAmount")
		local CashOwnerUserID = hit:GetAttribute("OwnerUserID")
		if not CashAmount or not CashOwnerUserID then return end
		
		if CashOwnerUserID ~= OwnerUserID then return end
		
		local Multiplier = UpgraderPart:GetAttribute("Multiplier") or 1.15

		local newAmount = hit:GetAttribute("CashAmount") * Multiplier
		hit:SetAttribute("CashAmount", newAmount)
		
		UpgradedCash[upgrader][hit] = true
		hit:FindFirstChild("BillboardGui"):FindFirstChild("TextLabel").Text = "$"..math.round(newAmount*100)/100
		task.delay(30, function()
			if UpgradedCash[upgrader] and UpgradedCash[upgrader][hit] then
				UpgradedCash[upgrader][hit] = nil
			end
		end)
	end)
end

function removeUpgrader(upgrader: Model)
	if upgrader then
		UpgradedCash[upgrader] = nil
		upgrader:Destroy()
		upgrader = nil
	end
	print("upgrader is removed")
end

for _, button in CollectionService:GetTagged("Upgrader") do
	setupUpgrader(button)
end
CollectionService:GetInstanceAddedSignal("Upgrader"):Connect(setupUpgrader)
CollectionService:GetInstanceRemovedSignal("Upgrader"):Connect(removeUpgrader)