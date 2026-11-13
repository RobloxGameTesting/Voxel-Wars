local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Detail = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("Detail"))
local WorldConfig = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("WorldConfig"))

local LocalPlayer = Players.LocalPlayer
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 0.72 or 0.66

local color = Color3.fromRGB(10, 10, 12)
local color2 = Color3.fromRGB(255, 60, 48)
local color3 = Color3.fromRGB(4, 4, 6)

local v2 = { 0.1, 0.18, 0.26, 0.34, 0.42, 0.5 }

local color4 = Color3.fromRGB(255, 70, 56)

local SniperSight = {}
SniperSight.__index = SniperSight

SniperSight.RING_SHARE = v * 1.25

function SniperSight.scope(p)
	local clone = table.clone(p)
	clone.ring = "Eyecup"
	clone.handoff = SniperSight.RING_SHARE
	return clone
end

local function frame(parent, color5: Color3, value: number?) -- 9 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = color5
	frame2.BackgroundTransparency = value or 0
	frame2.BorderSizePixel = 0
	frame2.Parent = parent
	return frame2
end

local function circle(parent) -- 3 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = parent
end

local function stroke(parent, color5: Color3) -- 2 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color5
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = parent
	return uiStroke
end

local function image(parent, image2: string) -- 3 equivalent calls inferred from this helper
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = image2
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Parent = parent
	return imageLabel
end

local function uiScale(parent) -- 2 equivalent calls inferred from this helper
	local uiScale2 = Instance.new("UIScale")
	uiScale2.Parent = parent
	return uiScale2
end

local function centred(p, p2: number) -- 1 equivalent call inferred from this helper
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Position = UDim2.fromScale(0.5, 0.5)
	p.Size = UDim2.fromScale(p2, p2)
end

local function anchor(sniperSight, name: string, zIndex: number)
	local frame2 = frame(sniperSight, color3, 1) -- inferred equivalent call
	frame2.Name = name
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.Size = UDim2.fromOffset(0, 0)
	frame2.ZIndex = zIndex
	return frame2
end

local function build()
	local sniperSight = Instance.new("ScreenGui")
	sniperSight.Name = "SniperSight"
	sniperSight.IgnoreGuiInset = true
	sniperSight.ScreenInsets = Enum.ScreenInsets.None
	sniperSight.ResetOnSpawn = false
	sniperSight.DisplayOrder = -1
	sniperSight.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sniperSight.Enabled = false

	local mask = {}

	for i = 1, 4 do
		mask[i] = frame(sniperSight, color3, 1) -- inferred equivalent call
		mask[i].ZIndex = 1
	end

	local back = anchor(sniperSight, "Housing", 2)
	local cornerShell = frame(back, color3, 1) -- inferred equivalent call
	cornerShell.AnchorPoint = Vector2.new(0.5, 0.5)
	cornerShell.ClipsDescendants = true
	cornerShell.ZIndex = 1
	local parent = frame(cornerShell, color3, 1) -- inferred equivalent call
	centred(parent, 1) -- inferred equivalent call
	circle(parent) -- inferred equivalent call
	local corner = stroke(parent, color3) -- inferred equivalent call
	local lens = frame(sniperSight, color3, 1) -- inferred equivalent call
	lens.Name = "Lens"
	lens.AnchorPoint = Vector2.new(0.5, 0.5)
	lens.ZIndex = 3
	local flash = image(lens, "rbxassetid://104181707194427") -- inferred equivalent call
	flash.Name = "Flash"
	flash.ImageTransparency = 0.2
	flash.Visible = false
	flash.ZIndex = 1
	local lines = {}
	local posts = {}

	for i = 1, 4 do
		lines[i] = frame(lens, color) -- inferred equivalent call
		lines[i].ZIndex = 2
	end

	for i = 1, 3 do
		posts[i] = image(lens, "rbxassetid://77435322891726") -- inferred equivalent call
		posts[i].ImageColor3 = color
		posts[i].ZIndex = 2
	end

	posts[2].Rotation = 180
	posts[3].Rotation = -90
	local centre = frame(lens, color2) -- inferred equivalent call
	centre.Name = "Centre"
	centre.AnchorPoint = Vector2.new(0.5, 0.5)
	centre.Position = UDim2.fromScale(0.5, 0.5)
	centre.ZIndex = 3
	circle(centre) -- inferred equivalent call
	local uiStroke2 = stroke(centre, color) -- inferred equivalent call
	uiStroke2.Thickness = 1
	uiStroke2.Transparency = 0.3
	local ticks = {}

	for i = 1, #v2 * 4 do
		ticks[i] = frame(lens, color) -- inferred equivalent call
		ticks[i].ZIndex = 2
	end

	local range = Instance.new("TextLabel")
	range.Name = "Range"
	range.BackgroundTransparency = 1
	range.AutoLocalize = false
	range.Font = Enum.Font.GothamBold
	range.TextColor3 = color4

	range.TextXAlignment = Enum.TextXAlignment.Right
	range.TextYAlignment = Enum.TextYAlignment.Bottom
	range.AnchorPoint = Vector2.new(1, 1)
	range.Position = UDim2.fromScale(0.47, 0.494)
	range.Size = UDim2.fromScale(0.3, 0.06)
	range.Text = ""
	range.ZIndex = 3
	range.Parent = lens
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.35
	uiStroke.Parent = range

	local front = anchor(sniperSight, "Tube", 4)
	local raiseFrame = frame(front, color3, 1) -- inferred equivalent call
	circle(raiseFrame) -- inferred equivalent call
	raiseFrame.ZIndex = 1
	local eyepiece = image(front, "rbxassetid://94632251903662") -- inferred equivalent call
	eyepiece.Name = "Eyepiece"
	eyepiece.ZIndex = 2
	local uiScale2 = uiScale(lens) -- inferred equivalent call
	local uiScale3 = uiScale(front) -- inferred equivalent call
	sniperSight.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return {
		gui = sniperSight,
		back = back,
		holder = lens,
		front = front,
		scales = { uiScale2, uiScale3 },
		cornerShell = cornerShell,
		corner = corner,
		mask = mask,
		raiseFrame = raiseFrame,
		housing = eyepiece,
		flash = flash,
		lines = lines,
		posts = posts,
		dot = centre,
		ticks = ticks,
		range = range
	}
