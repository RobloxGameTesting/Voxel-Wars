local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Game = ReplicatedStorage:WaitForChild("Game")
local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local EmplacementData = require(Game:WaitForChild("EmplacementData"))
local EmplacementRemotes = Game:WaitForChild("EmplacementRemotes")
local EmplacementSeat = EmplacementRemotes:WaitForChild("EmplacementSeat")
local EmplacementFire = EmplacementRemotes:WaitForChild("EmplacementFire")
local EmplacementAim = EmplacementRemotes:WaitForChild("EmplacementAim")

local Detail = require(Voxel:WaitForChild("Detail"))
local Tracers = require(Voxel:WaitForChild("Tracers"))
local ImpactFX = require(Voxel:WaitForChild("ImpactFX"))
local VoxelSound = require(Voxel:WaitForChild("VoxelSound"))
local TouchControls = require(Voxel:WaitForChild("TouchControls"))
local LookSettings = require(Voxel:WaitForChild("LookSettings"))
local MenuLock = require(Voxel:WaitForChild("MenuLock"))
local AimKey = require(Voxel:WaitForChild("AimKey"))
local VR = require(Voxel:WaitForChild("VR"))
local SeatButton = require(Voxel:WaitForChild("SeatButton"))
local EnterButton = require(Voxel:WaitForChild("EnterButton"))
local RigidParts = require(ReplicatedStorage:WaitForChild("Vehicles"):WaitForChild("RigidParts"))
local Glyph = require(script.Parent:WaitForChild("GameUI"):WaitForChild("Glyph"))

local gun = EmplacementData.GUN

local v = {
	follow = 14,
	rest = 0.001,
	aimSend = 1 / 15,
	kick = 0.1,
	kickBack = 18,
	flash = 0.045,
	jolt = 0.035,
	scopeFov = 22,
	scopeTime = 0.2,
	mouseTurn = 0.0035,
	padTurn = 3.2,
	padDead = 0.15,
	eye = CFrame.new(0, 1.45, 2.55),
	sightEye = CFrame.new(0, 0.5, -0.7)
}

local v2 = {
	lens = 0.36,
	ring = 1.12,
	from = 0.45,
	to = 0.8,
	dark = 0.03,
	mask = Color3.fromRGB(4, 4, 6),
	rim = Color3.fromRGB(46, 50, 56),
	ink = Color3.fromRGB(10, 10, 12),
	dot = Color3.fromRGB(255, 60, 48)
}

local v3 = {
	steel = Color3.fromRGB(52, 56, 62),
	black = Color3.fromRGB(28, 28, 30),
	olive = Color3.fromRGB(88, 96, 72),
	lens = Color3.fromRGB(64, 104, 124),
	flash = Color3.fromRGB(255, 214, 140),
	light = Color3.fromRGB(255, 196, 120),
	Reds = Color3.fromRGB(186, 64, 50),
	Blues = Color3.fromRGB(58, 104, 170)
}

local v4 = {
	panel = Color3.fromRGB(24, 25, 28),
	white = Color3.fromRGB(242, 238, 228),
	hazard = Color3.fromRGB(255, 198, 32),
	danger = Color3.fromRGB(214, 72, 52),
	font = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
}

local random = Random.new()
local function wrap(p: number) -- 1 equivalent call inferred from this helper
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

local function yawOf(vector3: Vector3) -- 2 equivalent calls inferred from this helper
	return (math.atan2(-vector3.X, -vector3.Z))
end

local v5 = {}
local parent2 = nil

local v6 = {
	view = nil,
	yaw = 0,
	pitch = 0,
	zoom = 0,
	heat = 0,
	heatAt = 0,
	last = 0,
	nextAt = 0,
	locked = false,
	shots = 0,
	firing = false,
	autoFire = false,
	touchFire = false,
	touchScope = false,
	aimHeld = false,
	lastLook = nil,
	baseFov = nil,
	cursorHidden = false,
	shake = CFrame.identity,
	hintUntil = 0,
	aimSentAt = 0,
	askedAt = 0,
	leftAt = 0,
	controls = nil,
	controlsOff = false
}

local function block(model, name: string, size: Vector3, color: Color3) -- 4 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Parent = model
	return part
end

local newVector3 = Vector3.new
local newCFrame = CFrame.new

local v7 = {
	{ "Foot", Vector3.new(1.9, 0.5, 1.9), "steel", newCFrame(0, -3.35, 0) },
	{ "Post", Vector3.new(0.5, 2.5, 0.5), "steel", newCFrame(0, -2.05, 0) },
	{ "Collar", Vector3.new(0.82, 0.26, 0.82), "black", newCFrame(0, -0.86, 0) }
}

local v8 = {
	{ "Swivel", Vector3.new(0.7, 0.3, 0.7), "steel", newCFrame(0, -0.6, 0) },
	{ "CheekL", Vector3.new(0.14, 0.92, 0.5), "steel", newCFrame(-0.3, -0.2, 0) },
	{ "CheekR", Vector3.new(0.14, 0.92, 0.5), "steel", newCFrame(0.3, -0.2, 0) },
	{ "ShieldL", Vector3.new(0.95, 1.1, 0.14), "olive", newCFrame(-0.74, 0.12, -0.78) },
	{ "ShieldR", Vector3.new(0.95, 1.1, 0.14), "olive", newCFrame(0.74, 0.12, -0.78) },
	{ "BandL", Vector3.new(0.99, 0.14, 0.18), "team", newCFrame(-0.74, 0.62, -0.78) },
	{ "BandR", Vector3.new(0.99, 0.14, 0.18), "team", newCFrame(0.74, 0.62, -0.78) }
}

