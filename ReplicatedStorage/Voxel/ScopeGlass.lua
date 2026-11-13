local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Voxel = ReplicatedStorage:WaitForChild("Voxel")
local Viewmodel = require(Voxel:WaitForChild("Viewmodel"))
local WorldConfig = require(Voxel:WaitForChild("WorldConfig"))
local Detail = require(Voxel:WaitForChild("Detail"))

local color = Color3.fromRGB(72, 75, 83)
local color2 = Color3.fromRGB(68, 71, 79)
local color3 = Color3.fromRGB(65, 68, 75)
local color4 = Color3.fromRGB(62, 64, 70)
local color5 = Color3.fromRGB(88, 91, 98)
local color6 = Color3.fromRGB(100, 104, 112)

local vector2 = Vector2.new(0.05, -0.22)

local color7 = Color3.fromRGB(255, 64, 48)
local v = {
	{ 2.2, 0.55 },
	{ 3.6, 0.78 },
	{ 5.4, 0.9 }
}

local color8 = Color3.fromRGB(10, 10, 12)
local color9 = Color3.fromRGB(255, 70, 56)
local color10 = Color3.fromRGB(6, 6, 8)
local color11 = Color3.fromRGB(36, 52, 60)

local ScopeGlass = {}
ScopeGlass.__index = ScopeGlass

local function frame(parent, backgroundColor: Color3, value: number?) -- 8 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = backgroundColor
	frame2.BackgroundTransparency = value or 0
	frame2.BorderSizePixel = 0
	frame2.Parent = parent
	return frame2
end

local function circle(parent) -- 5 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = parent
end

local function ring(parent, p: number, thickness: number, transparency: number, color12: Color3?)
	local parent2 = frame(parent, color12 or color10, 1) -- inferred equivalent call
	parent2.AnchorPoint = Vector2.new(0.5, 0.5)
	parent2.Position = UDim2.fromScale(0.5, 0.5)
	parent2.Size = UDim2.fromOffset(p, p)
	circle(parent2) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color12 or color10
	uiStroke.Transparency = transparency
	uiStroke.Thickness = thickness
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = parent2
	return parent2
end

local function graded(instance, rotation: number, colorSequence, transparency) -- 2 equivalent calls inferred from this helper
	local uiStroke = instance:FindFirstChildOfClass("UIStroke")
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation

	if colorSequence then
		uiStroke.Color = Color3.new(1, 1, 1)
		uiGradient.Color = colorSequence
	end

	if transparency then
		uiGradient.Transparency = transparency
	end

	uiGradient.Parent = uiStroke
end