end

local function buildBlur()
	local scopeBlur = Instance.new("Folder")
	scopeBlur.Name = "ScopeBlur"
	local scopeBlurFocus = Instance.new("DepthOfFieldEffect")
	scopeBlurFocus.Name = "ScopeBlurFocus"
	scopeBlurFocus.FarIntensity = 0
	scopeBlurFocus.NearIntensity = 0.25
	scopeBlurFocus.FocusDistance = 1.5
	scopeBlurFocus.InFocusRadius = 0.5
	scopeBlurFocus.Enabled = false
	local panes = {}
	local parts = {}

	for _ = 1, 66 do
		local pane = Instance.new("Part")
		pane.Name = "Pane"
		pane.Material = Enum.Material.Glass
		pane.Color = Color3.new(0, 0, 0)
		pane.Transparency = 0.98
		pane.Size = Vector3.new(1, 1, 0.001)
		pane.Anchored = true
		pane.CanCollide = false
		pane.CanQuery = false
		pane.CanTouch = false
		pane.CastShadow = false
		pane.Locked = true
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Brick
		specialMesh.Parent = pane
		pane.Parent = scopeBlur
		table.insert(panes, {
			part = pane,
			mesh = specialMesh,
			x = 0,
			y = 0,
			w = 0,
			h = 0
		})
		table.insert(parts, pane)
	end

	return { folder = scopeBlur, focus = scopeBlurFocus, panes = panes, parts = parts }
end

