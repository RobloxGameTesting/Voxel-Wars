local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while LocalPlayer:GetAttribute("JoinCovered") == true do
	LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
end

task.wait(1.4)

local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Players2 = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Hellfire = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Hellfire"))
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local VoxelProp = require(Voxel:WaitForChild("VoxelProp"))
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local VoxelCore = require(Voxel:WaitForChild("VoxelCore"))
local ClientWorld = require(Voxel:WaitForChild("ClientWorld"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Quality = require(Voxel:WaitForChild("Quality"))
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))
local Remotes = ReplicatedStorage.Game:WaitForChild("Remotes")
local hellfire = Remotes:WaitForChild("Hellfire")
local HellfirePose = Remotes:WaitForChild("HellfirePose")
local HellfireState = Remotes:WaitForChild("HellfireState")

local localPlayer = Players2.LocalPlayer
local meter = WorldConfig.METER
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local cframe = CFrame.new(0, workspace.FallenPartsDestroyHeight + 60, 0)

local hellfires = Instance.new("Folder")
hellfires.Name = "Hellfires"
hellfires.Parent = workspace

local color = Color3.fromRGB(78, 86, 58)
local color2 = Color3.fromRGB(60, 66, 44)
local color3 = Color3.fromRGB(206, 170, 58)
local color4 = Color3.fromRGB(150, 156, 160)
local color5 = Color3.fromRGB(38, 40, 42)
local function missileShape(vector3: Vector3)
	local v = math.sqrt(vector3.X * vector3.X + vector3.Y * vector3.Y)
	local z = vector3.Z

	if
		z > 2.5
		and z < 5
		and (math.abs(vector3.X) < 0.26 or math.abs(vector3.Y) < 0.26)
		and v < (z - 2.5) * 0.35 + 1.05
	then
		return color2
	end

	if z > -3.6 and z < -2.6 and (math.abs(vector3.X) < 0.26 or math.abs(vector3.Y) < 0.26) and v < 1.35 then
		return color2
	end

	if z < -5.6 or z > 5.4 or (not (z < -4) and 0.9 or (z + 5.6) / 1.6 * 0.65 + 0.25) < v then
		return nil
	end

	if z < -4 then
		return color4
	end

	if z > 4.8 then
		return if not (v < 0.5) then color5 else nil
	else
		return if z > -2 and z < -1.4 then color3 else color
	end
end

local v = nil
local function ensureBaked() -- 1 equivalent call inferred from this helper
	if not v then
		v = VoxelProp.bake(Vector3.new(6, 6, 24), Vector3.new(-1.5, -1.5, -6), VOXEL_SIZE, missileShape)
	end
end

local function buildMissile()
	ensureBaked() -- inferred equivalent call
	local v2 = v
	local part = VoxelProp.part(v2, "Hellfire")
	part.CastShadow = false
	part.CFrame = cframe
	local function on(vector3: Vector3) -- 3 equivalent calls inferred from this helper
		local attachment = Instance.new("Attachment")
		attachment.Position = vector3 - v2.center
		attachment.Parent = part
		return attachment
	end

	local parent = on(Vector3.new(0, 0, 5.6)) -- inferred equivalent call
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://13145063652"
	particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
	particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.Loop
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.LockedToPart = true
	particleEmitter.EmissionDirection = Enum.NormalId.Back
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 230, 170), Color3.fromRGB(255, 120, 40))
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.6), NumberSequenceKeypoint.new(1, 0.4) })
	particleEmitter.Transparency = NumberSequence.new(0.1, 1)
	particleEmitter.Lifetime = NumberRange.new(0.06, 0.12)
	particleEmitter.Speed = NumberRange.new(30, 40)
	particleEmitter.Rate = 80 * Quality.share()
	particleEmitter.SpreadAngle = Vector2.new(6, 6)
	particleEmitter.Enabled = false
	particleEmitter.Parent = parent
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 170, 90)
	pointLight.Range = 18
	pointLight.Brightness = 3
	pointLight.Shadows = false
	pointLight.Enabled = false
	pointLight.Parent = parent
	local trail = Instance.new("Trail")
	trail.Attachment0 = on(Vector3.new(0.7, 0, 5.4)) -- inferred equivalent call
	trail.Attachment1 = on(Vector3.new(-0.7, 0, 5.4)) -- inferred equivalent call
	trail.Lifetime = 3.5
	trail.Color = ColorSequence.new(Color3.fromRGB(150, 148, 144), Color3.fromRGB(110, 108, 104))
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
	trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 4) })
	trail.LightInfluence = 1
	trail.FaceCamera = true
	trail.MinLength = 0.5
	trail.Enabled = false
	trail.Parent = part
	part.Parent = hellfires
	return {
		body = part,
		offset = CFrame.new(v2.center),
		flame = particleEmitter,
		light = pointLight,
		smoke = trail,
		frames = {}
	}
