local parent = script.Parent

local HeldScale = {}

HeldScale.BY_BASE = {
	AssaultRifle = 1.3,
	SMG = 1.35,
	LMG = 1.25,
	DMR = 1.2,
	Sniper = 1.15,
	Shotgun = 1.2,
	Pistol = 1,
	HandCannon = 1
}

local clone = table.clone(HeldScale.BY_BASE)

for childName, v in {
	RifleSpecs = "AssaultRifle",
	SMGSpecs = "SMG",
	LMGSpecs = "LMG",
	DMRSpecs = "DMR",
	SniperSpecs = "Sniper",
	PistolSpecs = "Pistol"
} do
	local module = require(parent:WaitForChild(childName))

	for k in module.LIST do
		clone[k] = HeldScale.BY_BASE[v]
	end
end

function HeldScale.of(p: string)
	return clone[p] or 1
end

function HeldScale.offset(cframe: CFrame, p: number)
	return CFrame.new(cframe.Position * p) * cframe.Rotation
end

function HeldScale:grow(p: number)
	self.Size *= p

	for _, child in self:GetChildren() do
		if child:IsA("Attachment") then
			child.Position *= p
		elseif child:IsA("SpecialMesh") then
			if child.MeshType == Enum.MeshType.FileMesh then
				child.Scale *= p
			end

			child.Offset *= p
		end
	end
end

return HeldScale