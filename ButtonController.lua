local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local configurePlayer = require(ReplicatedStorage:FindFirstChild("configurePlayer"))
local debounce = {}

local templateTycoon = game.Workspace:WaitForChild("template")

local function setupButton(button: Model)
	--check if the button's location and structure is correct(via the parents and childrens)
	local ButtonFolder = button.Parent
	if not ButtonFolder then return end
	
	local Tycoon = ButtonFolder.Parent
	if not Tycoon then return end
	
	local ModelsFolder = Tycoon:FindFirstChild("models")
	if not ModelsFolder then return end
	
	local hitbox = button:FindFirstChild("button") :: BasePart
	if not hitbox then return end
	
	hitbox.Touched:Connect(function(hit)
		if debounce[hitbox] then return end
		debounce[hitbox] = true
		task.delay(0.5, function()
			debounce[hitbox] = nil
		end)

		--check the player's existence and his ownership of the tycoon
		local player = configurePlayer(hit)
		if not player then return end
		
		local OwnerUserID = Tycoon:GetAttribute("OwnerUserID")
		if not OwnerUserID then return end

		--local door = Tycoon:FindFirstChild("door")
		--if not door or not door:HasTag("TycoonDoor") then return end

		--if not OwnerUserID then
		--	warn("Missing owner of tycoon")
		--	return
		--end
		
		if OwnerUserID ~= player.UserId then
			print("You are not the owner!")
			return
		end
		
		--print("Buy!")
		--check the button's other attributes
		local PurchaseObject = button:GetAttribute("PurchaseObject")
		local Price = button:GetAttribute("Price")
		local Dependency = button:GetAttribute("Dependency")
		if not PurchaseObject or not Price then return end

		--check mony
		local leaderstats = player:FindFirstChild("leaderstats")
		local money = leaderstats:FindFirstChild("Money")
		
		if not money then
			print("you dont even have money wow")
			return
		end
		
		if money.Value < Price then
			print("You don't have enough money!")
			return
		end

		--check can thou find the models to copy
		local templateModelsFolder = templateTycoon:FindFirstChild("models")
		local templateButtonsFolder = templateTycoon:FindFirstChild("buttons")
		local templateBase = templateTycoon:FindFirstChild("base")
		
		local model
		for _, v in templateModelsFolder:GetChildren() do
			if not v or v.Name ~= PurchaseObject then continue end
			model = v:Clone() :: Model
			model.Parent = ModelsFolder
			local objectSpace = templateBase.CFrame:ToObjectSpace(v:GetPivot())
			model:PivotTo(Tycoon:FindFirstChild("base").CFrame:ToWorldSpace(objectSpace))
		end
		if not model then
			warn("THE MODEL DOES NOT EXIST")
			return
		end
		
		--after checking button's attributes and model's availability, deduct money
		money.Value = money.Value - Price
		print("you win")
		button:Destroy()
		button = nil
		
		--make new button
		for _, v in templateButtonsFolder:GetChildren() do
			if v:GetAttribute("Dependency") == PurchaseObject then
				local clone = v:Clone() :: Model
				clone.Parent = ButtonFolder
				local objectSpace = templateBase.CFrame:ToObjectSpace(v:GetPivot())
				clone:PivotTo(Tycoon:FindFirstChild("base").CFrame:ToWorldSpace(objectSpace))
			end
		end
	end)
end

function removeButton(button: Model)
	if button then
		button:Destroy()
		button = nil
	end
	print("removed")
end

for _, button in CollectionService:GetTagged("TycoonButton") do
	setupButton(button)
end
CollectionService:GetInstanceAddedSignal("TycoonButton"):Connect(setupButton)
CollectionService:GetInstanceRemovedSignal("TycoonButton"):Connect(removeButton)