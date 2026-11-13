local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while LocalPlayer:GetAttribute("JoinCovered") == true do
	LocalPlayer:GetAttributeChangedSignal("JoinCovered"):Wait()
end

task.wait(1)

local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Players2 = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LookSettings = require(ReplicatedStorage2:WaitForChild("Voxel"):WaitForChild("LookSettings"))

local Gunship = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("Gunship"))
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local VoxelProp = require(Voxel:WaitForChild("VoxelProp"))
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local AudioGraph = require(Voxel:WaitForChild("AudioGraph"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Quality = require(Voxel:WaitForChild("Quality"))
local Style = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Style"))
local Remotes = ReplicatedStorage.Game:WaitForChild("Remotes")
local gunship = Remotes:WaitForChild("Gunship")
local GunshipState = Remotes:WaitForChild("GunshipState")

local localPlayer = Players2.LocalPlayer
local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local meter = WorldConfig.METER
local v = 343 * meter
local cframe = CFrame.new(0, workspace.FallenPartsDestroyHeight + 60, 0)

local v2 = { 6, 11 }

local v3 = {
	id = 9112812185,
	from = 2,
	to = 34,
	gain = 0.5,
	cutoff = 1500
}
local v4 = {
	heavy = {
		id = 9114361763,
		at = 0,
		length = 3,
		gain = 1.3,
		speed = 0.78
	},
	cannon = {
		id = 9114361755,
		at = 0,
		length = 0.9,
		gain = 0.9,
		speed = 0.95
	},
	auto = {
		id = 84103293274638,
		at = 0,
		length = 0.4,
		gain = 0.55,
		speed = 0.92
	}
}

VoxelSound.addSamples({ v4.heavy.id, v4.cannon.id }, 3)
VoxelSound.addSamples({ v4.auto.id }, 6)

local gunships = Instance.new("Folder")
gunships.Name = "Gunships"
gunships.Parent = workspace

local color = Color3.fromRGB(104, 108, 110)
local color2 = Color3.fromRGB(78, 82, 86)
local color3 = Color3.fromRGB(88, 92, 96)
local color4 = Color3.fromRGB(30, 38, 46)
local color5 = Color3.fromRGB(36, 38, 40)
local color6 = Color3.fromRGB(46, 46, 46)
local v5 = { -14, -7.5, 7.5, 14 }
local v6 = {
	{ y = -0.75, z = -4 },
	{ y = -0.5, z = 1.5 }
}

local function bodyR(z: number) -- 1 equivalent call inferred from this helper
	if z < -19 or z > 17.5 then
		return nil
	end

	if z < -15 then
		return (z + 19) / 4 * 2 + 0.8
	end

	if z < 8 then
		return 2.8
	end

	return 2.8 - (z - 8) / 9.5 * 1.6
end

local function planeShape(vector3: Vector3)
	local x = vector3.X
	local y = vector3.Y
	local z = vector3.Z
	local v7 = math.abs(x)

	for _, v8 in v6 do
		if x > 2.2 and x < 4 and math.abs(y - v8.y) < 0.3 and math.abs(z - v8.z) < 0.3 then
			return color5
		end
	end

	local v8 = bodyR(z) -- inferred equivalent call

	if v8 then
		local v9 = not (z > 8) and 0 or (z - 8) * 0.18
		local v10 = (y - v9) / 0.95

		if x * x + v10 * v10 <= v8 * v8 then
			if z < -16.5 and v9 + 0.6 < y then
				return color4
			end

			if y < v9 - 1.4 then
				return color3
			end

			if z > -14 and z < 8 and (z + 14) % 5.5 < 0.5 then
				return color2
			end

			return color
		end
	end

	if y >= 2.4 and y < 3.1 and v7 <= 25 then
		local v9 = v7 * 0.04 + -4.5
		local v10 = 1.5 - v7 * 0.04

		if v9 <= z and z <= v10 then
			return if v10 - 0.6 < z then color2 else color
		end
	end

	for _, v9 in v5 do
		local v10 = x - v9
		local v11 = y - 1.9
		local v12 = v10 * v10 + v11 * v11

		if z >= -8 and z <= -0.5 and v12 <= 0.9025 then
			return if z < -7.4 then color5 else color2
		elseif z >= -8.7 and z < -8 and v12 <= 7.290000000000001 and (math.abs(v10) < 0.28 or math.abs(v11) < 0.28) then
			return color6
		end
	end

	if v7 < 0.3 and y >= 2 and y <= 9 and (y - 2) * 0.55 + 11 <= z and z <= 17.5 then
		return color
	end

	if y >= 2.2 and y < 2.7 and v7 <= 8 and v7 * 0.15 + 13 <= z and z <= 17.2 then
		return color
	end

	return nil
end

local v7 = nil
local flag = false
local function ensureBaked() -- 1 equivalent call inferred from this helper
	if v7 then
		return
	end

	if flag then
		repeat
			task.wait()
		until v7
	else
		flag = true
		v7 = VoxelProp.bake(Vector3.new(104, 22, 76), Vector3.new(-26, -3.5, -19.5), VOXEL_SIZE, planeShape)
	end
end

local function buildPlane()
	ensureBaked() -- inferred equivalent call
	local v8 = v7
	local part = VoxelProp.part(v8, "Gunship")
	part.CastShadow = false
	part.CFrame = cframe
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, -1, 14) - v8.center
	attachment.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 236, 190), Color3.fromRGB(255, 140, 60))
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 1) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(2.2, 3.2)
	particleEmitter.Speed = NumberRange.new(25, 45)
	particleEmitter.SpreadAngle = Vector2.new(55, 55)
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.Acceleration = Vector3.new(0, -22, 0)
	particleEmitter.Drag = 0.6
	particleEmitter.Rate = 0
	particleEmitter.Parent = attachment
	local flash = Instance.new("Part")
	flash.Name = "Flash"
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanQuery = false
	flash.CanTouch = false
	flash.CastShadow = false
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 214, 150)
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(3, 3, 3)
	flash.Transparency = 1
	flash.CFrame = cframe
	flash.Parent = gunships
	part.Parent = gunships
	return {
		body = part,
		offset = CFrame.new(v8.center),
		flares = particleEmitter,
		flash = flash,
		flashT = 1
	}
