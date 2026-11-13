local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local parent = script.Parent
local Skins = require(parent:WaitForChild("Skins"))
local Uniforms = require(parent:WaitForChild("Uniforms"))
local WeaponSkins = require(parent:WaitForChild("WeaponSkins"))
local Hardpoint = require(parent:WaitForChild("Hardpoint"))
local HeldScale = require(parent:WaitForChild("HeldScale"))
local StandardBody = require(parent:WaitForChild("StandardBody"))
local PodiumSet = require(parent:WaitForChild("PodiumSet"))
local ToolTemplates = ReplicatedStorage:WaitForChild("ToolTemplates")

local Podium = {}

Podium.SLOTS = {
	{ x = 0, z = 1.6, turn = -0.3839724354387525, pose = "hero" },
	{ x = -4.6, z = -0.6, turn = -0.5235987755982988, pose = "port" },
	{ x = 4.6, z = -0.6, turn = 0.4886921905584123, pose = "aim" }
}
Podium.PUSH_AT = 3.4
Podium.LENGTH = 6.7

local function findJoint(instance, childName: string, childName2: string)
	local child = instance:FindFirstChild(childName)
	local instance2 = child and child:FindFirstChild(childName2)

	if instance2 and instance2:IsA("Motor6D") then
		return { j = instance2, c0 = instance2.C0, c1i = instance2.C1:Inverse() }
	end

	if instance2 and instance2:IsA("AnimationConstraint") and instance2.Attachment0 and instance2.Attachment1 then
		return {
			j = instance2,
			c0 = instance2.Attachment0.CFrame,
			c1i = instance2.Attachment1.CFrame:Inverse()
		}
	end

	return nil
end

local function makeArm(result, p: string)
	local joint = findJoint(result, p .. "UpperArm", p .. "Shoulder")
	local joint2 = findJoint(result, p .. "LowerArm", p .. "Elbow")
	local joint3 = findJoint(result, p .. "Hand", p .. "Wrist")

	if not (joint and joint2 and joint3) then
		return nil
	end

	joint3.j.Transform = CFrame.identity
	local v = joint.c1i * joint2.c0.Position
	local v2 = joint2.c1i * (joint3.c0 * joint3.c1i).Position
	local cframe = CFrame.lookAlong(Vector3.new(0, 0, 0), v, joint.c1i:VectorToWorldSpace(Vector3.new(1, 0, 0)))
	local cframe2 = CFrame.lookAlong(Vector3.new(0, 0, 0), v2, joint2.c1i:VectorToWorldSpace(Vector3.new(1, 0, 0)))
	return {
		shoulder = joint,
		elbow = joint2,
		upperLen = v.Magnitude,
		lowerLen = v2.Magnitude,
		upperRestInv = cframe:Inverse(),
		lowerRestInv = cframe2:Inverse(),
		r0i = joint.c0.Rotation:Inverse(),
		mid = joint.c1i.Rotation * joint2.c0.Rotation
	}
end

local function solveArm(data, vector3: Vector3, vector: Vector3)
	local position = data.shoulder.c0.Position
	local upperLen = data.upperLen
	local lowerLen = data.lowerLen
	local v = vector3 - position
	local magnitude = v.Magnitude
	local vector2 = not (magnitude > 0.0001) and Vector3.new(0, -1, 0) or v / magnitude
	local v2 = math.clamp(magnitude, math.abs(upperLen - lowerLen) + 0.01, upperLen + lowerLen - 0.001)
	local v3 = (upperLen * upperLen - lowerLen * lowerLen + v2 * v2) / (2 * v2)
	local v4 = math.sqrt((math.max(0, upperLen * upperLen - v3 * v3)))
	local v5 = vector - vector2 * vector:Dot(vector2)

	if v5.Magnitude < 0.001 then
		v5 = vector2:Cross(Vector3.new(0, 0, 1))

		if v5.Magnitude < 0.001 then
			v5 = vector2:Cross(Vector3.new(1, 0, 0))
		end
	end

	local unit = v5.Unit
	local v6 = position + vector2 * v3 + unit * v4
	local v7 = (v6 - position) / upperLen
	local unit2 = (position + vector2 * v2 - v6).Unit
	local cross = unit:Cross(vector2)
	local v8 = CFrame.lookAlong(Vector3.new(0, 0, 0), v7, cross) * data.upperRestInv
	data.shoulder.j.Transform = data.r0i * v8
	local v9 = CFrame.lookAlong(Vector3.new(0, 0, 0), unit2, cross) * data.lowerRestInv
	data.elbow.j.Transform = (v8 * data.mid):Inverse() * v9
