local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("GameConfig"))

local Style = {}

Style.PANEL = Color3.fromRGB(24, 25, 28)
Style.PANEL_ALPHA = 0.18
Style.STEEL = Color3.fromRGB(58, 61, 68)
Style.STEEL_LIGHT = Color3.fromRGB(86, 90, 99)
Style.INK = Color3.fromRGB(14, 14, 16)
Style.WHITE = Color3.fromRGB(242, 238, 228)
Style.MUTED = Color3.fromRGB(176, 178, 184)

Style.DIM = Color3.fromRGB(144, 147, 154)
Style.HAZARD = Color3.fromRGB(255, 198, 32)
Style.ORANGE = Color3.fromRGB(255, 118, 26)
Style.GOOD = Color3.fromRGB(120, 214, 96)

Style.FONT = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
Style.FONT_BODY = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold)
Style.REF_HEIGHT = 720
Style.REF_HEIGHT_TOUCH = 560

function Style.isTouch()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Style.topInset()
	return GuiService:GetGuiInset().Y
end

function Style.teamColor(p: string?)
	if p == nil or p == "" then
		return Style.WHITE
	end

	for _, v in GameConfig.TEAMS do
		if v.name == p then
			return v.color
		end
	end

	error("GameUI: unknown team '" .. tostring(p) .. "'")
end

function Style.teamText(p: string?)
	return Style.teamColor(p):Lerp(Color3.new(1, 1, 1), 0.25)
end

function Style.hex(color: Color3)
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		(math.floor(color.B * 255 + 0.5))
	)
end

function Style.escape(value: string)
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function Style.paint(p: string, color: Color3)
	return "<font color=\"" .. Style.hex(color) .. "\">" .. Style.escape(p) .. "</font>"
end

function Style.shown(childName: string)
	local Players = game:GetService("Players")
	local player = Players:FindFirstChild(childName)

	if player and player:IsA("Player") then
		return player.DisplayName
	end

	return childName
end

function Style.clock(p: number)
	local v = math.max(0, (math.ceil(p)))
	return string.format("%d:%02d", v // 60, v % 60)
end

function Style.duration(p: number)
	local v = math.max(0, (math.ceil(p)))
	local v2 = v // 3600
	local v3 = v % 3600 // 60
	local v4 = v % 60

	if v2 > 0 then
		return string.format("%dH %02dM %02dS", v2, v3, v4)
	end

	if v3 > 0 then
		return string.format("%dM %02dS", v3, v4)
	end

	return v4 .. "S"
end

function Style.thousands(p: number)
	local v = tostring((math.floor((math.abs(p))))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return (p < 0 and "-" or "") .. v
end

function Style.corner(parent, p: number)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = parent
	return uiCorner
end

function Style.stroke(parent, thickness: number, value: number?, color: Color3?, flag: boolean?)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = thickness
	uiStroke.Transparency = value or 0
	uiStroke.Color = color or Style.INK
	uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

	if flag then
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end

	uiStroke.Parent = parent
	return uiStroke
end

function Style.frame(parent, name: string, size: UDim2, udim: UDim2?, vector2: Vector2?)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = size
	frame.Position = udim or UDim2.new()
	frame.AnchorPoint = vector2 or Vector2.zero
	frame.Parent = parent
	return frame
end

function Style.fill(p, p2: string, backgroundColor: Color3, udim: UDim2, udim2: UDim2?, vector2: Vector2?)
	local frame = Style.frame(p, p2, udim, udim2, vector2)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = backgroundColor
	return frame
end

function Style.box(p, p2: string, color: Color3, udim: UDim2, value: number?, value2: number?)
	local fill = Style.fill(p, p2, color, udim)
	Style.corner(fill, value or 3)

	if (value2 or 2) > 0 then
		Style.stroke(fill, value2 or 2, 0, nil, true)
	end

	return fill
end

function Style.panel(p, p2: string, udim: UDim2, value: number?)
	local fill = Style.fill(p, p2, Style.PANEL, udim)
	fill.BackgroundTransparency = Style.PANEL_ALPHA
	Style.corner(fill, value or 3)
	Style.stroke(fill, 1.5, 0.35, Color3.new(0, 0, 0), true)
	return fill
end

function Style:hazard(value: number?, value2: number?, color: Color3?, color2: Color3?)
	local v = math.clamp(value or 4, 1, 4)
	local v2 = color2 or Style.HAZARD
	local v3 = color or Style.INK
	local colorSequenceKeypoints = {}

	for i = 0, v * 2 - 1 do
		local v4 = i / (v * 2)
		local v5 = (i + 1) / (v * 2)
		local v6 = if i % 2 == 0 then v2 else v3
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v4, v6))
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(math.min(v5 - 0.001, 1), v6))
	end

	colorSequenceKeypoints[#colorSequenceKeypoints] = ColorSequenceKeypoint.new(
		1,
		colorSequenceKeypoints[#colorSequenceKeypoints].Value
	)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new(colorSequenceKeypoints)
	uiGradient.Rotation = value2 or 30
	uiGradient.Parent = self
	self.BackgroundColor3 = Color3.new(1, 1, 1)
	return uiGradient
end

local numberSequences = {}

for i = 1, 4 do
	local numberSequenceKeypoints = { NumberSequenceKeypoint.new(0, 1) }

	for j = 0, i - 1 do
		local v = (j + 0.5) / 4
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v - 0.076298411797591 - 0.001, 1))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v - 0.076298411797591 + 0.001, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v + 0.076298411797591 - 0.001, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v + 0.076298411797591 + 0.001, 1))
	end

	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
	numberSequences[i] = NumberSequence.new(numberSequenceKeypoints)