local v9 = {
	{ "Receiver", Vector3.new(0.42, 0.5, 1.7), "olive", newCFrame(0, 0, 0.15) },
	{ "Jacket", Vector3.new(0.27, 0.27, 1.4), "steel", newCFrame(0, 0, -1.25) },
	{ "Barrel", Vector3.new(0.16, 0.16, 1.1), "black", newCFrame(0, 0, -2.4) },
	{ "Brake", Vector3.new(0.25, 0.25, 0.3), "steel", newCFrame(0, 0, -3) },
	{ "Neck", Vector3.new(0.2, 0.2, 0.14), "steel", newCFrame(0, 0, 1.04) },
	{ "Grips", Vector3.new(0.5, 0.52, 0.12), "black", newCFrame(0, 0, 1.15) },
	{ "ScopeMount", Vector3.new(0.14, 0.2, 0.6), "steel", newCFrame(0, 0.31, 0.3) },
	{ "Scope", Vector3.new(0.24, 0.24, 1.2), "black", newCFrame(0, 0.5, 0.25) },
	{ "ScopeBell", Vector3.new(0.32, 0.32, 0.34), "black", newCFrame(0, 0.5, -0.45) },
	{ "ScopeEye", Vector3.new(0.3, 0.3, 0.2), "black", newCFrame(0, 0.5, 0.86) },
	{ "ScopeKnob", Vector3.new(0.12, 0.12, 0.12), "steel", newCFrame(0, 0.66, 0.2) },
	{ "ScopeLens", Vector3.new(0.26, 0.26, 0.04), "lens", newCFrame(0, 0.5, -0.63) },
	{ "AmmoBox", Vector3.new(0.44, 0.5, 0.7), "olive", newCFrame(-0.68, -0.04, 0.12) },
	{ "Belt", Vector3.new(0.26, 0.1, 0.3), "black", newCFrame(-0.36, 0.12, 0.12) }
}

local step

local function add(configuration)
	if v5[configuration] then
		return
	end

	local id = configuration:GetAttribute("Id")
	local team = configuration:GetAttribute("Team")
	local pivot = configuration:GetAttribute("Pivot")
	local look = configuration:GetAttribute("Look")
	local v10 = typeof(id) == "number" and typeof(pivot) == "Vector3" and typeof(look) == "Vector3"
	assert(v10, "[EmplacementClient] gun " .. configuration.Name .. " has no Id / Pivot / Look")
	local v11 = v3[team]
	assert(
		typeof(v11) == "Color3",
		"[EmplacementClient] gun " .. configuration.Name .. " has no side colour for " .. tostring(team)
	)

	if not parent2 then
		local emplacementGuns = Instance.new("Folder")
		emplacementGuns.Name = "EmplacementGuns"
		emplacementGuns.Parent = workspace
		parent2 = emplacementGuns
	end

	local base = EmplacementData.base(pivot, look)
	local model = Instance.new("Model")
	model.Name = configuration.Name
	local function colorOf(p: string) -- 3 equivalent calls inferred from this helper
		if p == "team" then
			return v11
		end

		return v3[p]
	end

	for _, v12 in v7 do
		local part = block(model, v12[1], v12[2], colorOf(v12[3])) -- inferred equivalent call
		part.CFrame = base * v12[4]
	end

	local root = RigidParts.root(model, "Yoke")

	for _, v12 in v8 do
		RigidParts.weld(root, block(model, v12[1], v12[2], colorOf(v12[3])), v12[4]) -- inferred equivalent call
	end

	local root2 = RigidParts.root(model, "Cradle")

	for _, v12 in v9 do
		RigidParts.weld(root2, block(model, v12[1], v12[2], colorOf(v12[3])), v12[4]) -- inferred equivalent call
	end

	local v12 = block(model, "Flash", Vector3.new(0.5, 0.5, 0.7), v3.flash) -- inferred equivalent call
	v12.Material = Enum.Material.Neon
	v12.Transparency = 1
	v12.CastShadow = false
	local pointLight = Instance.new("PointLight")
	pointLight.Color = v3.light
	pointLight.Range = 10
	pointLight.Brightness = 3
	pointLight.Enabled = false
	pointLight.Parent = v12
	RigidParts.weld(root2, v12, newCFrame(0, 0, EmplacementData.MUZZLE.Z - 0.4))
	model.Parent = parent2
	local aim = configuration:GetAttribute("Aim")
	local gunner = configuration:GetAttribute("Gunner")
	local v13 = {
		config = configuration,
		id = id,
		team = team,
		base = base,
		pivot = pivot,
		gunner = typeof(gunner) ~= "number" and 0 or gunner,
		aim = typeof(aim) ~= "Vector3" and Vector3.new(0, 0, 0) or aim,
		yaw = 0,
		pitch = 0,
		kick = 0,
		model = model,
		yoke = root,
		cradle = root2,
		flash = v12,
		light = pointLight,
		flashAt = -1,
		flashOn = nil,
		nextShot = 0,
		posed = false,
		conns = {}
	}

	local x = v13.aim.X
	local y = v13.aim.Y
	v13.yaw = x
	v13.pitch = y
	table.insert(v13.conns, configuration:GetAttributeChangedSignal("Aim"):Connect(function()
		local aim2 = configuration:GetAttribute("Aim")

		if typeof(aim2) == "Vector3" then
			v13.aim = aim2
		end
	end))
	table.insert(v13.conns, configuration:GetAttributeChangedSignal("Gunner"):Connect(function()
		local gunner2 = configuration:GetAttribute("Gunner")
		v13.gunner = typeof(gunner2) ~= "number" and 0 or gunner2
	end))
	local v14 = next(v5) == nil
	v5[configuration] = v13

	if v14 then
		RunService:BindToRenderStep("Emplacements", Enum.RenderPriority.Camera.Value + 2, step)
	end
end

local stopManning
local v10 = {}

local function drop(p)
	local v11 = v5[p]

	if not v11 then
		return
	end

	if v6.view == v11 then
		stopManning()
	end

	v5[p] = nil

	for _, conn in v11.conns do
		conn:Disconnect()
	end

	v11.model:Destroy()

	if next(v5) == nil then
		RunService:UnbindFromRenderStep("Emplacements")
		EnterButton.set("gun", nil)
		Glyph.claim("gun", false)

		if v10.gui then
			v10.gui.Enabled = false
			v10.state = nil
		end
	end
end

