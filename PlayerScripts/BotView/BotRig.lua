--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ToolTemplates = ReplicatedStorage2:WaitForChild("ToolTemplates")

local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local Gear = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Gear"))
local HeldScale = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("HeldScale"))

local BotRig = {}

local color = Color3.fromRGB(255, 206, 120)

local btest = bit32.btest

local rifle3 = {
	tool = "AssaultRifle",
	flash = true,
	right = Vector3.new(0.05, -0.35, 0.17),
	left = Vector3.new(0, -0.33, -0.8),
	pivot = Vector3.new(0.42, 0.42, 0.3),
	up = CFrame.new(0, 0.05, -0.96),
	detail = 0.0005
}

local v = {
	tool = "RocketLauncher",
	flash = false,
	right = Vector3.new(0, -0.95, 0.3),
	left = Vector3.new(-0.5, -0.25, -0.85),
	pivot = Vector3.new(0.95, 0.9, 0.9),
	up = CFrame.new(0, 0.65, -1.5)
}

local v2 = {
	rifle = rifle3,
	lmg = {
		tool = "LMG",
		flash = true,
		right = Vector3.new(0.05, -0.43, 0.26),
		left = Vector3.new(0, -0.32, -0.9),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -0.92),
		detail = 0.0005
	},
	sniper = {
		tool = "Sniper",
		flash = true,
		right = Vector3.new(0.05, -0.35, 0.32),
		left = Vector3.new(0, -0.22, -1),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -1.18),
		detail = 0.0005
	},
	minigun = {
		tool = "Minigun",
		flash = true,
		right = Vector3.new(0.05, -0.43, 0.26),
		left = Vector3.new(0, -0.4, -0.85),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -0.92),
		detail = 0.0005,
		props = true
	},
	smg = {
		tool = "SMG",
		flash = true,
		right = Vector3.new(0.05, -0.32, 0.19),
		left = Vector3.new(0, -0.3, -0.5),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -0.68),
		detail = 0.0005
	},
	dmr = {
		tool = "DMR",
		flash = true,
		right = Vector3.new(0.05, -0.35, 0.29),
		left = Vector3.new(0, -0.3, -0.82),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -1.12),
		detail = 0.0005
	},
	shotgun = {
		tool = "Shotgun",
		flash = true,
		right = Vector3.new(0.05, -0.19, 0.47),
		left = Vector3.new(0, -0.3, -0.8),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.05, -1.12),
		detail = 0.0005
	},
	hammer = {
		tool = "BuildHammer",
		flash = false,
		right = Vector3.new(0, 0, -0.75),
		left = Vector3.new(0, 0, -0.35),
		pivot = Vector3.new(0.42, 0.42, 0.3),
		up = CFrame.new(0, 0.2, -0.9) * CFrame.Angles(0.5, 3.141592653589793, 0)
	}
}

local low2 = CFrame.new(0.3, -0.05, -0.7) * CFrame.Angles(-0.6, 0.35, 0.25)
local sprint2 = CFrame.new(0.05, 0.1, -0.8) * CFrame.fromEulerAnglesYXZ(0.5, 1, 0.2)
local reload2 = CFrame.new(0.25, 0, -0.95) * CFrame.Angles(0.15, 0.3, 0.7)
local transform = CFrame.new(0, 0.05, 0.68) * CFrame.Angles(0, 0, 0.75) * CFrame.Angles(1.5707963267948966, 0, 0)

local function quiet(p) -- 3 equivalent calls inferred from this helper
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = false
end

local function strip(clone)
	for _, child in clone:GetChildren() do
		if not (child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("WeldConstraint") or child:IsA("Constraint") or child:IsA("NoCollisionConstraint") or child:IsA("BasePart")) then
			continue
		end

		child:Destroy()
	end
end

local v3 = {}
local function propTemplate(data)
	local v4 = v3[data.tool]

	if v4 then
		return v4
	end

	local v5

	if data.props then
		v5 = ReplicatedStorage:WaitForChild("BotProps")
	else
		v5 = ToolTemplates
	end

	local tool = v5:WaitForChild(data.tool, 10)
	assert(tool and tool:IsA("Tool"), "[BotView] " .. v5.Name .. "." .. data.tool .. " is missing")
	local handle = tool:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "[BotView] " .. data.tool .. " has no Handle")
	local muzzleAttachment = handle:FindFirstChild("MuzzleAttachment")

	assert(
		muzzleAttachment and muzzleAttachment:IsA("Attachment") or not data.flash,
		"[BotView] " .. data.tool .. " has no MuzzleAttachment"
	)

	local model = Instance.new("Model")
	model.Name = "Bot" .. data.tool
	local clone = handle:Clone()
	strip(clone)
	quiet(clone) -- inferred equivalent call

	if not muzzleAttachment then
		local muzzleAttachment2 = Instance.new("Attachment")
		muzzleAttachment2.Name = "MuzzleAttachment"
		muzzleAttachment2.Position = Vector3.new(0, 0, 1)
		muzzleAttachment2.Parent = clone
	end

	local v6 = HeldScale.of(data.tool)
	HeldScale.grow(clone, v6)
	clone.CFrame = CFrame.identity
	clone.Parent = model
	local function weld(p, cframe: CFrame) -- 2 equivalent calls inferred from this helper
		p.CFrame = cframe
		local weld2 = Instance.new("Weld")
		weld2.Part0 = clone
		weld2.Part1 = p
		weld2.C0 = cframe
		weld2.Parent = p
		p.Parent = model
	end
	local detail = data.detail or 0.0021

	for _, part in tool:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= handle and part.Transparency < 1 and detail <= part.Size.X * part.Size.Y * part.Size.Z) then
			continue
		end

		local clone2 = part:Clone()
		strip(clone2)
		quiet(clone2) -- inferred equivalent call
		HeldScale.grow(clone2, v6)
		weld(clone2, HeldScale.offset(handle.CFrame:ToObjectSpace(part.CFrame), v6)) -- inferred equivalent call
	end

	if data.flash then
		local muzzleAttachment2 = clone:FindFirstChild("MuzzleAttachment")
		local function block(size: Vector3, cframe: CFrame) -- 3 equivalent calls inferred from this helper
			local flash = Instance.new("Part")
			flash.Name = "Flash"
			flash.Size = size
			flash.Material = Enum.Material.Neon
			flash.Color = color
			flash.Transparency = 1
			quiet(flash) -- inferred equivalent call
			weld(flash, muzzleAttachment2.CFrame * cframe) -- inferred equivalent call
		end
		block(Vector3.new(0.3, 0.3, 0.8), CFrame.new(0, 0, -0.4)) -- inferred equivalent call
		block(Vector3.new(0.95, 0.16, 0.16), CFrame.new(0, 0, -0.2) * CFrame.Angles(0, 0, 0.7853981633974483)) -- inferred equivalent call
		block(Vector3.new(0.95, 0.16, 0.16), CFrame.new(0, 0, -0.2) * CFrame.Angles(0, 0, -0.7853981633974483)) -- inferred equivalent call
		local pointLight = Instance.new("PointLight")
		pointLight.Color = color
		pointLight.Range = 12
		pointLight.Brightness = 4
		pointLight.Shadows = false
		pointLight.Enabled = false
		pointLight.Parent = muzzleAttachment2
	end

	model.PrimaryPart = clone
	v3[data.tool] = model
	return model