end

function Style.tape(p, p2: string, udim: UDim2, p3: number, value: number?)
	local v = value or 14
	local fill = Style.fill(p, p2, Style.HAZARD, udim)
	fill.ClipsDescendants = true

	local v2 = math.floor((p3 + v / 4) / v) + 1
	local v3 = 4 * v * 0.8191520442889918

	for i = 0, math.ceil(v2 / 4) - 1 do
		local fill2 = Style.fill(
			fill,
			"Slat",
			Style.INK,
			UDim2.new(0, v3, 1.5, 2.4 * v),
			UDim2.new(0, (i * 4 + 1.5) * v, 0.5, 0),
			Vector2.new(0.5, 0.5)
		)
		fill2.Rotation = 35
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = numberSequences[math.min(4, v2 - i * 4)]
		uiGradient.Parent = fill2
	end

	return fill
end

function Style.label(parent, name: string, text: string, textSize: number, p, value: number?)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.FontFace = p or Style.FONT
	textLabel.TextSize = textSize
	textLabel.TextColor3 = Style.WHITE
	textLabel.Text = text
	textLabel.Size = UDim2.fromOffset(0, textSize + 4)
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.Parent = parent

	if (value or 1.5) > 0 then
		Style.stroke(textLabel, value or 1.5, 0.25)
	end

	return textLabel
end

function Style.button(parent, name: string, p: string, backgroundColor: Color3, size: UDim2, color: Color3?, value: number?)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.AutoButtonColor = true
	textButton.Text = ""
	textButton.BorderSizePixel = 0
	textButton.BackgroundColor3 = backgroundColor
	textButton.Size = size
	textButton.Parent = parent
	Style.corner(textButton, 3)
	Style.stroke(textButton, 2, 0, nil, true)
	local label = Style.label(textButton, "Text", p, value or 18, Style.FONT, color and 0 or 1.5)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = color or Style.WHITE
	return textButton, label
end

function Style.emblem(p, p2: string, p3: number)
	local teamColor = Style.teamColor(p2)
	local frame = Style.frame(p, "Emblem", UDim2.fromOffset(p3, p3))
	local frame2 = Style.frame(
		frame,
		"Shape",
		UDim2.fromScale(p2 == "Reds" and 0.72 or 0.86, p2 == "Reds" and 0.72 or 0.86),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	Style.stroke(frame2, math.max(2, p3 * 0.13), 0, teamColor, true)

	if p2 == "Reds" then
		frame2.Rotation = 45
		Style.corner(frame2, 1)
	else
		Style.corner(frame2, p3)
	end

	local fill = Style.fill(
		frame,
		"Core",
		teamColor,
		UDim2.fromScale(0.26, 0.26),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)

	if p2 == "Reds" then
		fill.Rotation = 45
		return frame
	end

	Style.corner(fill, p3)

	return frame
end

function Style.robuxLine(p, p2: string, p3: number)
	local frame = Style.frame(p, p2, UDim2.fromScale(1, 1))
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, (math.ceil(p3 * 0.6)))
	uiListLayout.Parent = frame
	local label = Style.label(frame, "Words", "", p3, Style.FONT, 1.5)
	label.LayoutOrder = 1
	local frame2 = Style.frame(frame, "Tag", UDim2.fromOffset(0, p3 + 10))
	frame2.AutomaticSize = Enum.AutomaticSize.X
	frame2.LayoutOrder = 2
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 2)
	uiListLayout2.Parent = frame2

	local frame3 = Style.frame(frame2, "Robux", UDim2.fromOffset(p3, p3))
	frame3.LayoutOrder = 1

	for _, v in {
		{ 4, Style.INK },
		{ 0, Style.WHITE }
	} do
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Image = "rbxasset://textures/ui/common/robux.png"
		icon.ImageColor3 = v[2]
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Size = UDim2.new(1, v[1], 1, v[1])
		icon.Parent = frame3
	end

	local label2 = Style.label(frame2, "Amount", "", p3, Style.FONT, 1.5)
	label2.RichText = true
	label2.TextColor3 = Style.WHITE
	label2.LayoutOrder = 2
	return frame, function(value: string?, text: string, textColor: Color3)
		label.Visible = value ~= nil
		label.Text = value or ""
		label.TextColor3 = textColor
		label2.Text = text
	end