end

local v2 = {}
local function park(missile) -- 1 equivalent call inferred from this helper
	local flame = missile.flame
	local light = missile.light
	local smoke = missile.smoke
	flame.Enabled = false
	light.Enabled = false
	smoke.Enabled = false
	missile.body.CFrame = cframe
	table.insert(v2, missile)
end
local function place(missile, vector3: Vector3, vector3_2: Vector3) -- 2 equivalent calls inferred from this helper
	local v3 = not (vector3_2.Magnitude > 1) and -Vector3.new(0, 1, 0) or vector3_2.Unit
	local v4 = math.abs(v3.Y) > 0.95 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
	missile.body.CFrame = CFrame.lookAt(vector3, vector3 + v3, v4) * missile.offset
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.IgnoreWater = true
local v3 = nil
local v4 = false
local function strike(origin: Vector3, vector3: Vector3)
	local v5 = vector3 - origin
	local magnitude = v5.Magnitude

	if magnitude < 0.001 then
		return nil, nil
	end

	local v6 = v5 / magnitude
	local v7 = nil
	local v8 = nil

	local world = ClientWorld.world
	local v9

	if world then
		local v10, v11, _
		v10, v11, _, v9 = VoxelCore.raycast(world, origin, v6, magnitude)

		if v10 then
			v7 = v10
			v8 = v11 or Vector3.new(0, 1, 0)
		else
			v9 = magnitude
		end
	else
		v9 = magnitude
	end

	local vehicleHulls = workspace:FindFirstChild("VehicleHulls")

	if not v4 or vehicleHulls ~= v3 then
		v4 = true
		v3 = vehicleHulls
		local filterDescendantsInstances

		if vehicleHulls then
			filterDescendantsInstances = { workspace.Terrain, vehicleHulls }
		else
			filterDescendantsInstances = { workspace.Terrain }
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	end

	local raycastResult = workspace:Raycast(origin, v6 * magnitude, raycastParams)

	if raycastResult and raycastResult.Distance < v9 then
		v7 = raycastResult.Position
		v8 = raycastResult.Normal
	end

	return v7, v8
end

local function release(state) -- 1 equivalent call inferred from this helper
	if state.missile then
		park(state.missile) -- inferred equivalent call
		state.missile = nil
	end

	if state.heard then
		VoxelSound.rocketEnd(state.sound)
		state.heard = false
	end
end

local hellfireView = Instance.new("ScreenGui")
hellfireView.Name = "HellfireView"
hellfireView.ResetOnSpawn = false
hellfireView.IgnoreGuiInset = true
hellfireView.DisplayOrder = 40
hellfireView.Enabled = false
hellfireView.Parent = localPlayer:WaitForChild("PlayerGui")

local function bar(name: string, p: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0, p)
	frame.Position = UDim2.fromScale(0, p)
	frame.Size = UDim2.fromScale(1, 0.085)
	frame.Parent = hellfireView
	return frame
end