end

local v8 = {}
local function parkPlane(plane) -- 1 equivalent call inferred from this helper
	plane.body.CFrame = cframe
	plane.flash.CFrame = cframe
	plane.flash.Transparency = 1
	plane.flashT = 1
	plane.flares:Clear()
	table.insert(v8, plane)
end

local function planeFrame(planeAt: Vector3, vector3: Vector3) -- 1 equivalent call inferred from this helper
	local v9 = not (vector3.Magnitude > 1) and Vector3.new(0, 0, 1) or vector3.Unit
	return CFrame.lookAt(planeAt, planeAt + v9) * CFrame.Angles(0, 0, -0.24434609527920614)
end

local v9 = {
	{ width = 1.6, len = 40, color = Color3.fromRGB(255, 226, 170) },
	{ width = 0.9, len = 26, color = Color3.fromRGB(255, 214, 150) },
	{ width = 0.45, len = 16, color = Color3.fromRGB(255, 200, 130) }
}

local parts = {}

local function tracerPart()
	local v10 = table.remove(parts)

	if v10 then
		return v10
	end

	local tracer = Instance.new("Part")
	tracer.Name = "Tracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanQuery = false
	tracer.CanTouch = false
	tracer.CastShadow = false
	tracer.Material = Enum.Material.Neon
	tracer.CFrame = cframe
	tracer.Parent = gunships
	return tracer
end

local function release(state) -- 1 equivalent call inferred from this helper
	if state.plane then
		parkPlane(state.plane) -- inferred equivalent call
		state.plane = nil
	end

	if state.heard then
		VoxelSound.jetEnd(-500000 - state.id)
		state.heard = false
	end
end

local gunshipView = Instance.new("ScreenGui")
gunshipView.Name = "GunshipView"
gunshipView.ResetOnSpawn = false
gunshipView.IgnoreGuiInset = true
gunshipView.DisplayOrder = 40
gunshipView.Enabled = false
gunshipView.Parent = localPlayer:WaitForChild("PlayerGui")

local hazard = Style.HAZARD

local function bar(name: string, p: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0, p)
	frame.Position = UDim2.fromScale(0, p)
	frame.Size = UDim2.fromScale(1, 0.085)
	frame.Parent = gunshipView
	return frame
end

local v10 = bar("Top", 0)
local parent2 = bar("Bottom", 1)
local label = Style.label(v10, "Title", "GUNSHIP", 18, Style.FONT, 1.5)
label.AnchorPoint = Vector2.new(0, 0.5)
label.Position = UDim2.new(0, 24, 0.5, 0)
label.TextColor3 = hazard
local label2 = Style.label(v10, "Time", "", 18, Style.FONT, 1.5)
label2.AnchorPoint = Vector2.new(1, 0.5)
label2.Position = UDim2.new(1, -24, 0.5, 0)
local label3 = Style.label(v10, "Takedowns", "", 18, Style.FONT, 1.5)
label3.AnchorPoint = Vector2.new(0.5, 0.5)
label3.Position = UDim2.fromScale(0.5, 0.5)
local label4 = Style.label(gunshipView, "Help", "", 14, Style.FONT, 1.5)
label4.AnchorPoint = Vector2.new(0.5, 1)
label4.Position = UDim2.new(0.5, 0, 0.915, -8)
label4.TextColor3 = Style.WHITE

local guns = Instance.new("Frame")
guns.Name = "Guns"
guns.BackgroundTransparency = 1
guns.AnchorPoint = Vector2.new(0.5, 0.5)
guns.Position = UDim2.fromScale(0.5, 0.5)
guns.Size = UDim2.new(0, 474, 0.8, 0)
guns.Parent = parent2
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 12)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = guns
local v11 = {}
local v12 = nil
local v13 = {}
local v14 = {}

for k, v15 in Gunship.GUNS do
	local textButton = Instance.new("TextButton")
	textButton.Name = v15.name
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Active = false
	textButton.LayoutOrder = k
	textButton.Size = UDim2.new(0, 150, 1, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(20, 21, 23)
	textButton.BackgroundTransparency = 0.25
	textButton.BorderSizePixel = 0
	textButton.Parent = guns
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = hazard
	uiStroke.Transparency = 1
	uiStroke.Parent = textButton
	local label5 = Style.label(textButton, "Name", k .. "  " .. v15.name, 14, Style.FONT, 1)
	label5.Position = UDim2.fromOffset(8, 2)
	local label6 = Style.label(textButton, "Count", "", 14, Style.FONT, 1)
	label6.AnchorPoint = Vector2.new(1, 0)
	label6.Position = UDim2.new(1, -8, 0, 2)
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0, 1)
	track.Position = UDim2.new(0, 8, 1, -6)
	track.Size = UDim2.new(1, -16, 0, 6)
	track.BackgroundColor3 = Color3.fromRGB(60, 62, 66)
	track.BorderSizePixel = 0
	track.Parent = textButton
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = hazard
	fill.BorderSizePixel = 0
	fill.Parent = track
	v11[k] = {
		frame = textButton,
		stroke = uiStroke,
		name = label5,
		fill = fill,
		count = label6
	}
