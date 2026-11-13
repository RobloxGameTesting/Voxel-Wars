local Gear = require(script.Parent:WaitForChild("Gear"))

local Uniforms = {}

Uniforms.SHIRTS = {
	Reds = {
		blouse = "rbxassetid://118139739997303",
		rolled = "rbxassetid://87118663401765",
		combat = "rbxassetid://117147235340961"
	},
	Blues = {
		blouse = "rbxassetid://105993339235675",
		rolled = "rbxassetid://125606549889657",
		combat = "rbxassetid://140726468772905"
	},
	Neutral = {
		blouse = "rbxassetid://137896596159835",
		rolled = "rbxassetid://137896596159835",
		combat = "rbxassetid://137896596159835"
	}
}

Uniforms.PANTS = {
	Reds = { camo = "rbxassetid://73440888723993", solid = "rbxassetid://131832990450428" },
	Blues = { camo = "rbxassetid://110353663417350", solid = "rbxassetid://136978426347948" },
	Neutral = { camo = "rbxassetid://127218599976800", solid = "rbxassetid://127218599976800" }
}

Uniforms.CLOTH = {
	Reds = Color3.fromRGB(150, 128, 92),
	Blues = Color3.fromRGB(88, 94, 72),
	Neutral = Color3.fromRGB(104, 100, 76)
}

Uniforms.CUTS = {
	{ name = "Blouse, camo trousers", shirt = "blouse", pants = "camo" },
	{ name = "Combat shirt, camo trousers", shirt = "combat", pants = "camo" },
	{ name = "Rolled sleeves, camo trousers", shirt = "rolled", pants = "camo" },
	{ name = "Blouse, plain trousers", shirt = "blouse", pants = "solid" },
	{ name = "Combat shirt, plain trousers", shirt = "combat", pants = "solid" },
	{ name = "Rolled sleeves, plain trousers", shirt = "rolled", pants = "solid" }
}

function Uniforms.team(p: string?)
	return if p and Uniforms.SHIRTS[p] then p else "Neutral"
end

function Uniforms.cutFor(p: number)
	local v = math.abs((math.floor(p)))
	return Uniforms.CUTS[v // 7 % #Uniforms.CUTS + 1]
end

function Uniforms.templates(p: string?, p2: string, p3: string)
	local team = Uniforms.team(p)
	local v = Uniforms.SHIRTS[team][p2]
	local v2 = Uniforms.PANTS[team][p3]
	assert(v, "[Uniforms] unknown shirt style " .. tostring(p2))
	assert(v2, "[Uniforms] unknown trouser style " .. tostring(p3))
	return v, v2
end

for _, v in { "Reds", "Blues", "Neutral" } do
	for _, v2 in Uniforms.CUTS do
		Uniforms.templates(v, v2.shirt, v2.pants)
	end
end

local v = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerArm",
	"RightLowerArm",
	"LeftHand",
	"RightHand",
	"LeftUpperLeg",
	"RightUpperLeg",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftFoot",
	"RightFoot"
}

function Uniforms.put(parent, data, flag: boolean?)
	for _, child in parent:GetChildren() do
		if child:IsA("Clothing") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end

	for _, childName in v do
		local part = parent:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		if part:GetAttribute("BareColor") == nil then
			part:SetAttribute("BareColor", part.Color)
			part:SetAttribute("BareMaterial", part.Material.Name)
		end

		part.Color = part:GetAttribute("BareColor")
		part.Material = Enum.Material[part:GetAttribute("BareMaterial")]
	end

	local uniform = Instance.new("Shirt")
	uniform.Name = "Uniform"
	uniform.ShirtTemplate = data.shirt
	uniform.Parent = parent
	local trousers = Instance.new("Pants")
	trousers.Name = "Trousers"
	trousers.PantsTemplate = data.pants
	trousers.Parent = parent

	if data.gear then
		Gear.attach(parent, data.gear, flag)
	else
		Gear.strip(parent)
	end
end

return Uniforms