local v5 = bar("Top", 0)
local v6 = bar("Bottom", 1)
local label = Style.label(v5, "Title", "HELLFIRE", 18, Style.FONT, 1.5)
label.AnchorPoint = Vector2.new(0, 0.5)
label.Position = UDim2.new(0, 24, 0.5, 0)
label.TextColor3 = Color3.fromRGB(255, 90, 70)
local label2 = Style.label(v5, "Height", "", 18, Style.FONT, 1.5)
label2.AnchorPoint = Vector2.new(1, 0.5)
label2.Position = UDim2.new(1, -24, 0.5, 0)
local label3 = Style.label(v6, "Help", "", 16, Style.FONT, 1.5)
label3.AnchorPoint = Vector2.new(0.5, 0.5)
label3.Position = UDim2.fromScale(0.5, 0.5)

local ring = Instance.new("Frame")
ring.Name = "Ring"
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.Position = UDim2.fromScale(0.5, 0.5)
ring.BackgroundTransparency = 1
ring.Parent = hellfireView
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.5, 0)
uiCorner.Parent = ring
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 90, 70)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.15
uiStroke.Parent = ring
local v7 = nil
local v8 = {}

for _, v9 in {
	{ 1, 0 },
	{ -1, 0 },
	{ 0, 1 },
	{ 0, -1 }
} do
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(255, 90, 70)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	local size

	if v9[1] == 0 then
		size = UDim2.fromOffset(2, 12)
	else
		size = UDim2.fromOffset(12, 2)
	end

	frame.Size = size
	frame.Position = UDim2.new(0.5, v9[1] * 12, 0.5, v9[2] * 12)
	frame.Parent = hellfireView
end

local color6 = Color3.fromRGB(255, 60, 50)
local color7 = Color3.fromRGB(90, 230, 120)
local v9 = {}
local function marker(count: number)
	local marker2 = v9[count]

	if marker2 then
		return marker2
	end

	marker2 = Instance.new("Frame")
	marker2.Name = "Marker"
	marker2.AnchorPoint = Vector2.new(0.5, 0.5)
	marker2.Size = UDim2.fromOffset(13, 13)
	marker2.Rotation = 45
	marker2.BorderSizePixel = 0
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Parent = marker2
	marker2.Parent = hellfireView
	v9[count] = marker2

	return marker2
end

local flash = Instance.new("Frame")
flash.Name = "Flash"
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 5
flash.Parent = hellfireView

local hellfireCut = Instance.new("ScreenGui")
hellfireCut.Name = "HellfireCut"
hellfireCut.ResetOnSpawn = false
hellfireCut.IgnoreGuiInset = true
hellfireCut.DisplayOrder = 42
hellfireCut.Enabled = false
hellfireCut.Parent = localPlayer:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = hellfireCut

local boost = Instance.new("TextButton")
boost.Name = "Boost"
boost.Text = "BOOST"
boost.Font = Enum.Font.GothamBlack
boost.TextSize = 20
boost.TextColor3 = Color3.new(1, 1, 1)
boost.BackgroundColor3 = Color3.fromRGB(190, 50, 35)
boost.AnchorPoint = Vector2.new(1, 1)
boost.Position = UDim2.new(1, -36, 1, -110)
boost.Size = UDim2.fromOffset(110, 110)
boost.Visible = false
boost.Parent = hellfireView
local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0.5, 0)
uiCorner2.Parent = boost

local hellfireGrade = Instance.new("ColorCorrectionEffect")
hellfireGrade.Name = "HellfireGrade"
hellfireGrade.Saturation = -0.75
hellfireGrade.Contrast = 0.25
hellfireGrade.Brightness = -0.03
hellfireGrade.TintColor = Color3.fromRGB(214, 228, 238)
hellfireGrade.Enabled = false
hellfireGrade.Parent = Lighting

local v10 = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Down,
	Enum.KeyCode.Left,
	Enum.KeyCode.Right,
	Enum.KeyCode.Space,
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseWheel,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.G,
	Enum.KeyCode.Q,
	Enum.KeyCode.E,
	Enum.KeyCode.R,
	Enum.KeyCode.F,
	Enum.KeyCode.C,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight
}

local function boost2() -- 1 equivalent call inferred from this helper
	local v11 = v7

	if not v11 or v11.phase ~= "fly" or v11.boostT then
		return
	end

	v11.boostT = v11.t
	hellfire:FireServer("boost", v11.f.id)
	v11.flashAt = os.clock()
	VoxelSound.designator("lock")