end

local function line(parent, size: UDim2, position: UDim2) -- 12 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Style.WHITE
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = size
	frame.Position = position
	frame.Parent = parent
	return frame
end

local v15 = {}

for i = 1, #Gunship.GUNS do
	local frame = Instance.new("Frame")
	frame.Name = "Reticle" .. i
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(120, 120)
	frame.Visible = false
	frame.Parent = gunshipView
	v15[i] = frame
end

local parent = v15[1]

for _, v16 in {
	{ -1, -1 },
	{ 1, -1 },
	{ -1, 1 },
	{ 1, 1 }
} do
	local v17 = 0.5 + v16[1] * 0.38
	local v18 = 0.5 + v16[2] * 0.38
	line(parent, UDim2.fromOffset(22, 3), UDim2.new(v17, -v16[1] * 10, v18, 0)) -- inferred equivalent call
	line(parent, UDim2.fromOffset(3, 22), UDim2.new(v17, 0, v18, -v16[2] * 10)) -- inferred equivalent call
end

line(parent, UDim2.fromOffset(5, 5), UDim2.fromScale(0.5, 0.5)) -- inferred equivalent call

local parent3 = v15[2]
local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(46, 46)
frame.Parent = parent3
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.5, 0)
uiCorner.Parent = frame
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Style.WHITE
uiStroke.Thickness = 2
uiStroke.Parent = frame
line(parent3, UDim2.fromOffset(14, 2), UDim2.new(0.5, -32, 0.5, 0)) -- inferred equivalent call
line(parent3, UDim2.fromOffset(14, 2), UDim2.new(0.5, 32, 0.5, 0)) -- inferred equivalent call
line(parent3, UDim2.fromOffset(2, 14), UDim2.new(0.5, 0, 0.5, -32)) -- inferred equivalent call
line(parent3, UDim2.fromOffset(2, 14), UDim2.new(0.5, 0, 0.5, 32)) -- inferred equivalent call
line(parent3, UDim2.fromOffset(3, 3), UDim2.fromScale(0.5, 0.5)) -- inferred equivalent call

local parent4 = v15[3]
line(parent4, UDim2.fromOffset(10, 2), UDim2.new(0.5, -10, 0.5, 0)) -- inferred equivalent call
line(parent4, UDim2.fromOffset(10, 2), UDim2.new(0.5, 10, 0.5, 0)) -- inferred equivalent call
line(parent4, UDim2.fromOffset(2, 10), UDim2.new(0.5, 0, 0.5, -10)) -- inferred equivalent call
line(parent4, UDim2.fromOffset(2, 10), UDim2.new(0.5, 0, 0.5, 10)) -- inferred equivalent call

local color7 = Color3.fromRGB(255, 60, 50)
local color8 = Color3.fromRGB(90, 230, 120)
local v16 = {}
local function marker(count: number)
	local marker2 = v16[count]

	if marker2 then
		return marker2
	end

	marker2 = Instance.new("Frame")
	marker2.Name = "Marker"
	marker2.AnchorPoint = Vector2.new(0.5, 0.5)
	marker2.Size = UDim2.fromOffset(12, 12)
	marker2.Rotation = 45
	marker2.BackgroundTransparency = 1
	marker2.BorderSizePixel = 0
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Parent = marker2
	marker2.Parent = gunshipView
	v16[count] = marker2

	return marker2
end

local flash = Instance.new("Frame")
flash.Name = "Flash"
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 5
flash.Parent = gunshipView

local gunshipCut = Instance.new("ScreenGui")
gunshipCut.Name = "GunshipCut"
gunshipCut.ResetOnSpawn = false
gunshipCut.IgnoreGuiInset = true
gunshipCut.DisplayOrder = 42
gunshipCut.Enabled = false
gunshipCut.Parent = localPlayer:WaitForChild("PlayerGui")
local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromScale(1, 1)
frame2.BackgroundColor3 = Color3.new(0, 0, 0)
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.Parent = gunshipCut

local function seatPanels(active: boolean)
	local size

	if active then
		size = UDim2.new(1, 0, 0, 76)
	else
		size = UDim2.fromScale(1, 0.085)
	end

	parent2.Size = size

	v10.BackgroundTransparency = active and 1 or 0.12
	parent2.BackgroundTransparency = active and 1 or 0.12
	guns.AnchorPoint = Vector2.new(0.5, active and 0 or 0.5)
	local position

	if active then
		position = UDim2.new(0.5, 0, 0, 6)
	else
		position = UDim2.fromScale(0.5, 0.5)
	end

	guns.Position = position
	local size2

	if active then
		size2 = UDim2.new(0, 416, 0, 52)
	else
		size2 = UDim2.new(0, 474, 0.8, 0)
	end

	guns.Size = size2
	uiListLayout.Padding = UDim.new(0, active and 10 or 12)

	for _, v17 in v11 do
		v17.frame.Size = UDim2.new(0, active and 132 or 150, 1, 0)
		v17.frame.Active = active
	end

	label4.Visible = not active
end