end

function Style.nut(p, p2: number)
	local frame = Style.frame(p, "Nut", UDim2.fromOffset(p2, p2))

	for _, rotation in { 0, 45 } do
		local fill = Style.fill(
			frame,
			"Face",
			Style.HAZARD,
			UDim2.fromScale(0.78, 0.78),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = rotation
		Style.corner(fill, 2)
		Style.stroke(fill, 1.5, 0, nil, true)
	end

	local fill = Style.fill(
		frame,
		"Bore",
		Style.INK,
		UDim2.fromScale(0.34, 0.34),
		UDim2.fromScale(0.5, 0.5),
		Vector2.new(0.5, 0.5)
	)
	Style.corner(fill, p2)
	return frame
end

function Style.key(p, p2: string, p3: number)
	local box = Style.box(p, "Key", Style.HAZARD, UDim2.fromOffset(0, p3), 2, 1.5)
	box.AutomaticSize = Enum.AutomaticSize.X
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 4)
	uiPadding.PaddingRight = UDim.new(0, 4)
	uiPadding.Parent = box
	local label = Style.label(box, "Text", p2, p3 - 4, Style.FONT, 0)
	label.Size = UDim2.fromOffset(0, p3)
	label.TextColor3 = Style.INK
	return box
end

local v = {}

local v2 = {}
local v3 = {}
local fn
local function track(uiScale) -- 2 equivalent calls inferred from this helper
	if v[uiScale] then
		return
	end

	v[uiScale] = true
	uiScale.Destroying:Once(function()
		fn(uiScale)
	end)
end
local scale = 1
local callbacks = {}

function Style.computeScale(vector2: Vector2)
	local v4

	if Style.isTouch() then
		v4 = Style.REF_HEIGHT_TOUCH
	else
		v4 = Style.REF_HEIGHT
	end

	return (math.clamp(math.min(vector2.Y / v4, vector2.X / (v4 * 1.6)), 0.55, 2))
end

function Style.scale()
	return scale
end

function Style.onScale(callback)
	table.insert(callbacks, callback)
	callback(scale)
	return function()
		local index = table.find(callbacks, callback)

		if index then
			table.remove(callbacks, index)
		end
	end
end

local v4 = {}
fn = function(instance)
	v[instance] = nil
	v2[instance] = nil
	v4[instance] = nil
	v3[instance] = nil
end

local function keep(instance): boolean -- 2 equivalent calls inferred from this helper
	if instance:IsDescendantOf(game) then
		v3[instance] = true
		return true
	end

	if not v3[instance] and instance.Parent ~= nil then
		return true
	end

	fn(instance)
	return false
end

local fn2
local function refitAll()
	for k, v5 in table.clone(v4) do
		if keep(k) then -- inferred equivalent call
			fn2(k, v5)
		end
	end
end
local function refresh()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	scale = Style.computeScale(currentCamera.ViewportSize)

	for k in table.clone(v) do
		if not keep(k) or v4[k] then -- inferred equivalent call
			continue
		end

		k.Scale = scale * (v2[k] or 1)
	end

	for _, v5 in callbacks do
		v5(scale)
	end

	refitAll()
end

local v5 = nil
local viewportSizeChangedConnection = nil
local function watchCamera() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera == v5 then
		return
	end

	v5 = currentCamera

	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
	end

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
	end

	refresh()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera() -- inferred equivalent call