local function layPanes(blur, p: number, x: number, y: number)
	local v3 = math.max(x, y) * 1.5
	local v4 = p * 1.12
	local v5 = v4 * 2 / 32
	local panes = blur.panes

	for i = 1, 32 do
		local v6 = -v4 + (i - 1) * v5
		local v7 = v6 + v5
		local v8 = v6 < 0 and v7 > 0 and 0 or math.min(math.abs(v6), (math.abs(v7)))
		local v9 = math.sqrt((math.max(0, v4 * v4 - v8 * v8)))
		local pane = panes[i * 2 - 1]
		local pane2 = panes[i * 2]
		local v10 = -(v3 + v9) / 2
		local midpoint = (v6 + v7) / 2
		local v11 = v3 - v9
		pane.x = v10
		pane.y = midpoint
		pane.w = v11
		pane.h = v5
		local midpoint2 = (v3 + v9) / 2
		local midpoint3 = (v6 + v7) / 2
		local v12 = v3 - v9
		pane2.x = midpoint2
		pane2.y = midpoint3
		pane2.w = v12
		pane2.h = v5
	end

	local pane = panes[65]
	local pane2 = panes[66]
	local v6 = -(v3 + v4) / 2
	local v7 = v3 * 2
	local v8 = v3 - v4
	pane.x = 0
	pane.y = v6
	pane.w = v7
	pane.h = v8
	local midpoint = (v3 + v4) / 2
	local v9 = v3 * 2
	local v10 = v3 - v4
	pane2.x = 0
	pane2.y = midpoint
	pane2.w = v9
	pane2.h = v10
end

local function qualityBlurs(): boolean
	local success, result = pcall(function()
		return UserGameSettings.SavedQualityLevel
	end)

	return not success or result == Enum.SavedQualitySetting.Automatic or result.Value >= 8
end

local function blurWanted()
	local v3 = not Detail.potato

	if not v3 then
		return v3
	end

	if not ((Detail.strain or 0) < 1) then
		v3 = false
		return false
	end

	local success, result = pcall(function()
		return UserGameSettings.SavedQualityLevel
	end)

	return not success or result == Enum.SavedQualitySetting.Automatic or result.Value >= 8
end

function SniperSight.new(view, p)
	return (setmetatable({
		view = view,
		posts = p and p.posts or 1,
		parts = nil,
		blur = nil,
		blurOn = false,
		grow = 0,
		growV = 0,
		joltX = 0,
		joltY = 0,
		joltVX = 0,
		joltVY = 0,
		flashT = 0,
		shownScale = -1,
		shownFlash = false,
		lagX = 0,
		lagY = 0,
		lastLook = nil,
		shownR = -1,
		shownRy = 1e999,
		shownRx = 1e999,
		shownH = Vector2.new(1e999, 1e999),
		raiseT = -1,
		zHand = 0,
		blurShown = -1,
		shown = -1,
		vis = false,
		paneAt = Vector3.new(-1, -1, -1),
		paneScale = -1,
		rangeAt = 0,
		rangeText = ""
	}, SniperSight))
end

local v3 = 0.5733122259564006

function SniperSight:fired(value: number?)
	Detail.mark("snipe")
	local v4 = value or 1
	self.growV += 0.1 * v4 * 2.718281828459045 * 25
	self.joltVX += 0.083 * v4 * 40 / v3
	self.joltVY -= 0.11 * v4 * 40 / v3
	self.flashT = 0.035
end

local function springs(state, p: number)
	local v4 = math.clamp(math.ceil(p / 0.006), 1, 20)
	local v5 = p / v4

	for _ = 1, v4 do
		state.growV += (-625 * state.grow - 50 * state.growV) * v5
		state.grow += state.growV * v5
		state.joltVX += (-1600 * state.joltX - 36 * state.joltVX) * v5
		state.joltX += state.joltVX * v5
		state.joltVY += (-1600 * state.joltY - 36 * state.joltVY) * v5
		state.joltY += state.joltVY * v5
	end

	if math.abs(state.grow) < 0.0001 and math.abs(state.growV) < 0.001 then
		state.grow = 0
		state.growV = 0
	end

	if
		math.abs(state.joltX) + math.abs(state.joltY) < 0.0001
		and math.abs(state.joltVX) + math.abs(state.joltVY) < 0.001
	then
		state.joltX = 0
		state.joltY = 0
		state.joltVX = 0
		state.joltVY = 0
	end

	state.flashT = math.max(0, state.flashT - p)
end

local function put(p, p2: number, p3: number, p4: number, p5: number)
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Position = UDim2.fromOffset(math.round(p2), (math.round(p3)))
	p.Size = UDim2.fromOffset(math.round(p4), (math.round(p5)))
end

