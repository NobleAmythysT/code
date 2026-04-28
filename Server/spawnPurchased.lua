local getTemplate = require(game:GetService("ServerScriptService"):WaitForChild("getTemplate"))

local Blacklists = {}

local spawnPurchased = {}

function spawnPurchased.Init(Tycoon: Folder)
	if not Blacklists[Tycoon] then
		Blacklists[Tycoon] = {}
	end
end

function spawnPurchased.Reset(Tycoon: Folder)
	if Blacklists[Tycoon] then
		Blacklists[Tycoon] = nil
	end
end

function spawnPurchased.AddModel(Tycoon: Folder, id)
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

--this checks the purchase object
function spawnPurchased.AddButton(Tycoon: Folder, id)
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")

	for _, v in templateButtonsFolder:GetChildren() do
		if v:GetAttribute("Dependency") == id then
			local PurchaseObject = v:GetAttribute("PurchaseObject")
			local Price = v:GetAttribute("Price")
			local Dependency = v:GetAttribute("Dependency")

			if not PurchaseObject or not Price then
				warn("button of "..id.." has missing attributes")
				continue
			end
			
			local buttonsFolder = Tycoon:FindFirstChild("buttons")
			for _, v1 in buttonsFolder:GetChildren() do
				if v1:GetAttribute("Dependency") == id then
					local PurchaseObject = v1:GetAttribute("PurchaseObject") or "nil"
					local Dependency = v1:GetAttribute("Dependency") or "nil"
					print(string.format("Button already exist || PurchaseObject: %s, Dependency: %s", PurchaseObject, Dependency))
					continue
				end
			end
			
			local base = Tycoon:FindFirstChild("base")
			local clone = v:Clone() :: Model
			clone.Parent = buttonsFolder
			local objectSpace = templateBase.CFrame:ToObjectSpace(v:GetPivot())
			clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
			continue
		end
	end
end

--this checks the purchase object
function spawnPurchased.RemoveButton(Tycoon: Folder, id)
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")
	
	local buttonsFolder = Tycoon:FindFirstChild("buttons")

	for _, v in buttonsFolder:GetChildren() do
		if v:GetAttribute("PurchaseObject") == id then
			print(v.Name.." is destroyed.")
			v:Destroy()
			v = nil
			continue
		end
	end
end

--this will add all buttons not within tycoon's blacklist
--will need to use .GetButtonMatchingPurchaseObject() before this function
function spawnPurchased.AddAllButtons(Tycoon: Folder)
	print(Blacklists[Tycoon])
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")

	for _, v in templateButtonsFolder:GetChildren() do
		local PurchaseObject = v:GetAttribute("PurchaseObject")
		local Price = v:GetAttribute("Price")
		local Dependency = v:GetAttribute("Dependency")

		if not PurchaseObject or not Price then	continue end
		
		if table.find(Blacklists[Tycoon], v.Name) then continue end

		local buttonsFolder = Tycoon:FindFirstChild("buttons")
		local base = Tycoon:FindFirstChild("base")
		local clone = v:Clone() :: Model
		clone.Parent = buttonsFolder
		local objectSpace = templateBase.CFrame:ToObjectSpace(v:GetPivot())
		clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
	end
end

--this will remove all buttons accumulated in the tycoon's blacklist
--will need to use .GetButtonMatchingPurchaseObject() before this function
function spawnPurchased.RemoveAllButtons(Tycoon: Folder)
	local buttonsFolder = Tycoon:FindFirstChild("buttons")

	for _, v in buttonsFolder:GetChildren() do
		if table.find(Blacklists[Tycoon], v.Name) then
			v:Destroy()
			v = nil
		end
	end
end

--Find any buttons in the template that its PurchaseObject matches the given id, returns the found table
function spawnPurchased.GetButtonMatchingPurchaseObject(Tycoon: Folder, id)
	local tablee = {}
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")

	local buttonsFolder = Tycoon:FindFirstChild("buttons")

	for _, v in buttonsFolder:GetChildren() do
		if v:GetAttribute("PurchaseObject") == id then
			table.insert(tablee, v)
			if not table.find(Blacklists[Tycoon], v.Name) then
				table.insert(Blacklists[Tycoon], v.Name)
			end
		end
	end	
	return tablee
end

--Find any buttons in the template that its Dependency matches the given id, returns the found table
function spawnPurchased.GetButtonMatchingDependency(Tycoon: Folder, id)
	local tablee = {}
	local template = getTemplate.Full()
	local templateButtonsFolder = template:FindFirstChild("buttons")
	local templateBase = template:FindFirstChild("base")
	
	for _, v in templateButtonsFolder:GetChildren() do
		if v:GetAttribute("Dependency") == id then
			local PurchaseObject = v:GetAttribute("PurchaseObject")
			local Price = v:GetAttribute("Price")
			local Dependency = v:GetAttribute("Dependency")

			if not PurchaseObject or not Price then
				warn("button of "..id.." has missing attributes")
				continue
			end

			table.insert(tablee, v)
		end
	end
	return tablee
end

return spawnPurchased