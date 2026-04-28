local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local configurePlayer = require(ReplicatedStorage:FindFirstChild("configurePlayer"))
local getTemplate = require(ServerScriptService:WaitForChild("getTemplate"))
local spawnPurchased = require(ServerScriptService:WaitForChild("spawnPurchased"))
local CashObject = require(game.ServerScriptService:WaitForChild("Cash"))
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local debounce = {} --self explainatory
local tycoonClaimed = {} --stores tycoon with player as index
local tycoonOwners = {} --stores player with tycoon as index
local claimDoor = ReplicatedStorage.claimDoor :: RemoteEvent

local function displayOwnerName(door: BasePart, player: Player)
	if door:FindFirstChild("OwnerBillboard") then door.OwnerBillboard:Destroy() end
	
	local attachment = Instance.new("Attachment")
	attachment.Name = "OwnerBillboard"
	attachment.CFrame = CFrame.new(0, 7, 0)
	attachment.Parent = door
	
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.Parent = attachment
	
	local textLabel = Instance.new("TextLabel")
	textLabel.TextScaled = true
	textLabel.Text = player.Name.."'s plot"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Parent = billboardGui
end

local function spawnDoorEffects(door: BasePart, player: Player, success: boolean, seconds: number?)
	if debounce[player] then return end
	if not seconds or typeof(seconds) ~= "number" then
		seconds = 1
	end
	
	debounce[player] = true
	claimDoor:FireClient(player, door, success, seconds)
	if success then displayOwnerName(door, player) end
	task.wait(seconds)
	debounce[player] = nil
end

local function loadTycoon(player: Player, Tycoon: Folder)
	local data = PlayerDataService:GetData(player)
	if not data then return end

	local unlocked = data.Tycoon.Unlocked
	
	spawnPurchased.Init(Tycoon)
	for id, _ in pairs(unlocked) do
		print(id)
		spawnPurchased.AddModel(Tycoon, id)
		spawnPurchased.GetButtonMatchingPurchaseObject(Tycoon, id)
		spawnPurchased.AddButton(Tycoon, id)
	end
	spawnPurchased.RemoveAllButtons(Tycoon)
end

--[[lets say the player is Dued1, he just joined the server
	and there's an empty tycoon, it is called Crimson Cherries
	(examples will have the prefix of "(EX)")
]]
local function configureTycoonOwner(door: BasePart, hit: BasePart)
	--(EX) check if the hit is of the player, in this case is Dued1
	local player = configurePlayer(hit)
	if not player then return end
	
	--(EX) check if the tycoon exist and not just a door
	local Tycoon = door.Parent :: Folder
	if not Tycoon then
		warn("Missing Tycoon")
		return
	end
	
	--(EX) check if the door has the attribute SlotName, in this case yes, and it's "Crimson Cherries"
	local slotName = door:GetAttribute("SlotName") :: string
	if not slotName then
		warn("Missing Slot Name")
		return
	end
	
	--[[(EX) each player may have already claimed a spot, or the spot is already claimed by someone else
		in this case, Dued1 touches the empty tycoon called Crimson Cherries
		since he doesn't have a tycoon yet, he gets to skip this if statement
	]]
	--prevent the case of touching the tycoon the player already owned
	if tycoonOwners[player] == Tycoon or tycoonOwners[Tycoon] == player then return end
	
	if tycoonOwners[player] then
		spawnDoorEffects(door, player, false)
		print("Sorry, you("..player.Name..") already claimed a tycoon!")
		return
	end
	
	--(EX) and since this tycoon is also claimed by no one, skip this if statement too
	if tycoonClaimed[Tycoon]then
		spawnDoorEffects(door, player, false)
		print("Sorry, "..tycoonClaimed[Tycoon].Name.." claimed the tycoon "..slotName.." already!")
		return
	end
	
	--[[(EX) it's time to give Dued1 the tycoon!
		assign Dued1 to the owner list(tycoonOwners) with the Crimson Cherries tycoon as value
		and assign the tycoon CrimsonCherries to the claimed list(tycoonClaimed) with Dued1 as value
		additionally, you can add the owner's user id as attribute to the tycoon for extra clariance i guess
	]]
	spawnDoorEffects(door, player, true)
	tycoonClaimed[Tycoon] = player :: Player
	tycoonOwners[player] = Tycoon :: Model
	print(player.Name.." claimed the tycoon "..slotName..'!')
	Tycoon:SetAttribute("OwnerUserID", player.UserId)
	task.wait()
	--PlayerDataService:Set(player, "Tycoon", {Unlocked = {}})
	loadTycoon(player, Tycoon)
	--[[(EX) at the end, the owners list and the claimed list both have a new entry
		tycoonOwners[Dued1] = "CrimsonCherries"
		tycoonClaimed["CrimsonCherries"] = Dued1
	]]
