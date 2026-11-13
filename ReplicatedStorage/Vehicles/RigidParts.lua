local RigidParts = {}

RigidParts.PARK = CFrame.new(0, 50000, 0)

function RigidParts.root(parent, name: string)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = RigidParts.PARK
	part.Parent = parent
	return part
end

function RigidParts.weld(part, p, c0: CFrame)
	assert(part.Anchored, "[RigidParts] the root must be anchored")
	p.Anchored = true
	p.CFrame = part.CFrame * c0
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = p
	weld.C0 = c0
	weld.Parent = p
	p.Massless = true
	p.Anchored = false
	return weld
end

return RigidParts