local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Players = game:GetService("Players")

local Style = require(script.Parent:WaitForChild("Style"))

local Glyph = {}

local hazard = Style.HAZARD
local ink = Style.INK

local set = {
	[Enum.KeyCode.LeftAlt] = true,
	[Enum.KeyCode.RightAlt] = true,
	[Enum.KeyCode.LeftSuper] = true,
	[Enum.KeyCode.RightSuper] = true,
	[Enum.KeyCode.LeftMeta] = true,
	[Enum.KeyCode.RightMeta] = true
}

local lastTime = -1e999
local v = -1e999
local total = 0
local count = 0

local v2 = "keyboard"
local v3 = "xbox"
local v4 = {}
local v5 = nil
local v6 = false

local function padConnected(): boolean -- 4 equivalent calls inferred from this helper
	return #UserInputService:GetConnectedGamepads() > 0
end

local function padHere() -- 2 equivalent calls inferred from this helper
	return v5 ~= "keyboard"
		and (GuiService:IsTenFootInterface() or padConnected() or UserInputService.PreferredInput == Enum.PreferredInput.Gamepad) -- inferred equivalent call
end

local function readMode(): string -- 2 equivalent calls inferred from this helper
	if GuiService:IsTenFootInterface() then
		return if v5 == "keyboard" then "keyboard" else "gamepad"
	end

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		return "touch"
	end

	if v5 == "gamepad" and padConnected() then -- inferred equivalent call
		return "gamepad"
	end

	if v5 == "keyboard" then
		return "keyboard"
	end

	if padHere() then -- inferred equivalent call
		return "gamepad"
	end

	return "keyboard"
end

local function readFamily(): string -- 2 equivalent calls inferred from this helper
	if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross" then
		return "ps"
	end

	return "xbox"
end

local function update()
	local mode = readMode() -- inferred equivalent call
	local family = readFamily() -- inferred equivalent call
	local v7 = padHere() -- inferred equivalent call

	if mode ~= v2 or family ~= v3 or v7 ~= v6 then
		v2 = mode
		v3 = family
		v6 = v7
		local RunService = game:GetService("RunService")

		if RunService:IsStudio() then
			print(
				"[Glyph]",
				v2,
				v3,
				"pad here",
				v6,
				"used",
				v5,
				"preferred",
				UserInputService.PreferredInput.Name,
				"ten foot",
				GuiService:IsTenFootInterface(),
				"pads",
				#UserInputService:GetConnectedGamepads()
			)
		end

		Players.LocalPlayer:SetAttribute("PadMode", v2 == "gamepad")

		for _, callback in v4 do
			task.spawn(callback)
		end
	end
end
local set2 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}

local function deviceOf(data): nil | string
	local userInputType = data.UserInputType

	if set2[userInputType] then
		local keyCode = data.KeyCode

		if keyCode == Enum.KeyCode.Thumbstick1 or keyCode == Enum.KeyCode.Thumbstick2 then
			if Vector2.new(data.Position.X, data.Position.Y).Magnitude >= 0.5 then
				return "gamepad"
			end

			return nil
		elseif keyCode == Enum.KeyCode.ButtonL2 or keyCode == Enum.KeyCode.ButtonR2 then
			return if data.Position.Z >= 0.5 then "gamepad" else nil
		elseif data.UserInputState == Enum.UserInputState.Begin then
			return "gamepad"
		else
			return nil
		end
	else
		if os.clock() - lastTime < 0.4 then
			return nil
		end

		if userInputType == Enum.UserInputType.Keyboard then
			return if not set[data.KeyCode] then "keyboard" else nil
		else
			if
				userInputType == Enum.UserInputType.MouseButton1
				or userInputType == Enum.UserInputType.MouseButton2
				or userInputType == Enum.UserInputType.MouseButton3
				or userInputType == Enum.UserInputType.MouseWheel
			then
				return "keyboard"
			end

			if userInputType ~= Enum.UserInputType.MouseMovement then
				return nil
			end

			local now = os.clock()

			if now - v > 0.15 then
				total = 0
				count = 0
			end

			v = now
			total += data.Delta.Magnitude
			count += 1

			if total >= 100 and count >= 4 then
				return "keyboard"
			end

			return nil
		end
	end
end

local function noteInput(input) -- 1 equivalent call inferred from this helper
	local v7 = deviceOf(input)

	if v7 and v7 ~= v5 then
		v5 = v7
		update()
	end
end