local gunshipGrade = Instance.new("ColorCorrectionEffect")
gunshipGrade.Name = "GunshipGrade"
gunshipGrade.Saturation = -1
gunshipGrade.Contrast = 0.4
gunshipGrade.Brightness = 0.04
gunshipGrade.TintColor = Color3.fromRGB(232, 236, 222)
gunshipGrade.Enabled = false
gunshipGrade.Parent = Lighting

local flat = AudioGraph.flat("GunshipDrone")
flat.player.Asset = "rbxassetid://" .. 9112812185
flat.player.Looping = true
flat.player.LoopRegion = NumberRange.new(2, 34)
flat.player.Volume = 0
AudioGraph.lowpass(flat, 1500)

local v17 = {
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
	Enum.KeyCode.Q,
	Enum.KeyCode.E,
	Enum.KeyCode.R,
	Enum.KeyCode.F,
	Enum.KeyCode.G,
	Enum.KeyCode.C,
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.UserInputType.MouseWheel,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight
}

local function pickGun(p, gun: number) -- 6 equivalent calls inferred from this helper
	if p.gun ~= gun then
		p.gun = gun
		VoxelSound.designator("tick")
	end
end

local function sinkAction(_: string, p, data)
	local v18 = v12

	if not v18 or v18.phase ~= "fly" then
		return Enum.ContextActionResult.Sink
	end

	local userInputType = data.UserInputType
	local keyCode = data.KeyCode

	if userInputType == Enum.UserInputType.MouseButton1 or keyCode == Enum.KeyCode.ButtonR2 then
		local firing

		if p == Enum.UserInputState.Begin then
			firing = true
		else
			firing = p == Enum.UserInputState.Change and v18.firing
		end

		v18.firing = firing
	elseif p == Enum.UserInputState.Begin then
		if keyCode == Enum.KeyCode.One then
			pickGun(v18, 1) -- inferred equivalent call
		elseif keyCode == Enum.KeyCode.Two then
			pickGun(v18, 2) -- inferred equivalent call
		elseif keyCode == Enum.KeyCode.Three then
			pickGun(v18, 3) -- inferred equivalent call
		elseif keyCode == Enum.KeyCode.Q or keyCode == Enum.KeyCode.ButtonY or keyCode == Enum.KeyCode.ButtonL1 then
			pickGun(v18, v18.gun % #Gunship.GUNS + 1) -- inferred equivalent call
		end
	elseif userInputType == Enum.UserInputType.MouseWheel and p == Enum.UserInputState.Change then
		local v19 = data.Position.Z < 0 and 1 or -1
		pickGun(v18, (v18.gun - 1 + v19) % #Gunship.GUNS + 1) -- inferred equivalent call
	end

	return Enum.ContextActionResult.Sink
end

for k, v18 in v11 do
	v18.frame.Activated:Connect(function()
		local v19 = v12

		if v19 and v19.phase == "fly" then
			pickGun(v19, k) -- inferred equivalent call
		end
	end)
end

local v18 = {
	{
		name = "GunshipFire",
		slot = "fire",
		glyph = "FIRE",
		look = true,
		hold = function(flag2: boolean)
			local v18 = v12

			if v18 then
				v18.firing = flag2 and v18.phase == "fly"
			end
		end
	}
}

local v19 = { on = false, was = nil }
local function touchAim(on: boolean)
	if on == v19.on then
		return
	end

	v19.on = on

	if on then
		v19.was = TouchControls.getVehicle()
		TouchControls.setVehicle(v18)
		TouchControls.setLookSink(function(vector2: Vector2)
			local v20 = v12

			if v20 and v20.phase == "fly" then
				v20.touch += vector2
			end
		end)
	else
		TouchControls.setLookSink(nil)
		TouchControls.setVehicle(v19.was)
		v19.was = nil
	end
end

local v20 = {
	CombatFeedback = true,
	SkirmishFeed = true,
	SkirmishPoints = true,
	TouchControls = true
}

local displayOrdersByScreenGui = {}
local function liftKept(flag2: boolean)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if flag2 and playerGui then
		for _, screenGui in playerGui:GetChildren() do
			if not (screenGui:IsA("ScreenGui") and v20[screenGui.Name] and displayOrdersByScreenGui[screenGui] == nil) then
				continue
			end

			displayOrdersByScreenGui[screenGui] = screenGui.DisplayOrder
			screenGui.DisplayOrder = 41
		end
	elseif not flag2 then
		for k, displayOrder in displayOrdersByScreenGui do
			k.DisplayOrder = displayOrder
		end

		table.clear(displayOrdersByScreenGui)
	end
end
local screenGuis = {}

local function hideOthers()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	liftKept(true)

	for _, screenGui in playerGui:GetChildren() do
		if
			not screenGui:IsA("ScreenGui")
			or screenGui == gunshipView
			or screenGui == gunshipCut
			or v20[screenGui.Name]
		then
			continue
		end

		if not (screenGui.Name ~= "TouchLook" and screenGui.Enabled) then
			continue
		end

		screenGui.Enabled = false

		if not table.find(screenGuis, screenGui) then
			table.insert(screenGuis, screenGui)
		end
	end
end
local v21 = nil
local function showWorld(enabled: boolean) -- 1 equivalent call inferred from this helper
	gunshipView.Enabled = enabled
	gunshipGrade.Enabled = enabled

	if not enabled then
		localPlayer:FindFirstChildOfClass("PlayerGui")

		for k, displayOrder in displayOrdersByScreenGui do
			k.DisplayOrder = displayOrder
		end

		table.clear(displayOrdersByScreenGui)
	end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if enabled and atmosphere and not v21 then
		v21 = { density = atmosphere.Density, haze = atmosphere.Haze }
		atmosphere.Density = math.min(atmosphere.Density, 0.1)
		atmosphere.Haze = 0
	elseif not enabled and v21 then
		if atmosphere then
			local density = v21.density
			local haze = v21.haze
			atmosphere.Density = density
			atmosphere.Haze = haze
		end

		v21 = nil
	end

	if enabled then
		flat.player.Volume = 0.5
		flat.player.TimePosition = 2 + math.random() * 30
		flat.player:Play()
		hideOthers()
	else
		flat.player:Stop()

		for _, v22 in screenGuis do
			if v22.Parent then
				v22.Enabled = true
			end
		end

		table.clear(screenGuis)
	end
end

local function cutBlack(p: number, p2: number)
	local lastTime = os.clock()
	gunshipCut.Enabled = true
	frame2.BackgroundTransparency = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v22 = os.clock() - lastTime

		if v22 < p then
			gunshipCut.Enabled = true
			frame2.BackgroundTransparency = 0
		else
			local backgroundTransparency = math.clamp((v22 - p) / p2, 0, 1)
			gunshipCut.Enabled = backgroundTransparency < 1
			frame2.BackgroundTransparency = backgroundTransparency

			if backgroundTransparency >= 1 then
				renderSteppedConnection:Disconnect()
			end
		end
	end)
end

local function finishControl()
	local v22 = v12

	if not v22 then
		return
	end

	v12 = nil

	gunshipView.Enabled = false

	if v19.on ~= false then
		v19.on = false

		TouchControls.setLookSink(nil)
		TouchControls.setVehicle(v19.was)
		v19.was = nil
	end

	ContextActionService:UnbindAction("GunshipSink")
	RunService:UnbindFromRenderStep("GunshipCamera")
	showWorld(false) -- inferred equivalent call

	if v22.killConn then
		v22.killConn:Disconnect()
	end

	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and v22.anchored then
		humanoidRootPart.Anchored = false
	end

	if v22.took then
		currentCamera.FieldOfView = v22.fov

		if humanoid and humanoid.Health > 0 then
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = humanoid
		end
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	if v22.took then
		task.delay(0.3, function()
			if not v12 and Viewmodel.current == nil then
				UserInputService.MouseIconEnabled = true
			end
		end)
	end
end

local function groundPoint(vector3: Vector3, aim: Vector3, y: number) -- 2 equivalent calls inferred from this helper
	if aim.Y > -0.001 then
		return nil
	end

	return vector3 + aim * ((y - vector3.Y) / aim.Y)
end

local function clampCone(unit: Vector3, lookVector: Vector3)
	local AIM_CONE = math.rad(Gunship.AIM_CONE)

	if math.acos((math.clamp(unit:Dot(lookVector), -1, 1))) <= AIM_CONE then
		return lookVector
	end

	local v22 = lookVector - unit * unit:Dot(lookVector)

	if v22.Magnitude < 0.0001 then
		return unit
	end

	return (unit * math.cos(AIM_CONE) + v22.Unit * math.sin(AIM_CONE)).Unit
end

local function gunReady(state, gun: number, p: number): boolean -- 1 equivalent call inferred from this helper
	local gun2 = state.guns[gun]

	if not (gun2.ammo <= 0) then
		return gun2.nextAt <= p
	end

	if p < gun2.reloadAt then
		return false
	end

	gun2.ammo = Gunship.GUNS[gun].rounds

	return gun2.nextAt <= p
end

local function shoot(state, now: number)
	local gun = state.gun
	local v22 = Gunship.GUNS[gun]
	local gun2 = state.guns[gun]

	if not gunReady(state, gun, now) then -- inferred equivalent call
		return
	end

	gun2.ammo -= 1
	gun2.nextAt = now + v22.interval

	if gun2.ammo <= 0 then
		gun2.reloadAt = now + v22.reload
	end

	gunship:FireServer("fire", state.s.id, gun, state.aim)

	local v23 = v4[v22.key]
	local currentCamera = workspace.CurrentCamera
	VoxelSound.oneShotAt(
		v23.id,
		v23.at,
		v23.length,
		currentCamera.CFrame.Position + currentCamera.CFrame.RightVector * 3,
		v23.gain,
		v23.speed * (0.96 + math.random() * 0.04)
	)
	state.kick = math.min(state.kick + v22.shake, 1.5)

	if gun == 1 then
		state.flashAt = os.clock()
	end
end

local v22 = {}
local function put(p, p2: string, p3) -- 20 equivalent calls inferred from this helper
	local v23 = v22[p]

	if not v23 then
		v23 = {}
		v22[p] = v23
	end

	if v23[p2] ~= p3 then
		v23[p2] = p3
		p[p2] = p3
	end
end
local color9 = Color3.fromRGB(150, 150, 150)
local v23 = -1
local v24 = {}

local function updateOverlay(data, currentCamera, now: number)
	local v25 = math.max(0, Gunship.DURATION - data.t)
	local v26 = math.floor(v25 / 60)
	local v27 = math.floor(v25 % 60)

	if v26 * 60 + v27 ~= v23 then
		v23 = v26 * 60 + v27
		put(label2, "Text", string.format("%d:%02d", v26, v27)) -- inferred equivalent call
	end

	local v28 = if v25 < 6 then Style.ORANGE else Style.WHITE
	put(label2, "TextColor3", v28) -- inferred equivalent call
	put(label3, "Text", not (data.kills > 0) and "" or data.kills .. (data.kills == 1 and " KILL" or " KILLS")) -- inferred equivalent call
	put( -- inferred equivalent call
		label4,
		"Text",
		UserInputService.TouchEnabled and "DRAG TO AIM   ·   FIRE   ·   SWITCH GUNS" or "MOUSE TO AIM   ·   CLICK TO FIRE   ·   1 2 3 / Q / WHEEL TO SWITCH"
	)

	for k, v29 in v11 do
		local v30 = Gunship.GUNS[k]
		local gun = data.guns[k]
		local v31 = k == data.gun
		put(v29.stroke, "Transparency", v31 and 0 or 1) -- inferred equivalent call
		put(v29.frame, "BackgroundTransparency", v31 and 0.05 or 0.35) -- inferred equivalent call

		if gun.ammo <= 0 and now < gun.reloadAt then
			local v32 = 1 - (gun.reloadAt - now) / v30.reload
			put(v29.fill, "Size", UDim2.fromScale(math.clamp(v32, 0, 1), 1)) -- inferred equivalent call
			put(v29.fill, "BackgroundColor3", color9) -- inferred equivalent call
			put(v29.count, "Text", "RELOAD") -- inferred equivalent call
			put(v29.count, "TextColor3", Style.ORANGE) -- inferred equivalent call
		else
			local v32 = if gun.ammo <= 0 then v30.rounds else gun.ammo
			put(v29.fill, "Size", UDim2.fromScale(v32 / v30.rounds, 1)) -- inferred equivalent call
			put(v29.fill, "BackgroundColor3", hazard) -- inferred equivalent call
			put(v29.count, "Text", not (v30.rounds > 1) and "READY" or tostring(v32)) -- inferred equivalent call
			put(v29.count, "TextColor3", Style.WHITE) -- inferred equivalent call
		end

		put(v15[k], "Visible", v31) -- inferred equivalent call
	end

	local name = localPlayer.Team and localPlayer.Team.Name
	local count = 0
	local y = currentCamera.ViewportSize.Y
	local function mark(position: Vector3, flag2: boolean)
		local worldToViewportPoint, v29 = currentCamera:WorldToViewportPoint(position)
		local v30 = v10.BackgroundTransparency >= 1 and 0 or y * 0.085

		if not v29 or worldToViewportPoint.Y < v30 or worldToViewportPoint.Y > y - parent2.AbsoluteSize.Y then
			return
		end

		count += 1
		local v31 = marker(count)
		put(v31, "Visible", true) -- inferred equivalent call
		put(v31, "Position", UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)) -- inferred equivalent call
		local v32 = v24[v31]

		if not v32 then
			v32 = v31:FindFirstChildOfClass("UIStroke")
			v24[v31] = v32
		end

		local v38 = if flag2 then color8 else color7
		put(v32, "Color", v38) -- inferred equivalent call
	end

	for _, v29 in Players2:GetPlayers() do
		local character = v29.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if v29 ~= localPlayer and humanoid and humanoidRootPart and humanoid.Health > 0 and v29.Team then
			mark(humanoidRootPart.Position, v29.Team == localPlayer.Team)
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

			mark(humanoidRootPart.Position, name ~= nil and model:GetAttribute("Team") == name)
		end
	end

	for i = count + 1, #v16 do
		put(v16[i], "Visible", false) -- inferred equivalent call
	end

	local v29 = os.clock() - (data.flashAt or -1)
	put(flash, "BackgroundTransparency", not (v29 < 0.35) and 1 or 0.35 + v29 / 0.35 * 0.65) -- inferred equivalent call