end

local function sinkAction(_: string, p, p2)
	if
		p == Enum.UserInputState.Begin
		and (p2.UserInputType == Enum.UserInputType.MouseButton1 or p2.KeyCode == Enum.KeyCode.ButtonR2)
	then
		boost2() -- inferred equivalent call
	end

	return Enum.ContextActionResult.Sink
end

boost.Activated:Connect(boost2)

local v11 = { CombatFeedback = true, SkirmishFeed = true, SkirmishPoints = true }

local displayOrdersByScreenGui = {}
local function liftKept(enabled: boolean)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if enabled and playerGui then
		for _, screenGui in playerGui:GetChildren() do
			if not (screenGui:IsA("ScreenGui") and v11[screenGui.Name] and displayOrdersByScreenGui[screenGui] == nil) then
				continue
			end

			displayOrdersByScreenGui[screenGui] = screenGui.DisplayOrder
			screenGui.DisplayOrder = 41
		end
	elseif not enabled then
		for k, displayOrder in displayOrdersByScreenGui do
			k.DisplayOrder = displayOrder
		end

		table.clear(displayOrdersByScreenGui)
	end
end
local screenGuis = {}
local v12 = nil
local function showWorld(enabled: boolean)
	hellfireView.Enabled = enabled
	hellfireGrade.Enabled = enabled

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if enabled and atmosphere and not v12 then
		v12 = { density = atmosphere.Density, haze = atmosphere.Haze }
		atmosphere.Density = math.min(atmosphere.Density, 0.08)
		atmosphere.Haze = 0
	elseif not enabled and v12 then
		if atmosphere then
			local density = v12.density
			local haze = v12.haze
			atmosphere.Density = density
			atmosphere.Haze = haze
		end

		v12 = nil
	end

	liftKept(enabled)

	if enabled then
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			for _, screenGui in playerGui:GetChildren() do
				if
					not screenGui:IsA("ScreenGui")
					or screenGui == hellfireView
					or screenGui == hellfireCut
					or v11[screenGui.Name]
				then
					continue
				end

				if not screenGui.Enabled then
					continue
				end

				screenGui.Enabled = false
				table.insert(screenGuis, screenGui)
			end
		end
	else
		for _, v13 in screenGuis do
			if v13.Parent then
				v13.Enabled = true
			end
		end

		table.clear(screenGuis)
	end
end

local function finishControl()
	local v13 = v7

	if not v13 then
		return
	end

	v7 = nil

	hellfireView.Enabled = false
	boost.Visible = false
	ContextActionService:UnbindAction("HellfireSink")
	RunService:UnbindFromRenderStep("HellfireCamera")
	hellfireView.Enabled = false
	hellfireGrade.Enabled = false

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if v12 then
		if atmosphere then
			local density = v12.density
			local haze = v12.haze
			atmosphere.Density = density
			atmosphere.Haze = haze
		end

		v12 = nil
	end

	localPlayer:FindFirstChildOfClass("PlayerGui")

	for k, displayOrder in displayOrdersByScreenGui do
		k.DisplayOrder = displayOrder
	end

	table.clear(displayOrdersByScreenGui)

	for _, v14 in screenGuis do
		if v14.Parent then
			v14.Enabled = true
		end
	end

	table.clear(screenGuis)

	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and v13.anchored then
		humanoidRootPart.Anchored = false
	end

	if v13.took then
		currentCamera.FieldOfView = v13.fov

		if humanoid and humanoid.Health > 0 then
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = humanoid
		end
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	if v13.took then
		task.delay(0.3, function()
			if not v7 and Viewmodel.current == nil then
				UserInputService.MouseIconEnabled = true
			end
		end)
	end
end

local function cutBlack(p: number, p2: number)
	local lastTime = os.clock()
	hellfireCut.Enabled = true
	frame.BackgroundTransparency = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v13 = os.clock() - lastTime

		if v13 < p then
			hellfireCut.Enabled = true
			frame.BackgroundTransparency = 0
		else
			local backgroundTransparency = math.clamp((v13 - p) / p2, 0, 1)
			hellfireCut.Enabled = backgroundTransparency < 1
			frame.BackgroundTransparency = backgroundTransparency

			if backgroundTransparency >= 1 then
				renderSteppedConnection:Disconnect()
			end
		end
	end)