end

local function hold(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3?) -- 1 equivalent call inferred from this helper
	return CFrame.lookAlong(vector3, vector3_2.Unit, vector3_3 or Vector3.new(0, 1, 0))
end

hold(Vector3.new(0.38, -0.42, -0.78), Vector3.new(-0.9, -0.24, -0.36)) -- inferred equivalent call
local cframe = CFrame.lookAlong(
	Vector3.new(0.1, -0.2, -0.66),
	(Vector3.new(-0.78, 0.58, -0.2)).Unit,
	Vector3.new(0.55, 0.75, 0)
)
local cframe2 = CFrame.lookAlong(
	Vector3.new(0.5, -0.35, -0.95),
	(Vector3.new(0.22, 0.95, 0.12)).Unit,
	Vector3.new(0.3, 0, -1)
)

local v = cframe2 * CFrame.new(0, 0.05, 0.12) * CFrame.Angles(0.12, 0, 0)

local unit = (Vector3.new(-0.72, -0.16, -0.75)).Unit
local cframe3 = CFrame.Angles(-0.12, math.atan2(-unit.X, -unit.Z) * 0.8, 0.12)

local v2 = {
	rifle = "AssaultRifle",
	lmg = "LMG",
	sniper = "Sniper",
	smg = "SMG",
	dmr = "DMR",
	shotgun = "Shotgun"
}

function Podium.gunOf(data, attributeName: string, p: string)
	if data.bot then
		local gun = data.entry and data.entry:GetAttribute("Gun")
		return v2[tostring(gun)] or "AssaultRifle", WeaponSkins.DEFAULT
	end

	local player = data.player
	local attribute = player:GetAttribute(attributeName)

	if type(attribute) == "string" and ToolTemplates:FindFirstChild(attribute) then
		p = attribute
	end

	return p, WeaponSkins.pick(player, p)
end

local function playerDesc(player)
	local success, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
	end)

	if not (success and result) then
		warn("[Podium] no avatar for " .. player.Name .. ": " .. tostring(result))
		return nil
	end

	StandardBody.apply(result)
	result.Shirt = 0
	result.Pants = 0
	result.GraphicTShirt = 0
	result:SetAccessories({}, true)
	result.HatAccessory = ""
	result.HairAccessory = ""
	result.FaceAccessory = ""
	result.NeckAccessory = ""
	result.ShouldersAccessory = ""
	result.FrontAccessory = ""
	result.BackAccessory = ""
	result.WaistAccessory = ""
	return result
end

local function lookOf(data, instance)
	if data.bot then
		local shirtTemplate = instance:GetAttribute("ShirtTemplate")
		local pantsTemplate = instance:GetAttribute("PantsTemplate")
		local gear = instance:GetAttribute("Gear")

		if type(shirtTemplate) ~= "string" or type(pantsTemplate) ~= "string" then
			return nil
		end

		if type(gear) ~= "string" then
			gear = nil
		end

		return { shirt = shirtTemplate, pants = pantsTemplate, gear = gear }
	else
		local player = data.player
		local look = Skins.look(Skins.get(Skins.pick(player)), data.team, player.UserId)
		return { shirt = look.shirt, pants = look.pants, gear = look.gear }
	end
end

local function quiet(p, castShadow: boolean) -- 3 equivalent calls inferred from this helper
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = castShadow
end

