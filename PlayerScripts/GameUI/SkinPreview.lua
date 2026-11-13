local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Skins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Skins"))
local Uniforms = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Uniforms"))
local Gear = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Gear"))
local WeaponSkins = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("WeaponSkins"))
local HeldScale = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("HeldScale"))

local v = nil
local v2 = nil

local v3 = {
	"LuaSourceContainer",
	"Tool",
	"Sound",
	"Clothing",
	"ShirtGraphic",
	"BillboardGui",
	"SurfaceGui",
	"Highlight",
	"ForceField",
	"ParticleEmitter",
	"Trail",
	"Beam",
	"Light",
	"Constraint",
	"JointInstance",
	"Accessory",
	"BodyMover",
	"Explosion",
	"Fire",
	"Smoke",
	"Sparkles",
	"ProximityPrompt",
	"ClickDetector"
}

local function strip(folder)
	for _, descendant in folder:GetDescendants() do
		if not descendant.Parent then
			continue
		end

		for _, className in v3 do
			if descendant:IsA(className) then
				descendant:Destroy()
				break
			end
		end
	end
end

local function pose(instance, identity: CFrame, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	assert(
		humanoidRootPart and humanoidRootPart:IsA("BasePart"),
		"[SkinPreview] the character copy has no HumanoidRootPart"
	)
	humanoidRootPart.CFrame = identity
	local parts = {}

	for _, part in instance:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	local v4 = { [humanoidRootPart] = true }
	local flag = true

	while flag do
		flag = false

		for _, v5 in parts do
			if not v4[v5] then
				continue
			end

			for _, attachment in v5:GetChildren() do
				if not (attachment:IsA("Attachment") and string.sub(attachment.Name, -13) == "RigAttachment") then
					continue
				end

				for _, v6 in parts do
					if v4[v6] then
						continue
					end

					local attachment2 = v6:FindFirstChild(attachment.Name)

					if not (attachment2 and attachment2:IsA("Attachment")) then
						continue
					end

					local v7 = p and p[v6.Name]
					local cframe

					if v7 then
						cframe = v5.CFrame * attachment.CFrame * v7 * attachment2.CFrame:Inverse()
					else
						cframe = v5.CFrame * attachment.CFrame * attachment2.CFrame:Inverse()
					end

					v6.CFrame = cframe
					v4[v6] = true
					flag = true
				end
			end
		end
	end

	for _, v5 in parts do
		if not v4[v5] then
			warn("[SkinPreview] could not place " .. v5.Name .. " on the preview body")
		end
	end
end

local function anchorAll(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.LocalTransparencyModifier = 0
	end
end

local function copyBody(model)
	local archivable = model.Archivable
	model.Archivable = true
	local soldierPreview = model:Clone()
	model.Archivable = archivable
	assert(soldierPreview, "[SkinPreview] could not copy the character")
	strip(soldierPreview)
	Gear.strip(soldierPreview)
	local humanoid = soldierPreview:FindFirstChildOfClass("Humanoid")
	assert(humanoid, "[SkinPreview] the character copy has no Humanoid (the uniform needs one)")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.EvaluateStateMachine = false

	for _, part in soldierPreview:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = part.Name == "HumanoidRootPart" and 1 or 0
		end
	end

	pose(soldierPreview, CFrame.identity)
	anchorAll(soldierPreview)
	soldierPreview.Name = "SoldierPreview"
	return soldierPreview
end

local SkinPreview = {}

function SkinPreview.body(player)
	local model = player.Character

	if player.Team == nil or not model or model:GetAttribute("Outfit") == nil then
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		model = playerGui and playerGui:FindFirstChild("SoldierBody")

		if not (model and model:IsA("Model")) then
			model = nil
		end
	end

	if not model or model == v2 or not (model.Parent and model:FindFirstChild("HumanoidRootPart")) then
		return v
	end

	if v then
		v:Destroy()
	end

	v = copyBody(model)
	v2 = model

	return v
end

local cframe = CFrame.lookAlong(Vector3.new(0.4, -0.5, -0.8), (Vector3.new(-0.88, -0.36, -0.3)).Unit)

local v4 = {
	LowerTorso = CFrame.Angles(0, 0.13962634015954636, 0.04363323129985824),
	UpperTorso = CFrame.Angles(-0.05235987755982989, -0.24434609527920614, -0.061086523819801536),
	Head = CFrame.Angles(-0.06981317007977318, -0.2792526803190927, 0),
	LeftUpperLeg = CFrame.Angles(0.12217304763960307, 0.24434609527920614, -0.19198621771937624),
	LeftLowerLeg = CFrame.Angles(-0.15707963267948966, 0, 0),
	LeftFoot = CFrame.Angles(0.03490658503988659, 0, 0.14835298641951802),
	RightUpperLeg = CFrame.Angles(0, -0.10471975511965978, 0.06981317007977318),
	RightFoot = CFrame.Angles(0, 0, -0.11344640137963143)
}

local function rigPoint(instance, childName: string, childName2: string) -- 6 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName)
	local attachment = child and child:FindFirstChild(childName2)
	assert(
		attachment and attachment:IsA("Attachment"),
		"[SkinPreview] the preview body has no " .. childName .. "." .. childName2
	)
	return attachment.CFrame
end

local function reach(parent, p: string, vector3: Vector3, vector: Vector3, clone)
	local cframe4 = rigPoint(parent, "UpperTorso", p .. "ShoulderRigAttachment") -- inferred equivalent call
	local cframe2 = rigPoint(parent, p .. "UpperArm", p .. "ShoulderRigAttachment"):Inverse() -- inferred equivalent call
	local cframe5 = rigPoint(parent, p .. "UpperArm", p .. "ElbowRigAttachment") -- inferred equivalent call
	local cframe3 = rigPoint(parent, p .. "LowerArm", p .. "ElbowRigAttachment"):Inverse() -- inferred equivalent call
	local cframe6 = rigPoint(parent, p .. "LowerArm", p .. "WristRigAttachment") -- inferred equivalent call
	local inverse = rigPoint(parent, p .. "Hand", p .. "WristRigAttachment"):Inverse() -- inferred equivalent call
	local v5 = cframe2 * cframe5.Position
	local v6 = cframe3 * (cframe6 * inverse).Position
	local inverse2 = CFrame.lookAlong(Vector3.new(0, 0, 0), v5, cframe2:VectorToWorldSpace(Vector3.new(1, 0, 0))):Inverse()
	local inverse3 = CFrame.lookAlong(Vector3.new(0, 0, 0), v6, cframe3:VectorToWorldSpace(Vector3.new(1, 0, 0))):Inverse()
	local magnitude = v5.Magnitude
	local magnitude2 = v6.Magnitude
	local position = cframe4.Position
	local v7 = vector3 - position
	local magnitude3 = v7.Magnitude
	local v8 = not (magnitude3 > 0.0001) and Vector3.new(0, -1, 0) or v7 / magnitude3
	local v9 = math.clamp(magnitude3, math.abs(magnitude - magnitude2) + 0.01, magnitude + magnitude2 - 0.001)
	local v10 = (magnitude * magnitude - magnitude2 * magnitude2 + v9 * v9) / (2 * v9)
	local v11 = math.sqrt((math.max(0, magnitude * magnitude - v10 * v10)))
	local v12 = vector - v8 * vector:Dot(v8)
	assert(v12.Magnitude > 0.001, "[SkinPreview] an arm's pole lies along its reach")
	local unit = v12.Unit
	local v13 = position + v8 * v10 + unit * v11
	local v14 = (v13 - position) / magnitude
	local unit2 = (position + v8 * v9 - v13).Unit
	local cross = unit:Cross(v8)
	local v15 = CFrame.lookAlong(Vector3.new(0, 0, 0), v14, cross) * inverse2
	clone[p .. "UpperArm"] = cframe4.Rotation:Inverse() * v15
	clone[p .. "LowerArm"] = (v15 * (cframe2.Rotation * cframe5.Rotation)):Inverse() * CFrame.lookAlong(Vector3.new(0, 0, 0), unit2, cross) * inverse3
end

local function gunFor(p)
	local tool = ReplicatedStorage:WaitForChild("ToolTemplates"):FindFirstChild(p.tool)
	local handle = tool and tool:FindFirstChild("Handle")
	assert(
		tool and tool:IsA("Tool") and handle and handle:IsA("BasePart"),
		"[SkinPreview] no tool " .. tostring(p.tool) .. " to hold"
	)
	local v5 = HeldScale.of(p.tool)
	local gun = Instance.new("Model")
	gun.Name = "Gun"
	local function piece(instance, cframe2: CFrame)
		local clone = instance:Clone()

		for _, child in clone:GetChildren() do
			if not (child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("WeldConstraint") or child:IsA("Constraint") or child:IsA("BasePart") or child:IsA("Sound") or child:IsA("Light") or child:IsA("ParticleEmitter")) then
				continue
			end

			child:Destroy()
		end

		HeldScale.grow(clone, v5)
		clone.CFrame = cframe2
		clone.Parent = gun
		return clone
	end

	local handle2 = piece(handle, CFrame.identity)
	handle2.Name = "Handle"

	for _, part in tool:GetDescendants() do
		if part:IsA("BasePart") and part ~= handle and part.Transparency < 1 then
			piece(part, HeldScale.offset(handle.CFrame:ToObjectSpace(part.CFrame), v5))
		end
	end

	gun.PrimaryPart = handle2
	WeaponSkins.paint(gun, p.skin)
	local position = tool.Grip.Position
	local muzzleAttachment = handle:FindFirstChild("MuzzleAttachment")
	local v6 = not (muzzleAttachment and muzzleAttachment:IsA("Attachment")) and -1.6 or muzzleAttachment.Position.Z
	local vector3 = Vector3.new(0, position.Y + 0.03, (math.clamp(v6 * 0.48, -1.05, -0.45)))
	return gun, position * v5, vector3 * v5
end

local function stand(clone, p)
	local v5, v6, v7 = gunFor(p)
	local clone2 = table.clone(v4)
	reach(clone, "Right", cframe * v6, Vector3.new(1, -0.6, 0.35), clone2)
	reach(clone, "Left", cframe * v7, Vector3.new(-0.5, -1, 0.2), clone2)
	pose(clone, CFrame.identity, clone2)
	local upperTorso = clone:FindFirstChild("UpperTorso")
	assert(upperTorso and upperTorso:IsA("BasePart"), "[SkinPreview] the preview body has no UpperTorso")
	v5:PivotTo(upperTorso.CFrame * cframe)
	v5.Parent = clone
end

function SkinPreview.dress(instance, p, p2: string?, p3: number, p4)
	local clone = instance:Clone()

	if p4 then
		stand(clone, p4)
	end

	Uniforms.put(clone, Skins.look(p, p2, p3))
	anchorAll(clone)
	return clone
end

local v5 = {
	full = { focus = Vector3.new(0, -0.35, 0), height = 6.6 },
	bust = { focus = Vector3.new(0, 1.35, 0), height = 2.9 }
}

local v6 = {
	plain = {
		ambient = Color3.fromRGB(150, 150, 156),
		light = Color3.fromRGB(255, 246, 232),
		dir = Vector3.new(0.45, -0.75, 0.55)
	},
	stage = {
		ambient = Color3.fromRGB(92, 104, 130),
		light = Color3.fromRGB(255, 232, 196),
		dir = Vector3.new(0.3, -0.8, 0.52)
	}
}

function SkinPreview.view(parent, p: string, value: string?)
	local v7 = v5[p]
	assert(v7, "[SkinPreview] unknown framing " .. tostring(p))
	local v8 = v6[value or "plain"]
	assert(v8, "[SkinPreview] unknown look " .. tostring(value))
	local preview = Instance.new("ViewportFrame")
	preview.Name = "Preview"
	preview.BackgroundTransparency = 1
	preview.BorderSizePixel = 0
	preview.Size = UDim2.fromScale(1, 1)
	preview.Ambient = v8.ambient
	preview.LightColor = v8.light
	preview.LightDirection = v8.dir
	preview.Parent = parent
	local camera = Instance.new("Camera")
	camera.FieldOfView = 28
	camera.Parent = preview
	preview.CurrentCamera = camera
	local v9 = v7.height / 2 / 0.24932800284318068

	local v10 = -0.4886921905584123
	local function place()
		local position = (CFrame.new(v7.focus) * CFrame.Angles(0, v10, 0) * CFrame.Angles(0.10471975511965978, 0, 0) * CFrame.new(0, 0, -v9)).Position
		camera.CFrame = CFrame.lookAt(position, v7.focus)
	end
	place()

	local v11 = nil
	local connections = {}

	if p == "full" then
		local v12 = nil
		local v13 = 0
		table.insert(connections, preview.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v12 = input
				v13 = input.Position.X
			end
		end))
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if not v12 then
				return
			end

			local v14

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				v14 = true
			elseif input.UserInputType == Enum.UserInputType.Touch then
				v14 = input == v12
			else
				v14 = false
			end

			if v14 then
				v10 -= (input.Position.X - v13) * 0.012
				v13 = input.Position.X
				place()
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if v12 and (input == v12 or input.UserInputType == Enum.UserInputType.MouseButton1) then
				v12 = nil
			end
		end))
	end

	return {
		["frame"] = preview,
		show = function(p2)
			if v11 then
				v11:Destroy()
			end

			v11 = p2

			if p2 then
				p2.Parent = preview
			end
		end,
		resetTurn = function()
			v10 = -0.4886921905584123
			place()
		end,
		destroy = function()
			for _, connection in connections do
				connection:Disconnect()
			end

			if v11 then
				v11:Destroy()
			end

			preview:Destroy()
		end
	}
end

return SkinPreview