end

local function groundBelow(pos: Vector3, p: number) -- 2 equivalent calls inferred from this helper
	local v13 = strike(pos, pos - Vector3.new(0, 1, 0) * (Hellfire.START_HEIGHT * 2))
	return if v13 then v13.Y else p
end

local function steerInput(state)
	local total = 0
	local total2 = 0

	if not UserInputService:GetFocusedTextBox() then
		total += ((UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right)) and 1 or 0) - ((UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left)) and 1 or 0)
		total2 += ((UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up)) and 1 or 0) - ((UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down)) and 1 or 0)
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	state.mouse = state.mouse * 0.6 + Vector2.new(mouseDelta.X, -mouseDelta.Y) * 0.06
	local v13 = total + state.mouse.X
	local v14 = total2 + state.mouse.Y

	if UserInputService.GamepadEnabled then
		for _, v15 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
			if not (v15.KeyCode == Enum.KeyCode.Thumbstick1 and v15.Position.Magnitude > 0.15) then
				continue
			end

			v13 += v15.Position.X
			v14 += v15.Position.Y
		end
	end

	if UserInputService.TouchEnabled and v13 == 0 and v14 == 0 then
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local moveDirection = humanoid and humanoid.MoveDirection or Vector3.new(0, 0, 0)

		if moveDirection.Magnitude > 0.1 then
			v13 = moveDirection:Dot((state.f.heading:Cross(Vector3.new(0, 1, 0))))
			v14 = moveDirection:Dot(state.f.heading)
		end
	end

	local vector2 = Vector2.new(v13, v14)
	return if vector2.Magnitude > 1 then vector2.Unit else vector2
end

local function updateOverlay(data, currentCamera)
	local viewportSize = currentCamera.ViewportSize
	local v13 = math.max(data.pos.Y - data.ground, 1)
	label2.Text = string.format("%d m", (math.floor(v13 / meter + 0.5)))
	label3.Text = data.boostT and "BOOSTED"
		or UserInputService.TouchEnabled and "STEER   ·   BOOST"
		or "MOVE TO STEER   ·   CLICK TO BOOST"
	local textColor

	if data.boostT then
		textColor = Color3.fromRGB(255, 90, 70)
	else
		textColor = Style.WHITE
	end

	label3.TextColor3 = textColor

	local v14 = v13 * math.tan(math.rad(Hellfire.FOV) / 2)
	local v15 = Hellfire.RING / v14 * viewportSize.Y * 0.5
	ring.Size = UDim2.fromOffset(v15 * 2, v15 * 2)

	local name = localPlayer.Team and localPlayer.Team.Name
	local count = 0
	local function mark(position: Vector3, flag: boolean)
		local worldToViewportPoint, v16 = currentCamera:WorldToViewportPoint(position)

		if not v16 then
			return
		end

		count += 1
		local v17 = marker(count)
		v17.Visible = true
		v17.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
		local v18 = not flag
			and (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - viewportSize / 2).Magnitude < v15
		local v19 = if flag then color7 else color6
		local uiStroke = v17:FindFirstChildOfClass("UIStroke")
		uiStroke.Color = v19
		v17.BackgroundColor3 = v19
		v17.BackgroundTransparency = v18 and 0.1 or 1
	end

	for _, v16 in Players2:GetPlayers() do
		local character = v16.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if v16 ~= localPlayer and humanoid and humanoidRootPart and humanoid.Health > 0 and v16.Team then
			mark(humanoidRootPart.Position, v16.Team == localPlayer.Team)
		end
	end

	local botRigs = workspace:FindFirstChild("BotRigs")

	if botRigs then
		for _, model in botRigs:GetChildren() do
			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

			if not (model:IsA("Model") and model:GetAttribute("BotId") ~= nil and model:GetAttribute("Alive") == true and humanoidRootPart) then
				continue
			end

			if not humanoidRootPart:IsA("BasePart") then
				continue
			end

			local team = model:GetAttribute("Team")
			mark(humanoidRootPart.Position, name ~= nil and team == name)
		end
	end

	for i = count + 1, #v9 do
		v9[i].Visible = false
	end

	local v16 = os.clock() - (data.flashAt or -1)
	flash.BackgroundTransparency = not (v16 < 0.12) and 1 or 0.2 + v16 / 0.12 * 0.8