local function label(parent, text: string, textSize: number, position: UDim2, anchorPoint: Vector2)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = v4.font
	textLabel.TextColor3 = v4.white
	textLabel.TextSize = textSize
	textLabel.Text = text
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Position = position
	textLabel.AnchorPoint = anchorPoint
	textLabel.Parent = parent
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Transparency = 0.5
	uiStroke.Parent = textLabel
	return textLabel
end

local function plate(parent, size: UDim2, position: UDim2, anchorPoint: Vector2)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchorPoint
	frame.BackgroundColor3 = v4.panel
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local tab = Instance.new("Frame")
	tab.Name = "Tab"
	tab.Size = UDim2.new(0, 22, 0, 4)
	tab.BackgroundColor3 = v4.hazard
	tab.BorderSizePixel = 0
	tab.Parent = frame
	return frame
end

local v11 = {}

local emplacementHud = Instance.new("ScreenGui")
emplacementHud.Name = "EmplacementHud"
emplacementHud.ResetOnSpawn = false
emplacementHud.IgnoreGuiInset = true
emplacementHud.DisplayOrder = 7
emplacementHud.Enabled = false
emplacementHud.Parent = LocalPlayer:WaitForChild("PlayerGui")
v11.gui = emplacementHud
local parent3 = plate(emplacementHud, UDim2.fromOffset(124, 38), UDim2.new(0.5, 0, 0.5, 64), Vector2.new(0.5, 0))
label(parent3, "GUN", 13, UDim2.fromOffset(12, 20), Vector2.new(0, 0.5))
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -56, 0, 6)
frame.Position = UDim2.new(0, 44, 0, 17)
frame.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
frame.BorderSizePixel = 0
frame.Parent = parent3
local frame2 = Instance.new("Frame")
frame2.Size = UDim2.fromScale(0, 1)
frame2.BackgroundColor3 = v4.white
frame2.BorderSizePixel = 0
frame2.Parent = frame
v11.bar = frame2
local status = label(emplacementHud, "GUN HOT", 16, UDim2.new(0.5, 0, 0.5, 58), Vector2.new(0.5, 1))
status.TextColor3 = v4.danger
status.Visible = false
v11.status = status
local hint = label(emplacementHud, "", 14, UDim2.new(0.5, 0, 0.5, 110), Vector2.new(0.5, 0))
hint.TextTransparency = 0.15
v11.hint = hint
local frame3 = Instance.new("Frame")
frame3.Size = UDim2.fromOffset(34, 34)
frame3.Position = UDim2.fromScale(0.5, 0.5)
frame3.AnchorPoint = Vector2.new(0.5, 0.5)
frame3.BackgroundTransparency = 1
frame3.Parent = emplacementHud
v11.reticle = frame3
local bits = {}

for _, v12 in {
	{ 0.5, 0, 3, 9 },
	{ 0.5, 1, 3, 9 },
	{ 0, 0.5, 9, 3 },
	{ 1, 0.5, 9, 3 },
	{ 0.5, 0.5, 4, 4 }
} do
	local frame4 = Instance.new("Frame")
	frame4.Size = UDim2.fromOffset(v12[3], v12[4])
	frame4.Position = UDim2.fromScale(v12[1], v12[2])
	frame4.AnchorPoint = Vector2.new(v12[1], v12[2])
	frame4.BackgroundColor3 = v4.white
	frame4.BorderSizePixel = 0
	frame4.Parent = frame3
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = v4.panel
	uiStroke.Transparency = 0.4
	uiStroke.Parent = frame4
	table.insert(bits, frame4)
end

v11.bits = bits
v11.sent = {}

local v12 = { alpha = 0, vp = Vector2.zero, hid = false, fade = {} }

local emplacementScope = Instance.new("ScreenGui")
emplacementScope.Name = "EmplacementScope"
emplacementScope.ResetOnSpawn = false
emplacementScope.IgnoreGuiInset = true
emplacementScope.DisplayOrder = 5
emplacementScope.Enabled = false
emplacementScope.Parent = LocalPlayer:WaitForChild("PlayerGui")
v12.gui = emplacementScope
local function frame4(emplacementScope2, backgroundColor: Color3, dark: number, zIndex: number) -- 12 equivalent calls inferred from this helper
	local frame5 = Instance.new("Frame")
	frame5.BackgroundColor3 = backgroundColor
	frame5.BackgroundTransparency = 1
	frame5.BorderSizePixel = 0
	frame5.ZIndex = zIndex
	frame5.Parent = emplacementScope2
	table.insert(v12.fade, { frame5, "BackgroundTransparency", dark })
	return frame5
end

local function round(parent, color: Color3, p: number, zIndex: number)
	local frame5 = Instance.new("Frame")
	frame5.BackgroundTransparency = 1
	frame5.BorderSizePixel = 0
	frame5.AnchorPoint = Vector2.new(0.5, 0.5)
	frame5.ZIndex = zIndex
	frame5.Parent = parent
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = frame5
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Transparency = 1
	uiStroke.Parent = frame5
	table.insert(v12.fade, { uiStroke, "Transparency", p })
	return frame5, uiStroke
end

local frame6 = frame4(emplacementScope, v2.mask, v2.dark, 1) -- inferred equivalent call
local frame7 = frame4(emplacementScope, v2.mask, v2.dark, 1) -- inferred equivalent call
local frame8 = frame4(emplacementScope, v2.mask, v2.dark, 1) -- inferred equivalent call
local frame9 = frame4(emplacementScope, v2.mask, v2.dark, 1) -- inferred equivalent call
local v13 = { frame6, frame7, frame8, frame9 }