local inputChangedConnection = nil
local function listenMoves() -- 3 equivalent calls inferred from this helper
	if not inputChangedConnection then
		inputChangedConnection = UserInputService.InputChanged:Connect(noteInput)
	end
end

v2 = readMode() -- inferred equivalent call
v3 = readFamily() -- inferred equivalent call
v6 = false

if v5 ~= "keyboard" then
	v6 = GuiService:IsTenFootInterface()

	if not v6 then
		if padConnected() then -- inferred equivalent call
			v6 = true
		else
			v6 = false
		end

		if not v6 then
			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
				v6 = true
			else
				v6 = false
			end
		end
	end
end

Players.LocalPlayer:SetAttribute("PadMode", v2 == "gamepad")
UserInputService.WindowFocused:Connect(function()
	lastTime = os.clock()
end)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)

UserInputService.GamepadConnected:Connect(function()
	listenMoves() -- inferred equivalent call
	task.defer(update)
end)
UserInputService.GamepadDisconnected:Connect(function()
	task.defer(function()
		if v5 == "gamepad" and not padConnected() then -- inferred equivalent call
			v5 = nil
		end

		update()
	end)
end)
UserInputService.InputBegan:Connect(function(input)
	if not inputChangedConnection then
		local userInputType = input.UserInputType

		if
			set2[userInputType]
			or userInputType == Enum.UserInputType.MouseButton1
			or userInputType == Enum.UserInputType.MouseButton2
			or userInputType == Enum.UserInputType.MouseButton3
		then
			listenMoves() -- inferred equivalent call
		end
	end

	noteInput(input) -- inferred equivalent call
end)

if UserInputService.MouseEnabled or UserInputService.GamepadEnabled then
	listenMoves() -- inferred equivalent call
end

function Glyph.mode()
	return v2
end

function Glyph.gamepad(): boolean
	return v2 == "gamepad"
end

function Glyph.padHere()
	return v6
end

function Glyph.family()
	return v3
end

function Glyph.onChange(callback)
	table.insert(v4, callback)
	return function()
		local index = table.find(v4, callback)

		if index then
			table.remove(v4, index)
		end
	end
end

local v7 = {}

function Glyph.claim(p: string, flag: boolean)
	v7[p] = flag and true or nil
end

function Glyph.claimed(p: string?): boolean
	if p then
		return v7[p] == true
	end

	return next(v7) ~= nil
end

local v8 = {
	[Enum.KeyCode.ButtonA] = "A",
	[Enum.KeyCode.ButtonB] = "B",
	[Enum.KeyCode.ButtonX] = "X",
	[Enum.KeyCode.ButtonY] = "Y",
	[Enum.KeyCode.ButtonL1] = "LB",
	[Enum.KeyCode.ButtonR1] = "RB",
	[Enum.KeyCode.ButtonL2] = "LT",
	[Enum.KeyCode.ButtonR2] = "RT",
	[Enum.KeyCode.ButtonL3] = "LS",
	[Enum.KeyCode.ButtonR3] = "RS",
	[Enum.KeyCode.Thumbstick1] = "LS",
	[Enum.KeyCode.Thumbstick2] = "RS",
	[Enum.KeyCode.ButtonStart] = "MENU",
	[Enum.KeyCode.ButtonSelect] = "VIEW",
	[Enum.KeyCode.DPadUp] = "UP",
	[Enum.KeyCode.DPadDown] = "DOWN",
	[Enum.KeyCode.DPadLeft] = "LEFT",
	[Enum.KeyCode.DPadRight] = "RIGHT"
}

local v9 = {
	[Enum.KeyCode.ButtonA] = "CROSS",
	[Enum.KeyCode.ButtonB] = "CIRCLE",
	[Enum.KeyCode.ButtonX] = "SQUARE",
	[Enum.KeyCode.ButtonY] = "TRIANGLE",
	[Enum.KeyCode.ButtonL1] = "L1",
	[Enum.KeyCode.ButtonR1] = "R1",
	[Enum.KeyCode.ButtonL2] = "L2",
	[Enum.KeyCode.ButtonR2] = "R2",
	[Enum.KeyCode.ButtonL3] = "L3",
	[Enum.KeyCode.ButtonR3] = "R3",
	[Enum.KeyCode.Thumbstick1] = "L3",
	[Enum.KeyCode.Thumbstick2] = "R3",
	[Enum.KeyCode.ButtonStart] = "OPTIONS",
	[Enum.KeyCode.ButtonSelect] = "CREATE",
	[Enum.KeyCode.DPadUp] = "UP",
	[Enum.KeyCode.DPadDown] = "DOWN",
	[Enum.KeyCode.DPadLeft] = "LEFT",
	[Enum.KeyCode.DPadRight] = "RIGHT"
}