local function build(scopeGlass, p: number, r: number, _: number)
	local scopeGlass2 = Instance.new("SurfaceGui")
	scopeGlass2.Name = "ScopeGlass"
	scopeGlass2.Face = Enum.NormalId.Front
	scopeGlass2.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	scopeGlass2.CanvasSize = Vector2.new(1024, 1024)
	scopeGlass2.LightInfluence = 0
	scopeGlass2.AlwaysOnTop = false
	scopeGlass2.ClipsDescendants = true
	scopeGlass2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	scopeGlass2.Enabled = false
	local parent = frame(scopeGlass2, color11, 0.93) -- inferred equivalent call
	parent.AnchorPoint = Vector2.new(0.5, 0.5)
	parent.Position = UDim2.fromScale(0.5, 0.5)
	parent.Size = UDim2.fromOffset(r * 2, r * 2)
	circle(parent) -- inferred equivalent call
	parent.ZIndex = 1
	local reticle = frame(scopeGlass2, color8, 1) -- inferred equivalent call
	reticle.Name = "Reticle"
	reticle.AnchorPoint = Vector2.new(0.5, 0.5)
	reticle.Size = UDim2.fromOffset(r * 2, r * 2)
	reticle.ZIndex = 2
	local posts = {}

	for i = 1, 3 do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://77435322891726"
		imageLabel.ImageColor3 = color8
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.ZIndex = 2
		imageLabel.Parent = scopeGlass2
		posts[i] = imageLabel
	end

	posts[2].Rotation = 180
	posts[3].Rotation = -90
	local arms = {}

	for i = 1, 4 do
		arms[i] = frame(scopeGlass2, color8) -- inferred equivalent call
		arms[i].ZIndex = 2
	end

	local centre = frame(reticle, color7) -- inferred equivalent call
	centre.Name = "Centre"
	centre.AnchorPoint = Vector2.new(0.5, 0.5)
	centre.Position = UDim2.fromScale(0.5, 0.5)
	centre.ZIndex = 4
	circle(centre) -- inferred equivalent call
	local glow = {}

	for k, v2 in v do
		local parent2 = frame(reticle, color7, v2[2]) -- inferred equivalent call
		parent2.AnchorPoint = Vector2.new(0.5, 0.5)
		parent2.Position = UDim2.fromScale(0.5, 0.5)
		parent2.ZIndex = 3
		circle(parent2) -- inferred equivalent call
		glow[k] = parent2
	end

	local range = Instance.new("TextLabel")
	range.Name = "Range"
	range.BackgroundTransparency = 1
	range.AutoLocalize = false
	range.Font = Enum.Font.GothamBold
	range.TextColor3 = color9
	range.TextXAlignment = Enum.TextXAlignment.Right
	range.TextYAlignment = Enum.TextYAlignment.Bottom
	range.AnchorPoint = Vector2.new(1, 1)
	range.Position = UDim2.fromScale(0.44, 0.494)
	range.Size = UDim2.fromScale(0.3, 0.06)
	range.Text = ""
	range.ZIndex = 3
	range.Parent = reticle
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color8
	uiStroke.Transparency = 0.35
	uiStroke.Parent = range
	local shade = frame(scopeGlass2, color10, 1) -- inferred equivalent call
	shade.Name = "Shade"
	shade.AnchorPoint = Vector2.new(0.5, 0.5)
	shade.Size = UDim2.fromOffset(r * 2, r * 2)
	shade.ZIndex = 4
	local v2 = r * 1.135
	local v3 = 1

	for i = 1, 10 do
		local v4 = (i - 1) * 0.09999999999999998 / 10 + 0.9
		local v5 = i / 10
		local v6 = math.clamp((1 - v5 * 0.45 * v5 * (3 - v5 * 2)) / v3, 0, 1)
		v3 *= v6
		local ring_2 = ring(shade, r * 2 * v4, v2 - r * v4, v6)
		ring_2.Position = UDim2.fromScale(0.5, 0.5)
	end

	local dark = frame(scopeGlass2, color10) -- inferred equivalent call
	dark.Name = "Dark"
	dark.Size = UDim2.fromScale(1, 1)
	circle(dark) -- inferred equivalent call
	dark.ZIndex = 5

	local parent2 = ring(scopeGlass2, r * 2, r * 0.27, 0, color2)
	parent2.ZIndex = 6
	local colorSequence, transparency = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.55, color2),
		ColorSequenceKeypoint.new(1, color3)
	})
	graded(parent2, 90, colorSequence, transparency) -- inferred equivalent call
	local ring_2 = ring(scopeGlass2, r * 2, r * 0.065, 0, color4)
	ring_2.ZIndex = 7
	local ring_3 = ring(scopeGlass2, r * 2 * 1.065, r * 0.012, 0.2, color5)
	ring_3.ZIndex = 7
	local parent3 = ring(scopeGlass2, r * 2 * 1.252, r * 0.018, 0, color6)
	parent3.ZIndex = 7
	graded( -- inferred equivalent call
		parent3,
		45,
		nil,
		NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.55, 0.8),
			NumberSequenceKeypoint.new(1, 0.15)
		})
	)

	scopeGlass2.Parent = scopeGlass
	return {
		gui = scopeGlass2,
		reticle = reticle,
		posts = posts,
		arms = arms,
		centre = centre,
		glow = glow,
		heavy = math.max(2, r * 0.075 * p),
		range = range,
		rangeStroke = uiStroke,
		shade = shade,
		shadeMax = 0.135,
		dark = dark
	}
