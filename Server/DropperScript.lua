local CollectionService = game:GetService("CollectionService")
local CashObject = require(game.ServerScriptService:WaitForChild("Cash"))

function setupDropper(dropper: Model)
	local Tycoon = dropper.Parent.Parent
	if not Tycoon then return end
	
	local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
	if not OwnerUserID then return end
	
	local Spawner = dropper:FindFirstChild("Spawner") :: BasePart
	if not Spawner then return end
	
	local amount = Spawner:GetAttribute("SpawnCash") or 50
	local duration = Spawner:GetAttribute("SpawnTime") or 2
	
	task.spawn(function()
		while task.wait(duration) do
			local Cash = CashObject.New(duration, amount, Spawner, Tycoon, OwnerUserID)
			Cash:Spawn()
		end
	end)
end

function removeDropper(dropper: Model)
	if dropper then
		dropper:Destroy()
		dropper = nil
	end
	print("dropper is removed")
end

for _, button in CollectionService:GetTagged("Dropper") do
	setupDropper(button)
end
CollectionService:GetInstanceAddedSignal("Dropper"):Connect(setupDropper)
CollectionService:GetInstanceRemovedSignal("Dropper"):Connect(removeDropper)