local function putMid(p, p2: number, p3: number, p4: number, p5: number)
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Position = UDim2.new(0.5, math.round(p2), 0.5, ((math.round)(p3)))
	p.Size = UDim2.fromOffset(math.round(p4), (math.round(p5)))
end

local function size(state, parts, p: number, y: number)
	local v4 = math.max(1, (math.round(y / 720)))

	local tool = state.view.tool
	local v5 = tool and tool:GetAttribute("GsPosts")

	if type(v5) ~= "number" then
		v5 = state.posts
	end

	local v6 = math.max(v4 + 3, (math.round(p * 0.052 * v5)))
	local v7 = math.clamp(0.75 - 0.3 * v5, 0.3, 0.7) * p
	local v8 = math.round(p * 1.25)
	local v9 = math.round(p * 0.12)

	local cornerShell = parts.cornerShell
	local v10 = v8 * 2
	local v11 = v8 * 2
	cornerShell.AnchorPoint = Vector2.new(0.5, 0.5)
	cornerShell.Position = UDim2.fromOffset(0, 0)
	cornerShell.Size = UDim2.fromOffset(math.round(v10), (math.round(v11)))

	parts.corner.Thickness = math.ceil(v8 * 0.42) + 2
	local raiseFrame = parts.raiseFrame
	local v12 = p * 2
	local v13 = p * 2
	raiseFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	raiseFrame.Position = UDim2.fromOffset(0, 0)
	raiseFrame.Size = UDim2.fromOffset(math.round(v12), (math.round(v13)))

	local housing = parts.housing
	local v14 = p * 3.2
	local v15 = p * 3.2
	housing.AnchorPoint = Vector2.new(0.5, 0.5)
	housing.Position = UDim2.fromOffset(0, 0)
	housing.Size = UDim2.fromOffset(math.round(v14), (math.round(v15)))

	local lines = parts.lines
	local line = lines[1]
	local line2 = lines[1]
	local line3 = lines[1]
	local vector2 = Vector2.new(1, 0.5)
	local udim = UDim2.fromScale(0.4825, 0.5)
	local udim2 = UDim2.new(0.4825, v9, 0, v4)
	line.AnchorPoint = vector2
	line2.Position = udim
	line3.Size = udim2
	local line4 = lines[2]
	local line5 = lines[2]
	local line6 = lines[2]
	local vector2_2 = Vector2.new(0, 0.5)
	local udim3 = UDim2.fromScale(0.5175, 0.5)
	local udim4 = UDim2.new(0.4825, v9, 0, v4)
	line4.AnchorPoint = vector2_2
	line5.Position = udim3
	line6.Size = udim4
	local line7 = lines[3]
	local line8 = lines[3]
	local line9 = lines[3]
	local vector2_3 = Vector2.new(0.5, 1)
	local udim5 = UDim2.fromScale(0.5, 0.4825)
	local udim6 = UDim2.new(0, v4, 0.4825, v9)
	line7.AnchorPoint = vector2_3
	line8.Position = udim5
	line9.Size = udim6
	local line10 = lines[4]
	local line11 = lines[4]
	local line12 = lines[4]
	local vector2_4 = Vector2.new(0.5, 0)
	local udim7 = UDim2.fromScale(0.5, 0.5175)
	local udim8 = UDim2.new(0, v4, 0.4825, v9)
	line10.AnchorPoint = vector2_4
	line11.Position = udim7
	line12.Size = udim8
	local posts = parts.posts
	local v16 = p + v9 - v7
	local v17 = v7 + v16 / 2
	putMid(posts[1], -v17, 0, v16, v6)
	putMid(posts[2], v17, 0, v16, v6)
	local post = posts[3]
	post.AnchorPoint = Vector2.new(0.5, 0.5)
	post.Position = UDim2.new(0.5, 0, 0.5, (math.round(v17)))
	post.Size = UDim2.fromOffset(math.round(v16), (math.round(v6)))

	local flash = parts.flash
	local v18 = p * 0.6
	local v19 = p * 0.9
	local v20 = p * 0.9
	flash.AnchorPoint = Vector2.new(0.5, 0.5)
	flash.Position = UDim2.new(0.5, 0, 0.5, (math.round(v18)))
	flash.Size = UDim2.fromOffset(math.round(v19), (math.round(v20)))

	for _, post2 in posts do
		post2.Visible = v5 > 0
	end

	local v21 = math.max(4, (math.round(p * 0.014))) + math.max(4, (math.round(p * 0.014))) % 2
	parts.dot.Size = UDim2.fromOffset(v21, v21)
	local count = #v2

	for k, v22 in v2 do
		local v23 = (k % 2 == 0 and 0.05 or 0.028) / 2
		local v24 = v22 / 2
		local ticks = parts.ticks
		local tick = ticks[k]
		local tick2 = ticks[count + k]
		local tick3 = ticks[count * 2 + k]
		local tick4 = ticks[count * 3 + k]
		local vector2_5 = Vector2.new(0.5, 0.5)
		local udim9 = UDim2.fromScale(0.5 - v24, 0.5)
		local udim10 = UDim2.new(0, v4, v23, 0)
		tick.AnchorPoint = vector2_5
		tick.Position = udim9
		tick.Size = udim10
		local vector2_6 = Vector2.new(0.5, 0.5)
		local udim11 = UDim2.fromScale(0.5 + v24, 0.5)
		local udim12 = UDim2.new(0, v4, v23, 0)
		tick2.AnchorPoint = vector2_6
		tick2.Position = udim11
		tick2.Size = udim12
		local vector2_7 = Vector2.new(0.5, 0.5)
		local udim13 = UDim2.fromScale(0.5, 0.5 - v24)
		local udim14 = UDim2.new(v23, 0, 0, v4)
		tick3.AnchorPoint = vector2_7
		tick3.Position = udim13
		tick3.Size = udim14
		local vector2_8 = Vector2.new(0.5, 0.5)
		local udim15 = UDim2.fromScale(0.5, 0.5 + v24)
		local udim16 = UDim2.new(v23, 0, 0, v4)
		tick4.AnchorPoint = vector2_8
		tick4.Position = udim15
		tick4.Size = udim16
	end

	parts.range.TextSize = math.max(12, (math.round(p * 0.05)))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local function rangeNow()
	local currentCamera = workspace.CurrentCamera
	local cframe = currentCamera.CFrame
	local character = LocalPlayer.Character
	raycastParams.FilterDescendantsInstances = character and { character, currentCamera } or { currentCamera }
	local raycastResult = workspace:Raycast(cframe.Position, cframe.LookVector * 4000, raycastParams)

	if raycastResult then
		return raycastResult.Distance / WorldConfig.METER
	end

	return nil