local frame5 = Instance.new("Frame")
frame5.BackgroundTransparency = 1
frame5.BorderSizePixel = 0
frame5.ClipsDescendants = true
frame5.Parent = emplacementScope
local parent, v14 = round(frame5, v2.mask, v2.dark, 1)
parent.Position = UDim2.fromScale(0.5, 0.5)
local parent4, v15 = round(emplacementScope, v2.rim, 0, 2)
local frame10 = frame4(emplacementScope, v2.ink, 0.1, 3) -- inferred equivalent call
local frame11 = frame4(emplacementScope, v2.ink, 0.1, 3) -- inferred equivalent call
local frame12 = frame4(emplacementScope, v2.ink, 0.1, 3) -- inferred equivalent call
local frame13 = frame4(emplacementScope, v2.ink, 0.1, 3) -- inferred equivalent call
local v16 = { frame10, frame11, frame12, frame13 }
local frame14 = frame4(emplacementScope, v2.ink, 0, 3) -- inferred equivalent call
local frame15 = frame4(emplacementScope, v2.ink, 0, 3) -- inferred equivalent call
local frame16 = frame4(emplacementScope, v2.ink, 0, 3) -- inferred equivalent call
local v17 = { frame14, frame15, frame16 }
local parent5 = frame4(emplacementScope, v2.dot, 0, 4) -- inferred equivalent call
parent5.AnchorPoint = Vector2.new(0.5, 0.5)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.5, 0)
uiCorner.Parent = parent5
local fromOffset = UDim2.fromOffset
function v12.layout(vector2: Vector2)
	local v18 = math.floor(vector2.X / 2)
	local v19 = math.floor(vector2.Y / 2)
	local v20 = math.floor(vector2.Y * v2.lens)
	local v21 = math.floor(v20 * v2.ring)

	local v22 = v13[1]
	local v23 = v13[1]
	local udim = fromOffset(-4, -4)
	local udim2 = fromOffset(v18 - v21 + 4, vector2.Y + 8)
	v22.Position = udim
	v23.Size = udim2
	local v24 = v13[2]
	local v25 = v13[2]
	local udim3 = fromOffset(v18 + v21, -4)
	local udim4 = fromOffset(vector2.X - v18 - v21 + 4, vector2.Y + 8)
	v24.Position = udim3
	v25.Size = udim4
	local v26 = v13[3]
	local v27 = v13[3]
	local udim5 = fromOffset(v18 - v21, -4)
	local udim6 = fromOffset(v21 * 2, v19 - v21 + 4)
	v26.Position = udim5
	v27.Size = udim6
	local v28 = v13[4]
	local v29 = v13[4]
	local udim7 = fromOffset(v18 - v21, v19 + v21)
	local udim8 = fromOffset(v21 * 2, vector2.Y - v19 - v21 + 4)
	v28.Position = udim7
	v29.Size = udim8
	local udim9 = fromOffset(v18 - v21, v19 - v21)
	local udim10 = fromOffset(v21 * 2, v21 * 2)
	frame5.Position = udim9
	frame5.Size = udim10
	parent.Size = fromOffset(v20 * 2, v20 * 2)
	v14.Thickness = math.ceil(v21 * 1.4143 - v20) + 2
	local udim11 = fromOffset(v18, v19)
	local udim12 = fromOffset(v20 * 2, v20 * 2)
	parent4.Position = udim11
	parent4.Size = udim12
	v15.Thickness = math.max(2, (math.floor(v20 * 0.03)))
	local v30 = math.max(1, (math.floor(vector2.Y / 540 + 0.5)))
	local v31 = math.max(3, (math.floor(v20 * 0.024)))
	local v32 = math.floor(v20 * 0.05)
	local v52 = math.floor(v20 * 0.5)
	local v53 = v16[1]
	local v54 = v16[1]
	local v55 = v16[1]
	local vector2_2 = Vector2.new(1, 0.5)
	local udim13 = fromOffset(v18 - v32, v19)
	local udim14 = fromOffset(v20 - v32, v30)
	v53.AnchorPoint = vector2_2
	v54.Position = udim13
	v55.Size = udim14
	local v56 = v16[2]
	local v57 = v16[2]
	local v58 = v16[2]
	local vector2_3 = Vector2.new(0, 0.5)
	local udim15 = fromOffset(v18 + v32, v19)
	local udim16 = fromOffset(v20 - v32, v30)
	v56.AnchorPoint = vector2_3
	v57.Position = udim15
	v58.Size = udim16
	local v59 = v16[3]
	local v60 = v16[3]
	local v61 = v16[3]
	local vector2_4 = Vector2.new(0.5, 1)
	local udim17 = fromOffset(v18, v19 - v32)
	local udim18 = fromOffset(v30, v20 - v32)
	v59.AnchorPoint = vector2_4
	v60.Position = udim17
	v61.Size = udim18
	local v62 = v16[4]
	local v63 = v16[4]
	local v64 = v16[4]
	local vector2_5 = Vector2.new(0.5, 0)
	local udim19 = fromOffset(v18, v19 + v32)
	local udim20 = fromOffset(v30, v20 - v32)
	v62.AnchorPoint = vector2_5
	v63.Position = udim19
	v64.Size = udim20
	local v65 = v17[1]
	local v66 = v17[1]
	local v67 = v17[1]
	local vector2_6 = Vector2.new(1, 0.5)
	local udim21 = fromOffset(v18 - v52, v19)
	local udim22 = fromOffset(v20 - v52, v31)
	v65.AnchorPoint = vector2_6
	v66.Position = udim21
	v67.Size = udim22
	local v68 = v17[2]
	local v69 = v17[2]
	local v70 = v17[2]
	local vector2_7 = Vector2.new(0, 0.5)
	local udim23 = fromOffset(v18 + v52, v19)
	local udim24 = fromOffset(v20 - v52, v31)
	v68.AnchorPoint = vector2_7
	v69.Position = udim23
	v70.Size = udim24
	local v71 = v17[3]
	local v72 = v17[3]
	local v73 = v17[3]
	local vector2_8 = Vector2.new(0.5, 0)
	local udim25 = fromOffset(v18, v19 + v52)
	local udim26 = fromOffset(v31, v20 - v52)
	v71.AnchorPoint = vector2_8
	v72.Position = udim25
	v73.Size = udim26
	local v74 = math.max(4, (math.floor(v20 * 0.022)))
	local udim27 = fromOffset(v18, v19)
	local udim28 = fromOffset(v74, v74)
	parent5.Position = udim27
	parent5.Size = udim28
end