local function makeGun(childName: string, p: string, castShadow: boolean)
	local tool = ToolTemplates:FindFirstChild(childName)
	local handle = tool and tool:FindFirstChild("Handle")

	if not (tool and tool:IsA("Tool") and handle and handle:IsA("BasePart")) then
		warn("[Podium] no tool " .. childName)
		return nil, Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), CFrame.identity
	end

	local gun = Instance.new("Model")
	gun.Name = "Gun"
	local function clean(instance)
		for _, child in instance:GetChildren() do
			if not (child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("WeldConstraint") or child:IsA("Constraint") or child:IsA("BasePart") or child:IsA("Sound") or child:IsA("Light") or child:IsA("ParticleEmitter")) then
				continue
			end

			child:Destroy()
		end
	end

	local v3 = HeldScale.of(childName)
	local handle2 = handle:Clone()
	clean(handle2)
	quiet(handle2, castShadow) -- inferred equivalent call
	HeldScale.grow(handle2, v3)
	handle2.CFrame = CFrame.identity
	handle2.Name = "Handle"
	handle2.Parent = gun

	for _, part in tool:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= handle and part.Transparency < 1) then
			continue
		end

		local clone = part:Clone()
		clean(clone)
		quiet(clone, castShadow) -- inferred equivalent call
		HeldScale.grow(clone, v3)
		local offset = HeldScale.offset(handle.CFrame:ToObjectSpace(part.CFrame), v3)
		clone.CFrame = offset
		local weld = Instance.new("Weld")
		weld.Part0 = handle2
		weld.Part1 = clone
		weld.C0 = offset
		weld.Parent = clone
		clone.Parent = gun
	end

	gun.PrimaryPart = handle2
	WeaponSkins.paint(gun, p)

	local position = tool.Grip.Position
	local muzzleAttachment = handle:FindFirstChild("MuzzleAttachment")
	local v4 = not (muzzleAttachment and muzzleAttachment:IsA("Attachment")) and -1.6 or muzzleAttachment.Position.Z
	local vector3 = Vector3.new(0, position.Y + 0.03, (math.clamp(v4 * 0.48, -1.05, -0.45)))
	local cframe4 = CFrame.new(0, 0.05, -(position.Z + 0.8))
	return gun, position * v3, vector3 * v3, HeldScale.offset(cframe4, v3)
end

local function buildFigure(data, slot: number, data2, p: string, p2: string, castShadow: boolean)
	local v3 = nil

	if data2.bot then
		local avatar = data2.entry and data2.entry:FindFirstChild("Avatar")

		if avatar and avatar:IsA("HumanoidDescription") then
			v3 = avatar:Clone()
		else
			v3 = nil
		end
	elseif data2.player then
		v3 = playerDesc(data2.player)
	end

	if v3 and not data.dead then
		local v4 = lookOf(data2, v3)
		v3.ClimbAnimation = 0
		v3.FallAnimation = 0
		v3.IdleAnimation = 0
		v3.JumpAnimation = 0
		v3.RunAnimation = 0
		v3.SwimAnimation = 0
		v3.WalkAnimation = 0
		v3.MoodAnimation = 0
		local success, result = pcall(function()
			return Players:CreateHumanoidModelFromDescriptionAsync(
				v3,
				Enum.HumanoidRigType.R15,
				Enum.AssetTypeVerification.Always
			)
		end)

		v3:Destroy()

		if not (success and result) then
			warn("[Podium] avatar build failed for " .. data2.name .. ": " .. tostring(result))
			return
		end

		if data.dead then
			result:Destroy()
			return
		end

		for _, descendant in result:GetDescendants() do
			if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("BallSocketConstraint") or descendant:IsA("NoCollisionConstraint")) then
				continue
			end

			descendant:Destroy()
		end

		local humanoid = result:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")
		local upperTorso = result:FindFirstChild("UpperTorso")

		if
			humanoid
			and humanoidRootPart
			and humanoidRootPart:IsA("BasePart")
			and upperTorso
			and upperTorso:IsA("BasePart")
		then
			if v4 then
				Uniforms.put(result, v4)
			else
				warn("[Podium] no uniform for " .. data2.name)
			end

			humanoid.EvaluateStateMachine = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			humanoid.BreakJointsOnDeath = false
			humanoid.RequiresNeck = false
			local animator = humanoid:FindFirstChildOfClass("Animator")

			if animator then
				animator:Destroy()
			end

			for _, part in result:GetDescendants() do
				if part:IsA("BasePart") then
					quiet(part, castShadow) -- inferred equivalent call
				end
			end

			humanoidRootPart.Anchored = true
			humanoidRootPart.Transparency = 1
			local arms = { makeArm(result, "Right"), makeArm(result, "Left") }

			if arms[1] and arms[2] then
				local v5 = Podium.SLOTS[slot]
				local v6 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
				humanoidRootPart.CFrame = data.frame * CFrame.new(v5.x, v6, v5.z) * CFrame.Angles(0, 3.141592653589793 + v5.turn, 0)
				local gun, right, left, up = makeGun(p, p2, castShadow)
				local mount

				if gun then
					local primaryPart = gun.PrimaryPart
					mount = Instance.new("Motor6D")
					mount.Name = "Mount"
					mount.Part0 = upperTorso
					mount.Part1 = primaryPart
					mount.Parent = primaryPart
					gun.Parent = result
				end

				local v7 = {
					model = result,
					root = humanoidRootPart,
					upper = upperTorso,
					arms = arms,
					waist = findJoint(result, "UpperTorso", "Waist"),
					neck = findJoint(result, "Head", "Neck"),
					hips = {
						findJoint(result, "LeftUpperLeg", "LeftHip"),
						findJoint(result, "RightUpperLeg", "RightHip")
					},
					gun = gun,
					motor = mount,
					right = right,
					left = left,
					up = up,
					slot = slot,
					seed = slot * 1.7
				}

				result.Name = "Podium" .. slot
				Podium.pose(v7, 0)
				result.Parent = data.folder
				data.figures[slot] = v7
			else
				warn("[Podium] avatar for " .. data2.name .. " has no R15 arms")
				result:Destroy()
			end
		else
			warn("[Podium] avatar for " .. data2.name .. " is missing its Humanoid, root or UpperTorso")
			result:Destroy()
		end
	elseif not v3 then
		warn("[Podium] no avatar description for " .. data2.name)
	end