end

local function own(state) -- 2 equivalent calls inferred from this helper
	local view = state.view

	if state.parts and view and type(view.ownGui) == "function" then
		view:ownGui(state.parts.gui)
	end
end

local function setBlur(state, flag: boolean)
	if flag == state.blurOn then
		return
	end

	state.blurOn = flag

	if flag and not state.blur then
		state.blur = buildBlur()
	end

	local blur = state.blur

	if not blur then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local function place(blur2) -- 1 equivalent call inferred from this helper
		local focus = blur2.focus
		local parent

		if flag then
			parent = currentCamera
		end

		focus.Parent = parent
		blur2.focus.Enabled = flag
		local folder = blur2.folder
		local parent2

		if flag then
			parent2 = currentCamera
		end

		folder.Parent = parent2
	end

	if not pcall(place, blur) then
		local blur2 = buildBlur()
		state.blur = blur2
		place(blur2) -- inferred equivalent call
	end

	state.paneAt = Vector3.new(-1, -1, -1)
	state.paneScale = -1
	state.blurShown = -1
end

local function movePanes(state, p: number, p2: number, p3: number)
	local blur = state.blur
	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera.ViewportSize
	local vector3 = Vector3.new(p, viewportSize.X, viewportSize.Y)

	if vector3 ~= state.paneAt then
		state.paneAt = vector3
		layPanes(blur, p, viewportSize.X, viewportSize.Y)
		state.paneScale = -1
	end

	local paneScale = math.tan(math.rad(currentCamera.FieldOfView) / 2) * 1 / viewportSize.Y
	local v4 = math.abs(paneScale - state.paneScale) > state.paneScale * 0.0001

	if v4 then
		state.paneScale = paneScale
	end

	local cframe = currentCamera.CFrame
	local v5 = table.create(#blur.panes)

	for k, pane in blur.panes do
		v5[k] = cframe * CFrame.new((pane.x + p2) * paneScale, -(pane.y + p3) * paneScale, -0.5)

		if v4 then
			pane.mesh.Scale = Vector3.new(pane.w * paneScale, pane.h * paneScale, 0)
		end
	end

	workspace:BulkMoveTo(blur.parts, v5, Enum.BulkMoveMode.FireCFrameChanged)
end

function SniperSight:step(p: number)
	local view = self.view
	springs(self, p)

	if not self.parts and view.active then
		self.parts = build()
		own(self) -- inferred equivalent call
	end

	local function fn()
		return UserGameSettings.SavedQualityLevel
	end

	if not self.blur and view.active then
		local v4 = not Detail.potato

		if v4 then
			if (Detail.strain or 0) < 1 then
				local success, result = pcall(fn)

				v4 = not success or (result == Enum.SavedQualitySetting.Automatic or result.Value >= 8)
			else
				v4 = false
			end
		end

		if v4 then
			self.blur = buildBlur()
		end
	end

	local v4 = not (view.active and view.spec.scope) and 0 or view.zoomAlpha
	local v5

	if v4 > 0 then
		v5 = view.scopeCovered == true
	else
		v5 = false
	end

	if v5 ~= self.vis then
		self.vis = v5

		if v5 then
			Detail.mark("scope")
			self.zHand = math.min(v4, 0.95)
		end

		if v5 and not self.parts then
			self.parts = build()
			own(self) -- inferred equivalent call
		end

		if self.parts then
			self.parts.gui.Enabled = v5
		end
	end

	if v5 then
		local parts = self.parts

		if not parts.gui.Enabled then
			parts.gui.Enabled = true
		end

		local v6 = not Detail.potato

		if v6 then
			if (Detail.strain or 0) < 1 then
				local success, result = pcall(fn)

				v6 = not success or (result == Enum.SavedQualitySetting.Automatic or result.Value >= 8)
			else
				v6 = false
			end
		end

		setBlur(self, v6)

		local v7 = parts.gui.AbsoluteSize

		if v7.X < 1 or v7.Y < 1 then
			v7 = workspace.CurrentCamera.ViewportSize
		end

		local y = v7.Y
		local shownR = math.round(v * math.min(y, v7.X) / 2)
		local v8 = math.round(shownR * 1.25)

		local cframe = workspace.CurrentCamera.CFrame
		local lastLook = self.lastLook

		if lastLook then
			local vectorToObjectSpace = lastLook:VectorToObjectSpace(cframe.LookVector)

			if vectorToObjectSpace.Z < 0 then
				self.lagX -= math.deg((math.atan2(vectorToObjectSpace.X, -vectorToObjectSpace.Z))) * 0.008 * shownR
				self.lagY += math.deg((math.atan2(vectorToObjectSpace.Y, -vectorToObjectSpace.Z))) * 0.008 * shownR
			end
		end

		self.lastLook = cframe
		local v9 = math.exp(p * -12)
		self.lagX *= v9
		self.lagY *= v9
		local v10 = math.sqrt(self.lagX * self.lagX + self.lagY * self.lagY)
		local v11 = shownR * 0.11

		if v11 < v10 then
			self.lagX *= v11 / v10
			self.lagY *= v11 / v10
		end

		local scopeRing = view.scopeRing
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local v12 = not (viewportSize.Y > 0) and 1 or y / viewportSize.Y
		local v13 = math.round(self.joltX * shownR)
		local v14 = math.round(self.joltY * shownR)
		local shownRx = math.round(scopeRing.X * v12) + v13
		local shownRy = math.round(scopeRing.Y * v12) + v14
		local v15 = shownRx + math.round(self.lagX)
		local v16 = shownRy + math.round(self.lagY)

		local v17 = shownR ~= self.shownR

		if v17 then
			self.shownR = shownR
			size(self, parts, shownR, y)
			parts.holder.Size = UDim2.fromOffset(shownR * 2, shownR * 2)
		end

		if shownRy ~= self.shownRy or shownRx ~= self.shownRx then
			self.shownRy = shownRy
			self.shownRx = shownRx
			parts.holder.Position = UDim2.new(0.5, shownRx, 0.5, shownRy)
		end

		local vector2 = Vector2.new(v15, v16)

		if v17 or vector2 ~= self.shownH then
			self.shownH = vector2
			parts.back.Position = UDim2.new(0.5, v15, 0.5, v16)
			parts.front.Position = UDim2.new(0.5, v15, 0.5, v16)

			local mask = parts.mask
			local v18 = v16 - v8
			local v19 = v16 + v8
			local v20 = v15 - v8
			local v21 = v15 + v8
			local v22 = mask[1]
			local v23 = mask[1]
			local udim = UDim2.new(0, 0, 0, 0)
			local udim2 = UDim2.new(1, 0, 0.5, v18)
			v22.Position = udim
			v23.Size = udim2
			local v24 = mask[2]
			local v25 = mask[2]
			local udim3 = UDim2.new(0, 0, 0.5, v19)
			local udim4 = UDim2.new(1, 0, 0.5, -v19)
			v24.Position = udim3
			v25.Size = udim4
			local v26 = mask[3]
			local v27 = mask[3]
			local udim5 = UDim2.new(0, 0, 0.5, v18)
			local udim6 = UDim2.new(0.5, v20, 0, v19 - v18)
			v26.Position = udim5
			v27.Size = udim6
			local v28 = mask[4]
			local v29 = mask[4]
			local udim7 = UDim2.new(0.5, v21, 0.5, v18)
			local udim8 = UDim2.new(0.5, -v21, 0, v19 - v18)
			v28.Position = udim7
			v29.Size = udim8
		end

		local v18 = math.round((1 + self.grow) * 200) / 200

		if v18 ~= self.shownScale then
			self.shownScale = v18

			for _, scale in parts.scales do
				scale.Scale = v18
			end
		end

		local v19 = self.flashT > 0

		if v19 ~= self.shownFlash then
			self.shownFlash = v19
			parts.flash.Visible = v19
		end

		local v20 = math.clamp((1 - v4) / (1 - self.zHand), 0, 1)
		local v21 = math.round((1 - v20 ^ 1.5 * 0.55) * 20) / 20

		if v21 ~= self.raiseT then
			self.raiseT = v21
			parts.raiseFrame.BackgroundTransparency = v21
		end

		if v6 then
			movePanes(self, shownR, v15, v16)

			local v22 = math.round((1 - v20) * 0.25 * 20) / 20
			local blur = self.blur

			if blur and v22 ~= self.blurShown then
				self.blurShown = v22
				blur.focus.NearIntensity = v22
			end
		end

		local now = os.clock()

		if now - self.rangeAt >= 0.1 then
			self.rangeAt = now
			local v22 = rangeNow()
			local v23 = not v22 and "--- m" or string.format("%d m", (math.round(v22)))

			if v23 ~= self.rangeText then
				self.rangeText = v23
				parts.range.Text = v23
			end
		end

		local v22 = math.round((1 - (1 - (v6 and 0.88 or 0.75)) * (1 - v20)) * 20) / 20

		if v22 ~= self.shown then
			self.shown = v22
			parts.corner.Transparency = v22

			for _, v23 in parts.mask do
				v23.BackgroundTransparency = v22
			end
		end
	else
		setBlur(self, false)
		self.lastLook = nil
		self.lagX = 0
		self.lagY = 0
	end
end

function SniperSight:destroy()
	if self.parts then
		self.parts.gui:Destroy()
	end

	if self.blur then
		self.blur.folder:Destroy()
		self.blur.focus:Destroy()
	end

	self.parts = nil
	self.blur = nil
	self.blurOn = false
	self.vis = false
	self.lastLook = nil
	self.shownScale = -1
	self.shownFlash = false
	self.lagX = 0
	self.lagY = 0
	self.shownR = -1
	self.shownRy = 1e999
	self.shownRx = 1e999
	self.shownH = Vector2.new(1e999, 1e999)
	self.raiseT = -1
	self.blurShown = -1
	self.shown = -1
	self.paneAt = Vector3.new(-1, -1, -1)
	self.paneScale = -1
	self.rangeText = ""
end

return SniperSight