local function showScope(p, alpha: number)
	if alpha > 0 then
		local viewportSize = workspace.CurrentCamera.ViewportSize

		if viewportSize ~= v12.vp then
			v12.vp = viewportSize
			v12.layout(viewportSize)
		end
	end

	if alpha == v12.alpha then
		return
	end

	v12.alpha = alpha
	v12.gui.Enabled = alpha > 0

	for _, v18 in v12.fade do
		v18[1][v18[2]] = 1 - alpha * (1 - v18[3])
	end

	local hid = alpha >= 0.5

	if hid ~= v12.hid then
		v12.hid = hid

		for _, part in p.model:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = hid and 1 or 0
			end
		end
	end
end

local emplacementPrompt = Instance.new("ScreenGui")
emplacementPrompt.Name = "EmplacementPrompt"
emplacementPrompt.ResetOnSpawn = false
emplacementPrompt.IgnoreGuiInset = true
emplacementPrompt.DisplayOrder = 7
emplacementPrompt.Enabled = false
emplacementPrompt.Parent = LocalPlayer:WaitForChild("PlayerGui")
local parent6 = plate(emplacementPrompt, UDim2.fromOffset(0, 34), UDim2.new(0.5, 0, 1, -162), Vector2.new(0.5, 1))
parent6.AutomaticSize = Enum.AutomaticSize.X
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 12)
uiPadding.PaddingRight = UDim.new(0, 12)
uiPadding.Parent = parent6
local text = label(parent6, "", 18, UDim2.new(0, 0, 0.5, 0), Vector2.new(0, 0.5))
text.TextXAlignment = Enum.TextXAlignment.Left
local cap = Glyph.cap(parent6, nil, nil, 24)
cap.AnchorPoint = Vector2.new(0, 0.5)
cap.Position = UDim2.fromScale(0, 0.5)
v10.gui = emplacementPrompt
v10.text = text
v10.cap = cap
v10.state = nil

local function myBody()
	local character = LocalPlayer.Character

	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return character, humanoid, humanoidRootPart
	end

	return character, humanoid, nil
end

local v18 = { char = nil, parts = {}, dirty = true }
local function setCharacterShown(flag: boolean)
	local character = LocalPlayer.Character

	if not character then
		return
	end

	if character ~= v18.char then
		v18.char = character
		v18.dirty = true
		character.DescendantAdded:Connect(function()
			v18.dirty = true
		end)
		character.DescendantRemoving:Connect(function()
			v18.dirty = true
		end)
	end

	if v18.dirty then
		v18.dirty = false
		table.clear(v18.parts)

		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				table.insert(v18.parts, descendant)
			end
		end
	end

	local localTransparencyModifier = flag and 0 or 1

	for _, part in v18.parts do
		if part.LocalTransparencyModifier ~= localTransparencyModifier then
			part.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function setControls(flag: boolean)
	if not v6.controls then
		local playerModule = LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("PlayerModule")

		if not playerModule then
			return
		end

		local module = require(playerModule)
		v6.controls = module:GetControls()
	end

	if flag and v6.controlsOff then
		v6.controlsOff = false
		v6.controls:Enable()
	elseif not (flag or v6.controlsOff) then
		v6.controlsOff = true
		v6.controls:Disable()
	end
end

local function startManning(view)
	v6.view = view
	local clamped, pitch = EmplacementData.clamp(view.yaw, view.pitch)
	v6.yaw = clamped
	v6.pitch = pitch
	v6.zoom = 0
	v6.firing = false
	v6.autoFire = false
	v6.touchFire = false
	v6.touchScope = false
	v6.aimHeld = false
	local identity = CFrame.identity
	v6.lastLook = nil
	v6.shake = identity
	v6.hintUntil = os.clock() + 6
	LocalPlayer:SetAttribute("InVehicle", "gun")
	local character = LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local _ = humanoidRootPart and humanoidRootPart:IsA("BasePart")
	end

	if humanoid then
		humanoid.AutoRotate = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		humanoid:UnequipTools()
	end

	setControls(false)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	v11.gui.Enabled = true

	TouchControls.setGunAim({
		aim = function()
			return v6.zoom
		end,
		range = 500,
		fire = function(autoFire: boolean)
			v6.autoFire = autoFire
		end
	})
end

stopManning = function()
	local view = v6.view

	if not view then
		return
	end

	showScope(view, 0)
	v6.view = nil
	v6.leftAt = os.clock()
	v6.firing = false
	v6.zoom = 0
	v6.autoFire = false
	v6.touchFire = false
	v6.touchScope = false
	v6.aimHeld = false
	v6.shake = CFrame.identity
	TouchControls.setGunAim(nil)
	v11.gui.Enabled = false

	if LocalPlayer:GetAttribute("InVehicle") == "gun" then
		LocalPlayer:SetAttribute("InVehicle", nil)
	end

	if v6.controls then
		if v6.controlsOff then
			v6.controlsOff = false
			v6.controls:Enable()
		end
	else
		local playerModule = LocalPlayer:WaitForChild("PlayerScripts"):FindFirstChild("PlayerModule")

		if playerModule then
			local module = require(playerModule)
			v6.controls = module:GetControls()

			if v6.controlsOff then
				v6.controlsOff = false
				v6.controls:Enable()
			end
		end
	end

	local currentCamera = workspace.CurrentCamera

	if v6.baseFov then
		currentCamera.FieldOfView = v6.baseFov
		v6.baseFov = nil
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	local character = LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local _ = humanoidRootPart and humanoidRootPart:IsA("BasePart")
	end

	if humanoid then
		currentCamera.CameraSubject = humanoid
		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end

	if v6.cursorHidden then
		UserInputService.MouseIconEnabled = true
		v6.cursorHidden = false
	end

	setCharacterShown(true)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v19 = 0