end

local function aimInput(state, p: number)
	local v25 = UserInputService:GetMouseDelta() * 0.0018

	if UserInputService.GamepadEnabled then
		for _, v26 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
			if v26.KeyCode == Enum.KeyCode.Thumbstick2 and v26.Position.Magnitude > 0.15 then
				v25 += Vector2.new(v26.Position.X, -v26.Position.Y) * 0.8 * LookSettings.look * p
			end
		end
	end

	local v26 = v25 + state.touch * 0.0025 * LookSettings.look
	state.touch = Vector2.zero
	return v26 * (Gunship.GUNS[state.gun].fov / Gunship.GUNS[1].fov) * (Gunship.VIEW_RANGE / state.dist)
end

local function viewStep(p: number)
	local v25 = v12

	if not v25 then
		return
	end

	local s = v25.s
	local currentCamera = workspace.CurrentCamera
	local serverTimeNow = workspace:GetServerTimeNow()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		finishControl()
		return
	end

	if v25.phase == "wait" then
		if s.t0 - 0.15 <= serverTimeNow and not v25.cut then
			v25.cut = true
			local lastTime = os.clock()
			gunshipCut.Enabled = true
			frame2.BackgroundTransparency = 0
			local renderSteppedConnection = nil
			local v26 = 0.15
			local v27 = 0.3
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v28 = os.clock() - lastTime

				if v28 < v26 then
					gunshipCut.Enabled = true
					frame2.BackgroundTransparency = 0
				else
					local backgroundTransparency = math.clamp((v28 - v26) / v27, 0, 1)
					gunshipCut.Enabled = backgroundTransparency < 1
					frame2.BackgroundTransparency = backgroundTransparency

					if backgroundTransparency >= 1 then
						renderSteppedConnection:Disconnect()
					end
				end
			end)
		end

		if serverTimeNow < s.t0 then
			return
		end

		v25.phase = "fly"
		v25.took = true
		v25.fov = currentCamera.FieldOfView
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and not humanoidRootPart.Anchored then
			humanoidRootPart.Anchored = true
			v25.anchored = true
		end

		humanoid:UnequipTools()
		ContextActionService:BindActionAtPriority("GunshipSink", sinkAction, false, 3000, table.unpack(v17))
		gunshipView.Enabled = true
		gunshipGrade.Enabled = true

		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		if atmosphere and not v21 then
			v21 = { density = atmosphere.Density, haze = atmosphere.Haze }
			atmosphere.Density = math.min(atmosphere.Density, 0.1)
			atmosphere.Haze = 0
		end

		flat.player.Volume = v3.gain
		flat.player.TimePosition = v3.from + math.random() * (v3.to - v3.from - 2)
		flat.player:Play()
		hideOthers()

		seatPanels(TouchControls.active())

		if v19.on ~= true then
			v19.on = true

			v19.was = TouchControls.getVehicle()
			TouchControls.setVehicle(v18)
			TouchControls.setLookSink(function(vector2: Vector2)
				local v26 = v12

				if v26 and v26.phase == "fly" then
					v26.touch += vector2
				end
			end)
		end

		local planeAt = Gunship.planeAt(s.centre, s.phase, 0)
		v25.aim = (s.centre - planeAt).Unit
		v25.kills0 = tonumber(localPlayer:GetAttribute("Takedowns")) or 0
		v25.killConn = localPlayer:GetAttributeChangedSignal("Takedowns"):Connect(function()
			local kills = (tonumber(localPlayer:GetAttribute("Takedowns")) or 0) - v25.kills0

			if v25.kills < kills then
				v25.kills = kills
			end
		end)
	end

	if v25.phase == "fly" then
		v25.t = serverTimeNow - s.t0

		if character and character:FindFirstChildOfClass("Tool") then
			humanoid:UnequipTools()
		end

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
		local eye = Gunship.planeAt(s.centre, s.phase, v25.t) - Vector3.new(0, 3, 0)

		local v26 = groundPoint(v25.eye or eye, v25.aim, s.centre.Y) -- inferred equivalent call
		local v27

		if v26 then
			v27 = (v26 - eye).Unit
		else
			v27 = v25.aim
		end

		local v28 = aimInput(v25, p)
		local v29 = CFrame.lookAt(eye, eye + v27) * CFrame.Angles(0, -v28.X, 0) * CFrame.Angles(-v28.Y, 0, 0)
		v25.aim = clampCone((s.centre - eye).Unit, v29.LookVector)
		v25.eye = eye

		local v30 = groundPoint(eye, v25.aim, s.centre.Y) -- inferred equivalent call
		local dist

		if v30 then
			dist = math.max((v30 - eye).Magnitude, Gunship.VIEW_RANGE)
		else
			dist = Gunship.VIEW_RANGE
		end

		v25.dist = dist
		v25.cam = eye + v25.aim * (v25.dist - Gunship.VIEW_RANGE)
		hideOthers()
		local now = os.clock()

		if v25.firing then
			shoot(v25, now)
		end

		v25.kick *= math.exp(-p * 7)
	end