function Glyph.text(p)
	local v10 = if v3 == "ps" then v9 else v8
	return v10[p] or p.Name
end

local function bar(p, p2: number, p3: number, p4: number, p5: number, rotation: number, value: number?)
	local fill = Style.fill(p, "Bar", ink, UDim2.fromOffset(p2, p3), UDim2.new(0.5, p4, 0.5, p5), Vector2.new(0.5, 0.5))
	fill.Rotation = rotation
	fill.BackgroundTransparency = value or 0
	return fill
end

local function ring(p, p2: number, thickness: number, flag: boolean)
	local frame = Style.frame(p, "Ring", UDim2.fromOffset(p2, p2), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

	if flag then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.5, 0)
		uiCorner.Parent = frame
	end

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = thickness
	uiStroke.Color = ink
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local lineJoinMode

	if flag then
		lineJoinMode = Enum.LineJoinMode.Round
	else
		lineJoinMode = Enum.LineJoinMode.Miter
	end

	uiStroke.LineJoinMode = lineJoinMode
	uiStroke.Parent = frame
	return frame
end

local function capBox(p, p2: string, udim: UDim2, p3: number) -- 3 equivalent calls inferred from this helper
	local box = Style.box(p, p2, hazard, udim, p3, 1.5)
	local uiStroke = box:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.LineJoinMode = Enum.LineJoinMode.Round
	end

	return box
end

local function ink2(p, p2: string, p3: number)
	local label = Style.label(p, "Text", p2, p3, Style.FONT, 0)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = ink
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	return label
end

local function disc(p, p2: number) -- 2 equivalent calls inferred from this helper
	return capBox(p, "Disc", UDim2.fromOffset(p2, p2), math.ceil(p2 / 2)) -- inferred equivalent call
end

local function tab(p, p2: number, p3: string, p4: number)
	local parent = capBox(p, "Tab", UDim2.fromOffset(0, p2), p4) -- inferred equivalent call
	parent.AutomaticSize = Enum.AutomaticSize.X
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, (math.max(4, (math.floor(p2 * 0.28)))))
	uiPadding.PaddingRight = uiPadding.PaddingLeft
	uiPadding.Parent = parent
	local label = Style.label(parent, "Text", p3, p2 - 6, Style.FONT, 0)
	label.Size = UDim2.fromOffset(0, p2)
	label.TextColor3 = ink
	return parent
end

local set3 = {
	[Enum.KeyCode.ButtonA] = true,
	[Enum.KeyCode.ButtonB] = true,
	[Enum.KeyCode.ButtonX] = true,
	[Enum.KeyCode.ButtonY] = true
}

local vector2s = {
	[Enum.KeyCode.DPadUp] = Vector2.new(0, -1),
	[Enum.KeyCode.DPadDown] = Vector2.new(0, 1),
	[Enum.KeyCode.DPadLeft] = Vector2.new(-1, 0),
	[Enum.KeyCode.DPadRight] = Vector2.new(1, 0)
}

local set4 = {
	[Enum.KeyCode.ButtonL3] = true,
	[Enum.KeyCode.ButtonR3] = true,
	[Enum.KeyCode.Thumbstick1] = true,
	[Enum.KeyCode.Thumbstick2] = true
}