local function refreshAim(aimSentAt: number)
	if aimSentAt - v19 <= 0.5 then
		return
	end

	v19 = aimSentAt
	local excludeInstances = {}

	if parent2 then
		table.insert(excludeInstances, parent2)
	end

	if LocalPlayer.Character then
		table.insert(excludeInstances, LocalPlayer.Character)
	end

	for _, childName in {
		"VoxelTracers",
		"VoxelLoose",
		"VoxelChips",
		"VoxelFalling",
		"VoxelBombs",
		"VoxelAtmosphere"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(excludeInstances, child)
		end
	end

	if workspace.CurrentCamera then
		table.insert(excludeInstances, workspace.CurrentCamera)
	end

	raycastParams.ExcludeInstances = excludeInstances
end

local function padStick()
	if not UserInputService.GamepadEnabled or MenuLock.held then
		return Vector2.zero
	end

	for _, v20 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
		if v20.KeyCode == Enum.KeyCode.Thumbstick2 then
			local vector2 = Vector2.new(v20.Position.X, v20.Position.Y)

			if vector2.Magnitude > v.padDead then
				return vector2
			end

			return Vector2.zero
		end
	end

	return Vector2.zero
end

local function camera(view, p: number)
	local currentCamera = workspace.CurrentCamera

	if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
		currentCamera.CameraType = Enum.CameraType.Scriptable
	end

	if VR.on() then
		local aim, pitch = EmplacementData.aimOf(view.base, VR.frame(currentCamera).LookVector)
		v6.yaw = aim
		v6.pitch = pitch
		currentCamera.CFrame = EmplacementData.stand(view.base, 0) * CFrame.new(0, -EmplacementData.ROOT_UP, 0)
		currentCamera.Focus = CFrame.new(view.pivot)
		v6.lastLook = nil
	else
		if not GuiService.MenuIsOpen and UserInputService.MouseEnabled then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
			v6.cursorHidden = true
		end

		v6.baseFov = v6.baseFov or currentCamera.FieldOfView
		local baseFov = v6.baseFov

		local v20 = math.tan(math.rad(currentCamera.FieldOfView) / 2) / math.tan(math.rad(baseFov) / 2)
		local v21 = 0
		local v22 = 0
		local v23

		if TouchControls.active() then
			v23 = Vector2.zero
		else
			v23 = UserInputService:GetMouseDelta()
		end

		if v23.Magnitude > 0 then
			v21 -= v23.X * v.mouseTurn * v20
			v22 += v23.Y * v.mouseTurn * v20
		end

		local v24 = padStick()

		if v24.Magnitude > 0 then
			v21 -= v24.X * v.padTurn * v20 * LookSettings.look * p
			v22 -= v24.Y * v.padTurn * v20 * LookSettings.look * p
		end

		if v6.lastLook then
			local lastLook = v6.lastLook
			local lookVector = currentCamera.CFrame.LookVector
			local v25 = wrap(yawOf(lookVector) - yawOf(lastLook)) -- inferred equivalent call

			local v26 = math.asin((math.clamp(lastLook.Y, -1, 1))) - math.asin((math.clamp(lookVector.Y, -1, 1)))

			if math.abs(v25) > 0.0001 or math.abs(v26) > 0.0001 then
				v21 += v25
				v22 += v26
			end
		end

		local clamped, pitch = EmplacementData.clamp(v6.yaw + v21, v6.pitch - v22)
		v6.yaw = clamped
		v6.pitch = pitch
		local v25 = v6.zoom * v6.zoom * (3 - 2 * v6.zoom)
		currentCamera.FieldOfView = baseFov + (v.scopeFov - baseFov) * v25
		local cframe = (EmplacementData.mount(view.base, v6.yaw) * v.eye * CFrame.Angles(v6.pitch, 0, 0)):Lerp(
			EmplacementData.gun(view.base, v6.yaw, v6.pitch) * v.sightEye,
			v25
		) * v6.shake
		currentCamera.CFrame = cframe
		currentCamera.Focus = CFrame.new(view.pivot)
		v6.lastLook = cframe.LookVector
	end
end

local function spreadDir(vector3: Vector3, spread: number)
	local v20 = math.rad(spread) * math.sqrt((random:NextNumber()))
	return (CFrame.lookAt(Vector3.new(0, 0, 0), vector3) * CFrame.Angles(0, 0, random:NextNumber() * 6.283185307179586) * CFrame.Angles(v20, 0, 0)).LookVector
end

local function triggers()
	if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen or MenuLock.open then
		return false, false
	end

	local v20 = v6.touchFire or v6.autoFire
	local v21 = v6.touchScope or v6.aimHeld

	if UserInputService.MouseEnabled then
		v20 = v20 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	end

	if UserInputService.GamepadEnabled and not MenuLock.held then
		v20 = v20
			or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
			or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
		v21 = v21 or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2)
	end

	return v20, v21
end

local function cool(heatAt: number) -- 1 equivalent call inferred from this helper
	local v20 = math.max(v6.heatAt, v6.last + gun.coolDelay)

	if v20 < heatAt then
		v6.heat = math.max(0, v6.heat - gun.cool * (heatAt - v20))
	end

	v6.heatAt = heatAt

	if v6.locked and v6.heat <= gun.unlock then
		v6.locked = false
	end
end

local function shoot(state, aimSentAt: number, origin: Vector3, vector3: Vector3)
	if aimSentAt - v6.nextAt > 0.1 then
		v6.nextAt = aimSentAt
	end

	local result = {}

	while v6.nextAt <= aimSentAt and #result < gun.burst and not v6.locked do
		v6.nextAt += 1 / gun.rate
		local lookVector = spreadDir(vector3, gun.spread)
		v6.shots += 1
		VoxelSound.ownLMG(1)
		state.kick = v.kick
		state.flashAt = aimSentAt

		if v6.shots % gun.tracerEvery == 0 then
			local raycastResult = workspace:Raycast(origin, lookVector * 500, raycastParams)
			local v20

			if raycastResult then
				v20 = raycastResult.Position
			else
				v20 = origin + lookVector * 500
			end

			Tracers.fire(origin, v20, nil, nil, true, nil, true)

			if raycastResult then
				local v21 = raycastResult.Instance == workspace.Terrain
					and raycastResult.Material ~= Enum.Material.Water
				task.delay(
					Tracers.travelTime(origin, v20),
					ImpactFX.bullet,
					raycastResult.Position,
					raycastResult.Normal,
					lookVector,
					v21
				)
			end
		end

		table.insert(result, lookVector)
		v6.heat += gun.heat

		if v6.heat >= 1 then
			v6.locked = true
		end
	end

	v6.last = aimSentAt
	return result