end

local function cameraStep()
	local v25 = v12

	if not v25 or not v25.took or v25.phase ~= "fly" then
		return
	end

	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = Gunship.GUNS[v25.gun].fov
	local cam = v25.cam
	local cframe2 = CFrame.lookAt(cam, cam + v25.aim)

	if v25.kick > 0.01 then
		local kick = v25.kick
		cframe2 *= CFrame.Angles((math.random() - 0.5) * 0.012 * kick, (math.random() - 0.5) * 0.012 * kick, 0)
	end

	currentCamera.CFrame = cframe2
end

local function begin(p)
	finishControl()
	local guns2 = {}

	for k, v25 in Gunship.GUNS do
		guns2[k] = { ammo = v25.rounds, nextAt = 0, reloadAt = 0 }
	end

	v12 = {
		s = p,
		phase = "wait",
		t = 0,
		gun = 1,
		guns = guns2,
		aim = Vector3.new(0, -1, 0),
		eye = nil,
		cam = nil,
		dist = 760,
		firing = false,
		touch = Vector2.zero,
		kick = 0,
		flashAt = nil,
		kills = 0,
		kills0 = 0,
		killConn = nil,
		took = false,
		anchored = false,
		cut = false,
		fov = 70
	}

	RunService:BindToRenderStep("GunshipCamera", Enum.RenderPriority.Camera.Value + 20, function(p2)
		viewStep(p2)
		cameraStep()

		local v25 = v12

		if v25 and v25.took and v25.phase == "fly" then
			updateOverlay(v25, workspace.CurrentCamera, os.clock())
		end
	end)
