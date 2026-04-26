local CollectionService = game:GetService("CollectionService")
local CashObject = require(game.ServerScriptService:WaitForChild("Cash"))

function setupPartCollector(model: Model)
	local Tycoon = model.Parent.Parent
	if not Tycoon then return end
	
	local CashMonitor = model.Parent:FindFirstChild("CashMonitor") :: Model
	if not CashMonitor then return end
	
	local AccumulatedCash = CashMonitor:GetAttribute("AccumulatedCash")
	if not AccumulatedCash then return end
	
	local sellBlock = model:FindFirstChild("sellblock") :: BasePart
	if not sellBlock then return end
	
	sellBlock.Touched:Connect(function(hit: BasePart)
		--since this one is default to exist, check id in touched not via outside
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID") :: NumberValue
		if not OwnerUserID then return end
		
		if not hit:HasTag("Cash") then return end

		if not hit:GetAttribute("CashAmount") or not hit:GetAttribute("OwnerUserID") then return end

		local newCash = CashMonitor:GetAttribute("AccumulatedCash") + hit:GetAttribute("CashAmount")
		CashMonitor:SetAttribute("AccumulatedCash", newCash)

		local Cash = CashObject:GetCashFromPart(hit)
		if Cash then
			Cash:Destroy()
		else
			hit:Destroy()
			hit = nil
		end
	end)
end

function removePartCollector(model: Model)
	if model then
		model:Destroy()
		model = nil
	end
	print("ok now how do we turn those damn parts into monies")
end

for _, button in CollectionService:GetTagged("PartCollector") do
	setupPartCollector(button)
end
CollectionService:GetInstanceAddedSignal("PartCollector"):Connect(setupPartCollector)
CollectionService:GetInstanceRemovedSignal("PartCollector"):Connect(removePartCollector)