if not pcall(function()
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(refresh)
end) then
	warn("GameUI: GuiService.TopbarInset is not available; panels fit to the inset read at load")
end

function Style.scaler(parent)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = scale
	uiScale.Parent = parent
	track(uiScale) -- inferred equivalent call
	return uiScale
end

function Style.touchHud(): number
	return if Style.isTouch() then 1.15 else 1
end

function Style.boost(instance, p: number)
	local uiScale = instance:FindFirstChildOfClass("UIScale")
	assert(uiScale, "GameUI: Style.boost needs a Style.region")
	v2[uiScale] = p
	uiScale.Scale = scale * p
end

function Style.region(p, p2: string, anchorPoint: Vector2, vector2: Vector2, vector2_2: Vector2)
	local frame = Style.frame(p, p2, UDim2.fromOffset(vector2_2.X, vector2_2.Y))
	frame.AnchorPoint = anchorPoint
	frame.Position = UDim2.new(anchorPoint.X, vector2.X, anchorPoint.Y, vector2.Y)
	Style.scaler(frame)
	return frame
end

local v6 = {}

local v7 = {}
local function screenRef(instance)
	local playerGui = instance:FindFirstAncestorOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local screen = v6[playerGui]

	if screen then
		return screen
	end

	local styleScreenRef = Instance.new("ScreenGui")
	styleScreenRef.Name = "StyleScreenRef"
	styleScreenRef.IgnoreGuiInset = true
	styleScreenRef.ScreenInsets = Enum.ScreenInsets.None
	styleScreenRef.ResetOnSpawn = false
	styleScreenRef.Enabled = true
	styleScreenRef.Parent = playerGui
	screen = Instance.new("Frame")
	screen.Name = "Screen"
	screen.BackgroundTransparency = 1
	screen.Size = UDim2.fromScale(1, 1)
	screen.Parent = styleScreenRef
	v6[playerGui] = screen

	local styleSafeRef = Instance.new("ScreenGui")
	styleSafeRef.Name = "StyleSafeRef"
	styleSafeRef.IgnoreGuiInset = true
	styleSafeRef.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	styleSafeRef.ResetOnSpawn = false
	styleSafeRef.Parent = playerGui
	local safe = Instance.new("Frame")
	safe.Name = "Safe"
	safe.BackgroundTransparency = 1
	safe.Size = UDim2.fromScale(1, 1)
	safe.Parent = styleSafeRef
	v7[playerGui] = safe
	safe:GetPropertyChangedSignal("AbsoluteSize"):Connect(refitAll)

	screen:GetPropertyChangedSignal("AbsolutePosition"):Connect(refitAll)
	screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(refitAll)

	return screen
end

function Style.topOverlap(p)
	local v8 = screenRef(p)
	assert(v8, "GameUI: Style.topOverlap needs a frame in PlayerGui")
	return (math.max(0, v8.AbsolutePosition.Y + Style.topInset() - p.AbsolutePosition.Y))
end

fn2 = function(p, state)
	local parent = p.Parent
	local parent2 = parent and parent.Parent

	if not (parent and parent:IsA("GuiObject") and parent2 and parent2:IsA("GuiBase2d")) then
		return
	end

	local v8 = parent2.AbsolutePosition.Y
	local x = parent2.AbsoluteSize.X
	local y = parent2.AbsoluteSize.Y

	if x <= 0 or y <= 0 then
		local currentCamera = workspace.CurrentCamera
		local v9

		if currentCamera then
			v9 = currentCamera.ViewportSize
		else
			v9 = Vector2.new(1280, 720)
		end

		x = v9.X
		y = v9.Y
		v8 = 0
	end

	local v9 = screenRef(parent2)
	local v10

	if v9 and v9.AbsoluteSize.Y > 0 then
		v10 = v9.AbsolutePosition.Y
	else
		v10 = v8
	end

	local v11 = math.max(v8, v10 + Style.topInset()) + (not state.top and 0 or state.top())
	local v12 = v8 + y
	local v13 = math.max(1, v12 - v11)
	local v14 = scale

	local v15 = state.grow and 2 or 1

	if state.grow then
		local playerGui = parent2:FindFirstAncestorOfClass("PlayerGui")
		local v16 = playerGui and v7[playerGui]

		if v16 and v16.AbsoluteSize.X > 0 then
			x = math.min(x, v16.AbsoluteSize.X)
		end
	end

	state.base = v14 * math.min(v15, x * state.k / (state.size.X * v14), v13 * state.k / (state.size.Y * v14))

	if state.centred then
		local v16 = (v11 + v12) / 2 - (v8 + y / 2)
		parent.Position = UDim2.new(parent.Position.X, UDim.new(0.5, state.y0.Offset + v16))
	end

	p.Scale = state.base * state.pop