end

local clonesByData = {}
function BotRig.scaleSpec(data)
	local v4 = HeldScale.of(data.tool)

	if v4 == 1 then
		return data
	end

	local v5 = clonesByData[data]

	if v5 then
		return v5
	end

	local clone = table.clone(data)
	local right = data.right * v4
	local left = data.left * v4
	clone.right = right
	clone.left = left

	if not data.pistol then
		clone.up = HeldScale.offset(data.up, v4)
	end

	clone.mag = Vector3.new(0, -0.5, -0.28) * v4
	clonesByData[data] = clone
	return clone
end

local function mountProp(spec, part)
	local clone = propTemplate(spec):Clone()
	local primaryPart = clone.PrimaryPart
	local mount = Instance.new("Motor6D")
	mount.Name = "Mount"
	mount.Part0 = part
	mount.Part1 = primaryPart
	mount.Parent = primaryPart
	local parts = {}

	for _, part2 in clone:GetChildren() do
		if part2.Name == "Flash" and part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	local muzzleAttachment = primaryPart:FindFirstChild("MuzzleAttachment")
	local parts2 = {}

	for _, part2 in clone:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts2, part2)
		end
	end

	return {
		model = clone,
		parts = parts2,
		handle = primaryPart,
		motor = mount,
		muzzle = muzzleAttachment,
		flash = parts,
		light = muzzleAttachment:FindFirstChildOfClass("PointLight"),
		spec = spec,
		hold = BotRig.scaleSpec(spec)
	}
end

local function lightOk(p) -- 1 equivalent call inferred from this helper
	local worldPosition = p.muzzle.WorldPosition
	return (Detail.low and 60 or 120) * Detail.reach() > Detail.distance(worldPosition)
		and Detail.onScreen(worldPosition, 4)
end

local object = setmetatable({}, { __mode = "k" })
local function setFlashLight(light, enabled: boolean)
	if enabled and not object[light] then
		local count = 0

		for k in object do
			if k.Enabled and k.Parent then
				count += 1
			else
				object[k] = nil
			end
		end

		if ((Detail.potato or Detail.low) and 0 or 1e999) <= count then
			enabled = false
		end
	end

	object[light] = enabled and true or nil
	light.Enabled = enabled
end

local function flashLight(rifle, flag: boolean) -- 2 equivalent calls inferred from this helper
	local light = rifle.light

	if not light then
		return
	end

	if flag then
		if not (Detail.potato or Detail.low) then
			setFlashLight(light, lightOk(rifle)) -- inferred equivalent call
		end
	elseif object[light] then
		setFlashLight(light, false)
	end
end

local v4 = {}

local botGuns = Instance.new("Folder")
botGuns.Name = "BotGuns"
botGuns.Parent = workspace
local function propHome(p) -- 4 equivalent calls inferred from this helper
	if p.Parent == nil then
		return nil
	end

	return v4[p] or botGuns
end

local function showProp(p, flag: boolean, model) -- 2 equivalent calls inferred from this helper
	local parent

	if flag and model.Parent ~= nil then
		parent = v4[model] or botGuns
	end

	if p.model.Parent ~= parent then
		p.model.Parent = parent
	end
end

local v5 = {}

local function takeProp(spec, part) -- 3 equivalent calls inferred from this helper
	local v6 = v5[spec.tool]
	local selected = v6 and table.remove(v6)

	if not selected then
		return mountProp(spec, part)
	end

	selected.motor.Part0 = part
	return selected
end

local function giveProp(data)
	data.model.Parent = nil
	data.motor.Part0 = nil
	data.motor.Transform = CFrame.identity

	for _, v6 in data.flash do
		v6.Transparency = 1
	end

	if data.light then
		setFlashLight(data.light, false)
	end

	local data2 = v5[data.spec.tool]

	if not data2 then
		data2 = {}
		v5[data.spec.tool] = data2
	end

	table.insert(data2, data)
end

local cframe = CFrame.new(0, 20000, 0)

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

	local v6 = joint.c1i * joint2.c0.Position
	local v7 = joint2.c1i * (joint3.c0 * joint3.c1i).Position
	local cframe2 = CFrame.lookAlong(Vector3.new(0, 0, 0), v6, joint.c1i:VectorToWorldSpace(Vector3.new(1, 0, 0)))
	local cframe3 = CFrame.lookAlong(Vector3.new(0, 0, 0), v7, joint2.c1i:VectorToWorldSpace(Vector3.new(1, 0, 0)))
	return {
		shoulder = joint,
		elbow = joint2,
		upperLen = v6.Magnitude,
		lowerLen = v7.Magnitude,
		upperRestInv = cframe2:Inverse(),
		lowerRestInv = cframe3:Inverse(),
		r0i = joint.c0.Rotation:Inverse(),
		mid = joint.c1i.Rotation * joint2.c0.Rotation
	}
end