end

local function flyStep(p: number)
	local v13 = v7

	if not v13 then
		return
	end

	local f = v13.f
	local currentCamera = workspace.CurrentCamera
	local serverTimeNow = workspace:GetServerTimeNow()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		finishControl()
		return
	end

	if v13.phase == "wait" then
		if f.t0 - 0.12 <= serverTimeNow and not v13.cut then
			v13.cut = true
			local lastTime = os.clock()
			hellfireCut.Enabled = true
			frame.BackgroundTransparency = 0
			local renderSteppedConnection = nil
			local v14 = 0.12
			local v15 = 0.2
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v16 = os.clock() - lastTime

				if v16 < v14 then
					hellfireCut.Enabled = true
					frame.BackgroundTransparency = 0
				else
					local backgroundTransparency = math.clamp((v16 - v14) / v15, 0, 1)
					hellfireCut.Enabled = backgroundTransparency < 1
					frame.BackgroundTransparency = backgroundTransparency

					if backgroundTransparency >= 1 then
						renderSteppedConnection:Disconnect()
					end
				end
			end)
		end

		if serverTimeNow < f.t0 then
			return
		end

		v13.phase = "fly"
		v13.took = true
		v13.fov = currentCamera.FieldOfView
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and not humanoidRootPart.Anchored then
			humanoidRootPart.Anchored = true
			v13.anchored = true
		end

		humanoid:UnequipTools()
		ContextActionService:BindActionAtPriority("HellfireSink", sinkAction, false, 3000, table.unpack(v10))
		showWorld(true)
		boost.Visible = UserInputService.TouchEnabled
		v13.ground = groundBelow(v13.pos, f.start.Y - Hellfire.START_HEIGHT) -- inferred equivalent call
		VoxelSound.launch(v13.pos, f.sound)
		f.heard = true
	end

	if v13.phase == "fly" then
		v13.t = serverTimeNow - f.t0

		if character and character:FindFirstChildOfClass("Tool") then
			humanoid:UnequipTools()
		end

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		v13.groundAt -= p

		if v13.groundAt <= 0 then
			v13.groundAt = 0.15
			v13.ground = groundBelow(v13.pos, v13.ground) -- inferred equivalent call
		end

		local v14 = steerInput(v13)
		local v15 = (f.heading:Cross(Vector3.new(0, 1, 0)) * v14.X + f.heading * v14.Y) * Hellfire.steerSpeed(v13.pos.Y - v13.ground)
		v13.slide += (v15 - v13.slide) * (1 - math.exp(-Hellfire.STEER_RESPONSE * p))
		local fallSpeed = Hellfire.fallSpeed(v13.t, v13.boostT)
		local vel2 = v13.slide - Vector3.new(0, 1, 0) * fallSpeed
		local pos2 = v13.pos + vel2 * p

		local vector3 = Vector3.new(pos2.X - f.start.X, 0, pos2.Z - f.start.Z)

		if vector3.Magnitude > Hellfire.MAX_SPREAD then
			local v16 = vector3.Unit * Hellfire.MAX_SPREAD
			pos2 = Vector3.new(f.start.X + v16.X, pos2.Y, f.start.Z + v16.Z)
		end

		local pos3, v16 = strike(v13.pos, pos2 + vel2.Unit * 1.5)

		if pos3 and v16 then
			hellfire:FireServer("impact", f.id, pos3, v16)
			v13.phase = "hold"
			v13.holdAt = os.clock()
			v13.pos = pos3
			v13.vel = vel2
			VoxelSound.rocketEnd(f.sound)
			f.heard = false
		else
			v13.pos = pos2
			v13.vel = vel2

			if os.clock() - v13.sent >= 1 / Hellfire.POSE_RATE then
				v13.sent = os.clock()
				HellfirePose:FireServer(f.id, v13.pos, v13.vel)
			end

			VoxelSound.rocketMove(f.sound, v13.pos, v13.vel)
		end

		local pos = v13.pos
		local vel = v13.vel
		f.pos = pos
		f.vel = vel
		updateOverlay(v13, currentCamera)
	end

	if v13.phase == "hold" then
		local v14 = os.clock() - v13.holdAt

		if Hellfire.HOLD <= v14 and not v13.cut2 then
			v13.cut2 = true
			local CUT_OUT = Hellfire.CUT_OUT
			local lastTime = os.clock()
			hellfireCut.Enabled = true
			frame.BackgroundTransparency = 0
			local renderSteppedConnection = nil
			local v15 = 0.25
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v16 = os.clock() - lastTime

				if v16 < CUT_OUT then
					hellfireCut.Enabled = true
					frame.BackgroundTransparency = 0
				else
					local backgroundTransparency = math.clamp((v16 - CUT_OUT) / v15, 0, 1)
					hellfireCut.Enabled = backgroundTransparency < 1
					frame.BackgroundTransparency = backgroundTransparency

					if backgroundTransparency >= 1 then
						renderSteppedConnection:Disconnect()
					end
				end
			end)
		end

		if Hellfire.HOLD + 0.02 <= v14 then
			finishControl()
		end
	end