end

local renderSteppedConnection = nil
local function step()
	local serverTimeNow = workspace:GetServerTimeNow()
	local now = os.clock()
	local v25 = false

	for _, v26 in v13 do
		v25 = true
		local v27 = serverTimeNow - v26.t0

		if v27 < 0 then
			continue
		end

		local planeAt, v28 = Gunship.planeAt(v26.centre, v26.phase, v27)
		local v29 = v12

		if v29 then
			if v12.s == v26 then
				v29 = v12.phase == "fly"
			else
				v29 = false
			end
		end

		if not v26.plane then
			v26.plane = table.remove(v8) or buildPlane()
		end

		local plane = v26.plane

		local body = plane.body
		local cframe2

		if v29 then
			cframe2 = cframe
		else
			cframe2 = planeFrame(planeAt, v28) * plane.offset -- inferred equivalent call
		end

		body.CFrame = cframe2

		if v29 then
			if v26.heard then
				VoxelSound.jetEnd(-500000 - v26.id)
				v26.heard = false
			end
		else
			v26.heard = true
			VoxelSound.jet(-500000 - v26.id, planeAt, v28)

			if v26.nextFlares <= now then
				v26.nextFlares = now + v2[1] + math.random() * (v2[2] - v2[1])

				plane.flares:Emit((math.max(2, (math.floor(8 * Quality.share() + 0.5)))))
			end
		end

		if not (plane.flashT < 1) then
			continue
		end

		plane.flashT = math.min(1, plane.flashT + 0.25)
		plane.flash.Transparency = plane.flashT
	end

	local v26 = 1

	while v26 <= #v14 do
		local v27 = v14[v26]
		local v28 = (serverTimeNow - v27.t0) / math.max(v27.t1 - v27.t0, 0.001)

		if v28 >= 1 then
			v27.part.CFrame = cframe
			table.insert(parts, v27.part)
			table.remove(v14, v26)
		else
			local unit = (v27.to - v27.from).Unit
			local lerped = v27.from:Lerp(v27.to, (math.max(v28, 0)))
			local v29 = lerped - unit * math.min(v27.len, (lerped - v27.from).Magnitude)
			local midpoint = (lerped + v29) / 2
			local shown = math.max((lerped - v29).Magnitude, 0.5)

			if shown ~= v27.shown then
				v27.shown = shown
				v27.part.Size = Vector3.new(v27.width, v27.width, shown)
			end

			v27.part.CFrame = CFrame.lookAt(midpoint, lerped)

			v26 += 1
			v25 = true
		end
	end

	if not v25 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end