end

local function smooth(value: number) -- 3 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return v3 * v3 * (3 - v3 * 2)
end

function Podium.pose(data, p: number)
	local v3 = Podium.SLOTS[data.slot]
	local v4 = math.sin(p * 1.7 + data.seed) * 0.018

	if data.waist then
		data.waist.j.Transform = CFrame.Angles(v4, v3.pose == "aim" and 0 or -v3.turn * 0.35, 0)
	end

	if data.neck then
		local j = data.neck.j
		local transform

		if v3.pose == "aim" then
			transform = cframe3
		else
			transform = CFrame.Angles(v4 * 0.5 + 0.06, -v3.turn * 0.55, 0)
		end

		j.Transform = transform
	end

	for k, hip in data.hips do
		if hip then
			hip.j.Transform = CFrame.Angles(0, 0, k == 1 and -0.07 or 0.07)
		end
	end

	local vector3 = nil
	local v5 = Vector3.new(-0.5, -1, 0.2)
	local v6

	if v3.pose == "hero" then
		local v7 = smooth((p - (Podium.PUSH_AT - 0.1)) / 0.35) -- inferred equivalent call
		v6 = cframe2:Lerp(v, v7)

		if v7 > 0 then
			local v8 = math.sin(math.max(0, p - Podium.PUSH_AT) * 9) * 0.06 * math.exp(-math.max(0, p - Podium.PUSH_AT) * 3)
			vector3 = (v6 * data.left):Lerp(Vector3.new(-0.95, 1.55, -0.45) + Vector3.new(0, v8, 0), v7)
			v5 = (Vector3.new(-0.5, -1, 0.2)):Lerp(Vector3.new(-1, -0.3, 0.4), v7)
		end
	elseif v3.pose == "port" then
		v6 = cframe
	else
		v6 = CFrame.lookAlong(Vector3.new(0.42, 0.42, 0.3), unit) * data.up
	end

	local transform = v6 * CFrame.new(0, v4 * 0.4, 0)

	if data.motor then
		data.motor.Transform = transform
	end

	solveArm(data.arms[1], transform * data.right, Vector3.new(1, -0.6, 0.35))
	solveArm(data.arms[2], vector3 or transform * data.left, v5)
end

function Podium.groundAt()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Terrain }
	local raycastResult = workspace:Raycast(
		Hardpoint.CENTER + Vector3.new(0, 300, 0),
		Vector3.new(0, -800, 0),
		raycastParams
	)

	if
		raycastResult
		and raycastResult.Material ~= Enum.Material.Water
		and raycastResult.Material ~= Enum.Material.Air
	then
		return raycastResult.Material, workspace.Terrain:GetMaterialColor(raycastResult.Material)
	end

	return Enum.Material.Ground, Color3.fromRGB(110, 98, 80)
end