@native local function solveArm(data, vector3: Vector3, vector: Vector3)
	local position = data.shoulder.c0.Position
	local upperLen = data.upperLen
	local lowerLen = data.lowerLen
	local v6 = vector3 - position
	local magnitude = v6.Magnitude
	local vector2 = not (magnitude > 0.0001) and Vector3.new(0, -1, 0) or v6 / magnitude
	local v7 = math.clamp(magnitude, math.abs(upperLen - lowerLen) + 0.01, upperLen + lowerLen - 0.001)
	local v8 = (upperLen * upperLen - lowerLen * lowerLen + v7 * v7) / (2 * v7)
	local v9 = math.sqrt((math.max(0, upperLen * upperLen - v8 * v8)))
	local v10 = vector - vector2 * vector:Dot(vector2)

	if v10.Magnitude < 0.001 then
		v10 = vector2:Cross(Vector3.new(0, 0, 1))

		if v10.Magnitude < 0.001 then
			v10 = vector2:Cross(Vector3.new(1, 0, 0))
		end
	end

	local unit = v10.Unit
	local v11 = position + vector2 * v8 + unit * v9
	local v12 = (v11 - position) / upperLen
	local unit2 = (position + vector2 * v7 - v11).Unit
	local cross = unit:Cross(vector2)
	local v13 = CFrame.lookAlong(Vector3.new(0, 0, 0), v12, cross) * data.upperRestInv
	data.shoulder.j.Transform = data.r0i * v13
	local v14 = CFrame.lookAlong(Vector3.new(0, 0, 0), unit2, cross) * data.lowerRestInv
	data.elbow.j.Transform = (v13 * data.mid):Inverse() * v14
end

local function setMarker(state, textColor: Color3, flag: boolean)
	if flag then
		local friendMarker = state.marker

		if not friendMarker then
			friendMarker = Instance.new("BillboardGui")
			friendMarker.Name = "FriendMarker"
			friendMarker.Size = UDim2.fromOffset(14, 10)
			friendMarker.StudsOffset = Vector3.new(0, 3.4, 0)
			friendMarker.AlwaysOnTop = true

			friendMarker.MaxDistance = 1e999
			friendMarker.LightInfluence = 0
			local mark = Instance.new("TextLabel")
			mark.Name = "Mark"
			mark.Size = UDim2.fromScale(1, 1)
			mark.BackgroundTransparency = 1
			mark.Text = "▼"
			mark.TextScaled = true
			mark.TextStrokeTransparency = 0.4
			mark.Parent = friendMarker
			friendMarker.Adornee = state.model:FindFirstChild("Head") or state.root
			friendMarker.Parent = state.model
			state.marker = friendMarker
		end

		local mark = friendMarker:FindFirstChild("Mark")
		mark.TextColor3 = textColor
	elseif state.marker then
		state.marker:Destroy()
		state.marker = nil
	end
end

local v6 = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftUpperLeg = true,
	RightUpperLeg = true
}

