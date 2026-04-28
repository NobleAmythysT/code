local CollectionService = game:GetService("CollectionService")

function setupConveyor(conveyor: Model)
	local Tycoon = conveyor.Parent.Parent
	if not Tycoon then return end

	local Path = conveyor:FindFirstChild("Path") :: BasePart
	if not Path then return end

	local velocity = Path.AssemblyLinearVelocity.Magnitude
	Path.AssemblyLinearVelocity = (Path.CFrame * CFrame.Angles(0, math.rad(90), 0)).LookVector * velocity
end

function removeConveyor(conveyor: Model)
	if conveyor then
		conveyor:Destroy()
		conveyor = nil
	end
	print("Conveyor is removed")
end

for _, button in CollectionService:GetTagged("Conveyor") do
	setupConveyor(button)
end
CollectionService:GetInstanceAddedSignal("Conveyor"):Connect(setupConveyor)
CollectionService:GetInstanceRemovedSignal("Conveyor"):Connect(removeConveyor)