function Podium.build(items, p, p2, flag: boolean)
	local sunDirection = Lighting:GetSunDirection()
	local vector3 = Vector3.new(sunDirection.X, 0, sunDirection.Z)
	local v3

	if sunDirection.Y > 0.05 and vector3.Magnitude > 0.001 then
		local unit2 = vector3.Unit
		v3 = math.atan2(unit2.X, unit2.Z) + 0.6108652381980153
	else
		v3 = 0
	end

	local frame = CFrame.new(Hardpoint.CENTER + Vector3.new(8000, 200, 0)) * CFrame.Angles(0, v3, 0)
	local roundPodium = Instance.new("Model")
	roundPodium.Name = "RoundPodium"
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.CanCollide = false
	floor.CanQuery = false
	floor.CanTouch = false
	floor.Size = Vector3.new(2048, 4, 2048)
	floor.CFrame = frame * CFrame.new(0, -2, 0)

	if not pcall(function()
		floor.Material = p2.material
	end) then
		floor.Material = Enum.Material.Ground
	end

	floor.Color = p2.color
	floor.Parent = roundPodium
	PodiumSet.build(roundPodium, frame, p2, flag)

	if not flag then
		local fill = Instance.new("Part")
		fill.Name = "Fill"
		fill.Anchored = true
		fill.CanCollide = false
		fill.CanQuery = false
		fill.CanTouch = false
		fill.Transparency = 1
		fill.Size = Vector3.new(1, 1, 1)
		fill.CFrame = CFrame.lookAt((frame * CFrame.new(-6, 9, 16)).Position, (frame * CFrame.new(0, 3.5, 0)).Position)
		local spotLight = Instance.new("SpotLight")
		spotLight.Face = Enum.NormalId.Front
		spotLight.Angle = 70
		spotLight.Range = 40
		spotLight.Brightness = 1.2
		spotLight.Color = Color3.fromRGB(255, 240, 222)
		spotLight.Shadows = false
		spotLight.Parent = fill
		fill.Parent = roundPodium
	end

	roundPodium.Parent = workspace
	local v4 = {
		folder = roundPodium,
		frame = frame,
		figures = {},
		dead = false,
		focus = nil,
		grade = nil,
		tAt = nil,
		clockAt = 0,
		poser = nil
	}
	v4.poser = RunService.PreSimulation:Connect(function()
		local tAt = v4.tAt

		if tAt then
			local v5 = tAt + (os.clock() - v4.clockAt)

			for _, figure in v4.figures do
				Podium.pose(figure, v5)
			end
		end
	end)

	local podiumGrade = Instance.new("ColorCorrectionEffect")
	podiumGrade.Name = "PodiumGrade"
	podiumGrade.Contrast = 0.12
	podiumGrade.Saturation = -0.1
	podiumGrade.Brightness = 0.01
	podiumGrade.TintColor = Color3.fromRGB(255, 244, 230)
	podiumGrade.Enabled = false
	podiumGrade.Parent = Lighting
	v4.grade = podiumGrade

	if not flag then
		local podiumFocus = Instance.new("DepthOfFieldEffect")
		podiumFocus.Name = "PodiumFocus"
		podiumFocus.FocusDistance = 17.5
		podiumFocus.InFocusRadius = 9
		podiumFocus.FarIntensity = 0.45
		podiumFocus.NearIntensity = 0
		podiumFocus.Enabled = false
		podiumFocus.Parent = Lighting
		v4.focus = podiumFocus
	end

	task.spawn(function()
		for k, item in items do
			if v4.dead or #Podium.SLOTS < k then
				break
			end

			local v5 = p[k]
			local success, result = pcall(buildFigure, v4, k, item, v5[1], v5[2], not flag)

			if not success then
				warn("[Podium] figure " .. k .. " failed: " .. tostring(result))
			end
		end
	end)
	return v4
end

function Podium.camera(p, p2: number)
	local v3

	if p2 < Podium.PUSH_AT then
		v3 = smooth(p2 / Podium.PUSH_AT) * -2 * 0.6 + 19.5 + -0.8 * (p2 / Podium.PUSH_AT) -- inferred equivalent call
	elseif p2 < Podium.PUSH_AT + 0.7 then
		v3 = smooth((p2 - Podium.PUSH_AT) / 0.7) * -4.699999999999999 + 17.5 -- inferred equivalent call
	else
		v3 = math.clamp((p2 - Podium.PUSH_AT - 0.7) / (Podium.LENGTH - Podium.PUSH_AT - 0.7), 0, 1) * -0.6000000000000014 + 12.8
	end

	local v4 = math.clamp(p2 / Podium.LENGTH, 0, 1) * 2.2 + -1.4
	local v5 = p.frame * Vector3.new(v4, 2.7, v3)
	local v6 = p.frame * Vector3.new(v4 * 0.35, 3.7, 0)

	if p.focus then
		p.focus.FocusDistance = v3 - 1
	end

	return CFrame.lookAt(v5, v6), 32
end

function Podium:step(tAt: number)
	if self.focus and not self.focus.Enabled then
		self.focus.Enabled = true
	end

	if self.grade and not self.grade.Enabled then
		self.grade.Enabled = true
	end

	self.tAt = tAt
	self.clockAt = os.clock()
end

function Podium:destroy()
	self.dead = true

	if self.poser then
		self.poser:Disconnect()
		self.poser = nil
	end

	self.folder:Destroy()

	if self.focus then
		self.focus:Destroy()
	end

	if self.grade then
		self.grade:Destroy()
	end

	table.clear(self.figures)
end

return Podium