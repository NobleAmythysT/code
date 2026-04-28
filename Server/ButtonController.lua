local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local configurePlayer = require(ReplicatedStorage:FindFirstChild("configurePlayer"))
local getTemplate = require(ServerScriptService:WaitForChild("getTemplate"))
local spawnPurchased = require(ServerScriptService:WaitForChild("spawnPurchased"))
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local debounce = {}

local function remove(button: Model)
	if button then
		if debounce[button] then
			debounce[button] = nil
		end
		button:Destroy()
		button = nil
	end
	print("button removed")
end

local function setupButton(button: Model)
	--step 1: check if the button's location and structure is correct(via the parents, childrens, self attributes)
	local ButtonFolder = button.Parent
	if not ButtonFolder then return end
	
	local Tycoon = ButtonFolder.Parent
	if not Tycoon then return end
	
	local ModelsFolder = Tycoon:FindFirstChild("models")
	if not ModelsFolder then return end
	
	local hitbox = button:FindFirstChild("button") :: BasePart
	if not hitbox then return end
	
	local PurchaseObject = button:GetAttribute("PurchaseObject")
	local Price = button:GetAttribute("Price")
	local Dependency = button:GetAttribute("Dependency")
	if not PurchaseObject or not Price then return end
	
	--step 2: check if button is already purchased or not
	
	--step 3: after verifying, now you can do the touched connect
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

		if OwnerUserID ~= player.UserId then
			print("You are not the owner!")
			return
		end

		--check mony
		local money = PlayerDataService:Get(player, "Money")

		if money < Price then
			print("You don't have enough money!")
			return
		end

		--check can thou find the models to copy
		spawnPurchased.AddModel(Tycoon, PurchaseObject)
		spawnPurchased.AddButton(Tycoon, PurchaseObject)

		--after checking button's attributes and model's availability, deduct money
		--money.Value = money.Value - Price
		local PlayerData = PlayerDataService:GetData(player)
		local purchased = false
		for i, _ in PlayerData.Tycoon.Unlocked do
			if i == PurchaseObject then
				purchased = true
				break
			end
		end
		if not purchased then
			PlayerDataService:Update(player, "Money", function(currentMoney)
				return currentMoney - Price
			end)
		end
		PlayerDataService:Update(player, "Tycoon", function(tycoonUnlocks)
			if not tycoonUnlocks.Unlocked[PurchaseObject] then
				tycoonUnlocks.Unlocked[PurchaseObject] = true
			end
			return tycoonUnlocks
		end)
		print("you win")
		remove(button)
	end)
end

local function removeButton(button: Model)
	remove(button)
end

for _, button in CollectionService:GetTagged("TycoonButton") do
	setupButton(button)
end
CollectionService:GetInstanceAddedSignal("TycoonButton"):Connect(setupButton)
CollectionService:GetInstanceRemovedSignal("TycoonButton"):Connect(removeButton)