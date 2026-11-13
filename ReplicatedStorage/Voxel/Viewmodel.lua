local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local Movement = require(script.Parent:WaitForChild("Movement"))
local LookSettings = require(script.Parent:WaitForChild("LookSettings"))
local Detail = require(script.Parent:WaitForChild("Detail"))
local MenuLock = require(script.Parent:WaitForChild("MenuLock"))
local Keyframes = require(script.Parent:WaitForChild("Keyframes"))
local GearSound = require(script.Parent:WaitForChild("GearSound"))
local VR = require(script.Parent:WaitForChild("VR"))
local CaseDrop = require(script.Parent:WaitForChild("CaseDrop"))

local v = { "UpperArm", "LowerArm", "Hand" }

local v2 = Vector2.new(1, 0.77) * 0.008726646259971648 * 0.6
local v3 = Vector2.new(1, 0.77) * 0.06981317007977318 * 60

local function stickCurve(p: number) -- 2 equivalent calls inferred from this helper
	local v4 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v4, 0, 1)
end

local function rightStick()
	if not UserInputService.GamepadEnabled or MenuLock.held then
		return Vector2.zero
	end

	for _, v4 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
		if v4.KeyCode == Enum.KeyCode.Thumbstick2 then
			return Vector2.new(stickCurve(v4.Position.X), -stickCurve(v4.Position.Y)) -- inferred equivalent call
		end
	end

	return Vector2.zero
end

local function wrapAngle(p: number) -- 2 equivalent calls inferred from this helper
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

local v4 = 0.4

local v5 = v4

local function zoomedFov(p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function aimTimeFor(p: number)
	if p < 1 then
		return 0.24 - (1 - p) * 0.23
	end

	return (p - 1) * 0.4 + 0.24
end

local _ = {
	yaw = 0.012,
	pitch = 0.009,
	roll = 0.03,
	maxRot = 0.12,
	zeta = 0.5,
	strafeSlide = 0.005,
	strafeRoll = 0.006,
	moveFollow = 9,
	aimKeep = 0.3,
	aimRoll = 0.15
}

local color = Color3.fromRGB(38, 36, 42)

local color2 = Color3.fromRGB(255, 214, 140)
local color3 = Color3.fromRGB(196, 158, 84)

local cframe = CFrame.new(0, 10000, 0)

local v6 = {
	{ 0, Vector3.new(0, -0.17, 0) },
	{ 0.25, Vector3.new(0.45, 0.2, 0) },
	{ 0.5, Vector3.new(0, -0.17, 0) },
	{ 0.75, Vector3.new(-0.45, 0.12, 0) },
	{ 1, Vector3.new(0, -0.17, 0) }
}

local v7 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.25, Vector3.new(6, 16, -4) },
	{ 0.5, Vector3.new(0, 0, 0) },
	{ 0.75, Vector3.new(-6, -16, 4) },
	{ 1, Vector3.new(0, 0, 0) }
}

local v8 = {
	{ 0, Vector3.new(0, -0.035, 0) },
	{ 0.25, Vector3.new(0.07, 0.02, 0) },
	{ 0.5, Vector3.new(0, -0.035, 0) },
	{ 0.75, Vector3.new(-0.07, 0.015, 0) },
	{ 1, Vector3.new(0, -0.035, 0) }
}

local v9 = {
	{ 0, Vector3.new(0, 0, 0) },
	{ 0.25, Vector3.new(1, 2, -1.5) },
	{ 0.5, Vector3.new(0, 0, 0) },
	{ 0.75, Vector3.new(-1, -2, 1.5) },
	{ 1, Vector3.new(0, 0, 0) }
}

local v10 = {
	{ 0, 0, 9 },
	{ 0.28, 1, true },
	{ 0.45, 0.95 },
	{ 1, 0, true }
}

local v11 = {
	{ 0, 0, 8 },
	{ 0.22, 1, true },
	{ 0.45, 0.75 },
	{ 1, 0, true }
}

local v12 = {
	{ 0, Vector3.new(0.2, -1.3, 0.4) },
	{ 0.7, Vector3.new(0, 0.04, 0) },
	{ 1, Vector3.new(0, 0, 0), true }
}
local v13 = {
	{ 0, Vector3.new(-45, 15, 20) },
	{ 0.7, Vector3.new(2, -1, -1) },
	{ 1, Vector3.new(0, 0, 0), true }
}

local function follow(state, p: number, p2: number, p3: number, p4: number)
	if state.x == p and state.v == 0 then
		return
	end

	local v14 = math.max(1, (math.ceil(p4 * 240)))
	local v15 = p4 / v14

	for _ = 1, v14 do
		state.v += (p2 * p2 * (p - state.x) - p3 * 2 * p2 * state.v) * v15
		state.x += state.v * v15
	end

	if math.abs(state.x - p) < 0.00001 and math.abs(state.v) < 0.0001 then
		state.x = p
		state.v = 0
	end
end

local function follow3(state, vector3: Vector3, p: number, p2: number, p3: number)
	if state.x == vector3 and state.v == Vector3.new(0, 0, 0) then
		return
	end

	local v14 = math.max(1, (math.ceil(p3 * 240)))
	local v15 = p3 / v14

	for _ = 1, v14 do
		state.v += ((vector3 - state.x) * (p * p) - state.v * (p2 * 2 * p)) * v15
		state.x += state.v * v15
	end

	if (state.x - vector3).Magnitude < 0.00001 and state.v.Magnitude < 0.0001 then
		state.x = vector3
		state.v = Vector3.new(0, 0, 0)
	end
end

local function degrees(vector3: Vector3) -- 3 equivalent calls inferred from this helper
	return CFrame.fromOrientation(math.rad(vector3.X), math.rad(vector3.Y), (math.rad(vector3.Z)))
end

local function stepSpring(state, p: number)
	if state.x == Vector3.new(0, 0, 0) and state.v == Vector3.new(0, 0, 0) then
		return
	end

	local v14 = math.max(1, (math.ceil(p * 240)))
	local v15 = p / v14

	for _ = 1, v14 do
		state.v += (state.x * -170 - state.v * 21) * v15
		state.x += state.v * v15
	end

	if state.x.Magnitude < 0.00001 and state.v.Magnitude < 0.0001 then
		state.x = Vector3.new(0, 0, 0)
		state.v = Vector3.new(0, 0, 0)
	end
end

local function smooth(value: number) -- 5 equivalent calls inferred from this helper
	local v14 = math.clamp(value, 0, 1)
	return v14 * v14 * (3 - v14 * 2)
end

local function easeOut3(value: number)
	local v14 = 1 - math.clamp(value, 0, 1)
	return 1 - v14 * v14 * v14
end

local function prepare(instance)
	instance.Anchored = true
	instance.CanCollide = false
	instance.CanQuery = false
	instance.CanTouch = false
	instance.CastShadow = false
	instance.Massless = true
	instance.LocalTransparencyModifier = 0
	instance.Size *= v4

	if instance.MaterialVariant ~= "" and v4 < 1 then
		local materialVariant = instance.MaterialVariant .. "View"
		local MaterialService = game:GetService("MaterialService")

		if MaterialService:FindFirstChild(materialVariant) then
			instance.MaterialVariant = materialVariant
		end
	end

	for _, child in instance:GetChildren() do
		if child:IsA("SurfaceAppearance") or child:IsA("DataModelMesh") or child:IsA("Decal") then
			continue
		end

		child:Destroy()
	end
end

local function scaled(cframe2: CFrame) -- 14 equivalent calls inferred from this helper
	return CFrame.new(cframe2.Position * v4) * cframe2.Rotation
end

local function solveArm(vector3: Vector3, vector3_2: Vector3, vector: Vector3, y: number, y2: number, y3: number)
	local v14 = (y + y2) * 0.98
	local v15 = vector3_2 - vector3

	if v14 < v15.Magnitude then
		vector3 = vector3_2 - v15.Unit * v14
		v15 = vector3_2 - vector3
	end

	local v16 = math.max(v15.Magnitude, 0.001)
	local v17 = v15 / v16
	local v18 = math.clamp((y * y + v16 * v16 - y2 * y2) / (y * 2 * v16), -1, 1)
	local v19 = vector - v17 * vector:Dot(v17)
	local v20 = not (v19.Magnitude > 0.0001) and Vector3.new(0, 1, 0) or v19.Unit
	local v21 = vector3 + v17 * (v18 * y) + v20 * (math.sqrt(1 - v18 * v18) * y)

	local function bone(vector3_3: Vector3, vector3_4: Vector3) -- 2 equivalent calls inferred from this helper
		local unit = (vector3_3 - vector3_4).Unit
		local cross = unit:Cross(v20)
		local v22 = not (cross.Magnitude > 0.0001) and Vector3.new(1, 0, 0) or cross.Unit
		return CFrame.fromMatrix((vector3_3 + vector3_4) * 0.5, v22, unit)
	end

	local unit = (vector3_2 - v21).Unit
	return bone(vector3, v21), bone(v21, vector3_2), bone(vector3_2, vector3_2 + unit * y3) -- inferred equivalent call