end

local function onModelAdded(model: BasePart)
	model.Touched:Connect(function(otherPart: BasePart)
		configureTycoonOwner(model, otherPart)
	end)
end

local function onModelRemoved(model: Part)
	print("wth who deleted this")
end

for _, v in CollectionService:GetTagged("TycoonDoor") do
	onModelAdded(v)
end
CollectionService:GetInstanceAddedSignal("TycoonDoor"):Connect(onModelAdded)
CollectionService:GetInstanceRemovedSignal("TycoonDoor"):Connect(onModelRemoved)


--(EX) Oh noes! Dued1 left the server! Now we gotta clean up his mess!
Players.PlayerRemoving:Connect(function(player: Player, reason: Enum.PlayerExitReason)
	print(player.Name.." left the game")
	
	--(EX) check if Dued1 has tycoon, in this case yes and it is called Crimson Cherries
	local Tycoon = tycoonOwners[player]
	if not Tycoon then return end
	
	--(EX) strip Dued1 off of tycoon rights
	tycoonClaimed[Tycoon] = nil
	tycoonOwners[player] = nil
	
	--(EX) strip the tycoon off of the ownership
	local door = Tycoon:FindFirstChild("door")
	if door and door:FindFirstChild("OwnerBillboard") then door.OwnerBillboard:Destroy() end
	
	Tycoon:SetAttribute("OwnerUserID", nil)
	
	--[[(EX) Dued1 may have made progress in his tycoon, now he has left, the tycoon has to turn into what it originally looked like
		there's this starter template inside replicated storage
		which consist of 2 uh conveyors and the cash display and button to get da sweet cash
		and most importantly the starter button to begin all life
	]]
	local buttonsFolder = Tycoon:FindFirstChild("buttons")
	local modelsFolder = Tycoon:FindFirstChild("models")
	local dropsFolder = Tycoon:FindFirstChild("drops")
	if not buttonsFolder or not modelsFolder or not dropsFolder then
		warn("things are missing")
		return
	end
	--[[now you may ask, why delete everything in buttons and models folder and then copy from starter template
		instead of delete everything else except models matching the starter tycoon name?
		1. its just much simpler and you dont have to manually hardcode the names
		and it's just easier to adjust via the template in replicated storage than here
		you know what i mean
		2. most models have tags, simply removing it then add it back is gonna make some problems
		and due to the function i made that handles when a specfic tag is removed, it's just redundant
		3. its fast anyway (microseconds wont do harm)
		if in any ways it fails its probably the player's fault anyway for randomly playing with DEX and deleting the starter template
		but if that ever happens we should all be in fear cause that means server side exploits are back
	]]
	for _, v in dropsFolder:GetChildren() do
		local Cash = CashObject:GetCashFromPart(v)
		if Cash then
			Cash:Destroy()
		else
			v:Destroy()
			v = nil
		end
	end
	for _, v in buttonsFolder:GetChildren() do
		v:Destroy()
		v = nil
	end
	for _, v in modelsFolder:GetChildren() do
		v:Destroy()
		v = nil
	end
	
	
	--you know what i should just make an instance serializer so that items would be more certain to load
	local StarterTemplate = getTemplate.Starter()
	local starterTemplateButtonsFolder = StarterTemplate:FindFirstChild("buttons")
	local starterTemplateModelsFolder = StarterTemplate:FindFirstChild("models")
	local starterTemplateBase = StarterTemplate:FindFirstChild("base")
	
	for _, v in starterTemplateButtonsFolder:GetChildren() do
		local clone = v:Clone()
		local objectSpace = starterTemplateBase.CFrame:ToObjectSpace(v:GetPivot())
		local base = Tycoon.base
		clone.Parent = buttonsFolder
		clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
	end
	for _, v in starterTemplateModelsFolder:GetChildren() do
		local clone = v:Clone()
		local objectSpace = starterTemplateBase.CFrame:ToObjectSpace(v:GetPivot())
		local base = Tycoon.base
		clone.Parent = modelsFolder
		clone:PivotTo(base.CFrame:ToWorldSpace(objectSpace))
	end
	
	--(EX) Now Dued1 left the server, the tycoon Crimson Cherries is back to its original state for the next player to use!
end)