function BotRig.build(instance, textColor: Color3, flag: boolean)
	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(
			instance,
			Enum.HumanoidRigType.R15,
			Enum.AssetTypeVerification.Always
		)
	end)

	if not (success and result) then
		warn("[BotView] avatar build failed: " .. tostring(result))
		return nil
	end

	debug.profilebegin("BR.build")

	for _, luaSourceContainer in result:GetDescendants() do
		if luaSourceContainer:IsA("LuaSourceContainer") then
			luaSourceContainer:Destroy()
		end
	end

	local humanoid = result:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")
	local upperTorso = result:FindFirstChild("UpperTorso")

	if humanoid and humanoidRootPart and upperTorso then
		local shirtTemplate = instance:GetAttribute("ShirtTemplate")
		local pantsTemplate = instance:GetAttribute("PantsTemplate")

		if type(shirtTemplate) == "string" and type(pantsTemplate) == "string" then
			local uniform = Instance.new("Shirt")
			uniform.Name = "Uniform"
			uniform.ShirtTemplate = shirtTemplate
			uniform.Parent = result
			local trousers = Instance.new("Pants")
			trousers.Name = "Trousers"
			trousers.PantsTemplate = pantsTemplate
			trousers.Parent = result
		else
			warn("[BotView] avatar has no uniform")
		end

		local gear = instance:GetAttribute("Gear")

		if type(gear) == "string" then
			Gear.attach(result, gear)
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
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = v6[part.Name] == true and part.Parent == result
			part.Massless = true
		end

		humanoidRootPart.Anchored = true
		humanoidRootPart.CanQuery = false
		humanoidRootPart.Transparency = 1
		local acc = {}
		local body = {}

		for _, part in result:GetDescendants() do
			if not (part:IsA("BasePart") and part ~= humanoidRootPart) then
				continue
			end

			part.CastShadow = not Detail.low
			local v7

			if
				part:FindFirstAncestorOfClass("Accessory") ~= nil
				or string.sub(part.Name, 1, #Gear.PREFIX) == Gear.PREFIX
			then
				v7 = acc
			else
				v7 = body
			end

			table.insert(v7, part)
		end

		local joint = findJoint(result, "LowerTorso", "Root")
		local joint2 = findJoint(result, "UpperTorso", "Waist")
		local joint3 = findJoint(result, "Head", "Neck")
		local hips = {}
		local knees = {}
		local ankles = {}

		for k, v7 in { "Left", "Right" } do
			hips[k] = findJoint(result, v7 .. "UpperLeg", v7 .. "Hip")
			knees[k] = findJoint(result, v7 .. "LowerLeg", v7 .. "Knee")
			ankles[k] = findJoint(result, v7 .. "Foot", v7 .. "Ankle")
		end

		local arm = makeArm(result, "Right")
		local arm2 = makeArm(result, "Left")

		if joint and joint2 and joint3 and arm and arm2 and #hips == 2 and #knees == 2 and #ankles == 2 then
			local set = {}
			local v7 = false

			for _, descendant in result:GetDescendants() do
				if descendant:IsA("WrapLayer") then
					v7 = true
				elseif descendant:IsA("Constraint") and not descendant:IsA("BallSocketConstraint") then
					if descendant.Attachment0 then
						set[descendant.Attachment0] = true
					end

					if descendant.Attachment1 then
						set[descendant.Attachment1] = true
					end
				end
			end

			for _, descendant in result:GetDescendants() do
				if not (descendant:IsA("BallSocketConstraint") or descendant:IsA("NoCollisionConstraint") or descendant:IsA("Camera") or descendant:IsA("Vector3Value") and (descendant.Name == "OriginalSize" or descendant.Name == "OriginalPosition") or descendant:IsA("WrapTarget") and not v7 or descendant:IsA("Attachment") and not (set[descendant] or v7)) then
					continue
				end

				descendant:Destroy()
			end

			local rifle = takeProp(rifle3, upperTorso) -- inferred equivalent call
			local model = rifle.model
			model.Parent = propHome(result) -- inferred equivalent call
			propTemplate(v)

			result.Name = "Bot"
			local v8 = {
				model = result,
				root = humanoidRootPart,
				humanoid = humanoid,
				upper = upperTorso,
				rootJ = joint,
				waist = joint2,
				neck = joint3,
				hips = hips,
				knees = knees,
				ankles = ankles,
				arms = { arm, arm2 },
				rifle = rifle,
				launcher = nil,
				body = body,
				acc = acc,
				lodTier = 0,
				shadowOn = not Detail.low,
				accHidden = false,
				rocketShown = false,
				marker = nil,
				vel = Vector3.new(0, 0, 0),
				dir = Vector3.new(0, 0, -1),
				phase = 0,
				tilt = Vector3.new(0, 0, 0),
				tiltV = Vector3.new(0, 0, 0),
				air = 0,
				wasAir = false,
				vy = 0,
				land = 0,
				twist = -0.45,
				up = 0,
				sprint = 0,
				reload = 0,
				reloadT = 0,
				kick = 0,
				kickYaw = 0,
				flashT = 0,
				flashOn = false,
				shotT = 0,
				shotAt = Vector3.new(0, 0, 0),
				throwT = 0,
				wasThrowing = false,
				seed = math.random() * 10,
				swayK = 1,
				swayRate = 0.6,
				strideK = 1,
				bobK = 1,
				carry = 0,
				breathRate = 1.7,
				headYaw = 0,
				gestureT = 0,
				gestureKind = 0,
				pending = 0,
				dying = nil,
				deathDir = Vector3.new(0, 0, 1),
				deathCF = nil
			}

			setMarker(v8, textColor, flag)

			result:GetPropertyChangedSignal("Parent"):Connect(function()
				if v8.destroyed then
					return
				end

				local parent = propHome(result) -- inferred equivalent call

				if v8.rifle.model.Parent ~= parent then
					v8.rifle.model.Parent = parent
				end

				local launcher = v8.launcher

				if launcher and v8.rocketShown and launcher.model.Parent ~= parent then
					launcher.model.Parent = parent
				end
			end)
			debug.profileend()
			return v8
		end

		warn("[BotView] avatar is missing R15 joints; it cannot be posed")
		result:Destroy()
		debug.profileend()
		return nil
	end

	warn("[BotView] avatar is missing its Humanoid, root or UpperTorso")
	result:Destroy()
	debug.profileend()
	return nil
end

function BotRig.setLook(p, textColor: Color3, flag: boolean)
	setMarker(p, textColor, flag)
end

function BotRig:setStyle(p: number, p2: number)
	local random = Random.new(p)
	self.seed = random:NextNumber() * 10
	self.swayK = random:NextNumber(0.5, 1.6) * (1 - p2 * 0.25)
	self.swayRate = random:NextNumber(0.4, 0.9)
	self.strideK = random:NextNumber(0.9, 1.12)
	self.bobK = random:NextNumber(0.7, 1.35) * (p2 * 0.15 + 1)
	self.carry = random:NextNumber(-0.12, 0.12)
	self.breathRate = random:NextNumber(1.4, 2.1)
end

local function approach(p: number, p2: number, p3: number, p4: number)
	return p + (p2 - p) * (1 - math.exp(-p3 * p4))
end

local function smooth(value: number) -- 3 equivalent calls inferred from this helper
	local v7 = math.clamp(value, 0, 1)
	return v7 * v7 * (3 - v7 * 2)
end

@native function BotRig:update(vector3: Vector3, p: number, value: number, p2: number, p3: number, p4: number, vector3_2: Vector3, p5: number, flag: boolean, value2: number)
	if self.dying then
		return
	end

	local v7 = math.cos(p)
	local v8 = math.sin(p)
	local cframe2 = CFrame.new(vector3.X, vector3.Y + 3.2 - p2 * 1.3, vector3.Z, v7, 0, v8, 0, 1, 0, -v8, 0, v7)

	self.rootCF = cframe2
	self.pending += p5

	if not flag then
		return
	end

	local v9 = math.min(self.pending, 0.1)
	self.pending = 0

	if v9 <= 0 then
		return
	end

	local rotation = cframe2.Rotation
	local v10 = math.clamp(value, -1.35, 1.35)

	local wasAir = btest(p4, 1)
	local rocketShown = btest(p4, 8)
	local v11 = btest(p4, 4) and not rocketShown
	local wasThrowing = btest(p4, 16)
	local v12 = btest(p4, 2)
	local v13 = btest(p4, 32) and not v11
	local now = os.clock()

	local vectorToObjectSpace = rotation:VectorToObjectSpace(vector3_2)
	local vel = self.vel
	local lerped = vel:Lerp(Vector3.new(vectorToObjectSpace.X, 0, vectorToObjectSpace.Z), 1 - math.exp(-v9 * 18))
	self.vel = lerped
	local v14 = (lerped - vel) / v9
	local magnitude = lerped.Magnitude

	if magnitude > 0.3 then
		self.dir = lerped / magnitude
	end

	local dir = self.dir

	local v15 = lerped * 0.006 + v14 * 0.0035

	if v15.Magnitude > 0.32 then
		v15 = v15.Unit * 0.32
	end

	local v16 = math.ceil(v9 / 0.02)
	local v17 = v9 / v16
	local tilt = self.tilt
	local tiltV = self.tiltV

	for _ = 1, v16 do
		tiltV += ((v15 - tilt) * 240 - tiltV * 19) * v17
		tilt += tiltV * v17
	end

	self.tilt = tilt
	self.tiltV = tiltV

	if wasAir then
		self.vy = vector3_2.Y
	elseif self.wasAir then
		self.land = math.clamp(-self.vy / 50, 0.35, 1)
	end

	self.wasAir = wasAir
	local air = self.air
	self.air = air + ((wasAir and 1 or 0) - air) * (1 - math.exp(v9 * -16))
	self.land *= math.exp(-v9 * 6)
	local air2 = self.air
	local land = self.land
	local v18 = math.clamp((self.vy + 8) / 30, 0, 1)

	local v19 = (3.5 + magnitude * 0.25) * (1 - p2 * 0.25) * self.strideK
	self.phase = (self.phase + 6.283185307179586 * magnitude / v19 * v9) % 6.283185307179586
	local phase = self.phase
	local v20 = (math.min(magnitude, 16) / 16 * 0.7 + math.clamp((magnitude - 16) / 9, 0, 1) * 0.25) * (1 - math.abs(dir.X) * 0.35) * (1 - p2 * 0.3) * (1 - air2)
	local v21 = 1 - math.clamp(magnitude / 6, 0, 1)

	local v22 = rocketShown and -0.6 or v13 and -0.7 or v12 and -0.15 or self.carry + -0.45
	local twist = self.twist
	self.twist = twist + (v22 - twist) * (1 - math.exp(v9 * -10))
	local v23 = v20 * 0.1 * math.sin(phase)
	local v24 = self.twist * 0.4 * v21 - v23
	local v25 = self.twist - v24

	local v26 = math.cos(v24)
	local v27 = math.sin(v24)
	local v28 = dir.X * v26 - dir.Z * v27
	local v29 = dir.X * v27 + dir.Z * v26
	local vector3_3 = Vector3.new(-v29, 0, v28)
	self.seatLegs = nil

	for i = 1, 2 do
		local v30 = phase + (i == 2 and 3.141592653589793 or 0)
		local v31 = v20 * math.sin(v30)
		local v32 = v20 * (math.max(0, (math.cos(v30))) * 1.5 + 0.2)
		local v41 = (i == 1 and 0.14 or -0.1) * v21 * (1 - air2)
		local v42

		if i == 1 then
			v42 = v18 * 0.5 + 0.25
		else
			v42 = v18 * 0.25 + 0.1
		end

		local v43

		if i == 1 then
			v43 = v18 * 0.8 + 0.45
		else
			v43 = v18 * 0.45 + 0.25
		end

		local v44 = p2 * 1.35 + v41 + air2 * v42 + land * 0.5
		local v45 = p2 * 2.47 + v32 + air2 * v43 + land * 0.95
		local v46 = (v45 - v44 + v31 * v29) * (1 - air2) - air2 * 0.35
		local v47 = (i == 1 and -0.05 or 0.05) * (1 - air2)
		self.hips[i].j.Transform = CFrame.Angles(v44, 0, v47) * CFrame.fromAxisAngle(vector3_3, v31)
		self.knees[i].j.Transform = CFrame.Angles(-v45, 0, 0)
		self.ankles[i].j.Transform = CFrame.Angles(v46, 0, 0)
	end

	local v30 = self.bobK * -0.16 * v20 * math.abs((math.sin(phase))) - land * 0.45
	local v31 = tilt.Z * 0.3
	local transform2 = CFrame.new(0, v30, 0) * CFrame.fromEulerAnglesYXZ(v31, v24, -tilt.X * 0.3)
	self.rootJ.j.Transform = transform2
	local v32 = math.sin(now * self.breathRate + self.seed) * 0.025 * v21
	local v42 = v10 * 0.35 - p2 * 0.2 + tilt.Z * 0.7 + v32 + self.kick * 0.04

	local v43 = self.swayK * 0.035 * v21 * (1 - self.up * 0.6) * math.sin(now * self.swayRate + self.seed * 2.3)
	local cframe3 = CFrame.fromEulerAnglesYXZ(v42, v25 + v43, -p3 * 0.35 - tilt.X * 0.7 + v43 * 0.4)
	self.waist.j.Transform = cframe3

	local headYaw = self.headYaw
	self.headYaw = headYaw + (math.clamp(value2, -1.4, 1.4) - headYaw) * (1 - math.exp(v9 * -7))
	local gestureKind = btest(p4, 64) and 1 or btest(p4, 128) and 2 or 0

	if gestureKind ~= 0 and self.gestureKind ~= gestureKind then
		self.gestureT = now
	end

	self.gestureKind = gestureKind
	local v45 = 0
	local v46 = 0
	local v47 = now - self.gestureT

	if gestureKind ~= 0 and v47 < 1.1 then
		local v48 = math.sin(3.141592653589793 * v47 / 1.1)

		if gestureKind == 1 then
			v45 = v48 * 0.22 * math.sin(v47 * 6.283185307179586 * 2.2)
		else
			v46 = v48 * 0.3 * math.sin(v47 * 6.283185307179586 * 2.6)
		end
	end

	self.neck.j.Transform = CFrame.fromEulerAnglesYXZ(
		v10 - v42 - v31 - v45,
		-self.twist * 0.9 - v43 + self.headYaw + v46,
		p3 * 0.15 + tilt.X
	)

	local cframe4 = cframe2 * self.rootJ.c0 * transform2 * self.rootJ.c1i * self.waist.c0 * cframe3 * self.waist.c1i
	local inverse = cframe4:Inverse()
	local position = cframe4.Position

	local v48 = math.cos(v10)
	local v49 = Vector3.new(-math.sin(p) * v48, math.sin(v10), -math.cos(p) * v48)

	if self.shotT > 0 then
		self.shotT -= v9
		local v50 = self.shotAt - position

		if v50.Magnitude > 2 and v50.Unit:Dot(v49) > 0.6 then
			v49 = v50.Unit
			v13 = true
		end
	end

	local v50 = CFrame.new(position) * rotation

	local up = self.up
	self.up = up + ((v13 and not wasThrowing and 1 or 0) - up) * (1 - math.exp(v9 * -14))
	local sprint = self.sprint
	self.sprint = sprint + ((v12 and not v13 and 1 or 0) - sprint) * (1 - math.exp(v9 * -10))
	local reload = self.reload
	self.reload = reload + ((v11 and 1 or 0) - reload) * (1 - math.exp(v9 * -10))

	if rocketShown ~= self.rocketShown then
		self.rocketShown = rocketShown
		local launcher = self.launcher

		if rocketShown and not launcher then
			local launcherSpec = self.launcherSpec or v
			local upper = self.upper
			local v52 = v5[launcherSpec.tool]
			launcher = v52 and table.remove(v52)

			if launcher then
				launcher.motor.Part0 = upper
			else
				launcher = mountProp(launcherSpec, upper)
			end

			self.launcher = launcher
		end

		if launcher then
			showProp(launcher, rocketShown, self.model) -- inferred equivalent call
		end
	end

	local rifle = self.rifle
	local v51 = if rocketShown then self.launcher else rifle

	local cframe5 = CFrame.lookAlong(v50 * v51.hold.pivot, v49) * v51.hold.up

	if rocketShown then
		rifle.motor.Transform = transform
	else
		local v52 = low2

		if self.sprint > 0.001 then
			v52 = v52:Lerp(sprint2, self.sprint)
		end

		if self.reload > 0.001 then
			v52 = v52:Lerp(reload2, self.reload)
		end

		cframe5 = (v50 * v52):Lerp(cframe5, self.up)
	end

	local kick = self.kick

	if kick > 0 then
		self.kick = math.max(0, kick - v9 * 9)
		cframe5 *= CFrame.new(0, kick * 0.03, kick * 0.24) * CFrame.Angles(kick * 0.09, self.kickYaw * kick, 0)
	end

	local hold = v51.hold
	local transform3 = inverse * cframe5

	local arm = self.arms[2]
	local v53 = (transform3 * hold.left - arm.shoulder.c0.Position).Magnitude - (arm.upperLen + arm.lowerLen - 0.02)

	if v53 > 0 then
		transform3 *= CFrame.new(0, 0, (math.min(v53 * 1.3, 0.6)))
	end

	v51.motor.Transform = transform3

	local v54 = transform3 * hold.right
	local v55 = transform3 * hold.left

	if self.reload > 0.01 then
		self.reloadT += v9
		local v56 = 0.5 - math.cos(self.reloadT * 6.283185307179586 / 1.6) * 0.5
		local v57 = inverse * (v50 * Vector3.new(-0.45, -1, -0.55))
		v55 = v55:Lerp((transform3 * (hold.mag or Vector3.new(0, -0.5, -0.28))):Lerp(v57, v56), self.reload)
	else
		self.reloadT = 0
	end

	if wasThrowing and not self.wasThrowing and self.throwT == 0 then
		self.throwT = now
	end

	self.wasThrowing = wasThrowing

	if self.throwT > 0 then
		local v56 = (now - self.throwT) / 0.65

		if v56 >= 1 then
			self.throwT = 0
		else
			local v57 = inverse * (v50 * Vector3.new(0.9, 1.5, 0.9))
			local v58 = inverse * (v50 * Vector3.new(0.35, 1.2, -1.8))

			if v56 < 0.4 then
				v54 = v54:Lerp(v57, smooth(v56 / 0.4)) -- inferred equivalent call
			elseif v56 < 0.6 then
				v54 = v57:Lerp(v58, smooth((v56 - 0.4) / 0.2)) -- inferred equivalent call
			else
				v54 = v58:Lerp(v54, smooth((v56 - 0.6) / 0.4)) -- inferred equivalent call
			end
		end
	end

	solveArm(self.arms[1], v54, Vector3.new(1, -0.6, 0.35))
	solveArm(self.arms[2], v55, Vector3.new(-0.5, -1, 0.2))

	if self.flashT > 0 then
		self.flashT -= v9
	end

	local flashOn

	if self.flashT > 0 then
		flashOn = not rocketShown
	else
		flashOn = false
	end

	if flashOn ~= self.flashOn then
		self.flashOn = flashOn

		for _, v57 in rifle.flash do
			v57.Transparency = flashOn and 0 or 1
		end

		flashLight(rifle, flashOn) -- inferred equivalent call
	end
end

function BotRig:fired(shotAt: Vector3, value: number?)
	self.kick = value or 1
	self.kickYaw = (math.random() - 0.5) * 0.06
	self.flashT = 0.05
	self.shotT = 0.18
	self.shotAt = shotAt
	self.up = math.max(self.up, 0.85)
end

function BotRig:throw()
	if self.throwT == 0 then
		self.throwT = os.clock()
	end
end

function BotRig:setAA(flag: boolean)
	local launcherSpec

	if flag then
		launcherSpec = BotRig.SPECS.AALauncher
	else
		launcherSpec = BotRig.SPECS.RocketLauncher
	end

	self.launcherSpec = launcherSpec
	local launcher = self.launcher

	if launcher and launcher.spec ~= launcherSpec then
		giveProp(launcher)
		self.launcher = nil

		if self.rocketShown then
			local launcher2 = takeProp(launcherSpec, self.upper) -- inferred equivalent call
			self.launcher = launcher2
			showProp(launcher2, true, self.model) -- inferred equivalent call
		end
	end
end

function BotRig:setGun(p: string)
	local spec = v2[p]
	assert(spec, "[BotRig] no prop for the bot gun " .. tostring(p))
	local rifle = self.rifle

	if rifle.spec == spec then
		return
	end

	local rifle2 = takeProp(spec, self.upper) -- inferred equivalent call

	if self.rifle ~= rifle or self.destroyed then
		giveProp(rifle2)
		return
	end

	rifle2.motor.Transform = rifle.motor.Transform
	local model = rifle2.model
	model.Parent = propHome(self.model) -- inferred equivalent call
	self.rifle = rifle2
	self.flashOn = false
	giveProp(rifle)
end

function BotRig:updateFlash(flag: boolean?)
	local flashOn

	if self.flashT - self.pending > 0 then
		flashOn = not self.rocketShown

		if flashOn then
			local low = flag and Detail.low
			flashOn = not low
		end
	else
		flashOn = false
	end

	if flashOn ~= self.flashOn then
		self.flashOn = flashOn

		for _, v7 in self.rifle.flash do
			v7.Transparency = flashOn and 0 or 1
		end

		flashLight(self.rifle, flashOn) -- inferred equivalent call
	end
end

local v7 = CFrame.new(0.15, -0.55, -0.75) * CFrame.Angles(-0.15, 1.15, 0.15)

local function seatRoot(state, cframe2: CFrame?) -- 2 equivalent calls inferred from this helper
	if cframe2 and cframe2 ~= state.written then
		state.root.CFrame = cframe2
		state.written = cframe2
	end

	state.vel = Vector3.new(0, 0, 0)
	state.tilt = Vector3.new(0, 0, 0)
	state.tiltV = Vector3.new(0, 0, 0)
	state.air = 0
	state.land = 0

	if state.rocketShown then
		state.rocketShown = false
		local launcher = state.launcher
		local _model = state.model

		if launcher.model.Parent ~= nil then
			launcher.model.Parent = nil
		end
	end
end

function BotRig:seat(cframe2: CFrame, driving: boolean, value: number, vector3: Vector3, p: number)
	if self.dying then
		return
	end

	seatRoot(self, cframe2) -- inferred equivalent call
	local v8 = math.clamp(p + self.pending, 0, 0.1)
	local flag = not self.seatLegs

	if not self.seatLegs then
		self.seatLegs = true

		for i = 1, 2 do
			self.hips[i].j.Transform = CFrame.Angles(1.45, 0, i == 1 and -0.08 or 0.08)
			self.knees[i].j.Transform = CFrame.Angles(-1.5, 0, 0)
			self.ankles[i].j.Transform = CFrame.Angles(0.15, 0, 0)
		end
	end

	local vectorToObjectSpace = cframe2:VectorToObjectSpace(vector3)
	local vector3_2 = Vector3.new(
		math.clamp(-vectorToObjectSpace.X * 0.004, -0.12, 0.12),
		0,
		(math.clamp(vectorToObjectSpace.Z * 0.004, -0.12, 0.12))
	)
	local twist = self.twist
	self.twist = twist + (0 - twist) * (1 - math.exp(v8 * -6))
	local headYaw = self.headYaw
	self.headYaw = headYaw + (math.clamp(value, -1.3, 1.3) - headYaw) * (1 - math.exp(v8 * -4))

	local seatWrote = self.seatWrote

	if
		flag
		or not seatWrote
		or seatWrote.driving ~= driving
		or seatWrote.rifle ~= self.rifle
		or math.abs(seatWrote.x - vector3_2.X) > 0.004
		or math.abs(seatWrote.z - vector3_2.Z) > 0.004
		or math.abs(seatWrote.yaw - self.headYaw) > 0.004
	then
		if not seatWrote then
			seatWrote = {}
			self.seatWrote = seatWrote
		end

		local rifle = self.rifle
		local x = vector3_2.X
		local z = vector3_2.Z
		local headYaw2 = self.headYaw
		seatWrote.driving = driving
		seatWrote.rifle = rifle
		seatWrote.x = x
		seatWrote.z = z
		seatWrote.yaw = headYaw2
		local cframe3 = CFrame.new()
		self.rootJ.j.Transform = cframe3
		local cframe4 = CFrame.fromEulerAnglesYXZ(vector3_2.Z - 0.05, 0, vector3_2.X)
		self.waist.j.Transform = cframe4
		self.neck.j.Transform = CFrame.fromEulerAnglesYXZ(-vector3_2.Z + 0.05, self.headYaw, -vector3_2.X * 0.5)
		local cframe5 = cframe2 * self.rootJ.c0 * cframe3 * self.rootJ.c1i * self.waist.c0 * cframe4 * self.waist.c1i
		local inverse = cframe5:Inverse()
		local rifle2 = self.rifle
		local v9, v10

		if driving then
			rifle2.motor.Transform = transform
			v9 = inverse * cframe2:PointToWorldSpace(Vector3.new(0.5, 0.35, -1.55))
			v10 = inverse * cframe2:PointToWorldSpace(Vector3.new(-0.55, 0.4, -1.55))
		else
			local transform2 = inverse * (CFrame.new(cframe5.Position) * cframe2.Rotation * v7)
			rifle2.motor.Transform = transform2
			v9 = transform2 * rifle2.hold.right
			v10 = transform2 * rifle2.hold.left
		end

		solveArm(self.arms[1], v9, Vector3.new(1, -0.6, 0.35))
		solveArm(self.arms[2], v10, Vector3.new(-0.5, -1, 0.2))
	end

	self.pending = 0
	self.shotT = 0

	if self.flashT > 0 then
		self.flashT -= v8
	end

	BotRig.updateFlash(self)
end

function BotRig:seatHidden(cframe2: CFrame?, p: number)
	if self.dying then
		return
	end

	seatRoot(self, cframe2) -- inferred equivalent call
	self.shotT = 0
	self.pending += p
	BotRig.updateFlash(self, true)
end

function BotRig.muzzlePos(data)
	if data.teamHidden then
		return data.root.CFrame * Vector3.new(0.5, 0.8, -1.8)
	end

	local v8 = if data.rocketShown then data.launcher else data.rifle
	return v8.muzzle.WorldPosition
end

function BotRig:die(vector3: Vector3?)
	self.dying = os.clock()
	self.deathDir = vector3 or -self.root.CFrame.LookVector
	self.deathCF = self.root.CFrame
	self.flashT = 0
	self.kick = 0
	self.fallLanded = false
	self.dropFrom = nil
	self.dropTo = nil
	self.dropT0 = nil

	if self.flashOn then
		self.flashOn = false

		for _, v8 in self.rifle.flash do
			v8.Transparency = 1
		end

		if self.rifle.light then
			setFlashLight(self.rifle.light, false)
		end
	end
end

function BotRig:redirect(deathDir: Vector3)
	self.deathDir = deathDir
end

local function dropNow(data) -- 2 equivalent calls inferred from this helper
	local dropTo = data.dropTo
	local dropT0 = data.dropT0

	if dropTo and dropT0 then
		local v8 = os.clock() - dropT0
		return (math.min(dropTo, (data.dropFrom or 0) + 70 * v8 * v8))
	end

	return 0
end

function BotRig:settle(p: number)
	local deathCF = self.deathCF

	if not deathCF then
		return
	end

	local dropTo = deathCF.Position.Y - 3.2 - p
	local dropFrom = dropNow(self) -- inferred equivalent call

	if dropTo <= dropFrom + 0.4 then
		return
	end

	local now = os.clock()
	self.dropFrom = dropFrom
	self.dropTo = dropTo
	self.dropT0 = now
	self.fallLanded = false
end

function BotRig:fall(p: number, p2, p3, position: Vector3?)
	local dying = self.dying
	local deathCF = self.deathCF

	if not (dying and deathCF) then
		return
	end

	local v8 = math.clamp((os.clock() - dying) / 0.55, 0, 1)
	local v9 = v8 * v8
	local v10 = deathCF.Position - Vector3.new(0, 3.2, 0)
	local cross = (Vector3.new(0, 1, 0)):Cross(self.deathDir)
	local v11 = not (cross.Magnitude > 0.001) and Vector3.new(1, 0, 0) or cross.Unit
	local cframe2 = CFrame.fromAxisAngle(v11, v9 * 1.53588974175501)
	local cframe3 = CFrame.new(v10)
	local objectSpace = cframe3:ToObjectSpace(deathCF)
	local v12 = dropNow(self) -- inferred equivalent call
	self.rootCF = CFrame.new(0, p * -2.5 - v12, 0) * cframe3 * cframe2 * objectSpace * CFrame.new(0, v9 * -0.9, 0)

	if position then
		self.rootCF = CFrame.new(position) * self.rootCF
	end

	BotRig.queueRoot(self, p2, p3)

	if self.fallLanded then
		return
	end

	self.fallLanded = v8 >= 1 and (self.dropTo or 0) <= v12
	self.seatLegs = nil

	for i = 1, 2 do
		self.knees[i].j.Transform = CFrame.Angles(v9 * -0.6108652381980153, 0, 0)
		self.hips[i].j.Transform = CFrame.Angles(v9 * 0.3490658503988659, 0, 0)
	end

	self.waist.j.Transform = CFrame.Angles(v9 * -0.35, 0, 0)
end

function BotRig:revive()
	self.dying = nil
	self.rootCF = nil
	self.written = nil
	self.deathCF = nil
	self.vel = Vector3.new(0, 0, 0)
	self.tilt = Vector3.new(0, 0, 0)
	self.tiltV = Vector3.new(0, 0, 0)
	self.air = 0
	self.wasAir = false
	self.vy = 0
	self.land = 0
	self.kick = 0
	self.shotT = 0
	self.throwT = 0
	self.reloadT = 0
	self.pending = 0
	self.fallLanded = nil
	self.dropFrom = nil
	self.dropTo = nil
	self.dropT0 = nil
	self.seatLegs = nil
end

function BotRig:lod(vector3: Vector3)
	if self.dying then
		return
	end

	local tier = Detail.tier(vector3, 6, self.lodTier)
	self.lodTier = tier
	local low = Detail.low

	local v8 = not low and tier <= 1

	if v8 ~= self.shadowOn then
		self.shadowOn = v8

		for _, v9 in self.body do
			v9.CastShadow = v8
		end

		for _, v9 in self.acc do
			v9.CastShadow = v8
		end
	end

	local accHidden = (low and 2 or 3) <= tier

	if accHidden ~= self.accHidden and not self.teamHidden then
		self.accHidden = accHidden
		local localTransparencyModifier = accHidden and 1 or 0

		for _, v9 in self.acc do
			v9.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

function BotRig:teamHideStep()
	local hideQueue = self.hideQueue

	if not hideQueue then
		return
	end

	local model = self.model
	local parent = v4[model]

	for _ = 1, 12 do
		local v8 = table.remove(hideQueue)

		if not v8 then
			break
		end

		local v9

		if v8.Parent == model then
			v9 = true
		elseif v8.Parent == botGuns then
			if v8 == self.rifle.model then
				v9 = true
			elseif self.launcher == nil then
				v9 = false
			else
				v9 = v8 == self.launcher.model
			end
		else
			v9 = false
		end

		if v9 then
			v8.Parent = parent
		end
	end

	if #hideQueue == 0 then
		self.hideQueue = nil
	end
end

function BotRig:teamHide(teamHidden: boolean)
	if (self.teamHidden == true) == teamHidden then
		return
	end

	self.teamHidden = teamHidden

	local model = self.model
	local marker = self.marker

	if teamHidden then
		v4[model] = Instance.new("Folder")
		local hideQueue = {}

		for _, child in model:GetChildren() do
			if not (child ~= self.root and (child:IsA("BasePart") or child:IsA("Accessory"))) then
				continue
			end

			table.insert(hideQueue, child)
		end

		for _, v8 in { self.rifle, self.launcher } do
			if v8 and v8.model.Parent == botGuns then
				table.insert(hideQueue, v8.model)
			end
		end

		self.hideQueue = hideQueue
		BotRig.teamHideStep(self)

		if marker then
			marker.Adornee = self.root
			marker.StudsOffset = Vector3.new(0, 5, 0)
		end
	else
		self.hideQueue = nil
		local v8 = v4[model]
		v4[model] = nil
		local v9 = propHome(model) -- inferred equivalent call

		for _, child in v8:GetChildren() do
			local v10

			if child == self.rifle.model then
				v10 = true
			elseif self.launcher == nil then
				v10 = false
			else
				v10 = child == self.launcher.model
			end

			local parent = if v10 then v9 else model
			child.Parent = parent
		end

		v8:Destroy()

		if marker then
			marker.Adornee = model:FindFirstChild("Head")
			marker.StudsOffset = Vector3.new(0, 3.4, 0)
		end
	end
end

function BotRig:park()
	self.root.CFrame = cframe
	self.written = nil
end

function BotRig:queueRoot(roots, rootCFs)
	local rootCF = self.rootCF

	if rootCF and rootCF ~= self.written then
		self.written = rootCF
		table.insert(roots, self.root)
		table.insert(rootCFs, rootCF)
	end
end

function BotRig:destroy()
	assert(not self.destroyed, "[BotRig] rig destroyed twice")
	BotRig.teamHide(self, false)
	self.destroyed = true

	giveProp(self.rifle)

	if self.launcher then
		giveProp(self.launcher)
		self.launcher = nil
	end

	self.model:Destroy()
end

BotRig.SPECS = {}

for _, v8 in v2 do
	BotRig.SPECS[v8.tool] = v8
end

BotRig.SPECS[v.tool] = v
local clone = table.clone(v)
clone.tool = "AALauncher"
BotRig.SPECS[clone.tool] = clone
BotRig.POSES = {
	low = low2,
	sprint = sprint2,
	reload = reload2,
	mag = Vector3.new(0, -0.5, -0.28),
	pouch = Vector3.new(-0.45, -1, -0.55),
	rightPole = Vector3.new(1, -0.6, 0.35),
	leftPole = Vector3.new(-0.5, -1, 0.2)
}
BotRig.findJoint = findJoint
BotRig.makeArm = makeArm
BotRig.solveArm = solveArm

return BotRig