end

local function gunStep(view, now: number, p: number)
	refreshAim(now)
	local character = LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local _ = humanoidRootPart and humanoidRootPart:IsA("BasePart")
	else
		character = nil
	end

	if character and humanoid and character:FindFirstChildOfClass("Tool") then
		humanoid:UnequipTools()
	end

	setCharacterShown(false)
	cool(now) -- inferred equivalent call
	local v20, v21 = triggers()
	local v22 = p / v.scopeTime
	local zoom

	if v21 then
		zoom = math.min(1, v6.zoom + v22)
	else
		zoom = math.max(0, v6.zoom - v22)
	end

	v6.zoom = zoom
	v6.firing = v20 and not v6.locked

	if v6.firing then
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera.ViewportSize
		local ray = VR.ray(currentCamera, viewportSize.X * 0.5, viewportSize.Y * 0.5)
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
		local v23

		if raycastResult then
			v23 = raycastResult.Position
		else
			v23 = ray.Origin + ray.Direction * 500
		end

		local cframe = EmplacementData.gun(view.base, v6.yaw, v6.pitch)
		local pointToWorldSpace = cframe:PointToWorldSpace(EmplacementData.MUZZLE)
		local v24 = v23 - pointToWorldSpace
		local v25

		if v24.Magnitude > 1 and v24.Unit:Dot(cframe.LookVector) > 0.9975640502598242 then
			v25 = v24.Unit
		else
			v25 = cframe.LookVector
		end

		local v26 = shoot(view, now, pointToWorldSpace, v25)

		if #v26 > 0 then
			EmplacementFire:FireServer(view.id, table.unpack(v26))
		end

		v6.shake = CFrame.Angles(
			math.rad(v.jolt * (random:NextNumber() * 2 - 1)),
			math.rad(v.jolt * (random:NextNumber() * 2 - 1)),
			0
		)
	else
		v6.shake = CFrame.identity
	end

	if now - v6.aimSentAt >= v.aimSend then
		v6.aimSentAt = now
		EmplacementAim:FireServer(view.id, v6.yaw, v6.pitch, v6.firing)
	end

	local yaw = v6.yaw
	local pitch = v6.pitch
	view.yaw = yaw
	view.pitch = pitch

	local sent = v11.sent
	local v23 = math.clamp(v6.heat, 0, 1)
	local locked = v6.locked
	local v24

	if locked then
		v24 = v4.danger
	else
		v24 = if v23 > 0.7 then v4.hazard else v4.white
	end

	if sent.h ~= v23 then
		sent.h = v23
		v11.bar.Size = UDim2.fromScale(v23, 1)
	end

	if sent.tint ~= v24 then
		sent.tint = v24
		v11.bar.BackgroundColor3 = v24
	end

	if sent.locked ~= locked then
		sent.locked = locked
		v11.status.Visible = locked

		for _, bit in v11.bits do
			local backgroundColor

			if locked then
				backgroundColor = v4.danger
			else
				backgroundColor = v4.white
			end

			bit.BackgroundColor3 = backgroundColor
		end
	end

	showScope(view, VR.on() and 0 or math.clamp((v6.zoom - v2.from) / (v2.to - v2.from), 0, 1))
	local v25 = v6.zoom < 0.35 or VR.on()

	if sent.reticle ~= v25 then
		sent.reticle = v25
		v11.reticle.Visible = v25
	end

	local v26 = now < v6.hintUntil

	if sent.hintOn ~= v26 then
		sent.hintOn = v26
		v11.hint.Visible = v26
	end

	local hint2 = TouchControls.active() and "touch" or LocalPlayer:GetAttribute("PadMode") == true and "pad" or "mouse"

	if sent.hint ~= hint2 then
		sent.hint = hint2

		v11.hint.Text = hint2 == "touch" and "DRAG  AIM     FIRE  HOLD     SIGHT  AIM IN"
			or hint2 == "pad" and "RS  AIM     RT  FIRE     LT  SIGHT     Y  OUT"
			or "MOUSE  AIM     LMB  FIRE     RMB  SIGHT     E  OUT"
	end
end

local function nearest()
	local team = LocalPlayer.Team
	local character = LocalPlayer.Character
	local humanoid, humanoidRootPart

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end
	end

	if not team or not humanoid or humanoid.Health <= 0 or not humanoidRootPart then
		return nil
	end

	local v20 = EmplacementData.REACH
	local v21 = nil

	for _, v22 in v5 do
		if not (v22.gunner == 0 and v22.team == team.Name) then
			continue
		end

		local position = EmplacementData.stand(v22.base, v22.yaw).Position
		local position2 = humanoidRootPart.Position
		local v23 = position2.X - position.X
		local v24 = position2.Z - position.Z
		local v25 = math.sqrt(v23 * v23 + v24 * v24)

		if not (v25 <= v20 and math.abs(position2.Y - position.Y) <= 6) then
			continue
		end

		v21 = v22
		v20 = v25
	end

	return v21
end

local function ask()
	local now = os.clock()
	local view = v6.view

	if view then
		EmplacementSeat:FireServer(view.id, false)
		stopManning()
	else
		if
			LocalPlayer:GetAttribute("InVehicle")
			or now - v6.leftAt < EmplacementData.REENTER_GAP
			or now - v6.askedAt < 0.3
		then
			return
		end

		if Glyph.claimed("vehicle") or Glyph.claimed("heli") then
			return
		end

		local v20 = nearest()

		if v20 then
			v6.askedAt = now
			EmplacementSeat:FireServer(v20.id, true)
		end
	end
end

local v20 = {
	word = "USE",
	what = "MOUNTED GUN",
	icon = "GUN",
	locked = false,
	press = ask
}

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if next(v5) == nil then
		return
	end

	if v6.view and AimKey.began(input, gameProcessed) then
		v6.aimHeld = true
		return
	end

	if gameProcessed or MenuLock.held and input.UserInputType == Enum.UserInputType.Gamepad1 then
		return
	end

	if
		(input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY)
		and not MenuLock.open
		and (input.KeyCode ~= Enum.KeyCode.E or LocalPlayer:GetAttribute("ReviveFocus") ~= true)
	then
		ask()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if v6.aimHeld and AimKey.ended(input) then
		v6.aimHeld = false
	end