end

local function cameraStep()
	local v13 = v7

	if not (v13 and v13.took) then
		return
	end

	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = Hellfire.FOV
	local v14 = v13.pos + Vector3.new(0, 1, 0) * (v13.phase ~= "hold" and 4 or math.min((os.clock() - v13.holdAt) / Hellfire.HOLD, 1) * 30 + 26)
	currentCamera.CFrame = CFrame.lookAt(v14, v14 - Vector3.new(0, 1, 0), v13.f.heading)
end

local function begin(p)
	finishControl()
	v7 = {
		f = p,
		phase = "wait",
		t = 0,
		pos = p.start,
		vel = Vector3.new(0, 0, 0),
		slide = Vector3.new(0, 0, 0),
		mouse = Vector2.zero,
		boostT = nil,
		ground = p.start.Y - Hellfire.START_HEIGHT,
		groundAt = 0,
		sent = 0,
		took = false,
		anchored = false,
		cut = false,
		cut2 = false,
		holdAt = 0,
		flashAt = nil,
		fov = 70
	}

	RunService:BindToRenderStep("HellfireCamera", Enum.RenderPriority.Camera.Value + 20, function(p2)
		flyStep(p2)
		cameraStep()
	end)
end

local function poseAt(p, p2: number)
	local poses = p.poses

	if #poses == 0 then
		return nil, Vector3.new(0, 0, 0)
	end

	if p2 <= poses[1].t then
		return poses[1].pos, poses[1].vel
	end

	for i = #poses, 1, -1 do
		local pos = poses[i]

		if pos.t <= p2 then
			local pos2 = poses[i + 1]

			if not pos2 then
				return pos.pos + pos.vel * math.min(p2 - pos.t, 0.2), pos.vel
			end

			local v13 = (p2 - pos.t) / math.max(pos2.t - pos.t, 0.001)
			return pos.pos:Lerp(pos2.pos, v13), pos.vel:Lerp(pos2.vel, v13)
		end
	end

	return poses[1].pos, poses[1].vel
end

