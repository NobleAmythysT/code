local getTemplate = require(game:GetService("ServerScriptService"):WaitForChild("getTemplate"))

local spawnPurchased = {}

function spawnPurchased.Model(Tycoon: Model, id)
	local template = getTemplate.Full()
	local templateModelsFolder = template:FindFirstChild("models")
	local templateBase = template:FindFirstChild("base")

	local model = templateModelsFolder:FindFirstChild(id)
	if not model then
		warn("model of "..id.." not found")
		return
	end

	local modelsFolder = Tycoon:FindFirstChild("models")
	if modelsFolder:FindFirstChild(id) then
		print("model of "..id.." already exist")
		return
	end
	local base = Tycoon:FindFirstChild("base")

	local clone = model:Clone() :: Model
	clone.Parent = modelsFolder
	local objectSpace = templateBase.CFrame:ToObjectSpace(model:GetPivot())
	clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
end

function spawnPurchased.Button(Tycoon: Model, id)
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")

	--check purchase object first then check dependency
	--if there is purchase id, then the button shouldnt exist
	--but after that check, if the dependency id matches, then it should exist, or be created if theres none
	--but there's no matching id, then leave it as it is, begoned
	--local button
	for _, v in templateButtonsFolder:GetChildren() do
		--if v:GetAttribute("PurchaseObject") then
		--	print("target: "..id.." // current id: ".. v:GetAttribute("PurchaseObject"))
		--end
		if v:GetAttribute("PurchaseObject") == id then
			--print(id.." // aa1")
			--button = v
			local buttonsFolder = Tycoon:FindFirstChild("buttons")
			for _, v1 in buttonsFolder:GetChildren() do
				if v1:GetAttribute("PurchaseObject") == id then
					print("button with purchase id "..id.." is deleted")
					v1:Destroy()
					v1 = nil
					return
				end
			end
			break
		end
	end
	
	for _, v in templateButtonsFolder:GetChildren() do
		if v:GetAttribute("Dependency") == id then
			--print(id.." // bb1")
			local PurchaseObject = v:GetAttribute("PurchaseObject")
			local Price = v:GetAttribute("Price")
			local Dependency = v:GetAttribute("Dependency")

			if not PurchaseObject or not Price then
				warn("button of "..id.." has missing attributes")
				return
			end

			local buttonsFolder = Tycoon:FindFirstChild("buttons")
			for _, v1 in buttonsFolder:GetChildren() do
				if v1:GetAttribute("Dependency") == id then
					print("button with purchase id "..id.." already exist")
					return
				end
			end
			local base = Tycoon:FindFirstChild("base")

			local clone = v:Clone() :: Model
			clone.Parent = buttonsFolder
			local objectSpace = templateBase.CFrame:ToObjectSpace(v:GetPivot())
			clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
			return
		end
	end
end

return spawnPurchased