end

function Style.fit(instance, size: Vector2, value: number?, p)
	local uiScale = instance:FindFirstChildOfClass("UIScale")
	assert(uiScale, "GameUI: Style.fit needs a Style.region")
	local parent = instance.Parent
	assert(parent and parent:IsA("GuiBase2d"), "GameUI: Style.fit needs a region inside a layer or frame")
	local v8 = {
		size = size,
		k = value or 0.94,
		centred = instance.AnchorPoint.Y == 0.5 and instance.Position.Y.Scale == 0.5,
		y0 = instance.Position.Y,
		base = 1,
		pop = 1,
		grow = p ~= nil and p.grow == true,
		top = p and p.top
	}

	v4[uiScale] = v8
	track(uiScale) -- inferred equivalent call
	screenRef(parent)
	fn2(uiScale, v8)

	local object = setmetatable({ uiScale }, { __mode = "v" })
	local function refit()
		local v9 = object[1]
		local v10 = v9 and v4[v9]

		if v9 and v10 then
			fn2(v9, v10)
		end
	end
	local v9 = {
		parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit),
		parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(refit)
	}

	instance.Destroying:Once(function()
		for _, connection in v9 do
			connection:Disconnect()
		end
	end)
	return function(pop: number)
		v8.pop = pop
		uiScale.Scale = v8.base * pop
	end
end

function Style.layer(parent, name: string, displayOrder: number, flag: boolean?)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.IgnoreGuiInset = true

	if flag then
		screenGui.ScreenInsets = Enum.ScreenInsets.None
	end

	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = displayOrder
	screenGui.Parent = parent
	return screenGui
end

local v8 = {}
local renderSteppedConnection = nil

local v9 = {}
local v10 = false

local function drive(p: number)
	local now = os.clock()
	v10 = true

	for k, callback in v8 do
		local success, result = xpcall(callback, debug.traceback, p, now)

		if success then
			if not result and v8[k] == callback then
				v8[k] = nil
			end
		else
			if v8[k] == callback then
				v8[k] = nil
			end

			task.spawn(error, result, 0)
		end
	end

	v10 = false

	if next(v9) ~= nil then
		for k, v11 in v9 do
			v8[k] = v11
		end

		table.clear(v9)
	end

	if next(v8) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

function Style.animate(p, callback)
	if v10 and v8[p] == nil then
		v9[p] = callback
	else
		v8[p] = callback
		v9[p] = nil
	end

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(drive)
	end
end

function Style.stop(p)
	v8[p] = nil
	v9[p] = nil
end

function Style.easeOut(value: number)
	local v11 = math.clamp(value, 0, 1)
	return 1 - (1 - v11) * (1 - v11) * (1 - v11)
end

function Style.easeIn(value: number)
	local v11 = math.clamp(value, 0, 1)
	return v11 * v11 * v11
end

function Style.smooth(value: number)
	local v11 = math.clamp(value, 0, 1)
	return v11 * v11 * (3 - v11 * 2)
end

function Style.pop(value: number)
	local v11 = math.clamp(value, 0, 1)

	return (v11 - 1) ^ 3 * 2.8 + 1 + (v11 - 1) ^ 2 * 1.8
end

function Style.supplyIcon(p, p2: number)
	local box = Style.box(p, "Crate", Color3.fromRGB(176, 128, 74), UDim2.fromOffset(p2, p2), 2, 1.5)

	for _, rotation in { 45, -45 } do
		local fill = Style.fill(
			box,
			"Brace",
			Color3.fromRGB(120, 82, 44),
			UDim2.new(1.25, 0, 0, 2),
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		fill.Rotation = rotation
	end

	box.ClipsDescendants = true
	return box
end

Style.CLOSE_SIZE = 44
function Style.closeButton(p)
	return (Style.button(
		p,
		"Close",
		"X",
		Style.ORANGE,
		UDim2.fromOffset(Style.CLOSE_SIZE, Style.CLOSE_SIZE),
		Style.INK,
		24
	))
end

return Style