local renderSteppedConnection = nil
local function step()
	local now = os.clock()
	local v13 = nil
	local v14 = false

	for _, v15 in v8 do
		v14 = true

		if not v15.mine then
			local v16 = v15.start.Y - Hellfire.START_HEIGHT
			local v17 = 1 - math.clamp((v15.pos.Y - v16) / Hellfire.START_HEIGHT, 0, 1)
			v13 = math.max(v13 or 0, v17)
		end

		local pos = nil
		local vel = Vector3.new(0, 0, 0)

		if v15.mine and v7 and v7.f == v15 then
			vel = v15.vel
		elseif v15.poses[1] then
			pos, vel = poseAt(v15, now - 0.1)
		elseif workspace:GetServerTimeNow() >= v15.t0 then
			pos = v15.start
			vel = -Vector3.new(0, 1, 0)
		end

		if pos then
			v15.pos = pos
			v15.vel = vel

			if not v15.missile then
				v15.missile = table.remove(v2) or buildMissile()
				local missile = v15.missile
				place(missile, pos, vel) -- inferred equivalent call
				missile.smoke:Clear()

				local flame = missile.flame
				local light = missile.light
				local smoke = missile.smoke
				local mobile = Quality.mobile or Quality.potato
				flame.Enabled = true
				light.Enabled = not mobile
				smoke.Enabled = true
			end

			place(v15.missile, pos, vel) -- inferred equivalent call

			if not v15.heard then
				v15.heard = true
				VoxelSound.launch(pos, v15.sound)
			end

			VoxelSound.rocketMove(v15.sound, pos, vel)

			if not v15.whistled and vel.Y < -1 then
				local v16 = strike(pos, pos + vel.Unit * (-vel.Y * 1.4 * 1.2 + 4))

				if v16 then
					v15.whistled = true
					VoxelSound.bombFall(v16, (pos - v16).Magnitude / vel.Magnitude)
				end
			end
		end

		while #v15.poses > 2 and v15.poses[2].t < now - 0.1 - 0.3 do
			table.remove(v15.poses, 1)
		end
	end

	VoxelSound.hellfireRumble(v13)

	if not v14 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

HellfireState.OnClientEvent:Connect(function(p: string, id: number, pos, p2, p3, heading, t0)
	if p == "start" then
		local v13 = {
			id = id,
			mine = pos == localPlayer.Name,
			start = p3,
			heading = heading,
			t0 = t0,
			poses = {},
			boosted = false,
			missile = nil,
			sound = -100000 - id,
			heard = false,
			whistled = false,
			pos = p3,
			vel = Vector3.new(0, 0, 0)
		}

		v8[id] = v13

		if v13.mine then
			v13.whistled = true
			begin(v13)
		else
			local v14

			if localPlayer.Team == nil or p2 == nil then
				v14 = false
			else
				v14 = localPlayer.Team.Name == p2
			end

			if localPlayer.Team ~= nil then
				VoxelSound.hellfireAlert(not v14)
			end
		end

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end
	elseif p == "auto" then
		local v13 = v8[id]

		if v13 and v7 and v7.f == v13 and v7.phase ~= "hold" then
			local lastTime = os.clock()
			hellfireCut.Enabled = true
			frame.BackgroundTransparency = 0
			local renderSteppedConnection2 = nil
			local v14 = 0.15
			local v15 = 0.25
			renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
				local v16 = os.clock() - lastTime

				if v16 < v14 then
					hellfireCut.Enabled = true
					frame.BackgroundTransparency = 0
				else
					local backgroundTransparency = math.clamp((v16 - v14) / v15, 0, 1)
					hellfireCut.Enabled = backgroundTransparency < 1
					frame.BackgroundTransparency = backgroundTransparency

					if backgroundTransparency >= 1 then
						renderSteppedConnection2:Disconnect()
					end
				end
			end)

			finishControl()
		end
	else
		local v13 = p == "end" and v8[id]

		if v13 then
			v8[id] = nil
			release(v13) -- inferred equivalent call

			if v7 and v7.f == v13 and v7.phase ~= "hold" then
				v7.phase = "hold"
				v7.holdAt = os.clock()
				v7.pos = pos
			end
		end
	end
end)

HellfirePose.OnClientEvent:Connect(function(p: number, pos: Vector3, vel: Vector3, boosted: boolean)
	local v13 = v8[p]

	if not v13 then
		return
	end

	v13.boosted = boosted
	table.insert(v13.poses, { t = os.clock(), pos = pos, vel = vel })
end)

localPlayer.CharacterRemoving:Connect(function()
	finishControl()
end)

task.spawn(function()
	while #v2 < 2 do
		table.insert(v2, buildMissile())
		task.wait()
	end
end)