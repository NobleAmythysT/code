local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local You = game.Players.LocalPlayer

local claimDoor = ReplicatedStorage.claimDoor :: RemoteEvent
local collectMoney = ReplicatedStorage.collectMoney :: RemoteEvent

local successSound = SoundService:FindFirstChild("Success") :: Sound
local errorSound = SoundService:FindFirstChild("Error") :: Sound
local moneySound = SoundService:FindFirstChild("Money") :: Sound
local GetOutSound = SoundService:FindFirstChild("GetOutSoundEffect") :: Sound

claimDoor.OnClientEvent:Connect(function(door: BasePart, success: boolean, seconds: number?)
	seconds = seconds and seconds or 1
	if success then
		print("Congratulations! You claimed the tycoon "..door:GetAttribute("SlotName").."!")
		local sound = successSound:Clone()
		sound.Parent = door
		sound:Play()
		Debris:AddItem(sound, 5)
	else
		local doorColor = door.Color
		door.Color = Color3.fromRGB(255, 0, 0)
		local sound = errorSound:Clone()
		sound.Parent = door
		sound:Play()
		Debris:AddItem(sound, 5)
		task.delay(seconds, function()
			door.Color = doorColor
		end)
	end
end)

collectMoney.OnClientEvent:Connect(function(collector: Model, success: boolean)
	if success then
		local sound = moneySound:Clone()
		sound.Parent = collector
		sound:Play()
		Debris:AddItem(sound, 5)
	else
		print("oh my god you dont own this tycoon get out")
		local sound = GetOutSound:Clone()
		sound.Parent = collector
		sound:Play()
		Debris:AddItem(sound, 5)
	end
end)