end

local function buildHud()
	local weaponHud = Instance.new("ScreenGui")
	weaponHud.Name = "WeaponHud"
	weaponHud.IgnoreGuiInset = true
	weaponHud.ScreenInsets = Enum.ScreenInsets.None
	weaponHud.ResetOnSpawn = false
	weaponHud.DisplayOrder = 5

	local crosshair = Instance.new("Frame")
	crosshair.Name = "Crosshair"
	crosshair.BackgroundTransparency = 1
	crosshair.Size = UDim2.fromScale(1, 1)
	crosshair.Parent = weaponHud
	local function tick(p: number, p2: number, p3: number, p4: number)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, p, 0.5, p2)
		frame.Size = UDim2.fromOffset(p3, p4)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BorderSizePixel = 0
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Transparency = 0.55
		uiStroke.Parent = frame
		frame.Parent = crosshair
		return frame
	end

	tick(0, 0, 2, 2)
	local ticks = { tick(-12, 0, 8, 2), tick(12, 0, 8, 2), tick(0, -12, 2, 8), tick(0, 12, 2, 8) }

	local aimVignette = Instance.new("ScreenGui")
	aimVignette.Name = "AimVignette"
	aimVignette.IgnoreGuiInset = true
	aimVignette.ScreenInsets = Enum.ScreenInsets.None
	aimVignette.ResetOnSpawn = false
	aimVignette.DisplayOrder = -10
	aimVignette.Enabled = false
	local numberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.18, 0.45),
		NumberSequenceKeypoint.new(0.38, 0.85),
		NumberSequenceKeypoint.new(0.55, 1),
		NumberSequenceKeypoint.new(1, 1)
	})

	local function band(anchorPoint: Vector2, udim: UDim2, rotation: number)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = anchorPoint
		frame.Position = UDim2.fromScale(anchorPoint.X, anchorPoint.Y)
		frame.Size = udim
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Active = false
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = numberSequence
		uiGradient.Rotation = rotation
		uiGradient.Parent = frame
		frame.Parent = aimVignette
		return frame
	end

	local udim = UDim2.fromScale(0.3, 0.42)
	return {
		gui = weaponHud,
		crosshair = crosshair,
		ticks = ticks,
		vignetteGui = aimVignette,
		vignette = {
			band(Vector2.new(0, 0), udim, 45),
			band(Vector2.new(1, 0), udim, 135),
			band(Vector2.new(1, 1), udim, 225),
			band(Vector2.new(0, 1), udim, 315)
		}
	}
end

local Viewmodel = {}
Viewmodel.VIEW_SCALE = v4
Viewmodel.SNAP_RECOIL = {
	{ 0, 0, 40 },
	{ 0.05, 1, true },
	{ 0.2, 0.55 },
	{ 1, 0, true }
}

Viewmodel.__index = Viewmodel

Viewmodel.current = nil

Viewmodel.hands = nil

Viewmodel.touchMode = false

Viewmodel.padMode = false

Viewmodel.stickScale = 1
Viewmodel.stickInput = Vector2.zero

Viewmodel.TOUCH_EASE = {}
function Viewmodel.hipSpread(value: number)
	if not Viewmodel.touchMode then
		return 1
	end

	local current = Viewmodel.current
	local v14 = current and Viewmodel.TOUCH_EASE[current.tool.Name] or 1
	return (math.clamp(value, 0, 1) * 0.050000000000000044 + 0.75) * v14
end

Viewmodel.HIP_BLOOM_CUT = {
	AssaultRifle = 0.35,
	K433 = 0.35,
	GX36 = 0.35,
	SK556 = 0.35,
	RN545 = 0.5,
	MX65 = 0.5,
	BT762 = 0.5,
	LMG = 0.4,
	MG60 = 0.4,
	BX110 = 0.4,
	HX83 = 0.4,
	KT8 = 0.4,
	NX68 = 0.4,
	GR240 = 0.4,
	SMG = 0.3,
	KP50 = 0.3,
	HM45 = 0.3,
	TK17 = 0.3,
	SP44 = 0.3,
	PD46 = 0.3
}

function Viewmodel.hipBloom(value: number)
	local current = Viewmodel.current
	return 1 - (current and Viewmodel.HIP_BLOOM_CUT[current.tool.Name] or 0) * (1 - math.clamp(value, 0, 1))
end

local v14 = { Sniper = true, RX10 = true, SC11 = true, VX50 = true }
function Viewmodel.padKick(p: string)
	if Viewmodel.padMode and not v14[p] then
		return 0.7 * (Viewmodel.TOUCH_EASE[p] or 1)
	end

	return 1
end

local v15 = {}
local count = 0

local object = setmetatable({}, { __mode = "k" })

function Viewmodel.new(instance, spec)
	local object2 = setmetatable({
		tool = instance,
		spec = spec,
		active = false,
		model = nil,
		parts = {},
		hud = nil,
		muzzleWorld = Vector3.new(0, 0, 0),
		pos = { x = Vector3.new(0, 0, 0), v = Vector3.new(0, 0, 0) },
		rot = { x = Vector3.new(0, 0, 0), v = Vector3.new(0, 0, 0) },
		aiming = false,
		aimBlocked = false,
		aimAlpha = 0,
		zoomAlpha = 0,
		scopeCovered = false,
		scopeRing = Vector3.new(0, 0, 0),
		opening = nil,
		pose = CFrame.identity,
		leftWeight = 0,
		leftTarget = Vector3.new(0, 0, 0),
		leftOnAmmo = 0,
		leftGun = nil,
		shots = {},
		ammoGrab = Vector3.new(0, 0, 0),
		ammoVisible = true,
		ammoDelta = CFrame.identity,
		pinDelta = CFrame.identity,
		pinVisible = true,
		reloadProgress = nil,
		firing = false,
		slideLocked = false,
		slideHold = nil,
		rightGun = nil,
		rightWeight = 0,
		holdView = CFrame.identity,
		ammoShown = {},
		sprintAlpha = 0,
		sprintHoldUntil = 0,
		restore = nil,
		fx = nil,
		bindings = nil,
		rightReachTo = nil,
		rightReach = 0,
		leftReachTo = nil,
		leftReach = 0,
		rightPole = nil,
		leftPole = nil,
		guis = {},
		recoilPitch = 0,
		recoilYaw = 0,
		recoilRoll = 0
	}, Viewmodel)

	instance.Equipped:Connect(function()
		debug.profilebegin("VM.start")
		object2:start()
		debug.profileend()
	end)
	instance.Unequipped:Connect(function()
		debug.profilebegin("VM.stop")
		object2:stop()
		debug.profileend()
	end)
	instance.AncestryChanged:Connect(function()
		if object2.active and not instance:IsDescendantOf(workspace) then
			object2:stop()
		end
	end)

	task.defer(function()
		object[instance] = true
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not object2.active and character and instance.Parent == character and humanoid and humanoid.Health > 0 then
			humanoid:UnequipTools()
			humanoid:EquipTool(instance)
		end
	end)
	return object2
end

function Viewmodel.scriptReady(p): boolean
	return object[p] == true
end

local function firstPerson() -- 2 equivalent calls inferred from this helper
	local localPlayer = Players.LocalPlayer

	if localPlayer.Team == nil and localPlayer:GetAttribute("PickingTeam") == true then
		return
	end

	localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end

