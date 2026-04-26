local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dollar = ReplicatedStorage:WaitForChild("dollar") :: BasePart
local CashRegistry = {}

local Cash = {}
Cash.__index = Cash

function Cash.New(duration: number, amount: number, spawner: BasePart, ownerUserId: number)
	local self = setmetatable({
		duration = duration,
		amount = amount,
		spawnPos = spawner.Position,
		ownerUserId = ownerUserId,
		parentFolder = spawner.Parent.Parent.Parent:FindFirstChild("drops") or workspace
	}, Cash)
	
	local part = dollar:Clone()
	part:SetAttribute("CashAmount", amount)
	part:SetAttribute("OwnerUserID", ownerUserId)
	local TextLabel = part:FindFirstChild("BillboardGui"):FindFirstChild("TextLabel")
	TextLabel.Text = "$" .. amount
	
	self.dollar = part
	CashRegistry[part] = self
	--failsafe
	task.delay(30, function()
		self:Destroy()
	end)
	
	return self
end

function Cash:Spawn()
	self.dollar.Position = self.spawnPos
	self.dollar.Parent = self.parentFolder
end

function Cash:Destroy()
	if CashRegistry[self.dollar] then
		CashRegistry[self.dollar] = nil
	end
	if self.dollar then
		self.dollar:Destroy()
		self.dollar = nil
	end
end

function Cash:GetCashFromPart(part)
	return CashRegistry[part]
end

return Cash