end)

if UserInputService.TouchEnabled then
	local v21 = SeatButton.make(v11.gui, "Seat", "GET OUT", UDim2.new(1, -16, 0.5, -10), true)
	v21.Visible = true
	v21.Activated:Connect(ask)
	local v22 = SeatButton.make(v11.gui, "Fire", "FIRE", UDim2.new(1, -114, 0.5, -10), false)
	v22.Visible = true
	v22.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v6.touchFire = true
		end
	end)
	v22.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v6.touchFire = false
		end
	end)
	local v23 = SeatButton.make(v11.gui, "Sight", "SIGHT", UDim2.new(1, -16, 0.5, -74), false)
	v23.Visible = true
	v23.Activated:Connect(function()
		v6.touchScope = not v6.touchScope
	end)
end

RunService.PreSimulation:Connect(function()
	local view = v6.view

	if not view then
		return
	end

	local character = LocalPlayer.Character
	local humanoidRootPart

	if character then
		character:FindFirstChildOfClass("Humanoid")
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end
	end

	if not humanoidRootPart then
		return
	end

	local stand = EmplacementData.stand(view.base, v6.yaw)
	humanoidRootPart.CFrame = stand.Rotation + Vector3.new(stand.X, humanoidRootPart.Position.Y, stand.Z)
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, humanoidRootPart.AssemblyLinearVelocity.Y, 0)
	humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end)

local v21 = {}
local v22 = {}
step = function(p: number)
	local now = os.clock()
	local v23 = nil

	for _, v24 in v5 do
		if v24.gunner == LocalPlayer.UserId then
			v23 = v24
			break
		end
	end

	local character = LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local _ = humanoidRootPart and humanoidRootPart:IsA("BasePart")
	end

	if v23 and (not humanoid or humanoid.Health <= 0) then
		v23 = nil
	end

	if v23 ~= v6.view then
		if v23 and now - v6.leftAt > 0.5 then
			stopManning()
			startManning(v23)
		elseif not v23 then
			stopManning()
		end
	end

	local view = v6.view

	if view then
		camera(view, p)
		gunStep(view, now, p)
	end

	local v24

	if not (view or LocalPlayer:GetAttribute("InVehicle") or Glyph.claimed("vehicle") or Glyph.claimed("heli") or MenuLock.open) then
		v24 = nearest()
	end

	Glyph.claim("gun", view ~= nil or v24 ~= nil)
	local touchEnabled = UserInputService.TouchEnabled

	if touchEnabled then
		local set = EnterButton.set
		local v25

		if v24 then
			v25 = v20
		end

		set("gun", v25)
	end

	local state = v24 and not touchEnabled and (Glyph.gamepad() and "pad" or "key") or nil

	if v10.state ~= state then
		v10.state = state

		if state then
			local setCap = Glyph.setCap
			local cap2 = v10.cap
			local v25

			if state == "pad" then
				v25 = Enum.KeyCode.ButtonY
			end

			setCap(cap2, nil, v25)
			v10.text.Position = UDim2.new(0, state == "pad" and 32 or 0, 0.5, 0)
			v10.text.Text = state == "pad" and "USE GUN" or "E   USE GUN"
		end

		v10.gui.Enabled = state ~= nil
	end

	table.clear(v21)
	table.clear(v22)
	local v25 = 1 - math.exp(-v.follow * p)
	local v26 = math.exp(-v.kickBack * p)

	for _, v27 in v5 do
		local v28 = not v27.posed

		if v27 == view then
			v28 = true
		else
			local aim = v27.aim

			if aim.X ~= v27.yaw then
				local v29 = aim.X - v27.yaw
				local yaw

				if math.abs(v29) > v.rest then
					yaw = v27.yaw + v29 * v25
				else
					yaw = aim.X
				end

				v27.yaw = yaw
				v28 = true
			end

			if aim.Y ~= v27.pitch then
				local v29 = aim.Y - v27.pitch
				local pitch

				if math.abs(v29) > v.rest then
					pitch = v27.pitch + v29 * v25
				else
					pitch = aim.Y
				end

				v27.pitch = pitch
				v28 = true
			end

			if aim.Z > 0.5 and v27.gunner ~= 0 and v27.nextShot <= now then
				v27.nextShot = now + 1 / gun.rate
				v27.kick = v.kick
				v27.flashAt = now
			end
		end

		if v27.kick ~= 0 then
			v27.kick = not (v27.kick > 0.002) and 0 or v27.kick * v26
			v28 = true
		end

		if v28 then
			if v27 == view or Detail.distance(v27.pivot) < 450 * Detail.reach() and Detail.onScreen(v27.pivot, 5) then
				table.insert(v21, v27.yoke)
				table.insert(v22, EmplacementData.mount(v27.base, v27.yaw))
				table.insert(v21, v27.cradle)
				table.insert(v22, EmplacementData.gun(v27.base, v27.yaw, v27.pitch) * CFrame.new(0, 0, v27.kick))
				v27.posed = true
			else
				v27.posed = false
			end
		end

		local flashOn = now - v27.flashAt < v.flash

		if flashOn == v27.flashOn then
			continue
		end

		v27.flashOn = flashOn
		v27.flash.Transparency = flashOn and 0.15 or 1
		v27.light.Enabled = flashOn and not Detail.low
	end

	if #v21 > 0 then
		workspace:BulkMoveTo(v21, v22, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local Emplacements = Game:WaitForChild("Emplacements")
Emplacements.ChildAdded:Connect(function(configuration)
	if configuration:IsA("Configuration") then
		add(configuration)
	end
end)
Emplacements.ChildRemoved:Connect(drop)

for _, configuration in Emplacements:GetChildren() do
	if configuration:IsA("Configuration") then
		add(configuration)
	end
end