local function partOffset(handle, part)
	for _, jointInstance in part:GetChildren() do
		if not (jointInstance:IsA("JointInstance") and jointInstance.Enabled) then
			continue
		end

		if jointInstance.Part0 == handle and jointInstance.Part1 == part then
			return jointInstance.C0 * jointInstance.C1:Inverse()
		end

		if jointInstance.Part0 == part and jointInstance.Part1 == handle then
			return (jointInstance.C0 * jointInstance.C1:Inverse()):Inverse()
		end
	end

	for _, jointInstance in handle:GetChildren() do
		if
			jointInstance:IsA("JointInstance")
			and jointInstance.Enabled
			and jointInstance.Part0 == handle
			and jointInstance.Part1 == part
		then
			return jointInstance.C0 * jointInstance.C1:Inverse()
		end
	end

	return handle.CFrame:ToObjectSpace(part.CFrame)
end

function Viewmodel:start()
	if self.active then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	assert(character, "view model needs a character")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	assert(humanoid and humanoid.RigType == Enum.HumanoidRigType.R15, "view model needs an R15 character")
	local handle = self.tool:FindFirstChild("Handle")
	assert(handle and handle:IsA("BasePart"), "view model needs a Handle")

	if not self.spec.silentGear then
		GearSound.draw(self.spec)
	end

	local current = Viewmodel.current

	if current and current ~= self then
		current:stop()
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, screenGui in playerGui:GetChildren() do
			local ownerTool = screenGui:IsA("ScreenGui") and screenGui:FindFirstChild("OwnerTool")

			if
				not ownerTool
				or not ownerTool:IsA("ObjectValue")
				or ownerTool.Value and ownerTool.Value:IsDescendantOf(game)
			then
				continue
			end

			screenGui:Destroy()
		end
	end

	count += 1
	local v16 = "VoxelViewmodel" .. count
	local v17 = "VoxelViewmodelTurnMark" .. count
	local v18 = "VoxelViewmodelTurn" .. count
	self.bindings = { v16, v17, v18 }
	self.active = true
	Viewmodel.current = self
	v15[self] = humanoid.Died:Connect(function()
		self:stop()
	end)

	local v19 = VR.on()
	v4 = v19 and 1 or v5
	Viewmodel.VIEW_SCALE = v4
	self.vrAim = nil
	self.vrTwo = false

	local viewModel = Instance.new("Model")
	viewModel.Name = "ViewModel"

	local parts2 = {}
	local v20 = {}
	local v21 = {}
	local v22 = {}

	for _, part in self.tool:GetDescendants() do
		if
			not part:IsA("BasePart")
			or (part:GetAttribute("Ammo") or part:GetAttribute("Slide") or part:GetAttribute("Pin"))
		then
			continue
		end

		local clone = part:Clone()
		prepare(clone)
		clone.Parent = viewModel
		table.insert(parts2, clone)
		table.insert(v20, partOffset(handle, part))
	end

	for _, part in self.tool:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute("Ammo")) then
			continue
		end

		local clone = part:Clone()
		prepare(clone)
		clone.Parent = viewModel
		table.insert(parts2, clone)
		table.insert(v21, clone)
		table.insert(v22, partOffset(handle, part))
	end

	local v23 = {}

	if self.spec.slide then
		for _, part in self.tool:GetDescendants() do
			if not part:IsA("BasePart") or not part:GetAttribute("Slide") or part:GetAttribute("Ammo") then
				continue
			end

			local clone = part:Clone()
			prepare(clone)
			clone.Parent = viewModel
			table.insert(parts2, clone)
			table.insert(v23, partOffset(handle, part))
		end

		assert(#v23 > 0, "spec.slide is set but the tool has no parts tagged Slide")
	end

	local v24 = {}

	for _, part in self.tool:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute("Pin")) then
			continue
		end

		local clone = part:Clone()
		prepare(clone)
		clone.Parent = viewModel
		table.insert(parts2, clone)
		table.insert(v24, partOffset(handle, part))
	end

	local armThickness = self.spec.armThickness or 1
	assert(armThickness > 0, "armThickness must be positive")
	local v25 = {}

	for _, v26 in { "Right", "Left" } do
		for _, v27 in v do
			local part = character:FindFirstChild(v26 .. v27)
			assert(part and part:IsA("BasePart"), "view model needs " .. v26 .. v27)
			local clone = part:Clone()
			prepare(clone)
			clone.Size = Vector3.new(clone.Size.X * armThickness, clone.Size.Y, clone.Size.Z * armThickness)

			if v27 ~= "Hand" then
				clone.Color = color
				clone.Material = Enum.Material.SmoothPlastic

				if clone:IsA("MeshPart") then
					clone.TextureID = ""
				end
			end

			clone.Parent = viewModel
			table.insert(parts2, clone)
			v25[v26 .. v27] = clone.Size / v4
		end
	end

	local fx = {
		flashT0 = -1,
		roll = 0,
		pendingCase = false,
		caseSize = Vector3.new(1, 1, 1),
		caseColor = color3,
		slideT0 = -1
	}
	self.fx = fx
	local v26 = {}
	local v27 = {}

	local v28 = false
	local v29 = nil
	local flag = false
	local pointLight

	if self.spec.flash then
		local function flashPart(size: Vector3, cframe2: CFrame, color4: Color3) -- 3 equivalent calls inferred from this helper
			local muzzleFlash = Instance.new("Part")
			muzzleFlash.Name = "MuzzleFlash"
			muzzleFlash.Size = size
			muzzleFlash.Material = Enum.Material.Neon
			muzzleFlash.Color = color4
			prepare(muzzleFlash)
			muzzleFlash.Transparency = 1
			muzzleFlash.Parent = viewModel
			table.insert(parts2, muzzleFlash)
			table.insert(v26, muzzleFlash)
			table.insert(v27, cframe2)
			return muzzleFlash
		end

		local flashScale = self.spec.flashScale or 1
		local parent = flashPart( -- inferred equivalent call
			Vector3.new(0.17, 0.17, 0.34) * flashScale,
			CFrame.new(0, 0, -0.17 * flashScale),
			Color3.fromRGB(255, 240, 200)
		)
		flashPart( -- inferred equivalent call
			Vector3.new(0.62, 0.07, 0.07) * flashScale,
			CFrame.new(0, 0, -0.1 * flashScale) * CFrame.Angles(0, 0, 0.7853981633974483),
			color2
		)
		flashPart( -- inferred equivalent call
			Vector3.new(0.62, 0.07, 0.07) * flashScale,
			CFrame.new(0, 0, -0.1 * flashScale) * CFrame.Angles(0, 0, -0.7853981633974483),
			color2
		)
		pointLight = Instance.new("PointLight")
		pointLight.Color = color2
		pointLight.Range = math.sqrt(flashScale) * 9
		pointLight.Brightness = 2.5
		pointLight.Shadows = false
		pointLight.Enabled = false
		pointLight.Parent = parent
	else
		pointLight = nil
	end

	if self.spec.eject then
		fx.caseSize = (self.spec.caseSize or Vector3.new(0.045, 0.045, 0.13)) / v5
		fx.caseColor = self.spec.caseColor or color3
	end

	local currentCamera = workspace.CurrentCamera
	viewModel.Parent = currentCamera
	self.model = viewModel
	self.parts = parts2

	local hud = buildHud()
	hud.gui.Parent = localPlayer:WaitForChild("PlayerGui")
	hud.vignetteGui.Parent = hud.gui.Parent
	self.hud = hud
	UserInputService.MouseIconEnabled = false
	firstPerson() -- inferred equivalent call
	local spec = self.spec
	local count2 = #v20
	local count3 = #v22
	local count4 = #v23
	local count5 = #v24

	local v30 = {}

	for i = 1, count2 do
		local v31 = v20[i]
		local v32 = parts2[i].Size / v4
		local v35 = math.clamp(math.ceil(v32.X / 0.35), 1, 6)
		local v36 = math.clamp(math.ceil(v32.Y / 0.35), 1, 6)
		local v37 = math.clamp(math.ceil(v32.Z / 0.35), 1, 6)

		for j = 0, v35 do
			for k = 0, v36 do
				for i2 = 0, v37 do
					if j == 0 or j == v35 or k == 0 or k == v36 or i2 == 0 or i2 == v37 then
						table.insert(v30, v31 * (v32 * Vector3.new(j / v35 - 0.5, k / v36 - 0.5, i2 / v37 - 0.5)))
					end
				end
			end
		end
	end

	local v31 = {}
	self.opening = nil
	local eyepiece = spec.scope and spec.scope.eyepiece

	if eyepiece then
		assert(spec.scopeHide == nil, "spec.scope.eyepiece and spec.scopeHide don't mix")
		local eye = spec.aimPoint + Vector3.new(0, 0, spec.aimDistance)

		local function samples(i: number, fn)
			local v32 = v20[i]
			local v36 = parts2[i].Size / v4

			for j = -2, 2 do
				for k = -2, 2 do
					for i2 = -2, 2 do
						fn(v32 * (v36 * Vector3.new(j, k, i2) / 4))
					end
				end
			end
		end

		local function offAxis(vector3: Vector3) -- 5 equivalent calls inferred from this helper
			local v32 = eye.Z - vector3.Z

			if v32 > 0 then
				return Vector2.new(vector3.X - eye.X, vector3.Y - eye.Y).Magnitude / v32
			end

			return nil
		end

		local tan = 1e999
		local minValue = 1e999
		local outer = 0

		for i = 1, count2 do
			if parts2[i].Name ~= eyepiece.rim then
				continue
			end

			local ringInner = parts2[i]:GetAttribute("RingInner")
			local ringOuter = parts2[i]:GetAttribute("RingOuter")

			if ringInner and ringOuter then
				local v32 = v20[i]
				local v38 = parts2[i].Size.X / v4 / 2

				for _, v39 in { -v38, v38 } do
					for j = 0, 63 do
						local v40 = j / 64 * 2 * 3.141592653589793
						local v41 = v32.YVector * math.cos(v40) + v32.ZVector * math.sin(v40)
						local v42 = v32.Position + v32.XVector * v39 + v41 * ringInner
						local v43 = offAxis(v42) -- inferred equivalent call
						tan = math.min(tan, v43 or 1e999)
						local z = v42.Z
						minValue = math.min(minValue, z)
						local v44 = offAxis(v42 + v41 * (ringOuter - ringInner)) -- inferred equivalent call
						outer = math.max(outer, v44 or 0)
					end
				end
			else
				samples(i, function(p)
					local v32 = tan
					tan = math.min(v32, offAxis(p) or 1e999) -- inferred equivalent call
					local v38 = outer
					outer = math.max(v38, offAxis(p) or 0) -- inferred equivalent call
					minValue = math.min(minValue, p.Z)
				end)
			end
		end

		assert(tan < 1e999, "spec.scope.eyepiece: no weapon part named " .. eyepiece.rim)

		for i = 1, count2 do
			local v32 = parts2[i]

			if v32.Name == eyepiece.rim then
				continue
			end

			local v38

			if eyepiece.slot == nil then
				v38 = false
			else
				v38 = v32:GetAttribute("GsSlot") == eyepiece.slot
			end

			for _, v39 in eyepiece.body or {} do
				v38 = v38 or string.sub(v32.Name, 1, #v39) == v39
			end

			if not v38 then
				samples(i, function(p)
					local v39 = offAxis(p) -- inferred equivalent call
					local v40 = v38

					if not v40 then
						if v39 == nil then
							v40 = false
						else
							v40 = v39 < tan * 0.99
						end
					end

					v38 = v40
				end)
			end

			if v38 then
				table.insert(v31, v32)
			end
		end

		table.move(v26, 1, #v26, #v31 + 1, v31)
		local v32 = count2 + count3 + count4 + count5

		table.insert(v31, parts2[v32 + 1])
		table.insert(v31, parts2[v32 + 2])
		table.insert(v31, parts2[v32 + 3])
		table.insert(v31, parts2[v32 + 4])
		table.insert(v31, parts2[v32 + 5])
		table.insert(v31, parts2[v32 + 6])

		self.opening = { tan = tan, outer = outer, eye = eye, plane = minValue }
	end

	local ring = spec.scope and spec.scope.ring
	local maxValue = 0
	local v32

	if ring then
		assert(
			not eyepiece and spec.scopeHide == nil,
			"spec.scope.ring doesn't mix with spec.scope.eyepiece or spec.scopeHide"
		)
		v32 = spec.scope.handoff
		local v35 = type(v32) == "number" and v32 > 0
		assert(v35, "spec.scope.ring needs spec.scope.handoff")

		for i = 1, count2 do
			if parts2[i].Name ~= ring then
				continue
			end

			local ringOuter = parts2[i]:GetAttribute("RingOuter")
			assert(type(ringOuter) == "number", "spec.scope.ring: " .. parts2[i]:GetFullName() .. " has no RingOuter")
			maxValue = math.max(maxValue, ringOuter)
		end

		assert(maxValue > 0, "spec.scope.ring: no weapon part named " .. ring)
	else
		v32 = 0
	end

	for _, v35 in { v20, v22, v23, v24, v27 } do
		for k, v36 in v35 do
			v35[k] = scaled(v36) -- inferred equivalent call
		end
	end

	local textLabel = nil

	if v19 then
		local v35 = count2 + count3 + count4 + count5
		parts2[v35 + 1].LocalTransparencyModifier = 1
		parts2[v35 + 4].LocalTransparencyModifier = 1

		if count2 > 0 and not spec.vrNoCount then
			local vrAmmo = Instance.new("Part")
			vrAmmo.Name = "VRAmmo"
			vrAmmo.Transparency = 1
			prepare(vrAmmo)
			vrAmmo.Size = Vector3.new(0.42, 0.2, 0.02)
			vrAmmo.Anchored = false
			local v36 = CFrame.new(spec.rightHand + Vector3.new(-0.3, 0.42, 0.15)) * CFrame.Angles(-0.4363323129985824, -0.2617993877991494, 0)
			local weld = Instance.new("Weld")
			weld.Part0 = parts2[1]
			weld.Part1 = vrAmmo
			weld.C0 = v20[1]:Inverse() * v36
			weld.Parent = vrAmmo
			vrAmmo.Parent = viewModel
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Back
			surfaceGui.LightInfluence = 0
			surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			surfaceGui.PixelsPerStud = 300
			surfaceGui.Parent = vrAmmo
			textLabel = Instance.new("TextLabel")
			textLabel.BackgroundColor3 = Color3.fromRGB(16, 18, 20)
			textLabel.BackgroundTransparency = 0.25
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.Font = Enum.Font.GothamBlack
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.Text = ""
			textLabel.Parent = surfaceGui
		end
	end

	local v35 = {}

	local function group(p: number, list)
		local count6 = #list

		if count6 == 0 then
			return nil
		end

		local part = parts2[p]
		local inverse = list[1]:Inverse()

		for i = 2, count6 do
			local v37 = parts2[p + i - 1]
			v37.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = v37
			weld.C0 = inverse * list[i]
			weld.Parent = v37
		end

		table.insert(v35, part)
		return #v35
	end

	local v36 = count2 + count3 + count4 + count5
	local v37 = group(1, v20)
	local v38 = group(count2 + 1, v22)
	local v39 = group(count2 + count3 + 1, v23)
	local v40 = group(count2 + count3 + count4 + 1, v24)
	local count6 = #v35

	table.insert(v35, parts2[v36 + 1])
	table.insert(v35, parts2[v36 + 2])
	table.insert(v35, parts2[v36 + 3])
	table.insert(v35, parts2[v36 + 4])
	table.insert(v35, parts2[v36 + 5])
	table.insert(v35, parts2[v36 + 6])

	local v41 = group(v36 + 7, v27)
	local v42 = {}
	local ammoShown = nil

	for i = 1, #v35 do
		v42[i] = v35[i].CFrame
	end

	local pos = self.pos
	local rot = self.rot
	pos.x = Vector3.new(0, 0, 0)
	pos.v = Vector3.new(0, 0, 0)
	rot.x = Vector3.new(0, 0, 0)
	rot.v = Vector3.new(0, 0, 0)
	self.aimAlpha = 0
	self.zoomAlpha = 0
	self.scopeCovered = false
	self.scopeRing = Vector3.new(0, 0, 0)
	table.clear(self.shots)
	local shots = self.shots
	local v43 = 0
	local v44 = 0
	local v45 = { x = Vector3.new(0, 0, 0), v = Vector3.new(0, 0, 0) }

	local v46 = {
		turn = { x = Vector3.new(0, 0, 0), v = Vector3.new(0, 0, 0) },
		move = { x = Vector3.new(0, 0, 0), v = Vector3.new(0, 0, 0) },
		keep = 1,
		keepRoll = 1,
		keepMove = 1
	}
	local v47 = { x = 0, v = 0 }
	local now = os.clock()

	local weight = spec.weight or 1
	local v48 = spec.aimTime

	if not v48 then
		if weight < 1 then
			v48 = 0.24 - (1 - weight) * 0.23
		else
			v48 = 0.24 + (weight - 1) * 0.4
		end
	end

	local aimOutTime = spec.aimOutTime or v48 * 0.83
	local zoomIn = spec.zoomIn or v48 * 1.12
	local zoomOut = spec.zoomOut or aimOutTime
	local v49 = 0.02 * weight
	local v50 = 0.008 * weight
	local v51 = 0.25 * weight
	local v52 = 22 / weight
	local v53 = math.sqrt(weight)
	local v54 = 0.1 * weight
	local v55 = 0.32 * weight
	local v56 = currentCamera.CFrame

	local parts = {}
	local total = 0
	local total2 = 0
	local total3 = 0
	local v57 = false
	local v58 = true
	local v59 = true

	for _, part in self.tool:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	if Detail.low then
		for _, v60 in parts do
			v60.CastShadow = false
		end
	end

	local FIELD_OF_VIEW = Movement.FIELD_OF_VIEW
	Movement.fovApplied = 0
	Movement.weaponFov = true
	local v60 = CFrame.new(0, 0, -spec.aimDistance) * CFrame.new(-spec.aimPoint)
	local aimPoint = spec.aimPoint
	local v61 = math.max(0, spec.aimDistance - 0.36)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local voxelChips = workspace:FindFirstChild("VoxelChips")
	local voxelLoose = workspace:FindFirstChild("VoxelLoose")
	local excludeInstances = { character, viewModel }

	if voxelChips then
		table.insert(excludeInstances, voxelChips)
	end

	if voxelLoose then
		table.insert(excludeInstances, voxelLoose)
	end

	raycastParams.ExcludeInstances = excludeInstances
	function self.restore()
		currentCamera.FieldOfView = FIELD_OF_VIEW
		Movement.weaponScale = 1
		Movement.blockSprint = false
		Movement.weaponFov = false
	end

	local rightUpperArm = v25.RightUpperArm
	local rightLowerArm = v25.RightLowerArm
	local rightHand = v25.RightHand
	local leftUpperArm = v25.LeftUpperArm
	local leftLowerArm = v25.LeftLowerArm
	local leftHand = v25.LeftHand

	local function setHidden(list, p: number, p2: number, localTransparencyModifier: number) -- 4 equivalent calls inferred from this helper
		for i = p, p2 do
			list[i].LocalTransparencyModifier = localTransparencyModifier
		end
	end
	local v63 = false
	local v64 = false
	local v65 = nil
	local v66 = 1
	local v67 = -1

	local v68 = -1
	local v69 = -1
	local v70 = 15

	local v71 = 1
	local v72, v73 = currentCamera.CFrame:ToOrientation()
	local cframe2 = nil
	RunService:BindToRenderStep(v17, Enum.RenderPriority.Camera.Value - 1, function()
		if Viewmodel.current ~= self then
			return
		end

		local cframe3 = currentCamera.CFrame

		if cframe2 then
			local orientation, v74 = cframe2:ToOrientation()
			local orientation2, v75 = cframe3:ToOrientation()
			v73 += wrapAngle(v75 - v74) -- inferred equivalent call
			v72 += orientation2 - orientation
		else
			v72, v73 = cframe3:ToOrientation()
		end
	end)
	RunService:BindToRenderStep(v18, Enum.RenderPriority.Camera.Value + 1, function(p)
		if Viewmodel.current ~= self then
			return
		end

		if v19 or humanoid.SeatPart or currentCamera.CameraType ~= Enum.CameraType.Custom then
			cframe2 = nil
			return
		end

		local v74

		if Viewmodel.touchMode then
			v74 = Vector2.zero
		else
			v74 = UserInputService:GetMouseDelta()
		end

		local stickInput = rightStick()
		Viewmodel.stickInput = stickInput

		local v76 = v74 * v2

		if stickInput ~= Vector2.zero then
			v76 += stickInput * (UserGameSettings.GamepadCameraSensitivity * math.min(p, 0.1) * Viewmodel.stickScale * LookSettings.look) * v3
		end

		if v76.Y ~= 0 then
			v76 = Vector2.new(v76.X, v76.Y * UserGameSettings:GetCameraYInvertValue())
		end

		local v77 = v76 * v71
		v73 = wrapAngle(v73 - v77.X) -- inferred equivalent call
		v72 = math.clamp(v72 - v77.Y, -1.3962634015954636, 1.3962634015954636)
		local cframe3 = currentCamera.CFrame
		local position = currentCamera.Focus.Position
		local cframe4 = CFrame.fromOrientation(v72, v73, 0)
		local cframe5 = CFrame.new(position - cframe4.LookVector * (position - cframe3.Position).Magnitude) * cframe4
		currentCamera.CFrame = cframe5
		cframe2 = cframe5
	end)

	RunService:BindToRenderStep(v16, Enum.RenderPriority.Camera.Value + 4, function(p)
		if Viewmodel.current ~= self then
			return
		end

		local v74 = math.min(p, 0.1)
		local cframe3 = currentCamera.CFrame
		local now2 = os.clock()

		local hands = Viewmodel.hands
		local v75 = self.aiming and not (self.aimBlocked or hands)

		if v75 then
			v43 = math.min(1, v43 + v74 / v48)
		else
			v43 = math.max(0, v43 - v74 / aimOutTime)
		end

		if v75 then
			v44 = math.min(1, v44 + v74 / zoomIn)
		else
			v44 = math.max(0, v44 - v74 / zoomOut)
		end

		local v76 = if spec.aimEaseOut then easeOut3 else smooth
		local v77 = v76(v43)
		local v78 = v76(v43 / 0.7)
		local v79 = v76((v43 - 0.15000000000000002) / 0.85)

		self.aimAlpha = v19 and 1 or v77
		local state = Movement.state
		Movement.weaponScale = v19 and 1 or 1 + (spec.aimMove - 1) * v77
		Movement.blockSprint = self.aiming or self.firing or now2 < self.sprintHoldUntil or hands ~= nil

		local v80 = v74 / v54
		local sprintAlpha = self.sprintAlpha

		if not state.sprinting then
			v80 = -v80
		end

		self.sprintAlpha = math.clamp(sprintAlpha + v80, 0, 1)
		local sprintAlpha2 = self.sprintAlpha
		local v81 = smooth(state.slideAlpha) -- inferred equivalent call
		local v82 = zoomedFov(FIELD_OF_VIEW, spec.aimFov, smooth(v44)) + (v81 * 4 + Movement.fovOffset) * (1 - v77) -- inferred equivalent call
		local scope = spec.scope
		local v83

		if scope then
			local v84 = v75 and scope.at <= v77 and not v19 and 1 or 0
			local zoomAlpha = self.zoomAlpha
			local zoomAlpha3

			if v84 == 1 then
				zoomAlpha3 = math.min(1, zoomAlpha + v74 / scope.time)
			else
				zoomAlpha3 = math.max(0, zoomAlpha - v74 * 2 / scope.time)
			end

			self.zoomAlpha = zoomAlpha3
			local v86 = zoomedFov(FIELD_OF_VIEW, scope.eyeFov, smooth(v44)) -- inferred equivalent call
			local zoomAlpha2 = self.zoomAlpha

			if scope.easeOut then
				v83 = 1 - (1 - zoomAlpha2) * (1 - zoomAlpha2) * (1 - zoomAlpha2)
			else
				v83 = smooth(zoomAlpha2) -- inferred equivalent call
			end

			v82 = zoomedFov(v86, spec.aimFov, v83) + (v81 * 4 + Movement.fovOffset) * (1 - v77) -- inferred equivalent call
		else
			v83 = 0
		end

		local v84

		if ring == nil or scope == nil then
			v84 = false
		else
			v84 = not v19
		end

		v71 = math.tan(math.rad(v82) / 2) / math.tan(math.rad(FIELD_OF_VIEW) / 2) * (1 + ((spec.aimSensitivity or 1) - 1) * v77) * LookSettings.aimScale(v77)
		local v85 = 1 - 0.9 * v77

		local cframe4 = v56.Rotation:ToObjectSpace(cframe3.Rotation)
		v56 = cframe3
		local orientation, v86 = cframe4:ToOrientation()
		local v87 = orientation / math.max(p, 1 / 240)
		local v88 = v86 / math.max(p, 1 / 240)
		local v89 = Vector3.new(v88 * v49, -v87 * v49 - math.abs(v88) * v50, 0)

		if v51 < v89.Magnitude then
			v89 = v89.Unit * v51
		end

		local v90 = v19 and 0 or not scope and 1 or 1 - self.zoomAlpha
		v46.keep = (1 - 0.7 * v77) * v90
		v46.keepRoll = (1 - 0.85 * v77) * v90
		v46.keepMove = (1 - 0.8 * v77) * v90
		follow3(v45, v89 * v46.keep, v52, 0.5, v74)
		local v91 = 0.12 * weight
		follow3(
			v46.turn,
			Vector3.new(
				math.clamp(-v87 * 0.009 * weight, -v91, v91),
				math.clamp(-v88 * 0.012 * weight, -v91, v91),
				(math.clamp(v88 * 0.03 * weight, -v91, v91))
			),
			v52,
			0.5,
			v74
		)

		local rootPart = humanoid.RootPart
		local v92 = not rootPart and 0 or cframe3.RightVector:Dot(rootPart.AssemblyLinearVelocity)
		follow3(v46.move, Vector3.new(-v92 * 0.005, 0, -v92 * 0.006) * v53, 9, 0.6, v74)

		stepSpring(pos, v74)
		stepSpring(rot, v74)

		local v93 = humanoid.FloorMaterial == Enum.Material.Air
		follow(v47, v93 and 1 or 0, 11, v93 and 1 or 0.45, v74)

		local rootPart2 = humanoid.RootPart
		local v94 = not rootPart2 and Vector3.new(0, 0, 0) or rootPart2.AssemblyLinearVelocity
		local magnitude = Vector3.new(v94.X, 0, v94.Z).Magnitude
		local v95 = not v93

		if v95 then
			if magnitude > 1 then
				v95 = humanoid.MoveDirection.Magnitude > 0.1
			else
				v95 = false
			end
		end

		if not v93 then
			total += magnitude * v74 / (10 + 5 * sprintAlpha2)
		end

		total2 += ((v95 and 1 or 0) - total2) * math.min(1, v74 * 12)
		local v96 = total2 * (1 - v81) * v85 * v53
		local v97 = Keyframes.sampleLoop(v8, total):Lerp(Keyframes.sampleLoop(v6, total), sprintAlpha2) * v96
		local v98 = Keyframes.sampleLoop(v9, total):Lerp(Keyframes.sampleLoop(v7, total), sprintAlpha2) * v96
		local v99 = (1 - total2) * (1 - v77)
		local v100 = Vector3.new(math.sin(now2 * 2.4) * 0.01, math.sin(now2 * 2.9) * 0.016, 0) * v99
		local total4 = Vector3.new(0, 0, 0)
		local total5 = Vector3.new(0, 0, 0)
		local total6 = 0

		for i = #shots, 1, -1 do
			local shot = shots[i]
			local v101 = (now2 - shot.t0) / spec.recoilTime

			if v101 >= 1 then
				table.remove(shots, i)
			else
				local sample = Keyframes.sample(spec.recoilKeys or v11, v101)
				total4 += shot.kick * sample
				total5 += shot.kickRot * sample
				total6 += sample
			end
		end

		local fieldOfView = v82 + 0.35 * spec.punch * math.min(total6, 1.5) * v82 / FIELD_OF_VIEW

		if not v19 and (fieldOfView ~= v68 or currentCamera.FieldOfView ~= v69) then
			currentCamera.FieldOfView = fieldOfView
			v68 = fieldOfView
			v69 = currentCamera.FieldOfView
		end

		local v102 = math.min((now2 - now) / v55, 1)
		local sample = Keyframes.sample(v12, v102)
		local sample2 = Keyframes.sample(v13, v102)

		local v103 = spec.reach * v4
		local raycastResult = workspace:Raycast(cframe3.Position, cframe3.LookVector * v103, raycastParams)
		local v104 = not raycastResult and 0 or (v103 - raycastResult.Distance) / v103
		total3 += (v104 - total3) * (1 - math.exp(v74 * -16))

		local lerped = spec.hold:Lerp(spec.sprintHold, sprintAlpha2)
		local position = lerped.Position
		local position2 = v60.Position
		local v105, v106

		if v84 then
			v105 = v78 + (1 - v78) * v83
			v79 += (1 - v79) * v83
			v106 = v61 * v83
		else
			v105 = v78
			v106 = 0
		end

		local vector3 = Vector3.new(
			position.X + (position2.X - position.X) * v105,
			position.Y + (position2.Y - position.Y) * v79,
			position.Z + (position2.Z - position.Z) * v79 + v106
		)
		local v107 = lerped.Rotation:Lerp(v60.Rotation, v105) * CFrame.Angles(0, 0, 0.8377580409572782 * v105 * (1 - v105))

		local pose = self.pose
		local v108 = pos.x * v85 + v97 + v100 + v45.x + sample + pose.Position + Vector3.new(v46.move.x.X * v46.keepMove, 0, 0) + Vector3.new(v81 * -0.25, v81 * -0.2 - v47.x * 0.75 * v85, 0) + Vector3.new(0, total3 * 0.5, total3 * spec.reach * 0.5)
		local v109 = CFrame.Angles(
			rot.x.X * v85 + total3 * 0.9 + v46.turn.x.X * v46.keep,
			rot.x.Y * v85 + v46.turn.x.Y * v46.keep,
			rot.x.Z * v85 + v81 * 0.42 + (v46.turn.x.Z + v46.move.x.Z) * v46.keepRoll
		) * degrees(v98 + sample2) -- inferred equivalent call
		local holdView = CFrame.Angles(math.rad(self.recoilPitch), math.rad(self.recoilYaw), 0) * CFrame.Angles(0, 0, (math.rad(self.recoilRoll))) * CFrame.new(vector3 + v108) * v109 * v107 * pose.Rotation * CFrame.new(total4) * degrees(total5) -- inferred equivalent call
		local maxValue2

		if spec.scope and not spec.scope.eyepiece and (not v63 or v84) then
			local viewportSize = currentCamera.ViewportSize
			local v111 = math.tan(math.rad(v82) / 2)
			local v112 = v111 * viewportSize.X / math.max(viewportSize.Y, 1)
			local v113 = v111 * 0.25 * 1.25
			local v114 = 0.25 * v112 * 1.25
			maxValue2 = 0

			for _, v115 in v30 do
				local v116 = holdView * v115
				local v117 = -v116.Z

				if not (v117 < 0.3) then
					continue
				end

				local v118

				if v117 >= 0 then
					if math.abs(v116.Y) < (v117 + 0.3) * v111 then
						v118 = math.abs(v116.X) < (v117 + 0.3) * v112
					else
						v118 = false
					end
				elseif math.abs(v116.Y) < v113 then
					v118 = math.abs(v116.X) < v114
				else
					v118 = false
				end

				if v118 then
					maxValue2 = math.max(maxValue2, 0.3 - v117)
				end
			end

			if maxValue2 > 0 then
				holdView = CFrame.new(0, 0, -maxValue2) * holdView
			end
		else
			maxValue2 = 0
		end

		local v111

		if v84 then
			local v112 = CFrame.new(vector3) * v107 * aimPoint - Vector3.new(0, 0, maxValue2)
			local v113 = math.max(-v112.Z, 0.001)
			local viewportSize = currentCamera.ViewportSize
			local v114 = viewportSize.Y / 2 / math.tan(math.rad(fieldOfView) / 2) / v113
			local v115 = maxValue * v114
			self.scopeRing = Vector3.new(v112.X * v114, -v112.Y * v114, v115)

			if self.zoomAlpha > 0 then
				v111 = v32 * math.min(viewportSize.X, viewportSize.Y) / 2 <= v115
			else
				v111 = false
			end
		else
			v111 = false
		end

		local position3 = nil
		local v112, v113

		if v19 then
			local inverse = cframe3:Inverse()
			local v114 = inverse * VR.hand("Right") * VR.GRIP
			local v115 = inverse * VR.hand("Left")
			local v116 = v114 * CFrame.new(-spec.rightHand)
			local grip = VR.grip("Left")
			local v117 = v116 * spec.leftHand

			if grip and not v57 then
				local magnitude2 = (v117 - v115.Position).Magnitude
				local v118 = not v38 and 1e999 or ((v116 * self.ammoDelta * v22[1]).Position - v115.Position).Magnitude

				if v118 < 0.8 and v118 < magnitude2 then
					local vrReload = Viewmodel.vrReload

					if vrReload then
						VR.buzz("Left", 0.4, 0.05)
						task.spawn(vrReload)
					end
				elseif magnitude2 < 0.9 then
					self.vrTwo = true
					VR.buzz("Left", 0.25, 0.04)
				end
			elseif not grip then
				self.vrTwo = false
			end

			v57 = grip

			if self.vrTwo then
				local position4 = v114.Position
				local v118 = v117 - position4
				local v119 = v115.Position - position4

				if v118.Magnitude > 0.001 and v119.Magnitude > 0.001 then
					local unit = v118.Unit
					local unit2 = v119.Unit
					local cross = unit:Cross(unit2)

					if cross.Magnitude > 0.00001 then
						v116 = CFrame.new(position4) * CFrame.fromAxisAngle(
							cross.Unit,
							(math.acos((math.clamp(unit:Dot(unit2), -1, 1))))
						) * CFrame.new(-position4) * v116
					end
				end
			else
				position3 = v115.Position
			end

			v112 = v114.ZVector
			v113 = v115.ZVector
			holdView = v116 * CFrame.new(spec.rightHand) * CFrame.Angles(
				math.rad(self.recoilPitch),
				math.rad(self.recoilYaw),
				0
			) * CFrame.new(-spec.rightHand) * CFrame.new(total4) * degrees(total5) -- inferred equivalent call
			self.vrAim = cframe3 * scaled(holdView * CFrame.new(spec.muzzle)) -- inferred equivalent call
		else
			v112 = Vector3.new(0, 0, 1)
			v113 = Vector3.new(0, 0, 1)
		end

		if hands then
			holdView = CFrame.new(0, -3.4 * hands.stow, 0.8 * hands.stow) * holdView * CFrame.Angles(-0.7 * hands.stow, 0, 0)
		end

		if v37 then
			v42[v37] = cframe3 * scaled(holdView) * v20[1] -- inferred equivalent call
		end

		local v114 = holdView * self.ammoDelta

		if v38 then
			v42[v38] = cframe3 * scaled(v114) * v22[1] -- inferred equivalent call
		end

		local slide = spec.slide

		if slide and count4 > 0 then
			local v115 = (now2 - fx.slideT0) / slide.time
			local v116

			if self.slideHold then
				v116 = self.slideHold
			else
				v116 = self.slideLocked and 1 or not (v115 >= 0 and v115 < 1) and 0 or Keyframes.sample(v10, v115)
			end

			local v117 = holdView * CFrame.new(0, 0, slide.travel * v116)

			if v39 then
				v42[v39] = cframe3 * scaled(v117) * v23[1] -- inferred equivalent call
			end
		end

		local v115 = holdView * self.pinDelta

		if v40 then
			v42[v40] = cframe3 * scaled(v115) * v24[1] -- inferred equivalent call
		end

		self.muzzleWorld = cframe3 * (holdView * spec.muzzle * v4)

		self.holdView = holdView
		local v116 = holdView * spec.rightHand

		if self.rightGun and self.rightWeight > 0 then
			v116 = v116:Lerp(holdView * self.rightGun, (math.clamp(self.rightWeight, 0, 1)))
		end

		local v117 = holdView * (self.leftGun or spec.leftHand)

		if spec.leftHip and not self.leftGun then
			v117 = spec.leftHip:Lerp(v117, v78)
		end

		if self.leftWeight > 0 then
			v117 = v117:Lerp(self.leftTarget:Lerp(v114 * self.ammoGrab, self.leftOnAmmo), self.leftWeight)
		end

		if self.rightReachTo and self.rightReach ~= 0 then
			v116 = v116:Lerp(self.rightReachTo, self.rightReach)
		end

		if self.leftReachTo and self.leftReach ~= 0 then
			v117 = v117:Lerp(self.leftReachTo, self.leftReach)
		end

		if hands then
			v116 = v116:Lerp(hands.right, hands.weight)
			v117 = v117:Lerp(hands.left, hands.weight)
		end

		local v118 = count6
		local v119, v120

		if v19 then
			v117 = position3 or v117
			v119 = v116 + v112 * (rightUpperArm.Y + rightLowerArm.Y) * 0.9
			v120 = v117 + v113 * (leftUpperArm.Y + leftLowerArm.Y) * 0.9
		else
			v119 = Vector3.new(1.5, -2.2, 0.6)
			v120 = Vector3.new(-0.9, -2.2, 0.2)
		end

		local v121, v122, v123 = solveArm(
			v119,
			v116,
			self.rightPole or Vector3.new(0.6, -1, 0.3),
			rightUpperArm.Y,
			rightLowerArm.Y,
			rightHand.Y
		)
		local v124 = v118 + 1
		local v125 = v118 + 2
		local v126 = v118 + 3
		local v127 = cframe3 * scaled(v121) -- inferred equivalent call
		local v128 = cframe3 * scaled(v122) -- inferred equivalent call
		local v129 = cframe3 * scaled(v123) -- inferred equivalent call

		v42[v124] = v127
		v42[v125] = v128
		v42[v126] = v129
		local v130, v131, v132 = solveArm(
			v120,
			v117,
			self.leftPole or Vector3.new(-0.4, -1, 0.3),
			leftUpperArm.Y,
			leftLowerArm.Y,
			leftHand.Y
		)
		local v133 = v118 + 4
		local v134 = v118 + 5
		local v135 = v118 + 6
		local v136 = cframe3 * scaled(v130) -- inferred equivalent call
		local v137 = cframe3 * scaled(v131) -- inferred equivalent call
		local v138 = cframe3 * scaled(v132) -- inferred equivalent call

		v42[v133] = v136
		v42[v134] = v137
		v42[v135] = v138

		if #v26 > 0 then
			local v139 = now2 - fx.flashT0 < 0.035

			if v41 then
				if v139 then
					local v140 = holdView * CFrame.new(spec.muzzle) * CFrame.Angles(0, 0, fx.roll)
					local v141 = v26[1]
					local v142 = cframe3 * scaled(v140) * v27[1] -- inferred equivalent call
					v35[v41] = v141
					v42[v41] = v142
					flag = false
				elseif flag then
					v35[v41] = nil
					v42[v41] = nil
				else
					v35[v41] = v26[1]
					v42[v41] = cframe
					flag = true
				end
			end

			if v139 ~= v28 then
				v28 = v139

				local v140 = not Detail.low

				if v139 and v140 ~= v29 then
					v29 = v140

					for _, v141 in v26 do
						v141.Transparency = v140 and 0.15 or 0
					end
				end

				if pointLight then
					pointLight.Enabled = v139 and v140
				end
			end
		end

		workspace:BulkMoveTo(v35, v42, Enum.BulkMoveMode.FireCFrameChanged)

		if fx.pendingCase and spec.eject then
			fx.pendingCase = false
			local v139 = cframe3 * scaled(holdView * CFrame.new(spec.eject)) -- inferred equivalent call
			local v140 = (spec.ejectVel or Vector3.new(4.5, 2.4, 0.8)) + Vector3.new(
				math.random() * 1.5,
				math.random() * 1.2,
				math.random() * 0.8
			)
			local position4 = cframe3.Position
			CaseDrop.throwOwn(
				position4 + (v139.Position - position4) / v4,
				v139.Rotation:VectorToWorldSpace(v140) + v94,
				v139.Rotation * CFrame.Angles(0, 1.5707963267948966, 0),
				fx.caseSize,
				fx.caseColor,
				position4
			)
		end

		if v58 ~= self.ammoVisible and not v63 then
			v58 = self.ammoVisible
			setHidden(parts2, count2 + 1, count2 + count3, v58 and 0 or 1) -- inferred equivalent call
		end

		if v59 ~= self.pinVisible and count5 > 0 then
			v59 = self.pinVisible
			setHidden(parts2, count2 + count3 + count4 + 1, count2 + count3 + count4 + count5, v59 and 0 or 1) -- inferred equivalent call
		end

		if not v84 then
			v111 = not v19

			if v111 then
				if spec.scopeHide == nil then
					v111 = false
				else
					v111 = true
					local v139

					if spec.scope then
						v139 = self.zoomAlpha
					else
						v139 = v77
					end

					if not (spec.scopeHide <= v139) then
						v111 = v63

						if v111 then
							if spec.scopeShow == nil then
								v111 = false
							else
								v111 = spec.scopeShow <= v77
							end
						end
					end
				end
			end
		end

		if v111 ~= v63 then
			v63 = v111
			setHidden(parts2, 1, #parts2, v111 and 1 or 0) -- inferred equivalent call

			if not (v111 or v58) then
				setHidden(parts2, count2 + 1, count2 + count3, 1) -- inferred equivalent call
			end
		end

		self.scopeCovered = v84 and v63

		local v139 = not v19 and self.zoomAlpha > 0

		if v139 ~= v64 then
			v64 = v139

			for _, v140 in v31 do
				v140.LocalTransparencyModifier = v139 and 1 or 0
			end
		end

		local visible

		if v77 < 0.5 then
			visible = not (v19 or hands)
		else
			visible = false
		end

		if textLabel and self.ammoShown ~= ammoShown then
			ammoShown = self.ammoShown
			local v141 = ammoShown
			textLabel.Text = not (v141 and v141[1]) and ""
				or tostring(v141[1]) .. (not v141[2] and "" or " / " .. tostring(v141[2]))
			textLabel.Visible = textLabel.Text ~= ""
		end

		if visible ~= v65 then
			v65 = visible
			hud.crosshair.Visible = visible
		end

		local backgroundTransparency

		if v19 then
			backgroundTransparency = 1
		else
			backgroundTransparency = 1 - smooth(v77) * 0.2 -- inferred equivalent call
		end

		if math.abs(backgroundTransparency - v66) > 0.004 or (backgroundTransparency == 1) ~= (v66 == 1) then
			v66 = backgroundTransparency

			for _, v142 in hud.vignette do
				v142.BackgroundTransparency = backgroundTransparency
			end

			hud.vignetteGui.Enabled = backgroundTransparency < 1
		end

		local v142 = math.floor((math.min(total6, 2) * 0.5 + 1) * 12 * 2 + 0.5) / 2

		if visible and v142 ~= v67 then
			v67 = v142
			local ticks = hud.ticks
			ticks[1].Position = UDim2.new(0.5, -v142, 0.5, 0)
			ticks[2].Position = UDim2.new(0.5, v142, 0.5, 0)
			ticks[3].Position = UDim2.new(0.5, 0, 0.5, -v142)
			ticks[4].Position = UDim2.new(0.5, 0, 0.5, v142)
		end

		v70 += 1
		local v143 = parts[1]

		if v70 >= 15 or v143 and v143.LocalTransparencyModifier ~= 1 then
			v70 = 0

			for _, v144 in parts do
				v144.LocalTransparencyModifier = 1
			end
		end
	end)
end

function Viewmodel:stop()
	if not self.active then
		return
	end

	self.active = false
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 and not self.spec.silentGear then
		GearSound.stow(self.spec)
	end

	local connection = v15[self]

	if connection then
		connection:Disconnect()
		v15[self] = nil
	end

	local v16 = Viewmodel.current == self

	if v16 then
		Viewmodel.current = nil
	end

	self.aiming = false
	self.firing = false
	self.sprintAlpha = 0
	self.zoomAlpha = 0
	self.scopeCovered = false
	self.vrAim = nil
	self.vrTwo = false

	for _, v17 in self.bindings or {} do
		RunService:UnbindFromRenderStep(v17)
	end

	self.bindings = nil

	if self.restore then
		if v16 then
			self.restore()
		end

		self.restore = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	if self.hud then
		self.hud.gui:Destroy()
		self.hud.vignetteGui:Destroy()
		self.hud = nil
	end

	if not self.tool:IsDescendantOf(game) then
		for _, v17 in self.guis do
			v17:Destroy()
		end

		table.clear(self.guis)
	end

	local parent = self.tool.Parent
	local v17

	if parent == nil then
		v17 = false
	else
		v17 = parent:FindFirstChildOfClass("Humanoid") ~= nil
	end

	for _, part in self.tool:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = v17 and 0 or 1
		end
	end

	if v16 then
		task.delay(0.3, function()
			if Viewmodel.current == nil then
				UserInputService.MouseIconEnabled = true
			end
		end)
	end

	firstPerson() -- inferred equivalent call
end

function Viewmodel:rebuild()
	if self.active then
		self:stop()
		self:start()
	end
end

Viewmodel.pointerFree = {}

Viewmodel.vrReload = nil

function Viewmodel.cursorAfterMenu(flag: boolean)
	local current = Viewmodel.current
	return not (current and current.active) and flag
end

function Viewmodel.ownGui(p, screenGui)
	local v16 = typeof(screenGui) == "Instance" and screenGui:IsA("ScreenGui")
	assert(v16, "Viewmodel.ownGui: expected a ScreenGui")

	if not table.find(p.guis, screenGui) then
		table.insert(p.guis, screenGui)
	end

	if not screenGui:FindFirstChild("OwnerTool") then
		local ownerTool = Instance.new("ObjectValue")
		ownerTool.Name = "OwnerTool"
		ownerTool.Value = p.tool
		ownerTool.Parent = screenGui
	end
end

function Viewmodel:setAmmo(p: number, p2: number?)
	self.ammoShown = { p, p2 }
end

local domination = nil
function Viewmodel.held(): boolean
	if not domination or domination.Parent == nil then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Game = ReplicatedStorage:FindFirstChild("Game")
		domination = Game and Game:FindFirstChild("Domination")
	end

	local phase = domination and domination:GetAttribute("Phase")
	return phase == "starting" or phase == "over"
end

function Viewmodel:breakSprint()
	if not self.active then
		return
	end

	self.sprintAlpha = 0
	self.sprintHoldUntil = os.clock() + 0.35
	Movement.blockSprint = true
	Movement.state.sprinting = false
end

function Viewmodel.ready(p)
	local active = p.active

	if active then
		if p.sprintAlpha < 0.3 then
			return not (Viewmodel.held() or Viewmodel.hands)
		end

		return false
	end

	return active
end

function Viewmodel.fired(data)
	local spec = data.spec
	local aimAlpha = data.aimAlpha
	local lerped = spec.hipKick:Lerp(spec.aimKick, aimAlpha)
	local lerped2 = spec.hipKickRot:Lerp(spec.aimKickRot, aimAlpha)
	local padKick = Viewmodel.padKick(data.tool.Name)
	local v16 = lerped * padKick
	local v17 = lerped2 * padKick
	local v18 = math.random() * 2 - 1.25
	table.insert(data.shots, {
		t0 = os.clock(),
		kick = Vector3.new(v16.X * v18, v16.Y, v16.Z),
		kickRot = Vector3.new(v17.X, v17.Y * (math.random() * 2 - 1), v17.Z * (math.random() * 2 - 1))
	})

	if VR.on() then
		VR.buzz("Right", 0.55, 0.045)

		if data.vrTwo then
			VR.buzz("Left", 0.3, 0.045)
		end
	end

	local fx = data.fx

	if fx then
		fx.flashT0 = os.clock()
		fx.roll = math.random() * 3.141592653589793 * 2

		if not spec.boltEject then
			fx.pendingCase = true
			fx.slideT0 = os.clock()
		end
	end
end

function Viewmodel.eject(p)
	assert(p.spec.boltEject, "Viewmodel.eject is for bolt actions (spec.boltEject)")

	if p.fx then
		p.fx.pendingCase = true
	end
end

function Viewmodel.bump(p, p2: number)
	p.pos.v += Vector3.new(0, -0.8, 1.5) * p2
	p.rot.v += Vector3.new(-1.2, 0, 0.6) * p2
end

local object2 = setmetatable({}, { __mode = "k" })
function Viewmodel:setFilter(excludeInstances)
	local v16 = object2[self]

	if v16 and #v16 == #excludeInstances then
		local flag = true

		for k, excludeInstance in excludeInstances do
			if v16[k] ~= excludeInstance then
				flag = false
				break
			end
		end

		if flag then
			return
		end
	end

	assert(self.FilterType == Enum.RaycastFilterType.Exclude, "Viewmodel.setFilter: params must be Exclude")
	self.ExcludeInstances = excludeInstances
	object2[self] = table.clone(excludeInstances)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function Viewmodel.muzzle(p, p2)
	local v16

	if VR.on() then
		v16 = VR.eye()
	else
		v16 = workspace.CurrentCamera.CFrame.Position
	end

	local v17 = raycastParams
	Viewmodel.setFilter(v17, p2)
	local v18 = p.muzzleWorld - v16
	local raycastResult = workspace:Raycast(v16, v18, v17)

	if raycastResult then
		return raycastResult.Position - v18.Unit * 0.3
	end

	return p.muzzleWorld
end

return Viewmodel