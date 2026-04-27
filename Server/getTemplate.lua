local module = {}

function module.Starter(): Model?
	local template = game:GetService("ReplicatedStorage"):FindFirstChild("StarterTemplate")
	assert(template, "the starter template is missing")
	return template
end

function module.Full(): Model?
	local template = game:GetService("ReplicatedStorage"):FindFirstChild("template")
	assert(template, "the complete template is missing")
	return template
end

return module