local function ensureStep() -- 2 equivalent calls inferred from this helper
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

GunshipState.OnClientEvent:Connect(function(p: string, id: number, p2, position, p3, phase, t0)
	if p == "start" then
		local v25 = {
			id = id,
			mine = p2 == localPlayer.Name,
			centre = p3,
			phase = phase,
			t0 = t0,
			plane = nil,
			nextFlares = os.clock() + 2 + math.random() * 3,
			heard = false
		}

		v13[id] = v25

		if v25.mine then
			begin(v25)
		end

		ensureStep() -- inferred equivalent call
	elseif p == "shot" then
		local v25 = v13[id]

		if not v25 then
			return
		end

		local v26 = v9[p2]

		if not v26 then
			return
		end

		local tracer = table.remove(parts)

		if not tracer then
			tracer = Instance.new("Part")
			tracer.Name = "Tracer"
			tracer.Anchored = true
			tracer.CanCollide = false
			tracer.CanQuery = false
			tracer.CanTouch = false
			tracer.CastShadow = false
			tracer.Material = Enum.Material.Neon
			tracer.CFrame = cframe
			tracer.Parent = gunships
		end

		tracer.Color = v26.color
		tracer.Size = Vector3.new(v26.width, v26.width, v26.len)
		local serverTimeNow = workspace:GetServerTimeNow()
		table.insert(v14, {
			part = tracer,
			from = position,
			to = p3,
			t0 = serverTimeNow,
			t1 = math.max(phase, serverTimeNow + 0.05),
			len = v26.len,
			width = v26.width,
			shown = v26.len
		})
		ensureStep() -- inferred equivalent call

		if not v12 or v12.s ~= v25 then
			local plane = v25.plane

			if plane then
				plane.flash.CFrame = CFrame.new(position)
				plane.flash.Size = Vector3.new(1, 1, 1) * (4 - p2)
				plane.flash.Transparency = 0
				plane.flashT = 0
			end

			local magnitude = (position - workspace.CurrentCamera.CFrame.Position).Magnitude
			local v27 = v4[Gunship.GUNS[p2].key]
			local v28 = v27.gain * 0.35 * math.min(1, 160 / (magnitude / meter))
			task.delay(magnitude / v, function()
				VoxelSound.oneShotAt(v27.id, v27.at, v27.length, position, v28, v27.speed * 0.9)
			end)
		end
	else
		local v25 = p == "end" and v13[id]

		if v25 then
			v13[id] = nil
			release(v25) -- inferred equivalent call

			if v12 and v12.s == v25 then
				local CUT_OUT = Gunship.CUT_OUT
				local lastTime = os.clock()
				gunshipCut.Enabled = true
				frame2.BackgroundTransparency = 0
				local renderSteppedConnection2 = nil
				local v26 = 0.3
				renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
					local v27 = os.clock() - lastTime

					if v27 < CUT_OUT then
						gunshipCut.Enabled = true
						frame2.BackgroundTransparency = 0
					else
						local backgroundTransparency = math.clamp((v27 - CUT_OUT) / v26, 0, 1)
						gunshipCut.Enabled = backgroundTransparency < 1
						frame2.BackgroundTransparency = backgroundTransparency

						if backgroundTransparency >= 1 then
							renderSteppedConnection2:Disconnect()
						end
					end
				end)

				task.delay(0.03, finishControl)
			end
		end
	end
end)

localPlayer.CharacterRemoving:Connect(function()
	finishControl()
end)

task.spawn(function()
	table.insert(v8, buildPlane())
end)