end

local function scaled(cframe: CFrame) -- 3 equivalent calls inferred from this helper
	return CFrame.new(cframe.Position * Viewmodel.VIEW_SCALE) * cframe.Rotation
end

function ScopeGlass.new(view, p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	return (setmetatable({
		view = view,
		posts = p and p.posts or 1,
		model = nil,
		pane = nil,
		parts = nil,
		outside = nil,
		outsideStroke = nil,
		outsideShown = -1,
		r = 0,
		wall = 1,
		eyeOff = Vector2.zero,
		rangeAt = 0,
		rangeText = "",
		rangeParams = raycastParams,
		thin = -1,
		on = false
	}, ScopeGlass))
end

local function attach(state)
	local view = state.view
	local model = view.model
	local opening = view.opening
	assert(opening, "ScopeGlass: the view needs spec.scope.eyepiece")
	local tool = view.tool
	local handle = tool:FindFirstChild("Handle")
	local v2 = nil

	for _, part in tool:GetDescendants() do
		if
			part:IsA("BasePart")
			and not (part:GetAttribute("Ammo") or part:GetAttribute("Slide") or part:GetAttribute("Pin"))
		then
			v2 = part
			break
		end
	end

	local part = view.parts[1]
	assert(
		v2 and part and part.Name == v2.Name,
		"ScopeGlass: the view model's weapon root is not the tool's first part"
	)

	if state.pane then
		state.pane:Destroy()
	end

	if state.outside then
		state.outside:Destroy()
	end

	local v3 = opening.near + 0.004
	local v4 = opening.tan * (opening.eye.Z - v3)
	local wall = opening.outer / opening.tan
	assert(wall > 1, "ScopeGlass: the eyecup's outer edge is inside its opening")
	local v5 = CFrame.new(opening.eye.X, opening.eye.Y, v3) * CFrame.Angles(0, 3.141592653589793, 0)
	local VIEW_SCALE = Viewmodel.VIEW_SCALE
	local scopeGlass = Instance.new("Part")
	scopeGlass.Name = "ScopeGlass"

	local v6 = math.max(wall, 1.126998)
	scopeGlass.Size = Vector3.new(v6 * 2 * v4 * VIEW_SCALE, v6 * 2 * v4 * VIEW_SCALE, 0.002)
	scopeGlass.Transparency = 1
	scopeGlass.CanCollide = false
	scopeGlass.CanQuery = false
	scopeGlass.CanTouch = false
	scopeGlass.CastShadow = false
	scopeGlass.Massless = true
	scopeGlass.Anchored = false
	local cframe = handle.CFrame:ToObjectSpace(v2.CFrame)
	scopeGlass.CFrame = part.CFrame * scaled(cframe:Inverse() * v5) -- inferred equivalent call
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = scopeGlass
	weld.C0 = scaled(cframe:Inverse() * v5) -- inferred equivalent call
	weld.Parent = scopeGlass
	scopeGlass.Parent = model

	local v7 = opening.near + 0.002
	local v8 = opening.tan * (opening.eye.Z - v7)
	local v9 = CFrame.new(opening.eye.X, opening.eye.Y, v7) * CFrame.Angles(0, 3.141592653589793, 0)
	local scopeOutside = scopeGlass:Clone()
	scopeOutside:ClearAllChildren()
	scopeOutside.Name = "ScopeOutside"
	scopeOutside.Size = Vector3.new(32 * v8 * VIEW_SCALE, 32 * v8 * VIEW_SCALE, 0.002)
	local weld2 = Instance.new("Weld")
	weld2.Part0 = part
	weld2.Part1 = scopeOutside
	weld2.C0 = scaled(cframe:Inverse() * v9) -- inferred equivalent call
	weld2.Parent = scopeOutside
	scopeOutside.CFrame = part.CFrame * weld2.C0
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surfaceGui.CanvasSize = Vector2.new(1024, 1024)
	surfaceGui.LightInfluence = 0
	surfaceGui.ClipsDescendants = true
	surfaceGui.Enabled = false

	state.outsideStroke = ring(surfaceGui, 69.71136, 716.8, 1):FindFirstChildOfClass("UIStroke")
	surfaceGui.Parent = scopeOutside
	scopeOutside.Parent = model
	state.outside = scopeOutside
	state.outsideShown = -1
	state.model = model
	state.pane = scopeGlass
	state.r = 512 / v6 * 0.87
	state.wall = wall
	local v10 = tool:GetAttribute("GsPosts")

	if type(v10) ~= "number" then
		v10 = state.posts
	end

	state.parts = build(scopeGlass, v10, state.r, wall)
	state.thin = -1
	state.rangeText = ""
end

function ScopeGlass:nudge(vector2_2: Vector2)
	self.eyeOff += vector2_2
end

function ScopeGlass:fired(value: number?)
	Detail.mark("snipe")
	self.eyeOff += vector2 * (value or 1)
end

function ScopeGlass:step(p: number)
	local view = self.view
	self.eyeOff -= self.eyeOff * math.min(1, p * 6)

	if self.eyeOff.Magnitude < 0.001 then
		self.eyeOff = Vector2.zero
	end

	if
		view.active
		and view.model
		and view.opening
		and (view.model ~= self.model or not (self.pane and self.pane.Parent))
	then
		attach(self)
	end

	local v2 = not (view.active and view.opening) and 0 or view.zoomAlpha
	local v3

	if v2 > 0 and self.parts ~= nil then
		v3 = view.model == self.model
	else
		v3 = false
	end

	if v3 ~= self.on then
		self.on = v3

		if self.parts then
			self.parts.gui.Enabled = v3
		end

		local surfaceGui = self.outside and self.outside:FindFirstChildOfClass("SurfaceGui")

		if surfaceGui then
			surfaceGui.Enabled = v3
		end

		if v3 then
			Detail.mark("scope")
		end
	end

	if not v3 then
		return
	end

	local parts = self.parts
	local r = self.r
	local opening = view.opening
	local currentCamera = workspace.CurrentCamera
	local v4 = opening.near + 0.004
	local v5 = opening.tan * (opening.eye.Z - v4) * 0.87

	local holdView = view.holdView
	local pointToObjectSpace = holdView:PointToObjectSpace(Vector3.new(0, 0, 0))
	local vectorToObjectSpace = holdView:VectorToObjectSpace(Vector3.new(0, 0, -1))
	local v6 = Vector2.zero

	if vectorToObjectSpace.Z < -0.001 then
		local v7 = pointToObjectSpace + vectorToObjectSpace * ((v4 - pointToObjectSpace.Z) / vectorToObjectSpace.Z)
		v6 = Vector2.new(v7.X - opening.eye.X, -(v7.Y - opening.eye.Y)) / v5
	end

	parts.reticle.Position = UDim2.new(0.5, v6.X * r, 0.5, v6.Y * r)
	parts.reticle.Visible = v6.Magnitude < 1

	local y = currentCamera.ViewportSize.Y
	local v7 = opening.tan * 0.87 / math.tan(math.rad(currentCamera.FieldOfView) / 2) * y / 2
	local thickness = r / math.max(v7, 1)
	local thin = math.round(math.max(1, y / 720) * thickness * 2) / 2

	if thin ~= self.thin then
		self.thin = thin
		parts.range.TextSize = math.max(12, (math.round(v7 * 0.05))) * thickness
		parts.rangeStroke.Thickness = thickness
		local v8 = math.max(3, (math.round(y / 720 * 3))) * thickness
		parts.centre.Size = UDim2.fromOffset(v8, v8)

		for k, v9 in v do
			parts.glow[k].Size = UDim2.fromOffset(v8 * v9[1], v8 * v9[1])
		end
	end

	local x = v6.X
	local y2 = v6.Y
	local v8 = math.sqrt((math.max(0, 1 - y2 * y2)))
	local v9 = math.sqrt((math.max(0, 1 - x * x)))
	local function across(p2, p3: number, p4: number)
		p2.Visible = p3 < p4 and math.abs(y2) < 1
		p2.AnchorPoint = Vector2.new(0, 0.5)
		p2.Position = UDim2.new(0.5, p3 * r, 0.5, y2 * r)
		p2.Size = UDim2.fromOffset((p4 - p3) * r, thin)
	end
	local function upDown(p2, p3: number, p4: number)
		p2.Visible = p3 < p4 and math.abs(x) < 1
		p2.AnchorPoint = Vector2.new(0.5, 0)
		p2.Position = UDim2.new(0.5, x * r, 0.5, p3 * r)
		p2.Size = UDim2.fromOffset(thin, (p4 - p3) * r)
	end

	local function post(p2, p3: number, p4: number, p5: number) -- 3 equivalent calls inferred from this helper
		p2.Visible = p5 > 0
		p2.Position = UDim2.new(0.5, p3 * r, 0.5, p4 * r)
		p2.Size = UDim2.fromOffset(math.max(0, p5) * r, parts.heavy)
	end
	local arms = parts.arms
	local posts = parts.posts
	across(arms[1], -v8, x - 0.03)
	across(arms[2], x + 0.03, v8)
	upDown(arms[3], -v9, y2 - 0.03)
	upDown(arms[4], y2 + 0.03, v9)
	local v10 = x - 0.45 - -v8
	post(posts[1], (-v8 + x - 0.45) / 2, y2, not (math.abs(y2) < 1) and 0 or v10) -- inferred equivalent call
	local v11 = v8 - (x + 0.45)
	post(posts[2], (v8 + x + 0.45) / 2, y2, not (math.abs(y2) < 1) and 0 or v11) -- inferred equivalent call
	local v12 = v9 - (y2 + 0.45)
	post(posts[3], x, (v9 + y2 + 0.45) / 2, not (math.abs(x) < 1) and 0 or v12) -- inferred equivalent call
	local v13 = v6 + self.eyeOff

	if v13.Magnitude > parts.shadeMax then
		v13 = v13.Unit * parts.shadeMax
	end

	parts.shade.Position = UDim2.new(0.5, v13.X * r, 0.5, v13.Y * r)
	local v14 = math.clamp((v2 - 0.35) / 0.55, 0, 1)
	parts.dark.BackgroundTransparency = v14 * v14 * (3 - v14 * 2)
	parts.dark.Visible = v14 < 1

	local outsideStroke = self.outsideStroke

	if outsideStroke then
		local v15 = math.round((1 - math.clamp(v2 / 0.9, 0, 1) * 0.19999999999999996) * 40) / 40

		if v15 ~= self.outsideShown then
			self.outsideShown = v15
			outsideStroke.Transparency = v15
		end
	end

	local now = os.clock()

	if now - self.rangeAt >= 0.1 then
		self.rangeAt = now
		local v15 = { currentCamera }
		local character = Players.LocalPlayer.Character

		if character then
			table.insert(v15, character)
		end

		for _, childName in { "VoxelChips", "VoxelLoose", "VoxelTracers" } do
			local child = workspace:FindFirstChild(childName)

			if child then
				table.insert(v15, child)
			end
		end

		Viewmodel.setFilter(self.rangeParams, v15)
		local cframe = currentCamera.CFrame
		local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 4000, self.rangeParams)
		local v16 = not raycastResult and "--- m"
			or string.format("%d m", (math.round(raycastResult.Distance / WorldConfig.METER)))

		if v16 ~= self.rangeText then
			self.rangeText = v16
			parts.range.Text = v16
		end
	end
end

function ScopeGlass:destroy()
	if self.pane then
		self.pane:Destroy()
	end

	if self.outside then
		self.outside:Destroy()
	end

	self.pane = nil
	self.parts = nil
	self.model = nil
	self.outside = nil
	self.outsideStroke = nil
	self.on = false
end

return ScopeGlass