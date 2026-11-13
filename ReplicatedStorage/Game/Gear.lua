local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gearKits = ReplicatedStorage:WaitForChild("Game"):WaitForChild("GearKits")

local Gear = {}
Gear.PREFIX = "Gear_"
local v = {
	Head = Vector3.new(1.159, 1.182, 1.161),
	UpperTorso = Vector3.new(1.943, 1.698, 1.004),
	LowerTorso = Vector3.new(1.991, 0.401, 1.004),
	LeftUpperArm = Vector3.new(1.001, 1.242, 1.002),
	RightUpperArm = Vector3.new(1.001, 1.242, 1.002),
	LeftLowerArm = Vector3.new(1.001, 1.118, 1.002),
	RightLowerArm = Vector3.new(1.001, 1.118, 1.002),
	LeftHand = Vector3.new(0.984, 0.316, 1.028),
	RightHand = Vector3.new(0.984, 0.316, 1.028),
	LeftUpperLeg = Vector3.new(0.993, 1.363, 0.973),
	RightUpperLeg = Vector3.new(0.993, 1.363, 0.973),
	LeftLowerLeg = Vector3.new(0.993, 1.301, 0.973),
	RightLowerLeg = Vector3.new(0.993, 1.301, 0.973),
	LeftFoot = Vector3.new(1.009, 0.312, 1.001),
	RightFoot = Vector3.new(1.009, 0.312, 1.001)
}

function Gear.has(childName: string): boolean
	return gearKits:FindFirstChild(childName) ~= nil
end

function Gear.strip(instance)
	for _, part in instance:GetChildren() do
		if not (part:IsA("BasePart") and string.sub(part.Name, 1, #Gear.PREFIX) == Gear.PREFIX) then
			continue
		end

		part:Destroy()
	end
end

function Gear.attach(parent, childName: string, flag: boolean?)
	local child = gearKits:FindFirstChild(childName)
	assert(child, "[Gear] unknown kit " .. tostring(childName))
	Gear.strip(parent)
	local clones = {}

	for _, part in child:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local part2 = part:GetAttribute("Part")
		local part3

		if type(part2) == "string" then
			part3 = parent:FindFirstChild(part2)
		end

		if part3 and part3:IsA("BasePart") then
			local clone = part:Clone()
			clone.Name = Gear.PREFIX .. part.Name
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			local v2 = v[part2]

			if flag and v2 then
				clone.Size = part.Size * (part3.Size / v2)
			end

			clone.CFrame = part3.CFrame
			local weld = Instance.new("Weld")
			weld.Part0 = part3
			weld.Part1 = clone
			weld.Parent = clone
			clone.Parent = parent
			table.insert(clones, clone)
		else
			warn("[Gear] " .. parent.Name .. " has no " .. tostring(part2) .. " for " .. childName .. "." .. part.Name)
		end
	end

	return clones
end

return Gear