local set5 = { [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true }

local function psMark(p, p2, p3: number)
	local thickness = math.max(2, (math.floor(p3 * 0.11 + 0.5)))

	if p2 == Enum.KeyCode.ButtonA then
		bar(p, p3 * 0.56, thickness, 0, 0, 45)
		bar(p, p3 * 0.56, thickness, 0, 0, -45)
	else
		if p2 == Enum.KeyCode.ButtonB then
			ring(p, math.floor(p3 * 0.48), thickness, true)
			return
		end

		if p2 == Enum.KeyCode.ButtonX then
			ring(p, math.floor(p3 * 0.42), thickness, false)
			return
		end

		local v10 = p3 * 0.6
		local v11 = v10 * 1.7320508075688772 / 2
		local v12 = -p3 * 0.02
		bar(p, v10 + thickness * 0.5, thickness, 0, v11 / 3 + v12, 0)
		bar(p, v10 + thickness * 0.5, thickness, -v10 / 4, -v11 / 6 + v12, -60)
		bar(p, v10 + thickness * 0.5, thickness, v10 / 4, -v11 / 6 + v12, 60)
	end
end

local function drawPad(p, p2, p3: number)
	local v10 = typeof(p2) ~= "table" and { p2 } or p2
	local v11 = v10[1]

	if vector2s[v11] then
		local box = capBox(p, "DPad", UDim2.fromOffset(p3, p3), math.max(2, (math.floor(p3 * 0.18)))) -- inferred equivalent call
		local v12 = math.max(3, (math.floor(p3 * 0.24 + 0.5)))
		local v13 = math.floor(p3 * 0.74)
		bar(box, v13, v12, 0, 0, 0, 0.62)
		bar(box, v12, v13, 0, 0, 0, 0.62)

		for _, v14 in v10 do
			local v15 = vector2s[v14]

			if not v15 then
				continue
			end

			local v16 = (v13 - v12) / 2
			local v17

			if v15.X == 0 then
				v17 = v12
			else
				v17 = v16 + v12 / 2
			end

			local v18

			if v15.Y == 0 then
				v18 = v12
			else
				v18 = v16 + v12 / 2
			end

			bar(box, v17, v18, v15.X * (v16 / 2 + v12 / 4), v15.Y * (v16 / 2 + v12 / 4), 0)
		end
	elseif set3[v11] then
		local v12 = disc(p, p3) -- inferred equivalent call

		if v3 == "ps" then
			psMark(v12, v11, p3)
		else
			ink2(v12, v8[v11], p3 - 4)
		end
	elseif set4[v11] then
		local v12 = disc(p, p3) -- inferred equivalent call
		ring(v12, p3 - math.max(4, (math.floor(p3 * 0.22))), 1, true)
		ink2(v12, Glyph.text(v11), math.floor(p3 * 0.48))
	elseif set5[v11] then
		tab(p, p3, Glyph.text(v11), math.ceil(p3 / 2))
	else
		tab(p, p3, Glyph.text(v11), math.max(3, (math.floor(p3 * 0.3))))
	end
end

local function holderFrame(p, p2: number)
	local frame = Style.frame(p, "Glyph", UDim2.fromOffset(0, p2))
	frame.AutomaticSize = Enum.AutomaticSize.X
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame
	return frame
end

local function clear(folder)
	for _, uiListLayout in folder:GetChildren() do
		if not uiListLayout:IsA("UIListLayout") then
			uiListLayout:Destroy()
		end
	end
end

function Glyph.draw(p, p2, p3: number)
	local parent = holderFrame(p, p3)
	drawPad(parent, p2, p3)
	return parent
end

local v10 = {}
local function track(instance, p) -- 2 equivalent calls inferred from this helper
	v10[instance] = p
	instance.Destroying:Once(function()
		v10[instance] = nil
	end)
end

local function paintCap(folder, state)
	local shown = nil
	local v11

	if v2 == "gamepad" or state.always == true then
		v11 = state.pad ~= nil
	else
		v11 = false
	end

	if v11 then
		local pad = state.pad
		local v12

		if typeof(pad) == "table" then
			local names = {}

			for _, v13 in pad do
				table.insert(names, v13.Name)
			end

			v12 = table.concat(names, ",")
		else
			v12 = pad.Name
		end

		shown = "pad:" .. v3 .. ":" .. v12
	elseif v2 == "keyboard" and state.key then
		shown = "key:" .. state.key
	end

	if shown == state.shown then
		return
	end

	state.shown = shown
	clear(folder)
	folder.Visible = shown ~= nil

	if not shown then
		return
	end

	if v11 then
		drawPad(folder, state.pad, state.height)
	else
		Style.key(folder, state.key, state.height)
	end

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = folder.ZIndex
		end
	end
end

Glyph.onChange(function()
	for k, v11 in v10 do
		if k.Parent then
			paintCap(k, v11)
		end
	end
end)

function Glyph.cap(p, p2: string?, pad, height: number)
	local parent = holderFrame(p, height)
	local v11 = { key = p2, pad = pad, height = height, shown = "" }
	track(parent, v11) -- inferred equivalent call
	paintCap(parent, v11)
	return parent
end

function Glyph.padCap(p, pad, height: number)
	local parent = holderFrame(p, height)
	local v11 = { pad = pad, height = height, shown = "", always = true }
	track(parent, v11) -- inferred equivalent call
	paintCap(parent, v11)
	return parent
end

function Glyph.setCap(p, p2: string?, pad)
	local v11 = v10[p]

	if not v11 then
		return
	end

	if v11.key ~= p2 or v11.pad ~= pad then
		v11.key = p2
		v11.pad = pad
		v11.shown = ""
	end

	paintCap(p, v11)
end

return Glyph